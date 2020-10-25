USE [70-461]

SELECT * FROM tblTransaction AS T -- joins two tables on Employee Number
INNER JOIN tblEmployee AS E
ON E.EmployeeNumber = T.EmployeeNumber
WHERE E.EmployeeLastName LIKE 'Y%'
ORDER BY E.EmployeeNumber 

-- Alternative way
SELECT * FROM tblTransaction AS T
WHERE EmployeeNumber IN
	(SELECT EmployeeNumber FROM tblEmployee WHERE EmployeeLastName LIKE 'Y%') -- It is Run on a Sub-Querry
ORDER BY EmployeeNumber

-- Where and Not
SELECT * FROM tblTransaction AS T
WHERE EmployeeNumber IN
	(SELECT EmployeeNumber FROM tblEmployee WHERE EmployeeLastName NOT LIKE 'Y%') -- It is Run on a Sub-Querry
ORDER BY EmployeeNumber -- must be in tblEmployee AND tblTransaction, and not 126-129
                        -- INNER JOIN

SELECT * FROM tblTransaction AS T
WHERE EmployeeNumber NOT IN
	(SELECT EmployeeNumber FROM tblEmployee WHERE EmployeeLastName LIKE 'Y%') -- It is Run on a Sub-Querry
ORDER BY EmployeeNumber -- must be in tblTransaction, and not 126-129
                        -- LEFT JOIN

-- ANY, SOME and ALL
SELECT * FROM tblTransaction AS T
WHERE EmployeeNumber = ANY
	(SELECT EmployeeNumber FROM tblEmployee WHERE EmployeeLastName LIKE 'Y%') -- It is Run on a Sub-Querry
ORDER BY EmployeeNumber

-- Same as above
select * 
from tblTransaction as T
Where EmployeeNumber = some -- or "some"
    (Select EmployeeNumber from tblEmployee where EmployeeLastName like 'y%')
order by EmployeeNumber

-- ALL
SELECT * FROM tblTransaction AS T
WHERE EmployeeNumber <> ALL
	(SELECT EmployeeNumber FROM tblEmployee WHERE EmployeeLastName LIKE 'Y%') 
ORDER BY EmployeeNumber

-- any/some = OR
-- all = AND
SELECT * FROM tblTransaction AS T
WHERE EmployeeNumber <= ALL
	(SELECT EmployeeNumber FROM tblEmployee WHERE EmployeeLastName LIKE 'Y%') 
ORDER BY EmployeeNumber
-- anything up to 126 AND
-- anything up to 127 AND
-- anything up to 128 AND
-- anything up to 129

-- ANY = anything up to 129
-- ALL = anything up to 126

-- any/some = OR
-- all = AND

-- 126 <> all(126,127,128,129)
-- 126<>126 AND 126<>127 AND 126<>128 AND 126<>129
-- FALSE    AND TRUE = FALSE

-- 126 <> any(126,127,128,129)
-- 126<>126 OR 126<>127 OR 126<>128 OR 126<>129
-- FALSE    OR TRUE = TRUE


-- 7. Subqueries in the FROM clause
select * 
from tblTransaction as T
left join (select * from tblEmployee
where EmployeeLastName like 'y%') as E
on E.EmployeeNumber = T.EmployeeNumber
order by T.EmployeeNumber

select * 
from tblTransaction as T
left join tblEmployee as E
on E.EmployeeNumber = T.EmployeeNumber
Where E.EmployeeLastName like 'y%'
order by T.EmployeeNumber

select * 
from tblTransaction as T
left join tblEmployee as E
on E.EmployeeNumber = T.EmployeeNumber
and E.EmployeeLastName like 'y%' -- It is not good to use and in the join section
order by T.EmployeeNumber


-- The select Clause
SELECT * FROM tblEmployee as E
Where E.EmployeeLastName LIKE 'Y%'

SELECT *, (SELECT count(T.EmployeeNumber) FROM tblTransaction AS T) AS NumTransactions 
FROM tblEmployee AS E   -- We need to alias the table out of the derived clause
WHERE E.EmployeeLastName LIKE 'Y%'

SELECT *, (SELECT count(T.EmployeeNumber) FROM tblTransaction AS T
WHERE T.EmployeeNumber = E.EmployeeNumber) AS NumTransactions 
FROM tblEmployee AS E   -- We need to alias the table out of the derived clause
WHERE E.EmployeeLastName LIKE 'Y%' -- correlated subquery We do not know the E a table unless we finish the outer querry

SELECT *, (SELECT count(T.EmployeeNumber) 
			FROM tblTransaction AS T
			WHERE T.EmployeeNumber = E.EmployeeNumber) AS NumTransactions,
		  (SELECT sum(Amount)  -- You can't bring more than on column in a correlated query
			FROM tblTransaction AS T
			WHERE T.EmployeeNumber = E.EmployeeNumber) AS TotalAmount 
FROM tblEmployee AS E   -- We need to alias the table out of the derived clause
WHERE E.EmployeeLastName LIKE 'Y%' -- Another correlated querry

