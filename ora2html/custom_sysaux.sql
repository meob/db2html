REM Program:	custom_sysaux.sql
REM 		Oracle SYSAUX PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	14-FEB-14 mail@meo.bogliolo.name
REM		First version

column item format a25
column ALLOCATED_SPACE format 999,999,999,999,999
column owner format a20
column MOVE_PROC format a40 trunc
set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="sysaux"></a><h2>SYSAUX Space Usage</h2><pre>' h from dual; 
set heading on

SELECT  occupant_name item,
    space_usage_kbytes ALLOCATED_SPACE,
    schema_name owner,
    move_procedure MOVE_PROC
FROM v$sysaux_occupants
ORDER BY 2 desc;

set heading off
SELECT  'Total Usage' item,
    sum(space_usage_kbytes) ALLOCATED_SPACE
FROM v$sysaux_occupants;

SELECT '<b>Statistics retention</b>' from dual;  
set heading on

select dbms_stats.get_stats_history_retention retention from dual;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
