-- Program: tsdb2html.sql
-- Info:    TimescaleDB report in HTML
-- Date:    1-APR-08
-- Version: 1.0.0 - 1-APR-18
-- Author:  Bartolomeo Bogliolo (meo) mail@meo.bogliolo.name
-- Usage:   psql [-U USERNAME] [DBNAME] < pg2html.sql
-- Notes:   1-APR-08 mail@meo.bogliolo.name
--          1.0.0 First version based on pg2html

\pset tuples_only
\pset fieldsep ' '
\a
\o tsdb.htm

select '<!doctype html><html><head><meta charset="UTF-8"><link rel="stylesheet" href="ux3.css" /><title>tsdb2html - TimescaleDB Statistics</title></head><body>' as info;
select '<h1 align=center>PostgreSQL - '||current_database()||'</h1>' as info;

select '<P><A NAME="top"></A>' as info;
select '<p>Table of contents:' as info;
select '<table><tr><td><ul>' as info;
select '<li><A HREF="#status">Summary Status</A></li>' as info;
select '<li><A HREF="#ver">Hypertables</A></li>' as info;
select '<li><A HREF="#dbs">Chunks</A></li>' as info;
select '<li><A HREF="#usg">Space Usage</A></li>' as info;
select '<li><A HREF="#par">Parameters</A></li>' as info;
select '</ul></table><p><hr>' as info;
 
select '<P>Statistics generated on: '|| current_date || ' ' ||localtime
as info;
 
select 'on database: <b>'||current_database()||'</b>' as info;
select 'by user: '||user as info;

select 'using: <I><b>tsdb2html.sql</b> v.1.0.0' as info;
select '<br>Software by ' as info;
select '<A HREF="https://meoshome.it.eu.org">Meo Bogliolo</A></I><p>'
as info;
 
select '<hr><P><A NAME="status"></A>' as info;
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>' as info;
select '<tr><td><b>Item</b>', '<td><b>Value</b>' as info;

select '<tr><td>'||' Database :', '<! 10>',
 '<td>'||current_database()
union
select '<tr><td>'||' Version :', '<! 12>',
 '<td>'||substring(version() for  position('on' in version())-1)
union
select '<tr><td>'||' Started :',
   '<! 16>', '<td>'||pg_postmaster_start_time()
union
select '<tr><td>'||' Created :',
   '<! 15>', '<td>'|| (pg_stat_file('base/'||oid ||'/PG_VERSION')).modification
  from pg_database
 where datname=current_database()
union
select '<tr><td>'||' DB Size (MB):', '<! 20>',
 '<td align="right">'||trunc(sum(pg_database_size(datname))/(1024*1024))
  from pg_database
union
select '<tr><td>'||' Memory buffers (MB) :',
   '<! 24>', '<td align="right">'||trunc(sum(setting::int*8)/1024)
  from pg_settings
 where name like '%buffers'
union
select '<tr><td>'||' Work area (MB) :',
   '<! 25>', '<td align="right">'||trunc(sum(setting::int)/1024)
  from pg_settings
 where name like '%mem'
union
select '<tr><td>'||' Wal Archiving :',
   '<! 26>', '<td align="right">'||setting
  from pg_settings
 where name like 'archive_mode'
union
select '<tr><td>'||' Databases :', '<! 30>', '<td align="right">'||count(*)
  from pg_database
 where not datistemplate
union
select '<tr><td>'||' Defined Users :',
   '<! 31>', '<td align="right">'||count(*)
  from pg_roles
union
select '<tr><td>'||' Defined Schemata :',
   '<! 32>', '<td align="right">'||count(distinct relowner)
  from pg_class
union
select '<tr><td>'||' Defined Tables :',
   '<! 34>', '<td align="right">'||count(*)
  from pg_class
 where relkind='r'
union
select '<tr><td>'||' Sessions :', '<! 38>', '<td align="right">'||count(*)
 from pg_stat_activity
union
select '<tr><td>'||' Sessions (active) :', '<! 39>', '<td align="right">'||count(*)
  from pg_stat_activity
 where state = 'active'
union
select '<tr><td>'||' Hypertables :',
   '<! 40>', '<td align="right">'||count(*)
  from _timescaledb_catalog.hypertable
union
select '<tr><td>'||' Chunks :',
   '<! 42>', '<td align="right">'||count(*)
  from _timescaledb_catalog.chunk
union
select '<tr><td>'||' Chunk Indexes :',
   '<! 44>', '<td align="right">'||count(*)
  from _timescaledb_catalog.chunk_index
union
select '<tr><td>'||' Dimensions :',
   '<! 46>', '<td align="right">'||count(*)
  from _timescaledb_catalog.dimension
