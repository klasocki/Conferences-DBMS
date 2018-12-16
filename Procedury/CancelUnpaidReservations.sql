
CREATE PROCEDURE [dbo].[CancelUnpaidReservations]
AS
BEGIN
	UPDATE dbo.DayReservations
	SET Cancelled = 1
	FROM dbo.DayReservations DR
	JOIN dbo.ConferenceReservations CR
	ON CR.ID = DR.ReservationID
	WHERE DATEDIFF(DAY, CR.ReservationDate, GETDATE()) > 7 AND dbo.Balance(CR.ID) <> 0


END
GO


