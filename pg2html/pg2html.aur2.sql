-- Program: pg2html.aur2.sql
-- Info:    PostgreSQL report in HTML
--          Best with PostgreSQL 10 or sup.
-- Date:    2008-04-01
-- Version: 1.0.21.aur2 on 2021-08-15
-- Author:  Bartolomeo Bogliolo (meo) mail@meo.bogliolo.name
-- License: GPL
--
-- Notes:   1-APR-08 mail@meo.bogliolo.name
--          1.0.0 First version based on ora2html (Oracle report in HTML)
--          1.0.3 Minor changes (eg. formatting, alignment)
--          1.0.4 TOTAL for objects, space usage, roles
--          1.0.5 HTML5, function count
--          1.0.6 Pg 9.1 new features (if <9.1 gives an error on pg_available_extension)
--          1.0.7 Added poor password check (a) session summary
--          1.0.8 Pg 9.2 new features (NB pg_stat_activity is not compatible with previuos releases)
--          1.0.9 More performance statistics
--          1.0.10 Replication stats, (a) vacuum stats, (b) pg_stat_statement summary, (c) pg_buffercache
--          1.0.11 pg_stat_archiver (9.4), pg_stat_activity bkw changes (9.6), logical replication (10.1)
--                 (a) Schema/Function Matrix
--          1.0.12 HBA.conf file, datatypes usage, 10.x new wal function names, WAL list
--          1.0.13 Latest versions update
--          1.0.14 Latest versions update, relkind in pg_buffercache stat, bloat stats, HBA rules
--          1.0.15 Latest versions update, version 12 compliance
--          1.0.16 Latest versions update
--          1.0.17 Latest versions update
--          1.0.18 Per Host sessions, latest versions update, 
--	           (aur2) Customized for Aurora PostgreSQL 2.x and 3.x
--          1.0.19 Latest versions update 
--          1.0.20 Latest versions update
--          1.0.21 Latest versions update
--
-- Usage:   psql [-U USERNAME] [DBNAME] < pg2html.sql

\pset tuples_only
\pset fieldsep ' '
\a
\o pg.htm

select '<!doctype html><html><head><meta charset="UTF-8"><link rel="stylesheet" href="ux3.css" /><title>pg2html - PostgreSQL Statistics</title></head><body>' as info;
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
select '<li><A HREF="#repl">Replication</A></li>' as info;
select '<li><A HREF="#ext">Extensions</A></li>' as info;
select '<li><A HREF="#nls">NLS Settings</A></li>' as info;
select '<li><A HREF="#par">Parameters</A></li>' as info;
select '</ul></table><p><hr>' as info;
 
select '<P>Statistics generated on: '|| current_date || ' ' ||localtime
as info;
 
select 'on database: <b>'||current_database()||'</b>' as info;
select 'by user: '||user as info;

select 'using: <I><b>pg2html.aur2.sql</b> v.1.0.21.aur2' as info;
select '<br>Software by ' as info;
select '<A HREF="https://meoshome.it.eu.org/">Meo Bogliolo</A></I><p>'
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
select '<tr><td>'||' DB Size (MB):', '<! 20>',
 '<td align="right">'||trunc(sum(pg_database_size(datname))/(1024*1024))
  from pg_database;
select '<tr><td>'||' Created :',
   '<! 15>', '<td>'|| 'N/A'
  from pg_database
 where datname=current_database();
select '<tr><td>'||' Started :',
   '<! 16>', '<td>'||pg_postmaster_start_time()
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
 where name like 'archive_mode';
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
 where relkind='r';
select '<tr><td>'||' Sessions :', '<! 40>', '<td align="right">'||count(*)
 from pg_stat_activity
union
select '<tr><td>'||' Sessions (active) :', '<! 42>', '<td align="right">'||count(*)
  from pg_stat_activity
 where state = 'active';
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
select '</table><p>' as info;
select '<P><table border="2"><tr><td><b>Version check</b></td></tr>' ;
select '<tr><td><b>Version</b>',
 '<td><b> Supported</b>',
 '<td><b> Last major release (N or N-1)</b>',
 '<td><b> Last minor release (N or N-1)</b>',
 '<td><b> Notes</b>';
SELECT '<tr><td>'||substring(version() for  position('on' in version())-1);
SELECT '<td>', CASE WHEN trunc(cast(current_setting('server_version_num') as integer)/100) in (1000, 1100, 1200, 1300, 1400) THEN 'YES'
                    ELSE 'NO'
               END; -- supported
