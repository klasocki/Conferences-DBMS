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
SELECT C.Name                     as ClientName,
       CR.ID                      as ReservationId,
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
       ConferenceName,
       ConferenceID,
       SUM(AdultCount * PriceForAdult + StudentCount * (1 - StudentDiscount))
         AS PriceToPayForEntry,
       (SELECT SUM(Price * WR.PlaceCount)
        FROM WorkshopReservations WR
               JOIN
             Workshops W on WR.WorkshopID = W.ID
       JOIN DayReservations R on WR.DayReservationID = R.ID
        WHERE R.ReservationID = DayResDetails.ReservationID
       ) as PriceToPayForWorkshops
FROM (SELECT C.ID                       as ClientID,
             C.Name                     as ClientName,
             CR.ID                      as ReservationId,
             Conf.Name                  as ConferenceName,
             Conf.ID                    as ConferenceID,
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
             JOIN Days D on Conf.ID = D.ConferenceID) as DayResDetails
GROUP BY ClientID, ClientName, ReservationId, ConferenceName, ConferenceID

