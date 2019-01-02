CREATE TRIGGER DayReservationCancelled
  ON DayReservations
  AFTER UPDATE
  AS
BEGIN
  IF EXISTS(SELECT * FROM inserted WHERE inserted.Cancelled = 1)
    BEGIN
      UPDATE WorkshopReservations
      SET Cancelled = 1
      WHERE DayReservationID IN (SELECT inserted.ID FROM inserted)
    end
end
GO

CREATE TRIGGER ReservationCancelled
  ON ConferenceReservations
  AFTER UPDATE
  AS
BEGIN
  IF EXISTS(SELECT * FROM inserted WHERE inserted.Cancelled = 1)
    BEGIN
      UPDATE DayReservations
      SET Cancelled = 1
      WHERE ReservationID IN (SELECT inserted.ID FROM inserted)
    end
end
GO

CREATE TRIGGER ConferenceCancelled
  ON Conferences
  AFTER UPDATE
  AS
BEGIN
  IF EXISTS(SELECT * FROM inserted WHERE inserted.Cancelled = 1)
    BEGIN
      UPDATE ConferenceReservations
      SET Cancelled = 1
      WHERE ConferenceID IN (SELECT inserted.ID FROM inserted)
    end
end
GO

CREATE TRIGGER DayReservationNotInConference
  ON DayReservations
  AFTER INSERT, UPDATE
  AS
BEGIN
  IF EXISTS(
      SELECT *
      FROM inserted
             JOIN ConferenceReservations CR ON inserted.ReservationID = CR.ID
             JOIN Days D on inserted.DayID = D.ID
      WHERE D.ConferenceID != CR.ConferenceID
    )
    BEGIN
      THROW 51000, 'Day of reservation is not a day of the conference associated with this reservation', 1
      ROLLBACK
    end
end
GO

CREATE TRIGGER WorkshopReservationNotInDay
  ON WorkshopReservations
  AFTER INSERT, UPDATE
  AS
BEGIN
  IF EXISTS(
      SELECT *
      FROM inserted
             JOIN DayReservations DR ON inserted.DayReservationID = DR.ID
             JOIN Workshops W ON W.ID = inserted.WorkshopID
      WHERE W.DayID != DR.DayID
    )
    BEGIN
      THROW 51000, 'Day of the workshop reserved is not the day associated with this reservation', 1
      ROLLBACK
    end
end
GO

CREATE TRIGGER TooManyReservationAttendees
  ON AttendeesDay
  AFTER INSERT
  AS
BEGIN
  IF EXISTS(SELECT *
            FROM inserted
            WHERE (SELECT PlaceCount
                   FROM DayReservations
                   WHERE DayReservations.ID = inserted.DayReservationID)
                    < (SELECT COUNT(*)
                       FROM AttendeesDay
                       WHERE DayReservationID = inserted.DayReservationID)
       ) OR EXISTS(
         SELECT *
         FROM inserted
         WHERE (SELECT StudentCount
                FROM DayReservations
                WHERE DayReservations.ID = inserted.DayReservationID)
                 < (SELECT COUNT(*)
                    FROM AttendeesDay
                    WHERE DayReservationID = inserted.DayReservationID
                      AND AttendeesDay.IsStudent = 1)
       )
    BEGIN
      THROW 51000, 'All places of your reservation are already taken', 1
      ROLLBACK
    end
end
GO

CREATE TRIGGER TooManyWorkshopAttendees
  ON AttendeesWorkshop
  AFTER INSERT
  AS
BEGIN
  IF EXISTS(SELECT *
            FROM inserted
            WHERE (SELECT PlaceCount
                   FROM WorkshopReservations
                   WHERE WorkshopReservations.ID = inserted.WorkshopReservationID)
                    < (SELECT COUNT(*)
                       FROM AttendeesWorkshop
                       WHERE AttendeesWorkshop.WorkshopReservationID = inserted.WorkshopReservationID)
    )
    BEGIN
      THROW 51000, 'All places of your reservation are already taken', 1
      ROLLBACK
    end
end
GO

CREATE TRIGGER DayNumInvalid
  ON Days
  AFTER INSERT, UPDATE
  AS
BEGIN
  IF EXISTS(SELECT *
            FROM inserted
            WHERE (SELECT DATEDIFF(day, StartDate, EndDate)
                   FROM Conferences
                   WHERE Conferences.ID = inserted.ConferenceID) < inserted.DayNum)
    BEGIN
      THROW 51000, 'Too big day number for this conference', 1
      ROLLBACK
    end
end

CREATE TRIGGER NoStudentCardNum
  ON AttendeesDay
  AFTER INSERT , UPDATE
  AS
BEGIN
  IF EXISTS(SELECT *
            FROM inserted
            WHERE inserted.IsStudent = 1
              AND inserted.StudentCardNum IS NULL
    )
    BEGIN
      THROW 51000, 'Student card number is necessary for student attendees', 1
      ROLLBACK
    end
end

CREATE TRIGGER TooLateReservation
  ON ConferenceReservations
  AFTER INSERT, UPDATE
  AS
BEGIN
  IF EXISTS(
      SELECT *
      FROM inserted
      WHERE (
                DATEDIFF(day, inserted.ReservationDate, (
                  SELECT StartDate
                  FROM Conferences
                  WHERE Conferences.ID = inserted.ConferenceID
                )) < 0
              )
    )
    BEGIN
      THROW 51000, 'This conference has already started', 1
      ROLLBACK
    end
end

CREATE TRIGGER NoPriceForConference
  ON ConferenceReservations
  AFTER INSERT
  AS
BEGIN
  IF EXISTS(SELECT *
            FROM inserted
            WHERE EXISTS(
                      SELECT *
                      FROM Days
                      WHERE Days.ConferenceID = inserted.ConferenceID
                        AND NOT EXISTS(SELECT * FROM PriceThresholds WHERE DayID = Days.ID AND DaysBefore = 0)
                    ))
    BEGIN
      THROW 51000, 'There must be a PriceThreshold for 0 DaysBefore for every conference Day before you can make any reservations', 1
      ROLLBACK
    end
end
GO


CREATE TRIGGER InvalidPaymentDate
  ON Payments AFTER INSERT, UPDATE
  AS
BEGIN
  IF EXISTS(SELECT *
            FROM inserted
  --check if payment date is before reservation date, or after
  --conference start date
            WHERE (DATEDIFF(day, (SELECT ReservationDate
                                  FROM ConferenceReservations
                                  WHERE ID = inserted.ConferenceReservationID),
                            inserted.PayDate) < 0
              OR (DATEDIFF(day, inserted.PayDate,
                           (SELECT StartDate
                            FROM Conferences
                                   JOIN
                                 ConferenceReservations CR
                                 ON Conferences.ID = CR.ConferenceID
                                   JOIN inserted
                                        ON inserted.ConferenceReservationID = CR.ID)
                    ) < 0)))
    BEGIN
      THROW 51000,
        'There must be a PriceThreshold for 0 DaysBefore for every conference Day before you can make any reservations',
        1
      ROLLBACK
    end
end