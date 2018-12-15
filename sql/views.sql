CREATE VIEW UpcomingConferences AS
SELECT Name,
       StartDate,
       DayNum,
       PlaceLimit,
       PlaceLimit - (
         SELECT SUM(PlaceCount)
         FROM DayReservations
         WHERE DayID = Days.ID
       ) as FreePlaces
FROM Conferences
       JOIN Days on Conferences.ID = Days.ConferenceID
WHERE StartDate > GETDATE()

CREATE VIEW DayReservationDetails AS
SELECT C.ID as ClientID,
       C.Name                     as ClientName,
       CR.ID                      as ReservationId,
       Conf.ID as ConferenceID,
       Conf.Name                  as ConferenceName,
       DayNum,
       PlaceCount - StudentCount  as AdultCount,
       StudentCount,
       (SELECT TOP 1 Price
        FROM PriceThresholds
               JOIN Days InnD on PriceThresholds.DayID = InnD.ID
               JOIN Conferences InnC on InnD.ConferenceID = InnC.ID
        WHERE PriceThresholds.DayID = D.ID
          AND (DATEDIFF(day, CR.ReservationDate, StartDate) >= DaysBefore)
        ORDER BY DaysBefore DESC) as PriceForAdult,
       StudentDiscount
FROM DayReservations DR
       JOIN ConferenceReservations CR on DR.ReservationID = CR.ID
       JOIN Clients C on CR.ClientID = C.ID
       JOIN Conferences Conf on CR.ConferenceID = Conf.ID
       JOIN Days D on Conf.ID = D.ConferenceID


CREATE VIEW ReservationDetails AS
SELECT ClientID,
       ClientName,
       ReservationID,
       dbo.isCancelled(ReservationId) as isCancelled,
       ConferenceName,
       ConferenceID,
       SUM(AdultCount * PriceForAdult + StudentCount * (1 - StudentDiscount))
         AS PriceToPayForEntries,
       (SELECT SUM(Price * WR.PlaceCount)
        FROM WorkshopReservations WR
               JOIN
             Workshops W on WR.WorkshopID = W.ID
               JOIN DayReservations R on WR.DayReservationID = R.ID
        WHERE R.ReservationID = DayReservationDetails.ReservationID
       ) as PriceToPayForWorkshops
FROM DayReservationDetails
GROUP BY ClientID, ClientName, ReservationId, ConferenceName, ConferenceID

CREATE VIEW TopTenClients
AS
SELECT TOP 10 ID,
              Name,
              (SELECT SUM(PlaceCount)
               FROM DayReservations
                      JOIN ConferenceReservations CR on DayReservations.ReservationID = CR.ID
               WHERE ClientID = Clients.ID
                 AND Cancelled = 0) as TotalPlacesBooked
FROM Clients
ORDER BY TotalPlacesBooked


CREATE VIEW ClientDueAmount
AS
SELECT ClientID, ClientName,
       SUM(PriceToPayForEntries + PriceToPayForWorkshops) as MoneyToPay,
       (SELECT SUM(Amount) FROM Payments
       JOIN ConferenceReservations CR on Payments.ConferenceReservationID = CR.ID
         WHERE ReservationDetails.ClientID = CR.ClientID) as MoneyPaid
FROM ReservationDetails
WHERE isCancelled = 0
GROUP BY ClientID, ClientName