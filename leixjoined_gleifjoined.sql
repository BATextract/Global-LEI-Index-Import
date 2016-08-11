USE lei_1
GO

CREATE TABLE gleif_1_table
(
Id INT IDENTITY PRIMARY KEY,
XMLData XML,
)

CREATE TABLE header
( 
Id INT IDENTITY PRIMARY KEY,
LOULEI VARCHAR(50),
LOUName VARCHAR(100),
ROCSponsorCountry [varchar](10),
RecordCount[varchar](10),
ContentDate [varchar](30),
LastAttemptedDownloadDate [varchar](30),
LastSuccessfulDownloadDate [varchar](30),
LastValidDownloadDate [varchar](30)
);

INSERT INTO gleif_1_table(XMLData)
SELECT CONVERT(XML, BulkColumn) AS BulkColumn
FROM OPENROWSET(BULK 'C:\gleif_example.xml', SINGLE_BLOB) AS x;

DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)


SELECT @XML = XMLData FROM gleif_1_table


EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML, '<lei:LEIData xmlns:lei="http://www.leiroc.org/data/schema/leidata/2014" xmlns:gleif="http://www.gleif.org/concatenated-file/header-extension/1" />'
	
	
insert into header(LOULEI, LOUName, ROCSponsorCountry, RecordCount, ContentDate, LastAttemptedDownloadDate, LastSuccessfulDownloadDate, LastValidDownloadDate)
SELECT LOULEI, LOUName, ROCSponsorCountry, RecordCount, ContentDate, LastAttemptedDownloadDate, LastSuccessfulDownloadDate, LastValidDownloadDate 
FROM OPENXML(@hDoc, 'lei:LEIData/lei:LEIHeader/lei:Extension/gleif:LOUSources/gleif:LOUSource')
WITH 
(
LOULEI VARCHAR(50) 'gleif:LOULEI',
LOUName VARCHAR(100) 'gleif:LOUName',
ROCSponsorCountry [varchar](10) 'gleif:ROCSponsorCountry',
RecordCount[varchar](10) 'gleif:RecordCount',
ContentDate [varchar](30) 'gleif:ContentDate',
LastAttemptedDownloadDate [varchar](30) 'gleif:LastAttemptedDownloadDate',
LastSuccessfulDownloadDate [varchar](30) 'gleif:LastSuccessfulDownloadDate',
LastValidDownloadDate [varchar](30) 'gleif:LastValidDownloadDate'
)

SELECT * FROM header


EXEC sp_xml_removedocument @hDoc
GO