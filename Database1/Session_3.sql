-- Problems with our database
select * from tblEmployee where EmployeeNumber = 2001

-- You can add transactions from non existing employees
select T.EmployeeNumber as TEmployeeNumber,
       E.EmployeeNumber as EEmployeeNumber,
	   sum(Amount) as SumAmount
from tblTransaction AS T
LEFT JOIN tblEmployee AS E
ON T.EmployeeNumber = E.EmployeeNumber
group by T.EmployeeNumber, E.EmployeeNumber
order by EEmployeeNumber

-- It should not be allowed to update date of birth after current date
BEGIN TRAN
UPDATE tblEmployee
SET DateOfBirth = '2101-01-01'
WHERE EmployeeNumber = 537
select * from tblEmployee ORDER BY DateOfBirth DESC
ROLLBACK TRAN

-- you cannot update 10 employees to the same government IDs
-- and they should follow certain criteria
BEGIN TRAN
UPDATE tblEmployee
SET EmployeeGovernmentID = 'aaaa'
WHERE EmployeeNumber BETWEEN 530 AND 539
select * from tblEmployee ORDER BY EmployeeGovernmentID ASC
ROLLBACK TRAN

insert into tblEmployee
select NULL, EmployeeFirstName, EmployeeMiddleName, EmployeeLastName, EmployeeGovernmentID, DateOfBirth, Department
from tblEmployee

-- Constraints.

delete from tblEmployee
Where EmployeeNumber > 2000
-- Unique constraints in action
alter table tblEmployee
ADD CONSTRAINT unqGovernmentID UNIQUE (EmployeeGovernmentID);

select EmployeeGovernmentID, count(EmployeeGovernmentID) as MyCount from tblEmployee
group by EmployeeGovernmentID
having count(EmployeeGovernmentID)>1

select * from tblEmployee where EmployeeGovernmentID IN ('WG884481Y')

begin tran
delete top(1) from tblEmployee
where EmployeeNumber = 224;
rollback tran -- I can to commit to tran to keep the change

alter table tblTransaction
add constraint unqTransaction UNIQUE (Amount, DateOfTransaction, EmployeeNumber) -- the same employ cannot have the same amount on the same date 

delete from tblTransaction
where EmployeeNumber = 131

insert into tblTransaction
VALUES (1,'2015-01-01', 131)
insert into tblTransaction
VALUES (1,'2015-01-01', 131)

alter table tblTransaction
Drop constraint unqTransaction

-- Add constraint to new tables
create table tblTransaction2
(Amount smallmoney not null,
DateOfTransaction smalldatetime not null,
EmployeeNumber int not null,
CONSTRAINT unqTransaction2 UNIQUE (Amount,DateOfTransaction,EmployeeNumber))

drop table tblTransaction2 
-- we modify a constraint my dropping it and recreating it 

--Default Constraints - Each column in a record must contain a value, even if that value is NULL
alter table tblTransaction
add DateOfEntry datetime

alter table tblTransaction
add constraint defDateOfEntry DEFAULT GETDATE() for DateOfEntry; -- After the DEFAULT Is the value we want to add, Then for which column(date of Entry)

delete from tblTransaction where EmployeeNumber < 3

insert into tblTransaction(Amount, DateOfTransaction, EmployeeNumber)
values (1, '2014-01-01', 1) -- This will add the current date of since we do not provide one like in the second case
insert into tblTransaction(Amount, DateOfTransaction, EmployeeNumber, DateOfEntry)
values (2, '2014-01-02', 1, '2013-01-01')

select * from tblTransaction where EmployeeNumber < 3

create table tblTransaction2
(Amount smallmoney not null,
DateOfTransaction smalldatetime not null,
EmployeeNumber int not null,
DateOfEntry datetime null CONSTRAINT tblTransaction2_defDateOfEntry DEFAULT GETDATE()) -- You cannot name the constraint the same in two seperate tables
																					   -- Ppl add the name of the table in the constraint
