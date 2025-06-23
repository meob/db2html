-- Program: ch2html.sql
-- Info:    ClickHouse report in HTML
--          Best with ClickHouse 19 or sup.
-- Date:    2018-02-14
-- Version: 1.0.12 on 2024-08-15
-- Author:  Bartolomeo Bogliolo (meo) mail@meo.bogliolo.name
-- License: Apache License 2.0
--
-- Notes:   
--          1.0.0 First version based on my2html (MySQL report in HTML) (2018-02-14)
--          1.0.1 Minor changes (eg. formatting, alignment)
--          1.0.2 Latest versions update, mutations
--          1.0.3 TOTAL for objects, space usage, ... added disks
--          1.0.4 Latest versions update, better formatting for dictionaries and replicas (2020-05-01)
--          1.0.5 Latest versions update (2021-01-01)
--          1.0.6 Latest versions update (2021-02-14). (a) Short table formatting, TTLs, version update
--          1.0.7 Latest versions update, Replication Queue (2021-08-15)
--          1.0.8 Latest versions update, ... (2021-12-31). (a) version update (2022-02-14) (b,c) latest versions update
--          1.0.9 Users and grants, detached parts, errors, latest versions update (a) latest versions update (b) minor updates
--          1.0.10 Latest versions update (2023-08-15)
--          1.0.11 Latest versions update (2024-02-14). (a) metric_log and asynchronous_metric_log statistics
--          1.0.12 Latest versions update (2024-08-15). (a) version update (b) version update, formatting
--
-- Usage: clickhouse-client -mn --ignore-error < ch2html.sql > `hostname`.8123.htm

use system;
select '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8" /><link rel="stylesheet" href="ux3.css" />' ;
select '<title>ClickHouse Statistics</title></head><body>' ;
select '<h1>ClickHouse Database</h1>' ;
select '<P><A NAME="top"></A>' ;
select '<p>Table of contents:' ;
select '<table><tr><td><ul>' ;
select '<li><A HREF="#status">Summary Status</A></li>' ;
select '<li><A HREF="#ver">Versions</A></li>' ;
select '<li><A HREF="#obj">Schema/Object Matrix</A></li>' ;
select '<li><A HREF="#usr">Users</A></li>' ;
select '<li><A HREF="#tbs">Space Usage</A></li>' ;
select '<li><A HREF="#part">Partitioning</A></li>' ;
select '<li><A HREF="#comp">Compression</A></li>' ;
select '<li><A HREF="#tune">Tuning Parameters</A> </li>' ;
select '<li><A HREF="#eng">Engines</A></li>' ;
select '</ul><td><ul>' ;
select '<li><A HREF="#prc">Threads</A></li>' ;
select '<li><A HREF="#stat">Performance Statistics</A></li>' ;
select '<li><A HREF="#big">Biggest Objects</A></li>' ;
select '<li><A HREF="#dict">Dictionary</A></li>' ;
select '<li><A HREF="#repl">Replication</A>' ;
select '  - <A HREF="#kfk">Kafka Consumers</A></li>' ;
select '<li><A HREF="#det">Details:</A>' ;
select '    <A HREF="#dbs">Databases</A>' ;
select '    <A HREF="#dspace">Space</A>' ;
select '    <A HREF="#ttl">TTL</A>' ;
select '    <A HREF="#dpart">Partitions</A>' ;
select '    <A HREF="#dpar">Parts</A>' ;
select '    <A HREF="#dcomp">Compression</A>' ;
select '    <A HREF="#dtype">Data types</A>' ;
select '<li><A HREF="#par">Configuration Parameters</A></li>' ;
select '<li><A HREF="#gstat">Global Status</A></li>' ;
select '<li><A HREF="#os">Operating System info</A></li>' ;
select '</ul></table><p><hr>' ;
 
select '<P>Statistics generated on: ', now();
select 'using: <I><b>ch2html.sh</b> v.1.0.12b';

select '<hr><P><A NAME="status"></A>';
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>';
select '<tr><td><b>Item</b>', '<td><b>Value</b>';
select '<tr><td>Version :', '<td>', version();
select '<tr><td>Created :', '<td>', min(metadata_modification_time)
  from system.tables
 where metadata_modification_time<>'0000-00-00 00:00:00';
select '<tr><td>Started :', '<td>', now()-uptime();
select '<tr><td>DB Size :', '<td align=right>',
       formatReadableSize(sum(bytes_on_disk))
  from system.parts;
select '<tr><td>Max Memory (Configured/Used) :', '<td align="right">',
       formatReadableSize(toInt64(value)), ' / '
  from system.settings
 where name='max_memory_usage';
select formatReadableSize(max(memory_usage))
  from system.query_log
 where type=2
   and event_time > now() - interval 7 day;
select '<tr><td>Logged Users :', '<td align=right>', count(distinct initial_user)
  from system.query_log where event_time > now() - interval 7 day;
select '<tr><td>Defined Schemata :', '<td align="right">', count()
  from system.databases;
select '<tr><td>Defined Tables :', '<td align=right>',count()
  from system.tables;
select '<tr><td>Sessions (TCP/HTTP/Replica):', '<td align=right>', value, ' / '
  from system.metrics
 where metric='TCPConnection';
select value, ' / '
  from system.metrics
 where metric='HTTPConnection';
select value
  from system.metrics
 where metric='InterserverConnection';
select '<tr><td>Sessions (active) :', '<td align="right">', count()
  from system.processes;
select '<tr><td>Query (#/hour) :', '<td align=right>', round(count(*)/24,5)
  from system.query_log
 where event_time > now() - interval 1 day;
select '<tr><td>Merges/Day (Unc. bytes) :', '<td align=right>', formatReadableSize(value/uptime()*60*60*24)
  from system.events
 where event = 'MergedUncompressedBytes';
select '<tr><td>Hostname :', '<td>', hostName();
select '</table><p><hr>' ;

select '<P><A NAME="ver"></A>';
select '<P><table border="2"><tr><td><b>Version check</b></td></tr>' ;
select '<tr><td><b>Version</b>',
 '<td><b> Current year release </b>',
 '<td><b> Recent releases </b>',
 '<td><b> Notes</b>';
select '<tr><td>', version();
select '<td>', if(value>=25000000,'Yes','No')
  from system.metrics
 where metric='VersionInteger';
select '<td>', if(value>=24000000,'Yes','No')
  from system.metrics
 where metric='VersionInteger';
select '<td>Latest Releases: 25.4.1.2934, 25.3.3.42-lts, 24.8.14.39-lts, 24.3.18.7-lts; 23.8.16.40−lts, 23.3.22.3−lts, 22.8.21.38-lts, 22.3.20.29−lts, 21.8.15.7-lts';
select '</table><p>' ;

