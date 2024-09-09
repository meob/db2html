-- Program: pg2html.sql
-- Info:    PostgreSQL report in HTML
--          Tested with PostgreSQL >= 7.0 and PostgreSQL < 9.2. Best with Postgres 9.0 and 9.1. 

--          Important notice: versions not supported, the script is not maintained any longer

-- Date:    1-APR-08
-- Version: 1.0.10c
-- Author:  Bartolomeo Bogliolo (aka meo) mail@meo.bogliolo.name
-- Usage:   psql [-U USERNAME] [DBNAME] < pg2html.sql
-- Notes:   1-APR-08 mail@meo.bogliolo.name
--          1.0.0 First version based on ora2html (Oracle report in HTML)
--          1.0.3 Minor changes (eg. formatting, aligment)
--          1.0.4 TOTAL for objects, space usage, roles
--          1.0.5 HTML5, function count
--          1.0.6 Added 9.1 new features (<9.1 gives an error on pg_available_extension)
--          1.0.7 2012-11-01 	Added poor password check (a) session summary
--          Removed 9.0 incompatibilities
--          1.0.9 More performance statistics
--          1.0.10 Vacuum stats (b) pg_stat_statement summary (c) pg_buffercache

\pset tuples_only
\pset fieldsep ' '
\a
\o pg.htm

select '<!doctype html><html><head><meta charset="UTF-8"><title>pg2html - PostgreSQL Statistics</title></head><body>' as info;
select '<h1 align=center>PostgreSQL - '||current_database()||'</h1>' as info;

select '<P><A NAME="top"></A>' as info;
select '<p>Table of contents:' as info;
select '<table><tr><td><ul>' as info;
select '<li><A HREF="#status">Summary Status</A></li>' as info;
select '<li><A HREF="#ver">Versions</A></li>' as info;
select '<li><A HREF="#dbs">Databases</A></li>' as info;
select '<li><A HREF="#tbs">Tablespaces</A></li>' as info;
select '<li><A HREF="#obj">Schema/Object Matrix</A></li>' as info;
select '<li><A HREF="#usg">Space Usage</A></li>' as info;
select '<li><A HREF="#usr">Users</A></li>' as info;
select '<li><A HREF="#sql">Sessions</A></li>' as info;
select '<li><A HREF="#lock">Locks</A></li>' as info;
select '</ul><td><ul>' as info;
select '<li><A HREF="#sga">Memory</A></li>' as info;
select '<li><A HREF="#stat">Performance Statistics</A></li>' as info;
select '<li><A HREF="#big">Biggest Objects</A></li>' as info;
select '<li><A HREF="#psq">PLPGSQL</A></li>' as info;
select '<li><A HREF="#rman">Backup</A></li>' as info;
select '<li><A HREF="#ext">Extensions</A></li>' as info;
select '<li><A HREF="#nls">NLS Settings</A></li>' as info;
select '<li><A HREF="#par">Parameters</A></li>' as info;
select '</ul></table><p><hr>' as info;
 
select '<P>Statistics generated on: '|| current_date || ' ' ||localtime
as info;
 
select 'on database: <b>'||current_database()||'</b>' as info;
select 'by user: '||user as info;

select 'using: <I><b>pg2html.sql</b> v.1.0.10c' as info;
select '<br>Software by ' as info;
select '<A HREF="https://meoshome.it.eu.org/">Meo Bogliolo</A></I><p>'
as info;
 
select '<hr><P><A NAME="status"></A>' as info;
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>' as info;
select '<tr><td><b>Item</b>', '<td><b>Value</b>' as info;

select '<tr><td>'||' Version :', '<! 10>',
 '<td>'||substring(version() for  position(',' in version())-1)
union
select '<tr><td>'||' DB Size (MB):', '<! 15>',
 '<td align="right">'||trunc(sum(pg_database_size(datname))/(1024*1024))
from pg_database
union
select '<tr><td>'||' Databases :', '<! 20>', '<td align="right">'||count(*)
from pg_database
union
select '<tr><td>'||' Tablespaces :', '<! 25>', '<td align="right">'||count(*)
from pg_tablespace
union
select '<tr><td>'||' Sessions :', '<! 30>', '<td align="right">'||count(*)
from pg_stat_activity
union
select '<tr><td>'||' Sessions (active) :', '<! 35>', '<td align="right">'||count(*)
from pg_stat_activity
where current_query <> '<IDLE>'
union
select '<tr><td>'||' Memory buffers (KB) :',
   '<! 40>', '<td align="right">'||sum(setting::int*8)
from pg_settings
where name like '%buffers'
union
select '<tr><td>'||' Work area (KB) :',
   '<! 45>', '<td align="right">'||sum(setting::int)
from pg_settings
where name like '%mem'
order by 2;
select '</table><p><hr>' as info;


