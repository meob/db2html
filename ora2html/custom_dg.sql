REM Program:	custom_dg.sql
REM 		Custom Oracle Data Guard Plug-in
REM Version:	1.0.3
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	15-AUG-12 mail@meo.bogliolo.name
REM		
REM		This plugin is intended for the primary site in a Data Guard configuration

set colsep ' '
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
column SYSDATE format a20
column scn_next    format 999999999999999
column CURRENT_SCN format 999999999999999
column scn_time_formatted format a20
column DEST_NAME format a20
column DESTINATION format a54
column name format a16

set heading off
select '<P><a id="custO"></a><a id="dg"></a><h2>Data Guard</h2><pre>' h from dual;
set heading on
select INSTANCE_NAME, INSTANCE_ROLE, DATABASE_STATUS, HOST_NAME from v$instance;
select name, database_role, open_mode, controlfile_type, switchover_status, PROTECTION_MODE, flashback_on, log_mode, FORCE_LOGGING
 from v$database;
select to_char(sysdate,'YYYY-MM-DD HH24:MI') "SYSDATE", CURRENT_SCN,
       sys.scn_to_timestamp(CURRENT_SCN) scn_time, to_char(sys.scn_to_timestamp(CURRENT_SCN),'YYYY-MM-DD HH24:MI') scn_time_formatted
 from v$database;
select 'Using Active Data Guard' ADG from v$managed_standby where process like 'MRP%';
select dest_id, creator, registrar, status, archived,
	deleted, applied, count(*), max(SEQUENCE#) max_seq, min(to_char(FIRST_TIME,'YYYY-MM-DD HH24:MI')) arc_first,
	max(to_char(FIRST_TIME,'YYYY-MM-DD HH24:MI')) arc_last, max(NEXT_CHANGE#) scn_next
 from v$archived_log
 group by dest_id, creator, registrar, archived, status, applied, deleted
 order by dest_id, deleted,applied, status;
select round((ARCHIVED_TIME-APPLIED_TIME)*24*60) Est_GAP_IN_MINUTES
from   (SELECT MAX(COMPLETION_TIME) ARCHIVED_TIME
          FROM V$ARCHIVED_LOG WHERE DEST_ID=1 AND ARCHIVED='YES'),
       (SELECT MAX(COMPLETION_TIME) APPLIED_TIME
          FROM V$ARCHIVED_LOG WHERE DEST_ID=2 AND APPLIED='YES');
select 'RedoLog ' Logs, GROUP#,THREAD#,SEQUENCE#,ARCHIVED,STATUS,(bytes/1024/1024) size_mb from V$LOG;
select 'StdbyLog' Logs, GROUP#,THREAD#,SEQUENCE#,ARCHIVED,STATUS,(bytes/1024/1024) size_mb from V$STANDBY_LOG;
select TYPE Arc_Dest_Type,INST_ID,DEST_ID,STATUS,ARCHIVED_SEQ#,DEST_NAME,DESTINATION
 from gv$Archive_Dest_Status
 where status !='INACTIVE';
select name, FS_FAILOVER_STATUS, FS_FAILOVER_OBSERVER_PRESENT
 from v$database;
SELECT LAST_FAILOVER_TIME, LAST_FAILOVER_REASON FROM V$FS_FAILOVER_STATS;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
