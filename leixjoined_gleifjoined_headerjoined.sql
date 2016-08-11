USE lei_1
GO

CREATE TABLE header_1_table
(
Id INT IDENTITY PRIMARY KEY,
XMLData XML,
)

CREATE TABLE header_meta
( 
Id INT IDENTITY PRIMARY KEY,
ContentDate VARCHAR(30),
FileContent VARCHAR(70),
RecordCount [varchar](20)
);

INSERT INTO lei_1_table(XMLData)
SELECT CONVERT(XML, BulkColumn) AS BulkColumn
FROM OPENROWSET(BULK 'C:\gleif_example_head.xml', SINGLE_BLOB) AS x;


DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)


SELECT @XML = XMLData FROM header_1_table


EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML, '<lei:LEIData xmlns:lei="http://www.leiroc.org/data/schema/leidata/2014" xmlns:gleif="http://www.gleif.org/concatenated-file/header-extension/1" />'
	  
insert into header_meta(ContentDate, FileContent, RecordCount)
SELECT ContentDate, FileContent, RecordCount
FROM OPENXML(@hDoc, 'lei:LEIData/lei:LEIHeader')
WITH 
(
ContentDate VARCHAR(30)'lei:ContentDate',
FileContent VARCHAR(70)'lei:FileContent',
RecordCount [varchar](20)'lei:RecordCount'
)

SELECT * FROM header_meta


EXEC sp_xml_removedocument @hDoc
GO