select '<P><A NAME="obj"></A>' ;
select '<P><table border="2"><tr><td><b>Schema/Object Matrix</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b> Tables</b>',
 '<td><b> Columns</b>',
 '<td><b> Partitions</b>',
 '<td><b> Parts</b>',
 '<td><b> Replicas</b>',
 '<td><b> Dictionaries</b>',
 '<td><b> All</b>' ;
select '<tr><td>', sk,
	'<td align=right>', sum(if(otype='T',1,0)),
	'<td align=right>', sum(if(otype='C',1,0)),
	'<td align=right>', sum(if(otype='A',1,0)),
	'<td align=right>', sum(if(otype='P',1,0)),
	'<td align=right>', sum(if(otype='R',1,0)),
	'<td align=right>', sum(if(otype='D',1,0)),
	'<td align=right>', count(*)
from ( select 'T' otype, database sk, name
  from system.tables
  union all
 select 'C' otype, database sk, concat(table,'.',name) name
  from system.columns
  union all
 select distinct 'A' otype, database sk, concat(table,'.',partition) name
  from system.parts
  union all
 select 'P' otype, database sk, concat(table,'.',name) name
  from system.parts
  union all
 select 'R' otype, database sk, table name
  from system.replicas
  union all
 select 'D' otype, database sk, name
  from system.dictionaries
     ) a
group by sk
order by sk;
select '<tr><td>TOTAL',
	'<td align=right>', sum(if(otype='T',1,0)),
	'<td align=right>', sum(if(otype='C',1,0)),
	'<td align=right>', sum(if(otype='A',1,0)),
	'<td align=right>', sum(if(otype='P',1,0)),
	'<td align=right>', sum(if(otype='R',1,0)),
	'<td align=right>', sum(if(otype='D',1,0)),
	'<td align=right>', count(*)
from ( select 'T' otype, database sk, name
  from system.tables
  union all
 select 'C' otype, database sk, concat(table,'.',name) name
  from system.columns
  union all
 select distinct 'A' otype, database sk, concat(table,'.',partition) name
  from system.parts
  union all
 select 'P' otype, database sk, concat(table,'.',name) name
  from system.parts
  union all
 select 'R' otype, database sk, table name
  from system.replicas
  union all
 select 'D' otype, database sk, name
  from system.dictionaries
     ) a;
select '</table><p>' ;


select '<P><A NAME="eng"></A>' ;
select '<P><table border="2"><tr><td><b>Schema/Engine Matrix</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b> MergeTree</b>',
 '<td><b> Aggr.MergeTree </b>',
 '<td><b> Sum.MergeTree </b>',
 '<td><b> Repl.MergeTree </b>',
 '<td><b> Coll.MergeTree </b>',
 '<td><b> Ver.Collap. </b>',
 '<td><b> Log* </b>',
 '<td><b> Replicated* </b>',
 '<td><b> Distributed* </b>',
 '<td><b> View </b>',
 '<td><b> MaterializedView </b>',
 '<td><b> Dictionary </b>',
 '<td><b> Memory </b>',
 '<td><b> Kafka </b>',
 '<td><b> System* </b>',
 '<td><b> All</b>' ;
select '<tr><td>', database,
	'<td align=right>', sum(if(engine='MergeTree',1,0)),
	'<td align=right>', sum(if(engine='AggregatingMergeTree',1,0)),
	'<td align=right>', sum(if(engine='SummingMergeTree',1,0)),
	'<td align=right>', sum(if(engine='ReplacingMergeTree',1,0)),
	'<td align=right>', sum(if(engine='CollapsingMergeTree',1,0)),
	'<td align=right>', sum(if(engine='VersionedCollapsingMergeTree',1,0)),
	'<td align=right>', sum(if(engine like '%Log',1,0)),
	'<td align=right>', sum(if(engine like 'Replicated%',1,0)),
	'<td align=right>', sum(if(engine like 'Distributed%',1,0)),
	'<td align=right>', sum(if(engine='View',1,0)),
	'<td align=right>', sum(if(engine='MaterializedView',1,0)),
	'<td align=right>', sum(if(engine='Dictionary',1,0)),
	'<td align=right>', sum(if(engine='Memory',1,0)),
	'<td align=right>', sum(if(engine='Kafka',1,0)),
	'<td align=right>', sum(if(engine like 'System%',1,0)),
	'<td align=right>', count(*)
  from system.tables
 group by database
 order by database;
select '<tr><td>TOTAL',
	'<td align=right>', sum(if(engine='MergeTree',1,0)),
	'<td align=right>', sum(if(engine='AggregatingMergeTree',1,0)),
	'<td align=right>', sum(if(engine='SummingMergeTree',1,0)),
	'<td align=right>', sum(if(engine='ReplacingMergeTree',1,0)),
	'<td align=right>', sum(if(engine='CollapsingMergeTree',1,0)),
	'<td align=right>', sum(if(engine='VersionedCollapsingMergeTree',1,0)),
	'<td align=right>', sum(if(engine like '%Log',1,0)),
	'<td align=right>', sum(if(engine like 'Replicated%',1,0)),
	'<td align=right>', sum(if(engine like 'Distributed%',1,0)),
	'<td align=right>', sum(if(engine='View',1,0)),
	'<td align=right>', sum(if(engine='MaterializedView',1,0)),
	'<td align=right>', sum(if(engine='Dictionary',1,0)),
	'<td align=right>', sum(if(engine='Memory',1,0)),
	'<td align=right>', sum(if(engine='Kafka',1,0)),
	'<td align=right>', sum(if(engine like 'System%',1,0)),
	'<td align=right>', count(*)
  from system.tables;
select '</table><p><hr>' ;


select '<P><A NAME="usr"></A>' ;
select '<P><table border="2"><tr><td><b>Users</b></td></tr>' ;

select '<P><table border="2"><tr><td><b>User list</b></td></tr>' ;
select '<tr><td><b>Name',
 '<td><b>Auth_type</b>',
 '<td><b>Host</b>',
 '<td><b>Default Roles</b>',
 '<td><b>Storage</b>';
select '<tr><td>',name, 
       '<td>', auth_type,
       '<td>', host_ip, host_names, host_names_regexp, host_names_like,
       '<td>', default_roles_all, default_roles_list, default_roles_except,
       '<td>', storage
 from system.users;
select '<tr><td>',name, 
       '<td>', 'ROLE',
       '<td>', 
       '<td>', 
       '<td>', storage
 from system.roles;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>User directories</b></td></tr>' ;
select '<tr><td><b>Name',
 '<td><b>Type</b>',
 '<td><b>Parameters</b>',
 '<td><b>Precedence</b>';
select '<tr><td>',name, 
       '<td>', type,
       '<td>', params,
       '<td align=right>', precedence
 from system.user_directories
 order by precedence;
select '</table><p>' ;

