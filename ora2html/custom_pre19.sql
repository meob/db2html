REM Program:	custom_10g.sql
REM 		Oracle 10g PlugIn
REM Version:	1.0.3
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	15-AUG-12 mail@meo.bogliolo.name
REM		First version with useful new 10g queries
REM		1.0.3 Added MAX PCT for autoextensible TBS

column TABLESPACE_SIZE format 9,999,999,999,999
column TABLESPACE_NAME format A32
column NAME format A32
column USED_SPACE format 9,999,999,999,999
column USED_PERCENT format 99.99
column STARTUP_TIME format a30
column HOST_NAME format a50
column bg format a18 trunc
column ed format a18 trunc
column MIN_USED format 9,999,999,999,999
column MAX_USED format 9,999,999,999,999
column maxbytes format 9,999,999,999,999,999
set lines 132
set define off

set heading off
select '<a id="10g"></a> <a id="11g"></a> <a id="12c"></a> <a id="18c"></a> ' h from dual;
select '<P><a id="custO"></a><a id="pre19"></a><h2>Oracle pre 19c features</h2>' h from dual;

SELECT '<h3>Tablespace Usage</h3><pre>' from dual;  
set heading on
select TABLESPACE_NAME, USED_SPACE, TABLESPACE_SIZE, USED_PERCENT
  from dba_tablespace_usage_metrics
 order by TABLESPACE_NAME;

SELECT df.tablespace_name tspace,                                                              
       df.bytes/(1024*1024) tot_ts_size,   
       round((df.bytes-sum(fs.bytes))/(1024*1024),0) used_MB,                                                   
       round(sum(fs.bytes)/(1024*1024),0) free_ts_size,                                                 
       round(sum(fs.bytes)*100/df.bytes) free_pct,                                               
       round((df.bytes-sum(fs.bytes))*100/df.bytes) used_pct,
       round((df.bytes-sum(fs.bytes))*100/df.max_sz) used_pct_of_max
  FROM (select tablespace_name, sum(bytes) bytes,sum(decode(autoextensible, 'YES', maxbytes, bytes)) max_sz
          from dba_data_files
         where tablespace_name in (select tablespace_name from dba_tablespaces where contents = 'PERMANENT')
         group by tablespace_name ) df,
       dba_free_space fs
 WHERE fs.tablespace_name = df.tablespace_name                                                  
 GROUP BY df.tablespace_name, df.bytes,df.max_sz
 ORDER BY 1;

set heading off
SELECT '</pre><h3>Tablespaces</h3><pre>' from dual;  
set heading on
select TS#, name, bigfile big, FLASHBACK_ON fsh, INCLUDED_IN_DATABASE_BACKUP bck, ENCRYPT_IN_BACKUP enc
from v$tablespace
order by TS#;

select file_id, a.tablespace_name, autoextensible, maxbytes
from (select file_id, tablespace_name, autoextensible, maxbytes from dba_data_files where autoextensible='YES' and maxbytes = 35184372064256) a, (select tablespace_name from dba_tablespaces where bigfile='YES') b
where a.tablespace_name = b.tablespace_name
union
select file_id,a.tablespace_name, autoextensible, maxbytes
from (select file_id, tablespace_name, autoextensible, maxbytes from dba_temp_files where autoextensible='YES' and maxbytes = 35184372064256) a, (select tablespace_name from dba_tablespaces where bigfile='YES') b
where a.tablespace_name = b.tablespace_name;

set heading off
SELECT '</pre><h3>Instance startup</h3><pre>' from dual;  
set heading on
select *
from (select STARTUP_TIME,VERSION,DB_NAME,INSTANCE_NAME,HOST_NAME
      from DBA_HIST_DATABASE_INSTANCE
      order by startup_time desc)
where rownum <= 30
order by startup_time desc;
set heading off

column sql_id format a20
column patch_date format a20
column child format 99999
column plan format 999999999999
column execs format 999,999,999,999
column cpu_time format 999,999,999,999,999
column elapsed_time format 999,999,999,999,999
column buffer_gets format 999,999,999,999,999
column avg_time format 99,999,999.99
column avg_par format 999.9
column offload format a10
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
column owner format a30
set lines 160
set define off

