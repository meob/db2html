REM Program:	custom_11g.sql
REM 		Oracle 11g PlugIn
REM Version:	1.0.7
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://www.md-c.it/meo/
REM		
REM Date:    	15-AUG-12 mail@meo.bogliolo.name
REM		  First version with useful 11g queries on Temporary, RAC, Exadata, DB patch
REM		1.0.2 More compression info
REM		1.0.3 Alert log
REM		1.0.4 New CSS
REM		1.0.5 Commented out the alter log query (a) version a12 -> a16
REM		1.0.6 Added ADR view V$DIAG_INFO
REM		1.0.7 V$SQLSTATS (10gR2+)

column sql_id format a20
column patch_date format a20
column child format 99999
column plan format 999999999999
column execs format 999,999,999,999
column avg_time format 99,999,999
column avg_par format 999.9
column offload format a10
column IO_saved format 9999.9
column sql1 format a128 trunc
column sql1l format a128 
column comments format a30 trunc
column tmp_file_name format a70
column TABLESPACE_NAME format a32
column TABLESPACE_SIZE format 999,999,999,999,999
column ALLOCATED_SPACE format 999,999,999,999,999
column FREE_SPACE format 999,999,999,999,999
column BYTES format 999,999,999,999,999
column WINDOW_NAME format a20
column WINDOW_NEXT_TIME format a40 trunc
column action format a12 trunc
column version format a16
column username format a30
column ACCOUNT_STATUS format a30
column message_text format a100
column Timestamp format a28
column adr_name format a30
column adr_value format a90
set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="11g"></a><h2>Oracle 11g features</h2>' h from dual;
SELECT '<h3>Temporary Tablespace Usage</h3><pre>' from dual;  
set heading on

SELECT TABLESPACE_NAME, TABLESPACE_SIZE, ALLOCATED_SPACE, FREE_SPACE 
FROM dba_temp_free_space
order by TABLESPACE_NAME;

select  NAME tmp_file_name, TS#,  BYTES, STATUS, ENABLED, inst_id
from gv$TEMPFILE
order by NAME;

SELECT tablespace_name, total_blocks, used_blocks, free_blocks, inst_id
FROM gv$sort_segment
order by tablespace_name, total_blocks desc;

set heading off
SELECT '</pre><h3>Password file Users</h3><pre>' from dual;  
set heading on

select USERNAME,INST_ID,SYSDBA,SYSOPER,SYSASM
  from gv$pwfile_users
 order by INST_ID,USERNAME;

set heading off
SELECT '</pre><a id="usr_sec_11g"><h3>Users with default password</h3><pre>' from dual;  
set heading on

select d.username, u.account_status
 from dba_users_with_defpwd d, dba_users u
 where d.username=u.username;

set heading off
SELECT '</pre><h3>Manteniance Tasks</h3><pre>' from dual;  
set heading on

select * from DBA_AUTOTASK_WINDOW_CLIENTS;

column client_name format a32
column job_status format a10
column job_start_time format a45
column job_duration format a19
column job_info format a20
select * from (
SELECT client_name, job_status, job_start_time, job_duration, job_info
  FROM dba_autotask_job_history
 WHERE job_start_time > sysdate-7
 ORDER BY job_start_time desc)
 WHERE rownum < 101
 ORDER BY job_start_time;

set heading off
SELECT '</pre><h3>Slowest SQL Statements</h3> (Statements and cell offload)<pre>' from dual;  
set heading on
select * from (
select sql_id, child_number child, plan_hash_value plan, executions execs, 
    (elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions)
        /decode(px_servers_executions,0,1,px_servers_executions/decode(nvl(executions,0),0,1,executions)) avg_time, 
    px_servers_executions/decode(nvl(executions,0),0,1,executions) avg_par,
    decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') offload,
    decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,100*(IO_CELL_OFFLOAD_ELIGIBLE_BYTES-IO_INTERCONNECT_BYTES)
       /decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,1,IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) IO_saved,
    replace(replace(sql_text,'<','&lt;'),'>','&gt;') sql1
