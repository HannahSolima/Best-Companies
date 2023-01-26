BEGIN TRAN

CREATE TABLE Persons (
    PersonID tinyint,
    LastName varchar(255),
    FirstName varchar(255),
    BirthYear int,
    HomeCity varchar(255),
	StartDate varchar(25),
	EndDate varchar(25) NULL,
	IsCurrentEmployee bit,
	IsRemote bit
);

COMMIT

--Importing my flat file of data
--Making sure it importing correctly
SELECT *
FROM Persons



--Creating Company Table
BEGIN TRAN

CREATE TABLE Company (
    CompanyID tinyint,
    Company varchar(255),
	GrossRevenue int,
    BusinessType varchar(255),
    IsAmerican bit
);

COMMIT

--Importing my flat file of data
--Making sure it importing correctly
SELECT *
FROM Company


--Creating PersonsCompany Table
BEGIN TRAN

CREATE TABLE PersonsCompany (
    PersonID tinyint,
	CompanyID tinyint,
	FT bit, 
	PT bit,
	Role varchar(255)
);

COMMIT

--Importing my flat file of data
--Making sure it importing correctly
SELECT *
FROM PersonsCompany

--SUCCESS
