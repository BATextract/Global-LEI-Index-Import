    CREATE DATABASE lei_1
    GO

    USE lei_1
    GO

    CREATE TABLE lei_1_table
    (
        Id INT IDENTITY PRIMARY KEY,
        XMLData XML,
        LoadedDateTime DATETIME
    )

    CREATE TABLE recordsx
    ( 
        LegalName VARCHAR(100),
        la_Line1 [varchar](100),
        la_Line2 [varchar](100),
        la_City [varchar](100),
        la_Region [varchar](100),
        la_Country [varchar](100),
        la_PostalCode [varchar](100)
    );

    INSERT INTO lei_1_table(XMLData, LoadedDateTime)
    SELECT CONVERT(XML, BulkColumn) AS BulkColumn, GETDATE() 
    FROM OPENROWSET(BULK 'C:\lei_example2.xml', SINGLE_BLOB) AS x;

    SELECT * FROM lei_1_table

    DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)


    SELECT @XML = XMLData FROM lei_1_table
	
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML, '<lei:LEIData xmlns:lei="http://www.leiroc.org/data/schema/leidata/2014" />'

SELECT LegalName, la_Line1, la_Line2, la_City, la_Region, la_Country, la_PostalCode                      
FROM OPENXML(@hDoc, 'lei:LEIData/lei:LEIRecords/lei:LEIRecord')
WITH                          --^ here
(
    LegalName [varchar](100) 'lei:Entity/lei:LegalName',
    la_Line1 [varchar](100) 'lei:Entity/lei:LegalAddress/lei:Line1',
    la_Line2 [varchar](100) 'lei:Entity/lei:LegalAddress/lei:Line2',
    la_City [varchar](100) 'lei:Entity/lei:LegalAddress/lei:City',
    la_Region [varchar](100) 'lei:Entity/lei:LegalAddress/lei:Region',
    la_Country [varchar](100) 'lei:Entity/lei:LegalAddress/lei:Country',
    la_PostalCode [varchar](100) 'lei:Entity/lei:LegalAddress/lei:PostalCode'
)

insert into recordsx(LegalName, la_Line1, la_Line2, la_City, la_Region, la_Country, la_PostalCode)
SELECT LegalName, la_Line1, la_Line2, la_City, la_Region, la_Country, la_PostalCode 
FROM OPENXML(@hDoc, 'lei:LEIData/lei:LEIRecords/lei:LEIRecord/lei:Entity')
WITH                          --^ here
(
    LegalName [varchar](100) 'lei:LegalName',
    la_Line1 [varchar](100) 'lei:LegalAddress/lei:Line1',
    la_Line2 [varchar](100) 'lei:LegalAddress/lei:Line2',
    la_City [varchar](100) 'lei:LegalAddress/lei:City',
    la_Region [varchar](100) 'lei:LegalAddress/lei:Region',
    la_Country [varchar](100) 'lei:LegalAddress/lei:Country',
    la_PostalCode [varchar](100) 'lei:LegalAddress/lei:PostalCode'
)

SELECT * FROM recordsx


EXEC sp_xml_removedocument @hDoc