--DML COMMAND
USE ProjectDB
GO
INSERT INTO Project_T
VALUES 
	('PC01', 'Pensions System', 800000),
	('PC04', 'Salary System', 900000),
	('PC06', 'HR System', 600000)
GO
INSERT INTO Department_T
VALUES 
	('L004', 'IT'),
	('L023', 'HR'),
	('L008', 'Pay Roll'),
	('L009', 'Sales');
GO
INSERT INTO Emplopyee_T
VALUES 
	('S1000', 'Allen', 'Smith', 'L004'),
	('S1003', 'Lewis', 'Jones', 'L023'),
	('S2101', 'Prince', 'Lewis', 'L004'),
	('S1001', 'Barbara', 'Jones', 'L004'),
	('S3100', 'Tony', 'Gilbert', 'L023'),
	('S1321', 'Frank', 'Richo', 'L008'),
	('S1004', 'Robert', 'John', 'L009');
GO
INSERT INTO Associate_T
VALUES 
	('PC01', 'S1000', 220.00),
	('PC01', 'S1003', 180.50),
	('PC01', 'S2101', 210.00),
	('PC04', 'S1001', 210.00),
	('PC04', 'S1000', 180.00),
	('PC04', 'S3100', 25.00),
	('PC04', 'S1321', 170.00),
	('PC06', 'S3100', 230.00),
	('PC06', 'S2101', 170.00),
	('PC06', 'S1004', 160.00);
GO
--A Query For delete Column

DELETE FROM Associate_T
WHERE ProjectCode = 'PC01';
GO

-- An Update Query

UPDATE Associate_T
	SET HourlyRate=30.00
	WHERE ProjectCode='PC04'  AND DepartmentCode='L023';
GO
--- A query to retrieve top 3 employee
SELECT TOP 3 EmployeeCode, EmployeeFName,EmployeeLName,DepartmentCode 
FROM Emplopyee_T
ORDER BY EmployeeCode DESC;

--- A query to retrieve projects which budget is more than 800000

SELECT ProjectTittle, Budget FROM Associate_T A JOIN Project_T P
ON A.ProjectCode=P.ProjectCode
WHERE Budget > 800000;


--- Example of in/not in
select E.EmployeeCode, (e.EmployeeFName+' '+e.EmployeeLName) AS EmployeeName ,d.DepartmentName
from Emplopyee_T e join Department_T d
on e.DepartmentCode=d.DepartmentCode
where d.DepartmentName in ('IT','HR')

select E.EmployeeCode, (e.EmployeeFName+' '+e.EmployeeLName) AS EmployeeName ,d.DepartmentName
from Emplopyee_T e join Department_T d
on e.DepartmentCode=d.DepartmentCode
where d.DepartmentName not in ('IT','HR')

---example of between
select ProjectTittle, Budget from  Project_T
where Budget between 600000 and 900000

--- Example of %
select ProjectTittle, Budget from Project_T
where ProjectTittle like 'HR%'
GO
select 
* from Emplopyee_T
where EmployeeFName like 'B[A-J]%'
GO
select 
* from Emplopyee_T
where EmployeeFName like 'L[^X-Z]%'

---A query to retrieve those employee whose FName in (a, e, i, o, u)
select ProjectCode, EmployeeFName,EmployeeLName from Associate_T A JOIN  Emplopyee_T E
ON A.EmployeeCode=E.EmployeeCode
WHERE EmployeeFName LIKE '[aeiou]%';
go

--A join query to retrieve all info using group by / having
SELECT  DepartmentName, Count(Emplopyee_T.EmployeeCode) AS TotalEmployee, SUM(Budget) AS TotalBudget
	FROM Associate_T
	JOIN Project_T ON Associate_T.ProjectCode=Project_T.ProjectCode
	JOIN Emplopyee_T ON Emplopyee_T.EmployeeCode=Associate_T.EmployeeCode
	JOIN Department_T ON Department_T.DepartmentCode=Emplopyee_T.DepartmentCode
GROUP BY  DepartmentName
HAVING SUM(Budget)>800000;

