CREATE TRIGGER AlreadyEnrolledAtThisTimeSlot ON dbo.AttendeesWorkshop
  AFTER INSERT, UPDATE
  AS BEGIN
    IF EXISTS(SELECT * FROM Inserted
	JOIN dbo.WorkshopReservations W1
	ON W1.ID = Inserted.WorkshopReservationID
	JOIN dbo.Workshops W11
	ON W11.ID = W1.WorkshopID
	JOIN dbo.Workshops W22
	ON W22.ID = W1.WorkshopID
	WHERE (W11.DayID = W22.DayID) AND w11.ID <> W22.ID and
	 ((W11.StartHour >= W22.StartHour and W11.StartHour <= W22.EndHour) OR
     (W11.EndHour >= W22.StartHour and W11.StartHour <= W22.EndHour) OR
	  (W22.StartHour >= W11.StartHour and W22.StartHour <= W11.EndHour) OR
     (W22.EndHour >= W11.StartHour and W22.StartHour <= W11.EndHour)
	 )

	)
	BEGIN
  	;THROW 51000, 'Attendee is already registered for another workshop at that time', 1
  	ROLLBACK
	end
END