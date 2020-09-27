-- Union and Union all -- they need same number of columns
					   -- compatible data types (eg varchar and numbers are not compatible data types)

select * from inserted
union
select * from deleted

select convert(char(5), 'hi') as Greeting -- columns name come from the first set of data
union -- without union we get two seperate rows
select convert(char(11), 'hello there') 
union
select convert(char(11), 'bonjour')
union all -- union all does not remove the duplication
select convert(char(11), 'hi') -- duplicate rows are ignored in the union


with cte as (
select convert(tinyint, 45) as Mycolumn
union
select convert(bigint, 456)
)
select Mycolumn
into tblTemp
from cte

select 'hi there'
union
select convert(CHAR,4)


-- Intersect and except 
select *, Row_Number() over(order by(select null)) % 3 as ShouldIDelete
into tblTransactionNew
from tblTransaction

delete from tblTransactionNew
where ShouldIDelete = 1

update tblTransactionNew
set DateOfTransaction = dateadd(day,1,DateOfTransaction)
where ShouldIDelete = 2

alter table tblTransactionNew
drop column ShouldIDelete

SELECT * FROM tblTransaction
union --all -- to join them together (brings back everything that is new and old) η ένωση
SELECT * FROM tblTransactionNew
-- If I want to see only the rows that are different

SELECT * FROM tblTransaction
except -- to show the rows which are different (brings back everything that is new) η διαφορά
SELECT * FROM tblTransactionNew

SELECT * FROM tblTransaction
intersect --return the rows which are in both tables (brings back everything that is old) η τομή
SELECT * FROM tblTransactionNew
order by EmployeeNumber

-- they are better explained with 
-- case isnull coalesce

declare @myOption as varchar(10) = 'Option A'
-- IF I do not have an else statement anything not caught by when it evaluates to NULL
select case when @myOption = 'Option A' then 'First option'
			when @myOption = 'Option B' then 'Second option'
			else 'No Option' END as MyOptions

declare @myOption as varchar(10) = 'Option A'

select case @myOption when 'Option A' then 'First option'
					when 'Option B' then 'Second option' -- If I have strings and integers together I should convert them
					else 'No Option' END as MyOptions
go


-- isnull and coalesce
select * from tblEmployee where EmployeeMiddleName is null

-- 
declare @myOption as varchar(10) = 'Option B'
select isnull(@myOption, 'No Option') as MyOptions -- If my option is NULL then it evaluates to No Option
go

declare @myFirstOption as varchar(10) --= 'Option A' -- If both are NULL it goes to the last option
declare @mySecondOption as varchar(10) --= 'Option B'

select coalesce(@myFirstOption, @mySecondOption, 'No option') as MyOptions
go

select isnull('ABC',1) as MyAnswer -- takes the first non null type
select coalesce('ABC',1) as MyOtherAnswer -- the data type of lower precedance (here string) 
										  -- is converted to the data type with higher precedence (here int) 
go

select isnull(null,null) as MyAnswer
select coalesce(null,null) as MyOtherAnswer -- at least on expression must be the non null constant
go

create table tblExample
(myOption nvarchar(10) null)
go

insert into tblExample (myOption)
values ('Option A')

select coalesce(myOption, 'No option') as MyOptions
into tblIsCoalesce
from tblExample 
select case when myOption is not null then myOption else 'No option' end as myOptions from tblExample
go
select isnull(myOption, 'No option') as MyOptions -- gives us a not NULL column
into tblIsNull
from tblExample 
go

drop table tblExample
drop table tblIsCoalesce
drop table tblIsNull
-- modify data using Merge statements
-- filtering it in to existing data 
-- updating it whenever necessary
			-- target tbl
SELECT DateOfTransaction, EmployeeNumber, COUNT(*) AS NumberOfRows
FROM tblTransactionNew 
GROUP BY DateOfTransaction, EmployeeNumber
HAVING COUNT(*)>1

BEGIN TRAN
go
DISABLE TRIGGER TR_tblTransaction ON dbo.tblTransaction
GO
			-- target tbl
MERGE INTO tblTransaction as T
USING (SELECT DateOfTransaction, EmployeeNumber, MIN(Amount) as Amount
      FROM tblTransactionNew
	  GROUP BY DateOfTransaction, EmployeeNumber) as S
ON T.EmployeeNumber = S.EmployeeNumber AND
	T.DateOfTransaction = S.DateOfTransaction
WHEN MATCHED THEN
    UPDATE SET Amount = T.Amount + S.Amount
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Amount, DateOfTransaction, EmployeeNumber)
	VALUES (S.Amount, S.DateOfTransaction, S.EmployeeNumber)
	OUTPUT deleted.*, inserted.*;
ROLLBACK TRAN

-- Merge Columns too

BEGIN TRAN
go
DISABLE TRIGGER TR_tblTransaction ON dbo.tblTransaction
GO
ALTER TABLE tblTransaction
ADD Comments varchar(50) NULL
GO
MERGE TOP(5) PERCENT tblTransaction as T
USING (SELECT DateOfTransaction, EmployeeNumber, sum(Amount) as Amount
      FROM tblTransactionNew
	  GROUP BY EmployeeNumber, DateOfTransaction) as S