select '<P><A NAME="ver"></A>' as info;
select '<P><table border="2"><tr><td><b>Versions</b></td></tr>' as info;
select '<tr><td>'||version()||'</tr></td>';
select '</table><p><hr>' as info;

select '<P><A NAME="dbs"></A>' as info;
select '<P><table border="2"><tr><td><b>Databases</b></td></tr>' as info;
select '<tr><td><b>Name</b>',
 '<td><b>Size</b>',
 '<td><b>UR Size</b>'
as info;
select '<tr><td>'||datname,
 '<td align=right>'||pg_database_size(datname),
 '<td align=right>'||pg_size_pretty(pg_database_size(datname))
from pg_database
where not datistemplate;
select '<tr><tr><td>TOTAL (MB)',
 '<td align=right>'||trunc(sum(pg_database_size(datname))/(1024*1024)),
 '<td align=right>'||pg_size_pretty(sum(pg_database_size(datname))::int8)
from pg_database;
select '</table><p><hr>' as info;

select '<P><A NAME="tbs"></A>' as info;
select '<P><table border="2"><tr><td><b>Tablespaces</b></td></tr>' as info;
select '<tr><td><b>Name</b>',
 '<td><b>Location</b>'
as info;
select '<tr><td>'||spcname,
 '<td>'||spclocation
from pg_tablespace;
select '</table><p><hr>' as info;

select '<P><A NAME="obj"></A>' as info;
select '<P><table border="2"><tr><td><b>Schema/Object Matrix</b></td></tr>' as info;
select '<tr><td><b>Owner</b>',
 '<td><b> Table</b>',
 '<td><b> Index</b>',
 '<td><b> View</b>',
 '<td><b> Sequence</b>',
 '<td><b> Composite</b>',
 '<td><b> TOAST</b>'
as info;
select '<tr><td>'||rolname,
 '<td align="right">'||sum(case when relkind='r' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='i' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='v' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='S' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='c' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='t' THEN 1 ELSE 0 end)
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
 '<td align="right">'||sum(case when relkind='t' THEN 1 ELSE 0 end)
from pg_class, pg_roles
where relowner=pg_roles.oid;
select '</table><p><hr>' as info;

select '<P><A NAME="usg"></A>' as info;
select '<P><table border="2"><tr><td><b>Space Usage</b></td></tr>' as info;
select '<tr><td><b>Owner</b>',
 '<td><b>Tables rows</b>',
 '<td><b>Tables MBytes</b>',
 '<td><b>Indexes MBytes</b>'
as info;
select '<tr><td>'||rolname,
 '<td align="right">'||to_char(sum(case when relkind='r' THEN reltuples ELSE 0 end),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='r' THEN relpages *8/1024 ELSE 0 end)),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='i' THEN relpages *8/1024 ELSE 0 end)),'999G999G999')
from pg_class, pg_roles
where relowner=pg_roles.oid
group by rolname
order by rolname;
select '<tr><td>TOTAL',
 '<td align="right">'||to_char(sum(case when relkind='r' THEN reltuples ELSE 0 end),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='r' THEN relpages *8/1024 ELSE 0 end)),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='i' THEN relpages *8/1024 ELSE 0 end)),'999G999G999')
from pg_class, pg_roles
where relowner=pg_roles.oid;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Vacuum and Analyze</b></td></tr>' as info;
select '<tr><td><b># Tables</b>',
 '<td><b>Last autoVACUUM</b>',
 '<td><b>Last VACUUM</b>',
 '<td><b>Last autoANALYZE</b>',
 '<td><b>Last ANALYZE</b>'
as info;
select '<tr><td align="right">'||count(*), '<td>'||max(last_autovacuum), '<td>'||max(last_vacuum),
 '<td>'||max(last_autoanalyze), '<td>'||max(last_analyze)
 from pg_stat_user_tables;
select '</table><p><hr>' as info;

select '<P><A NAME="usr"></A>' as info;
select '<P><table border="2"><tr><td><b>Users/Roles</b></td></tr>' as info;
select '<tr><td><b>Role</b>',
 '<td><b>Login</b>',
 '<td><b>Inherit</b>',
 '<td><b>Superuser</b>',
 '<td><b>Config</b>'
as info;
select '<tr><td>'||rolname,
	'<td>'||rolcanlogin,
	'<td>'||rolinherit,
	'<td>'||rolsuper,
	'<td>'||rolconfig::text
from pg_roles
order by rolname;
select '<tr><td>TOTAL',
	'<td align=right>'||count(*)
from pg_roles;
select '</table><p>' as info;

select '<P><a id="usr_sec"></a>' as defaultpw;
select '<P><table border="2"><tr><td><b>Users with poor password</b></td></tr>' as info;
select '<tr><td><b>Username</b>','<td><b>Password</b>',
 '<td><b>Note</b>' ;