insert into tblTransaction2(Amount, DateOfTransaction, EmployeeNumber)
values (1, '2014-01-01', 1)
insert into tblTransaction2(Amount, DateOfTransaction, EmployeeNumber, DateOfEntry)
values (2, '2014-01-02', 1, '2013-01-01')

select * from tblTransaction2 where EmployeeNumber < 3

drop table tblTransaction2

alter table tblTransaction -- Then I can safely delete the column
drop column DateOfEntry

alter table tblTransaction
drop constraint defDateOfEntry -- First I need to drop the constraint and then I need to delete the column

-- Check Constraints -- Constraints a rows to some values Not necesserily for new rows
alter table tblTransaction
add constraint chkAmount check (Amount>-1000 and Amount < 1000)

insert into tblTransaction
values (1010, '2014-01-01', 1)

alter table tblEmployee with nocheck -- Do not check the existing rows
add constraint chkMiddleName check
(REPLACE(EmployeeMiddleName,'.','') = EmployeeMiddleName or EmployeeMiddleName is null)
-- Replace the . with a space
alter table tblEmployee
drop constraint chkMiddleName

begin tran
  insert into tblEmployee
  values (2003, 'A', 'B.', 'C', 'D', '2014-01-01', 'Accounts')
  select * from tblEmployee where EmployeeNumber = 2003
rollback tran

alter table tblEmployee with nocheck
add constraint chkDateOfBirth check (DateOfBirth between '1900-01-01' and getdate()) -- Date of birth should be between 1900-01-01 and getdate

begin tran
  insert into tblEmployee
  values (2003, 'A', 'B', 'C', 'D', '2115-01-01', 'Accounts')
  select * from tblEmployee where EmployeeNumber = 2003
rollback tran

create table tblEmployee2							-- here is the name of the constraint
(EmployeeMiddleName varchar(50) null, constraint CK_EmployeeMiddleName check -- if we omit the constraint name it give a random ugly name
(REPLACE(EmployeeMiddleName,'.','') = EmployeeMiddleName or EmployeeMiddleName is null))

drop table tblEmployee2

alter table tblEmployee
drop chkDateOfBirth
alter table tblEmployee
drop chkMiddleName
alter table tblTransaction
drop chkAmount

-- Primary key constraint 
-- Primary key is not null, clustered, one per table
-- If the key does not mean sth in real life (eg it is a number I have just added) it is called surrogate key
-- in contrast a natural key could be first, middle, and last name

alter table tblEmployee
add constraint PK_tblEmployee PRIMARY KEY (EmployeeNumber)

insert into tblEmployee(EmployeeNumber, EmployeeFirstName, EmployeeMiddleName, EmployeeLastName, 
EmployeeGovernmentID, DateOfBirth, Department) 
values (123, 'FirstName', 'MiddleName', 'LastName', 'AB12345FI', '2014-01-01', 'Accounts')

delete from tblEmployee
where EmployeeNumber = 224

alter table tblEmployee
drop constraint PK_tblEmployee
-- automatically numbers new rows(first number is the first number, 
-- and the second one how much it goes up in this case +1)
-- identity cannot be added to an existing column
-- If I have deleted a row the counter will keep growing and new entries will have 3,4 and so on
create table tblEmployee2
(EmployeeNumber int CONSTRAINT PK_tblEmployee2 PRIMARY KEY IDENTITY(1,1), 
EmployeeName nvarchar(20))

insert into tblEmployee2
values ('My Name'),
('My Name')

select * from tblEmployee2

delete from tblEmployee2

truncate table tblEmployee2

insert into tblEmployee2(EmployeeNumber, EmployeeName)
values (3, 'My Name'), (4, 'My Name')

SET IDENTITY_INSERT tblEmployee2 ON

insert into tblEmployee2(EmployeeNumber, EmployeeName)
values (38, 'My Name'), (39, 'My Name')

