--QUESTION 1
--Create a stored procedure that you pass a CompanyID
--Returns the Full Names (LAST, FIRST) of persons in that company and if they are a current employee. 

CREATE OR ALTER PROCEDURE MyEmployeesSP @CompanyID int
AS 
SELECT (p.LastName + ', ' + p.FirstName) as FullName,
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
	WHERE c.Company = 'Cole and Company');

--Using the CTE, I need to figure out how many months each employee spent at Cole and Company
--Current employees will be given an EndDate that is 6 months from today for when the company shuts down
SELECT PersonID, LastName, FirstName,
	CASE WHEN EndDate = 'null' THEN DATEDIFF(MONTH, CAST(StartDate as Date), DATEADD(MONTH, 6, GETDATE())) 
	ELSE DATEDIFF(MONTH, CAST(StartDate as Date), CAST(EndDate as Date)) END AS MonthsWCompany
FROM ColeCompanyEmployees;

--ANSWER
--Christian Raycroft was the longest employee.
--He spent 124 months (10.3 years) with Cole and Company
--Raycroft was not even a current employee with the company (EndDate in 2021)

--QUESTION 3
--TBD

--QUESTION 4
--You want the top 3 oldest and top 3 youngest workers in the same table. 
SELECT *
FROM
(
	(
		SELECT TOP 3 LastName, FirstName, BirthYear,
			('Youngest #' + CAST(ROW_NUMBER() OVER (ORDER BY BirthYear DESC) AS varchar(10))) AS AgeRank
		--AgeRank is not necessary and makes the query look more complicated
		--BUT the goal was to provide an immediate understanding of what THIS Result-Set was showing, which it did
		FROM Persons
		ORDER BY BirthYear DESC
	UNION
		SELECT TOP 3 LastName, FirstName, BirthYear,
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
SELECT TOP 3 BusinessType, COUNT(BusinessType) AS Count
FROM Company
GROUP BY BusinessType
ORDER BY Count DESC;
--Education and Furniture tie as the most prevalent BusinessType

SELECT TOP 3 BusinessType, SUM(GrossRevenue) AS GrossRevenue
FROM Company
GROUP BY BusinessType
ORDER BY GrossRevenue DESC;
--Education and Fashion are the most profitable BusinessTypes

--QUESTION 6
--

--QUESTION 14
--SECTION 14.A
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

--Create a Weekly Order Table for Hannah Hammocks incorporating all the hammocks the company sold this week.  
BEGIN TRAN
CREATE TABLE WeeklyOrdersHammocks (
	OrderNo int,
	HammockType varchar(255),
	ShipDate date,
	DeliveryDate date,
	ShippedIntl bit
);
COMMIT

--Inserting Hannah Hammocks' orders for the week
INSERT INTO WeeklyOrdersHammocks (OrderNo, HammockType, ShipDate, DeliveryDate, ShippedIntl)
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

--New WeeklyOrdersHammocks Table
SELECT *
FROM WeeklyOrdersHammocks


--SECTION 14.B
--For each day of shipping, Hannah Hammocks pays $2 (+$12 flat fee for orders to Mexico and Canada)
--How much did Hannah Hammocks earn per order?
WITH GrossPerHammock AS (
SELECT OrderNo, PricePerHammockUSD*COUNT(WOH.HammockType) AS GrossEarned
FROM WeeklyOrdersHammocks WOH
JOIN HannahHammocks AS HH
	ON HH.HammockType = WOH.HammockType
GROUP BY OrderNo, PricePerHammockUSD) -- This gives me how much was made per Hammock

SELECT GPH.OrderNo, SUM(GrossEarned)-ShippingCost AS NetEarned --I summed GrossEarned to get GrossEarnedPerOrder instead of Per Hammock
--INTO #HammockTemp --This is for the following question 
--I created the Temp Table and then commented it (and GO) out 
FROM (
	SELECT DISTINCT OrderNo,
		CASE WHEN ShippedIntl = 1 THEN (DATEDIFF(DAY,ShipDate,DeliveryDate)*2+12)
		ELSE DATEDIFF(DAY,ShipDate,DeliveryDate)*2 END AS ShippingCost --This subquery makes sure the shipping cost is only applied once per order
	FROM WeeklyOrdersHammocks) AS Cost 
JOIN GrossPerHammock AS GPH 
	ON Cost.Orderno = GPH.OrderNo
GROUP BY GPH.OrderNo, ShippingCost
ORDER BY GPH.OrderNo
--GO

--What was the average net earnings per order compared to US and International orders?
--I used the above Result-Set as a Temp Table (#HammockTemp)
SELECT ShippedIntl,
	AVG(DISTINCT NetEarned) AS AVGEarnedPerOrder
FROM #HammockTemp AS HT
LEFT JOIN WeeklyOrdersHammocks WOH
	ON HT.OrderNo = WOH.OrderNo
GROUP BY ShippedIntl
ORDER BY AVGEarnedPerOrder DESC

