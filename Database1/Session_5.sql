select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

-- sum all the number of days that are in attendance for the entire period by the employ number per year
select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance as AttendanceYear,													-- -- partion by restricts the data the over uses							
sum(A.NumberAttendance) over(partition by A.EmployeeNumber, year(A.AttendanceMonth) order by A.AttendanceMonth DESC) as RunningMonth -- partion by reduces what the sum will look at
--convert(decimal(18,7), A.NumberAttendance) / sum(A.NumberAttendance) over(partition by A.EmployeeNumber) * 100 as PercentageAttendance -- calculates the entirety of this sum over the entire table
from tblEmployee as E join tblAttendance as A															  -- It totals Number Of Attendance over the entire table			
on E.EmployeeNumber = A.EmployeeNumber
--where year(A.AttendanceMonth) < '20150101'
order by A.EmployeeNumber, A.AttendanceMonth

select sum(NumberAttendance) from tblAttendance

-- Current ROW and Unbounded
select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance as AttendanceYear,													-- -- partion by restricts the data the over uses							
		sum(A.NumberAttendance) over(partition by A.EmployeeNumber, year(A.AttendanceMonth) order by A.AttendanceMonth DESC			-- for row 1 there is no preceding so it adds only the first two rows
		rows between unbounded preceding and 0 following) as RunningTotal															-- for the second row there is one before and one after so it adds three rows
from tblEmployee as E join tblAttendance as A																						-- for the last row there is no following so again it adds two rows
on E.EmployeeNumber = A.EmployeeNumber																								-- we are partitioning by Empoyee and year so it considers only the employee Number and the Year in the over and in the preceeding
																																	-- unbounded we are not bounded by any number


