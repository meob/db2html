REM Program:	custom_sqlt.sql
REM 		Oracle SQL Tuning PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:	1-APR-10 mail@meo.bogliolo.name
REM		Initial version with useful ADDM queries
REM		
REM IMPORTANT NOTICE:
REM		This script uses tables about:
REM		  SQL tuning
REM		This script requires the Oracle Tuning Pack LICENSE

column sql_hash format a20
column rank format 999999999
column plan format 999999999999
column sql_profile format a30
column sql_text format a180
column execs format 999,999,999,999
column ELAPSED_TIME format 999,999,999,999
column Action_found format a132
set lines 132

set heading off
SELECT '<p><a id="custP"></a><a id="sqlt"></a><h2>SQL tuning (Tuning Pack based)</h2><pre>' from dual;
SELECT '<b>SQL Profiles</b>' from dual;  
set heading on
set long 1000
column TASK_EXEC_NAME format a16
column sql_text format a130

select NAME, TASK_EXEC_NAME, to_char(LAST_MODIFIED,'YYYY-MM-DD HH24:MI:SS') last_modified,
       type, status, force_matching mtc,
       substr(SQL_TEXT,1,130) sql_text
  from DBA_SQL_PROFILES;

set heading off
SELECT '<b>SQL running with profile</b>' from dual;  
set heading on
column TASK_EXEC_NAME format a16
column sql_text format a130
break on sql_id on sql_text

select sql_id, child_number child, plan_hash_value plan, sql_profile, EXECUTIONS execs, ELAPSED_TIME, BUFFER_GETS, sql_text
  from v$sql 
 where sql_profile is not null
order by sql_id, child_number;
CLEAR BREAKS

set heading off
SELECT '<b>SQL Plan Baselines</b>' from dual;  
set heading on

SELECT sql_handle, plan_name, enabled, accepted, elapsed_time,
       executions, optimizer_cost, to_char(created,'YYYY-MM-DD HH24:MI') created
FROM   dba_sql_plan_baselines
WHERE  sql_text NOT LIKE '%dba_sql_plan_baselines%'
order by sql_handle, executions desc;

set heading off
SELECT '<b>Auto Tuning Report</b>' from dual;  
set heading on

variable my_rept CLOB;
BEGIN
  :my_rept :=DBMS_SQLTUNE.REPORT_AUTO_TUNING_TASK(
    begin_exec => NULL,
    end_exec => NULL,
    type => 'TEXT',
    level => 'TYPICAL',
    section => 'ALL',
    object_id => NULL,
    result_limit => 10);
END;
/
print :my_rept

set heading off
SELECT '<b>SQLTUNE_STATISTICS</b>' from dual;  
set heading on

select * from DBA_SQLTUNE_STATISTICS
 where rownum<=20;

set heading off
SELECT '<b>SQLTUNE_PLANS</b>' from dual;  
set heading on

column REMARKS format a20 TRUNC
column OPTIMIZER format a20 TRUNC
column ACCESS_PREDICATES format a60 TRUNC
column FILTER_PREDICATES format a60 TRUNC
column PROJECTION format a60 TRUNC

select TASK_ID,EXECUTION_NAME,OBJECT_ID ATTRIBUTE,PLAN_HASH_VALUE,PLAN_ID,TIMESTAMP,
       OPERATION,OBJECT_NAME,OBJECT_TYPE,OPTIMIZER,
       ACCESS_PREDICATES,PROJECTION,FILTER_PREDICATES,TIME,QBLOCK_NAME,
       CPU_COST,IO_COST,TEMP_SPACE
  from DBA_SQLTUNE_PLANS
 where rownum<=20;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