SELECT E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName, count(T.EmployeeNumber) AS NumTransactions
FROM tblTransaction AS T
INNER JOIN tblEmployee AS E 
ON E.EmployeeNumber = T.EmployeeNumber
WHERE E.EmployeeLastName LIKE 'y%'
GROUP BY E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName
ORDER BY E.EmployeeNumber

--Correlated subquerry in WHERE Clause
select * 
from tblTransaction as T
Where exists -- We only want those rows where exists employee number like '%Y' adn T.EmployeeNumber = E.EmployeeNumber
    (Select EmployeeNumber from tblEmployee as E where EmployeeLastName like 'y%' and T.EmployeeNumber = E.EmployeeNumber)
order by EmployeeNumber

select * 
from tblTransaction as T
Where not exists 
    (Select EmployeeNumber from tblEmployee as E where EmployeeLastName like 'y%' and T.EmployeeNumber = E.EmployeeNumber)
order by EmployeeNumber


select *, (Select EmployeeNumber from tblEmployee as E where EmployeeLastName like 'y%' 
and T.EmployeeNumber = E.EmployeeNumber) as DoesItExist
from tblTransaction as T
--Where exists -- We only want those rows where exists employee number like '%Y' adn T.EmployeeNumber = E.EmployeeNumber
order by EmployeeNumber


-- 10. Top X from various categories
-- Rank() is a windowed Function
-- Windowed functions can only appear in the SELECT or ORDER BY clauses

select * from
(select D.Department, EmployeeNumber, EmployeeFirstName, EmployeeLastName,
       rank() over(partition by D.Department order by E.EmployeeNumber) as TheRank
 from tblDepartment as D 
 join tblEmployee as E on D.Department = E.Department) as MyTable
where TheRank <= 5
order by Department, EmployeeNumber

-- The With Statement

-- It has to go in one batch
-- The With creates some derived table 
with MyTable AS
(select D.Department, EmployeeNumber, EmployeeFirstName, EmployeeLastName,
       rank() over(partition by D.Department order by E.EmployeeNumber) as TheRank
 from tblDepartment as D 
 join tblEmployee as E on D.Department = E.Department)

select * from MyTable
where TheRank <= 5
order by Department, EmployeeNumber


-- TblTransaction
-- Again it has to go in a batch
with tblWithRanking as
(select D.Department, EmployeeNumber, EmployeeFirstName, EmployeeLastName,
       rank() over(partition by D.Department order by E.EmployeeNumber) as TheRank
 from tblDepartment as D 
 join tblEmployee as E on D.Department = E.Department),
Transaction2014 as
(select * from tblTransaction where DateOfTransaction < '2015-01-01')

select * from tblWithRanking left join Transaction2014 ON tblWithRanking.EmployeeNumber = Transaction2014.EmployeeNumber
where TheRank <= 5
order by Department, tblWithRanking.EmployeeNumber


-- 12. Exercise 1
-- This is wrong
select E.EmployeeNumber from tblEmployee as E 
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
where T.EmployeeNumber IS NULL
order by E.EmployeeNumber

select max(EmployeeNumber) from tblTransaction;

-- Question: Show The employees that have never executed some Transaction
-- Here the answer
with Numbers as (
select top(select max(EmployeeNumber) from tblTransaction) row_Number() over(order by (select null)) as RowNumber
from tblTransaction as U)

select U.RowNumber from Numbers as U
left join tblTransaction as T
on U.RowNumber = T.EmployeeNumber
where T.EmployeeNumber is null
order by U.RowNumber

select row_number() over(order by(select null)) from sys.objects O cross join sys.objects P


--13. Exercise 2
with Numbers as (
select top(select max(EmployeeNumber) from tblTransaction) row_Number() over(order by (select null)) as RowNumber
from tblTransaction as U),
Transactions2014 as (
select * from tblTransaction where DateOfTransaction>='2014-01-01' and DateOfTransaction < '2015-01-01'),
tblGap as (
select U.RowNumber, 
       RowNumber - LAG(RowNumber) over(order by RowNumber) as PreviousRowNumber, 
	   LEAD(RowNumber) over(order by RowNumber) - RowNumber as NextRowNumber,
	   case when RowNumber - LAG(RowNumber) over(order by RowNumber) = 1 then 0 else 1 end as GroupGap
from Numbers as U
left join Transactions2014 as T
on U.RowNumber = T.EmployeeNumber
where T.EmployeeNumber is null),
tblGroup as (
select *, sum(GroupGap) over (ORDER BY RowNumber) as TheGroup
from tblGap)
select Min(RowNumber) as StartingEmployeeNumber, Max(RowNumber) as EndingEmployeeNumber,
       Max(RowNumber) - Min(RowNumber) + 1 as NumberEmployees
from tblGroup
group by TheGroup
order by TheGroup

-- Pivot

with myTable as
(select year(DateOfTransaction) as TheYear, month(DateOfTransaction) as TheMonth, Amount from tblTransaction)