SELECT '<td>', CASE WHEN trunc(cast(current_setting('server_version_num')as integer)/100) in (1300, 1400) THEN 'YES'
                    ELSE 'NO'
               END; -- last2 release
SELECT '<td>', CASE WHEN cast(current_setting('server_version_num')as integer)
       in (90623,90624, 100020,100018,100019, 110015,110013,110014, 120010,120008,120009, 130006,130004,130005, 140000,140001,140002) THEN 'YES'
                    ELSE 'NO'
               END; -- last2 update
select '<td>Latest Releases: 14.1, 13.5, 12.9, 11.14, 10.19';
select '    <br>Latest Unsupported: 9.6.24, 9.5.25, 9.4.26, 9.3.25, 9.2.24, 9.1.24, 9.0.23, 8.4.21, 8.3.23, 8.2.23, 8.1.23, 8.0.26, 7.4.30; 6.5.3, 1.0.9';
select '</table><p>';

select '<tr><td>'||AURORA_VERSION();
SELECT '<td>YES<td><td>';
select '<td>Latest Aurora PostgreSQL Releases: 13.4, 12.8, 11.13, 10.18, 1.11 (9.6.22)';
select '</table><p><hr>';

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
select '<tr><td><b>Schema</b><td><b>Owner</b>',
 '<td><b> Table</b>',
 '<td><b> Index</b>',
 '<td><b> View</b>',
 '<td><b> Sequence</b>',
 '<td><b> Composite type</b>',
 '<td><b> Foreign table</b>',
 '<td><b> TOAST table</b>',
 '<td><b> Materialized view</b>',
 '<td><b> Partitioned table</b>',
 '<td><b> Unlogged</b>',
 '<td><b> Temporary</b>',
 '<td><b> TOTAL</b>'
as info;
select '<tr><td>'||nspname, '<td>'||rolname,
 '<td align="right">'||sum(case when relkind='r' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='i' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='v' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='S' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='c' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='f' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='t' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='m' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='p' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relpersistence='u' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relpersistence='t' THEN 1 ELSE 0 end),
 '<td align="right">'||count(*)
from pg_class, pg_roles, pg_namespace
where relowner=pg_roles.oid
  and relnamespace=pg_namespace.oid
group by rolname, nspname
order by nspname, rolname;
select '<tr><td>TOTAL<td>TOTAL',
 '<td align="right">'||sum(case when relkind='r' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='i' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='v' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='S' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='c' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='f' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='t' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='m' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='p' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relpersistence='u' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relpersistence='t' THEN 1 ELSE 0 end),
 '<td align="right">'||count(*)
from pg_class;
select '</table><p>' as info;


select '<P><A NAME="fnc"></A>' as info;
select '<P><table border="2"><tr><td><b>Owner/Function Matrix</b></td></tr>' as info;
select '<tr><td><b>Owner</b>',
 '<td><b> Internal</b>',
 '<td><b> C</b>',
 '<td><b> SQL</b>',
 '<td><b> plpgSQL</b>',
 '<td><b> TOTAL</b>',
 '<td><b> Source size</b>'
as info;
select '<tr><td>'||rolname,
       '<td align="right">'||sum(case when lanname='internal' THEN 1 ELSE 0 end),
       '<td align="right">'||sum(case when lanname='c' THEN 1 ELSE 0 end),
       '<td align="right">'||sum(case when lanname='sql' THEN 1 ELSE 0 end),
       '<td align="right">'||sum(case when lanname='plpgsql' THEN 1 ELSE 0 end),
       '<td align="right">'||count(*),
       '<td align="right">'||sum(char_length(prosrc))
  from pg_proc, pg_roles, pg_language
 where proowner=pg_roles.oid
   and prolang=pg_language.oid
 group by rolname
 order by rolname;
select '<tr><td>TOTAL',
       '<td align="right">'||sum(case when lanname='internal' THEN 1 ELSE 0 end),
       '<td align="right">'||sum(case when lanname='c' THEN 1 ELSE 0 end),
       '<td align="right">'||sum(case when lanname='sql' THEN 1 ELSE 0 end),
       '<td align="right">'||sum(case when lanname='plpgsql' THEN 1 ELSE 0 end),
       '<td align="right">'||count(*),
       '<td align="right">'||sum(char_length(prosrc))
  from pg_proc, pg_language
 where prolang=pg_language.oid;
