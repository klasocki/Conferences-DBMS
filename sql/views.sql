CREATE VIEW UpcomingConferences AS
  SELECT Name, StartDate, DayNum, PlaceLimit, PlaceLimit - (
    SELECT SUM(PlaceCount)
    FROM DayReservations
    WHERE DayID = Days.ID
    ) as FreePlaces
  FROM Conferences JOIN Days on Conferences.ID = Days.ConferenceID
  WHERE StartDate > GETDATE()
  ORDER BY StartDate, DayNum