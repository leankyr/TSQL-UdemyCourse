INSERT INTO dbo.tb1Second VALUES (234);

SELECT myNumbers FROM dbo.tb1Second; -- you need hard brackets like [dbo].[tb1Second] if we have non standard characters in the name like space or sth


SELECT * FROM tb1Second; 

SELECT myNumbers AS myNs, myFloats AS myFs FROM tb1Second;