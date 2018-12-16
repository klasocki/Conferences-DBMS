
CREATE TRIGGER TooSmallPlaceLimitForDay ON dbo.Days
  AFTER UPDATE
  AS BEGIN
    IF EXISTS(SELECT * FROM Inserted
	WHERE(dbo.DayPlacesLeft(Inserted.ID) < 0)
	)
	BEGIN
  	;THROW 51000, 'place limit lower than attendees count that have reservation for it', 1
  	ROLLBACK
	end
END