select '<tr><td>',usename, '<td>', passwd, '<td>Weak password'
 from pg_shadow
 where substr(passwd,4) in (
         md5('postgres'||usename), md5('mypass'|| usename), md5('admin'|| usename), md5('secret'|| usename),
         md5('root'|| usename), md5('password'|| usename), md5('public'|| usename), md5('private'|| usename),
         md5('1234'|| usename), md5('secure'|| usename), md5('pass'|| usename), md5('qwerty'|| usename),
         md5('pippo'|| usename))
order by usename;
select '<tr><td>',usename, '<td>', passwd, '<td>Same as user'
 from pg_shadow
 where substr(passwd,4) = md5(usename||usename)
order by usename;
select '</table><p><hr>';

select '<P><A NAME="sql"></A>' as info;
select '<P><table border="2"><tr><td><b>User Sessions</b></td></tr>'
 as info;
select '<tr><td><b>User</b>',
 '<td><b>Count</b>' ;
select 	'<tr><td>'||usename,
 	'<td>', count(*)
from pg_stat_activity
group by usename
order by 3 desc, 1;
select 	'<tr><td>TOTAL (', count(distinct usename),
 	')<td>'|| count(*)
from pg_stat_activity;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Sessions</b></td></tr>'
 as info;
select '<tr><td><b>Pid</b>',
 '<td><b>User</b>',
 '<td><b>Address</b>',
 '<td><b>Running SQL</b>' ;
select 	'<tr><td>'||procpid,
 	'<td>'||usename,
 	'<td>',client_addr,
 	'<td>'|| case when current_query='<IDLE>' THEN E'\136Idle' ELSE current_query end
from pg_stat_activity
where current_query not like 'select %pg_stat_activity%current_query%'
order by 5, procpid;
select '</table><p><hr>' as info;

select '<P><A NAME="lock"></A>'  as info;
select '<P><table border="2"><tr><td><b>Lock</b></td></tr>'
 as info;
select '<tr><td><b>Pid</b>',
 '<td><b>Type</b>',
 '<td><b>Database</b>',
 '<td><b>Relation</b>',
 '<td><b>Mode</b>',
 '<td><b>Granted</b>'
as info;
select '<tr><td>'||pid, 
	'<td>'||locktype, 
	'<td>',database, 
	'<td>',relation, 
	'<td>'||mode, 
	'<td>'||granted
from pg_locks
order by granted, pid;
select '</table><p><hr>' as info;

select '<P><A NAME="sga"></A>' as info;
select '<P><table border="2"><tr><td><b>Memory</b></td></tr>' as info;
select '<tr><td><b>Element</b>',
 '<td><b>KB</b>',
 '<td><b>Description</b>'
as info;
select '<tr><td>'||name,
	'<td align=right>'||setting::int*8,
	'<td>'||short_desc
from pg_settings
where name like '%buffers';
select '<tr><td>'||name,
	'<td align=right>'||setting::int,
	'<td>'||short_desc
from pg_settings
where name like '%mem';
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Buffer Cache Contents</b></td></tr>' as info;
select '<tr><td><b>Table</b>',
       '<td><b>Buffers</b>'
as info;
select '<tr><td>', c.relname, '<td>', count(*)
  from pg_buffercache b INNER JOIN pg_class c
       ON  b.relfilenode = pg_relation_filenode(c.oid)
       AND b.reldatabase IN (0, (select oid from pg_database
                                  where datname = current_database()))
 group by c.relname
 order by 4 desc
 limit 10;
select '</table><p><hr>' as info;

select '<P><A NAME="stat"></A><P>' as info;
select '<P><table border="2"><tr><td><b>Statistics</b>' as info;
select '<tr><td><b>Database</b>',
 '<td><b>Backends</b>',
 '<td><b>Commit</b>',
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
	'<td align="right">'||xact_rollback, 
	'<td align="right">'||blks_read, 
	'<td align="right">'||blks_hit, 
        '<td align="right">'||(blks_hit)*100/nullif(blks_read+blks_hit, 0) hit_ratio, 
	'<td align="right">'||tup_returned, 
	'<td align="right">'||tup_fetched, 
	'<td align="right">'||tup_inserted, 
	'<td align="right">'||tup_updated, 
	'<td align="right">'||tup_deleted
from pg_stat_database
where datname not like 'template%';
select '</table><p>' as info;

-- SELECT query, calls, total_time, rows,
--        100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
-- FROM pg_stat_statements ORDER BY total_time DESC LIMIT 20;

select '<P><table border="2"><tr><td><b>BG Writer statistics</b>' as info;
select '<tr><td><b>checkpoints_timed</b>',
 '<td><b> checkpoints_req </b>',
 '<td><b> buffers_checkpoint </b>',
 '<td><b> buffers_clean </b>',
 '<td><b> maxwritten_clean </b>',
 '<td><b> buffers_backend </b>',
 '<td><b> buffers_alloc </b>';
