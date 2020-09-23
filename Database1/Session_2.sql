-- Creation of tblEmployee table
CREATE TABLE tblEmployee
(
EmployeeNumber INT NOT NULL,
EmployeeFirstName VARCHAR(50) NOT NULL,
EmployeeMiddleName VARCHAR(50) NULL,
EmployeeLastName VARCHAR(50) NOT NULL,
EmployeeGovernmentID CHAR(10) NULL,
DateOfBirth DATE NOT NULL
)
GO

ALTER TABLE tblEmployee
ADD Department VARCHAR(20) NOT NULL

INSERT INTO tblEmployee([EmployeeNumber], [EmployeeFirstName], [EmployeeMiddleName], [EmployeeLastName], [EmployeeGovernmentID], [DateOfBirth], [Department])
VALUES ('224',	'Nuan',	NULL	,'Ray', 'WG884481Y',	'3/21/1991', 'HR');																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											
GO

SELECT LEN('WG884481Y')

SELECT * FROM tblEmployee WHERE EmployeeLastName = 'Word';
SELECT * FROM tblEmployee WHERE EmployeeLastName <> 'Word';
SELECT * FROM tblEmployee WHERE EmployeeLastName > 'Word'; -- Names later than Word
SELECT * FROM tblEmployee WHERE EmployeeLastName LIKE '%W%'; -- W at the end 
SELECT * FROM tblEmployee WHERE EmployeeLastName LIKE '_W%'; -- Underscore stands for one letter (so W must be second)


SELECT * FROM tblEmployee WHERE EmployeeLastName LIKE '[r-t]%'; -- First letter of last name anywhere between r-t
SELECT * FROM tblEmployee WHERE EmployeeLastName LIKE '[^rst]%'; -- ^not I do not want name to start with ^

-- % = 0-infinity characters
-- _ = 1 character
-- [A-G] = In the range A-G.
-- [AGQ] = A, G or Q.
-- [^AGQ] = NOT A, G or Q.

select * from tblEmployee
where EmployeeLastName like '[%]%'

select * from tblEmployee
where EmployeeLastName like '`%%' ESCAPE '`'

select * FROM tblEmployee
WHERE NOT EmployeeNumber > 200

select * FROM tblEmployee
WHERE EmployeeNumber != 200

SELECT * FROM tblEmployee
WHERE EmployeeNumber BETWEEN 200 AND 209;

SELECT * FROM tblEmployee
WHERE NOT EmployeeNumber BETWEEN 200 AND 209;

select * from tblEmployee
where EmployeeNumber>=200 and EmployeeNumber<=209;


select * from tblEmployee
where not (EmployeeNumber>=200 and EmployeeNumber<=209);

select * from tblEmployee
where EmployeeNumber<200 or EmployeeNumber>209

SELECT * FROM tblEmployee
where EmployeeNumber = 204 or EmployeeNumber = 210 or EmployeeNumber = 211;

SELECT * FROM tblEmployee
where EmployeeNumber in (204, 210, 211);

-- Summarising and ordering data

SELECT * FROM tblEmployee
where DateOfBirth BETWEEN '19760101' and '19861231'

select * from tblEmployee
where DateOfBirth >= '19760101' and DateOfBirth < '19870101'

SELECT year(DateOfBirth) as YearOfDateOfBirth, count(*) as NumberBorn -- * means count the number
FROM tblEmployee
GROUP BY year(DateOfBirth)
ORDER BY YearOfDateOfBirth ASC;

SELECT * FROM tblEmployee
where year(DateOfBirth) = 1967

SELECT year(DateOfBirth) as YearOfDateOfBirth, count(*) as NumberBorn
FROM tblEmployee
WHERE 1=1
GROUP BY year(DateOfBirth) -- You cannot use aliases in the GROUP BY clause
-- non-deterministic

-- group by first letter of the name 
select left(EmployeeLastName,1) as Initial, count(*) as CountOfInitial -- left to take the first letter of the name 
from tblEmployee
group by left(EmployeeLastName,1)
order by count(*) DESC --left(EmployeeLastName,1)

-- pick the top 5 rows
select top(5) left(EmployeeLastName,1) as Initial, count(*) as CountOfInitial -- left to take the first letter of the name 
from tblEmployee
group by left(EmployeeLastName,1)
order by count(*) DESC --left(EmployeeLastName,1)

-- we need the rows that having count greater than 50
select left(EmployeeLastName,1) as Initial, count(*) as CountOfInitial -- left to take the first letter of the name 
from tblEmployee
group by left(EmployeeLastName,1)
having count(*) >= 50
order by count(*) DESC --left(EmployeeLastName,1)


