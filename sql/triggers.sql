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