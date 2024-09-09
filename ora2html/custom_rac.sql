REM Program:	custom_rac.sql
REM 		Oracle RAC PlugIn
REM Version:	1.0.2
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	14-FEB-13 mail@meo.bogliolo.name
REM		First version with Oracle RAC performance queries
rem X$KSXPIA in 10g; gv$cluster_interconnects in g11 reports interconnect only
rem latency can be checked with ping -s 8192 (or block size) and should be less than 1ms

column is_private format a8
column event format a64
column TIME_CATEGORY format a64
column OPERATION format a64
column avg_ms format 999.99
column logical_reads format 999,999,999,999,999
column gc_blocks_recieved format 999,999,999,999
column physical_reads format 999,999,999,999
column value format 999,999,999,999
column pct format 990.99
column total_waits format 999,999,999,999
column time_waited_secs format 999,999,999,999
column ip_address format a20
set lines 132

set heading off
select '<P><a id="custO"></a><a id="rac"></a><h2>Oracle RAC - Performance Statistics</h2>' h from dual;

SELECT '<h3>Instances</h3><pre>' from dual;  
set heading on
select distinct host_name, name "DB_NAME", db_unique_name, instance_name
  from gv$instance, gv$database;
set heading off

SELECT '</pre><h3>Cluster Interconnects</h3><pre>' from dual;  
set heading on
SELECT INST_ID, name, ip_address, is_public pub, source 
  FROM gv$configured_interconnects ORDER BY inst_id,name;
set heading off

SELECT '</pre><h3>Global Cache latency</h3> (should be less than 1/10th of disk access)<pre>' from dual;  
set heading on
SELECT event, SUM(total_waits) total_waits, ROUND(SUM(time_waited_micro) / 1000000, 2) time_waited_secs,
       ROUND(SUM(time_waited_micro)/1000 / SUM(total_waits), 2) avg_ms  FROM gv$system_event WHERE wait_class <> 'Idle' 
       AND( event LIKE 'gc%block%way'
     OR event LIKE 'gc%multi%'
    OR event like 'gc%grant%'
    OR event = 'db file sequential read') GROUP BY event HAVING SUM(total_waits) > 0 ORDER BY event;
set heading off

SELECT '</pre><h3>Cluster overhead</h3> (should be less than 10%)<pre>' from dual;  
set heading on
SELECT wait_class time_category ,ROUND ( (time_secs), 2) time_secs,
       ROUND ( (time_secs) * 100 / SUM (time_secs) OVER (), 2) pct
FROM (SELECT wait_class wait_class,
             sum(time_waited_micro) / 1000000 time_secs
        FROM gv$system_event
       WHERE wait_class <> 'Idle'
         AND time_waited > 0
       GROUP BY wait_class   
   UNION SELECT 'CPU', ROUND ((SUM(VALUE) / 1000000), 2) time_secs   
     FROM gv$sys_time_model
       WHERE stat_name IN ('background cpu time', 'DB CPU'))ORDER BY time_secs DESC;
set heading off

SELECT '</pre><h3>Temporary Tablespace Usage</h3> (should be paired between instances)<pre>' from dual;  
set heading on
select inst_id, tablespace_name, segment_file, total_blocks,
       used_blocks, free_blocks, max_used_blocks, max_sort_blocks 
  from gv$sort_segment; 

select inst_id, tablespace_name, blocks_used extent_block_used, blocks_cached 
  from gv$temp_extent_pool;
select inst_id, tablespace_name, blocks_used header_block_used, blocks_free 
  from gv$temp_space_header;
select inst_id, free_requests, freed_extents 
  from gv$sort_segment;
set heading off

SELECT '</pre><h3>Parallel query statistics</h3><pre>' from dual;  
set heading on
SELECT name operation, value from v$sysstat where name like 'Parallel operation%';
set heading off

SELECT '</pre><h3>Cluster balancing: CPU and Global Cache</h3> (should be paired between instances)<pre>' from dual;  
set heading on
WITH sys_time AS (
SELECT inst_id, SUM(CASE stat_name WHEN 'DB time'	
   THEN VALUE END) db_time, 
	SUM(CASE WHEN stat_name IN ('DB CPU', 'background cpu time') 
	   THEN VALUE END) cpu_time
 FROM gv$sys_time_model
 GROUP BY inst_id ) SELECT instance_name,
ROUND(db_time/1000000,2) db_time_secs, 
ROUND(db_time*100/SUM(db_time) over(),2) db_time_pct, 
ROUND(cpu_time/1000000,2) cpu_time_secs, 
ROUND(cpu_time*100/SUM(cpu_time) over(),2) cpu_time_pct
   FROM sys_time   JOIN gv$instance USING (inst_id);

WITH sysstats AS ( 
SELECT inst_id, SUM(CASE WHEN name LIKE 'gc%received' 
	    THEN VALUE END) gc_blocks_recieved, 
	SUM(CASE WHEN name = 'session logical reads' 
	    THEN VALUE END) logical_reads, 
	SUM(CASE WHEN name = 'physical reads' 
	    THEN VALUE END) physical_reads 
FROM gv$sysstat 
GROUP BY inst_id) SELECT instance_name, logical_reads, gc_blocks_recieved, physical_reads, 
ROUND(physical_reads*100/logical_reads,2) phys_to_logical_pct, 
ROUND(gc_blocks_recieved*100/logical_reads,2) gc_to_logical_pct   
FROM sysstats 
   JOIN gv$instance USING (inst_id);
set heading off

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
