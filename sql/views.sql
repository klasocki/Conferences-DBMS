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
GO


CREATE VIEW DayReservationDetails AS
SELECT C.ID                       as ClientID,
       C.Name                     as ClientName,
       CR.ID                      as ReservationId,
       Conf.ID                    as ConferenceID,
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
GO


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
       )                              as PriceToPayForWorkshops
FROM DayReservationDetails
GROUP BY ClientID, ClientName, ReservationId, ConferenceName, ConferenceID
GO

drop view TopTenClients
CREATE VIEW TopTenClients
AS
SELECT TOP 10 ID,
              Name,
              (SELECT SUM(ISNULL(PlaceCount, 0))
               FROM DayReservations
                      JOIN ConferenceReservations CR on DayReservations.ReservationID = CR.ID
               WHERE ClientID = Clients.ID
                 AND Cancelled = 0
              ) as TotalPlacesBooked
FROM Clients
WHERE (SELECT SUM(ISNULL(PlaceCount, 0))
               FROM DayReservations
                      JOIN ConferenceReservations CR on DayReservations.ReservationID = CR.ID
               WHERE ClientID = Clients.ID
                 AND Cancelled = 0
              ) IS NOT NULL
ORDER BY TotalPlacesBooked DESC
GO


CREATE VIEW ClientDueAmount
AS
SELECT ClientID,
       ClientName,
       SUM(PriceToPayForEntries + PriceToPayForWorkshops) as MoneyToPay,
       (SELECT SUM(Amount)
        FROM Payments
               JOIN ConferenceReservations CR on Payments.ConferenceReservationID = CR.ID
        WHERE ReservationDetails.ClientID = CR.ClientID)  as MoneyPaid
FROM ReservationDetails
WHERE isCancelled = 0
GROUP BY ClientID, ClientName
GO


CREATE VIEW UnpaidReservations AS
SELECT ClientID,
       ClientName,
       ReservationID,
       (SELECT ReservationDate
        FROM ConferenceReservations
        WHERE ID = ReservationID)                      as ReservationDate,
       (PriceToPayForEntries + PriceToPayForWorkshops) as TotalPriceToPay,
       (SELECT SUM(Amount)
        FROM Payments
        WHERE ConferenceReservationID = ReservationID) as PaidAmount,
       (- dbo.Balance(ReservationID))                  as PriceToPayLeft
FROM ReservationDetails
WHERE isCancelled = 0
  AND dbo.Balance(ReservationID) < 0
GO


CREATE VIEW OverpaidReservations AS
SELECT ClientID,
       ClientName,
       ReservationID,
       (SELECT ReservationDate
        FROM ConferenceReservations
        WHERE ID = ReservationID)                      as ReservationDate,
       (PriceToPayForEntries + PriceToPayForWorkshops) as TotalPriceToPay,
       (SELECT SUM(Amount)
        FROM Payments
        WHERE ConferenceReservationID = ReservationID) as PaidAmount,
       dbo.Balance(ReservationID)                      as Overpayment
FROM ReservationDetails
WHERE isCancelled = 0
  AND dbo.Balance(ReservationID) > 0
GO

CREATE VIEW ClientsToCall AS
SELECT C.ID,
       Name,
       Phone,
       DR.ID                            as DayReservationID,
       (SELECT COUNT(*)
        FROM AttendeesDay
        WHERE DayReservationID = DR.ID) as AttendeesFilled,
       PlaceCount
FROM Clients C
       JOIN ConferenceReservations CR on C.ID = CR.ClientID
       JOIN DayReservations DR on CR.ID = DR.ReservationID
WHERE PlaceCount > (SELECT COUNT(*)
                    FROM AttendeesDay
                    WHERE DayReservationID = DR.ID)