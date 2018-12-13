CREATE TABLE Conferences
(
  ID              int IDENTITY              NOT NULL,
  Name            varchar(255)              NOT NULL,
  StartDate       date                      NOT NULL,
  EndDate         date                      NOT NULL,
  Cancelled       bit           DEFAULT 0   NOT NULL,
  StudentDiscount numeric(3, 2) DEFAULT 0.0 NOT NULL,
  Description     varchar(3000)             NULL,
  PRIMARY KEY (ID)
);


CREATE TABLE Days
(
  ID           int IDENTITY NOT NULL,
  ConferenceID int          NOT NULL,
  DayNum       int          NOT NULL,
  PlaceLimit   int          NOT NULL,
  PRIMARY KEY (ID),
  CONSTRAINT FKDaysToConferences FOREIGN KEY (ConferenceID) REFERENCES Conferences (ID)
);
CREATE TABLE PriceThresholds
(
  DayID      int            NOT NULL,
  DaysBefore int            NOT NULL,
  Price      numeric(10, 2) NOT NULL,
  PRIMARY KEY (DayID, DaysBefore),
  CONSTRAINT FKPriceThreshToDays FOREIGN KEY (DayID) REFERENCES Days (ID)
);
CREATE TABLE Workshops
(
  ID              int IDENTITY                NOT NULL,
  Name            varchar(255)                NOT NULL,
  Price           numeric(10, 2) DEFAULT 0.00 NOT NULL,
  PlaceLimit      int                         NOT NULL,
  Description     varchar(3000)               NULL,
  StartHour       time                        NOT NULL,
  EndHour         time                        NOT NULL,
  DayID           int                         NOT NULL,
  PRIMARY KEY (ID),
  CONSTRAINT FKWorkshopsToDays FOREIGN KEY (DayID) REFERENCES Days (ID)
);
CREATE TABLE Clients
(
  ID          int IDENTITY NOT NULL,
  Name        varchar(100) NOT NULL,
  IsCompany   bit          NOT NULL,
  CompanyName varchar(100) NULL,
  Email       varchar(100) NOT NULL,
  PRIMARY KEY (ID)
);
CREATE TABLE ConferenceReservations
(
  ID              int IDENTITY NOT NULL,
  ClientID        int          NOT NULL,
  ConferenceID    int          NOT NULL,
  ReservationDate int          NOT NULL,
  PRIMARY KEY (ID),
  CONSTRAINT FKConferenceToClient FOREIGN KEY (ClientID) REFERENCES Clients (ID),
  CONSTRAINT FKConferenceResToConferences FOREIGN KEY (ConferenceID) REFERENCES Conferences (ID)
);
CREATE TABLE DayReservations
(
  ID              int IDENTITY  NOT NULL,
  DayID           int           NOT NULL,
  PlaceCount      int           NOT NULL,
  StudentCount    int           NOT NULL,
  ReservationDate datetime      NOT NULL,
  Cancelled       bit DEFAULT 0 NOT NULL,
  ReservationID   int           NOT NULL,
  PRIMARY KEY (ID),

  CONSTRAINT FKDayReservationsToDays FOREIGN KEY (DayID) REFERENCES Days (ID),
  CONSTRAINT FKDayReservationsToConfRes FOREIGN KEY (ReservationID) REFERENCES ConferenceReservations (ID)
);
CREATE TABLE Payments
(
  ID                      int IDENTITY   NOT NULL,
  ConferenceReservationID int            NOT NULL,
  Amount                  numeric(10, 2) NOT NULL,
  PayDate                 datetime       NOT NULL,
  Method                  char           NOT NULL,
  PRIMARY KEY (ID),
  CONSTRAINT FKPaymentsToConfRes FOREIGN KEY (ConferenceReservationID) REFERENCES ConferenceReservations (ID)
);
CREATE TABLE WorkshopReservations
(
  ID               int IDENTITY  NOT NULL,
  DayReservationID int           NOT NULL,
  WorkshopID       int           NOT NULL,
  Cancelled        bit DEFAULT 0 NOT NULL,
  PlaceCount       int           NOT NULL,
  PRIMARY KEY (ID),

  CONSTRAINT FKWorkshopResToDayRes FOREIGN KEY (DayReservationID) REFERENCES DayReservations (ID),
  CONSTRAINT FKWorkshopResToWorkshops FOREIGN KEY (WorkshopID) REFERENCES Workshops (ID)
);
CREATE TABLE Attendees
(
  ID        int IDENTITY NOT NULL,
  FirstName varchar(50)  NOT NULL,
  LastName  varchar(50)  NOT NULL,
  Phone     int          NULL,
  Email     varchar(100) NULL,
  PRIMARY KEY (ID)
);

CREATE TABLE AttendeesDay
(
  ID               int IDENTITY NOT NULL,
  DayReservationID int          NOT NULL,
  AttendeeID       int          NOT NULL,
  IsStudent        bit          NOT NULL,
  StudentCardNum   varchar(25)  NULL,
  PRIMARY KEY (ID),
  CONSTRAINT FKAttendeesDayToDayRes FOREIGN KEY (DayReservationID) REFERENCES DayReservations (ID),
  CONSTRAINT FKAttendeesDayToAttendees FOREIGN KEY (AttendeeID) REFERENCES Attendees (ID)
);
CREATE TABLE AttendeesWorkshop
(
  WorkshopReservationID int NOT NULL,
  AttendeeDayID         int NOT NULL,
  PRIMARY KEY (WorkshopReservationID, AttendeeDayID),
  CONSTRAINT FKAttendeesToWorkshopRes FOREIGN KEY (WorkshopReservationID) REFERENCES WorkshopReservations (ID),
  CONSTRAINT FKAttendeesWorkshopToAttendeesDay FOREIGN KEY (AttendeeDayID) REFERENCES AttendeesDay (ID)
);