select '</table><p><hr>' as info;

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

select '<P><table border="2"><tr><td><b>Internals</b></td></tr>' as info;
select '<tr><td><b>Tables#</b>',
 '<td><b>Rows</b>',
 '<td><b>Relpages*8</b>',
 '<td><b>Total Size</b>',
 '<td><b>Main Fork</b>',
 '<td><b>Free Space Map</b>',
 '<td><b>Visibility Map</b>',
 '<td><b>Initialization Fork</b>'
as info;
select
 '<tr><td align="right">'||to_char(count(*),'999G999G999') obj,
 '<td align="right">'||to_char(sum(reltuples),'999G999G999') rowcount,
 '<td align="right">'||to_char(trunc(sum(relpages *8)),'999G999G999') relpages,
 '<td align="right">'||to_char(trunc(sum(pg_total_relation_size(oid))/1024),'999G999G999') total,
 '<td align="right">'||to_char(trunc(sum(pg_relation_size(oid, 'main'))/1024),'999G999G999') main,
 '<td align="right">'||to_char(trunc(sum(pg_relation_size(oid, 'fsm'))/1024),'999G999G999') fsm,
 '<td align="right">'||to_char(trunc(sum(pg_relation_size(oid, 'vm'))/1024),'999G999G999') vm,
 '<td align="right">'||to_char(trunc(sum(pg_relation_size(oid, 'init'))/1024),'999G999G999') init
from pg_class
where relkind='r';
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
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>High dead tuples</b></td></tr>' as info;
select '<tr><td><b>Table</b>',
 '<td><b>Tuples</b>',
 '<td><b>Dead tuples</b>',
 '<td><b>Last autoVACUUM</b>',
 '<td><b>Last VACUUM</b>',
 '<td><b>Last autoANALYZE</b>',
 '<td><b>Last ANALYZE</b>'
as info;
select '<tr><td>'||schemaname||'.'||relname,
 '<td align="right">'||n_live_tup, '<td align="right">'||n_dead_tup,
 '<td>'||last_autovacuum, '<td>'||last_vacuum,
 '<td>'||last_autoanalyze, '<td>'||last_analyze
  from pg_stat_user_tables
 where n_dead_tup>1000
   and n_dead_tup>n_live_tup*0.05
 order by n_dead_tup desc
 limit 20;
select '</table><p><hr>' as info;

select '<P><A NAME="usr"></A>' as info;
select '<P><table border="2"><tr><td><b>Users/Roles</b></td></tr>' as info;
select '<tr><td><b>Role</b>',
 '<td><b>Login</b>',
 '<td><b>Inherit</b>',
 '<td><b>Superuser</b>',
 '<td><b>Expiry time</b>',
 '<td><b>Config</b>' 
as info;
select '<tr><td>'||rolname,
	'<td>'||rolcanlogin,
	'<td>'||rolinherit,
	'<td>'||rolsuper,
	'<td>',rolvaliduntil,
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
select '<tr><td>N/A', '<td>', '<td>Check not possible with Aurora';
select '</table><p>';

select '<P><a id="usr_hba"></a>';
select '<P><table border="2"><tr><td><b>HBA Rules</b></td></tr>' as info;
select '<tr><td><b>Type</b>','<td><b>Database</b>',
 '<td><b>User</b>',  '<td><b>Address</b>', '<td><b>Netmask</b>',
 '<td><b>Auth</b>',  '<td><b>Options</b>', '<td><b>Error</b>';
select '<tr><td>N/A<td><td><td><td><td><td><td>HBA rules not available with Aurora';
select '</table><p><hr>';

select '<P><A NAME="sql"></A>' as info;
select '<P><table><tr>';
select '<td valign="top"><table border="2"><tr><td><b>Per-User Sessions</b></td></tr>'
 as info;
select '<tr><td><b>User</b>', '<td><b>Database</b>',
       '<td><b>Count</b>', '<td><b>Active</b>' ;
select '<tr><td>',usename,
       '<td>',datname,
 	'<td>', count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end)
  from pg_stat_activity
 group by usename, datname
 order by 6 desc, 1
 limit 20;
select 	'<tr><td>TOTAL (', count(distinct usename),
 	' distinct users)<td><td>'|| count(*)
  from pg_stat_activity;
