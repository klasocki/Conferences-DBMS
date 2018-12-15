CREATE FUNCTION WorkshopDetails(@conferenceID INT)
  RETURNS TABLE
    AS
    RETURN
          (
            SELECT Name,
                   DayNum,
                   StartHour,
                   EndHour,
                   Price,
                   W.PlaceLimit,
                   dbo.WorkshopPlacesLeft(W.ID)
                     as
                     PlacesLeft,
                   Description
            FROM Workshops W
                   JOIN
                 Days D
                 on W.DayID = D.ID
            WHERE ConferenceID = @conferenceID
          )
GO

CREATE FUNCTION WorkshopPlacesLeft(@WorkshopID INT)
  RETURNS INT
AS
BEGIN
  RETURN (SELECT W.PlaceLimit - (
    SELECT SUM(PlaceCount)
    FROM WorkshopReservations
    WHERE WorkshopID = W.ID
  )
          FROM Workshops W
          WHERE ID = @WorkshopID
  )
end
GO


CREATE FUNCTION IsCancelled(@ConferenceReservationID INT)
  RETURNS BIT
AS
BEGIN
  --reservation is cancelled, if it hasn't got any uncancelled day reservations
  IF (NOT EXISTS(SELECT *
                 FROM DayReservations
                 WHERE DayReservations.ReservationID = @ConferenceReservationID
                   AND Cancelled = 0))
    RETURN 1;
  RETURN 0;
end
GO

CREATE FUNCTION Balance(@ConferenceReservationID INT)
  RETURNS NUMERIC(10, 2)
AS
BEGIN
  RETURN
    (SELECT (SELECT ISNULL(SUM(Amount), 0)
             FROM Payments
             WHERE ConferenceReservationID = @ConferenceReservationID) - dbo.ReservationCost(@ConferenceReservationID)
     FROM ReservationDetails
     WHERE @ConferenceReservationID = ReservationID)
end
GO

CREATE FUNCTION DayPlacesLeft(@DayID INT)
  RETURNS INT
AS
BEGIN
  RETURN (
    SELECT (SELECT PlaceLimit FROM Days WHERE ID = @DayID) -
           (SELECT SUM(PlaceCount)
            FROM DayReservations
            WHERE DayID = @DayID)
  )
end
GO

CREATE FUNCTION ReservationCost(@ReservationID INT)
  RETURNS NUMERIC(10, 2)
AS
BEGIN
  RETURN (SELECT ISNULL(PriceToPayForEntries + PriceToPayForWorkshops, 0)
          FROM ReservationDetails
          WHERE ReservationID = @ReservationID)
end
GO

CREATE FUNCTION DayAttendees(@DayID INT)
  RETURNS TABLE
    AS RETURN
          (
            SELECT ReservationID, DayReservationID, FirstName, LastName, Email, IsStudent, StudentCardNum
            FROM Attendees A
                   JOIN AttendeesDay AD on A.ID = AD.AttendeeID
                   JOIN DayReservations DR on AD.DayReservationID = DR.ID
            WHERE DayID = @DayID
          )
GO

CREATE FUNCTION WorkshopAttendees(@WorkshopID INT)
  RETURNS TABLE AS
    RETURN
          (
            SELECT ReservationID, WorkshopReservationID, FirstName, LastName, Email, IsStudent, StudentCardNum
            FROM Attendees A
                   JOIN AttendeesDay AD on A.ID = AD.AttendeeID
                   JOIN AttendeesWorkshop AW ON AD.ID = AW.AttendeeDayID
                   JOIN WorkshopReservations WR on AW.WorkshopReservationID = WR.ID
                   JOIN DayReservations DR on WR.DayReservationID = DR.ID
            WHERE WorkshopID = @WorkshopID
          )
GO

