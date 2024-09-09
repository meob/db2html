-- EMP7 Benchmark - SQL script - MySQL version
-- v.1.0.1
-- Copyright (C) 2006-2008 meo@bogliolo.name

use test;

drop table if exists emp7;
create table emp7(EMPNO integer not null,ENAME VARCHAR(10),JOB VARCHAR(9),
	MGR integer,HIREDATE DATE,SAL float,COMM float,DEPTNO integer);
create unique index pkemp7 on emp7(EMPNO);

insert into emp7(empno, ename, deptno) values(7369, 'SMITH', 10);
insert into emp7(empno, ename, deptno) values(7499, 'ALLEN', 10);
insert into emp7(empno, ename, deptno) values(7521, 'WARD',  10);
insert into emp7(empno, ename, deptno) values(7566, 'JONES', 10);
insert into emp7(empno, ename, deptno) values(7654, 'MARTIN',10);
insert into emp7(empno, ename, deptno) values(7698, 'BLAKE', 10);
insert into emp7(empno, ename, deptno) values(7782, 'CLARK', 10);
insert into emp7(empno, ename, deptno) values(7788, 'SCOTT', 10);
insert into emp7(empno, ename, deptno) values(7839, 'KING',  10);
insert into emp7(empno, ename, deptno) values(7844, 'TURNER',10);
insert into emp7(empno, ename, deptno) values(7876, 'ADAMS', 10);
insert into emp7(empno, ename, deptno) values(7900, 'JAMES', 10);
insert into emp7(empno, ename, deptno) values(7902, 'FORD',  10);
insert into emp7(empno, ename, deptno) values(7934, 'MILLER',10);
commit;

select version();

select count(*)
  from emp7 emp1, emp7 emp2, emp7 emp3, emp7 emp4, emp7 emp5, emp7 emp6, emp7 emp_7
  where emp_7.deptno=10;