select '<tr><td>'||checkpoints_timed, 
	'<td align="right">'|| checkpoints_req, 
	'<td align="right">'|| buffers_checkpoint, 
	'<td align="right">'|| buffers_clean, 
	'<td align="right">'|| maxwritten_clean, 
	'<td align="right">'|| buffers_backend, 
	'<td align="right">'|| buffers_alloc
 from pg_stat_bgwriter;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Cache statistics </b>' as info;
select '<tr><td><b>Object Type</b><td><b>#Read</b>',
 '<td><b> #Hit </b>',
 '<td><b> Hit Ratio% </b>';
SELECT '<tr><td>Table',
  '<td align="right">'||sum(heap_blks_read) as heap_read,
  '<td align="right">'||sum(heap_blks_hit)  as heap_hit,
  '<td align="right">'||100*sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
FROM 
  pg_statio_user_tables;
SELECT '<tr><td>Index',
  '<td align="right">'||sum(idx_blks_read) as idx_read,
  '<td align="right">'||sum(idx_blks_hit)  as idx_hit,
  '<td align="right">'||100*(sum(idx_blks_hit) - sum(idx_blks_read)) / nullif(sum(idx_blks_hit),0) as ratio
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
SELECT '<tr><td>'||replace(query,',',', '), '<td>'||pg_get_userbyid(userid), '<td align="right">'||calls,
       '<td align="right">'||round((total_time::numeric / calls::numeric)/1000,3),
       '<td align="right">'||round(total_time), '<td align="right">', '<td align="right">'||rows,
       '<td align="right">'||round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2)  AS hit_percent
  FROM pg_stat_statements 
 ORDER BY total_time DESC LIMIT 20;
select '</table><p>' as info;

select '<P><table border="2">' as info;
select '<tr><td><b>Database</b>',
 '<td><b>DBcpu</b>',
 '<td><b>IOcpu</b>'
as info;
select '<tr><td>', datname,
       '    <td>', round(sum( (total_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu
  from pg_stat_statements, pg_database
 where pg_stat_statements.dbid=pg_database.oid
 group by datname;
select '<tr><td>TOTAL<td>', round(sum( (total_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu  from pg_stat_statements;
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
 limit 40;
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

select '<P><A NAME="psq"></A>'  as info;
select '<P><table border="2"><tr><td><b>Procedural Languages</b></td></tr>'
 as info;
select '<tr><td><b>Available languages</b>' as info;
select '<tr><td>'||lanname
from pg_language;
select '<tr><td><b>Language templates</b>' as info;
select '<tr><td>'||tmplname
from pg_pltemplate;
select '</table><P><table border="2"><tr><td><b>PL Objects</b></td></tr>';
select '<tr><td><b>Owner</b>',
 '<td><b>Language</b>',
 '<td><b>Count</b>'
as info;
select '<tr><td>'||o.rolname, '<td>'||l.lanname, '<td align="right">'||count(*)
from pg_proc f, pg_authid o, pg_language l
where f.proowner=o.oid
and f.prolang=l.oid
group by o.rolname, l.lanname
order by o.rolname, l.lanname;
select '</table><p><hr>' as info;

select '<P><A NAME="rman"></A>'  as info;
select '<P><table border="2"><tr><td><b>Backup Configuration</b></td></tr>'
 as info;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
as info;
select '<tr><td>Write xlog location',
 '<td>'||pg_current_xlog_location();
select '<tr><td>Insert xlog location',
 '<td>'||pg_current_xlog_insert_location();
select '</table><p><hr>' as info;

select '<P><A NAME="ext"></A>'  as info;
select '<P><table border="2"><tr><td><b>Extensions</b></td></tr>'
 as info;
select '<tr><td><b>Name</b>',
 '<td><b>Default Version</b>',
 '<td><b>Installed Version</b>',
 '<td><b>Description</b>'
as info;
select '<tr><td>postgis<td><td><td>PostGIS installed (pre-extensions check)' pg 
from pg_proc 
where proname='postgis_version';
select '</table><p><hr>' as info;

-- pg_stat_replication Add here?

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
select '<tr><td>',name,'<td align=right>',setting,
   '<td align=right>',min_val,'<td align=right>',max_val,
   '<td>',short_desc
from pg_settings
order by name; 
select '</table><p><hr>' as info;

select '<P>Statistics generated on: '|| current_date || ' ' ||localtime as info;
select '<br>More info on' as info;
select '<A HREF="https://meoshome.it.eu.org/">this site</A>' as info;
select 'or contact' as info;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo</A>.<p></body></html>' as info;
