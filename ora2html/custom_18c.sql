REM Program:	custom_18c.sql
REM 		Oracle 18c PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	14-FEB-18 mail@meo.bogliolo.name
REM		First version with new useful queries available on 18

column con_name format a20
column con_id format a20
column service_name format a20

set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="18c"></a><h2>Oracle 18c features</h2>' h from dual;
SELECT '<h3>PDB Snapshots</h3><pre>' from dual;
set heading on
select CON_NAME, CON_ID, CON_UID, 
       SNAPSHOT_NAME, SNAPSHOT_TIME, SNAPSHOT_SCN,
       FULL_SNAPSHOT_PATH
  from DBA_PDB_SNAPSHOTS;
set heading off

REM  changed from 12... https://docs.oracle.com/en/database/oracle/oracle-database/18/refrn/DBA_REGISTRY_SQLPATCH.html
SELECT '</pre><h3>Patches</h3><pre>' from dual; 
set heading on
SELECT TO_CHAR(action_time, 'DD-MON-YYYY HH24:MI:SS') AS action_time,
	action,
	status,
	description,
	target_version,
	patch_id
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
set heading off

SELECT '</pre><h3>Automatic In-Memory task</h3><pre>' from dual;
set heading on
select *
  from DBA_INMEMORY_AIMTASKDETAILS;
set heading off

SELECT '</pre><h3>Private temporary tables</h3><pre>' from dual;
set heading on
select *
  from DBA_PRIVATE_TEMP_TABLES;
set heading off

SELECT '</pre><h3>Connection tests</h3><pre>' from dual;
set heading on
select *
  from DBA_CONNECTION_TESTS;
set heading off

select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;