set heading off
SELECT '</pre><h3>Temporary Tablespace Usage</h3><pre>' from dual;  
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
SELECT '</pre><h3>Mainteniance Tasks</h3><pre>' from dual;  
set heading on

select * from DBA_AUTOTASK_WINDOW_CLIENTS;

column client_name format a32
column job_status format a10
column job_start_time format a45
column job_duration format a19
column job_info format a40
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
select table_owner as owner, compression, compress_for, count(*) Tablespace_count
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
where executions>0
order by 3 desc)
where rownum < 41;

set heading off
SELECT '</pre><h3>SQL Statements using more Buffer Gets</h3><pre>' from dual;  
set heading on
select * from (
select sql_id, executions execs, cpu_time, elapsed_time, buffer_gets,
    (elapsed_time/1000000)/executions avg_time, 
    sql_text sql1l
from v$sqlstats s
where executions>0
order by 5 desc)
where rownum < 41;

set heading off
SELECT '</pre><h3>Most executed SQL Statements in SQL Area</h3><pre>' from dual;  
set heading on
select * from (
select sql_id, child_number child, plan_hash_value plan, executions execs, 
    (elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions)
        /decode(px_servers_executions,0,1,px_servers_executions/decode(nvl(executions,0),0,1,executions)) avg_time, 
    px_servers_executions/decode(nvl(executions,0),0,1,executions) avg_par,
    decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') offload,
    sql_text sql1
from v$sql s
where executions>0
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
    sql_text sql1
  from v$sql s
 where IO_CELL_OFFLOAD_ELIGIBLE_BYTES <> 0
   and executions>0
 order by 5 desc)
where rownum < 11;


set heading off
SELECT '<a id="diag"></a></pre><h3>ADR Diagnostic</h3><pre>' from dual;  
set heading on
select name adr_name, value adr_value
  from V$DIAG_INFO;
set heading off

set heading off
SELECT '<a id="cust6"></a></pre><h3>Alert log</h3><pre>' from dual;  
set heading on

select lpad('   ',lvl,'   ')||logical_file|| '    '|| MODIFY_TIME "Alert and Trace Files"
  from X$DBGDIREXT
 where rownum <31
 order by MODIFY_TIME desc;
set heading off


column connection_name format a20
column connection_id format a20
column db_name format a20
column db_name format a20
column instance_name format a20
column pdb_name format a20
column cloned_from format a20
column host_name format a50
column total_size format 999,999,999,999,999
column object_name format a20
column subobject_name format a20
column owner format a12
column profile format a20
column table_name format a20
column segment_name format a20
column name format a44
column parameter format a44
column value format a80
column distrib format a8 trunc
column bytes format 9999999999
column not_pop format 9999999999
column property_name format a40
column property_value format a20
column con_name format a20
column last_login format a40
column originating_timestamp format a40

set lines 132
set define off

set heading off
select '</pre><P><a id="custO"></a><a id="12c"></a><h2>Oracle 12c features</h2>' h from dual;

SELECT '<h3>Current container</h3><pre>' from dual;
set heading on
select name parameter,value
  from v$parameter
 where name = 'max_pdbs';

select Sys_Context('Userenv', 'Con_Name') Connection_Name,
 Sys_Context('Userenv', 'Con_Id') Connection_ID,
 decode(Sys_Context('Userenv', 'Con_Id'), 0, 'Entire CDB', 1, 'Root', 2, 'Seed', 'PDB') Data_Scope
 from dual;
set heading off

SELECT '</pre><h3>Database and Instance</h3><pre>' from dual;
set heading on
SELECT name db_name, created, cdb
  FROM v$database;
SELECT instance_name, host_name, status, to_char(startup_time, 'YYYY-MM-DD HH24:MI:SS') startup_time, edition
  FROM v$instance;
set heading off