select '<P><pre><table border="2"><tr><td><b>Grants</b></td></tr>' ;
select '<tr><td><b>User/Role name',
 '<td><b>Access type</b>',
 '<td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Column</b>',
 '<td><b>Partial revoke</b>',
 '<td><b>Grant option</b>';
select '<tr><td>',coalesce(user_name,''), coalesce(role_name,''),
       '<td>', access_type,
       '<td>', coalesce(database,''),
       '<td>', coalesce(table,''),
       '<td>', coalesce(column,''),
       '<td>', is_partial_revoke,
       '<td>', grant_option
 from system.grants;
select '</table></pre><p><br>' ;


select '<P><A NAME="tbs"></A>' ;
select '<P><table border="2"><tr><td><b>Space Usage</b></td></tr>' ;
select '<tr><td><b>Database',
 '<td><b>Row#</b>',
 '<td><b>Size</b>',
 '<td><b>Size HR</b>',
 '<td><b>Data compressed</b>',
 '<td><b>Data uncompressed</b>';
SELECT '<tr><td>',database, '<td align=right>', sum(rows),
       '<td align=right>', sum(bytes_on_disk),
       '<td align=right>', formatReadableSize(sum(bytes_on_disk)),
       '<td align=right>', formatReadableSize(sum(data_compressed_bytes)), 
       '<td align=right>', formatReadableSize(sum(data_uncompressed_bytes))
  FROM system.parts
 GROUP BY database
 ORDER BY database;
SELECT '<tr><td>TOTAL', '<td align=right>', sum(rows),
       '<td align=right>', sum(bytes_on_disk),
       '<td align=right>', formatReadableSize(sum(bytes_on_disk)),
       '<td align=right>', formatReadableSize(sum(data_compressed_bytes)), 
       '<td align=right>', formatReadableSize(sum(data_uncompressed_bytes))
  FROM system.parts;
select '</table><p>' ;

select '<P><A NAME="disk"></A>' ;
select '<P><table border="2"><tr><td><b>Disks</b></td></tr>' ;
select '<tr><td><b>Name',
 '<td><b>Path</b>',
 '<td><b>Total HR</b>',
 '<td><b>Free HR</b>',
 '<td><b>Used HR</b>',
 '<td><b>Total space</b>',
 '<td><b>Free space</b>',
 '<td><b>Used space</b>';
SELECT '<tr><td>',name, '<td>', path,
       '<td align=right>', formatReadableSize(total_space),
       '<td align=right>', formatReadableSize(free_space),
       '<td align=right>', formatReadableSize(total_space-free_space),
       '<td align=right>', total_space, 
       '<td align=right>', free_space, 
       '<td align=right>', total_space-free_space
  FROM system.disks;
SELECT '<tr><td>TOTAL', '<td>', 
       '<td align=right>', formatReadableSize(sum(total_space)),
       '<td align=right>', formatReadableSize(sum(free_space)),
       '<td align=right>', formatReadableSize(sum(total_space-free_space)),
       '<td align=right>', sum(total_space), 
       '<td align=right>', sum(free_space), 
       '<td align=right>', sum(total_space-free_space)
  FROM system.disks;
select '</table><p>' ;

select '<P><A NAME="part"></A>' ;
select '<P><table border="2"><tr><td><b>Partitioning</b></td></tr>';
select '<tr><td><b>Database</b>',
 '<td><b># Tables</b>',
 '<td><b># Partitions</b>',
 '<td><b>Min Partition</b>',
 '<td><b>Max Partition</b>',
 '<td><b># Parts</b>',
 '<td><b># Active</b>',
 '<td><b>Size HR</b>',
 '<td><b>Size</b>';
SELECT '<tr><td>',database, '<td align="right">',count(distinct table),
       '<td align="right">',count(distinct partition),
       '<td align="right">',minIf(partition, partition <>'tuple()'),
       '<td align="right">',maxIf(partition, partition <>'tuple()'),
       '<td align="right">',count(distinct name),
       '<td align="right">',sum(active),
       '<td align="right">',formatReadableSize(sum(bytes_on_disk)),
       '<td align="right">',sum(bytes_on_disk)
  FROM system.parts
 GROUP BY database
 ORDER BY database;

SELECT '<tr><td>TOTAL', '<td align="right">',count(distinct table),
       '<td align="right">',count(distinct partition),
       '<td align="right">',minIf(partition, partition <>'tuple()'),
       '<td align="right">',maxIf(partition, partition <>'tuple()'),
       '<td align="right">',count(distinct name),
       '<td align="right">',sum(active),
       '<td align="right">',formatReadableSize(sum(bytes_on_disk)),
       '<td align="right">',sum(bytes_on_disk)
  FROM system.parts;
select '</table><p>';

select '<P><A NAME="comp"></A>' ;
select '<P><table border="2"><tr><td><b>Compression</b></td></tr>';
select '<tr><td><b>Database</b>',
 '<td><b># Table</b>',
 '<td><b># Column</b>',
 '<td><b># Type</b>',
 '<td><b> Size compressed HR</b>',
 '<td><b> Size compressed</b>',
 '<td><b>Size uncompressed</b>',
 '<td><b>Gain %</b>';
SELECT '<tr><td>',database, '<td>',count(distinct table), '<td>',count(distinct column), '<td>',count(distinct type),
       '<td align=right>',formatReadableSize(sum(column_data_compressed_bytes)) compressed_hr,
       '<td align=right>',sum(column_data_compressed_bytes) compressed,
       '<td align=right>',sum(column_data_uncompressed_bytes) uncompressed,
       '<td align=right>',round( (sum(column_data_uncompressed_bytes)-sum(column_data_compressed_bytes))*100/sum(column_data_uncompressed_bytes), 2)
  FROM system.parts_columns
 WHERE active
 GROUP BY database
 ORDER BY database;
SELECT '<tr><td>','TOTAL', '<td>',count(distinct table), '<td>',count(distinct column), '<td>',count(distinct type),
       '<td align=right>',formatReadableSize(sum(column_data_compressed_bytes)) compressed_hr,
       '<td align=right>',sum(column_data_compressed_bytes) compressed,
       '<td align=right>',sum(column_data_uncompressed_bytes) uncompressed,
       '<td align=right>',round( (sum(column_data_uncompressed_bytes)-sum(column_data_compressed_bytes))*100/sum(column_data_uncompressed_bytes), 2)
  FROM system.parts_columns
 WHERE active;
select '</table><p><hr>';

select '<P><A NAME="tune"></A>' ;
select '<P><table border="2"><tr><td><b>Top Tuning Parameters</b></td></tr>';
select '<tr><td><b>Parameter</b>', '<td><b>Value</b>';
select '<tr><td>',name, '<td>',value
  from system.settings
 WHERE changed != 0
    OR name in ('max_memory_usage', 'max_memory_usage_for_all_queries', 'max_memory_usage_for_user',
         'max_bytes_before_external_group_by', 'max_bytes_before_external_sort',
         'max_bytes_before_remerge_sort')
 order by name;
