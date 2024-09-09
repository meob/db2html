REM Program:	custom_omf.sql
REM 		Oracle-Managed Files (OMF) PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	14-FEB-16 mail@meo.bogliolo.name
REM		First version
REM		  

column name format a55
column value format a50
column fname format a55

set heading off
select '<P><a id="custO"></a><a id="omf"></a><h2>Oracle-Managed Files</h2>' h from dual;

SELECT '<h3>#Datafile</h3><pre>' from dual;
set heading on
SELECT is_omf, count(*)
  FROM KU$_FILE_VIEW
 group by is_omf;
set heading off

SELECT '</pre><h3>OMF Configuration parameters</h3><pre>' from dual;
set heading on
select name, value
  from v$parameter
 where name like 'db_create_%'
union
select name, value
  from v$parameter
 where name like 'db_recovery_file_%';
set heading off

SELECT '</pre><h3>Datafiles and OMF flag</h3><pre>' from dual;
set heading on
SELECT name, fname, ts_num, is_omf
  FROM KU$_FILE_VIEW
 order by ts_num, name;
set heading off

select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;