SET IDENTITY_INSERT tblEmployee2 OFF

drop table tblEmployee2

select @@IDENTITY --@@ two ats refer to global variable returns the last identity used
select SCOPE_IDENTITY() -- Work regardless of what table was updated. It always shows the last table updated

select IDENT_CURRENT('dbo.tblEmployee2') --this one takes a specific table

create table tblEmployee3
(EmployeeNumber int CONSTRAINT PK_tblEmployee3 PRIMARY KEY IDENTITY(1,1),
EmployeeName nvarchar(20))

insert into tblEmployee3
values ('My Name'),
('My Name')

-- Foreign Keys
-- it is the counterpart of the PK
-- A foreign key references that specific row in a table
-- The FK uses the resulting key that the dictionary has created (seeking)
-- The FK uses a PK or a unique constraint to seek the value
-- Foreign Key connects two tables (A foreign Key can be NULL) 
-- Foreign key can do no action (can cause error)
-- Foreign key can cascade( changes in one table affects the other tables)
-- Foreign key can set to NULL
-- Foreign key can set to default ()

BEGIN TRAN
ALTER TABLE tblTransaction ALTER COLUMN EmployeeNumber INT NULL 
ALTER TABLE tblTransaction ADD CONSTRAINT DF_tblTransaction DEFAULT 124 FOR EmployeeNumber
ALTER TABLE tblTransaction WITH NOCHECK
ADD CONSTRAINT FK_tblTransaction_EmployeeNumber FOREIGN KEY (EmployeeNumber)
REFERENCES tblEmployee(EmployeeNumber)
ON UPDATE CASCADE -- If there is a change in the PK they will be cascaded to the Foreign Key
-- ON UPDATE SET NULL
-- ON UPDATE SET DEFAULT
-- ON DELETE CASCADE -- there is also on delete set cascade
-- ON DELETE SET NULL -- there is also on delete set cascade
ON DELETE SET DEFAULT

-- UPDATE tblEmployee SET EmployeeNumber = 9123 Where EmployeeNumber = 123 -- You cannot change a PK if it is a refererence to a FK(unless Cascade)
DELETE tblEmployee Where EmployeeNumber = 123

SELECT E.EmployeeNumber, T.*
FROM tblEmployee as E
RIGHT JOIN tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
where T.Amount IN (-179.47, 786.22, -967.36, 957.03)

ROLLBACK TRAN

alter table tblTransaction
drop constraint DF_tblTransaction

alter table tblTransaction
drop constraint FK_tblTransaction_EmployeeNumber

UPDATE tblEmployee SET EmployeeNumber = 123 Where EmployeeNumber IS NULL

SELECT ISNULL(EmployeeNumber,123) FROM tblEmployee

--BEGIN TRAN
DELETE FROM tblEmployee
WHERE EmployeeNumber = 9123
SELECT * FROM tblEmployee where EmployeeNumber IN (123, 9123)
--ROLLBACK TRAN

SELECT * FROM tblEmployee where EmployeeNumber IN (123, 9123)
SELECT * FROM tblTransaction
where Amount IN (-179.47, 786.22, -967.36, 957.03)

-- CREATE Views And Stuff 
-- View should be created as batches
select 1
-- to uses oder
go
create view ViewByDepartment as 
select top(100) percent D.Department, T.EmployeeNumber, T.DateOfTransaction, T.Amount as TotalAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.DepartmentW
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
where T.EmployeeNumber between 120 and 139
order by D.Department, T.EmployeeNumber -- invalid in views unless TOP or OFFSET is also specified
go

create view ViewSummary as 
select D.Department, T.EmployeeNumber as EmpNum, sum(T.Amount) as TotalAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
group by D.Department, T.EmployeeNumber
--order by D.Department, T.EmployeeNumber
go
select * from ViewByDepartment -- Nobody can go in the ViewByDepartmentAndGetDateOfBirth
select * from ViewSummary

-- Altering and droping views

GO

