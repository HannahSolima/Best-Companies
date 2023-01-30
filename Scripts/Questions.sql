--QUESTION 1
--Create a stored procedure that you pass a CompanyID
--Returns the Full Names (LAST, FIRST) of persons in that company and if they are a current employee. 

CREATE OR ALTER PROCEDURE MyEmployeesSP @CompanyID int
AS 
SELECT CONCAT_WS(', ', p.LastName, p.FirstName) as FullName,
		c.Company,
		p.IsCurrentEmployee
FROM Persons p
JOIN PersonsCompany pc
	ON p.PersonID = pc.PersonID
JOIN Company c
	ON pc.CompanyID = c.CompanyID
WHERE c.CompanyID = @CompanyID
GO;

--Execute MyEmployees for GoGoBus Employees
EXEC MyEmployeesSP @CompanyID = 14

--Execute MyEmployees for KoalaKare Employees
EXEC MyEmployeesSP @CompanyID = 5

--Execute MyEmployees for Carmien Employees
EXEC MyEmployeesSP @CompanyID = 6;


--QUESTION 2
--The company, Cole and Company, is shutting down in 6 months. Which employee spent the longest time with the company? 

--Creating CTE with only the info I need
WITH ColeCompanyEmployees AS (
	SELECT p.PersonID, LastName, FirstName, Company, StartDate, EndDate, IsCurrentEmployee 
	FROM Persons p
	JOIN PersonsCompany pc
		ON p.PersonID = pc.PersonID
	JOIN Company c
		ON pc.CompanyID = c.CompanyID
	WHERE c.Company = 'Cole and Company')

--Using the CTE, I need to figure out how many months each employee spent at Cole and Company
--Current employees will be given an EndDate that is 6 months from today for when the company shuts down
SELECT PersonID, LastName, FirstName,
	CASE WHEN ISNULL(EndDate, '') = '' THEN DATEDIFF(MONTH, CAST(StartDate as Date), DATEADD(MONTH, 6, GETDATE())) 
	ELSE DATEDIFF(MONTH, CAST(StartDate as Date), CAST(EndDate as Date)) END AS MonthsWCompany
FROM ColeCompanyEmployees
ORDER BY MonthsWCompany DESC;

--ANSWER
--Coulson Damien was the longest employee.
--He spent 97 months (8 years 1 month) with Cole and Company

--QUESTION 3
--Provide a list of active employees hired within the last 5 years 
--Sorted by last name
--Displaying First Initial and Last Name and hire date
SELECT LEFT(FirstName,1) AS First_Initial, LastName, StartDate
FROM Persons
WHERE IsCurrentEmployee = 1 AND StartDate >= '01/01/2018'
ORDER BY LastName
--There are 26 active employees that were hired within the last 5 years 

--QUESTION 4
--You want the top 3 oldest and top 3 youngest workers in the same table. 
SELECT *
FROM
(
	(
		SELECT TOP 3 WITH TIES LastName, FirstName, BirthYear,
			('Youngest #' + CAST(ROW_NUMBER() OVER (ORDER BY BirthYear DESC) AS varchar(10))) AS AgeRank
		--AgeRank is not necessary and makes the query look more complicated
		--BUT the goal was to provide an immediate understanding of what THIS Result-Set was showing, which it did
		FROM Persons
		ORDER BY BirthYear DESC
	UNION
		SELECT TOP 3 WITH TIES LastName, FirstName, BirthYear,
			('Oldest #' + CAST(ROW_NUMBER() OVER (ORDER BY BirthYear) AS varchar(10))) AS AgeRank
		FROM Persons
		ORDER BY BirthYear
	)
) AS YoungestOldest
ORDER BY AgeRank;


--What is the difference in years between the youngest and oldest worker?
SELECT MAX(BirthYear)-MIN(BirthYear) AS MaxAgeDiffYears
FROM Persons;
--ANSWER: 41 years between the youngest and oldest worker

--QUESTION 5
--Which business type is most prevalent? Most profitable?
SELECT TOP 1 WITH TIES BusinessType, COUNT(BusinessType) AS Count
FROM Company
GROUP BY BusinessType
ORDER BY Count DESC;
--ANSWER: Education and Furniture tie as the most prevalent BusinessType

