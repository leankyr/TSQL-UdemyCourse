USE [70-461] -- To get in the database want
GO

CREATE TABLE tb1Employee
(EmployeeNumber int, EmployeeName int);

ALTER TABLE tb1Employee
DROP COLUMN EmployeeName;

ALTER TABLE tb1Employee
ADD EmployeeName VARCHAR(20);

SELECT * FROM tb1Employee;

-- Creating Temporary Variables
DECLARE @myvar AS tinyint = 2; -- Local variables need @ tinyint needs only 1 byte
						   -- !! A local variable is only available in the batch it is created!!!!
SELECT @myvar as Result;
-- Changing the value of a local var
SET @myvar = @myvar * 3 + 1 -- If I give a float as a value it trunctuates to the int part 

SELECT @myvar as Result; 

-- Practise activity Number 3
DECLARE @myvar AS smallint;
SET @myvar = 20000;
SELECT @myvar;

-- Non integer numbers
DECLARE @myvar AS decimal (7,2); -- decimal(p, s) or numeric
SET @myvar = 12.34567; -- maximum number of digits to the left of the decimal point is 7-2 (p - s)
SELECT @myvar

DECLARE @myvar AS smallmoney;
DECLARE @myvar1 AS float(24); -- remember float is approximate or -- as real
DECLARE @myvar2 AS float(53);


----- mathematical functions -----

DECLARE @myvar AS decimal (7,2) = 3;
SELECT POWER(@myvar,2) -- Power returns float
SELECT SQUARE(@myvar)
SELECT POWER(@myvar,0.5)
SELECT SQRT(@myvar)


DECLARE @myvar AS decimal(5,4) = 9.225
SELECT FLOOR(@myvar);
SELECT CEILING(@myvar);
SELECT ROUND(@myvar,1); -- If second argument is 0 ROUND goes to the nearest number

GO

SELECT PI() as myPI;
SELECT EXP(1) as e;

DECLARE @myvar as numeric(7,2) = 456
SELECT ABS(@myvar), SIGN(@myvar)

-- Converting between data types

SELECT 3/2 -- dividing two integers results in an integer
SELECT 3.0/2 -- Results in Float

-- Converting between data types
-- Implicit

DECLARE @myvar as Decimal(5, 2) = 3
SELECT @myvar

-- Explicit

SELECT CONVERT(decimal(5,2),3);
SELECT CAST(3 as decimal(5, 2))/2;

-- Practise Activity 4


select system_type_id, column_id, ROUND(CONVERT(decimal(7,2),system_type_id) / column_id,0) as Calculation
from sys.all_columns

select system_type_id, column_id, CEILING(CONVERT(decimal(7,2),system_type_id) / column_id) as Calculation
from sys.all_columns

select system_type_id, column_id, ROUND(CONVERT(decimal(7,2),system_type_id) / column_id,1) as Calculation
from sys.all_columns

select TRY_CONVERT(TINYINT,2*system_type_id), column_id, system_type_id / column_id as Calculation
from sys.all_columns



-- Strings

-- char - ASCII - 1 byte char is fixed length
-- varchar - ASCII - 1 byte varchar is variable length

-- nchar - UNICODE - 2 bytes nchar is fixed length
-- nvarchar - UNICODE 2 bytes nvarchar is variable length

DECLARE @Chars as char(5);
SET @Chars = 'hello'
SELECT @Chars
SELECT len(@Chars), DATALENGTH(@Chars);


DECLARE @unicodeChars as nvarchar(10)
SET @Chars = N'hello'

-- the number in the nvarchar goes up to 8000 then we have varchar(max), nvarchar(max)
-- varchar(max) and nvarchar(max) got up to 2 GB 2 billion bytes

DECLARE @chrASCII as varchar(10) = 'hello';
DECLARE @chrUNICODE as nvarchar(10) = N'helloξ';

-- SQL is a 1 based language so we start counting from one unlike C or C# where we start counting from 0

select left(@chrASCII,2) as myASCII, right(@chrUNICODE,2) as myUNICODE;
DECLARE @chrASCII2 as varchar(10) = '  hello  '
select substring(@chrASCII2,3,2);
select ltrim(rtrim(@chrASCII2)) as TRIM;
select replace(@chrASCII, 'l', 'L');
select upper(@chrASCII) as myUpper;
select lower(@chrASCII) as myLower;

-- NULLS
declare @myvar as int
select @myvar as myCol

-- Concatinate strings
declare @firstname as nvarchar(20)
declare @middlename as nvarchar(20)
declare @lastname as nvarchar(20)

set @firstname = 'John'
-- set @middlename = 'Walker'
set @lastname = 'Smith'

-- to concatinate strings we use +

