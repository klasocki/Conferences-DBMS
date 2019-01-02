CREATE PROCEDURE [dbo].[ChangeDayReservationPlaceCount]
	-- Add the parameters for the stored procedure here
	@ID int,
	@PlaceCount int
AS
BEGIN
	IF NOT EXISTS
	(
		SELECT * FROM WorkshopReservations
		WHERE ID = @ID
	)
	BEGIN
		;THROW 52000,'Workshop Reservation does not exist',1
	END
	UPDATE dbo.WorkshopReservations
		SET PlaceCount = @PlaceCount
		WHERE ID = @ID

END
GO