SELECT TOP 1 WITH TIES BusinessType, SUM(GrossRevenue) AS GrossRevenue
FROM Company
GROUP BY BusinessType
ORDER BY GrossRevenue DESC;
--ANSWER: Education and Fashion are the most profitable BusinessTypes

--QUESTION 6
--Which city do most persons call home? 
SELECT TOP 1 WITH TIES City, COUNT(City) AS Count
FROM Persons
GROUP BY City
ORDER BY Count DESC;
--ANSWER: Nashville

--Which region (NORTH, SOUTH, WEST, EAST) do most persons reside? 

--Adding the Region column
ALTER TABLE Persons
ADD Region varchar(20);

--The regions are according to the US Census Bureau.
CREATE PROCEDURE UpdatePersonsWRegion 
	@PersonID int
	AS 
		BEGIN
		UPDATE Persons
		SET Region = CASE WHEN State IN ('AL','TN','GA','TX','FL','AR','KY','LA','MS','DE','NC','MD','OK','VA','WV','SC') THEN 'South'
		WHEN State IN ('ME','NH','VT','MA','RI','CT','NY','NJ','PA') THEN 'Northeast'
		WHEN State IN ('OH','MI','IN','WI','IL','MN','IA','MO','ND','SD','NE','KS') THEN 'Midwest'
		WHEN State IN ('MT','ID','WY','CO','NM','AZ','UT','NV','CA','OR','WA','AK','HI') THEN 'West' 
		ELSE Null END
		WHERE PersonID = @PersonID
		END

--Testing out the new stored procedure
EXEC UpdatePersonsWRegion @PersonID = 1

--The first person's Region has been updated
SELECT *
FROM Persons

--Creating a loop to apply stored procedure to all rows
DECLARE @ID int

SELECT @ID = MIN(p.PersonID)
FROM Persons p

WHILE(SELECT COUNT(1)
      FROM Persons p
      WHERE p.PersonID >= @ID) > 0
    BEGIN

        EXEC UpdatePersonsWRegion @PersonID = @ID

        SELECT @ID = MIN(p.PersonID)
		FROM Persons p
        WHERE p.PersonID > @ID
    END

--Now that I have the Regions in the Persons Table, back to the original question:
--Which region (NORTH, SOUTH, WEST, EAST) do most persons reside? 
SELECT TOP 1 WITH TIES Region, COUNT(Region) AS Count
FROM Persons
GROUP BY Region
ORDER BY Count DESC
--ANSWER: SOUTH, 20 workers reside there

--QUESTION 7
--SECTION 7.A
--Does there appear to be any pattern with the region of persons and working remotely? 
SELECT Region, COUNT(p.PersonID) AS Workers,
	SUM(CAST(IsRemote AS int)) AS RemoteWorkers,
	ROUND(SUM(CAST(IsRemote AS float))/COUNT(Region)*100,2) AS PctRemote
FROM Persons p 
JOIN PersonsCompany pc 
	ON p.PersonID = pc.PersonID 
JOIN Company c
	ON c.CompanyID = pc.CompanyID
GROUP BY Region
ORDER BY RemoteWorkers DESC
--ANSWER: The South has more workers in total, but it is important to note that the South has more states in the region.
--The West has more remote workersbut the Northeast has a higher percentage of remote workers.

--NOTE: In this data set, only 10 states being currently represented within the South region and the same is for the West.
SELECT Region, COUNT(DISTINCT State) AS StateCount
FROM Persons
GROUP BY Region
ORDER BY StateCount DESC

--SECTION 7.B
--What about working for a non-American company?
SELECT Region, COUNT(p.PersonID) AS Workers,
	SUM(CAST(IsAmerican AS int)) AS WithUSCompany,
	ROUND(SUM(CAST(IsAmerican AS float))/COUNT(Region)*100,2) AS Pct_WithUSCompany
FROM Persons p 
JOIN PersonsCompany pc 
	ON p.PersonID = pc.PersonID 
JOIN Company c
	ON c.CompanyID = pc.CompanyID