select '</table>' as info;

select '<td valign="top"><table border="2"><tr><td><b>Per-Host Sessions</b></td></tr>'
 as info;
select '<tr><td><b>User</b>', '<td><b>Database</b>',
       '<td><b>Count</b>', '<td><b>Active</b>' ;
select '<tr><td>', client_addr,
       '<td>',datname,
 	'<td>', count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end)
  from pg_stat_activity
 group by client_addr, datname
 order by 6 desc, 1
 limit 20;
select 	'<tr><td>TOTAL (', count(distinct client_addr),
 	' distinct clients)<td><td>'|| count(*)
  from pg_stat_activity;
select '</table> </table>' as info;

select '<P><table border="2"><tr><td><b>Sessions</b></td></tr>'
 as info;
select '<tr><td><b>Pid</b>',
 '<td><b>Database</b>',
 '<td><b>User</b>',
 '<td><b>Address</b>',
 '<td><b>State</b>',
 '<td><b>Query start</b>',
 '<td><b>Backend</b>',
 '<td><b>SQL</b>' ;
select 	'<tr><td>',pid,
 	'<td>',datname,
 	'<td>',usename,
 	'<td>',client_addr,
 	'<td>',state,
 	'<td>',query_start,
 	'<td>',backend_type,
 	'<td>',query
  from pg_stat_activity
 where pid<>pg_backend_pid()
 order by state, pid;
select '</table><p><hr>' as info;

select '<P><A NAME="lock"></A>'  as info;
select '<P><table border="2"><tr><td><b>Locks</b></td></tr>'
 as info;
select '<tr><td><b>Pid</b>',
 '<td><b>Type</b>',
 '<td><b>Database</b>',
 '<td><b>Relation</b>',
 '<td><b>Mode</b>',
 '<td><b>Granted</b>'
as info;
select '<tr><td>',pid, 
	'<td>',locktype, 
	'<td>', datname, 
	'<td>', relname, 
	'<td>',mode, 
	'<td>',granted
  from pg_locks l
  left join pg_catalog.pg_database d on d.oid = l.database
  left join pg_catalog.pg_class r on r.oid = l.relation
 order by granted, pid
 limit 200;
select '<tr><td>...';
select '</table><p>' as info;

select '<P><A NAME="lockd"></A>'  as info;
select '<P><table border="2"><tr><td><b>Blocking Locks</b></td></tr>'
 as info;
select '<tr><td><b>Blocked Pid</b>',
 '<td><b>Blocked User</b>',
 '<td><b>Blocking Pid</b>',
 '<td><b>Blocking User</b>',
 '<td><b> Blocked Statement</b>',
 '<td><b> Blocking Statement</b>'
as info;
SELECT '<tr><td>',blocked_locks.pid AS blocked_pid,
       '<td>',blocked_activity.usename AS blocked_user,
       '<td>',blocking_locks.pid AS blocking_pid,
       '<td>',blocking_activity.usename AS blocking_user,
       '<td>',blocked_activity.query AS blocked_statement,
       '<td>',blocking_activity.query AS current_statement_in_blocking_process
  FROM pg_catalog.pg_locks blocked_locks
       JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
       JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid
       JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
 WHERE NOT blocked_locks.GRANTED;
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
select '<tr><td><b>Class</b>','<td><b>Kind</b>',
       '<td><b>Buffers</b>',
       '<td><b>Buffered</b>',
       '<td><b>Buffers%</b>',
       '<td><b>Relation%</b>',
       '<td><b>Avg. usage</b>'
as info;
SELECT '<tr><td>', c.relname, '<td>', c.relkind, '<td align=right>', count(*),
       '<td align=right>', pg_size_pretty(count(*) * 8192),
       '<td align=right>', round(100.0 * count(*)/(SELECT setting FROM pg_settings WHERE name='shared_buffers')::integer,1),
       '<td align=right>', round(100.0 * count(*) * 8192 / pg_relation_size(c.oid),1),
	'<td align=right>', round(avg(usagecount),2)
  FROM pg_class c
 INNER JOIN pg_buffercache b ON b.relfilenode = c.relfilenode
 INNER JOIN pg_database d ON (b.reldatabase = d.oid AND d.datname = current_database())
 WHERE pg_relation_size(c.oid) > 0
 GROUP BY c.oid, c.relname, c.relkind
 ORDER BY 6 DESC
 LIMIT 20;
