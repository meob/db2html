REM Program:	DG2html.sql
REM 		Custom Oracle Data Guard report (for Standby Servers too)
REM Version:	1.0.2a
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	15-AUG-12 mail@meo.bogliolo.name
REM		
REM		This script is intended for the secondary site in a Data Guard configuration
REM		This script can be called from the OracleDetails ux2html plugin instead of ora2html.sql script

set space 1
set pagesize 9999
set linesize 132
set heading off
set feedback off
set timing off
ttitle off

spool ora2html.htm
select '<html><head><title>', value,
  ' - DG2html Oracle Statistics</title></head><body>'
from v$parameter
where name like 'db_name';

select '<h1 align=center>'||substr(value,1,25)||'</h1>'
from v$parameter
where name ='db_name';

select '<P><a id="top"></A>' from dual;
select '<table><tr><td><ul>' from dual;
select '<li><A HREF="#status">Summary Status</A></li>' from dual;
select '<li><A HREF="#dg">Data Guard Status</A></li>' from dual;
select '<li><A HREF="#asm">ASM</A></li>' from dual;
select '</ul></table><p><hr>' from dual;
 
select '<P>Statistics generated on: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') from dual;
 
select 'by: '||user from dual;

select 'using: <I><b>DG2html.sql</b> v.1.0.2a' from dual;
select '<br>Software by ' from dual;
select '<A HREF="http://www.xenialab.it/meo/web/index5.htm#dwn">Meo Bogliolo</A></I><p>' from dual;
 
select '<hr><P><a id="status"></A>' "Status" from dual;
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>' from dual;
select '<tr><td><b>Item</b>', '<td><b>Value</b>' from dual;

select '<tr><td>'||' Instance :', '<! 10>',
 '<td>'||value
from v$parameter
where name like 'db_name'
union
select '<tr><td>'||' Version :', '<! 12>',
 '<td>'||substr(banner,instr(banner, '.',1,1)-2,11)
 from sys.v$version
 where banner like 'Oracle%'
union
select '<tr><td>'||' Created :', '<! 15>',
 '<td >'|| to_char(created,'DD-MON-YYYY HH24:MI:SS')
 from v$database
union
select '<tr><td>'||' SGA (MB) :', '<! 30>',
 '<td align="right">'||to_char(sum(value)/(1024*1024),'999,999,999,999')
 from sys.v$sga
union
select '<tr><td>'||' Log archiving :', '<! 27>',
 '<td>'||log_mode
 from v$database
union
select '<tr><td>'||' Role :', '<! 14a>',
 '<td>'||database_role
 from v$database
union
select '<tr><td>'||' Processes :', '<! 40>',
 '<td align="right">'||to_char(count(*),'999999999999')
from v$session
union
select '<tr><td>'||' Hostname :', '<! 14>',
 '<td>'|| host_name
 from v$instance
union
select '<tr><td>'||' Startup :', '<! 16>',
 '<td>'|| to_char(startup_time,'DD-MON-YYYY HH24:MI:SS')
 from v$instance
union
select '<tr><td>'||' Last Applied Log (Est.) :', '<! 18>',
 '<td>'|| max(to_char(first_time,'DD-MON-YYYY HH24:MI:SS'))
 from v$archived_log
 where applied='YES'
union
select '<tr><td>'||' Archiver :', '<! 28>',
 '<td>'|| archiver
 from v$instance
order by 2;
select '</table><p><hr>' from dual;

SELECT '<a id="dg"></a><b>Data Guard Status</b><p><pre>' from dual;  
set heading on

column unit format a13 trunc
column value format a20
column arch_log format 99,999,999
column time_computed format a20
column datum_time format a20
column arc_first format a20
column arc_last format a20
column FORCE_LOGGING format a5
column flashback_on format a5 trunc
column timestamp format a20
column message format a100
column LastMessage format a100
column scn_next format 999999999999999
column CURRENT_SCN format 999999999999999
column lag format a20

select INSTANCE_NAME, INSTANCE_ROLE, DATABASE_STATUS, HOST_NAME from v$instance;
select name, database_role, open_mode, controlfile_type, switchover_status, PROTECTION_MODE, flashback_on, log_mode, 
	FORCE_LOGGING
 from v$database;
select to_char(sysdate,'YYYY-MM-DD HH24:MI') "SYSDATE", CURRENT_SCN from v$database;
rem select scn_to_timestamp(&SCN) from dual; Check on Primary
select applied arch_applied, count(*),min(to_char(FIRST_TIME,'YYYY-MM-DD HH24:MI')) arc_first,
       max(to_char(FIRST_TIME,'YYYY-MM-DD HH24:MI')) arc_last, max(NEXT_CHANGE#) scn_next
 from v$archived_log
 group by applied
 order by applied desc;
select * from v$dataguard_stats;
select message LastMessage
 from V$DATAGUARD_STATUS
 where timestamp = (select max(timestamp) from V$DATAGUARD_STATUS);
select 'RedoLog ' Logs, GROUP#,THREAD#,SEQUENCE#,ARCHIVED,STATUS,(bytes/1024/1024) size_mb from V$LOG;
select 'StdbyLog' Logs, GROUP#,THREAD#,SEQUENCE#,ARCHIVED,STATUS,(bytes/1024/1024) size_mb from V$STANDBY_LOG;

select process, status, thread#, sequence#, block#, blocks from v$managed_standby ;
rem select * from v$recovery_progress;

select name lag, sum(count), unit, round(time, -1) "Interval"
 from V$STANDBY_EVENT_HISTOGRAM
 group by name, round(time, -1), unit
 order by name, unit, round(time, -1) desc;

select to_char(timestamp, 'YYYY/MM/DD HH24:MI:SS') timestamp, message
 from (select * from V$DATAGUARD_STATUS order by timestamp desc)
 where rownum <= 40
 order by timestamp desc;

set heading off
select '</pre>' from dual;

REM can be excluded if not using ASM
select '<p><a id="asm"></A><h1>ASM</h1>' h from dual;
start custom_asm.sql
select '</pre><p><hr>' h from dual;

select '<P>Statistics generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||'<P>' 
from dual;

select 'For more info visit' from dual;
select '<A HREF="http://www.xenialab.it/meo/web/index5.htm">this site</A>' from dual;
select 'or contact' from dual;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo Bogliolo</A>.<p></body></html>' from dual;

spool off
set newpage 1
exit
