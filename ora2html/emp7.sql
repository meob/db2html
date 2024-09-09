REM EMP7 Benchmark - SQL script
REM v.1.0.0 
REM Copyright (C) 2005-2024 mail@meo.bogliolo.name

rem connect scott/tiger

spool emp7_create
drop table emp7;
create table emp7(EMPNO integer not null,ENAME VARCHAR(10),JOB VARCHAR(9),
	MGR integer,HIREDATE DATE,SAL float,COMM float,DEPTNO integer);
create unique index pkemp7 on emp7(EMPNO);

insert into emp7(empno, ename, deptno) values(1,'SMITH',10);
insert into emp7(empno, ename, deptno) values(2,'SMITH',10);
insert into emp7(empno, ename, deptno) values(3,'SMITH',10);
insert into emp7(empno, ename, deptno) values(4,'SMITH',10);
insert into emp7(empno, ename, deptno) values(5,'SMITH',10);
insert into emp7(empno, ename, deptno) values(6,'SMITH',10);
insert into emp7(empno, ename, deptno) values(7,'SMITH',10);
insert into emp7(empno, ename, deptno) values(8,'SMITH',10);
insert into emp7(empno, ename, deptno) values(9,'SMITH',10);
insert into emp7(empno, ename, deptno) values(10,'SMITH',10);
insert into emp7(empno, ename, deptno) values(11,'SMITH',10);
insert into emp7(empno, ename, deptno) values(12,'SMITH',10);
insert into emp7(empno, ename, deptno) values(13,'SMITH',10);
insert into emp7(empno, ename, deptno) values(14,'SMITH',10);
commit;

analyze table emp7 compute statistics;
spool off

set timing on
spool emp7
select count(*) 
  from emp7 emp1, emp7 emp2, emp7 emp3, emp7 emp4, emp7 emp5, emp7 emp6, emp7 emp_7
  where emp_7.deptno=10;

select count(*) 
  from emp7 emp1, emp7 emp2, emp7 emp3, emp7 emp4, emp7 emp5, emp7 emp6, emp7 emp_7
  where emp_7.deptno=10;

spool off
exit
