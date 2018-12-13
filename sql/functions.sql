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
                   D.PlaceLimit,
                   D.PlaceLimit - (
                     SELECT SUM(PlaceCount)
                     FROM WorkshopReservations
                     WHERE WorkshopID = W.ID
                   ) as PlacesLeft,
                   Description
            FROM Workshops W
                   JOIN Days D on W.DayID = D.ID
          )

-- TODO check if this could be simplified
CREATE FUNCTION IsCancelled(@ConferenceReservationID INT)
  RETURNS BIT
AS
  BEGIN
--reservation is cancelled, if it hasn't got any uncancelled day reservations
    IF ( NOT EXISTS(SELECT * FROM DayReservations
      WHERE DayReservations.ReservationID = @ConferenceReservationID
      AND Cancelled = 0) )
        RETURN 1;
    RETURN 0;
  end