select '</table><p>' as info;

SELECT 'Buffer Cache size: ', pg_size_pretty(setting::bigint*8192::bigint)
  FROM pg_settings
 WHERE name='shared_buffers';
SELECT '<br>Estimated Minimal Buffer Cache size: ', pg_size_pretty(count(*) * 8192)
  FROM pg_buffercache
 WHERE usagecount >= 3;
select '<p><hr>' as info;

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
 ORDER BY total_time DESC LIMIT 20;
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


select '<pre><P><table border="2"><tr><td><b>Index Usage - Details</b></td></tr></table>' ;

select '<P><table border="2"><tr><td><b>Per-table index usage</b>' as info;
select '<tr><td><b>Relation</b><td><b>Index Usage%</b>', '<td><b> #Rows </b>', '<td><b> #Scan </b>';
SELECT '<tr><td>', relname, '<td align="right">', 100 * idx_scan / (seq_scan + idx_scan) index_used_pct,
       '<td align="right">', n_live_tup, '<td align="right">', seq_scan
  FROM pg_stat_user_tables
 WHERE seq_scan + idx_scan > 1
   AND 100 * idx_scan / (seq_scan + idx_scan) < 95
 ORDER BY n_live_tup DESC
 LIMIT 32;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Missing indexes</b>' as info;
select '<tr><td><b>Schema</b><td><b>Relation</b>', '<td><b>Contraint</b><td><b>Issue</b>',
       '<td><b>#Table Scan</b><td><b>Parent</b>', '<td><b>Columns</b>';
WITH fk_actions ( code, action ) AS (
    VALUES ( 'a', 'error' ),
        ( 'r', 'restrict' ),
        ( 'c', 'cascade' ),
        ( 'n', 'set null' ),
        ( 'd', 'set default' )
),
fk_list AS (
    SELECT pg_constraint.oid as fkoid, conrelid, confrelid as parentid,
        conname, relname, nspname,
        fk_actions_update.action as update_action,
        fk_actions_delete.action as delete_action,
        conkey as key_cols
    FROM pg_constraint
        JOIN pg_class ON conrelid = pg_class.oid
        JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
        JOIN fk_actions AS fk_actions_update ON confupdtype = fk_actions_update.code
        JOIN fk_actions AS fk_actions_delete ON confdeltype = fk_actions_delete.code
    WHERE contype = 'f'
),
fk_attributes AS (
    SELECT fkoid, conrelid, attname, attnum
    FROM fk_list
        JOIN pg_attribute
            ON conrelid = attrelid
            AND attnum = ANY( key_cols )
    ORDER BY fkoid, attnum
),
fk_cols_list AS (
    SELECT fkoid, array_agg(attname) as cols_list
    FROM fk_attributes
    GROUP BY fkoid
),
index_list AS (
    SELECT indexrelid as indexid,
        pg_class.relname as indexname,
        indrelid,
        indkey,
        indpred is not null as has_predicate,
        pg_get_indexdef(indexrelid) as indexdef
    FROM pg_index
        JOIN pg_class ON indexrelid = pg_class.oid
    WHERE indisvalid
),
fk_index_match AS (
    SELECT fk_list.*,
        indexid,
        indexname,
        indkey::int[] as indexatts,
        has_predicate,
        indexdef,
        array_length(key_cols, 1) as fk_colcount,
        array_length(indkey,1) as index_colcount,
        round(pg_relation_size(conrelid)/(1024^2)::numeric) as table_mb,
        cols_list
    FROM fk_list
        JOIN fk_cols_list USING (fkoid)
        LEFT OUTER JOIN index_list
            ON conrelid = indrelid
            AND (indkey::int2[])[0:(array_length(key_cols,1) -1)] @> key_cols
),
fk_perfect_match AS (
    SELECT fkoid
    FROM fk_index_match
    WHERE (index_colcount - 1) <= fk_colcount
        AND NOT has_predicate
        AND indexdef LIKE '%USING btree%'
),
fk_index_check AS (
    SELECT 'no index' as issue, *, 1 as issue_sort
    FROM fk_index_match
    WHERE indexid IS NULL
    UNION ALL
    SELECT 'questionable index' as issue, *, 2
    FROM fk_index_match
    WHERE indexid IS NOT NULL
        AND fkoid NOT IN (
            SELECT fkoid
            FROM fk_perfect_match)
),
parent_table_stats AS (
    SELECT fkoid, tabstats.relname as parent_name,
        (n_tup_ins + n_tup_upd + n_tup_del + n_tup_hot_upd) as parent_writes,
        round(pg_relation_size(parentid)/(1024^2)::numeric) as parent_mb
    FROM pg_stat_user_tables AS tabstats
        JOIN fk_list
            ON relid = parentid
),
fk_table_stats AS (
    SELECT fkoid,
        (n_tup_ins + n_tup_upd + n_tup_del + n_tup_hot_upd) as writes,
        seq_scan as table_scans
    FROM pg_stat_user_tables AS tabstats
        JOIN fk_list
            ON relid = conrelid
)
SELECT '<tr><td>', nspname as schema_name,
    '<td>', relname as table_name,
    '<td>', conname as fk_name,
    '<td>', issue,
    '<td>', table_scans,
    '<td>', parent_name,
    '<td>', cols_list