-- Pivot table
select * from myTable
PIVOT (sum(Amount) for TheMonth in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) as myPvt
ORDER BY TheYear 

with myTable as
(select year(DateOfTransaction) as TheYear, month(DateOfTransaction) as TheMonth, Amount from tblTransaction)
-- We always have to alias the derived tables
Select TheYear, [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12]  from myTable
PIVOT (sum(Amount) for TheMonth in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) as myPvt
ORDER BY TheYear 

with myTable as
(select year(DateOfTransaction) as TheYear, month(DateOfTransaction) as TheMonth, Amount from tblTransaction)
-- Replacing Nulls IN Pivot
select TheYear, isnull([1],0) as [1], 
                isnull([2],0) as [2], 
				isnull([3],0) as [3],
				isnull([4],0) as [4],
				isnull([5],0) as [5],
				isnull([6],0) as [6],
				isnull([7],0) as [7],
				isnull([8],0) as [8],
				isnull([9],0) as [9],
				isnull([10],0) as [10],
				isnull([11],0) as [11],
				isnull([12],0) as [12] into tblPivot from myTable -- into tblPivot before after the select so that we get the info into a table
PIVOT (sum(Amount) for TheMonth in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) as myPvt
ORDER BY TheYear 

-- Unpivot
-- When unpivoting we can only get back what we can see
SELECT *
  FROM [tblPivot]