union
select '<tr><td>'||' Dimension Slices :',
   '<! 48>', '<td align="right">'||count(*)
  from _timescaledb_catalog.dimension_slice
union
select '<tr><td>'||' Host IP :',
   '<! 51>', '<td align="right">'||inet_server_addr()
union
select '<tr><td>'||' Port :',
   '<! 52>', '<td align="right">'||inet_server_port()
order by 2;
select '</table><p><hr>' as info;

select '<P><A NAME="ver"></A>' as info;
select '<P><table border="2"><tr><td><b>Version</b></td></tr>' as info;
select '<tr><td>'||version()||'</tr></td>';
select '</table><p><hr>' ;

select '<P><A NAME="dbs"></A>' as info;
select '<P><table border="2"><tr><td><b>Databases</b></td></tr>' as info;
select '<tr><td><b>Name</b>', '<td><b>OID</b>',
 '<td><b>Size</b>',
 '<td><b>UR Size</b>'
as info;
select '<tr><td>'||datname,'<td>', oid,
 '<td align=right>'||pg_database_size(datname),
 '<td align=right>'||pg_size_pretty(pg_database_size(datname))
  from pg_database
 where not datistemplate;
select '<tr><tr><td>TOTAL (MB)','<td>',
 '<td align=right>'||trunc(sum(pg_database_size(datname))/(1024*1024)),
 '<td align=right>'||pg_size_pretty(sum(pg_database_size(datname))::int8)
from pg_database;
select '</table><p><hr>' as info;

select '<P><A NAME="tbs"></A>' as info;
select '<P><table border="2"><tr><td><b>Tablespaces</b></td></tr>' as info;
select '<tr><td><b>Name</b>' as info;
select '<tr><td>'||spcname from pg_tablespace;
select '</table><p><hr>' as info;

select '<P><A NAME="obj"></A>' as info;
select '<P><table border="2"><tr><td><b>Schema/Object Matrix</b></td></tr>' as info;
select '<tr><td><b>Owner</b>',
 '<td><b> Table</b>',
 '<td><b> Index</b>',
 '<td><b> View</b>',
 '<td><b> Sequence</b>',
 '<td><b> Composite type</b>',
 '<td><b> Foreign table</b>',
 '<td><b> TOAST table</b>',
 '<td><b> Unlogged</b>',
 '<td><b> Temporary</b>',
 '<td><b> TOTAL</b>'
as info;
select '<tr><td>'||rolname,
 '<td align="right">'||sum(case when relkind='r' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='i' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='v' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='S' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='c' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='f' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='t' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relpersistence='u' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relpersistence='t' THEN 1 ELSE 0 end),
 '<td align="right">'||count(*)
from pg_class, pg_roles
where relowner=pg_roles.oid
group by rolname
order by rolname;
select '<tr><td>TOTAL',
 '<td align="right">'||sum(case when relkind='r' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='i' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='v' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='S' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='c' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='f' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='t' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relpersistence='u' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relpersistence='t' THEN 1 ELSE 0 end),
 '<td align="right">'||count(*)
from pg_class;
select '</table><p>' as info;


select '<P><A NAME="usg"></A>' as info;
select '<P><table border="2"><tr><td><b>Space Usage</b></td></tr>' as info;
select '<tr><td><b>Owner</b>',
 '<td><b>Table#</b>',
 '<td><b>Tables rows</b>',
 '<td><b>Tables KBytes</b>',
 '<td><b>Indexes KBytes</b>',
 '<td><b>TOAST KBytes</b>',
 '<td><b>Total KBytes</b>'
as info;
select '<tr><td>'||rolname,
 '<td align="right">'||to_char(sum(case when relkind='r' THEN 1 ELSE 0 end),'999G999G999'),
 '<td align="right">'||to_char(sum(case when relkind='r' THEN reltuples ELSE 0 end),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='r' THEN relpages *8 ELSE 0 end)),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='i' THEN relpages *8 ELSE 0 end)),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='t' THEN relpages *8 ELSE 0 end)),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(relpages *8)),'999G999G999')
from pg_class, pg_roles
where relowner=pg_roles.oid
group by rolname
order by rolname;
select '<tr><td>TOTAL',
 '<td align="right">'||to_char(sum(case when relkind='r' THEN 1 ELSE 0 end),'999G999G999'),
 '<td align="right">'||to_char(sum(case when relkind='r' THEN reltuples ELSE 0 end),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='r' THEN relpages *8 ELSE 0 end)),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='i' THEN relpages *8 ELSE 0 end)),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='t' THEN relpages *8 ELSE 0 end)),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(relpages *8)),'999G999G999')
from pg_class, pg_roles
where relowner=pg_roles.oid;
select '</table><p>' as info;


