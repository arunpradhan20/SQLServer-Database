--Create table and Insert data using createtables.sql files     
--Examine the Tables 
SELECT * from dept;
SELECT * from emp;


--Query using aggregate function
--This will give you aggregated result only
SELECT count(*) FROM emp;
SELECT min(hiredate) FROM emp;
SELECT max(sal) FROM emp;
SELECT sum(sal) FROM emp;
SELECT deptno,avg(sal) FROM emp group by deptno;
SELECT deptno,sum(sal) FROM emp group by deptno;

--Starting with Analytical Functions
--Using count with Analytical function will give you all the rows and count on each row
--"Over()" is mandatory field for Analytical Functions

--Since we did not give any arguement inside over() it assumes the scope is all.
SELECT deptno, count(*) over() dept_count FROM emp;

--Now if we specify (Partition By deptno) within over() then it will give count for each department
--Partition By is used to Group rows in Analytical Function(same as group by in aggregate functions)
SELECT e.*, count(*) over  (partition by deptno) as EMPCNT_BY_DEPT FROM emp e;

--Same thing can be done joining the dept table to get more information
SELECT e.*, d.DNAME,count(*) over  (partition by e.deptno) as EMPCNT_BY_DEPT 
FROM emp e , DEPT d
WHERE e.DEPTNO=d.DEPTNO;

--Get the Max Salary for Each Dept
SELECT d.deptno,d.dname,e.empno,e.ename,e.job,e.sal,
	   max(sal) over (partition by e.deptno) Dept_Max_Salary
FROM emp e, dept d
WHERE e.DEPTNO=d.DEPTNO;

--Get the Max, Min and Average Salary for each Job Types
SELECT d.deptno,d.dname,e.empno,e.ename,e.job,e.sal,
	   max(sal) over (partition by e.deptno) Dept_Max_Salary,
	   min(sal) over (partition by e.deptno) Dept_Min_Salary,
	   avg(sal) over (partition by e.deptno) Dept_Avg_Salary
FROM emp e, dept d
WHERE e.DEPTNO=d.DEPTNO;

--Order by can be used inside over() as well
SELECT d.deptno,d.dname,e.empno,e.ename,e.job,e.sal,
	   max(sal) over (partition by e.deptno ORDER BY e.sal) Dept_Max_Salary,
	   min(sal) over (partition by e.deptno) Dept_Min_Salary,
	   avg(sal) over (partition by e.deptno) Dept_Avg_Salary
FROM emp e, dept d
WHERE e.DEPTNO=d.DEPTNO;

--We can also get the running aggregate using ORDER BY for the aggregate functions
SELECT e.deptno,ename,job,loc,hiredate, sal Employee_Salary,
      sum(sal) over( partition by d.deptno ORDER BY sal) Dept_Salary_RunningTotal,
      sum(sal) over( partition by d.deptno) Dept_TotalSalary
FROM emp e,dept d
WHERE e.deptno=d.deptno;

--ROW_NUMBER 
--It is used to give serial number to a set of records.
--ORDER by is needed for this
SELECT e.ename, e.job,e.hiredate,e.sal, 
       ROW_NUMBER() over (order by sal desc) AS row_number
from emp e;

SELECT e.ename, e.job,e.hiredate,e.sal, 
       ROW_NUMBER() over (partition by deptno order by sal desc) AS row_number
from emp e;


--RANK
--Rank also gives the serial number but gives the same number incase of duplicate rows.
SELECT ename,hiredate,deptno,sal,
       rank() over (order by sal) rank
FROM emp;

--DENSE_RANK()
--DENSE_RANK also give serial number but it it will not skip the numbers while assigning to duplicate
select ename, hiredate,deptno, sal,
	   DENSE_RANK() over (order by sal) DENSE_RANK
from emp;

--Check the difference between ROWNUMBER,RANK and DENSE_RANK(see rownumber 2 and 10)
SELECT ename,deptno,sal,
       row_number() over (order by sal desc) ROWNUMBER,
       rank() over (order by sal desc) RANK,
       dense_rank() over (order by sal desc) DENSE_RANK 
FROM emp;

--Lead And Lag
--LEAD(<expression>,<offset>,<default>) over(<analytic clause>)
--Lead allows to apply computation on the NEXT row.
SELECT ename,sal,
		lead(sal) over (partition by deptno order by sal desc) next_low_sal,
		lead(sal,1,0) over (partition by deptno order by sal desc) next_low_sal2
FROM emp;

--Lag points to PREVIOUS rows
SELECT ename,sal,
		lag(sal) over (partition by deptno order by sal desc) next_high_sal
FROM emp;

 --FIRST_VALUE and LAST_VALUE
SELECT deptno,ename,sal,hiredate,
        FIRST_VALUE(HIREDATE) over (partition by deptno order by hiredate) FIRST_HIRED,
		LAST_VALUE(HIREDATE) over (partition by deptno order by hiredate) LAST_HIRED
FROM EMP;


--WINDOW Clause
--[ROW or RANGE] BETWEEN <start_expr> AND <end_expr>
--<start_expr> UNBOUNDED PRECEDING |CURRENT ROW -- <sql_expr> PRECEDING or FOLLOWING.
--<end_expr> UNBOUNDED FOLLOWING |CURRENT ROW or <sql_expr> PRECEDING or FOLLOWING


SELECT DISTINCT deptno, LAST_VALUE(sal)
 OVER (PARTITION BY deptno ORDER BY sal ASC
       RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
       AS "HIGHEST"
FROM emp
WHERE deptno in (10,20)
ORDER BY deptno;


SELECT ename,hiredate,sal,
        max(sal) over(order by hiredate,ename 
         ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) max_before_sal
FROM emp;