GROUP BY Region
ORDER BY WithUSCompany DESC
--ANSWER: The South has more workers who work with a US Company, but the Midwest has a higher percentage of workers with a US Company.
--Interestingly, this also means, by percentage, that the West and NorthEast have more workers with International Companies.

--QUESTION 8
--Create a stored procedure called ITWorkers 
--Returns the company and the persons who have “Analyst”, “Engineer” or “Developer” in their role title. 

CREATE PROCEDURE ITWorkers
AS
SELECT LastName, FirstName, Company, Role
FROM Persons p
JOIN PersonsCompany pc
	ON pc.PersonID = p.PersonID
JOIN Company c
	ON c.CompanyID = pc.CompanyID
WHERE LOWER(Role) LIKE '%analyst%' 
	OR LOWER(Role) LIKE '%engineer%'
	OR LOWER(Role) LIKE '%developer%'
ORDER BY Company 
GO;

EXEC ITWorkers
--There are 9 ITWorkers. 

--QUESTION 9 
--Update the stored procedure ITWorkers
--Include: Remote worker? Role Full-Time or Part-Time? 

ALTER PROCEDURE ITWorkers
AS
SELECT p.PersonID, LastName, FirstName, Company, Role, IsRemote, FT, PT
FROM Persons p
JOIN PersonsCompany pc
	ON pc.PersonID = p.PersonID
JOIN Company c
	ON c.CompanyID = pc.CompanyID
WHERE LOWER(Role) LIKE '%analyst%' 
	OR LOWER(Role) LIKE '%engineer%'
	OR LOWER(Role) LIKE '%developer%'
ORDER BY Company; 
GO

EXEC ITWorkers
--The SP now shows whether a worker was Remote, FT or PT. 

--QUESTION 10 
--Find all IT professionals located in TN and who have more than 4 years of experience
CREATE TABLE #ITWorkersTemp (
    PersonID int,
	LastName varchar(255), 
    FirstName varchar(255),
	Company varchar (255),
	Role varchar (255),
	IsRemote bit,add
	FT bit,
	PT bit
)

INSERT INTO #ITWorkersTemp EXEC ITWorkers

SELECT temp.PersonID, temp.Lastname, temp.Firstname, Company, Role, State, YearsExperience
FROM #ITWorkersTemp temp
JOIN (SELECT PersonID, LastName, FirstName, State,
		CAST(CASE WHEN ISNULL(EndDate, '') = '' THEN DATEDIFF(YEAR, CAST(StartDate as Date), GETDATE()) 
		ELSE DATEDIFF(YEAR, CAST(StartDate as Date), CAST(EndDate as Date)) END AS int) AS YearsExperience
	FROM Persons) AS sub
	ON sub.PersonID = temp.PersonID
WHERE YearsExperience > 4
	AND State = 'TN'
ORDER BY YearsExperience
--ANSWER: James Lolley and Timothy Riggs are the only IT Workers based in TN with more than 4 years of experience. 

--QUESTION 11
--SECTION 11.A
--Create a Hannah Hammocks table with all the specialized hammocks the small business offers and its pricing
BEGIN TRAN
CREATE TABLE HannahHammocks (
	HammockType varchar(255),
	PricePerHammockUSD int
);
COMMIT

--Testing "INSERT INTO" with one row first
INSERT INTO HannahHammocks (HammockType, PricePerHammockUSD)
VALUES ('Hanging Chair Hammock', 45)
--The values were inserted correctly

--Inserting multiple rows of values
INSERT INTO HannahHammocks (HammockType, PricePerHammockUSD)
VALUES ('Honey Hammock',82),('Quilted Hammock',60), ('Woven Hammock', 55), ('Camping Hammock',40)

--New HannahHammocks Table
SELECT *
FROM HannahHammocks

--Create a Order Table for Hannah Hammocks incorporating all the hammocks the company sold this week.  
BEGIN TRAN
CREATE TABLE HH_Orders (
	OrderNo int,
	HammockType varchar(255),
	ShipDate date,
	EstDeliveryDate date,
	ShippedIntl bit
);
COMMIT