-- we need the rows that having count greater than 50 and date of birth grater than 19600101
select left(EmployeeLastName,1) as Initial, count(*) as CountOfInitial -- left to take the first letter of the name 
from tblEmployee
where DateOfBirth > '19600101' -- Cannot use aliases
group by left(EmployeeLastName,1) -- Cannot use aliases
having count(*) >= 20 -- Cannot use aliases
order by count(*) DESC -- in the order by you can use aliases

-- replace gaps with NULLS
Update tblEmployee
Set EmployeeMiddleName = NULL
Where EmployeeMiddleName = ''

-- format(cast('2015-06-25 01:59:03.456' as datetime),'MM') as MyFormattedBritishDate
-- each month in the date of birth find the count of the number of ppl
SELECT format(DateOfBirth, 'MM') as MonthOfBirth, count(*) as CountOfBirths 
FROM tblEmployee
group by format(DateOfBirth, 'MM')

-- same thing but now we have a word rather than a number
SELECT datename(month ,DateOfBirth) as MonthOfBirth, count(*) as CountOfBirths 
FROM tblEmployee
group by datename(month ,DateOfBirth), format(DateOfBirth, 'MM') --datename(month, getdate())
order by format(DateOfBirth, 'MM') -- the thing you need to order with needs to be either in the group by or in the select part

--  format(cast('2015-06-25 01:02:03.456' as datetime),'D') as MyFormattedLongDate
-- same thing but now as above but now we use datepart function
SELECT datename(month ,DateOfBirth) as MonthOfBirth, count(*) as CountOfBirths, 
COUNT(EmployeeMiddleName) as NumberOfMiddleNames, --
count(*)-count(EmployeeMiddleName) as NoMiddleName,
format(min(DateOfBirth),'dd-MM-yy') as EarliestDateOfBirth,
format(max(DateOfBirth), 'D') as LatestDateOfBirth
FROM tblEmployee
group by datename(month ,DateOfBirth), DATEPART(month, DateOfBirth) --datename(month, getdate())
order by DATEPART(month, DateOfBirth)

-- Adding tables
-- Avoid SCD - Slow Changing Dimensions
CREATE TABLE tblTransaction  
(
Amount  SMALLMONEY NOT NULL,
DateOfTransaction smalldatetime NULL,
EmployeeNumber int NOT NULL
)

-- Join query

SELECT tblEmployee.EmployeeNumber, EmployeeFirstName, EmployeeLastName, Amount FROM tblEmployee
join tblTransaction 
on tblEmployee.EmployeeNumber = tblTransaction.EmployeeNumber

-- Sum amount
SELECT tblEmployee.EmployeeNumber, EmployeeFirstName, EmployeeLastName, sum(Amount) as SumOfAmount FROM tblEmployee
join tblTransaction -- default is inner join
on tblEmployee.EmployeeNumber = tblTransaction.EmployeeNumber
GROUP BY tblEmployee.EmployeeNumber, EmployeeFirstName, EmployeeLastName
ORDER BY tblEmployee.EmployeeNumber 

-- INNER JOIN default has to be in both tables
-- LEFT JOIN ALL the rows in the left table
-- RIGHT JOIN ALL the rows in right table
-- CROSS JOIN gives every single combination of the matrices

-- ADD a third table

-- derived table it has to be aliased

select Department
from
(select Department, count(*) as NumberOfDepartemnt from tblEmployee Group By Department) as newTable  

-- take these results and add them into a table into creates a new table
-- for Nvar char we put capital N before it if I want to make it into varchar 20
Select distinct Department, convert(varchar(20), N'') as DepartmentHead into tblDepartment from tblEmployee -- to get the distinct rows of the Department table

select * from tblDepartment

-- if I want to alter the table 
ALTER TABLE tblDepartment
ALTER COLUMN DepartmentHead varchar(30) null

-- joining 3 tables (table department table employee table transactions)


SELECT * FROM tblDepartment join tblEmployee on tblDepartment.Department = tblEmployee.Department 
join tblTransaction on tblEmployee.EmployeeNumber = tblTransaction.EmployeeNumber
group by tblDepartment.Department;


-- For each department which is the total amount of transactions
SELECT tblDepartment.Department, sum(Amount) FROM tblDepartment join tblEmployee on tblDepartment.Department = tblEmployee.Department 
join tblTransaction on tblEmployee.EmployeeNumber = tblTransaction.EmployeeNumber
group by tblDepartment.Department;

SELECT tblDepartment.DepartmentHead, sum(Amount) FROM tblDepartment left outer join tblEmployee on tblDepartment.Department = tblEmployee.Department 
left outer join tblTransaction on tblEmployee.EmployeeNumber = tblTransaction.EmployeeNumber
group by tblDepartment.DepartmentHead
order by DepartmentHead;

