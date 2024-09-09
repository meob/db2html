REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM IMPORTANT NOTICE:
REM		This script uses ADDM (Automatic Database Diagnostic Monitor)
REM		This script requires the Oracle Diagnostic Pack LICENSE

set heading off
set lines 180
set long 10000000
SET LONGCHUNKSIZE 10000000
spool addm_report
VARIABLE addm_report CLOB;
BEGIN
  :addm_report :=DBMS_AUTO_SQLTUNE.REPORT_AUTO_TUNING_TASK(
    begin_exec   => NULL,
    end_exec     => NULL,
    type         => 'TEXT',
    level        => 'TYPICAL',
    section      => 'ALL',
    object_id    => NULL,
    result_limit => NULL);
END;
/
PRINT :addm_report
spool off

SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF
spool addm_monitor_list.htm
select sys.DBMS_SQLTUNE.report_sql_monitor_list(TYPE=>'HTML',report_level=>'ALL')
 from dual;
spool off

set lines 132
SET LONGCHUNKSIZE 100
set heading on
COLUMN sql_profile FORMAT A30
spool addm_sql
select sql_id, child_number, plan_hash_value, sql_profile, executions, ELAPSED_TIME, BUFFER_GETS, sql_text
  from v$sql
 where sql_profile is not null;
spool off