--Inserting Hannah Hammocks' orders for the week
INSERT INTO HH_Orders (OrderNo, HammockType, ShipDate, EstDeliveryDate, ShippedIntl)
VALUES  (51, 'Hanging Chair Hammock', DATEADD(DAY,-1,GETDATE()), DATEADD(DAY,8, DATEADD(DAY,-1,GETDATE())),1),
		(51, 'Hanging Chair Hammock', DATEADD(DAY,-1,GETDATE()), DATEADD(DAY,8, DATEADD(DAY,-1,GETDATE())),1),
		(51, 'Hanging Chair Hammock', DATEADD(DAY,-1,GETDATE()), DATEADD(DAY,8, DATEADD(DAY,-1,GETDATE())),1),
		(52, 'Honey Hammock', DATEADD(WEEK, 1, GETDATE()), DATEADD(DAY,6,DATEADD(WEEK, 1, GETDATE())),0), 
		(52, 'Honey Hammock', DATEADD(WEEK, 1, GETDATE()), DATEADD(DAY,6,DATEADD(WEEK, 1, GETDATE())),0),
		(53, 'Quilted Hammock', DATEADD(DAY,-1,GETDATE()), DATEADD(DAY,2,GETDATE()),0), 
		(53, 'Woven Hammock', DATEADD(DAY,-1,GETDATE()), DATEADD(DAY,2,GETDATE()),0),
		(54, 'Woven Hammock', DATEADD(DAY,2,GETDATE()), DATEADD(DAY,3,GETDATE()),0),
		(54, 'Camping Hammock', DATEADD(DAY,2,GETDATE()), DATEADD(DAY,3,GETDATE()),0),
		(54, 'Camping Hammock', DATEADD(DAY,2,GETDATE()), DATEADD(DAY,3,GETDATE()),0),
		(55, 'Honey Hammock', DATEADD(DAY, 1, GETDATE()), DATEADD(DAY,4,GETDATE()),1)

--New HH_Orders Table
SELECT *
FROM HH_Orders

--SECTION 11.B
--For each day of shipping, Hannah Hammocks pays $2 (+$12 flat fee for orders to Mexico and Canada)
--How much did Hannah Hammocks earn per order?
SELECT OrderNo, GrossEarned-ShippingCost AS NetEarned
--INTO #HammockTemp --Temp Table for below
FROM (
	SELECT OrderNo, SUM(PricePerHammockUSD) AS GrossEarned,
		CASE WHEN ShippedIntl = 1 THEN (DATEDIFF(DAY,ShipDate,EstDeliveryDate)*2+12)
		ELSE DATEDIFF(DAY,ShipDate,EstDeliveryDate)*2 END AS ShippingCost
	FROM HH_Orders O

	JOIN HannahHammocks AS HH
		ON HH.HammockType = O.HammockType
	GROUP BY OrderNo, ShippedIntl, ShipDate,EstDeliveryDate) AS Cost 
ORDER BY OrderNo
--GO

--What was the average net earnings per order compared to US and International orders?
--I used the above Result-Set as a Temp Table (#HammockTemp)
SELECT ShippedIntl,
	AVG(DISTINCT NetEarned) AS AVGEarnedPerOrder
FROM #HammockTemp AS HT
LEFT JOIN HH_Orders O
	ON HT.OrderNo = O.OrderNo
GROUP BY ShippedIntl
ORDER BY AVGEarnedPerOrder DESC

--QUESTION 12
--On which day of week were employees hired on? Rank by the percent of total in descending order.
SELECT DayHired, (COUNT(CAST(PersonID AS float))/CAST(TotalWorkers AS float))*100 AS PctWorkers
FROM (SELECT DATENAME(WEEKDAY, StartDate) AS DayHired, PersonID, COUNT(PersonID) OVER() AS TotalWorkers
	FROM Persons) AS sub
GROUP BY DayHired, TotalWorkers
ORDER BY PctWorkers DESC
--ANSWER: Most workers were hired on Monday and Friday. Wednesday is the day the least amount of workers were hired.

--QUESTION 13
--SECTION 13.A
--Create a table of PersonId, LogDate, StartTime, EndTime
CREATE TABLE RemoteEmployees (
	PersonID int,
	LogDate date,
	StartTime time,
	EndTime time
);

--QUESTION 13
--TBD 




