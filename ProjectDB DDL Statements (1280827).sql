  
 --PROJECT DB

 ---Creating Database on SQL
USE master 
GO
DROP DATABASE IF EXISTS ProjectDB

GO
CREATE DATABASE ProjectDB
ON (
	Name= 'ProjectDB_Data_1',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ProjectDB_Data_1.mdf',
	Size= 25MB,
	MaxSize= 100MB,
	FileGrowth= 5%
)
LOG ON (
	Name= 'ProjectDB_Log_1',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ProjectDB_Log_1.ldf',
	Size= 2MB,
	MaxSize= 25MB,
	FileGrowth= 1%
)
GO
-- Creating Tables associate with Database with script
use ProjectDB
go
CREATE TABLE Project_T
(	
	ProjectCode varchar(10) NOT NULL PRIMARY KEY NONCLUSTERED,
	ProjectTittle varchar(20) NOT NULL,
	Budget money NOT NULL
)
CREATE TABLE Department_T
(	
	DepartmentCode varchar(10) NOT NULL PRIMARY KEY ,
	DepartmentName varchar(20) NOT NULL
)
GO

CREATE TABLE Emplopyee_T
(	
	EmployeeCode varchar(10) NOT NULL PRIMARY KEY ,
	EmployeeFName varchar(20) NOT NULL,
	EmployeeLName varchar(20) NOT NULL,
	DepartmentCode varchar(10) NOT NULL REFERENCES Department_T(DepartmentCode)
)
GO

CREATE TABLE Associate_T
(	
	ProjectCode varchar(10) NOT NULL REFERENCES Project_T(ProjectCode) ON DELETE CASCADE,
	EmployeeCode varchar(10) NOT NULL REFERENCES Emplopyee_T(EmployeeCode),
	HourlyRate money NOT NULL
	PRIMARY KEY(ProjectCode,EmployeeCode,HourlyRate)
)
---A script to create new table
go
CREATE TABLE PROJECTS

(
PROJECTID INT PRIMARY KEY NOT NULL,
PROJECTNAME VARCHAR(30) NOT NULL

)
-- A script to create delete table
go
DROP TABLE PROJECTS
GO
---A script to create a view to show all the information in a meaningfull order

create view ProjectBudgetView
WITH ENCRYPTION 
as 
select a.ProjectCode,p.ProjectTittle, p.Budget  from Associate_T a join Project_T p
on a.ProjectCode=p.ProjectCode

--A script to Create Store procedure to insert , update, delete data for a table(10)

CREATE PROCEDURE spInsertUpdateDeleteAndOutputParameter
	@Functionality varchar(20) = '',
	@DeptCode varchar(20),
	@DeptName varchar(20),
	@DeptCount Int Output
AS
BEGIN 
	IF @Functionality='SELECT'
		BEGIN
			SELECT * FROM Department_T
		END

	IF @Functionality='INSERT'
		BEGIN TRY
			INSERT INTO Department_T VALUES (@DeptCode, @DeptName)
		END TRY
		BEGIN CATCH 
			SELECT ERROR_MESSAGE() AS ErrorMessage,
				ERROR_LINE() AS ErrorLine,
				ERROR_SEVERITY() AS ErrorSeverity
		END CATCH

	IF @Functionality='UPDATE'
		BEGIN TRY
			UPDATE Department_T SET DepartmentName=@DeptName
				WHERE @DeptCode=DepartmentCode
		END TRY
		BEGIN CATCH 
			SELECT ERROR_MESSAGE() AS ErrorMessage,
				ERROR_LINE() AS ErrorLine,
				ERROR_SEVERITY() AS ErrorSeverity
		END CATCH

	IF @Functionality='DELETE'
		BEGIN 
			DELETE FROM Department_T WHERE @DeptCode=DepartmentCode
		END 
	IF @Functionality='COUNT'
	BEGIN

	SELECT DepartmentName, COUNT(EmployeeCode) FROM Emplopyee_T
	JOIN Department_T ON Department_T.DepartmentCode=Emplopyee_T.DepartmentCode
	GROUP BY DepartmentName
	END