ON T.EmployeeNumber = S.EmployeeNumber AND
	T.DateOfTransaction = S.DateOfTransaction
WHEN MATCHED AND T.Amount + S.Amount >0 THEN -- when the exist in bot matrices update the amount -- you can also put some other condition too
    UPDATE SET Amount = T.Amount + S.Amount, Comments = 'Updated Row'
WHEN MATCHED THEN
	DELETE 
WHEN NOT MATCHED BY TARGET THEN -- When it does not exist in the target insert the row
	INSERT (Amount, DateOfTransaction, EmployeeNumber, Comments)
	VALUES (S.Amount, S.DateOfTransaction, S.EmployeeNumber, 'Inserted Row')
--	OUTPUT deleted.*, inserted.*;
WHEN NOT MATCHED BY SOURCE THEN -- When it exist in the target and not in the source table the row is unchanged 
	UPDATE SET Comments = 'Unchanged'
OUTPUT deleted.*, inserted.*, $action; --Unique to the merge statement
Select * from tblTransaction ORDER BY EmployeeNumber, DateOfTransaction -- first order by employ number and then by date of transaction
ROLLBACK TRAN

select * from tblTransaction

ALTER TABLE tblTransaction
Drop Column Comments

-- Procedures

-- To drop a procedure 
select object_ID('NameEmployees','P') IS NOT NULL -- Another way to delete the procedure

If exists (select * from sys.procedures where name='NameEmployees')
	drop proc NameEmployees

GO
create proc NameEmployees(@EmployeeNumber int) as -- this procedure became like a function
begin -- procs should be surrounded by begin and end
	-- not get select statement when the Employee does not exist
	if exists (Select * from tblEmployee where EmployeeNumber = @EmployeeNumber) -- you can also have multiple arguments seperating them by coma
		begin
			if @EmployeeNumber < 300
			begin
				select EmployeeNumber, EmployeeFirstName, EmployeeLastName
				from tblEmployee
				where EmployeeNumber = @EmployeeNumber
			end
	else
		begin
			select EmployeeNumber, EmployeeFirstName, EmployeeLastName, Department
			from tblEmployee
			where EmployeeNumber = @EmployeeNumber
			select * from tblTransaction where EmployeeNumber = @EmployeeNumber	
		end
	end
end
go

-- the name only to exec proc should be after a GO statement Procedures help accessing the data access layer
NameEmployees 4  -- this one failed on the first if
execute NameEmployees 223 
exec NameEmployees @EmployeeNumber = 233
GO

-- Ask for a specific employee
-- declaring a variable
Declare @EmployeeName int = 123
select @EmployeeName


-- go to command also exists
-- Execute with while
--if exists (select * from sys.procedures where name='NameEmployees')
if object_ID('NameEmployees','P') IS NOT NULL
drop proc NameEmployees
go
create proc NameEmployees(@EmployeeNumberFrom int, @EmployeeNumberTo int, @NumberOfRows int OUTPUT) as
begin
	if exists (Select * from tblEmployee where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo)
	begin
		select EmployeeNumber, EmployeeFirstName, EmployeeLastName
		from tblEmployee
		where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo
		SET @NumberOfRows = @@ROWCOUNT
		RETURN 0
	end
	ELSE
	BEGIN
	    SET @NumberOfRows = 0
		RETURN 1
	END
end
go
DECLARE @NumberRows int, @ReturnStatus int
EXEC @ReturnStatus = NameEmployees 4, 5, @NumberRows OUTPUT
select @NumberRows as MyRowCount, @ReturnStatus as Return_Status
GO
DECLARE @NumberRows int, @ReturnStatus int
execute @ReturnStatus = NameEmployees 4, 327, @NumberRows OUTPUT
select @NumberRows as MyRowCount, @ReturnStatus as Return_Status
GO
DECLARE @NumberRows int, @ReturnStatus int
exec @ReturnStatus = NameEmployees @EmployeeNumberFrom = 323, @EmployeeNumberTo = 327, @NumberOfRows = @NumberRows OUTPUT
select @NumberRows as MyRowCount, @ReturnStatus as Return_Status

-- return statement

-- Execute with while
--if exists (select * from sys.procedures where name='NameEmployees')
if object_ID('NameEmployees','P') IS NOT NULL
drop proc NameEmployees
go
create proc NameEmployees(@EmployeeNumberFrom int, @EmployeeNumberTo int, @NumberOfRows int OUTPUT) as -- Export this value
begin
	if exists (Select * from tblEmployee where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo)
	begin
		declare @EmployeeNumber int = @EmployeeNumberFrom
		while @EmployeeNumber <= @EmployeeNumberTo
		BEGIN
			if exists (Select * from tblEmployee where EmployeeNumber = @EmployeeNumber)
			select EmployeeNumber, EmployeeFirstName, EmployeeLastName
			from tblEmployee
			where EmployeeNumber = @EmployeeNumber
			SET @EmployeeNumber = @EmployeeNumber + 1
		END
	end