SELECT '</pre><h3>Pluggable Databases</h3><pre>' from dual;
set heading on
SELECT con_id, name pdb_name, open_mode, total_size
  FROM v$pdbs;

SELECT con_id, con_name, instance_name, state saved_state
  FROM cdb_pdb_saved_states;
set heading off

SELECT '</pre><h3>Pluggable Database History</h3><pre>' from dual;  
set heading on
SELECT DB_NAME, CON_ID, PDB_NAME, OPERATION, OP_TIMESTAMP, CLONED_FROM_PDB_NAME cloned_from
  FROM CDB_PDB_HISTORY
 WHERE CON_ID>2
 ORDER BY OP_TIMESTAMP;
set heading off

set lines 180
SELECT '</pre><h3>Users last login</h3><pre>' from dual;  
set heading on
select username, account_status, profile,
       created, last_login, lock_date, expiry_date
  from sys.dba_users
 order by username;
set heading off

SELECT '</pre><h3>Local/Shared Undo</h3><pre>' from dual;  
set heading on
SELECT property_name, property_value
  FROM database_properties
 WHERE property_name = 'LOCAL_UNDO_ENABLED';
set heading off

SELECT '</pre><h3>PDB Modifiable Parameters</h3><b>Name</b><p>' from dual;  
SELECT name
  FROM v$parameter
 WHERE ispdb_modifiable = 'TRUE'
 ORDER BY name;

SELECT '<p><h3>Database In-Memory Option</h3><pre>' from dual;  
set heading on
select name,value
  from v$parameter
 where name like 'inmemory%'
order by name; 

select owner, table_name, cache, inmemory_priority inm_prio, inmemory_distribute, inmemory_compression
  from dba_tables
 where inmemory='ENABLED';

select OWNER, SEGMENT_NAME, INMEMORY_SIZE, BYTES, BYTES_NOT_POPULATED not_pop, 
       POPULATE_STATUS, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE distrib, INMEMORY_COMPRESSION,
       round(BYTES/INMEMORY_SIZE,3) comp_ratio
  from V$IM_SEGMENTS;
set heading off

SELECT '</pre><h3>Enterprise Manager Express</h3><pre>' from dual;  
set heading on
select dbms_xdb_config.gethttpport() HTTP_port,
       dbms_xdb_config.gethttpsport() HTTPS_port
  from dual;
set heading off


REM Requires parameter HEAT_MAP=on (does not work in 12cR1 with CDB)
SELECT '</pre><h3>Heat Map - Most accessed blocks</h3><pre>' from dual;  
set heading on
select * 
  from v$heat_map_segment 
 order by (full_scan+lookup_scan) desc 
 fetch first 50 rows only;
set heading off

SELECT '</pre><h3>Patches</h3><pre>' from dual; 
set heading on
SET LINESIZE 132
SET SERVEROUT ON
SET LONG 2000000
COLUMN action_time FORMAT A20
COLUMN action FORMAT A10
COLUMN bundle_series FORMAT A10
COLUMN comments FORMAT A30
COLUMN description FORMAT A60
COLUMN namespace FORMAT A22
COLUMN status FORMAT A10
COLUMN version FORMAT A10

select xmltransform(dbms_qopatch.get_opatch_install_info, dbms_qopatch.get_opatch_xslt) "Home and Inventory"
  from dual; 

SELECT TO_CHAR(action_time, 'DD-MON-YYYY HH24:MI:SS') AS action_time,
	action,
	status,
	description,
	patch_id
  FROM sys.dba_registry_sqlpatch
 ORDER by action_time;
SELECT TO_CHAR(action_time, 'DD-MON-YYYY HH24:MI:SS') AS action_time,
       action,
       namespace,
       id,
       comments
  FROM sys.registry$history
 ORDER by action_time;

exec dbms_qopatch.get_sqlpatch_status;

select message_type, message_level, originating_timestamp, message_text 
  from v$diag_alert_ext
 where message_type in (2, 3) or message_level=1
 order by originating_timestamp desc;

set heading off
set lines 132
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;

