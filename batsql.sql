CREATE DATABASE BatExtract1
GO

USE BatExtract1
GO

CREATE TABLE BatExtract1_Table1
(
Id INT IDENTITY PRIMARY KEY,
XMLData XML,
LoadedDateTime DATETIME
)

CREATE TABLE BatExtract1_Table1X
( 
 ClientName VARCHAR(50),
 TotalDebt VARCHAR(50)
);

INSERT INTO BatExtract1_Table1(XMLData, LoadedDateTime)
SELECT CONVERT(XML, BulkColumn) AS BulkColumn, GETDATE() 
FROM OPENROWSET(BULK 'C:\batExtract1.xml', SINGLE_BLOB) AS x;

SELECT * FROM BatExtract1_Table1


USE BatExtract1
GO



DECLARE @XMLt AS XML, @hDotc AS INT, @SQL NVARCHAR (MAX) /* declare variables for later */


SELECT @XMLt = XMLData FROM BatExtract1_Table1 /* xml is placed in variable */

EXEC sp_xml_preparedocument @hDotc OUTPUT, @XMLt /* xml variable parsed, place in hdoc variable and output */

SELECT ClientName,TotalDebt
FROM OPENXML(@hDotc, 'BATEXTRACT') /* openxml opens the xml */
WITH 
(
ClientName [varchar](100) 'Clients/Client/ClientName',
TotalDebt [varchar](100) 'Clients/Client/TotalDebt' /* name of field in xml*/
)

insert into BatExtract1_Table1X(ClientName,TotalDebt)
select ClientName,TotalDebt FROM OPENXML(@hDotc, 'BATEXTRACT')
with (
ClientName varchar(100)'Clients/Client/ClientName',
TotalDebt varchar(100)'Clients/Client/TotalDebt'
)

SELECT * FROM BatExtract1_Table1X

EXEC sp_xml_removedocument @hDotc /* remove temp hdoc variable */
GO
