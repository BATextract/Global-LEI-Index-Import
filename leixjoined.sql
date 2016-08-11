CREATE DATABASE lei_1
GO

USE lei_1
GO

CREATE TABLE lei_1_table
(
Id INT IDENTITY PRIMARY KEY,
XMLData XML,
)

CREATE TABLE records
( 
Id INT IDENTITY PRIMARY KEY,
LEI VARCHAR(50),
LegalName VARCHAR(100),
la_Line1 [varchar](100),
la_City [varchar](50),
la_Country [varchar](50),
la_PostalCode [varchar](10),
oa_Line1 [varchar](100),
oa_City [varchar](50),
oa_Country [varchar](50),
oa_PostalCode [varchar](10),
BusinessRegisterEntityID [varchar](16),
LegalJurisdiction [varchar](6),
LegalForm [varchar](50),
EntityStatus [varchar](10),
InitialRegistrationDate [varchar](30),
LastUpdateDate [varchar](30),
RegistrationStatus [varchar](30),
NextRenewalDate [varchar](30),
ManagingLOU[varchar](30),
ValidationSources [varchar](30)
);

INSERT INTO lei_1_table(XMLData)
SELECT CONVERT(XML, BulkColumn) AS BulkColumn
FROM OPENROWSET(BULK 'C:\lei_example.xml', SINGLE_BLOB) AS x;


SELECT * FROM lei_1_table

DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)


SELECT @XML = XMLData FROM lei_1_table


EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML, '<lei:LEIData xmlns:lei="http://www.leiroc.org/data/schema/leidata/2014" xmlns:gleif="http://www.gleif.org/concatenated-file/header-extension/1" />'

insert into records(LEI, LegalName, la_Line1, la_City, la_Country, la_PostalCode, oa_Line1, oa_City, oa_Country, oa_PostalCode,  BusinessRegisterEntityID, LegalJurisdiction, LegalForm, EntityStatus, InitialRegistrationDate, LastUpdateDate, RegistrationStatus, NextRenewalDate, ManagingLOU, ValidationSources)
SELECT LEI, LegalName, la_Line1, la_City, la_Country, la_PostalCode, oa_Line1, oa_City, oa_Country, oa_PostalCode,  BusinessRegisterEntityID, LegalJurisdiction, LegalForm, EntityStatus, InitialRegistrationDate, LastUpdateDate, RegistrationStatus, NextRenewalDate, ManagingLOU, ValidationSources
FROM OPENXML(@hDoc, 'lei:LEIData/lei:LEIRecords/lei:LEIRecord')
WITH 
(
LEI [varchar](50) 'lei:LEI',
LegalName [varchar](100) 'lei:Entity/lei:LegalName',
la_Line1 [varchar](100) 'lei:Entity/lei:LegalAddress/lei:Line1',
la_City [varchar](50) 'lei:Entity/lei:LegalAddress/lei:City',
la_Country [varchar](50) 'lei:Entity/lei:LegalAddress/lei:Country',
la_PostalCode [varchar](10) 'lei:Entity/lei:LegalAddress/lei:PostalCode',
oa_Line1 [varchar](100) 'lei:Entity/lei:HeadquartersAddress/lei:Line1',
oa_City [varchar](50) 'lei:Entity/lei:HeadquartersAddress/lei:City',
oa_Country [varchar](50) 'lei:Entity/lei:HeadquartersAddress/lei:Country',
oa_PostalCode [varchar](10) 'lei:Entity/lei:HeadquartersAddress/lei:PostalCode',
BusinessRegisterEntityID [varchar](16) 'lei:Entity/lei:BusinessRegisterEntityID',
LegalJurisdiction [varchar](6) 'lei:Entity/lei:LegalJurisdiction',
LegalForm [varchar](50) 'lei:Entity/lei:LegalForm',
EntityStatus [varchar](10) 'lei:Entity/lei:EntityStatus',
InitialRegistrationDate [varchar](30) 'lei:Registration/lei:InitialRegistrationDate',
LastUpdateDate [varchar](30) 'lei:Registration/lei:LastUpdateDate',
RegistrationStatus [varchar](30) 'lei:Registration/lei:RegistrationStatus',
NextRenewalDate [varchar](30) 'lei:Registration/lei:NextRenewalDate',
ManagingLOU[varchar](30) 'lei:Registration/lei:ManagingLOU',
ValidationSources [varchar](30) 'lei:Registration/lei:ValidationSources'
)

SELECT * FROM records


EXEC sp_xml_removedocument @hDoc
GO