select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
SUM(A.NumberAttendance) over(PARTITION BY E.EmployeeNumber ORDER BY A.AttendanceMonth ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as RollingTotal
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
SUM(A.NumberAttendance) over(PARTITION BY E.EmployeeNumber ORDER BY A.AttendanceMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingTotal
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
SUM(A.NumberAttendance) over(PARTITION BY E.EmployeeNumber ORDER BY A.AttendanceMonth ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as RollingTotal
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

-- RANGE versus ROWS

select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance				-- rows: take the current and work the backward and forward from that row
,sum(A.NumberAttendance)													-- range: as current rows takes also the rows tied to that
over(partition by A.EmployeeNumber, year(A.AttendanceMonth) 
     order by A.AttendanceMonth 
	 rows between 1 preceding and current row) as RowsTotal
,sum(A.NumberAttendance) 
over(partition by A.EmployeeNumber, year(A.AttendanceMonth)					-- rows: may be slightly out of q when we have ties 
     order by A.AttendanceMonth 
	 range between current row and unbounded following) as RangeTotal
from tblEmployee as E join (select * from tblAttendance UNION ALL select * from tblAttendance) as A
on E.EmployeeNumber = A.EmployeeNumber
order by A.EmployeeNumber, A.AttendanceMonth

--unbounded preceding and current row
--current row and unbounded following
--unbounded preceding and unbounded following -- here range and rows are the same
-- range is slower because it has to work out the ties

-- 8. Omitting Range/Row?
select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance
,sum(A.NumberAttendance) over() as TotalAttendance
--,convert(decimal(18,7),A.NumberAttendance) / sum(A.NumberAttendance) over() * 100.0000 as PercentageAttendance
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

select sum(NumberAttendance) from tblAttendance

select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
sum(A.NumberAttendance) 
over(PARTITION BY E.EmployeeNumber, year(A.AttendanceMonth)
     ORDER BY A.AttendanceMonth) as SumAttendance
from tblEmployee as E join (select * from tblAttendance UNION ALL Select * from tblAttendance) as A
on E.EmployeeNumber = A.EmployeeNumber
order by A.EmployeeNumber, A.AttendanceMonth

--range between unbounded preceding and unbounded following - DEFAULT where there is no ORDER BY
--range between unbounded preceding and current row         - DEFAULT where there IS an ORDER BY


-- Implement aggregate querries

-- 9. ROW_NUMBER, RANK and DENSE_RANK
select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
ROW_NUMBER() OVER(ORDER BY E.EmployeeNumber, A.AttendanceMonth) as TheRowNumber, -- ROW_NUMBER() takes the row number
RANK() OVER(ORDER BY E.EmployeeNumber, A.AttendanceMonth) as TheRank, -- When there is A tie Rank stays at the minimum of ROW Numbers
DENSE_RANK() OVER(ORDER BY E.EmployeeNumber, A.AttendanceMonth) as TheDenseRank -- DENSE_RANK() does not skip. After I get a tie it goes to the next row number
from tblEmployee as E join 
(Select * from tblAttendance union all select * from tblAttendance) as A
on E.EmployeeNumber = A.EmployeeNumber

select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
ROW_NUMBER() OVER(PARTITION BY E.EmployeeNumber              -- PARTITION BY Divides the query result set into partitions. The window function is applied to each partition separately and computation restarts for each partition.
                  ORDER BY A.AttendanceMonth) as TheRowNumber,
RANK()       OVER(PARTITION BY E.EmployeeNumber
                  ORDER BY A.AttendanceMonth) as TheRank,
DENSE_RANK() OVER(PARTITION BY E.EmployeeNumber
                  ORDER BY A.AttendanceMonth) as TheDenseRank
from tblEmployee as E join 
(Select * from tblAttendance union all select * from tblAttendance) as A
on E.EmployeeNumber = A.EmployeeNumber

select *, row_number() over(order by (select null)) from tblAttendance -- if you do not care about the order and you just wnat row_numbers

-- 10. NTILE
select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
NTILE(10) OVER(PARTITION BY E.EmployeeNumber -- how many buckets you want the partion to be split into (you can use it with partition and order by)
          ORDER BY A.AttendanceMonth) as TheNTile,
convert(int,(ROW_NUMBER() OVER(PARTITION BY E.EmployeeNumber
                               ORDER BY A.AttendanceMonth)-1)
 / (count(*) OVER(PARTITION BY E.EmployeeNumber 
		          ORDER BY A.AttendanceMonth 
				  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)/10.0))+1 as MyNTile
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
where A.AttendanceMonth <'2015-05-01'



-- 11. FIRST_VALUE and LAST_VALUE
select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
first_value(NumberAttendance) -- takes your FIRST value from the partition and returns it to you
over(partition by E.EmployeeNumber order by A.AttendanceMonth) as FirstMonth,
last_value(NumberAttendance)  -- takes your LAST value from the partition and returns it to you
over(partition by E.EmployeeNumber order by A.AttendanceMonth
rows between unbounded preceding and unbounded following) as LastMonth
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

-- 12. LAG and LEAD
select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
lag(NumberAttendance, 2)  over(partition by E.EmployeeNumber  -- lag goes backwards -- third parameter is what it will print when the rows before does not exist.
                            order by A.AttendanceMonth) as MyLag,
lead(NumberAttendance, 1) over(partition by E.EmployeeNumber -- lead goes forwards
                            order by A.AttendanceMonth) as MyLead,
NumberAttendance - lag(NumberAttendance, 1)  over(partition by E.EmployeeNumber 
                            order by A.AttendanceMonth) as MyDiff
--first_value(NumberAttendance)  over(partition by E.EmployeeNumber 
--                                    order by A.AttendanceMonth
--							        rows between 1 preceding and current row) as MyFirstValue,
--last_value(NumberAttendance) over(partition by E.EmployeeNumber 
--                                  order by A.AttendanceMonth
--								  rows between current row and 1 following) as MyLastValue
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

-- 13. CUME_DIST and PERCENT_RANK
select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
CUME_DIST()    over(partition by E.EmployeeNumber -- cumelative Distribution -- in our case went in 22nds  
               order by A.AttendanceMonth) as MyCume_Dist,
PERCENT_RANK() over(partition by E.EmployeeNumber -- percent Rank -- in our case went in 21first
                order by A.AttendanceMonth) as MyPercent_Rank,
cast(row_number() over(partition by E.EmployeeNumber order by A.AttendanceMonth) as decimal(9,5))
/ count(*) over(partition by E.EmployeeNumber) as CalcCume_Dist,
cast(row_number() over(partition by E.EmployeeNumber order by A.AttendanceMonth) - 1 as decimal(9,5))
/ (count(*) over(partition by E.EmployeeNumber) - 1) as CalcPercent_Rank
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

-- 14. PERCENTILE_CONT and PERCENTILE_DISC
select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
CUME_DIST()    over(partition by E.EmployeeNumber -- it shows where is the average 
               order by A.NumberAttendance) as MyCume_Dist,
PERCENT_RANK() over(partition by E.EmployeeNumber 
                order by A.NumberAttendance) * 100 as MyPercent_Rank
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

SELECT DISTINCT EmployeeNumber,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY NumberAttendance) OVER (PARTITION BY EmployeeNumber) as AverageCont, -- percentile in continuous format
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY NumberAttendance) OVER (PARTITION BY EmployeeNumber) as AverageDisc  -- percentile in descrete format. Picks one value from the list.
from tblAttendance

-- Adding Totals

select E.Department, E.EmployeeNumber, A.AttendanceMonth as AttendanceMonth, sum(A.NumberAttendance) as NumberAttendance
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
group by E.Department, E.EmployeeNumber, A.AttendanceMonth
UNION -- IF I want a totalAttendance Month
select E.Department, E.EmployeeNumber, null as AttendanceMonth, sum(A.NumberAttendance) as TotalAttendance
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
group by E.Department, E.EmployeeNumber
union -- if you want another total eg employ number
select E.Department, null, null as AttendanceMonth, sum(A.NumberAttendance) as TotalAttendance
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
group by E.Department
union
select null, null, null as AttendanceMonth, sum(A.NumberAttendance) as TotalAttendance
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
order by Department, EmployeeNumber, AttendanceMonth

--16. ROLLUP, GROUPING and GROUPING_ID
select E.Department, E.EmployeeNumber, A.AttendanceMonth as AttendanceMonth, sum(A.NumberAttendance) as NumberAttendance,
GROUPING(E.EmployeeNumber) AS EmployeeNumberGroupedBy,  -- Grouping returns 1 if that column has a total, Grouping_ID returns a value over all grouped columns
GROUPING_ID(E.Department, E.EmployeeNumber, A.AttendanceMonth) AS EmployeeNumberGroupedID -- Grouping ID makes assign values to colums like binary visible in the example
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
group by ROLLUP (E.Department, E.EmployeeNumber, A.AttendanceMonth) -- ROLLUP creates groups like above col1, col2, col3, col4  -- There is also Group by Cube to count all possible permutations(all combinations OF total)
order by Department, EmployeeNumber, AttendanceMonth                                                 -- col1, col2, col3, NULL
                                                                                                     -- col1, col2, NULL, NULL
                                                                                                     -- col1, NULL, NULL, NULL
                                                                                                     -- NULL, NULL, NULL, NULL


-- What If We have NULLs in the dataset??
-- We need to no if a null is a value or a NULL is a total

-- 17. GROUPING SETS
select E.Department, E.EmployeeNumber, A.AttendanceMonth as AttendanceMonth, sum(A.NumberAttendance) as NumberAttendance,
GROUPING(E.EmployeeNumber) AS EmployeeNumberGroupedBy,
GROUPING_ID(E.Department, E.EmployeeNumber, A.AttendanceMonth) AS EmployeeNumberGroupedID
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber                                                        -- To Calculate the grand total      
group by GROUPING SETS ((E.Department, E.EmployeeNumber, A.AttendanceMonth), (E.Department), ()) -- We can use grouping sets to replicate group and rollup
-- order by Department, EmployeeNumber, AttendanceMonth
order by coalesce(Department, 'zzzzzzz'), coalesce(E.EmployeeNumber, 99999), coalesce(AttendanceMonth,'2100-01-01') -- To send everything to the end

select E.Department, E.EmployeeNumber, A.AttendanceMonth as AttendanceMonth, sum(A.NumberAttendance) as NumberAttendance,
GROUPING(E.EmployeeNumber) AS EmployeeNumberGroupedBy,
GROUPING_ID(E.Department, E.EmployeeNumber, A.AttendanceMonth) AS EmployeeNumberGroupedID
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
group by GROUPING SETS ((E.Department, E.EmployeeNumber, A.AttendanceMonth), (E.Department), ())
order by CASE WHEN Department       IS NULL THEN 1 ELSE 0 END, Department, 
         CASE WHEN E.EmployeeNumber IS NULL THEN 1 ELSE 0 END, E.EmployeeNumber, -- Again to send everything at the end
         CASE WHEN AttendanceMonth  IS NULL THEN 1 ELSE 0 END, AttendanceMonth



--19. Geometry – Creating Point
-- Geography takes into acount the fact that the earth is round and it takes that into account when calculating the distance between two points
-- Geometry is better for more local stuff
BEGIN TRAN
CREATE TABLE tblGeom
(GXY geometry,
Description varchar(30),
IDtblGeom int CONSTRAINT PK_tblGeom PRIMARY KEY IDENTITY(1, 1) -- Identity to start by 1 and icrement by one
)

INSERT INTO tblGeom
VALUES (geometry::STGeomFromText('POINT (3 4)', 0), 'First point'), -- Create One Point From text and so on (0 is the SID value)
	   (geometry::STGeomFromText('POINT (3 5)', 0), 'Second point'),
	   (geometry::Point(4, 6, 0), 'Third Point'),
	   (geometry::STGeomFromText('MULTIPOINT ((1 2), (2 3), (3 4))', 0), 'Three Points')


Select * from tblGeom

select IDtblGeom, GXY.STGeometryType() as MyType --ST for static
, GXY.STStartPoint().ToString() as StartingPoint
, GXY.STEndPoint().ToString() as EndingPoint
, GXY.STPointN(1).ToString() as FirstPoint
, GXY.STPointN(2).ToString() as SecondPoint -- the point in the list and so on
, GXY.STPointN(1).STX as FirstPointX --STX is x coordinate
, GXY.STPointN(1).STY as FirstPointY
, GXY.STNumPoints() as NumberPoints
from tblGeom
ROLLBACK TRAN

-- We can also declare variables for geometry
DECLARE @g as geometry
DECLARE @h as geometry

select @g = GXY from tblGeom where IDtblGeom = 1
select @h = GXY from tblGeom where IDtblGeom = 3
select @g.STDistance(@h) as MyDistance



-- 21. Defining LINESTRINGs,  POLYGONs and CIRCULARSTRINGs
begin tran
create table tblGeom
(GXY geometry,
Description varchar(20),
IDtblGeom int CONSTRAINT PK_tblGeom PRIMARY KEY IDENTITY(5,1))
insert into tblGeom
VALUES (geometry::STGeomFromText('LINESTRING (1 1, 5 5)', 0),'First line'), -- Keep the SRID the same
       (geometry::STGeomFromText('LINESTRING (5 1, 1 4, 2 5, 5 1)', 0),'Second line'),
	   (geometry::STGeomFromText('MULTILINESTRING ((1 5, 2 6), (1 4, 2 5))', 0),'Third line'), -- Multi things always two open brackets
	   (geometry::STGeomFromText('POLYGON ((4 1, 6 3, 8 3, 6 1, 4 1))', 0), 'Polygon'),
	   (geometry::STGeomFromText('CIRCULARSTRING (1 0, 0 1, -1 0, 0 -1, 1 0)', 0), 'Circle')
SELECT * FROM tblGeom

-- Querring Lines
select IDtblGeom, GXY.STGeometryType() as MyType
, GXY.STStartPoint().ToString() as StartingPoint
, GXY.STEndPoint().ToString() as EndingPoint
, GXY.STPointN(1).ToString() as FirstPoint
, GXY.STPointN(2).ToString() as SecondPoint
, GXY.STPointN(1).STX as FirstPointX
, GXY.STPointN(1).STY as FirstPointY
, GXY.STBoundary().ToString() as Boundary
, GXY.STLength() as MyLength
, GXY.STNumPoints() as NumberPoints
from tblGeom

DECLARE @g2 as geometry
select @g2 = GXY from tblGeom where IDtblGeom = 5

select IDtblGeom, GXY.STIntersection(@g2).ToString() as Intersection
, GXY.STDistance(@g2) as DistanceFromFirstLine
from tblGeom

select GXY.STUnion(@g2), Description
from tblGeom
where IDtblGeom = 8 

rollback tran


-- 23. Geography
begin tran
create table tblGeog
(GXY geography,
Description varchar(30),
IDtblGeog int CONSTRAINT PK_tblGeog PRIMARY KEY IDENTITY(1,1))
insert into tblGeog
VALUES (geography::STGeomFromText('POINT (-73.993492 40.750525)', 4326),'Madison Square Gardens, NY'),
       (geography::STGeomFromText('POINT (-0.177452 51.500905)', 4326),'Royal Albert Hall, London'), -- We should use 4326 as SRID unless we have a good reason not too
	   (geography::STGeomFromText('LINESTRING (-73.993492 40.750525, -0.177452 51.500905)', 4326),'Connection') -- SRID: Special Reference Identifier

select * from tblGeog


DECLARE @g3 as geography
select @g3 = GXY from tblGeog where IDtblGeog = 1

select IDtblGeog, GXY.STGeometryType() as MyType
, GXY.STStartPoint().ToString() as StartingPoint
, GXY.STEndPoint().ToString() as EndingPoint
, GXY.STPointN(1).ToString() as FirstPoint
, GXY.STPointN(2).ToString() as SecondPoint
, GXY.STLength() as MyLength
, GXY.STIntersection(@g3).ToString() as Intersection
, GXY.STNumPoints() as NumberPoints
, GXY.STDistance(@g3) as DistanceFromFirstLine
from tblGeog

DECLARE @h2 as geography

select @g3 = GXY from tblGeog where IDtblGeog = 1
select @h2 = GXY from tblGeog where IDtblGeog = 2
select @g3.STDistance(@h2) as MyDistance

select GXY.STUnion(@g3)
from tblGeog
where IDtblGeog = 2 

ROLLBACK TRAN

select * from sys.spatial_reference_systems

DROP TABLE tblGeom


-- 24. Spatial aggregates
begin tran
create table tblGeom
(GXY geometry,
Description varchar(20),
IDtblGeom int CONSTRAINT PK_tblGeom PRIMARY KEY IDENTITY(5,1))
insert into tblGeom
VALUES (geometry::STGeomFromText('LINESTRING (1 1, 5 5)', 0),'First line'),
	   (geometry::STGeomFromText('LINESTRING (5 1, 1 4, 2 5, 5 1)', 0),'Second line'),
	   (geometry::STGeomFromText('MULTILINESTRING ((1 5, 2 6), (1 4, 2 5))', 0),'Third line'),
	   (geometry::STGeomFromText('POLYGON ((4 1, 6 3, 8 3, 6 1, 4 1))', 0), 'Polygon'),
	   (geometry::STGeomFromText('POLYGON ((5 2, 7 2, 7 4, 5 4, 5 2))', 0), 'Second Polygon'),
	   (geometry::STGeomFromText('CIRCULARSTRING (1 0, 0 1, -1 0, 0 -1, 1 0)', 0), 'Circle')
select * from tblGeom

SELECT *  FROM tblGeom
where GXY.Filter(geometry::Parse('POLYGON((2 1, 1 4, 4 4, 4 1, 2 1))')) = 1
UNION ALL
SELECT geometry::STGeomFromText('POLYGON((2 1, 1 4, 4 4, 4 1, 2 1))', 0), 'Filter', 0

declare @i as geometry
select @i = geometry::UnionAggregate(GXY) 
from tblGeom

Select @i as CombinedShapes

declare @j as geometry
select @j = geometry::CollectionAggregate(GXY) 
from tblGeom

select @j

Select @i as CombinedShapes
--union all
select geometry::EnvelopeAggregate(GXY) as Envelope from tblGeom
--union all
select geometry::ConvexHullAggregate(GXY) as Envelope from tblGeom

ROLLBACK TRAN