select '</table><p>' ;

select '<P><A NAME="sga"></A>' ;
select '<P><table border="2"><tr><td><b>Max Memory Usage </b><td>(last week)';
select '<tr><td><b>User</b>','<td><b>Host</b>',
       '<td><b>Client</b>','<td><b>Start</b>','<td><b>Duration</b>','<td><b>Memory</b>','<td><b>Type</b>',
       '<td><b>Query</b>';
SELECT '<tr><td>',user, '<td>',client_hostname AS host, '<td>',client_name AS client,
       '<td>',query_start_time AS started, '<td>',query_duration_ms/1000 AS sec,
       '<td align=right>', formatReadableSize(memory_usage) AS MEM, '<td>',type,
       '<td class="split">', replace(replace(query,'<','&lt;'), '>','&gt;') query
  FROM system.query_log
 WHERE memory_usage<>0
   and event_time > now() - interval 7 day
 ORDER BY memory_usage DESC
 LIMIT 5 BY type;
select '</table><p><hr>';

select '<P><A NAME="prc"></A>' ;
select '<P><table border="2"><tr><td><b>Sessions</b></td></tr>' ;
select '<tr><td><b>Type</b> <td><b>Count</b>';
select '<tr><td>TCP (clickhouse-client and native connections)', '<td>', value
  from system.metrics
 where metric='TCPConnection';
select '<tr><td>HTTP (drivers and programs)', '<td>', value
  from system.metrics
 where metric='HTTPConnection';
select '<tr><td>Interserver (replica and cluster)', '<td>', value
  from system.metrics
 where metric='InterserverConnection';
select '</table><p>' ;

select '<P><A NAME="run"></A>' ;
select '<P><table border="2"><tr><td><b>Active Sessions</b></td></tr>' ;
select '<tr><td><b>Id</b><td><b>User</b><td><b>Host</b>';
select '<td><b>Elapsed</b><td><b>Command</b>';
select '<tr><td>',query_id,
	'<td>', user,
	'<td>', address,
	'<td>', elapsed,
	'<td class="split">', substring(replace(replace(query,'<','&lt;'), '>','&gt;'),1,1024) queryHideMe
  from system.processes
 where query not like ('% queryHideMe%')
 order by query_id;
select '</table><p>' ;

select '<P><A NAME="stat"></A>' ;
select '<a id="sqls"></a><P><table border="2"><tr><td><b>Latest SQL Statements</b></td>' ;
select '<tr><td><b>User</b>','<td><b>Host</b>',
       '<td><b>Client</b>','<td><b>Start</b>','<td><b>Duration</b>','<td><b>Mem MB</b>',
       '<td><b>Rows</b>','<td><b>Result MB</b>','<td><b>Rows Examined</b>',
       '<td><b>Read MB</b>','<td><b>Written rows</b>',
       '<td><b>Written MB</b>','<td><b>Query</b>';
SELECT '<tr><td>',user, '<td>',client_hostname AS host, '<td>',client_name AS client,
       '<td>',query_start_time AS started, '<td align=right>',query_duration_ms/1000 AS sec,
       '<td align=right>',round(memory_usage/1048576) AS MEM_MB, '<td align=right>',result_rows AS RES_CNT,
       '<td align=right>',toDecimal64(result_bytes/1048576, 6) AS RES_MB, '<td align=right>',read_rows AS R_CNT,
       '<td align=right>',round(read_bytes/1048576) AS R_MB, '<td align=right>',written_rows AS W_CNT,
       '<td align=right>',round(written_bytes/1048576) AS W_MB,
       '<td class="split">', replace(replace(query,'<','&lt;'), '>','&gt;') query
  FROM system.query_log
 WHERE user <> 'my2'
   AND user <> user()
   and event_time > now() - interval 1 day
 ORDER BY query_start_time DESC
 LIMIT 20;
select '</table><p>';

-- Requires CH 21.8
select '<P><table border="2"><tr><td><b>Last day metrics</b></td>' ;
select '<tr><td><b>Time</b>','<td><b>Query/sec</b>',
       '<td><b>Running Query</b>','<td><b>Running Merge</b>','<td><b>Selected bytes</b>',       
       '<td><b>Memory (tracked)</b>',
       '<td><b>Selected row/sec</b>','<td><b>Inserted row/sec</b>',
       '<td><b>CPU (cores)</b>','<td><b>CPU wait</b>','<td><b>IO wait</b>',
       '<td><b>Disk read</b>','<td><b>FS read</b>';
SELECT '<tr><td>',toStartOfInterval(event_time, INTERVAL 3600 SECOND) AS t,
       '<td align="right">',round(avg(ProfileEvent_Query),2) as Query_sec,
       '<td align="right">',round(avg(CurrentMetric_Query),2) as Running_query,
       '<td align="right">',round(avg(CurrentMetric_Merge),2) as Running_merge,
       '<td align="right">',round(avg(ProfileEvent_SelectedBytes),2) as Selected_bytes,
       '<td align="right">',round(avg(CurrentMetric_MemoryTracking),2) as memory_track,
       '<td align="right">',round(avg(ProfileEvent_SelectedRows),2) as row_sel_sec,
       '<td align="right">',round(avg(ProfileEvent_InsertedRows),2) as row_ins_sec,
       '<td align="right">',round(avg(ProfileEvent_OSCPUVirtualTimeMicroseconds) / 1000000,1) as CPU,
       '<td align="right">',round(avg(ProfileEvent_OSCPUWaitMicroseconds) / 1000000,2) as CPU_wait,
       '<td align="right">',round(avg(ProfileEvent_OSIOWaitMicroseconds) / 1000000,2) as IO_wait,
       '<td align="right">',round(avg(ProfileEvent_OSReadBytes),2) as disk_read,
       '<td align="right">',round(avg(ProfileEvent_OSReadChars),2) as FS_read
  FROM system.metric_log
 WHERE event_date >= toDate(now() - 86400) AND event_time >= now() - 86400
 GROUP BY t
 ORDER BY t WITH FILL STEP 3600;
select '</table><p>';

-- Load Average (15 minutes): Last day/hour, Last month/day
select '<P><table><tr>' ;
select '<td><P><table border="2"><tr><td><b>Last month LA<td>by day' ;
select '<tr><td><b>Time</b>','<td><b>OS Load Average (15 minutes)</b>';
SELECT '<tr><td>', toStartOfInterval(event_time, INTERVAL 3600*24 SECOND) AS t,
       '<td align="right">',round(avg(value),2) as load_avg
  FROM system.asynchronous_metric_log
 WHERE event_date >= toDate(now() - 3600*24*31) AND event_time >= now() - 3600*24*31
   AND metric = 'LoadAverage15'
 GROUP BY t
 ORDER BY t WITH FILL STEP 3600*24;