UNPIVOT (Amount FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS tblUnPivot
where Amount <> 0


-- Self Joins
begin tran
alter table tblEmployee
add Manager int
go
update tblEmployee
set Manager = ((EmployeeNumber-123)/10)+123
where EmployeeNumber>123
select E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName,
       M.EmployeeNumber as ManagerNumber, M.EmployeeFirstName as ManagerFirstName, 
	   M.EmployeeLastName as ManagerLastName
from tblEmployee as E
left JOIN tblEmployee as M
on E.Manager = M.EmployeeNumber

rollback tran

-- Recursive CTE (common table expression)
-- How many bosses does a person have ? CTE basically means with statement


begin tran
alter table tblEmployee
add Manager int
go
update tblEmployee
set Manager = ((EmployeeNumber-123)/10)+123
where EmployeeNumber>123;
with myTable as
(select EmployeeNumber, EmployeeFirstName, EmployeeLastName, 0 as BossLevel
FROM tblEmployee where Manager is null
UNION ALL
SELECT E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName, myTable.BossLevel + 1
from tblEmployee as E
join myTable on E.Manager = myTable.EmployeeNumber
)

select * from myTable

rollback tran


GO
-- 19. Scalar Functions 1
-- Advantage of functions is that they can be used in a select statement
-- returns only one value
CREATE FUNCTION AmountPlusOne(@Amount smallmoney)
RETURNS smallmoney
AS
BEGIN

    RETURN @Amount + 1

END
GO

													-- dbo is the schema differantiates the user defined from the built in funs
select DateOfTransaction, EmployeeNumber, Amount, dbo.AmountPlusOne(Amount) as AmountAndOne -- here 
from tblTransaction

-- you can also use the functions with exec
DECLARE @myValue smallmoney
EXEC @myValue = dbo.AmountPlusOne @Amount = 345.67
select @myValue


GO


-- 20. Scalar Functions 2
-- FN is type of functions
if object_ID(N'NumberOfTransactions',N'FN') IS NOT NULL
	DROP FUNCTION NumberOfTransactions
GO
CREATE FUNCTION NumberOfTransactions(@EmployeeNumber int)
RETURNS int
AS
BEGIN
	DECLARE @NumberOfTransactions INT
	SELECT @NumberOfTransactions = COUNT(*) FROM tblTransaction
	WHERE EmployeeNumber = @EmployeeNumber
	RETURN @NumberOfTransactions
END

GO

SELECT *, dbo.NumberOfTransactions(EmployeeNumber) as TransNum FROM tblEmployee


GO
-- Inline Table Functions
-- return a table
CREATE FUNCTION TransactionList(@EmployeeNumber int)
RETURNS TABLE AS RETURN
(
    SELECT * FROM tblTransaction
	WHERE EmployeeNumber = @EmployeeNumber
)

GO
SELECT * 
from dbo.TransactionList(123)

GO

select *
from tblEmployee
where exists(select * from dbo.TransactionList(EmployeeNumber))

select distinct E.*
from tblEmployee as E
join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber

select *
from tblEmployee as E
where exists(Select EmployeeNumber from tblTransaction as T where E.EmployeeNumber = T.EmployeeNumber)

GO

-- Inline
-- a user-defined function that returns a table data type and also it can accept parameters.
-- TVFs can be used after the FROM clause in the SELECT statements so that we can use them just like a table in the queries.
CREATE FUNCTION [dbo].[FunctionName]
(
    @param1 int,
    @param2 char(5)
)
RETURNS TABLE AS RETURN
(
    SELECT @param1 AS c1,
	       @param2 AS c2
)
GO
-- MultiStatement
/*
Multi-statement table-valued function returns a table as output and this output table structure 
can be defined by the user. MSTVFs can contain only one statement or more than one statement. 
Also, we can modify and aggregate the output table in the function body
*/
CREATE FUNCTION TransList(@EmployeeNumber int)
RETURNS @TransListTb TABLE
(Amount smallmoney,
DateOfTransaction smalldatetime,
EmployeeNumber int   
)
AS
BEGIN
    INSERT INTO @TransListTb(Amount, DateOfTransaction, EmployeeNumber) --Translist is the table
    SELECT Amount, DateOfTransaction, EmployeeNumber FROM tblTransaction
	WHERE EmployeeNumber = @EmployeeNumber
    RETURN 
END

SELECT * 
FROM TransList(123)
GO

-- 22. Apply
SELECT * 
from dbo.TransList(123)
GO

select *, (select count(*) from dbo.TransList(E.EmployeeNumber)) as NumTransactions
from tblEmployee as E

select *
from tblEmployee as E
outer apply TransList(E.EmployeeNumber) as T -- apply is used instead of join for functions

-- 54
--123 left join TransList(123)
--124 left join TransList(124)

--outer apply all of tblEmployee, UDF 0+ rows
--cross apply UDF 1+ rows

--outer apply = LEFT JOIN
--cross apply = INNER JOIN

select *
from tblEmployee as E
where  (select count(*) from dbo.TransList(E.EmployeeNumber)) >3


-- Synonyms 
-- System meta data
select * from sys.views
select * from sys.synonyms


-- let's create a synonym 
-- to change the name of the table 
-- we do not have to have the tblEmployee at the time of creation
create synonym EmployeeTable 
for tblEmployee
go

select * from EmployeeTable

create synonym DateTable
for tblDate
go

select * from DateTable

create synonym RemoteTable
for OVERTHERE.[70-461].remote.dbo.tblRemote
	-- name of server


-- 24. Dynamic Queries
select * from tblEmployee where EmployeeNumber = 129;
go
-- variable have sequel commands
declare @command as varchar(255);
set @command = 'select * from tblEmployee where EmployeeNumber = 129;'
-- then execute the command 
set @command = 'Select * from tblTransaction'
execute (@command);
go
declare @command as varchar(255), @param as varchar(50);
set @command = 'select * from tblEmployee where EmployeeNumber = '
-- in case this parameter is set by the end user
set @param ='129 or 1=1'
execute (@command + @param); --sql injection potential
go
declare @command as nvarchar(255), @param as nvarchar(50);
set @command = N'select * from tblEmployee where EmployeeNumber = @ProductID' -- sq_executesql uses nvarchars
set @param =N'129 or 1=1'
execute sys.sp_executesql @statement = @command, @params = N'@ProductID int', @ProductID = @param; -- this one fails because it tries to 
																								   -- convert the string to a number



-- we might get holes in our tables in our Identity column
-- even if we delete the table the Identity does not reset
-- in order to reset we have to tranctuate the table
begin tran
insert into tblEmployee2
values ('New Name')
select * from tblEmployee2
rollback tran
truncate table tblEmployee2


-- GUIDs - Globally Unique IDentifier
declare @newvalue as uniqueidentifier --GUID
SET @newvalue = NEWID() -- It is presented in hexadecimal
SELECT @newvalue as TheNewID
GO
declare @randomnumbergenerator int = DATEPART(MILLISECOND,SYSDATETIME())+1000*(DATEPART(SECOND,SYSDATETIME())
                                     +60*(DATEPART(MINUTE,SYSDATETIME())+60*DATEPART(HOUR,SYSDATETIME())))
SELECT RAND(@randomnumbergenerator) as RandomNumber;
-- If the date was a variable everytime we run it generates a unique number.
begin tran
Create table tblEmployee4
(UniqueID uniqueidentifier CONSTRAINT df_tblEmployee4_UniqueID DEFAULT NEWID(),
EmployeeNumber int CONSTRAINT uq_tblEmployee4_EmployeeNumber UNIQUE)
-- The Unique ID changes each time
Insert into tblEmployee4(EmployeeNumber)
VALUES (1), (2), (3)
select * from tblEmployee4
rollback tran
go
declare @newvalue as uniqueidentifier
SET @newvalue = NEWSEQUENTIALID() -- can only be used in a column as default constraint
SELECT @newvalue as TheNewID
GO
begin tran
Create table tblEmployee4
(UniqueID uniqueidentifier CONSTRAINT df_tblEmployee4_UniqueID DEFAULT NEWSEQUENTIALID(), -- the generations of IDs is more predictable.
-- the value though is very long and is very memory hungry
-- the more bytes the PK requires has a performance hit.
EmployeeNumber int CONSTRAINT uq_tblEmployee4_EmployeeNumber UNIQUE)

Insert into tblEmployee4(EmployeeNumber)
VALUES (1), (2), (3)
select * from tblEmployee4
rollback tran

-- Sequences
BEGIN TRAN
CREATE SEQUENCE newSeq AS BIGINT -- we define the datatype.  
-- the first number of the sequence
START WITH 1
-- the step of the sequence
INCREMENT BY 1
-- max value or min value
MINVALUE 1
--MAXVALUE 999999
-- if the sequence will cycle or not.(go back to the minimum value)
--CYCLE
CACHE 50
CREATE SEQUENCE secondSeq AS INT
SELECT * FROM sys.sequences
ROLLBACK TRAN


-- 28. NEXT VALUE FOR sequence
BEGIN TRAN
CREATE SEQUENCE newSeq AS BIGINT
START WITH 1
INCREMENT BY 1
MINVALUE 1
CACHE 50
select NEXT VALUE FOR newSeq as NextValue;
--select *, NEXT VALUE FOR newSeq OVER (ORDER BY DateOfTransaction) as NextNumber from tblTransaction
rollback tran

CREATE SEQUENCE newSeq AS BIGINT
START WITH 1
INCREMENT BY 1
MINVALUE 1
--MAXVALUE 999999
--CYCLE
CACHE 50

alter table tblTransaction
ADD NextNumber int CONSTRAINT DF_Transaction DEFAULT NEXT VALUE FOR newSeq

alter table tblTransaction
drop DF_Transaction
alter table tblTransaction
drop column NextNumber

alter table tblTransaction
add NextNumber int
alter table tblTransaction
add CONSTRAINT DF_Transaction DEFAULT NEXT VALUE FOR newSeq for NextNumber

begin tran
select * from tblTransaction
INSERT INTO tblTransaction(Amount, DateOfTransaction, EmployeeNumber)
VALUES (1,'2017-01-01',123)
select * from tblTransaction WHERE EmployeeNumber = 123;
update tblTransaction
set NextNumber = NEXT VALUE FOR newSeq
where NextNumber is null
select * from tblTransaction --WHERE EmployeeNumber = 123
ROLLBACK TRAN

--SET IDENTITY_INSERT tablename ON
--DBCC CHECKIDENT(tablename,RESEED)

alter sequence newSeq -- this way we resart the sequence to the number we wish too
restart with 1

alter table tblTransaction
drop DF_Transaction
alter table tblTransaction
drop column NextNumber
DROP SEQUENCE newSeq


-- Introduction to XML
-- let's make a shopping list - XML helps the computer understand the stuff
-- XML has several tags

-- Creating XML variable and XML field
go

declare @x xml
set @x = '<Shopping ShopperName="Phillip Burton" Weather="Nice">
<ShoppingTrip ShoppingTripID="L1">
    <Item Cost="5">Bananas</Item>
    <Item Cost="4">Apples</Item>
    <Item Cost="3">Cherries</Item>
</ShoppingTrip>
<ShoppingTrip ShoppingTripID="L2">
    <Item>Emeralds</Item>
    <Item>Diamonds</Item>
    <Item>Furniture</Item>
</ShoppingTrip>
</Shopping>' -- This a string after all?

-- select @x

--alter table [dbo].[tblEmployee]
--add XMLOutput xml null


update [dbo].[tblEmployee] 
set XMLOutput = @x
where EmployeeNumber = 200

select * from [dbo].[tblEmployee]

alter table [dbo].[tblEmployee]
drop column xmlOutput
-- convert existing tables into XML

select E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName, 
		E.DateOfBirth, T.Amount, T.DateOfTransaction from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber between 200 and 202
for XML raw('MyRow'), elements -- you can put type also instead of elements

select E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName, 
		E.DateOfBirth, T.Amount, T.DateOfTransaction from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber between 200 and 202
for XML auto, elements -- you need to go to a parent element to find who did what
					   -- instead of everything being attributes everything is elements



-- path 
select 	E.EmployeeFirstName as '@EmployeeFirstName', 
		E.EmployeeLastName as '@EmployeeLastName',
		E.EmployeeNumber,
		E.DateOfBirth, 
		T.Amount, 
		T.DateOfTransaction from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber between 200 and 202
for XML path('Employees') -- the advantage of path is that we can say which items are attributes and which are going to be elements

-- nested stuff
select 	E.EmployeeFirstName as '@EmployeeFirstName', 
		E.EmployeeLastName as '@EmployeeLastName',
		E.EmployeeNumber,
		E.DateOfBirth, 
		T.Amount as 'Transaction/Amount', 
		T.DateOfTransaction 'Transaction/DateOfTransaction' from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber between 200 and 202
for XML path('Employees')

-- to have the amounts of each employee under his name 
select 	E.EmployeeFirstName, --as '@EmployeeFirstName', 
		E.EmployeeLastName, --as '@EmployeeLastName',
		E.EmployeeNumber,
		E.DateOfBirth, 
		(select T.Amount as 'Amount' from tblTransaction as T
		where T.EmployeeNumber = E.EmployeeNumber
		for xml path(''), type) as Amount
		from [dbo].[tblEmployee] as E
where E.EmployeeNumber between 200 and 202
for XML path('Elements'), root('MyXML')

-- FOR XML EXPLICIT
-- it is not often used 
select 1 as Tag, NULL as Parent -- should have a column name Tag, -- And the second column needs to be a Parent(often NULL)
       , E.EmployeeFirstName as [Elements!1!EmployeeFirstName] -- you need to alias everything
	   , E.EmployeeLastName as [Elements!1!EmployeeLastName]
	   , E.EmployeeNumber as [Elements!1!EmployeeNumber]
       , E.DateOfBirth as [Elements!1!DateOfBirth]
	   , null as [Elements!2!Amount]
	   , null as [Elements!2!DateOfTransaction]
from [dbo].[tblEmployee] as E
where E.EmployeeNumber between 200 and 202
-- for XML explicit
union all
select 2 as Tag, 1 as Parent
       , null as [EmployeeFirstName]
	   , null as [EmployeeLastName]
	   , T.EmployeeNumber
	   , null as DateOfBirth
	   , Amount
	   , DateOfTransaction
from [dbo].[tblTransaction] as T
inner join [dbo].[tblEmployee] as E on T.EmployeeNumber = E.EmployeeNumber
where T.EmployeeNumber between 200 and 202
order by EmployeeNumber, [Elements!2!Amount]
for xml explicit



-- Shredding XML data 
declare @x xml  
set @x='<Shopping ShopperName="Phillip Burton" >  
<ShoppingTrip ShoppingTripID="L1" >  
  <Item Cost="5">Bananas</Item>  
  <Item Cost="4">Apples</Item>  
  <Item Cost="3">Cherries</Item>  
</ShoppingTrip>  
<ShoppingTrip ShoppingTripID="L2" >  
  <Item>Emeralds</Item>  
  <Item>Diamonds</Item>  
  <Item>Furniture</Item>  
</ShoppingTrip>  
</Shopping>'  
select @x.value('(/Shopping/ShoppingTrip/Item/@Cost)[1]','varchar(50)')
--x.value takes 2 arguments -- @ sign to indicate 
-- first: how to navigate the way down
-- second: kind of argument to be returned

-- 36. XQuery Modify method
declare @x xml  
set @x='<Shopping ShopperName="Phillip Burton" >  
<ShoppingTrip ShoppingTripID="L1" >  
  <Item Cost="5">Bananas</Item>  
  <Item Cost="4">Apples</Item>  
  <Item Cost="3">Cherries</Item>  
</ShoppingTrip>  
<ShoppingTrip ShoppingTripID="L2" >  
  <Item>Emeralds</Item>  
  <Item>Diamonds</Item>  
  <Item>Furniture</Item>  
</ShoppingTrip>  
</Shopping>' 



set @x.modify('replace value of (/Shopping/ShoppingTrip[1]/Item[3]/@Cost)[1]
                  with "6.0"') -- to modify some xml Value

select @x

set @x.modify('insert <Item Cost="5">New Food</Item>
			   into (/Shopping/ShoppingTrip)[2]')
select @x

-- 37. XQuery Query and FLWOR 1
/*
This is the order
For
Let
Where
Order by
Return
*/
-- in x query we need to use a variable 
select @x.query('for $ValueRetrieved in /Shopping/ShoppingTrip/Item 
                 return $ValueRetrieved')
-- now we ask to retrieve just the string element
select @x.query('for $ValueRetrieved in /Shopping/ShoppingTrip/Item
                 return string($ValueRetrieved)')
select @x.query('for $ValueRetrieved in /Shopping/ShoppingTrip[1]/Item
                 return concat(string($ValueRetrieved),";")')



-- 38. XQuery Query and FLWOR 2
-- I want all those that the cost is greater or equal than four
select @x.query('for $ValueRetrieved in /Shopping/ShoppingTrip[1]/Item
                 let $CostVariable := $ValueRetrieved/@Cost
                 where $CostVariable >= 4
                 order by $CostVariable
                 return concat(string($ValueRetrieved),";")')

-- 39. nodes using Variable (shredding a variable)
-- say we want the node shopping trip shopping trip
-- we use x.nodes in the from clause
declare @x xml  
set @x='<Shopping ShopperName="Phillip Burton" >  
<ShoppingTrip ShoppingTripID="L1" >  
  <Item Cost="5">Bananas</Item>  
  <Item Cost="4">Apples</Item>  
  <Item Cost="3">Cherries</Item>  
</ShoppingTrip>  
<ShoppingTrip ShoppingTripID="L2" >  
  <Item>Emeralds</Item>  
  <Item>Diamonds</Item>  
  <Item>Furniture</Item>  
</ShoppingTrip>  
</Shopping>' 

-- here we create an item by parsing the XML
select tbl.col.value('.', 'varchar(50)') as Item
     , tbl.col.value('@Cost','varchar(50)') as Cost
into tblTemp
from @x.nodes('/Shopping/ShoppingTrip/Item') as tbl(col)

select * from tblTemp

drop table tblTemp
--for let where order by return


-- 40. notes using table (shredding a table)
begin tran
declare @x1 xml, @x2 xml 
set @x1='<Shopping ShopperName="Phillip Burton" >  
<ShoppingTrip ShoppingTripID="L1" >  
  <Item Cost="5">Bananas</Item>  
  <Item Cost="4">Apples</Item>  
  <Item Cost="3">Cherries</Item>
</ShoppingTrip></Shopping>'
set @x2='<Shopping ShopperName="Phillip Burton" >
<ShoppingTrip ShoppingTripID="L2" >  
  <Item>Emeralds</Item>  
  <Item>Diamonds</Item>  
  <Item>Furniture</Item>  
</ShoppingTrip>  
</Shopping>'  

--drop table #tblXML
create table #tblXML(pkXML INT PRIMARY KEY, xmlCol XML)

insert into #tblXML(pkXML, xmlCol) VALUES (1, @x1)
insert into #tblXML(pkXML, xmlCol) VALUES (2, @x2)

select * from #tblXML
select tbl.col.value('@Cost','varchar(50)')
from #tblXML CROSS APPLY -- when the tables are related we use cross apply
xmlCol.nodes('/Shopping/ShoppingTrip/Item') as tbl(col)

rollback tran

--41. Importing and exporting XML using the bcp utility
-- bcp to import and xport XMLs
-- this utility is not from sql server
-- we need to use the command prompt
bcp [70-461].dbo.tblDepartment out mydata.out -N -T -- the parameters at windows are called switches. 
													-- N: unicode chars T: microsoft authentication Trusted connection
create table dbo.tblDepartment2
([Department] varchar(19) null,
[DepartmentHead] varchar(19) null)
bcp [70-461].dbo.tblDepartment2 in mydata.out -N –T


-- 42. Bulk Insert and Openrowset
drop table #tblXML
go
create table #tblXML(XmlCol xml)
go
bulk insert #tblXML from 'C:\xml\SampleDataBulkInsert.txt'
select * from #tblXML

drop table #tblXML
go
create table #tblXML(IntCol int, XmlCol xml)
go
insert into #tblXML(XmlCol)
select * from
openrowset(BULK 'C:\XML\SampleDataOpenRowset.txt', SINGLE_BLOB) AS x
select * from #tblXML

-- 43. Schema -- schema enforces a number to be a number and not a string or whatever
-- it gives a schema at the beginning
select E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName
	   , T.Amount, T.DateOfTransaction
from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber between 200 and 202
for xml raw, xmlschema --, xmldata




-- 46. XML Indexes
begin tran
declare @x1 xml, @x2 xml 
set @x1='<Shopping ShopperName="Phillip Burton" >  
<ShoppingTrip ShoppingTripID="L1" >  
  <Item Cost="5">Bananas</Item>  
  <Item Cost="4">Apples</Item>  
  <Item Cost="3">Cherries</Item>
</ShoppingTrip></Shopping>'
set @x2='<Shopping ShopperName="Phillip Burton" >
<ShoppingTrip ShoppingTripID="L2" >  
  <Item>Emeralds</Item>  
  <Item>Diamonds</Item>  
  <Item>Furniture
        <Color></Color></Item>  
</ShoppingTrip>  
</Shopping>'  

-- drop table #tblXML;
create table #tblXML(pkXML INT PRIMARY KEY, xmlCol XML)

insert into #tblXML(pkXML, xmlCol) VALUES (1, @x1)
insert into #tblXML(pkXML, xmlCol) VALUES (2, @x2)
-- here we create a primary index
create primary xml index pk_tblXML on #tblXML(xmlCol)
create xml index secpk_tblXML_Path on #tblXML(xmlCol)
       using xml index pk_tblXML FOR PATH
create xml index secpk_tblXML_Value on #tblXML(xmlCol)
       using xml index pk_tblXML FOR VALUE
create xml index secpk_tblXML_Property on #tblXML(xmlCol)
       using xml index pk_tblXML FOR PROPERTY
rollback tran





SELECT compatibility_level FROM sys.databases
where [name] = DB_NAME();








-- JSON used for exchanging data when going between a browser and a server 
declare @json NVARCHAR(4000)SET @json = '
{"name" : "Phillip",
 "ShoppingTrip":
	{"ShoppingTripItem": "L1",
	"Items":
	[
		{"Item":"Bananas", "Cost":5}, 
		{"Item":"Apples", "Cost":4}, 
		{"Item":"Cherries", "Cost":3} 
	]
	}}
'

--{"name":"Phillip", --This is an object. It is surrounded by curly braces {} name is the key, and Phillip is the value.
                     --It is in the format name colon value, then a comma before the next name.
--	"ShoppingTrip":
--	{"ShoppingTripItem": "L1",
--	"Items":
--	{"Item":"Bananas", "Cost":5} -- This is the Items value, and it is an object
--	}}

select isjson(@json)
select JSON_value(@json,'$."Name"')
--select JSON_value(@json,'strict $."Name"')
select JSON_value(@json,'strict $."name"')
select JSON_QUERY(@json,'$')
select json_value(@json,'strict $.ShoppingTrip.Items[1].Item')
select json_modify(@json,'strict $.ShoppingTrip.Items[1].Item','Big Bananas')
select json_modify(@json,'strict $.ShoppingTrip.Items[1]','{"Item":"Big Apples", "Cost":1}')
select json_modify(@json,'strict $.ShoppingTrip.Items[1]',json_query('{"Item":"Big Apples", "Cost":1}'))
select json_modify(@json,'$.Date','2022-01-1')
--select json_modify(@json,'strict $.ShoppingTrip.Items[1].Item','')
-- to convert json to table
select * from openjson(@json)
select * from openjson(@json,'$.ShoppingTrip.Items')
select * from openjson(@json,'$.ShoppingTrip.Items')
	with (Item varchar(10), Cost int)

select 'Bananas' as Item, 5 as Cost
UNION
select 'Apples' as Item, 4 as Cost
UNION
select 'Cherries' as Item, 3 as Cost
for json path, root('MyShopping Trip')

-- Temporal Tables
CREATE TABLE [dbo].[tblEmployeeTemporal](
	[EmployeeNumber] [int] NOT NULL PRIMARY KEY CLUSTERED,
	[EmployeeFirstName] [varchar](50) NOT NULL,
	[EmployeeMiddleName] [varchar](50) NULL,
	[EmployeeLastName] [varchar](50) NOT NULL,
	[EmployeeGovernmentID] [char](10) NOT NULL,
	[DateOfBirth] [date] NOT NULL, [Department] [varchar](19) NULL
	, ValidFrom datetime2(2) GENERATED ALWAYS AS ROW START -- HIDDEN -- this hidden hides the columns ValidFrom and ValidTo
	, ValidTo datetime2(2) GENERATED ALWAYS AS ROW END -- HIDDEN
	, PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo) -- for temporal table create this period for system_time referencing those particular cols
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.tblEmployeeHistory))
GO

INSERT INTO [dbo].[tblEmployeeTemporal]
	( [EmployeeNumber], [EmployeeFirstName], [EmployeeMiddleName], [EmployeeLastName]
    , [EmployeeGovernmentID], [DateOfBirth], [Department])
VALUES (123, 'Jane', NULL, 'Zwilling', 'AB123456G', '1985-01-01', 'Customer Relations'),
	(124, 'Carolyn', 'Andrea', 'Zimmerman', 'AB234578H', '1975-06-01', 'Commercial'),
	(125, 'Jane', NULL, 'Zabokritski', 'LUT778728T', '1977-12-09', 'Commercial'),
	(126, 'Ken', 'J', 'Yukish', 'PO201903O', '1969-12-27', 'HR'),
	(127, 'Terri', 'Lee', 'Yu', 'ZH206496W', '1986-11-14', 'Customer Relations'),
	(128, 'Roberto', NULL, 'Young', 'EH793082D', '1967-04-05', 'Customer Relations')

select * from dbo.tblEmployeeTemporal

update [dbo].[tblEmployeeTemporal] set EmployeeLastName = 'Smith' where EmployeeNumber = 124
update [dbo].[tblEmployeeTemporal] set EmployeeLastName = 'Albert' where EmployeeNumber = 124

select * from dbo.tblEmployeeTemporal


-- to drop a temporal table we need to set system version to off 
ALTER TABLE [dbo].[tblEmployeeTemporal] SET ( SYSTEM_VERSIONING = OFF  )
DROP TABLE [dbo].[tblEmployeeTemporal]
DROP TABLE [dbo].[tblEmployeeHistory]

--- Altering Existing Table
alter table [dbo].[tblEmployee]
add
ValidFrom datetime2(2) GENERATED ALWAYS AS ROW START CONSTRAINT def_ValidFrom DEFAULT SYSUTCDATETIME()
	, ValidTo datetime2(2) GENERATED ALWAYS AS ROW END CONSTRAINT def_ValidTo DEFAULT
																  CONVERT(datetime2(2), '9999-12-31 23:59:59') -- This is the max datetime

alter table dbo.tblEmployee
set (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.tblEmployeeHistory2))
-- Querying temporal data at a point of time
select * from dbo.tblEmployeeTemporal
FOR SYSTEM_TIME AS OF '2021-02-01' -- to see how values changed in temporal table through time -- when typing a date it is always midnight 00:00
-- Querying temporal data between time periods
select * from dbo.tblEmployeeTemporal
FOR SYSTEM_TIME
--FROM startdatetime TO enddatetime -- current and historic data, exclude enddatetime
--BETWEEN startdatetime AND enddatetime -- current and historic data, includes enddatetime
--CONTAINED IN (startdatetime, enddatetime) -- NOT current data; historic only