insert into tblDepartment(Department, DepartmentHead) values ('Accounts', 'James')

select D.DepartmentHead, sum(T.Amount) as SumOfAmount from tblDepartment as D
left join tblEmployee as E on D.Department = E.Department
left join tblTransaction as T on E.EmployeeNumber = T.EmployeeNumber
group by D.DepartmentHead 
order by D.DepartmentHead  -- Same Result as above


-- Find missing data, and delete and update data
-- In order for it to show the columns it must be both in the select and in the group by clause
select E.EmployeeNumber as ENumber, E.EmployeeFirstName,
       E.EmployeeLastName, T.EmployeeNumber as TNumber, 
       sum(T.Amount) as TotalAmount
from tblEmployee as E
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
where T.EmployeeNumber IS NULL
group by E.EmployeeNumber, T.EmployeeNumber, E.EmployeeFirstName,
       E.EmployeeLastName
order by E.EmployeeNumber, T.EmployeeNumber, E.EmployeeFirstName,
       E.EmployeeLastName

-- derived table

select *
from (
select E.EmployeeNumber as ENumber, E.EmployeeFirstName,
       E.EmployeeLastName, T.EmployeeNumber as TNumber, 
       sum(T.Amount) as TotalAmount
from tblEmployee as E
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
group by E.EmployeeNumber, T.EmployeeNumber, E.EmployeeFirstName,
       E.EmployeeLastName) as newTable
where TNumber is null
order by ENumber, TNumber, EmployeeFirstName, EmployeeLastName

GO

select ENumber, EmployeeFirstName, EmployeeLastName
from (
select E.EmployeeNumber as ENumber, E.EmployeeFirstName,
       E.EmployeeLastName, T.EmployeeNumber as TNumber, 
       sum(T.Amount) as TotalAmount
from tblEmployee as E
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
group by E.EmployeeNumber, T.EmployeeNumber, E.EmployeeFirstName,
       E.EmployeeLastName) as newTable
where TNumber is null
order by ENumber, TNumber, EmployeeFirstName, EmployeeLastName

-- Finds some phantom rows in the employee table.

select *
from (
select E.EmployeeNumber as ENumber, E.EmployeeFirstName,
       E.EmployeeLastName, T.EmployeeNumber as TNumber, 
       sum(T.Amount) as TotalAmount
from tblEmployee as E
right join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
group by E.EmployeeNumber, T.EmployeeNumber, E.EmployeeFirstName,
       E.EmployeeLastName) as newTable -- groups the select statement
where ENumber is null
order by ENumber, TNumber, EmployeeFirstName -- orders the select statement

GO

SELECT EmployeeNumber, EmployeeFirstName, EmployeeLastName FROM tblEmployee
order by EmployeeNumber ASC

-- Deleting data We need to delete the phantom rows from the table transaction.
-- Version 1

begin transaction

select count(*) from tblTransaction

delete tblTransaction -- the table from which I want to delete stuff
from tblEmployee as E
right join tblTransaction as T -- he joins them and then deletes the rows as a whole
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber is null

select count(*) from tblTransaction

rollback transaction -- to undo deleting the lines

select count(*) from tblTransaction

begin transaction
select count(*) from tblTransaction

delete tblTransaction
from tblTransaction
where EmployeeNumber IN
(select TNumber
from (
select E.EmployeeNumber as ENumber, E.EmployeeFirstName,
       E.EmployeeLastName, T.EmployeeNumber as TNumber, 
       sum(T.Amount) as TotalAmount
from tblEmployee as E
right join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
group by E.EmployeeNumber, T.EmployeeNumber, E.EmployeeFirstName,
       E.EmployeeLastName) as newTable -- this inside querry is a new table
where ENumber is null) -- !!! IF I do not put where it is going to delete the entirety of the table !!!
select count(*) from tblTransaction
rollback tran
select count(*) from tblTransaction

-- Updating data 
-- updating certain rows based on criteria

select * from tblEmployee where EmployeeNumber = 194
select * from tblTransaction where EmployeeNumber = 3
select * from tblTransaction where EmployeeNumber = 194

begin transaction
-- select * from tblTransaction where EmployeeNumber = 194
Update tblTransaction -- to update a table
set EmployeeNumber = 194
output inserted.*, deleted.* -- to show us what happens(like select)
from tblTransaction
-- where EmployeeNumber = 3
where EmployeeNumber in (3, 5, 7 ,9)

insert into tblTransaction
go
delete tblTransaction
from tblTransaction
where EmployeeNumber = 3
rollback tran