select '</table>';
select '<td><P><table border="2"><tr><td><b>Last day LA</b><td>by hour' ;
select '<tr><td><b>Time</b>','<td><b>OS Load Average (15 minutes)</b>';
SELECT '<tr><td>', toStartOfInterval(event_time, INTERVAL 3600 SECOND) AS t,
       '<td align="right">',round(avg(value),2) as load_avg
  FROM system.asynchronous_metric_log
 WHERE event_date >= toDate(now() - 3600*24) AND event_time >= now() - 3600*24
   AND metric = 'LoadAverage15'
 GROUP BY t
 ORDER BY t WITH FILL STEP 3600;
select '</table>';
select '</table>';

select '<table border="2"><tr><td><b>Connection High Water mark</b>' ;
select '<tr><td><b>TCP</b>','<td><b>HTTP</b>','<td><b>Interserver</b>';
select '<tr><td>',max(CurrentMetric_TCPConnection),
       '<td>',max(CurrentMetric_HTTPConnection), 
       '<td>',max(CurrentMetric_InterserverConnection)
  from system.metric_log;
select '</table>';

select '</table><p><a id="top_users"></a><p><table border="2"><tr><td><b>User activities (last week)</b>' ;
select '<tr><td><b>User</b>', '<td><b>#Query</b>', '<td><b>Total Duration</b>', '<td><b>Agv. Duration</b>', '<td><b>#Error</b>';
select '<tr><td>',user, '<td align=right>',count(*), '<td align=right>',round(sum(query_duration_ms)/1000),
       '<td align=right>',round(sum(query_duration_ms)/1000/count(*),3),
       '<td align=right>',countIf(exception <> '')
  from system.query_log 
 where  event_time > now() - interval 7 day
 group by user
 order by user;
select '<tr><td>TOTAL', '<td align=right>',count(*), '<td align=right>',round(sum(query_duration_ms)/1000),
       '<td align=right>',round(sum(query_duration_ms)/1000/count(*),3),
       '<td align=right>',countIf(exception <> '')
  from system.query_log 
 where  event_time > now() - interval 7 day;
select '</table><p>';

select '<P><table border="2"><tr><td><b>Active Merges</b></td></tr>';
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Part</b>',
 '<td><b>Progress</b>',
 '<td><b> Elapsed </b>',
 '<td><b>Parts#</b>';
SELECT '<tr><td>',database, '<td>', table,'<td>',result_part_name,
       '<td align=right>', progress,
       '<td>', elapsed, 
       '<td align=right>', num_parts
  FROM system.merges;
select '</table><p>' ;

select '<P><div class="short"><a id="mutations"></a><table border="2"><tr><td><b>Mutations</b></td></tr>';
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Mutation ID</b>',
 '<td><b>Command</b>',
 '<td><b>Time</b>',
 '<td><b>Done</b>',
 '<td><b>Parts to do</b>',
 '<td><b>Fail Reason</b>';
SELECT '<tr><td>',database, '<td>', table,'<td>',mutation_id,
       '<td>', command, '<td>', create_time,
       '<td align=right>', is_done, 
       '<td align=right>', parts_to_do,
       '<td>', latest_fail_reason
  FROM system.mutations
 ORDER BY is_done, create_time desc
 LIMIT 20;
select '</table></div><p><hr>' ;


select '<p><div class="short"><a id="sqlslow"></a><p><table border="2"><tr><td><b>Slowest Statements</b> <td>(last week)' ;
select '<tr><td><b>User</b>','<td><b>Host</b>',
       '<td><b>Client</b>','<td><b>Start</b>','<td><b>Duration</b>','<td><b>Mem MB</b>',
       '<td><b>Rows</b>','<td><b>Result MB</b>','<td><b>Rows Examined</b>',
       '<td><b>Read MB</b>','<td><b>Written rows</b>',
       '<td><b>Written MB</b>','<td><b>Query</b>';
SELECT '<tr><td>',user, '<td>',client_hostname AS host, '<td>',client_name AS client,
       '<td>',query_start_time AS started, '<td align=right>',query_duration_ms/1000 AS sec,
       '<td align=right>',round(memory_usage/1048576) AS MEM_MB, '<td align=right>',result_rows AS RES_CNT,
       '<td align=right>',toDecimal64(result_bytes/1048576, 6) AS RES_MB, '<td align=right>',read_rows AS R_CNT,
       '<td align=right>',round(read_bytes/1048576) AS R_MB, '<td align=right>',written_rows AS W_CNT,
       '<td align=right>',round(written_bytes/1048576) AS W_MB,
       '<td class="split">', replace(replace(query,'<','&lt;'), '>','&gt;') query
  FROM system.query_log
 where event_time > now() - interval 7 day
 ORDER BY query_duration_ms DESC
 LIMIT 20;
select '</table></div><p>';

select '<p><div class="short"><a id="sqlerr"></a><p><table border="2"><tr><td><b>Recent Errors</b> <td> (last 24h)' ;
select '<tr><td><b>User</b>','<td><b>Host</b>',
       '<td><b>Client</b>','<td><b>Start</b>','<td><b>Duration</b>','<td><b>Mem MB</b>',
       '<td><b>Rows</b>','<td><b>Query</b>','<td><b>Exception</b>';
SELECT '<tr><td>',user, '<td>',client_hostname AS host, '<td>',client_name AS client,
       '<td>',query_start_time AS started, '<td align=right>',query_duration_ms/1000 AS sec,
       '<td align=right>',round(memory_usage/1048576) AS MEM_MB, '<td align=right>',result_rows AS RES_CNT,
       '<td class="split">', replace(replace(query,'<','&lt;'), '>','&gt;') query,
       '<td>', replace(replace(exception,'<','&lt;'), '>','&gt;') exception
  FROM system.query_log
 WHERE exception <> ''
   AND user <> 'haproxy'
   and event_time > now() - interval 1 day
 ORDER BY query_start_time DESC
 LIMIT 20;
select '</table></div><p>';

select '<p><div class="short"><a id="sqlslowu"></a><p><table border="2"><tr><td><b>Recent Slow Queries</b> <td>(24h,&nbsp;3&nbsp;by&nbsp;user)' ;
select '<tr><td><b>User</b>','<td><b>Host</b>',
       '<td><b>Client</b>','<td><b>Start</b>','<td><b>Duration</b>','<td><b>Mem MB</b>',
       '<td><b>Rows</b>','<td><b>Result MB</b>','<td><b>Rows Examined</b>',
       '<td><b>Read MB</b>','<td><b>Written rows</b>',
       '<td><b>Written MB</b>','<td><b>Query</b>';