if exists(select * from sys.views where name = 'ViewByDepartment')
	DROP view  dbo.ViewByDepartment
GO
-- I could also alter it If I wished
-- I can also use CREATE OR ALTER VIEW
-- If the view does not exist, it is CREATEd
-- If  the view does exist is ALTERed
Create view ViewByDepartment as 
select D.Department, T.EmployeeNumber, T.DateOfTransaction, T.Amount as TotalAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
where T.EmployeeNumber between 120 and 139
--order by D.Department, T.EmployeeNumber

GO
/*
DROP view  dbo.ViewByDepartment

-- To find the views in the system
-- To find if the view exists
if exists(select * from sys.views where name = 'ViewByDepartment')
*/

-- Security Views

select * from sys.syscomments as S -- To see views created and stuff
inner join sys.views as V 
on S.id = V.object_id

Select object_definition(object_id('dbo.ViewByDepartment'))
select * from sys.sql_modules
GO

-- To encrypt a view and not be able to get the code of it
Create view ViewByDepartment WITH ENCRYPTION as
select D.Department, T.EmployeeNumber, T.DateOfTransaction, T.Amount as TotalAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
where T.EmployeeNumber between 120 and 139 

GO

-- Chaining dbo.View which exposes dbo.Table1 and dbo.Table2(but those two tables each one individually deny select)
-- However if they have the same owner(schema) then someone can access them through the view


-- Adding new rows to views
-- You can insert rows to the undelying table by inserting rows to the view itself.
begin tran
-- if the modification affects multiple tables the we can not update through the view. 
-- In this case the Department affects multible tables.
insert into ViewByDepartment(EmployeeNumber, DateOfTransaction, TotalAmount)
values (132,'2015-07-07', 999.99)

select * from ViewByDepartment order by Department, EmployeeNumber -- we do not get the 142 because the view is between 120 and 139
select * from tblTransaction where EmployeeNumber in (132, 142)  

rollback tran

begin tran
select * from ViewByDepartment order by EmployeeNumber, DateOfTransaction
--Select * from tblTransaction where EmployeeNumber in (132,142)

update ViewByDepartment
set EmployeeNumber = 142
where EmployeeNumber = 132

select * from ViewByDepartment order by EmployeeNumber, DateOfTransaction
Select * from tblTransaction where EmployeeNumber in (132,142)
rollback tran

USE [70-461]
GO

--if exists(select * from sys.views where name = 'ViewByDepartment')
if exists(select * from INFORMATION_SCHEMA.VIEWS
where [TABLE_NAME] = 'ViewByDepartment' and [TABLE_SCHEMA] = 'dbo')
   drop view dbo.ViewByDepartment
go

CREATE view [dbo].[ViewByDepartment] as 
select D.Department, T.EmployeeNumber, T.DateOfTransaction, T.Amount as TotalAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
where T.EmployeeNumber between 120 and 139
WITH CHECK OPTION -- To avoid chaning values through a view
--order by D.Department, T.EmployeeNumber
GO

--Deleting rows in views
-- If the view is based on one table you can delete
-- Otherwise you cannot 
SELECT * FROM ViewByDepartment
delete from ViewByDepartment
where TotalAmount = 999.99 and EmployeeNumber = 132
GO
CREATE VIEW ViewSimple 
as
SELECT * FROM tblTransaction
GO
BEGIN TRAN
delete from ViewSimple
where EmployeeNumber = 132
select * from ViewSimple
ROLLBACK TRAN

--Index -- Seek Is much faster than scan
/* 
Creating a unique clustered index on a view improves query performance because the 
view is stored in the database in the same way a table with a clustered index is stored.
*/

GO

--if exists(select * from sys.views where name = 'ViewByDepartment')
if exists(select * from INFORMATION_SCHEMA.VIEWS
where [TABLE_NAME] = 'ViewByDepartment' and [TABLE_SCHEMA] = 'dbo')
   drop view dbo.ViewByDepartment
