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

--QUESTION 3
--SECTION 3.A
--Create a Hannah Hammocks table with all the specialized hammocks the small business offers and its pricing



--SECTION 3.B
--Make another table where your results show: Hammock Type, Number Shipped, Shipped Date, Delivery Date
--AND how much the company earned per order

--SECTION 3.C
--How would you advise Hannah Hammocks to optimize its net earnings? 