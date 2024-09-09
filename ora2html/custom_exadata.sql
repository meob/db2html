REM Program:	custom_exadata.sql
REM 		Oracle Exadata PlugIn
REM Version:	1.0.1
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	15-AUG-13 mail@meo.bogliolo.name
REM		First version with useful queries on Exadata (the top of Oracle engineered DB machine)

column sql_id format a20
column patch_date format a20
column child format 99999
column plan format 999999999999
column execs format 99,999,999
column avg_time format 99,999,999
column avg_par format 999.9
column offload format a10
column IO_saved format 9999.9
column sql1 format a128 trunc
column comments format a30 trunc
column tmp_file_name format a50
column TABLESPACE_SIZE format 999,999,999,999,999
column ALLOCATED_SPACE format 999,999,999,999,999
column FREE_SPACE format 999,999,999,999,999
column BYTES format 999,999,999,999,999
column WINDOW_NEXT_TIME format a40 trunc
column action format a12 trunc
column version format a12
set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="exa"></a><h2>Oracle Exadata</h2>' h from dual;
SELECT '<h3>Slowest SQL Statements and I/O savings</h3><pre>' from dual;  
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
SELECT '</pre><h3>Most executed SQL Statements and I/O savings</h3><pre>' from dual;  
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
where IO_CELL_OFFLOAD_ELIGIBLE_BYTES > 0
order by 5 desc)
where rownum < 11;

set heading off
SELECT '</pre><h3>Storage statistics</h3><pre>' from dual;  
set heading on
select s.name, m.value cell_stats
from v$mystat m, v$statname s
where s.statistic#=m.statistic#
and name like ('%storage%');

set heading off
SELECT '</pre><h3>Flash Hit</h3><pre>' from dual;  
set heading on
select s.name, m.value cell_stats
from v$mystat m, v$statname s
where s.statistic#=m.statistic#
and name like ('cell flash%');


set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
