CREATE PROCEDURE CancellUnfilledReservations
AS BEGIN
  UPDATE DayReservations
  SET Cancelled = 1
  WHERE ID IN (SELECT DayReservationID FROM ClientsToCall)
end
