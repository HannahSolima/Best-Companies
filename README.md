# Companies
In SQL Server, I created some very small tables about a few (fake) companies and its employees. This is to practice writing functions and stored procedures and be able to refer back to this if necessary. 

#### Question 1
Create a stored procedure that you pass a CompanyID and it returns a list of persons in that company

#### Question 2
The names in the Persons table are separated by last and first name. Your boss comes to you and tells you that she wants you to create a function that will combine the two columns and separate it with a comma. Apply the function to the Persons table. 

#### Question 3
The company, ReWind, is shutting down in 6 months. Which employee spent the longest time with the company? 

#### Question 4
Hannah Hammocks specializes in 5 different types of hammocks:
* Hanging Chair Hammock ($45)
* HoneyHammock (a hammock made for two) ($82)
* Quilted Hammock ($60)
* Woven Hammock ($55)
* Camping Hammock ($40)

The Hannah Hammocks has had a great week and is shipping out seven amazing hammocks! For each day of shipping, Hannah Hammocks pays $1.50 (+$5.50 flat fee for orders to Mexico and Canada). Three Hanging Chair Hammocks were shipped yesterday to Canada and will be delivered in 8 days. Two HoneyHammocks will be shipped next Tuesday to the Southwest and will be delivered in 6 days. Both a Quilted and a Woven Hammock will also be shipped on the same day as the Hanging Chair Hammocks but are only going to the a nearby city; delivery should take 2 days. 

Create a Hannah Hammocks table with all the specialized hammocks the small business offers and its pricing. Make a query that shows the type of hammock, count being shipped, its shipping date, its estimated delivery date, and how much the company earned per order. 

How would you advise Hannah Hammocks to optimize its net earnings? 

#### Question 5
You want the top 3 oldest and top 3 youngest workers in the same table. What is the difference in years between the youngest and oldest worker?

#### Question 6
Which business type is most prevalent? Which business type is the most profitable? \

#### Question 7
Pretend you are a recruiter looking for someone with IT skills. Create a stored procedure that pulls out the name of the persons who have “Analyst” or “Engineer” in the role column and the company for which they previously or currently work. 

#### Question 8
Update the stored procedure to also include whether the person is a remote worker and whether the role was FT or PT. 