select *
 from (SELECT '<tr><td>',user, '<td>',client_hostname AS host, '<td>' td2,client_name AS client,
       '<td>' td3,query_start_time AS started, '<td align=right>',query_duration_ms/1000 AS sec,
       '<td align=right>' td5,round(memory_usage/1048576) AS MEM_MB, '<td align=right>' td6,result_rows AS RES_CNT,
       '<td align=right>' td7,toDecimal64(result_bytes/1048576, 6) AS RES_MB, '<td align=right>' td8,read_rows AS R_CNT,
       '<td align=right>' td9,round(read_bytes/1048576) AS R_MB, '<td align=right>' td10,written_rows AS W_CNT,
       '<td align=right>' td11,round(written_bytes/1048576) AS W_MB,
       '<td class="split">' td12, substring(replace(replace(query,'<','&lt;'), '>','&gt;'),1,500) query
  FROM system.query_log
 WHERE type=2
   AND user <> 'my2'
   AND event_time > now() - interval 1 day
 ORDER BY query_duration_ms DESC
 LIMIT 3 BY user)
order by user, sec DESC;
select '</table></div><p>';

select '<p><div class="short"><a id="sqlerr"></a><p><table border="2"><tr><td><b>Recent Errors</b> <td>(3 by&nbsp;user)' ;
select '<tr><td><b>User</b>','<td><b>Host</b>',
       '<td><b>Client</b>','<td><b>Start</b>','<td><b>Duration</b>','<td><b>Mem MB</b>',
       '<td><b>Rows</b>','<td><b>Query</b>','<td><b>Exception</b>';
select *
 from (SELECT '<tr><td>' td1,user, '<td>' td2,client_hostname AS host, '<td>' td3,client_name AS client,
       '<td>' td4, query_start_time AS started, '<td align=right>' td5, query_duration_ms/1000 AS sec,
       '<td align=right>' td6,round(memory_usage/1048576) AS MEM_MB, '<td align=right>' td7,result_rows AS RES_CNT,
       '<td class="split">' td8, substring(replace(replace(query,'<','&lt;'), '>','&gt;'), 1, 500) query,
       '<td>' td9, replace(replace(exception,'<','&lt;'), '>','&gt;') exception
  FROM system.query_log
 WHERE exception <> ''
   AND event_time > now() - interval 1 day
 ORDER BY query_start_time DESC
 LIMIT 3 BY user)
order by user, started DESC;
select '</table></div><p><hr>';

select '<P><A NAME="big"></A>' ;
select '<P><table border="2"><tr><td><b>Biggest Objects</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Engine</b>',
 '<td><b>Rows</b>',
 '<td><b>Size HR</b>',
 '<td><b>Size (bytes)</b>',
 '<td><b>Size (uncompressed)</b>';
SELECT '<tr><td>',database, '<td>', table, '<td>', any(engine),
       '<td align=right>', sum(rows),
       '<td align=right>', formatReadableSize(sum(bytes_on_disk)),
       '<td align=right>', sum(bytes_on_disk),
       '<td align=right>', formatReadableSize(sum(data_uncompressed_bytes))
  FROM system.parts
 GROUP BY database, table
 ORDER BY sum(bytes_on_disk) desc
 LIMIT 32;
select '</table><p><hr>' ;

select '<P><A NAME="dict"></A>' ;
select '<P><table border="2"><tr><td><b>Dictionaries</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Name</b>',
 '<td><b>Status</b>',
 '<td><b>Source</b>',
 '<td><b> Attributes </b>',
 '<td><b>Rows</b>',
 '<td><b>Bytes</b>',
 '<td><b> Lifetime </b>',
 '<td><b>Last update</b>',
 '<td><b>Duration</b>',
 '<td><b>Last exception</b>';
SELECT '<tr><td>',database, '<td>', name, '<td>', status,
       '<td>', source, '<td>', attribute.names,
       '<td align=right>', element_count,
       '<td align=right>', bytes_allocated,
       '<td align=right>', lifetime_min, ' - ',lifetime_max,
       '<td>', last_successful_update_time,
       '<td>', loading_duration,
       '<td>', last_exception
  FROM system.dictionaries
 ORDER BY last_successful_update_time desc;
select '</table><p><hr>' ;

select '<P><A NAME="clu"></A>' ;
select '<P><table border="2"><tr><td><b>Cluster configuration</b></td></tr>' ;
select '<tr><td><b>Cluster</b>',
 '<td><b>Shard#</b>',
 '<td><b>Shard weight</b>',
 '<td><b>Replica#</b>',
 '<td><b>Hostname</b>',
 '<td><b>Address</b>',
 '<td><b>Port</b>',
 '<td><b>Local</b>',
 '<td><b>User</b>',
 '<td><b>Default database</b>';
SELECT '<tr><td>',cluster, '<td align=right>', shard_num, '<td>',shard_weight,
       '<td align=right>', replica_num,
       '<td>', host_name,
       '<td>', host_address,
       '<td>', port,
       '<td>', is_local,
       '<td>', user,
       '<td>', default_database
  FROM system.clusters;
select '</table><p>' ;

select '<P><A NAME="repl"></A>' ;
select '<P><table border="2"><tr><td><b>Replication</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Engine</b>',
 '<td><b>Replicas</b>',
 '<td><b> Leader </b>',
 '<td><b>RO</b>',
 '<td><b> Expired </b>',
 '<td><b>Future p.</b>',
 '<td><b>Check p.</b>',
 '<td><b>Insert queue</b>',
 '<td><b>Log index</b>',
 '<td><b>Log pointer</b>',
 '<td><b>Queue size</b>',
 '<td><b>Active replicas</b>',
 '<td><b>Queue oldest time</b>',
 '<td><b>Insert oldest time</b>',
 '<td><b>Last update</b>';
SELECT '<tr><td>',database, '<td>', table, '<td>', engine,
       '<td>', total_replicas,
       '<td>', is_leader, '<td>', is_readonly,
       '<td>', is_session_expired,
       '<td align=right>', future_parts,
       '<td align=right>', parts_to_check,
       '<td align=right>', inserts_in_queue,
       '<td align=right>', log_max_index,
       '<td align=right>', log_pointer,
       '<td align=right>', queue_size,
       '<td align=right>', active_replicas,
       '<td>', queue_oldest_time,
       '<td>', inserts_oldest_time,
       '<td>', last_queue_update
  FROM system.replicas;
select '</table><p>' ;