from v$sql s
order by 5 desc)
where rownum < 21;

set heading off
SELECT '</pre><h3>Table compression</h3><pre>' from dual;  
set heading on
select owner, compression, compress_for, count(*) Table_count
 from dba_tables
 where owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
   and compression='ENABLED'
 group by owner, compression, compress_for
 order by owner, compression, compress_for;
select table_owner, compression, compress_for, count(*) Tablespace_count
 from dba_tab_partitions
 where table_owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
   and compression='ENABLED'
 group by table_owner, compression, compress_for
 order by table_owner, compression, compress_for;

set heading off
SELECT '</pre><h3>Heaviest SQL Statements</h3><pre>' from dual;  
set heading on
select * from (
select sql_id, executions execs, cpu_time, elapsed_time, buffer_gets,
    (elapsed_time/1000000)/executions avg_time, 
    sql_text sql1l
from v$sqlstats s
order by 4 desc)
where rownum < 21;

set heading off
SELECT '</pre><h3>Most executed SQL Statements</h3><pre>' from dual;  
set heading on
select * from (
select sql_id, child_number child, plan_hash_value plan, executions execs, 
    (elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions)
        /decode(px_servers_executions,0,1,px_servers_executions/decode(nvl(executions,0),0,1,executions)) avg_time, 
    px_servers_executions/decode(nvl(executions,0),0,1,executions) avg_par,
    decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') offload,
    decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,100*(IO_CELL_OFFLOAD_ELIGIBLE_BYTES-IO_INTERCONNECT_BYTES)
       /decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,1,IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) IO_saved,
    sql_text sql1
from v$sql s
order by 4 desc)
where rownum < 21;

set heading off
SELECT '</pre><h3>Offloaded SQL Statements</h3><pre>' from dual;  
set heading on
select * from (
select sql_id, child_number child, plan_hash_value plan, executions execs, 
    (elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions)
        /decode(px_servers_executions,0,1,px_servers_executions/decode(nvl(executions,0),0,1,executions)) avg_time, 
    px_servers_executions/decode(nvl(executions,0),0,1,executions) avg_par,
    decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') offload,
    decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,100*(IO_CELL_OFFLOAD_ELIGIBLE_BYTES-IO_INTERCONNECT_BYTES)
       /decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,1,IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) IO_saved,
    sql_text sql1
  from v$sql s
 where IO_CELL_OFFLOAD_ELIGIBLE_BYTES <> 0
 order by 5 desc)
where rownum < 11;

set heading off
SELECT '<a id="cust5"></a></pre><h3>Database patches</h3><pre>' from dual;  
set heading on

REM Add the following text, if supported:   ,BUNDLE_SERIES
select to_char(action_time,'YYYY-MM-DD HH24:MI:SS') patch_date, id, action, substr(version,1, 16) version, comments
  from registry$history
 order by to_char(action_time,'YYYY-MM-DD HH24:MI:SS');

set heading off
SELECT '<a id="diag"></a></pre><h3>ADR Diagnostic</h3><pre>' from dual;  
set heading on
select name adr_name, value adr_value
  from V$DIAG_INFO;
set heading off

set heading off
SELECT '<a id="cust6"></a></pre><h3>Alert log</h3><pre>' from dual;  
set heading on

REM BUG 21172913 ???
rem SELECT time_stamp, message_text
rem   FROM ( SELECT To_Char(Originating_Timestamp, 'YYYY-MM-DD HH24:MI:SSxFF') time_stamp,
rem                trim(message_text) message_text
rem           FROM X$dbgalertext
rem          ORDER BY Originating_Timestamp DESC)
rem  WHERE rownum < 51
rem  ORDER BY time_stamp;

select lpad('   ',lvl,'   ')||logical_file|| '    '|| MODIFY_TIME "Alert and Trace Files"
  from X$DBGDIREXT
 where rownum <31
 order by MODIFY_TIME desc;
set heading off


REM dba_network_acls
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
