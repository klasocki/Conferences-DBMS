CREATE PROCEDURE [dbo].[ChangeDayReservationPlaceCount]
	-- Add the parameters for the stored procedure here
	@ID int,
	@PlaceCount INT,
    @StudentCount INT
AS
BEGIN
	IF NOT EXISTS
	(
		SELECT * FROM WorkshopReservations
		WHERE ID = @ID
	)
	BEGIN
		;THROW 52000,'Conference Day Reservation does not exist',1
	END
	UPDATE dbo.DayReservations
		SET PlaceCount = @PlaceCount,
		StudentCount = @StudentCount
		WHERE ID = @ID

END
GO