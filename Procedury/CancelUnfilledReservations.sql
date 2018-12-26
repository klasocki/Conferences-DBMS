CREATE PROCEDURE CancellUnfilledReservations(@DaysBefore INT)
AS
BEGIN
  UPDATE DayReservations
  SET Cancelled = 1
  WHERE ID IN (
    SELECT DayReservationID
    FROM ClientsToCall
    WHERE DaysToConferenceStart <= @DaysBefore)
end
