

CREATE TRIGGER PlaceCountLimitForConferenceDay ON dbo.AttendeesDay
  AFTER INSERT
  AS BEGIN
  IF EXISTS(SELECT * FROM inserted
	join dbo.DayReservations
	ON DayReservations.ID = Inserted.DayReservationID


  	WHERE dbo.WorkshopPlacesLeft(DayID) < 0
	)
	BEGIN
  	;THROW 51000, 'PlaceLimit has been exceeded', 1
  	ROLLBACK
	end
end

