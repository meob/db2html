REM Program:	custom_12c.sql
REM 		Oracle 12c PlugIn
REM Version:	1.0.4
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	1-JUL-13 mail@meo.bogliolo.name
REM		First version with useful 12c queries on Pluggable Databases, ...
REM Date:    	1-JUL-14 mail@meo.bogliolo.name
REM		12.1.0.2 new features: InMemory
REM Date:    	14-FEB-17 mail@meo.bogliolo.name
REM		12R2 new features: Local Undo
REM		(1.0.3) patches (a): formatting
REM		(1.0.4) last_login

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

set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="12c"></a><h2>Oracle 12c features</h2>' h from dual;

SELECT '<h3>Current container</h3><pre>' from dual;
set heading on
select name parameter,value
  from sys.v$parameter
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
  from sys.v$parameter
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
SET PAGESIZE 1000
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
	version,
	patch_id,
	bundle_series
  FROM sys.dba_registry_sqlpatch
 ORDER by action_time;
SELECT TO_CHAR(action_time, 'DD-MON-YYYY HH24:MI:SS') AS action_time,
       action,
       namespace,
       version,
       id,
       comments,
       bundle_series
  FROM sys.registry$history
 ORDER by action_time;

exec dbms_qopatch.get_sqlpatch_status;
set heading off

set lines 132

select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;

REM v$diag_alert_ext is too slow (Doc ID 1684140.1)
REM select message_type, message_level, message_text, ORIGINATING_TIMESTAMP from v$diag_alert_ext where message_type in (2, 3) or message_level=1;