go

CREATE view [dbo].[ViewByDepartment] with schemabinding as 
select D.Department, T.EmployeeNumber, T.DateOfTransaction, T.Amount as TotalAmount
from dbo.tblDepartment as D -- We need to add the schema
inner join dbo.tblEmployee as E
on D.Department = E.Department
inner join dbo.tblTransaction as T
on E.EmployeeNumber = T.EmployeeNumber
where T.EmployeeNumber between 120 and 139
GO

CREATE UNIQUE CLUSTERED INDEX inx_ViewByDepartment on dbo.ViewByDepartment(EmployeeNumber, Department)

-- cannot be done cause it is referenced in the view
begin tran
drop table tblEmployee
rollback tran



-- Triggers
-- Creating an AFTER trigger
-- Whenever an insert is done the after trigger is called
-- 
GO
CREATE TRIGGER TR_tblTransaction
ON tblTransaction
AFTER DELETE, INSERT, UPDATE
AS
BEGIN
	--insert into tblTransaction2
	select *, 'Inserted' from Inserted
	--insert into tblTransaction2
	select *, 'Deleted' from Deleted
END
GO

-- SET NOCOUNT ON -- suppresses the 5 rows affected
-- Select * FROM tblDepartment
-- SET NOCOUNT OFF
BEGIN TRAN
insert into tblTransaction(Amount, DateOfTransaction, EmployeeNumber)
VALUES (123,'2015-07-10', 123)
--delete tblTransaction 
--where EmployeeNumber = 123 and DateOfTransaction = '2015-07-10'
ROLLBACK TRAN
GO
DISABLE TRIGGER TR_tblTransaction ON tblTransaction;
GO
ENABLE TRIGGER TR_tblTransaction ON tblTransaction;
GO
DROP TRIGGER TR_tblTransaction;
GO


-- Creating an INSTEAD OF trigger
ALTER TRIGGER tr_ViewByDepartment
ON dbo.ViewByDepartment
INSTEAD OF DELETE -- in the instead statement you can use only one of the Delete, Insert, Update
					-- it is generally used in views for insertion and deletions
					-- In the instead of delete we "capture" the delete and issue our own commands
AS
BEGIN
    declare @EmployeeNumber as int
	declare @DateOfTransaction as smalldatetime
	declare @Amount as smallmoney
	select @EmployeeNumber = EmployeeNumber, @DateOfTransaction = DateOfTransaction,  @Amount = TotalAmount
	from deleted -- THIS TABLE IS CREATED BECAUSE OF THE TRIGGER! THIS IS WHAT APPEARS IN THE SELECT!
	--SELECT * FROM deleted
	delete tblTransaction -- This trigger is altering table transaction
	from tblTransaction as T
	where T.EmployeeNumber = @EmployeeNumber
	and T.DateOfTransaction = @DateOfTransaction
	and T.Amount = @Amount
END

begin tran
-- SELECT * FROM ViewByDepartment where TotalAmount = -2.77 and EmployeeNumber = 132
delete from ViewByDepartment
where TotalAmount = -2.77 and EmployeeNumber = 132
SELECT * FROM ViewByDepartment where TotalAmount = -2.77 and EmployeeNumber = 132
rollback tran

GO
--Update functions
--@@ Nest level shows the depth of the trigger called (how deep into the triggers we currently are)
-- TRIGGER SHOULD ALSO be the only commands in the batch
ALTER TRIGGER TR_tblTransaction
ON tblTransaction
AFTER DELETE, INSERT, UPDATE
AS
BEGIN
	 if (@@NESTLEVEL = 1) -- @@ NESTLEVEL is a global var goes up to 32
	 begin
		SELECT *, 'TABLEINSERT' from Inserted
		SELECT *, 'TABLEDELETE' from Deleted
	end
END
GO

BEGIN TRAN
insert into tblTransaction(Amount, DateOfTransaction, EmployeeNumber)
VALUES(123,'2015-07-10', 123)
ROLLBACK TRAN 

