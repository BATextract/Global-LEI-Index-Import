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
Id INT IDENTITY PRIMARY KEY,
LEI VARCHAR(50)
);

CREATE TABLE legal_name_x
( 
Id INT IDENTITY PRIMARY KEY,
LegalName VARCHAR(100)
);

CREATE TABLE address_x
( 
Id INT IDENTITY PRIMARY KEY,
Line1 [varchar](100),
Line2 [varchar](100),
City [varchar](100),
Region [varchar](100),
Country [varchar](100),
PostalCode [varchar](100)
);


INSERT INTO lei_1_table(XMLData)
SELECT CONVERT(XML, BulkColumn) AS BulkColumn
FROM OPENROWSET(BULK 'C:\lei_example2.xml', SINGLE_BLOB) AS x;


SELECT * FROM lei_1_table

DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)


SELECT @XML = XMLData FROM lei_1_table


EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML, '<lei:LEIData xmlns:lei="http://www.leiroc.org/data/schema/leidata/2014" xmlns:gleif="http://www.gleif.org/concatenated-file/header-extension/1" />'

insert into lei_x(LEI)
SELECT LEI
FROM OPENXML(@hDoc, 'lei:LEIData')
WITH 
(
LEI [varchar](100) 'lei:LEIRecords/lei:LEIRecord/lei:LEI'
)

SELECT * FROM lei_x

insert into legal_name_x(LegalName)
SELECT LegalName
FROM OPENXML(@hDoc, 'lei:LEIData')
WITH 
(
LegalName [varchar](100) 'lei:LEIRecords/lei:LEIRecord/lei:Entity/lei:LegalName'
)

SELECT * FROM legal_name_x


insert into address_x(Line1, Line2, City, Region, Country, PostalCode)
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

SELECT * FROM address_x


EXEC sp_xml_removedocument @hDoc
GO