select '<P><A NAME="stat"></A><P>' as info;
select '<P><table border="2"><tr><td><b>Cluster Database Statistics</b>' as info;
select '<tr><td><b>Database</b>',
 '<td><b>Backends</b>',
 '<td><b>Commit</b>',
 '<td><b>TPS</b>',
 '<td><b>Rollback</b>',
 '<td><b>Read</b>',
 '<td><b>Hit</b>',
 '<td><b>Hit Ratio%</b>',
 '<td><b>Return</b>',
 '<td><b>Fetch</b>',
 '<td><b>Insert</b>',
 '<td><b>Update</b>',
 '<td><b>Delete</b>'
as info;
select '<tr><td>'||datname, 
	'<td align="right">'||numbackends, 
	'<td align="right">'||xact_commit, 
	'<td align="right">'||round(xact_commit/EXTRACT( EPOCH FROM (now()-stats_reset))::decimal,2),
	'<td align="right">'||xact_rollback, 
	'<td align="right">'||blks_read, 
	'<td align="right">'||blks_hit, 
        '<td align="right">'||round((blks_hit)*100.0/nullif(blks_read+blks_hit, 0),2) hit_ratio, 
	'<td align="right">'||tup_returned, 
	'<td align="right">'||tup_fetched, 
	'<td align="right">'||tup_inserted, 
	'<td align="right">'||tup_updated, 
	'<td align="right">'||tup_deleted
from pg_stat_database
where datname not like 'template%';
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>BG Writer statistics</b>' as info;
select '<tr><td><b>checkpoints_timed</b>',
 '<td><b> checkpoints_req </b>',
 '<td><b> buffers_checkpoint </b>',
 '<td><b> buffers_clean </b>',
 '<td><b> maxwritten_clean </b>',
 '<td><b> buffers_backend </b>',
 '<td><b> buffers_alloc </b>',
 '<td><b> Minutes between checkpoints </b>';
select '<tr><td>'||checkpoints_timed, 
	'<td align="right">'|| checkpoints_req, 
	'<td align="right">'|| buffers_checkpoint, 
	'<td align="right">'|| buffers_clean, 
	'<td align="right">'|| maxwritten_clean, 
	'<td align="right">'|| buffers_backend, 
	'<td align="right">'|| buffers_alloc
 from pg_stat_bgwriter;
select '<td align="right">'|| seconds_since_start / total_checkpoints / 60 AS mbc
  from  (SELECT EXTRACT(EPOCH FROM (now() - pg_postmaster_start_time())) AS seconds_since_start,
                (checkpoints_timed+checkpoints_req) AS total_checkpoints
           FROM pg_stat_bgwriter
         ) AS sub;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Cache statistics</b>' as info;
select '<tr><td><b>Object Type</b><td><b>#Read</b>',
 '<td><b> #Hit </b>',
 '<td><b> Hit Ratio% </b>';
SELECT '<tr><td>Table',
  '<td align="right">'||sum(heap_blks_read) as heap_read,
  '<td align="right">'||sum(heap_blks_hit)  as heap_hit,
  '<td align="right">'||trunc(100*sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)),2) as ratio
FROM 
  pg_statio_user_tables;
SELECT '<tr><td>Index',
  '<td align="right">'||sum(idx_blks_read) as idx_read,
  '<td align="right">'||sum(idx_blks_hit)  as idx_hit,
  '<td align="right">'||trunc(100*(sum(idx_blks_hit) - sum(idx_blks_read)) / nullif(sum(idx_blks_hit),0),2) as ratio
FROM 
  pg_statio_user_indexes;
select '</table><p>' as info;

select '<P><A NAME="stmt"></A><P>' as info;
select '<P><table border="2"><tr><td><b>Statement statistics</b>' as info;
select '<tr><td><b>Query</b>',
 '<td><b>User</b>',
 '<td><b>Calls</b>',
 '<td><b>Average (sec.)</b>',
 '<td><b>Total Time</b>',
 '<td><b>I/O Time</b>',
 '<td><b>Rows</b>',
 '<td><b>Hit Ratio%</b>'
as info;
SELECT '<tr><td>'||replace(query,',',', '), ' <td>'||pg_get_userbyid(userid), '<td align="right">'||calls,
       '<td align="right">'||round((total_time::numeric / calls::numeric)/1000,3),
       '<td align="right">'||round(total_time), '<td align="right">'||round(blk_read_time+blk_write_time), '<td align="right">'||rows,
       '<td align="right">'||round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2)  AS hit_percent
  FROM pg_stat_statements 
 ORDER BY total_time DESC LIMIT 10;
select '</table><p>' as info;

select '<P><table border="2">' as info;
select '<tr><td><b>Database</b>',
 '<td><b>DBcpu</b>',
 '<td><b>IOcpu</b>'