FROM fk_index_check
    JOIN parent_table_stats USING (fkoid)
    JOIN fk_table_stats USING (fkoid)
WHERE table_mb > 5
    AND ( writes > 1000
        OR parent_writes > 1000
        OR parent_mb > 10 )
ORDER BY table_scans DESC, table_mb DESC, table_name, fk_name
 LIMIT 64;
select '</table>' as info;

select '<P><table border="2"><tr><td><b>Unused indexes</b>' as info;
select '<tr><td><b>Schema</b><td><b>Table</b>', '<td><b>Index</b>', '<td><b>Size</b>';
SELECT '<tr><td>',s.schemaname, '<td>',s.relname,
       '<td>',s.indexrelname, '<td align="right">',pg_relation_size(s.indexrelid)
  FROM pg_catalog.pg_stat_user_indexes s
  JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
 WHERE s.idx_scan = 0      
   AND 0 <>ALL (i.indkey)  
   AND NOT i.indisunique   
   AND NOT EXISTS (SELECT 1 FROM pg_catalog.pg_constraint c
          WHERE c.conindid = s.indexrelid)
 ORDER BY pg_relation_size(s.indexrelid) DESC
 LIMIT 64;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>All indexes</b>' as info;
select '<tr><td><b>Schema</b><td><b>Relation</b>',
       '<td><b>Index</b><td><b>DDL</b>';

SELECT '<tr><td>',schemaname, '<td>',tablename,
       '<td>',indexname, '<td>',indexdef
  FROM pg_indexes
 WHERE schemaname not in ('pg_catalog')
   AND tablename not like 'pgstatspack%'
 ORDER BY schemaname, tablename, indexname;
select '</table><p></pre><hr>' as info;

select '<P><table border="2"><tr><td><b>PostgreSQL Tuning Parameters</b></td></tr>'
 as info;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>',
 '<td><b>Min</b>',
 '<td><b>Max</b>',
 '<td><b>Unit</b>',
 '<td><b>Description</b>'
as info;
select '<tr><td>',name,'<td align=right>',replace(replace(setting,'<','&lt;'),'>','&gt;'),
   '<td align=right>',min_val,'<td align=right>',max_val,
   '<td>',unit, '<td>',short_desc
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
 '<td><b>Owner</b>', '<td><b>Schema</b>',
 '<td><b>Bytes</b>',
 '<td><b>Rows</b>'
as info;
select '<tr><td>'||relname,
 '<td>'||case WHEN relkind='r' THEN 'Table' 
    WHEN relkind='i' THEN 'Index'
    WHEN relkind='t' THEN 'TOAST Table'
    ELSE relkind||'' end,
 '<td>'||rolname,  '<td>'||n.nspname,
 '<td align=right>'||to_char(relpages::INT8*8*1024,'999G999G999G999'),
 '<td align=right>'||to_char(reltuples,'999G999G999G999')
  from pg_class, pg_roles, pg_catalog.pg_namespace n
 where relowner=pg_roles.oid
   and n.oid=pg_class.relnamespace
 order by relpages desc, reltuples desc
 limit 32;
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
from pg_proc f, pg_roles o, pg_language l
where f.proowner=o.oid
 and f.prolang=l.oid
 group by o.rolname, l.lanname
 order by o.rolname, l.lanname;
select '</table><p>' as info;