--- EXAMPLE OF CUBE
SELECT Budget, DepartmentName, Count(Emplopyee_T.EmployeeCode) AS TotalEmployee
	FROM Associate_T
	JOIN Project_T ON Associate_T.ProjectCode=Project_T.ProjectCode
	JOIN Emplopyee_T ON Emplopyee_T.EmployeeCode=Associate_T.EmployeeCode
	JOIN Department_T ON Department_T.DepartmentCode=Emplopyee_T.DepartmentCode
GROUP BY CUBE (Budget, DepartmentName)

---EXAMPLE OF ROLLUP
SELECT Budget, DepartmentName, Count(Emplopyee_T.EmployeeCode) AS TotalEmployee
	FROM Associate_T
	JOIN Project_T ON Associate_T.ProjectCode=Project_T.ProjectCode
	JOIN Emplopyee_T ON Emplopyee_T.EmployeeCode=Associate_T.EmployeeCode
	JOIN Department_T ON Department_T.DepartmentCode=Emplopyee_T.DepartmentCode
GROUP BY ROLLUP (Budget, DepartmentName)

---EXAMPLE OF GROUPING SETS

SELECT Budget, DepartmentName, Count(Emplopyee_T.EmployeeCode) AS TotalEmployee
	FROM Associate_T
	JOIN Project_T ON Associate_T.ProjectCode=Project_T.ProjectCode
	JOIN Emplopyee_T ON Emplopyee_T.EmployeeCode=Associate_T.EmployeeCode
	JOIN Department_T ON Department_T.DepartmentCode=Emplopyee_T.DepartmentCode
GROUP BY GROUPING SETS (Budget, DepartmentName)



-- SUB QUERY to show all information of Project HR SYSTEM
GO
SELECT  Project_T.ProjectCode, ProjectTittle, Emplopyee_T.EmployeeCode, EmployeeFName, Budget, DepartmentName, HourlyRate
	FROM Associate_T
		JOIN Project_T ON Associate_T.ProjectCode=Project_T.ProjectCode
		JOIN Emplopyee_T ON Emplopyee_T.EmployeeCode=Associate_T.EmployeeCode
		JOIN Department_T ON Department_T.DepartmentCode=Emplopyee_T.DepartmentCode
	WHERE  Project_T.ProjectCode IN
		(SELECT ProjectCode FROM Project_T WHERE ProjectTittle='HR SYSTEM');

--- example of exists
select EmployeeFName,EmployeeLName from Emplopyee_T
where exists
(select * from Project_T)
GO

--justify view
select * from ProjectBudgetView

EXEC sp_helptext ProjectBudgetView


--JUSTIFY STORE PROCEDURE
EXEC spInsertUpdateDeleteAndOutputParameter 'SELECT','','','';
EXEC spInsertUpdateDeleteAndOutputParameter 'Insert','L100','Marketing','';
EXEC spInsertUpdateDeleteAndOutputParameter 'Update','L100','MKT','';
EXEC spInsertUpdateDeleteAndOutputParameter 'Delete','L100','','';
GO


--Showing process of  ERROR HANDLING


BEGIN TRY 
	INSERT INTO Department_T
	VALUES 
		('L004', 'IT'),
		('L023', 'HR'),
		('L008', 'Pay Roll'),
		('L009', 'Sales')
	PRINT 'Query Execueed Successfully'
END TRY

BEGIN CATCH 
	SELECT ERROR_MESSAGE() AS ErrorMessage,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_LINE() AS ErrorLine,
			ERROR_NUMBER() AS ErrorNumber
END CATCH;
GO 

--Creating simple case and a search case
select ProjectTittle,Budget,
case
when Budget >800000 then 'Budget is more than 800000'
when Budget =800000 then 'Budget is 800000'
else 'Budget is less than 800000'
end as BudgetDetails
from Project_T;

go
select ProjectCode, ProjectTittle,Budget,
case
when Budget >800000 then 'Budget is more than 800000'
when Budget =800000 then 'Budget is 800000'
when  Budget =600000 then 'Budget is 600000'
else 'Budget is invalid'
end as BudgetDetails
from Project_T;

----------
DELETE FROM Associate_T WHERE EmployeeCode= 'pc04'
-------------
INSERT INTO Department_T values ('123','it')
----------------------
SELECT * FROM fnbudget(8000)
---------------------------------
SELECT dbo.fnprojrct('pc01')






