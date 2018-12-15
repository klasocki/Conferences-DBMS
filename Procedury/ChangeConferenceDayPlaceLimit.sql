CREATE PROCEDURE [dbo].[ChangeConferenceDayPlaceLimit]
	-- Add the parameters for the stored procedure here
	@ID int,
	@PlaceLimit int
AS
BEGIN
	IF NOT EXISTS
	(
		SELECT * FROM dbo.Days
		WHERE ID = @ID
	)
	BEGIN
		;THROW 52000, 'Conference Day does not exist',1
	END
	UPDATE dbo.Days
		SET PlaceLimit = @PlaceLimit
		WHERE ID = @ID

END
GO