select '<P><A NAME="dtype"></A>'  as info;
select '<pre><P><table border="2"><tr><td><b>Data Types - Details</b></td></tr></table>' ;
select '<P><table border="2"><tr><td><b>Data Types</b></td></tr>'
 as info;
select '<tr><td><b>Owner</b>',
 '<td><b>Data type</b>',
 '<td><b>Count</b>'
as info;
select '<tr><td>'||o.rolname, '<td>'||t.typname, '<td align="right">'||count(*)
  from pg_attribute a, pg_class r, pg_roles o, pg_type t
 where a.attrelid=r.oid
   and a.atttypid=t.oid
   and r.relowner=o.oid
 group by o.rolname, t.typname
 order by o.rolname, t.typname;
select '</table></pre><p><hr>' as info;

select '<P><A NAME="rman"></A>'  as info;
select '<P><table border="2"><tr><td><b>Physical Backup</b></td></tr>'
 as info;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
as info;
select '<tr><td>',name,'<td>',setting
 from pg_settings
 where name in ('archive_mode', 'archive_timeout')
 order by name; 
select '<tr><td>Write xlog location',
 '<td>'||pg_current_wal_lsn();
select '<tr><td>Insert xlog location',
 '<td>'||pg_current_wal_insert_lsn();
select '</table><p>' as info;

select '<P><A NAME="arch"></A>' as info;
select '<P><table border="2"><tr><td><b>Archiver Statistics</b></td></tr>'
 as info;
select '<tr><td><b> Archived Count </b>',
 '<td><b> Last Archived WAL </b>',
 '<td><b> Last Archived Time </b>',
 '<td><b> Failed Count </b>',
 '<td><b> Last Failed WAL </b>',
 '<td><b> Last Failed Time </b>',
 '<td><b> Statistics Reset </b>',
 '<td><b> Archiving </b>',
 '<td><b> WALS ps </b>'
as info;
select '<tr><td>',archived_count, '<td>',last_archived_wal, '<td>',last_archived_time, '<td>',failed_count,
       '<td>',last_failed_wal, '<td>',last_failed_time, '<td>',stats_reset,
       '<td>', current_setting('archive_mode')::BOOLEAN
                 AND (last_failed_wal IS NULL
                  OR last_failed_wal <= last_archived_wal),
       '<td>', CAST (archived_count AS NUMERIC) / EXTRACT (EPOCH FROM age(now(), stats_reset))
  from pg_stat_archiver;
select '</table><p><hr>' as info;

select '<P><A NAME="repl"></A>'  as info;
select '<P><table border="2"><tr><td><b>Replication</b></td></tr>'
 as info;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
as info;
select '<tr><td>In Recovery Mode',
 '<td><b>'||pg_is_in_recovery()||'</b>';
select '<tr><td>',name,'<td align=right>',replace(replace(setting,'<','&lt;'),'>','&gt;')
 from pg_settings
 where name in ('wal_level', 'archive_command', 'hot_standby', 'max_wal_senders',
                'wal_keep_segments', 'synchronous_standby_names')
 order by name; 
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Master Statistics</b></td></tr>' ;
select '<tr><td><b>Client</b>', '<td><b>State</b>', '<td><b>Sync</b>',
       '<td><b>Current Snapshot</b>', '<td><b>Sent loc.</b>',
       '<td><b>Write loc.</b>', '<td><b>Flush loc.</b>', '<td><b>Replay loc.</b>', '<td><b>Backend Start</b>';
select '<tr><td>',client_addr, '<td>', state, '<td>', sync_state, '<td>', txid_current_snapshot(),
       '<td>', sent_lsn, '<td>', write_lsn, '<td>', flush_lsn, '<td>', replay_lsn,
       '<td>', backend_start 
  from pg_stat_replication;
select '</table>' as info;

select '<P><table border="2"><tr><td><b>Slave Statistics</b></td></tr>' ;
select '<tr><td><b>Last Replication</b>','<td><b>Replication Delay</b>','<td><b>Current Snapshot</b>',
       '<td><b>Receive loc.</b>','<td><b>Replay loc.</b>';
