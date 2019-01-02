CREATE TRIGGER TooBigWorkshopPlaceCount ON dbo.Workshops
  AFTER INSERT, UPDATE
  AS BEGIN
    IF EXISTS(SELECT * FROM inserted
	WHERE ((SELECT D.Placelimit FROM dbo.Days D WHERE D.ID = Inserted.DayID)  < inserted.PlaceLimit))
	BEGIN
  	;THROW 51000, 'More Place Limit in workshop than in Conference Day', 1
  	ROLLBACK
	end
END