begin tran
SELECT * FROM ViewByDepartment where TotalAmount = -2.77 and EmployeeNumber = 132 -- Why nest level is 2?
delete from ViewByDepartment
where TotalAmount = -2.77 and EmployeeNumber = 132
SELECT * FROM ViewByDepartment WHERE TotalAmount = -2.77 and EmployeeNumber = 132
rollback tran

EXEC sp_configure 'nested triggers'; -- if this is 0 the after triggers cannot be recursive but the instead of triggers can be 

EXEC sp_configure 'nested triggers',0;
RECONFIGURE
GO



-- Update functions
ALTER TRIGGER TR_tblTransaction
ON tblTransaction
AFTER UPDATE
AS
BEGIN
	--if @@ROWCOUNT > 0 -- ROWCOUNT again global variable
	IF inserted.DateOfTransaction = deleted.DateOfTransaction -- to check if the value has been changed
	IF UPDATE(DateOfTransaction)
	BEGIN
		select *, 'Inserted' from Inserted
		select *, 'Deleted - tblTransaction' from Deleted
	END
END
GO

UPDATE tblTransaction -- because update de;etes and then inserts we both Inserted and deleted
set EmployeeNumber = 124 --DateOfTransaction = '2015-07-12'
where Amount = 123 and DateOfTransaction = '2015-07-12' and EmployeeNumber = 123

delete tblTransaction where Amount = 123 and EmployeeNumber = 123

insert into tblTransaction(Amount, DateOfTransaction, EmployeeNumber)
VALUES (123,'2015-07-11', 123)

SELECT * FROM ViewByDepartment where TotalAmount = -2.77 and EmployeeNumber = 132

begin tran
delete from ViewByDepartment
where TotalAmount = -2.77 and EmployeeNumber = 132 -- the triggers runs all the time after a delete
rollback tran

-- What If I wanted to see if columns are being affected?? 
-- The hard way
GO
ALTER TRIGGER TR_tblTransaction
ON tblTransaction
AFTER DELETE, INSERT, UPDATE
AS
BEGIN
	--SELECT COLUMNS_UPDATED()
	-- IF UPDATE(Amount) -- if (COLUMNS_UPDATED() & POWER(2,1-1)) > 0
	IF COLUMNS_UPDATED() & 2 = 2 -- If the numbering of the columns changes then this code will break
	BEGIN
		select *, 'Inserted' from Inserted
		select *, 'Deleted - tblTransaction' from Deleted
	END
END
go


UPDATE tblTransaction -- because update de;etes and then inserts we both Inserted and deleted
set DateOfTransaction = '2015-07-12'
where Amount = 123 and DateOfTransaction = '2015-07-12' and EmployeeNumber = 124



begin tran
--SELECT * FROM ViewByDepartment where TotalAmount = -2.77 and EmployeeNumber = 132
update ViewByDepartment
set TotalAmount = +2.77
where TotalAmount = -2.77 and EmployeeNumber = 132
rollback tran


-- Good code - allows multiple rows to be deleted
GO
alter TRIGGER tr_ViewByDepartment
ON dbo.ViewByDepartment
INSTEAD OF DELETE
AS
BEGIN
	SELECT *, 'To Be Deleted' FROM deleted
       delete tblTransaction
	from tblTransaction as T
	join deleted as D
	on T.EmployeeNumber = D.EmployeeNumber
	and T.DateOfTransaction = D.DateOfTransaction
	and T.Amount = D.TotalAmount
END
GO

begin tran
SELECT *, 'Before Delete' FROM ViewByDepartment where EmployeeNumber = 132
delete from ViewByDepartment
where EmployeeNumber = 132 --and TotalAmount = 861.16
SELECT *, 'After Delete' FROM ViewByDepartment where EmployeeNumber = 132
rollback tran

-- whatever we are writing should handle more than one row at a time