select '<P><A NAME="replq"></A>' ;
select '<P><table border="2"><tr><td><b>Replication Queue</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Replica Name</b>',
 '<td><b>Position</b>',
 '<td><b>Node Name</b>',
 '<td><b>Type</b>',
 '<td><b>Create Time</b>',
 '<td><b>Required Quorum</b>',
 '<td><b>Source</b>',
 '<td><b>New Part Name</b>',
 '<td><b>Parts to Merge</b>',
 '<td><b>Is Detach</b>',
 '<td><b>In Exec</b>',
 '<td><b># Tries</b>',
 '<td><b>Last Exception</b>',
 '<td><b>Last Attempt</b>',
 '<td><b># Postponed</b>',
 '<td><b>Postpone Reason</b>',
 '<td><b>Last Postpone Time</b>';

select '<tr><td>',database, '<td>',table, '<td>',replica_name,
       '<td>',position, '<td>',node_name, '<td>',type, '<td>',create_time, '<td>',required_quorum,
       '<td>',source_replica, '<td>',new_part_name, '<td>',parts_to_merge, '<td>',is_detach,
       '<td>',is_currently_executing, '<td>',num_tries, '<td>',last_exception,
       '<td>',last_attempt_time, '<td>',num_postponed, '<td>',postpone_reason, '<td>',last_postpone_time
  from system.replication_queue
 order by is_currently_executing desc, create_time;
select '</table><p><hr>' ;

select '<P><A NAME="kfk"></A>' ;
select '<P><table border="2"><tr><td><b>Kafka Objects</b></td></tr>' ;
select '<tr><td><b>Database</b>', '<td><b>#Objects</b>' ;
select '<tr><td>', database,
	'<td align=right>', count(*)
  from system.tables
 where engine='Kafka'
 group by database
 order by database;
select '<tr><td>TOTAL', '<td align=right>', count(*)
  from system.tables
 where engine='Kafka';
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Kafka Consumers</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Topic</b>',
 '<td><b>Commits</b>',
 '<td><b>Messages</b>',
 '<td><b>Last commit</b>',
 '<td><b>Last poll</b>',
 '<td><b>Ass.</b>',
 '<td><b>Used</b>',
 '<td><b>Last Exc. time</b>';
SELECT '<tr><td>',database, '<td>',table, '<td>',replace(assignments.topic, ',', ', '),
       '<td align=right>',num_commits, '<td align=right>',num_messages_read,
       '<td>',last_commit_time, '<td>',last_poll_time, 
       '<td>', if(consumer_id='', 0,1), '<td>',is_currently_used, 
       '<td>',if(empty(exceptions.time), '', toString(exceptions.time[-1]))      
  FROM system.kafka_consumers
 ORDER BY last_commit_time desc, last_poll_time desc, database, table;
select '</table><p>' ;

select '<pre><P><table border="2"><tr><td><b>Kafka Exceptions</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Last Exception</b>',
 '<td><b>Consumer ID</b>',
 '<td><b>Exceptions time</b>',
 '<td><b>Exceptions</b>';
SELECT '<tr><td>',database, '<td>',table,
       '<td>',exceptions.time[-1], '<td>',consumer_id,
       '<td>',exceptions.time, '<td>',exceptions.text    
  FROM system.kafka_consumers
 WHERE notEmpty(exceptions.time)
 ORDER BY exceptions.time[-1] desc, database, table;
select '</table><p></pre>' ;

select '<P><A NAME="zoo"></A>' ;
select '<P><table border="2"><tr><td><b>ZooKeeper</b></td></tr>' ;
select '<tr><td><b>Name</b>', '<td><b>Value</b>', '<td><b>CTime</b>', '<td><b>Path</b>';
SELECT '<tr><td>',name, '<td>',value, '<td>',ctime, '<td>',path
  FROM system.zookeeper
 WHERE path IN ('/', '/clickhouse')
 ORDER BY path;
select '</table><p><hr>' ;

select '<P><A NAME="det"></A>' ;
select '<P><A NAME="dbs"></A>' ;
select '<P><div class="short"><table border="2"><tr><td><b>Database Details</b></td></tr>' ;
-- comment, engine_full available on new CH releases
select '<tr><td><b>Database',
 '<td><b>Engine</b>',
 '<td><b>Path</b>',
 '<td><b>Metadata</b>',
 '<td><b>UUID</b>';
SELECT '<tr><td>',name, '<td>',engine,
       '<td>',data_path, '<td>',metadata_path,
       '<td>',uuid
  FROM system.databases
 ORDER BY name;
select '</table></div><p>' ;

select '<P><A NAME="dspace"></A>' ;
select '<P><div class="short"><table border="2"><tr><td><b>Space Usage Details</b></td></tr>' ;
select '<tr><td><b>Database',
 '<td><b>Table</b>',
 '<td><b>Row#</b>',
 '<td><b>Days</b>',
 '<td><b>Size</b>',
 '<td><b>Not Active</b>',
 '<td><b>Size HR</b>',
 '<td><b>Data compressed</b>',
 '<td><b>Data uncompressed</b>';
SELECT '<tr><td>',database, '<td>', table,'<td align=right>', sum(rows),
       '<td align=right>', toUInt32((max(max_time) - min(min_time)) / 86400),
       '<td align=right>', sum(bytes_on_disk),
       '<td align=right>', sum(if(active,0, bytes_on_disk)),
       '<td align=right>', formatReadableSize(sum(if(active,bytes_on_disk,0))),
       '<td align=right>', formatReadableSize(sum(data_compressed_bytes)), 
       '<td align=right>', formatReadableSize(sum(data_uncompressed_bytes))
  FROM system.parts
 GROUP BY database, table
 ORDER BY database, table;
select '</table></div><p>' ;

select '<P><A NAME="ttl"></A>' ;
select '<P><div class="short"><table border="2"><tr><td><b>TTL</b></td></tr>' ;
select '<tr><td><b>Database',
 '<td><b>Table</b>',
 '<td><b>Size (H)</b>',
 '<td><b>Engine</b>',
 '<td><b>TTL</b>';
SELECT '<tr><td>',database, '<td>', name,
       '<td align=right>', formatReadableSize(total_bytes),
       '<td>', engine, 
       '<td>', substring(create_table_query,
                 position(create_table_query, 'TTL'),
                 position(create_table_query, 'SETTING')-position(create_table_query, 'TTL') )
  FROM system.tables
 where engine not in ('View','MaterializedView', 'Kafka', 'Dictionary')
   and engine not like 'System%'
 ORDER BY database, name;
select '</table></div><p>' ;

select '<P><A NAME="dpart"></A>' ;
select '<pre><div class="short"><table border="2"><tr><td><b>Partitions Details</b></td></tr>';
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b># Partitions</b>',
 '<td><b>Min Partition</b>',
 '<td><b>Max Partition</b>',
 '<td><b># Parts</b>',
 '<td><b>Min Part</b>',
 '<td><b>Max Part</b>',
 '<td><b># Active</b>',
 '<td><b>Size</b>';