end
go
NameEmployees 4, 5
execute NameEmployees 223, 227
exec NameEmployees @EmployeeNumberFrom = 323, @EmployeeNumberTo = 1327


-- Procedure exercise

-- Try … Catch
--if exists (select * from sys.procedures where name='AverageBalance')
if object_ID('AverageBalance','P') IS NOT NULL
drop proc AverageBalance
go
create proc AverageBalance(@EmployeeNumberFrom int, @EmployeeNumberTo int, @AverageBalance int OUTPUT) as
begin
	SET NOCOUNT ON
	declare @TotalAmount money
	declare @NumOfEmployee int
	begin try
		select @TotalAmount = sum(Amount) from tblTransaction
		where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo
		select @NumOfEmployee = count(distinct EmployeeNumber) from tblEmployee
		where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo
		set @AverageBalance = @TotalAmount / @NumOfEmployee
		RETURN 0
	end try
	begin catch
		set @AverageBalance = 0
		SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_LINE() as ErrorLine,
			   ERROR_NUMBER() as ErrorNumber, ERROR_PROCEDURE() as ErrorProcedure,
			   ERROR_SEVERITY() as ErrorSeverity,  -- 0-10 for information
			   -- 16 default SQL SERVER log / Windows Application log
			   
			   -- 20-25 -- really bad errors
			   ERROR_STATE() as ErrorState
		RETURN 1
	end catch
end
go
DECLARE @AvgBalance int, @ReturnStatus int
EXEC @ReturnStatus = AverageBalance 4, 5, @AvgBalance OUTPUT
select @AvgBalance as Average_Balance, @ReturnStatus as Return_Status
GO
DECLARE @AvgBalance int, @ReturnStatus int
execute @ReturnStatus = AverageBalance 223, 227, @AvgBalance OUTPUT
select @AvgBalance as Average_Balance, @ReturnStatus as Return_Status
GO
DECLARE @AvgBalance int, @ReturnStatus int
exec @ReturnStatus = AverageBalance @EmployeeNumberFrom = 323, @EmployeeNumberTo = 327, @AverageBalance = @AvgBalance OUTPUT
select @AvgBalance as Average_Balance, @ReturnStatus as Return_Status

SELECT TRY_CONVERT(int, 'two')




-- Print
--if exists (select * from sys.procedures where name='AverageBalance')
if object_ID('AverageBalance','P') IS NOT NULL
drop proc AverageBalance
go
create proc AverageBalance(@EmployeeNumberFrom int, @EmployeeNumberTo int, @AverageBalance int OUTPUT) as
begin
	SET NOCOUNT ON
	declare @TotalAmount decimal(5,2)
	declare @NumOfEmployee int
	begin try
		print 'The employee numbers are from ' + convert(varchar(10),@EmployeeNumberFrom) 
		      + ' to ' + convert(varchar(10),@EmployeeNumberTo)
		select @TotalAmount = sum(Amount) from tblTransaction
		where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo
		select @NumOfEmployee = count(distinct EmployeeNumber) from tblEmployee
		where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo
		set @AverageBalance = @TotalAmount / @NumOfEmployee
		RETURN 0
	end try
	begin catch
		set @AverageBalance = 0
		if ERROR_NUMBER() = 8134 -- @@ERROR
		begin
			set @AverageBalance = 0
			print 'There are no valid employees in this range.'
			Return 8134
		end
		else
		    declare @ErrorMessage as varchar(255)
			select @ErrorMessage = error_Message()
			raiserror (@ErrorMessage, 16, 1)
			--throw 56789, 'Too many flanges', 1
		-- PRINT ERROR_MESSAGE() AS ErrorMessage, ERROR_LINE() as ErrorLine, 			   ERROR_NUMBER() as ErrorNumber, ERROR_PROCEDURE() as ErrorProcedure, 			   ERROR_SEVERITY() as ErrorSeverity,  -- 0-10 for information
			   -- 16 default SQL SERVER log / Windows Application log
			   
			   -- 20-25 
		--	   ERROR_STATE() as ErrorState
		--RETURN 1
		select 'Hi There'
	end catch
end
go
DECLARE @AvgBalance int, @ReturnStatus int
EXEC @ReturnStatus = AverageBalance 4, 5, @AvgBalance OUTPUT
select @AvgBalance as Average_Balance, @ReturnStatus as Return_Status
GO
DECLARE @AvgBalance int, @ReturnStatus int
execute @ReturnStatus = AverageBalance 223, 227, @AvgBalance OUTPUT
select @AvgBalance as Average_Balance, @ReturnStatus as Return_Status, 'Error did not stop us' as myMessage
GO
DECLARE @AvgBalance int, @ReturnStatus int
exec @ReturnStatus = AverageBalance @EmployeeNumberFrom = 323, @EmployeeNumberTo = 327, @AverageBalance = @AvgBalance OUTPUT
select @AvgBalance as Average_Balance, @ReturnStatus as Return_Status