SELECT @firstname + ' ' + iif(@middlename is null, '', ' ' + @middlename) + ' ' + @lastname as FullName -- to handle Nulls
select @firstname + CASE WHEN @middlename IS NULL THEN '' ELSE ' ' + @middlename END + ' ' + @lastname as FullName
select @firstname + coalesce(' ' + @middlename,'') + ' ' + @lastname as FullName -- if any of arguments in here is NULL it ignores them
SELECT CONCAT(@firstname,' ' + @middlename, ' ' , @lastname) as FullName -- CONCAT also ignores the NULL strings

-- Joinings a string and a number

SELECT 'My Number is: ' + convert(varchar(10),4567)
SELECT 'My Number is: ' + cast(4567 as varchar(20))

select 'My salary is: ' + format(2345.6, 'C')
select 'My salary is: ' + format(2345.6, 'C','en-GB')
select 'My salary is: ' + format(2345.6, 'C','fr-FR') -- Check format documentation
select 'My salary is: ' + format(2345.6, 'C','ch-CH') -- Check format documentation

-- Practise activity number 5

select [name]
from sys.all_columns


select [name] + 'a'
from sys.all_columns

select [name] + N'Ⱥ'
from sys.all_columns


select substring([name],2,len([name])) as [name]
from sys.all_columns

select substring([name],1,len([name]) - 1) as [name]
from sys.all_columns --did not work

-- Date data types

declare @mydate as datetime = '2015-06-24 12:34:56.124'
select @mydate as myDate

declare @mydate2 as datetime2(3) = '20150624 12:34:56.124' -- 6 bytes for precision less than 3. 7 bytes for precision 3 or 4. All other precision require 8 bytes
select @mydate2 as MyDate

select DATEFROMPARTS(2015,06,24) as ThisDate -- you define the date partially
select DATETIME2FROMPARTS(2015,06,24,12,34,56,124,5) as ThatDate -- 124 is division of seconds and 5 is the number of decimals
select year(@mydate) as myYear, month(@mydate) as myMonth, day(@mydate) as myDay -- extract stuff from a date


-- Get todays date
SELECT CURRENT_TIMESTAMP as RightNow --Used in other SQL dialects
select getdate() as RightNow -- Microsoft's TSQl version returns getime data type
select SYSDATETIME() AS RightNow -- This one retunrs datetime2


select dateadd(year,1,'2015-01-02 03:04:05') as myYear  -- adds one year as specified
select datepart(hour,'2015-01-02 03:04:05') as myHour -- extracts the hour
select datename(WEEK, getdate()) as myAnswer 
select datediff(day,'2015-01-02 03:04:05',getdate()) as DaysElapsed -- returns an int datediff_big returns bigint


-- Date offsets
declare @myDateOffset as datetimeoffset(2) = '2015-06-25 01:02:03.456 +05:30' -- 8-10 bytes (datetime2)
select @myDateOffset as MyDateOffset
go
declare @myDate as datetime2 = '2015-06-25 01:02:03.456'
select TODATETIMEOFFSET(@myDate,'+05:30') as MyDateOffset --Time ahead or behind GMT

select DATETIME2FROMPARTS     (2015,06,25,1,2,3,456,     3)
select DATETIMEOFFSETFROMPARTS(2015,06,25,1,2,3,456,5,30,3) as MyDateOffset

select SYSDATETIMEOFFSET() as TimeNowWithOffset;
select SYSUTCDATETIME() as TimeNowUTC;

declare @myDateOffset as datetimeoffset = '2015-06-25 01:02:03.456 +05:30'
select SWITCHOFFSET(@myDateOffset,'-05:00') as MyDateOffsetTexas -- to change time zone



-- Converting from dates to strings
declare @mydate as datetime = '2015-06-25 01:02:03.456'
select 'The date and time is: ' + @mydate -- does not work because the convert precedence
go
declare @mydate as datetime = '2015-06-25 01:02:03.456'
select 'The date and time is: ' + convert(nvarchar(20),@mydate,104) as MyConvertedDate -- 104 is to output it in german format
go
declare @mydate as datetime = '2015-06-25 01:02:03.456'
select cast(@mydate as nvarchar(20)) as MyCastDate

select try_convert(date,'Thursday, 25 June 2015') as MyConvertedDate -- does not work
select parse('Thursday, 25 June 2015' as date) as MyParsedDate
select parse('Jueves, 25 de junio de 2015' as date using 'es-ES') as MySpanishParsedDate
select parse('Sonntag, 20 September 2020' as date using 'de-CH') as MySwissParsedDate


select format(cast('2015-06-25 01:02:03.456' as datetime),'D') as MyFormattedLongDate
select format(cast('2015-06-25 01:02:03.456' as datetime),'d') as MyFormattedShortDate
select format(cast('2015-06-25 01:59:03.456' as datetime),'dd-MM-yyyy') as MyFormattedBritishDate -- Months need to be in capitals
select format(cast('2015-06-25 01:02:03.456' as datetime),'D','zh-CN') as MyFormattedInternationalLongDate