as info;
select '<tr><td>', datname,
       '    <td>', round(sum( (total_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) IOcpu
  from pg_stat_statements, pg_database
 where pg_stat_statements.dbid=pg_database.oid
 group by datname;
select '<tr><td>TOTAL<td>', round(sum( (total_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) IOcpu
  from pg_stat_statements;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Most accessed tables</b>' as info;
select '<tr><td><b>Schema</b><td><b>Table</b>',
 '<td><b>Heap Reads</b>',
 '<td><b>Table Hit Ratio%</b>',
 '<td><b>Index Hit Ratio%</b>';
select '<tr><td>'||schemaname,
  '<td>'||relname,
  '<td align="right">'||heap_blks_read,
  '<td align="right">'||heap_blks_hit*100/nullif(heap_blks_read+heap_blks_hit,0) as tb_hit_ratio,
  '<td align="right">'||idx_blks_hit*100/nullif(idx_blks_read+idx_blks_hit,0) as idx_hit_ratio
 from pg_statio_all_tables
 where heap_blks_read>0
 order by heap_blks_read desc
 limit 20;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>PostgreSQL Tuning Parameters</b></td></tr>'
 as info;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>',
 '<td><b>Min</b>',
 '<td><b>Max</b>',
 '<td><b>Description</b>'
as info;
select '<tr><td>',name,'<td align=right>',replace(replace(setting,'<','&lt;'),'>','&gt;'),
   '<td align=right>',min_val,'<td align=right>',max_val,
   '<td>',short_desc
  from pg_settings
 where name in ('max_connections','shared_buffers','effective_cache_size','work_mem', 'wal_buffers',
               'checkpoint_completion_target', 'checkpoint_segments', 'synchronous_commit', 'wal_writer_delay',
               'max_fsm_pages','fsync','commit_delay','commit_siblings','random_page_cost',
               'checkpoint_timeout', 'max_wal_size') 
 order by name; 
select '</table><p><hr>' as info;


select '<P><A NAME="big"></A>'  as info;
select '<P><table border="2"><tr><td><b>Biggest Objects</b></td></tr>'
 as info;
select '<tr><td><b>Object</b>',
 '<td><b>Type</b>',
 '<td><b>Owner</b>',
 '<td><b>Bytes</b>',
 '<td><b>Rows</b>'
as info;
select '<tr><td>'||relname,
 '<td>'||case WHEN relkind='r' THEN 'Table' 
    WHEN relkind='i' THEN 'Index'
    WHEN relkind='t' THEN 'TOAST Table'
    ELSE relkind||'' end,
 '<td>'||rolname,
 '<td align=right>'||to_char(relpages::INT8*8*1024,'999G999G999G999'),
 '<td align=right>'||to_char(reltuples,'999G999G999G999')
  from pg_class, pg_roles
 where relowner=pg_roles.oid
 order by relpages desc, reltuples desc
 limit 20;
select '</table><p><hr>' as info;

select '<P><A NAME="ext"></A>'  as info;
select '<P><table border="2"><tr><td><b>Extensions</b></td></tr>'
 as info;
select '<tr><td><b>Name</b>',
 '<td><b>Default Version</b>',
 '<td><b>Installed Version</b>',
 '<td><b>Description</b>'
as info;
select '<tr><td>',name,'<td>',default_version,'<td>',installed_version,'<td>',comment
  from pg_available_extensions
 where installed_version is not null
 order by name;
select '</table><p><hr>' as info;

select '<P><A NAME="nls"></A>'  as info;
select '<P><table border="2"><tr><td><b>NLS Settings</b></td></tr>'
 as info;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>',
 '<td><b>Description</b>'
as info;
select '<tr><td>',name,'<td align=right>',setting,
   '<td>',short_desc
from pg_settings
where name like 'lc%'
order by name; 
select '</table><p><hr>' as info;

select '<P><A NAME="par"></A>'  as info;
select '<P><table border="2"><tr><td><b>PostgreSQL Parameters</b></td></tr>'
 as info;

select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>',
 '<td><b>Min</b>',
 '<td><b>Max</b>',
 '<td><b>Description</b>'
as info;
select '<tr><td>',name,'<td align=right>',replace(replace(setting,'<','&lt;'),'>','&gt;'),
   '<td align=right>',min_val,'<td align=right>',max_val,
   '<td>',short_desc
from pg_settings
order by name; 
select '</table><p><hr>' as info;

select '<P>Statistics generated on: '|| current_date || ' ' ||localtime as info;
select '<br>More info on' as info;
select '<A HREF="https://meoshome.it.eu.org">this site</A>' as info;
select 'or contact' as info;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo</A>.<p></body></html>' as info;
