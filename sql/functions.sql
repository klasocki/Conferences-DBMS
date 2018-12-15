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

CREATE FUNCTION Balance(@ConferenceReservationID INT)
  RETURNS NUMERIC(10, 2)
AS
BEGIN
  RETURN
    (SELECT (SELECT SUM(Amount)
             FROM Payments
             WHERE ConferenceReservationID = @ConferenceReservationID) - (PriceToPayForWorkshops + PriceToPayForEntries)
     FROM ReservationDetails
     WHERE @ConferenceReservationID = ReservationID)
end