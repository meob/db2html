REM Program:	custom_emp7.sql
REM 		Oracle emp7 Benchmark PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	14-FEB-13 mail@meo.bogliolo.name
REM		First version

set lines 132

set heading off
select '<P><a id="custP"></a><a id="emp7"></a><h2>Oracle EMP7 Benchmark</h2>' h from dual;

SELECT '<h3>Oracle Version and Host CPUs</h3><pre>' from dual;
select 'Version: '|| banner
from sys.v_$version
where banner like 'Oracle%';
select 'CPU: '|| cpu_count_current || '  CORE: '|| cpu_core_count_current|| '  SOCKET: '|| cpu_socket_count_current
from v$license;
SELECT '</pre><h3>Benchmark results</h3><pre>' from dual;

set termout off
BEGIN
  EXECUTE IMMEDIATE 'drop TABLE emp7';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode != -0942 THEN RAISE; 
    END IF;
END;
/

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

set timing on
set termout on
select count(*) 
  from emp7 emp1, emp7 emp2, emp7 emp3, emp7 emp4, emp7 emp5, emp7 emp6, emp7 emp_7
  where emp_7.deptno=10;

select count(*) 
  from emp7 emp1, emp7 emp2, emp7 emp3, emp7 emp4, emp7 emp5, emp7 emp6, emp7 emp_7
  where emp_7.deptno=10;
set timing off
set termout off
drop table emp7;
set termout on

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
