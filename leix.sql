CREATE DATABASE lei_1
GO


USE lei_1
GO


CREATE TABLE lei_1_table
(
Id INT IDENTITY PRIMARY KEY,
XMLData XML,
)

CREATE TABLE lei_x
( 
 LEI VARCHAR(50)
);


INSERT INTO lei_1_table(XMLData)
SELECT CONVERT(XML, BulkColumn) AS BulkColumn
FROM OPENROWSET(BULK 'C:\lei_example2.xml', SINGLE_BLOB) AS x;


SELECT * FROM lei_1_table

DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)


SELECT @XML = XMLData FROM lei_1_table


EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML, '<lei:LEIData xmlns:lei="http://www.leiroc.org/data/schema/leidata/2014" xmlns:gleif="http://www.gleif.org/concatenated-file/header-extension/1" />'

SELECT LEI
FROM OPENXML(@hDoc, 'lei:LEIData')
WITH 
(
LEI [varchar](100) 'lei:LEIRecords/lei:LEIRecord/lei:LEI'
)

SELECT LegalName
FROM OPENXML(@hDoc, 'lei:LEIData')
WITH 
(
LegalName [varchar](100) 'lei:LEIRecords/lei:LEIRecord/lei:Entity/lei:LegalName'
)

SELECT Line1, Line2, City, Region, Country, PostalCode
FROM OPENXML(@hDoc, 'lei:LEIData')
WITH 
(
Line1 [varchar](100) 'lei:LEIRecords/lei:LEIRecord/lei:Entity/lei:LegalAddress/lei:Line1',
Line2 [varchar](100) 'lei:LEIRecords/lei:LEIRecord/lei:Entity/lei:LegalAddress/lei:Line2',
City [varchar](100) 'lei:LEIRecords/lei:LEIRecord/lei:Entity/lei:LegalAddress/lei:City',
Region [varchar](100) 'lei:LEIRecords/lei:LEIRecord/lei:Entity/lei:LegalAddress/lei:Region',
Country [varchar](100) 'lei:LEIRecords/lei:LEIRecord/lei:Entity/lei:LegalAddress/lei:Country',
PostalCode [varchar](100) 'lei:LEIRecords/lei:LEIRecord/lei:Entity/lei:LegalAddress/lei:PostalCode'
)

insert into lei_x(LEI)
select LEI FROM OPENXML(@hDoc, 'lei:LEIRecords/lei:LEIRecord/lei:LEI')
with (LEI varchar(100))

SELECT * FROM lei_x


EXEC sp_xml_removedocument @hDoc
GO

