CREATE TABLE Conferences
(
  ConferenceID    int IDENTITY              NOT NULL,
  Name            varchar(255)              NOT NULL,
  StartDate       date COLLATE S            NULL,
  EndDate         date                      NULL,
  StudentDiscount numeric(3, 2) DEFAULT 0.0 NOT NULL,
  Description     varchar(3000)             NULL,
  Logo            image                     NULL,
  PRIMARY KEY (ConferenceID)
);

CREATE TABLE PriceTresholds
(
  DayID      int            NOT NULL,
  DaysBefore int            NOT NULL,
  Price      numeric(10, 2) NOT NULL,
  PRIMARY KEY (DayID, DaysBefore)
);
CREATE TABLE Days
(
  DayID        int IDENTITY NOT NULL,
  ConferenceID int          NOT NULL,
  DayNum       int          NOT NULL,
  PlaceLimit   int          NOT NULL,
  PRIMARY KEY (DayID)
);
CREATE TABLE Workshops
(
  WorkshopID      int IDENTITY                NOT NULL,
  Name            varchar(255)                NOT NULL,
  Price           numeric(10, 2) DEFAULT 0.00 NOT NULL,
  StudentDiscount numeric(3, 2)  DEFAULT 0.00 NOT NULL,
  PlaceLimit      int                         NOT NULL,
  Description     varchar(3000)               NULL,
  StartHour       time                        NOT NULL,
  EndHour         time                        NOT NULL,
  DayID           int                         NOT NULL,
  PRIMARY KEY (WorkshopID)
);
CREATE TABLE DayReservations
(
  ID              int IDENTITY NOT NULL,
  DayID           int          NOT NULL,
  PlaceCount      int          NOT NULL,
  StudentCount    int          NOT NULL,
  ReservationDate datetime     NOT NULL,
  Cancelled       bit          NOT NULL,
  ReservationID   int          NOT NULL,
  PRIMARY KEY (ID)
);
CREATE TABLE ConferenceReservations
(
  ID              int IDENTITY NOT NULL,
  ClientID        int          NOT NULL,
  ConferenceID    int          NOT NULL,
  ReservationDate int          NOT NULL,
  PRIMARY KEY (ID)
);
CREATE TABLE Clients
(
  ClientID    int IDENTITY NOT NULL,
  Name        varchar(100) NOT NULL,
  IsCompany   bit          NOT NULL,
  CompanyName varchar(100) NULL,
  Email       varchar(100) NOT NULL,
  PRIMARY KEY (ClientID)
);
CREATE TABLE WorkshopReservations
(
  ID               int IDENTITY NOT NULL,
  DayReservationID int          NOT NULL,
  WorkshopID       int          NOT NULL,
  Cancelled        bit          NOT NULL,
  PlaceCount       int          NOT NULL,
  PRIMARY KEY (ID)
);
CREATE TABLE AttendeesWorkshop
(
  WorkshopReservationID int NOT NULL,
  AtendeeDayID          int NOT NULL,
  PRIMARY KEY (WorkshopReservationID, AtendeeDayID)
);
CREATE TABLE AttendeesDay
(
  AtendeeDayID     int IDENTITY NOT NULL,
  DayReservationID int          NOT NULL,
  AtendeeID        int          NOT NULL,
  IsStudent        bit          NOT NULL,
  StudentCardNum   varchar(25)  NULL,
  PRIMARY KEY (AtendeeDayID)
);
CREATE TABLE Atendees
(
  ID        int IDENTITY NOT NULL,
  FirstName varchar(50)  NOT NULL,
  LastName  varchar(50)  NOT NULL,
  Phone     int          NULL,
  Email     varchar(100) NULL,
  PRIMARY KEY (ID)
);
CREATE TABLE Payments
(
  ID                      int IDENTITY   NOT NULL,
  ConferenceReservationID int            NOT NULL,
  Amount                  numeric(10, 2) NOT NULL,
  PayDate                 datetime       NOT NULL,
  Method                  varchar(255)   NOT NULL,
  PRIMARY KEY (ID)
);
ALTER TABLE PriceTresholds
  ADD CONSTRAINT FKPriceTresh255123 FOREIGN KEY (DayID) REFERENCES Days (DayID);
ALTER TABLE Days
  ADD CONSTRAINT FKDays60080 FOREIGN KEY (ConferenceID) REFERENCES Conferences (ConferenceID);
ALTER TABLE Workshops
  ADD CONSTRAINT FKWorkshops622279 FOREIGN KEY (DayID) REFERENCES Days (DayID);
ALTER TABLE DayReservations
  ADD CONSTRAINT FKDayReserva132880 FOREIGN KEY (DayID) REFERENCES Days (DayID);
ALTER TABLE DayReservations
  ADD CONSTRAINT FKDayReserva572798 FOREIGN KEY (ReservationID) REFERENCES ConferenceReservations (ID);
ALTER TABLE ConferenceReservations
  ADD CONSTRAINT FKConference717641 FOREIGN KEY (ClientID) REFERENCES Clients (ClientID);
ALTER TABLE WorkshopReservations
  ADD CONSTRAINT FKWorkshopRe415350 FOREIGN KEY (DayReservationID) REFERENCES DayReservations (ID);
ALTER TABLE WorkshopReservations
  ADD CONSTRAINT FKWorkshopRe860502 FOREIGN KEY (WorkshopID) REFERENCES Workshops (WorkshopID);
ALTER TABLE AttendeesWorkshop
  ADD CONSTRAINT FKAttendeesW202033 FOREIGN KEY (WorkshopReservationID) REFERENCES WorkshopReservations (ID);
ALTER TABLE AttendeesWorkshop
  ADD CONSTRAINT FKAttendeesW230500 FOREIGN KEY (AtendeeDayID) REFERENCES AttendeesDay (AtendeeDayID);
ALTER TABLE AttendeesDay
  ADD CONSTRAINT FKAttendeesD487523 FOREIGN KEY (DayReservationID) REFERENCES DayReservations (ID);
ALTER TABLE AttendeesDay
  ADD CONSTRAINT FKAttendeesD226365 FOREIGN KEY (AtendeeID) REFERENCES Atendees (ID);
ALTER TABLE Payments
  ADD CONSTRAINT FKPayments425785 FOREIGN KEY (ConferenceReservationID) REFERENCES ConferenceReservations (ID);
ALTER TABLE ConferenceReservations
  ADD CONSTRAINT FKConference695402 FOREIGN KEY (ConferenceID) REFERENCES Conferences (ConferenceID);
