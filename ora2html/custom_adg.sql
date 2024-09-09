REM Program:	custom_adg.sql
REM 		Custom Oracle Active Data Guard Plug-in
REM Version:	1.0.2
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http:www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	15-AUG-12 mail@meo.bogliolo.name
REM		
REM		This plugin is intended for the secondary site in an Active Data Guard configuration

set linesize 132
set heading off
set feedback off
set timing off
column unit format a13 trunc
column value format a20
column arch_log format 99,999,999
column time_computed format a20
column datum_time format a20
column arc_first format a20
column arc_last format a20
column FORCE_LOGGING format a5
column scn_time format a21 trunc
column flashback_on format a5 trunc
column status format a6 trunc
column scn_next format 99999999999999
column CURRENT_SCN format 99999999999999
column message format a100 trunc

set heading off
select '<P><a id="custO"></a><a id="adg"></a><h2>Active Data Guard</h2><pre>' h from dual;
set heading on
select INSTANCE_NAME, INSTANCE_ROLE, DATABASE_STATUS, HOST_NAME from v$instance;
select name, database_role, open_mode, controlfile_type, switchover_status, PROTECTION_MODE, flashback_on, log_mode, 
	FORCE_LOGGING
 from v$database;
select to_char(sysdate,'YYYY-MM-DD HH24:MI') "SYSDATE", CURRENT_SCN from v$database;
select 'Using Active Data Guard' ADG from v$managed_standby where process like 'MRP%';
select dest_id, creator, registrar, status, archived,
	deleted, applied, count(*),min(to_char(FIRST_TIME,'YYYY-MM-DD HH24:MI')) arc_first,
	max(to_char(FIRST_TIME,'YYYY-MM-DD HH24:MI')) arc_last, max(NEXT_CHANGE#) scn_next
 from v$archived_log
 group by dest_id, creator, registrar, archived, status, applied, deleted
 order by dest_id, applied desc, status;
select * from v$dataguard_stats;
select time lag_time, unit, LAST_TIME_UPDATED
 from V$STANDBY_EVENT_HISTOGRAM
 where LAST_TIME_UPDATED=(select max(LAST_TIME_UPDATED) from V$STANDBY_EVENT_HISTOGRAM)
   and name='apply lag';
select message LastMessage
 from V$DATAGUARD_STATUS
 where timestamp = (select max(timestamp) from V$DATAGUARD_STATUS);
select 'RedoLog ' Logs, GROUP#,THREAD#,SEQUENCE#,ARCHIVED,STATUS,(bytes/1024/1024) size_mb from V$LOG;
select 'StdbyLog' Logs, GROUP#,THREAD#,SEQUENCE#,ARCHIVED,STATUS,(bytes/1024/1024) size_mb from V$STANDBY_LOG;

select name, FS_FAILOVER_STATUS, FS_FAILOVER_OBSERVER_PRESENT
 from v$database;
SELECT LAST_FAILOVER_TIME, LAST_FAILOVER_REASON FROM V$FS_FAILOVER_STATS;

select process, status, thread#, sequence#, block#, blocks from v$managed_standby ;
rem select * from v$recovery_progress;

select name lag, round(time, -1) "Interval", unit, sum(count), max(LAST_TIME_UPDATED) LAST_UPDATED
 from V$STANDBY_EVENT_HISTOGRAM
 group by name, round(time, -1), unit
 order by name, unit desc, round(time, -1);

select to_char(timestamp, 'YYYY/MM/DD HH24:MI:SS') timestamp, message
 from (select * from V$DATAGUARD_STATUS order by timestamp desc)
 where rownum <= 40
 order by timestamp desc;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
