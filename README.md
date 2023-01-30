# Companies
*In SQL Server, I created three small and simple tables about a few (fake) companies and its employees. This is to practice using SQL Server syntax, writing and creating functions as well as constructing and executing stored procedures. I primarily utilize this project as a way to refer back to the basics when necessary.* 

# ******

#### Question 1
Create a stored procedure that you pass a CompanyID, and it returns the Full Names (LAST, FIRST) of persons in that company and if they are a current employee. 

Test your MyEmployeesSP stored procedure by passing CompanyIDs 14, 5 and 6.

***

#### Question 2
The company, Cole and Company, is shutting down in 6 months. 


Which employee spent the longest time with the company? 


***

#### Question 3
Provide a list of active employees hired within the last 5 years sorted by last name, displaying First Initial and Last Name and hire date. 

***

#### Question 4
You want the top 3 oldest and top 3 youngest workers in the same table. 


What is the difference in years between the youngest and oldest worker?

***

#### Question 5
Which business type is most prevalent? Most profitable?

***

#### Question 6 
All the cities are US state capital cities. Which city do most persons call home? 

Which region (NORTH, SOUTH, WEST, EAST) do most persons reside? If there is not already a region column, create one to answer this question. 

***

#### Question 7
*Section 7.A*<br>
Does there appear to be any pattern with the region of persons and working remotely? 

*Section 7.B* <br>
What about working for a non-American company?

***

#### Question 8
Pretend you are a recruiter looking for someone with IT skills. Create a stored procedure called ITWorkers that returns the company and the persons who have “Analyst”, “Engineer” or “Developer” in their role title. 

***

#### Question 9
Update the stored procedure ITWorkers to also include whether the person is a remote worker and whether the role was Full-Time or Part-Time in the Result-Set. 

***

#### Question 10
Using ITWorkers, find all IT professionals located in Tennessee and who have more than 4 years of experience. 

***

#### Question 11
Hannah Hammocks specializes in 5 different types of hammocks:
* Hanging Chair Hammock ($45)
* Honey Hammock (a hammock made for two) ($82)
* Quilted Hammock ($60)
* Woven Hammock ($55)
* Camping Hammock ($40)

The Hannah Hammocks has had a great week and is shipping out several handmade luxury hammocks! For each day of shipping, Hannah Hammocks pays $2 (+$12 flat fee for orders to Mexico and Canada). 

Three Hanging Chair Hammocks were shipped yesterday to Canada and will be delivered in 8 days. Two Honey Hammocks will be shipped next week to the West Coast and will be delivered in 6 days. Both a Quilted and a Woven Hammock were also shipped on the same day as the Hanging Chair Hammocks but are only going to the a nearby city; delivery should take 2 days. To be shipped in 2 days to a neighboring US state, there is an order for one Woven Hammock and two Camping Hammocks; delivery is 3 days. 

There is a last-minute order for one Honey Hammock in Cancun, Mexico! Hannah Hammocks will ship it the next morning; delivery is 4 days.

**Section 11.A** <br>
Create a Hannah Hammocks table with all the specialized hammocks the small business offers and its pricing. 

Create a Weekly Order Table for Hannah Hammocks incorporating all the hammocks the company sold this week as well as its shipping and delivery dates and whether an order was shipped internationally.

**Section 11.B** <br>
How much did Hannah Hammocks earn per order? 

What was the average net earnings per order compared to US and International order?

## PowerBI Dashboard
#### Question 12
On which day of week were employees hired on? Rank by the percent of total in descending order.


**BONUS** <br>
Visualize this data using Power BI. Add link to a PDF file and put it in a new folder called Dashboard. 

***

#### Question 13
Remote employees will need to track their hours they work each day. This will log a start time and then an end time.  

**Section 13.A** <br>
Create a table of PersonId, LogDate, StartTime, EndTime.  

**Section 13.B** <br>
Create a Stored Procedure that inserts this data based on an employee using a simple Start Time / End Time interface. The SP should determine whether to insert a new record or close out an existing record based on the existing data. Assume no one will work across midnight. Enter several weeks of data for at least 3 employees.

**BONUS** <br>
Visualize a time log with Employees along y axis and the hours work per week across the x axis for the last month. 

**Note: ** If an employee does not enter an End Time, then ignore that record.

***

#### Question 14
Using the Remote Employee work log data from Q#12, produce a visualization showing the average coverage time per day of the week for all remote employee over the course of the last month.

***


