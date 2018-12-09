ALTER TABLE Conferences
  ADD CONSTRAINT CHKConferenceDates
      CHECK (StartDate < EndDate)
ALTER TABLE Conferences
  ADD CONSTRAINT CHKConferenceName
      CHECK (len(Name) > 0)
ALTER TABLE Conferences
  ADD CONSTRAINT CHKStudentDisc
      CHECK ( 0 <= StudentDiscount AND StudentDiscount <= 1)

ALTER TABLE Days
  ADD CONSTRAINT CHCKDayPlaceLimit
      CHECK (PlaceLimit > 0)
ALTER TABLE Days
  ADD CONSTRAINT CHCKDayNo
  CHECK (DayNum>0)

  ALTER TABLE PriceThresholds
  ADD CONSTRAINT CHCKDaysBefore
  CHECK (DaysBefore>=0)
  ALTER TABLE PriceThresholds
  ADD CONSTRAINT CHCKPrice
  CHECK (Price>=0)

ALTER TABLE Workshops
  ADD CONSTRAINT CHCKWorkshopHours
    CHECK (StartHour < EndHour)
ALTER TABLE Workshops
  ADD CONSTRAINT CHCKWkshpStudentDisc
  CHECK (0 <= StudentDiscount AND StudentDiscount <= 1)
ALTER TABLE Workshops
  ADD CONSTRAINT CHCKWorkshopPrice
    CHECK (Price>=0)
  ALTER TABLE Workshops
  ADD CONSTRAINT CHCKWorkshopPlaceLimit
    CHECK (PlaceLimit>0)

ALTER TABLE DayReservations
  ADD CONSTRAINT CHCKPlaceCounts
CHECK (0<=StudentCount AND StudentCount<=PlaceCount AND PlaceCount>0)

ALTER TABLE WorkshopReservations
ADD CONSTRAINT CHCKWkshpResPlaceCount
CHECK (PlaceCount > 0)

ALTER TABLE Payments
ADD CONSTRAINT CHCKAmount
CHECK (Amount > 0)
ALTER TABLE Payments
ADD CONSTRAINT CHCKMethod
CHECK (Method IN ('K', 'G', 'P'))
