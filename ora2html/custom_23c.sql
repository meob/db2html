REM Program:	custom_23c.sql
REM 		Oracle 23c PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	15-AUG-23 mail@meo.bogliolo.name
REM		First version with new useful queries available on 23c

column object_name format a25
column object_type format a15
column column_name format a20
column annotation_name format a15
column annotation_value format a15


set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="23c"></a><h2>Oracle 23c features</h2>' h from dual;
SELECT '<h3>Table Annotations</h3><pre>' from dual;
set heading on
select object_name, object_type, annotation_name, annotation_value 
  from user_annotations_usage
 where column_name is null
 order by 2, 1;
set heading off

SELECT '</pre><h3>Column Annotations</h3><pre>' from dual; 
set heading on
select object_name, object_type, column_name, annotation_name, annotation_value 
  from user_annotations_usage
 where column_name is not null
 order by 2, 1, 3;
set heading off

select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;