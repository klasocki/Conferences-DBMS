CREATE TRIGGER ReservationCancelled
  ON DayReservations
  AFTER UPDATE
  AS
BEGIN
  IF (inserted.Cancelled = 1)
    BEGIN
      UPDATE WorkshopReservations
      SET Cancelled = 1
      WHERE DayReservationID = inserted.ID
    end
end
GO

CREATE TRIGGER ConferenceCancelled
  ON Conferences
  AFTER UPDATE
  AS
BEGIN
  IF (inserted.Cancelled = 1)
    BEGIN
      UPDATE DayReservations
      SET Cancelled = 1
      WHERE (SELECT ConferenceID
             FROM ConferenceReservations
             WHERE ConferenceReservations.ID = ReservationID) = inserted.ID
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
    ) --(@ResConfID != @DayConfID)
    BEGIN
      THROW 51000, 'Day of reservation is not a day of the conference associated with this reservation', 1
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
              >= (SELECT COUNT(*)
                  FROM AttendeesDay
                  WHERE DayReservationID = inserted.DayReservationID)
       ) OR EXISTS(
         SELECT *
         FROM inserted
         WHERE (SELECT StudentCount
                FROM DayReservations
                WHERE DayReservations.ID = inserted.DayReservationID)
           >= (SELECT COUNT(*)
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
