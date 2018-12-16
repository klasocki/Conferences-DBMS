CREATE TRIGGER TooManyReservationsForWorkshop ON dbo.WorkshopReservations
  AFTER INSERT, UPDATE
  AS BEGIN
    IF EXISTS(SELECT * FROM inserted
	WHERE ((SELECT D.PlaceCount 
  	FROM dbo.DayReservations D WHERE D.ID = Inserted.DayReservationID)  < inserted.PlaceCount))
	BEGIN
  	;THROW 51000, 'More PlaceCount in workshop reservation than in Day reservation', 1
  	ROLLBACK
	end
END