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
GO

--Execute MyEmployees for GoGoBus Employees
EXEC MyEmployeesSP @CompanyID = 14

--Execute MyEmployees for KoalaKare Employees
EXEC MyEmployeesSP @CompanyID = 5

--Execute MyEmployees for Carmien Employees
EXEC MyEmployeesSP @CompanyID = 6

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
	CASE WHEN EndDate = 'null' THEN DATEDIFF(MONTH, CAST(StartDate as Date), DATEADD(MONTH, 6, GETDATE())) 
	ELSE DATEDIFF(MONTH, CAST(StartDate as Date), CAST(EndDate as Date)) END AS MonthsWCompany
FROM ColeCompanyEmployees

--ANSWER
--Christian Raycroft was the longest employee.
--He spent 124 months (10.3 years) with Cole and Company
--Raycroft was not even a current employee with the company (EndDate in 2021)

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
SELECT  OrderNo,
			PricePerHammockUSD*COUNT(Cost.HammockType)-USShippingCost AS NetEarningsPerOrder
FROM (SELECT *,
		CASE WHEN ShippedIntl = 1 THEN (DATEDIFF(DAY,ShipDate,DeliveryDate)*2)+12
		ELSE DATEDIFF(DAY,ShipDate,DeliveryDate)*2 END AS USShippingCost
		FROM WeeklyOrdersHammocks) AS Cost
JOIN HannahHammocks AS HH
	ON HH.HammockType = Cost.HammockType
GROUP BY OrderNo, PricePerHammockUSD, USShippingCost
ORDER BY OrderNo

--What was the average net earnings per order compared to US and International orders?
--Will use the above Result-Set as a CTE (with Top 7 added)

WITH EarnedPerOrder AS (
	SELECT  TOP 7 OrderNo,
				PricePerHammockUSD*COUNT(Cost.HammockType)-USShippingCost AS NetEarningsPerOrder
	FROM (SELECT *,
			CASE WHEN ShippedIntl = 1 THEN (DATEDIFF(DAY,ShipDate,DeliveryDate)*2)+12
			ELSE DATEDIFF(DAY,ShipDate,DeliveryDate)*2 END AS USShippingCost
			FROM WeeklyOrdersHammocks) AS Cost
	JOIN HannahHammocks AS HH
		ON HH.HammockType = Cost.HammockType
	GROUP BY OrderNo, PricePerHammockUSD, USShippingCost
	ORDER BY OrderNo)

SELECT AVG(NetEarningsPerOrder) AS AVGEarnedPerOrder, COUNT(HammockType) AS TotalSold, ShippedIntl
FROM WeeklyOrdersHammocks WOH
JOIN EarnedPerOrder EPO
	ON WOH.Orderno = EPO.Orderno
GROUP BY ShippedIntl
ORDER BY AVGEarnedPerOrder DESC