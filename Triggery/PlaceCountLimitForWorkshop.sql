CREATE TRIGGER PlaceCountLimitForWorkshop ON dbo.AttendeesWorkshop
  AFTER INSERT
  AS BEGIN
  IF EXISTS(SELECT * FROM inserted
	join dbo.WorkshopReservations
	ON WorkshopReservations.ID = Inserted.WorkshopReservationID


  	WHERE dbo.WorkshopPlacesLeft(WorkshopID) < 0
	)
	BEGIN
  	;THROW 51000, 'PlaceLimit has been exceeded', 1
  	ROLLBACK
	end
end