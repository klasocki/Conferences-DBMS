CREATE NONCLUSTERED INDEX Conf_StartDate_INDEX ON Conferences (StartDate)
CREATE NONCLUSTERED INDEX Conf_Name_INDEX ON Conferences(Name)

CREATE NONCLUSTERED INDEX Attendees_Name_INDEX ON Attendees(FirstName, LastName)

CREATE NONCLUSTERED INDEX Clients_Name_INDEX ON Clients(Name)