SELECT '<tr><td>',database, '<td>',table,
       '<td align="right">',count(distinct partition), '<td align="right">',min(partition), '<td align="right">',max(partition),
       '<td align="right">',count(distinct name), '<td align="right">',min(name), '<td align="right">',max(name),
       '<td align="right">',sum(active), '<td align="right">',sum(bytes_on_disk)
  FROM system.parts
 GROUP BY database, table
 ORDER BY database, table;
select '</table></div></pre><p>' ;

select '<P><A NAME="dpar"></A>' ;
select '<pre><div class="short"><table border="2"><tr><td><b>Parts Details</b></td></tr>';
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Partition</b>',
 '<td><b>Part</b>',
 '<td><b>Active</b>',
 '<td><b>Size</b>';
SELECT '<tr><td>',database, '<td>',table, '<td>',partition, '<td>',name,
       '<td>',active, '<td align=right>',bytes_on_disk
  FROM system.parts
 ORDER BY database, table, partition, name;
select '</table></div></pre><p>' ;

select '<P><A NAME="detpar"></A>' ;
select '<pre><div class="short"><table border="2"><tr><td><b>Detached Parts</b></td></tr>';
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Partition ID</b>',
 '<td><b>Part</b>',
 '<td><b>Disk</b>',
 '<td><b>Reason</b>',
 '<td><b>Min Block Number</b>',
 '<td><b>Max Block Number</b>',
 '<td><b>Level</b>';
SELECT '<tr><td>',database, '<td>',table, '<td>',partition_id, '<td>',name,
       '<td>',disk, '<td>',reason, 
       '<td align=right>',min_block_number,
       '<td align=right>',max_block_number,
       '<td align=right>',level
  FROM system.detached_parts
 ORDER BY database, table, partition_id, name;
select '</table></div></pre><p>' ;

select '<P><A NAME="dcomp"></A>' ;
select '<pre><div class="short"><table border="2"><tr><td><b>Compression Details</b></td></tr>';
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Column</b>',
 '<td><b>Type</b>',
 '<td><b> Size compressed</b>',
 '<td><b>Size uncompressed</b>',
 '<td><b>Gain %</b>';
SELECT '<tr><td>',database, '<td>',table, '<td>',column, '<td>',any(type),
       '<td align=right>',sum(column_data_compressed_bytes) compressed,
       '<td align=right>',sum(column_data_uncompressed_bytes) uncompressed,
       '<td align=right>',round( (sum(column_data_uncompressed_bytes)-sum(column_data_compressed_bytes))*100/sum(column_data_uncompressed_bytes), 2)
  FROM system.parts_columns
 WHERE active
 GROUP BY database, table, column
 HAVING sum(column_data_uncompressed_bytes)>0
 ORDER BY database, table, column;
select '</table></div></pre><p>' ;


select '<P><A NAME="deng"></A>' ;
select '<P><div class="short"><table border="2"><tr><td><b>Engine Usage</b></td></tr>';
select '<tr><td><b>Database</b>',
 '<td><b>Engine</b>',
 '<td><b># Tables</b>';
select '<tr><td>', database, '<td>', engine,
	'<td align=right>', count(*)
  from system.tables
 where database not in ('system', 'INFORMATION_SCHEMA', 'information_schema')
 group by database, engine
 order by database, engine;
select '</table></div><p>' ;

select '<P><A NAME="stor"></A>' ;
select '<P><A NAME="dtype"></A>' ;
select '<P><div class="short"><table border="2"><tr><td><b>Datatype Usage</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Data Type</b>',
 '<td><b>Count#</b>';
select '<tr><td>', database, '<td>', type,  '<td>', count()
  from system.columns
 where database not in ('system', 'INFORMATION_SCHEMA', 'information_schema')
 group by database, type
 order by database, type;
select '</table></div><p>' ;

select '<P><A NAME="tabs"></A>' ;
select '<pre><div class="short"><table border="2"><tr><td><b>Table Design</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Table</b>',
 '<td><b>Column</b>',
 '<td><b>Data Type</b>',
 '<td><b>PK</b>', '<td><b>PA</b>', '<td><b>OR</b>', '<td><b>SM</b>',
 '<td><b>Comment</b>';
select '<tr><td>', database, '<td>', table, '<td>', name, '<td>', type,
       '<td>', is_in_primary_key, '<td>', is_in_partition_key, '<td>', is_in_sorting_key, '<td>', is_in_sampling_key,
       '<td>', comment
  from system.columns
 where database not in ('system', 'INFORMATION_SCHEMA', 'information_schema')
 order by database, table, is_in_primary_key desc, name;
select '</table></div></pre><p>' ;

select '<P><A NAME="err"></A>' ;
select '<pre><div class="short"><table border="2"><tr><td><b>Errors</b></td></tr>' ;
select '<tr><td><b>Name</b>',
 '<td><b>Code</b>',
 '<td><b>Value</b>',
 '<td><b>Last error time</b>', '<td><b>Last error message</b>', '<td><b>Last error trace</b>',
 '<td><b>Remote</b>';
select '<tr><td>', name, '<td>', code, '<td>', value,
       '<td>', last_error_time, '<td>', last_error_message, '<td>', last_error_trace, 
       '<td>', remote
  from system.errors;
select '</table></div></pre><p><hr>' ;


select '<P><A NAME="par"></A>' ;
select '<P><table border="2"><tr><td><b>ClickHouse Parameters</b></td></tr>';
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>', '<td><b>Changed</b>' ;
select '<tr><td>',name, '<td>',value, '<td>',changed
  from system.settings
 order by changed desc, name;
select '</table><p><hr>' ;

select '<P><A NAME="gstat"></A>' ;
select '<P><table border="2"><tr><td><b>ClickHouse Metrics</b></td></tr>';
select '<tr><td><b>Statistic</b>', '<td><b>Value</b>', '<td><b>Description </b>' ;
select '<tr><td>', metric, '<td align=right>', value,  '<td>', description
  from system.metrics
 order by metric;
select '</table><p>' ;

select '<P><pre><table border="2"><tr><td><b>ClickHouse Async. Metrics</b></td></tr>';
select '<tr><td><b>Statistic</b>', '<td><b>Value</b>' ;
select '<tr><td>', metric, '<td align=right>', value
  from system.asynchronous_metrics
 order by metric;
select '</table></pre><p>' ;

select '<P><table border="2"><tr><td><b>ClickHouse Events</b></td></tr>';
select '<tr><td><b>Statistic</b>', '<td><b>Value</b>', '<td><b>Description </b>' ;
select '<tr><td>', event, '<td align=right>', value,  '<td>', description
  from system.events
 order by event;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Part log</b></td></tr>';
select '<tr><td><div class="short">' ;
SELECT *
  FROM system.part_log
 order by event_date desc, event_time desc
 limit 100;
select '</div></table><p>' ;

select '<hr><P>SQL Statistics generated on: ', now();