select '<tr><td>', 'N/A',
       '<td>', 'N/A',
       '<td>', case when pg_is_in_recovery() then txid_current_snapshot() else null end,
       '<td>', 'N/A',  
       '<td>', 'N/A';
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Logical Replication - Subscriptions</b></td></tr>' ;
select '<tr><td><b>Subscription Name</b>','<td><b>Pid</b>','<td><b>Relation OID</b>',
       '<td><b>Received</b>','<td><b>Last Message Send</b>','<td><b>Last Message Receipt</b>',
       '<td><b>Latest location</b>','<td><b>Latest time</b>';
select '<tr><td>',subname, '<td>',pid, '<td>',relid, '<td>',received_lsn, '<td>',last_msg_send_time, 	
       '<td>',last_msg_receipt_time, '<td>',latest_end_lsn, '<td>',latest_end_time
  from pg_stat_subscription
 order by subname;
select '</table><p>' as info;

select '<pre><P><table border="2"><tr><td><b>Logical Replication - Details</b></td></tr></table>' ;

select '<P><table border="2"><tr><td><b>Publications</b></td></tr>' ;
select '<tr><td><b>Publication Name</b>','<td><b>Owner</b>',
       '<td><b>All tables</b>', '<td><b>Insert</b>', '<td><b>Update</b>', '<td><b>Delete</b>';
select '<tr><td>',pubname, '<td>',rolname,
       '<td>',puballtables, '<td>', pubinsert, '<td>', pubupdate, '<td>', pubdelete 
  from pg_publication p, pg_roles a
 where a.oid=p.pubowner
 order by pubname;
select '<tr><td><b>Publication Name</b>','<td><b>Schema</b>','<td><b>Table</b>';
select '<tr><td>',pubname, '<td>',schemaname, '<td>',tablename
  from pg_publication_tables
 order by pubname, tablename;
select '</table><p>';

select '<P><table border="2"><tr><td><b>Subscriptions</b></td></tr>' ;
select '<tr><td><b>Subscription Name</b>','<td><b>Database</b>','<td><b>Owner</b>',
       '<td><b>Enabled</b>', '<td><b>Sync. Commit</b>', '<td><b> Slot </b>', '<td><b> Connection </b>';
select '<tr><td>',subname, '<td>',datname, '<td>',rolname,
       '<td>',subenabled, '<td>', subsynccommit, '<td>', subslotname, '<td>', subconninfo
  from pg_subscription s, pg_database d, pg_roles a
 where d.oid=s.subdbid
   and a.oid=s.subowner
 order by subname;

select '<tr><td><b>Subscription Name</b>','<td><b>Schema</b>','<td><b>Table</b>',
       '<td><b>State</b>', '<td><b>LSN</b>';
select '<tr><td>',subname, '<td>', '<td>',relname,
       '<td>',srsubstate, '<td>', srsublsn 
  from pg_subscription_rel r, pg_subscription s, pg_class c
 where s.oid=r.srsubid
   and c.oid=r.srrelid
 order by subname, relname;
select '</table><p>';
select '</pre>';

select '<pre><P><table border="2"><tr><td><b>Aurora Replication</b></td></tr></table>' ;
select *
  from aurora_replica_status();
select '</pre><hr>';

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
order by case when installed_version is null then 1 else 0 end, name;
select '<tr><td>postgis<td><td><td>PostGIS installed (pre-extensions check)' pg 
from pg_proc 
where proname='postgis_version';
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
 '<td><b>Unit</b>',
 '<td><b>Description</b>'
as info;
select '<tr><td>',name,'<td class="split">',replace(replace(setting,'<','&lt;'),'>','&gt;'),
   '<td align=right>',min_val,'<td align=right>',max_val,
   '<td>',unit, '<td>',short_desc
from pg_settings
order by name; 
select '</table><p><hr>' as info;

select '<P><A NAME="pghba"></A>'  as info;
select '<P><table border="2"><tr><td><b>HBA file</b></td></tr>';
select '<tr><td><pre>' as info;
select 'N/A with Aurora';
select '</pre></table><p><hr>' as info;


select '<P><A NAME="wal"></A>'  as info;
select '<P><table border="2"><tr><td><b>WAL files</b></td></tr>';
select '<tr><td><pre>' as info;
select 'N/A with Aurora';
select '</pre></table><p><hr>' as info;

select '<P>Statistics generated on: '|| current_date || ' ' ||localtime as info;
select '<br>More info on' as info;
select '<A HREF="https://meoshome.it.eu.org/">this site</A>' as info;
select 'or contact' as info;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo</A>.<p></body></html>' as info;