END;
GO
--A script for Creating clustered index 

CREATE alter CLUSTERED INDEX IX_ProjectTittle
ON Project_T (ProjectTittle);
go
--A script for Creating non clustered  index 

CREATE NONCLUSTERED INDEX IX_Employee
ON Emplopyee_T (EmployeeFName,EmployeeLName);
go


--A script for  Creating a CTE(17)
WITH TotalEmployee AS
(SELECT  DepartmentCode, Count(Emplopyee_T.EmployeeCode) AS TotalEmployee
		FROM Emplopyee_T
GROUP BY  DepartmentCode),

DeptNameCTE AS
(SELECT DepartmentCode, DepartmentName FROM Department_T)

SELECT DepartmentName, TotalEmployee FROM TotalEmployee JOIN DeptNameCTE 
	ON TotalEmployee.DepartmentCode = DeptNameCTE.DepartmentCode
GO

--A script to Create a CURSOR to insert data into a table(19)


DECLARE @ProjectCode Varchar(22), @ProjectTittle varchar(20),@BudgetVar Int, @ShowCount INT ;
SET @ShowCount=0;

DECLARE ProjectDB_Cursor Cursor
FOR
	SELECT * FROM Project_T

OPEN ProjectDB_Cursor
	FETCH NEXT FROM ProjectDB_Cursor INTO @ProjectCode , @ProjectTittle,@BudgetVar ;

	WHILE @@FETCH_STATUS<> -1
		BEGIN
			IF @BudgetVar>600000
				BEGIN 
					PRINT @ProjectTittle
					SET @ShowCount=@ShowCount+1
				END
			FETCH NEXT FROM ProjectDB_Cursor INTO @ProjectCode , @ProjectTittle,@BudgetVar
		END
CLOSE ProjectDB_Cursor
DEALLOCATE ProjectDB_Cursor

PRINT ''
PRINT CONVERT (varchar, @ShowCount )+ ' Row(s) are shown'
GO

--A script to create two table to merge data from these tables into another table(21)
CREATE TABLE Candiate
(ID INT PRIMARY KEY,
NAME VARCHAR(20))
INSERT INTO Candiate
values
(1, 'aa'), (2, 'bb'),(3, ' cc')
GO

CREATE TABLE PERSON
(AGE INT PRIMARY KEY,
NAME VARCHAR(20))
INSERT INTO PERSON
values
(20, 'aa'), (25, 'bb'),(76, 'cc')

CREATE TABLE Student
(ID INT,
NAME VARCHAR(20),
AGE INT)
GO


MERGE INTO Student as t
using
(SELECT AGE ,PERSON.Name AS pername, ID, Candiate.Name As cname  
FROM PERSON JOIN Candiate
ON PERSON.NAME=Candiate.NAME) AS S

ON t.id=S.id

WHEN MATCHED THEN
UPDATE SET

T.ID=S.id,
T.name=s.cname,
t.age=S.age

WHEN NOT MATCHED THEN
INSERT  (ID ,NAME, AGE)
VALUES (s.id, S.cname,s.age );


--------------------------------------------------

CREATE TABLE [dbo].[Associate_TArchieve](
	[ProjectCode] [varchar](10) NOT NULL,
	[EmployeeCode] [varchar](10) NOT NULL,
	[HourlyRate] [money] NOT NULL)

	--ctrate trigger 
CREATE TRIGGER tgdel
ON Associate_T
AFTER DELETE 
AS 
INSERT INTO Associate_TArchieve
SELECT * FROM deleted

--trigger to show data 

CREATE TRIGGER TgShowInsert 
on Department_T
AFTER insert 
as 
select * from inserted

--table function
create function fnbudget(@budget money)
returns table
as
return
SELECT ProjectTittle, Budget FROM Associate_T A JOIN Project_T P
ON A.ProjectCode=P.ProjectCode
WHERE Budget > @budget;

--scalar function
CREATE or alter function fnprojrct(@project varchar(10))
returns money
as
begin
declare @amt money
SELECT @amt= SUM(HourlyRate) FROM Associate_T
WHERE ProjectCode=@project
return @amt
end




