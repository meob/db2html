-- Program: pg2html.sql
-- Info:    PostgreSQL report in HTML
--          Works with PostgreSQL 10 or sup. (tested and updated up to 16.x)
-- Date:    2008-08-15
-- Version: 1.0.28a on 2024-08-15
-- Author:  Bartolomeo Bogliolo (meo) mail [AT] meo.bogliolo.name
-- Usage:   psql [-U USERNAME] [DBNAME] < pg2html.sql > /dev/null
-- Notes:   1-APR-08 mail [AT] meo.bogliolo.name
--          1.0.0 First version based on ora2html (Oracle report in HTML)
--          1.0.3 Minor changes (eg. formatting, alignment)
--          1.0.4 TOTAL for objects, space usage, roles
--          1.0.5 HTML5, function count
--          1.0.6 PG 9.1 new features (if <9.1 gives an error on pg_available_extension)
--          1.0.7 Added poor password check (a) session summary
--          1.0.8 PG 9.2 new features (NB pg_stat_activity is not compatible with previuos releases)
--          1.0.9 More performance statistics
--          1.0.10 Replication stats, (a) vacuum stats, (b) pg_stat_statement summary, (c) pg_buffercache
--                 pg_stat_statement, pg_buffercache extensions must be created to get all the infos
--          1.0.11 pg_stat_archiver (PG 9.4), pg_stat_activity bkw changes (PG 9.6), logical replication (PG 10.1)
--                 (a) Schema/Function Matrix
--          1.0.12 HBA.conf file, datatypes usage, PG 10.x new wal function names, WAL list
--          1.0.13 Latest versions update
--          1.0.14 Latest versions update, relkind in pg_buffercache stat, bloat stats, HBA rules
--          1.0.15 Latest versions update, version PG12 compliance
--          1.0.16 Latest versions update
--          1.0.17 Latest versions update
--          1.0.18 Per Host sessions, latest versions update
--          1.0.19 Both owner/schema in matrix, latest versions update
--          1.0.20 Latest versions update, (a) May 2021 updates, (b) SCRAM encryption in passwords
--          1.0.21 Latest versions update, fork for version PG13
--          1.0.22 Dynamic version: works for all PG supported releases (10+..PG14) and with details for created extensions; bigint casting
--          1.0.23 Latest versions update, (a) \if bug fixed (b) limit on the all index list (c,d,e,f) latest versions update
--          1.0.24 WAL bytes in pg_stat_statements, users/roles, (a) pg_stat_wal_receiver, pg_replication_slots (b) pg_stat_statements_info
--          1.0.25 Largest TOAST list, Stored Procedures count, Partitioning details, some graphical fixes, EnterpriseDB filter,
--                 PG16, estimated bloat, triggers, Postgis/Aurora/EDB/... additional statistics, latest versions update
--                 (a) constraints, statistic histograms (opt.), -IOTime (b) pg_ls_logdir
--          1.0.26 Latest versions update, (a) added some nullif
--          1.0.27 Latest versions update, small changes, (a) PG16, (b) progress stats, toplevel (c) small changes (d) VU
--                 (e) backend_start in activities, PG17 queries (f) fixed a small bug in database statistics, column collations
--                 (g) version update, application_name, better data type details, pg_stats info also for colums without histograms
--                 (h) pg_stat_checkpointer, extended statistics (i) event triggers for PG17 planned login trigger
--                 (l) toplevel, lock count(*) (m) schema/object reorg, biggest partitioned objs, subpartitioning details
--                 (n) pgstatspack stats (o) pg_buffercache stats moved to the optional/dynamic section, tablespaces space usage
--                 (p) autoconf file (q) version update
--          1.0.28 pgvector, ... (a) minor changes, waitstart

\pset tuples_only
\pset fieldsep ' '
\pset footer off
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
select '<li><A HREF="#obj">Schema/Object Matrix</A></li>' as info;
select '<li><A HREF="#tbs">Tablespaces</A></li>' as info;
select '<li><A HREF="#usg">Space Usage</A> (<A HREF="#vacuum">VACUUM</A>) </li>' as info;
select '<li><A HREF="#usr">Users</A></li>' as info;
select '<li><A HREF="#sql">Sessions</A></li>' as info;
select '<li><A HREF="#lockd">Locks</A></li>' as info;
select '<li><A HREF="#sga">Memory</A></li>' as info;
select '</ul><td><ul>' as info;
select '<li><A HREF="#stat">Performance Statistics</A></li>' as info;
select '  (<A HREF="#stat">Instance</A>, <A HREF="#stmt">Statements</A>, <A HREF="#slow">Slow</A>, <A HREF="#tbl">Tables</A>, ';
select '   <A HREF="#idx">Indexes</A>, <A HREF="#partdet">Partitions</A>, <A HREF="#param">Tuning Parameters</A>)';
select '<li><A HREF="#big">Biggest Objects</A></li>' as info;
select '<li><A HREF="#psq">PLPGSQL, data types</A></li>' as info;
select '<li><A HREF="#rman">Backup</A></li>' as info;
select '<li><A HREF="#repl">Replication</A></li>' as info;
select '<li><A HREF="#ext">Extensions</A></li>' as info;
select '<li><A HREF="#nls">NLS Settings</A></li>' as info;
select '<li><A HREF="#par">Parameters</A></li>' as info;
select '<li><A HREF="#logs">Logs (log, wal)</A></li>' as info;
select '<li><A HREF="#opt">Additional Statistics</A></li>' as info;
select '</ul></table><p><hr>' as info;
 
select '<P>Report generated on: '|| now();
 
select 'on database: <b>'||current_database()||'</b>' as info;
select 'by user: '||user as info;

select 'using: <I><b>pg2html.sql</b> v.1.0.28a' as info;
select '<br>Software by ' as info;
select '<A HREF="http://meoshome.it.eu.org">Meo</A></I><p>'
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
select '<tr><td>'||' DB Size:', '<! 20>',
 '<td align="right">'||pg_size_pretty(sum(pg_database_size(datname)))
  from pg_database;
select '<tr><td>'||' Created :',
   '<! 15>', '<td>'|| (pg_stat_file('base/'||oid ||'/PG_VERSION')).modification
  from pg_database
 where datname='template0';
select '<tr><td>'||' Started :',
   '<! 16>', '<td>'||pg_postmaster_start_time()
union
select '<tr><td>'||' Memory buffers (MB) :',
   '<! 24>', '<td align="right">'||trunc(sum(setting::int*8)/1024)
  from pg_settings
 where name in ('shared_buffers', 'wal_buffers', 'temp_buffers')
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
select '<tr><td>'||' Defined Users/Roles :',
   '<! 31>', '<td align="right">'||sum(case when rolcanlogin then 1 else 0 end)||
   ' / '|| sum(case when rolcanlogin then 0 else 1 end)
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
select '<tr><td>'||' Port (used):',
   '<! 52>', '<td align="right">'||inet_server_port()
union
select '<tr><td>'||' Port (configured):',
   '<! 53>', '<td align="right">'||setting
  from pg_settings where name='port'
order by 2;
select '</table><p><hr>' as info;


SELECT cast(current_setting('server_version_num')as integer)>= 110000 as version_11p
\gset var_

SELECT cast(current_setting('server_version_num')as integer)>= 120000 as version_12p
\gset var_

SELECT cast(current_setting('server_version_num')as integer)>= 130000 as version_13p
\gset var_

SELECT cast(current_setting('server_version_num')as integer)>= 140000 as version_14p
\gset var_

SELECT cast(current_setting('server_version_num')as integer)>= 150000 as version_15p
\gset var_

SELECT cast(current_setting('server_version_num')as integer)>= 160000 as version_16p
\gset var_

SELECT cast(current_setting('server_version_num')as integer)>= 170000 as version_17p
\gset var_


select '<P><A NAME="ver"></A>' as info;
select '<P><table border="2"><tr><td><b>Version</b></td></tr>' as info;
select '<tr><td>'||version()||'<td>'|| current_setting('server_version')||'<td>'|| current_setting('server_version_num');
select '</table><p>' as info;
select '<P><table border="2"><tr><td><b>Version check</b></td></tr>' ;
select '<tr><td><b>Version</b>',
 '<td><b> Supported</b>',
 '<td><b> Recent major release (up to N-2)</b>',
 '<td><b> Recent minor release (up to N-1)</b>',
 '<td><b> Notes</b>';
SELECT '<tr><td>'||substring(version() for  position('on' in version())-1);
SELECT '<td>', CASE WHEN trunc(cast(current_setting('server_version_num') as integer)/100)
  in (1200, 1300, 1400, 1500, 1600) THEN 'YES'
  ELSE 'NO' END;
SELECT '<td>', CASE WHEN trunc(cast(current_setting('server_version_num')
  as integer)/100)
  in (1400, 1500, 1600) THEN 'YES'
  ELSE 'NO' END; -- last2 release
SELECT '<td>', CASE WHEN cast(current_setting('server_version_num') as integer)
  in (90624,100023, 110022,110021,110020,
  120020,120019,120018,
  130016,130015,130014,
  140013,140012,140011,
  150008,150007,150006,
  160004,160003,160002) THEN 'YES'
  ELSE 'NO' END; -- last2 update
select '<td>Latest Releases: 16.4, 15.8, 14.13, 13.16, 12.20';
select '    <br>Latest Unsupported: 11.22, 10.23, 9.6.24, 9.5.25, 9.4.26, 9.3.25, 9.2.24, 9.1.24, 9.0.23,';
select '    8.4.21, 8.3.23, 8.2.23, 8.1.23, 8.0.26; 7.4.30, 6.5.3';
select '</table><p><hr>';

select '<P><A NAME="dbs"></A>' as info;
select '<P><table border="2"><tr><td><b>Databases</b></td></tr>' as info;
select '<tr><td><b>Name</b>', '<td><b>OID</b>', '<td><b>Owner</b>',
 '<td><b>Size</b>',
 '<td><b>HR Size</b>'
as info;
select '<tr><td>'||datname, '<td>',oid, '<td>',datdba::regrole::text,
 '<td align=right>'||pg_database_size(datname),
 '<td align=right>'||pg_size_pretty(pg_database_size(datname))
  from pg_database
 where not datistemplate;
select '<tr><tr><td>TOTAL (MB)','<td>','<td>',
 '<td align=right>'||trunc(sum(pg_database_size(datname))/(1024*1024)),
 '<td align=right>'||pg_size_pretty(sum(pg_database_size(datname))::int8)
from pg_database;
select '</table><p><hr>' as info;


select '<P><A NAME="obj"></A>' as info;
select '<P><table border="2"><tr><td><b>Schema/Object Matrix</b></td></tr>' as info;
select '<tr><td><b>Schema</b><td><b>Owner</b>',
 '<td><b> Table</b>',
 '<td><b> Index</b>',
 '<td><b> Part. Table</b>',
 '<td><b> Part. Index</b>',
 '<td><b> View</b>',
 '<td><b> Sequence</b>',
 '<td><b> Composite type</b>',
 '<td><b> Foreign table</b>',
 '<td><b> TOAST table</b>',
 '<td><b> Materialized view</b>',
 '<td><b> TOTAL</b>'
 '<td><b> Partitions</b>',
 '<td><b> Not Partitions</b>',
 '<td><b> Unlogged</b>',
 '<td><b> Temporary</b>'
as info;
select '<tr><td>'||nspname, '<td>'||rolname,
 '<td align="right">'||sum(case when relkind='r' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='i' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='p' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='I' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='v' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='S' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='c' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='f' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='t' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='m' THEN 1 ELSE 0 end),
 '<td align="right">'||count(*),
 '<td align="right">'||coalesce(sum(case when relkind in ('r','p') THEN case when relispartition then 1 else 0 end else 0 end),0),
 '<td align="right">'||coalesce(sum(case when relkind in ('r','p') THEN case when relispartition then 0 else 1 end else 0 end),0),
 '<td align="right">'||sum(case when relpersistence='u' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relpersistence='t' THEN 1 ELSE 0 end)
from pg_class, pg_roles, pg_namespace
where relowner=pg_roles.oid
  and relnamespace=pg_namespace.oid
--  and rolname not in ('enterprisedb')
group by rolname, nspname
order by nspname, rolname;
select '<tr><td>TOTAL<td>TOTAL',
 '<td align="right">'||sum(case when relkind='r' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='i' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='p' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='I' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='v' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='S' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='c' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='f' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='t' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='m' THEN 1 ELSE 0 end),
 '<td align="right">'||count(*),
 '<td align="right">'||coalesce(sum(case when relkind in ('r','p') THEN case when relispartition then 1 else 0 end else 0 end),0),
 '<td align="right">'||coalesce(sum(case when relkind in ('r','p') THEN case when relispartition then 0 else 1 end else 0 end),0),
 '<td align="right">'||sum(case when relpersistence='u' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relpersistence='t' THEN 1 ELSE 0 end)
from pg_class;
select '</table><p>' as info;

select '<P><A NAME="const"></A>' as info;
select '<P><table border="2"><tr><td><b>Constraints</b></td></tr>' as info;
select '<tr><td><b>Schema</b>',
 '<td><b> Primary</b>',
 '<td><b> Unique</b>',
 '<td><b> Foreign</b>',
 '<td><b> Check</b>',
 '<td><b> Trigger</b>',
 '<td><b> Exclusion</b>',
 '<td><b> TOTAL</b>'
as info;
select '<tr><td>'||nspname,
 '<td align="right">'||sum(case when contype ='p' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when contype ='u' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when contype ='f' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when contype ='c' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when contype ='t' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when contype ='x' THEN 1 ELSE 0 end),
 '<td align="right">'||count(*)
from pg_constraint, pg_namespace
where connamespace=pg_namespace.oid
  and nspname NOT IN('information_schema', 'pg_catalog')
group by nspname
order by nspname;
select '</table><p>' as info;

select '<P><A NAME="part"></A>' as info;
select '<P><table border="2"><tr><td><b><a href="#partdet">Partitions</a></b></td></tr>' as info;
select '<tr><td><b>Schema</b><td><b>Owner</b>',
 '<td><b> Object Type</b>',
 '<td><b> Partitioned Objects</b>',
 '<td><b> Partitions</b>';
select '<tr><td>'||nspname, '<td>'||rolname, '<td>'||t.relkind::text,
   '<td align="right">', count(distinct t.relname),
   '<td align="right">', count(*)
  from pg_class t, pg_inherits i, pg_class p, pg_roles r, pg_namespace n
 where i.inhparent = t.oid 
   and p.oid = i.inhrelid
   and t.relowner=r.oid
   and t.relnamespace=n.oid
 group by rolname, nspname, t.relkind
 order by t.relkind desc, nspname, rolname;
select '</table><p>' as info;

select '<P><A NAME="fnc"></A>' as info;
select '<P><table border="2"><tr><td><b>Schema/Function Matrix</b></td></tr>' as info;
select '<tr><td><b>Schema</b><td><b>Owner</b>',
 '<td><b> Functions</b>',
 '<td><b> Procedures</b>',
 '<td><b> TOTAL</b>'
as info;
select '<tr><td>'||nspname, '<td>'||rolname, 
  '<td align="right">'||sum(case when prokind='p' THEN 0 ELSE 1 end),
  '<td align="right">'||sum(case when prokind='p' THEN 1 ELSE 0 end),
  '<td align="right">'||count(*)
  from pg_proc, pg_roles, pg_language, pg_namespace n
 where proowner=pg_roles.oid
   and prolang=pg_language.oid
   and pronamespace=n.oid
   and rolname not in ('postgres', 'enterprisedb')
 group by nspname, rolname
 order by nspname, rolname;
select '<tr><td>TOTAL<td>TOTAL',
  '<td align="right">'||sum(case when prokind='p' THEN 0 ELSE 1 end),
  '<td align="right">'||sum(case when prokind='p' THEN 1 ELSE 0 end),
  '<td align="right">'||count(*)
  from pg_proc, pg_roles, pg_language, pg_namespace n
 where proowner=pg_roles.oid
   and prolang=pg_language.oid
   and pronamespace=n.oid
   and rolname not in ('postgres', 'enterprisedb');
select '</table><p>' as info;

select '<P><A NAME="trg"></A>' as info;
select '<P><table border="2"><tr><td><b>Schema/Trigger Matrix</b></td></tr>' as info;
select '<tr><td><b>Schema</b>',
 '<td><b> INSERT</b>',
 '<td><b> UPDATE</b>',
 '<td><b> DELETE</b>',
 '<td><b> Row</b>',
 '<td><b> Statement</b>',
 '<td><b> BEFORE</b>',
 '<td><b> AFTER</b>',
 '<td><b> INSTEAD</b>',
 '<td><b> TOTAL</b>'
as info;
select '<tr><td>'||trigger_schema,
 '<td align="right">'||sum(case when event_manipulation='INSERT' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when event_manipulation='UPDATE' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when event_manipulation='DELETE' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when action_orientation='ROW' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when action_orientation='STATEMENT' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when action_timing='BEFORE' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when action_timing='AFTER' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when action_timing='INSTEAD OF' THEN 1 ELSE 0 end),
 '<td align="right">'||count(*)
  from information_schema.triggers
 group by trigger_schema
 order by trigger_schema;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Event Triggers</b></td></tr>' as info;
select '<tr><td><b>Event</b>',
 '<td><b> Name</b>',
 '<td><b> Owner</b>',
 '<td><b> Function</b>',
 '<td><b> Enabled</b>',
 '<td><b> Enable mode</b>',
 '<td><b> Tags</b>';
select '<tr><td>'||evtevent, '<td>'||evtname, '<td>', evtowner::regrole::text, '<td>', evtfoid::regproc::text,
       '<td>', evtenabled, '<td>',
       case when evtenabled='A' then 'Always'
            when evtenabled='O' then 'Origin or Local'  
            when evtenabled='R' then 'Replica'  
            when evtenabled='D' then 'Disabled'
       end as evt_mode,
       '<td>', evttags  
  from pg_event_trigger
 order by evtevent, evtname;
select '</table><p><hr>' as info;

select '<P><A NAME="tbs"></A>' as info;
select '<P><table border="2"><tr><td><b>Tablespaces</b></td></tr>' as info;
select '<tr><td><b>Name</b>', '<td><b>Owner</b>', '<td><b>Location</b>', '<td><b>HR Size</b>' as info;
select '<tr><td>'||spcname, '<td>',pg_catalog.pg_get_userbyid(spcowner),
  '<td>',pg_catalog.pg_tablespace_location(oid),
  '<td align="right">', pg_size_pretty (pg_tablespace_size (spcname))
  from pg_tablespace
 order by spcname;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Tablespace Space Usage</b></td></tr>' as info;
select '<tr><td><b>Tablespace</b>',
 '<td><b>Table#</b>',
 '<td><b>Tables rows</b>',
 '<td><b>Tables KBytes</b>',
 '<td><b>Indexes KBytes</b>',
 '<td><b>TOAST KBytes</b>',
 '<td><b>Total KBytes</b>'
as info;
select '<tr><td>', spcname,
 '<td align="right">'||to_char(sum(case when relkind='r' THEN 1 ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(sum(case when relkind='r' THEN greatest(reltuples,0) ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='r' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='i' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='t' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(cast(1 as bigint)* relpages *8)),'999G999G999G999G999G999G999')
from pg_class
left join pg_tablespace on reltablespace=pg_tablespace.oid
group by spcname
order by spcname;
select '</table><p><hr>' as info;

select '<P><A NAME="usg"></A>' as info;
select '<P><table border="2"><tr><td><b>Space Usage</b></td></tr>' as info;
select '<tr><td><b>Schema</b><td><b>Owner</b>',
 '<td><b>Table#</b>',
 '<td><b>Tables rows</b>',
 '<td><b>Tables KBytes</b>',
 '<td><b>Indexes KBytes</b>',
 '<td><b>TOAST KBytes</b>',
 '<td><b>Total KBytes</b>'
as info;
select '<tr><td>'||nspname, '<td>'||rolname,
 '<td align="right">'||to_char(sum(case when relkind='r' THEN 1 ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(sum(case when relkind='r' THEN greatest(reltuples,0) ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='r' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='i' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='t' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(cast(1 as bigint)* relpages *8)),'999G999G999G999G999G999G999')
from pg_class, pg_roles, pg_namespace
where relowner=pg_roles.oid
  and relnamespace=pg_namespace.oid
group by rolname, nspname
order by nspname, rolname;
select '<tr><td>TOTAL<td>TOTAL',
 '<td align="right">'||to_char(sum(case when relkind='r' THEN 1 ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(sum(case when relkind='r' THEN reltuples ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='r' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='i' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='t' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td align="right">'||to_char(trunc(sum(cast(1 as bigint)* relpages *8)),'999G999G999G999G999G999G999')
from pg_class;
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
 '<tr><td align="right">'||to_char(count(*),'999G999G999999G999G999G999') obj,
 '<td align="right">'||to_char(sum(reltuples),'999G999G999G999G999G999G999') as rowcount,
 '<td align="right">'||to_char(trunc(sum(cast(1 as bigint)*relpages *8)),'999G999G999G999G999G999G999') relpages,
 '<td align="right">'||to_char(trunc(sum(pg_total_relation_size(oid))/1024),'999G999G999G999G999G999G999') total,
 '<td align="right">'||to_char(trunc(sum(pg_relation_size(oid, 'main'))/1024),'999G999G999G999G999G999G999') main,
 '<td align="right">'||to_char(trunc(sum(pg_relation_size(oid, 'fsm'))/1024),'999G999G999G999G999G999G999') fsm,
 '<td align="right">'||to_char(trunc(sum(pg_relation_size(oid, 'vm'))/1024),'999G999G999G999G999G999G999') vm,
 '<td align="right">'||to_char(trunc(sum(pg_relation_size(oid, 'init'))/1024),'999G999G999G999G999G999G999') init
from pg_class
where relkind='r';
select '</table><p>' as info;


select '<A NAME="vacuum"></A><P><table border="2"><tr><td><b>Vacuum and Analyze</b></td></tr>' as info;
select '<tr><td><b># Tables</b>',
 '<td><b>Last autoVACUUM</b>',
 '<td><b>Last VACUUM</b>',
 '<td><b>Last autoANALYZE</b>',
 '<td><b>Last ANALYZE</b>'
as info;
select '<tr><td align="right">'||count(*), '<td>'||coalesce(max(last_autovacuum)::TEXT, ' '), '<td>'||coalesce(max(last_vacuum)::TEXT, ' '),
 '<td>'||coalesce(max(last_autoanalyze)::TEXT, ' '), '<td>'||coalesce(max(last_analyze)::TEXT, ' ')
 from pg_stat_user_tables;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>High dead tuples</b></td></tr>' as info;
select '<tr><td><b>Table</b>',
 '<td><b>Tuples</b>',
 '<td><b>Dead tuples</b>',
 '<td><b>Dead%</b>',
 '<td><b>Last autoVACUUM</b>',
 '<td><b>Last VACUUM</b>',
 '<td><b>Last autoANALYZE</b>',
 '<td><b>Last ANALYZE</b>'
as info;
select '<tr><td>'||schemaname||'.'||relname,
 '<td align="right">'||n_live_tup, '<td align="right">'||n_dead_tup,
 '<td align="right">'||round(100*n_dead_tup/(n_live_tup+n_dead_tup)::float),
 '<td>'||coalesce(last_autovacuum::TEXT, ' '), '<td>'||coalesce(last_vacuum::TEXT, ' '),
 '<td>'||coalesce(last_autoanalyze::TEXT, ' '), '<td>'||coalesce(last_analyze::TEXT, ' ')
  from pg_stat_all_tables
 where n_dead_tup>1000
   and n_dead_tup>n_live_tup*0.05
 order by n_dead_tup desc
 limit 20;

select '<tr><td><b>Big Table</b>',
 '<td><b>Tuples</b>',
 '<td><b>Dead tuples</b>',
 '<td><b>-</b>',
 '<td><b>Last autoVACUUM</b>',
 '<td><b>Last VACUUM</b>',
 '<td><b>Last autoANALYZE</b>',
 '<td><b>Last ANALYZE</b>'
as info;
select '<tr><td>'||schemaname||'.'||relname,
 '<td align="right">'||n_live_tup, '<td align="right">'||n_dead_tup,
 '<td align="right">-',
 '<td>'||coalesce(last_autovacuum::TEXT, ' '), '<td>'||coalesce(last_vacuum::TEXT, ' '),
 '<td>'||coalesce(last_autoanalyze::TEXT, ' '), '<td>'||coalesce(last_analyze::TEXT, ' ')
  from pg_stat_all_tables
 order by n_live_tup+n_dead_tup desc
 limit 5;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Bloated tables (estimated size)</b></td></tr>' as info;
select '<tr><td><b>Table</b>',
 '<td><b>Fillfactor</b>',
 '<td><b>Table Size</b>',
 '<td><b>HR Size</b>',
 '<td><b>Bloat</b>',
 '<td><b>HR Bloat</b>',
 '<td><b>Bloat%</b>'
as info;
SELECT '<tr><td>'||schemaname||'.'||tblname, '<td align="right">'||fillfactor, 
       '<td align="right">'||bs*tblpages AS real_size, '<td align="right">'||pg_size_pretty(bs*tblpages) as HR_size,
  '<td align="right">', CASE WHEN tblpages - est_tblpages_ff > 0
    THEN (tblpages-est_tblpages_ff)*bs
    ELSE 0
  END AS bloat_size,
  '<td align="right">', CASE WHEN tblpages - est_tblpages_ff > 0
    THEN pg_size_pretty( ((tblpages-est_tblpages_ff)*bs)::bigint)
    ELSE '0'
  END AS hr_bloat_size,
  '<td align="right">', CASE WHEN tblpages > 0 AND tblpages - est_tblpages_ff > 0
    THEN round(100*(tblpages - est_tblpages_ff)/tblpages::float)
    ELSE 0
  END, '%'
FROM (
  SELECT ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
    tblpages, fillfactor, bs, tblid, schemaname, tblname, heappages, toastpages, is_na
  FROM (
    SELECT
      ( 4 + tpl_hdr_size + tpl_data_size + (2*ma)
        - CASE WHEN tpl_hdr_size%ma = 0 THEN ma ELSE tpl_hdr_size%ma END
        - CASE WHEN ceil(tpl_data_size)::int%ma = 0 THEN ma ELSE ceil(tpl_data_size)::int%ma END
      ) AS tpl_size, bs - page_hdr AS size_per_block, (heappages + toastpages) AS tblpages, heappages,
      toastpages, reltuples, toasttuples, bs, page_hdr, tblid, schemaname, tblname, fillfactor, is_na
    FROM (
      SELECT
        tbl.oid AS tblid, ns.nspname AS schemaname, tbl.relname AS tblname, tbl.reltuples,
        tbl.relpages AS heappages, coalesce(toast.relpages, 0) AS toastpages,
        coalesce(toast.reltuples, 0) AS toasttuples,
        coalesce(substring(
          array_to_string(tbl.reloptions, ' ')
          FROM 'fillfactor=([0-9]+)')::smallint, 100) AS fillfactor,
        current_setting('block_size')::numeric AS bs,
        CASE WHEN version()~'mingw32' OR version()~'64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END AS ma,
        24 AS page_hdr,
        23 + CASE WHEN MAX(coalesce(s.null_frac,0)) > 0 THEN ( 7 + count(s.attname) ) / 8 ELSE 0::int END
           + CASE WHEN bool_or(att.attname = 'oid' and att.attnum < 0) THEN 4 ELSE 0 END AS tpl_hdr_size,
        sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 0) ) AS tpl_data_size,
        bool_or(att.atttypid = 'pg_catalog.name'::regtype)
          OR sum(CASE WHEN att.attnum > 0 THEN 1 ELSE 0 END) <> count(s.attname) AS is_na
      FROM pg_attribute AS att
        JOIN pg_class AS tbl ON att.attrelid = tbl.oid
        JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
        LEFT JOIN pg_stats AS s ON s.schemaname=ns.nspname
          AND s.tablename = tbl.relname AND s.inherited=false AND s.attname=att.attname
        LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
      WHERE NOT att.attisdropped
        AND tbl.relkind in ('r','m')
      GROUP BY 1,2,3,4,5,6,7,8,9,10
      ORDER BY 2,3
    ) AS s
  ) AS s2
) AS s3
where not is_na
  and tblpages-est_tblpages_ff>0
ORDER BY 6 desc limit 20;

select '<tr><td><b>Bloated tables (estimated percentage)</b></td></tr>' as info;
select '<tr><td><b>Table</b>',
 '<td><b>Fillfactor</b>',
 '<td><b>Table Size</b>',
 '<td><b>HR Size</b>',
 '<td><b>Bloat</b>',
 '<td><b>HR Bloat</b>',
 '<td><b>Bloat%</b>'
as info;
SELECT '<tr><td>'||schemaname||'.'||tblname, '<td align="right">'||fillfactor, 
       '<td align="right">'||bs*tblpages AS real_size, '<td align="right">'||pg_size_pretty(bs*tblpages) as HR_size,
  '<td align="right">', CASE WHEN tblpages - est_tblpages_ff > 0
    THEN (tblpages-est_tblpages_ff)*bs
    ELSE 0
  END AS bloat_size,
  '<td align="right">', CASE WHEN tblpages - est_tblpages_ff > 0
    THEN pg_size_pretty( ((tblpages-est_tblpages_ff)*bs)::bigint)
    ELSE '0'
  END AS hr_bloat_size,
  '<td align="right">', CASE WHEN tblpages > 0 AND tblpages - est_tblpages_ff > 0
    THEN round(100*(tblpages - est_tblpages_ff)/tblpages::float)
    ELSE 0
  END, '%'
FROM (
  SELECT ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
    tblpages, fillfactor, bs, tblid, schemaname, tblname, heappages, toastpages, is_na
  FROM (
    SELECT
      ( 4 + tpl_hdr_size + tpl_data_size + (2*ma)
        - CASE WHEN tpl_hdr_size%ma = 0 THEN ma ELSE tpl_hdr_size%ma END
        - CASE WHEN ceil(tpl_data_size)::int%ma = 0 THEN ma ELSE ceil(tpl_data_size)::int%ma END
      ) AS tpl_size, bs - page_hdr AS size_per_block, (heappages + toastpages) AS tblpages, heappages,
      toastpages, reltuples, toasttuples, bs, page_hdr, tblid, schemaname, tblname, fillfactor, is_na
    FROM (
      SELECT
        tbl.oid AS tblid, ns.nspname AS schemaname, tbl.relname AS tblname, tbl.reltuples,
        tbl.relpages AS heappages, coalesce(toast.relpages, 0) AS toastpages,
        coalesce(toast.reltuples, 0) AS toasttuples,
        coalesce(substring(
          array_to_string(tbl.reloptions, ' ')
          FROM 'fillfactor=([0-9]+)')::smallint, 100) AS fillfactor,
        current_setting('block_size')::numeric AS bs,
        CASE WHEN version()~'mingw32' OR version()~'64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END AS ma,
        24 AS page_hdr,
        23 + CASE WHEN MAX(coalesce(s.null_frac,0)) > 0 THEN ( 7 + count(s.attname) ) / 8 ELSE 0::int END
           + CASE WHEN bool_or(att.attname = 'oid' and att.attnum < 0) THEN 4 ELSE 0 END AS tpl_hdr_size,
        sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 0) ) AS tpl_data_size,
        bool_or(att.atttypid = 'pg_catalog.name'::regtype)
          OR sum(CASE WHEN att.attnum > 0 THEN 1 ELSE 0 END) <> count(s.attname) AS is_na
      FROM pg_attribute AS att
        JOIN pg_class AS tbl ON att.attrelid = tbl.oid
        JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
        LEFT JOIN pg_stats AS s ON s.schemaname=ns.nspname
          AND s.tablename = tbl.relname AND s.inherited=false AND s.attname=att.attname
        LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
      WHERE NOT att.attisdropped
        AND tbl.relkind in ('r','m')
      GROUP BY 1,2,3,4,5,6,7,8,9,10
      ORDER BY 2,3
    ) AS s
  ) AS s2
) AS s3
where not is_na
  and tblpages-est_tblpages_ff>0
  and tblpages>2
ORDER BY 10 desc, 6 desc limit 5;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Database max age</b></td></tr>' as info;
select '<tr><td><b>Database</b>',
 '<td><b>Max XID age</b>', 
 '<td><b>% Wraparound</b>'
as info;
SELECT '<tr><td>'||datname||'<td align="right">', age(datfrozenxid), '<td>',
       (age(datfrozenxid)::numeric/2000000000*100)::numeric(4,2) as "% Wraparound"
  FROM pg_database
 ORDER BY 2 DESC;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Relations too aged</b></td></tr>' as info;
select '<tr><td><b>Schema</b>', '<td><b>Relation</b>',
 '<td><b>XID age</b>'
as info;
SELECT '<tr><td>'|| nspname ||'<td>'|| relname ||'<td align="right">', age(relfrozenxid)
  FROM pg_class
  JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
 WHERE relkind = 'r'
   AND age(relfrozenxid)> 2^28
 ORDER by 2 DESC;
select '</table><p><hr>' as info;

select '<P><A NAME="usr"></A>' as info;
select '<P><table border="2"><tr><td><b>Users/Roles</b></td></tr>' as info;
select '<tr><td><b>Role</b>',
 '<td><b>Login</b>',
 '<td><b>Inherit</b>',
 '<td><b>Superuser</b>',
 '<td><b>Expiry time</b>',
 '<td><b>Max Connections</b>',
 '<td><b>Config</b>' 
as info;
select '<tr><td>'||rolname,
	'<td>'||rolcanlogin,
	'<td>'||rolinherit,
	'<td>'||rolsuper,
	'<td>',rolvaliduntil,
	'<td>',rolconnlimit,
	'<td>'||rolconfig::text
from pg_roles
order by rolcanlogin desc, rolname;
select '<tr><td>TOTAL Users',
	'<td align=right>'||count(*)
from pg_roles where rolcanlogin;
select '<tr><td>TOTAL Roles',
	'<td align=right>'||count(*)
from pg_roles where not rolcanlogin;
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
         md5('pippo'|| usename), md5('manager'|| usename), md5('changeme'|| usename), md5('pwd'|| usename),
         md5('changeme'|| usename), md5('xxx'|| usename), md5('toor'|| usename), md5('supervisor'|| usename))
order by usename;
select '<tr><td>',usename, '<td>', passwd, '<td>Same as user'
 from pg_shadow
 where substr(passwd,4) = md5(usename||usename)
order by usename;
select '<tr><td>',usename, '<td>', passwd, '<td>Empty password'
 from pg_shadow
 where passwd is null
order by usename;
select '<tr><td>',usename, '<td>', passwd, '<td>Unencrypted password'
 from pg_shadow
 where passwd not like 'md5%' and  passwd not like 'SCRAM%'
order by usename;
select '</table><p>';

select '<P><a id="usr_hba"></a>';
select '<P><table border="2"><tr><td><b>HBA Rules</b></td></tr>' as info;
select '<tr><td><b>Type</b>','<td><b>Database</b>',
 '<td><b>User</b>',  '<td><b>Address</b>', '<td><b>Netmask</b>',
 '<td><b>Auth</b>',  '<td><b>Options</b>', '<td><b>Error</b>';
select '<tr><td>',type,
       '<td>',database, '<td>',user_name, '<td>',address, '<td>',netmask,
       '<td>',auth_method, '<td class="split">',options, '<td>',error
  from pg_hba_file_rules
 order by line_number;
select '</table><p>';

select '<P><A NAME="ownerDB"></A>' as info;
select '<P><pre><table border="2"><tr><td><b>Non-Superuser Ownership</b></td></tr>' as info;
select '<tr><td><b>Object Type</b>', '<td><b>Name</b>', '<td><b>Owner</b>';
select '<tr><td>Database', '<td>', datname, '<td>',datdba::regrole::text
  from pg_database
 where not datistemplate
   and datdba::regrole::text not in ('postgres', 'rdsadmin', 'enterprisedb')
 order by datname;
select '<tr><td>Schema', '<td>', nspname, '<td>',nspowner::regrole::text
  from pg_namespace
 where nspowner::regrole::text not in ('postgres', 'rdsadmin', 'enterprisedb')
 order by nspname;
select '</table>' as info;

select '<A NAME="GrantR"></A>' as info;
select '<P><table border="2"><tr><td><b>Granted Roles</b></td></tr>' as info;
select '<tr><td><b>Grantee</b>', '<td><b>Admin Option</b>', '<td><b>Granted Roles</b>';
select '<tr><td>',member::regrole::text, '<td>',admin_option, '<td>',string_agg(roleid::regrole::text, ', ' order by roleid)
  from pg_auth_members
 where member::regrole::text not in ('postgres')
 group by member::regrole::text, admin_option
 order by member::regrole::text;
select '</table>' as info;

-- There is a logical error in the following query... but it is more concise
select '<A NAME="GrantO"></A>' as info;
select '<P><table border="2"><tr><td><b>Grants on Objects</b></td></tr>' as info;
select '<tr><td><b>Grantee</b>', '<td><b>Schema</b>', '<td><b>Count</b>', '<td><b>Privileges</b>';
with grt as (
select grantee as gr, table_schema ts, privilege_type pt, count(*) as cnt
  from information_schema.table_privileges
 where grantee not in ('postgres', 'pg_monitor', 'rdsadmin', 'enterprisedb')
   and table_schema not in ('pg_catalog', 'information_schema', 'sys')
   and table_schema not like 'pg_temp_%'
 group by grantee, table_schema, privilege_type
 order by grantee, table_schema, privilege_type
) 
select '<tr><td>',gr, '<td>',ts, '<td>',cnt, '<td>',string_agg(pt, ', ' order by pt)
  from grt
 group by gr, ts, cnt;
select '</table><p></pre><hr>';

select '<P><A NAME="sql"></A>' as info;
select '<P><table><tr>';
select '<td><table border="2"><tr><td><b>Per-User Sessions</b></td></tr>'
 as info;
select '<tr><td><b>User</b>', '<td><b>Database</b>',
       '<td><b>Count</b>', '<td><b>Active</b>' ;
select '<tr><td>',usename,
       '<td>',datname,
 	'<td>', count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end)
  from pg_stat_activity
 group by usename, datname
 order by 6 desc, 1;
select 	'<tr><td>TOTAL (', count(distinct usename),
 	' distinct users)<td><td>'|| count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end)
  from pg_stat_activity;
select '</table>' as info;

select '<td><table border="2"><tr><td><b>Per-Host Sessions</b></td></tr>'
 as info;
select '<tr><td><b>Host</b>', '<td><b>Database</b>',
       '<td><b>Count</b>', '<td><b>Active</b>' ;
select '<tr><td>', client_addr,
       '<td>',datname,
 	'<td>', count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end)
  from pg_stat_activity
 group by client_addr, datname
 order by 6 desc, 2
 limit 20;
select 	'<tr><td>TOTAL (', count(distinct client_addr),
 	' distinct clients)<td><td>'|| count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end)
  from pg_stat_activity;
select '</table>' as info;

select '<td><table border="2"><tr><td><b>Per-APP Sessions</b></td></tr>'
 as info;
select '<tr><td><b>APP</b>', '<td><b>Database</b>',
       '<td><b>Count</b>', '<td><b>Active</b>' ;
select '<tr><td>', application_name,
       '<td>',datname,
 	'<td>', count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end)
  from pg_stat_activity
 group by application_name, datname
 order by 6 desc, 2
 limit 20;
select 	'<tr><td>TOTAL (', count(distinct application_name),
 	' distinct applications)<td><td>'|| count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end)
  from pg_stat_activity;
select '</table> </table>' as info;

select '<P><table border="2"><tr><td><b>Sessions</b></td></tr>'
 as info;
select '<tr><td><b>Pid</b>',
 '<td><b>Database</b>',
 '<td><b>User</b>',
 '<td><b>Address</b>',
 '<td><b>Session start</b>',
 '<td><b>State</b>',
 '<td><b>Query start</b>',
 '<td><b>Duration</b>',
 '<td><b>Backend</b>',
 '<td><b>Application</b>',
 '<td><b>Query</b>' ;
select 	'<tr><td>',pid,
 	'<td>',datname,
 	'<td>',usename,
 	'<td>',client_addr,
 	'<td>',to_char(backend_start, 'YYYY-MM-DD HH24:MI:SS'),
 	'<td>',state,
 	'<td>',query_start,
 	'<td>',now()-query_start,
 	'<td>',backend_type,
 	'<td>',application_name,
 	'<td>',query
  from pg_stat_activity
 where pid<>pg_backend_pid()
 order by state, query_start, pid;
select '</table><p><hr>' as info;

select '<A NAME="lockd"></A>'  as info;
select '<A NAME="wlock"></A>'  as info;
select '<P><table border="2"><tr><td><b>Waiting Locks</b></td></tr>'
 as info;
select '<tr><td><b>Pid</b>',
 '<td><b>Type</b>',
 '<td><b>Database</b>',
 '<td><b>Relation</b>',
 '<td><b>Mode</b>',
 '<td><b>Granted</b>',
 '<td><b>Wait start</b>'
as info;
\if :var_version_14p
select '<tr><td>',pid, 
	'<td>',locktype, 
	'<td>',datname, 
	'<td>',relname, 
	'<td>',mode, 
	'<td>',granted,
	'<td>',waitstart
  from pg_locks l
  left join pg_catalog.pg_database d on d.oid = l.database
  left join pg_catalog.pg_class r on r.oid = l.relation
 where not granted
 order by waitstart, pid;
\else
select '<tr><td>',pid, 
	'<td>',locktype, 
	'<td>',datname, 
	'<td>',relname, 
	'<td>',mode, 
	'<td>',granted,
	'<td>'
  from pg_locks l
  left join pg_catalog.pg_database d on d.oid = l.database
  left join pg_catalog.pg_class r on r.oid = l.relation
 where not granted
 order by pid;
\endif
select '</table><p>' as info;

select '<P><A NAME="block"></A>'  as info;
select '<P><table border="2"><tr><td><b>Blocking Locks</b></td></tr>'
 as info;
select '<tr><td><b>Blocked Pid</b>',
 '<td><b>Blocked User</b>',
 '<td><b>Blocking Pid</b>',
 '<td><b>Blocking User</b>',
 '<td><b> Blocked Statement</b>',
 '<td><b> Blocking Session Current Statement</b>'
as info;
SELECT '<tr><td>',blocked_locks.pid AS blocked_pid,
       '<td>',blocked_activity.usename AS blocked_user,
       '<td>',blocking_locks.pid AS blocking_pid,
       '<td>',blocking_activity.usename AS blocking_user,
       '<td>',substring(blocked_activity.query, 1, 128) AS blocked_statement,
       '<td>',substring(blocking_activity.query, 1, 128) AS current_statement_in_blocking_process
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
select '</table><p>' as info;

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
 limit 50;
select '<tr><td>...';

select '<tr><td>TOTAL',
	'<td>',locktype, 
	'<td>',datname, 
	'<td>', count(*),
	'<td>',mode, 
	'<td>',granted
  from pg_locks l
  left join pg_catalog.pg_database d on d.oid = l.database
  left join pg_catalog.pg_class r on r.oid = l.relation
 group by locktype, datname, mode, granted
 order by granted, datname, locktype, mode;
select '</table><p><hr>' as info;

select '<P><A NAME="sga"></A>' as info;
select '<P><table border="2"><tr><td><b>Memory</b></td></tr>' as info;
select '<tr><td><b>Element</b>',
 '<td><b>Value</b>',
 '<td><b>Description</b>'
as info;
select '<tr><td>'||name,
	'<td align=right>'||case when unit='kB'  then pg_size_pretty(setting::bigint*1024)
                when unit='8kB' then pg_size_pretty(setting::bigint*1024*8)
                when unit='B'   then pg_size_pretty(setting::bigint)
                when unit='MB'  then pg_size_pretty(setting::bigint*1024*1024)
                else coalesce(setting||' '||unit,setting) end,
	'<td>'||short_desc
from pg_settings
where name like '%buffers';
select '<tr><td>'||name,
	'<td align=right>'||case when unit='kB'  then pg_size_pretty(setting::bigint*1024)
                when unit='8kB' then pg_size_pretty(setting::bigint*1024*8)
                when unit='B'   then pg_size_pretty(setting::bigint)
                when unit='MB'  then pg_size_pretty(setting::bigint*1024*1024)
                else coalesce(setting||' '||unit,setting) end,
	'<td>'||short_desc
from pg_settings
where name like '%mem';
select '</table><p><hr>' as info;

select '<P><A NAME="stat"></A><P>' as info;
select '<P><table border="2"><tr><td><b>Database Statistics</b>' as info;
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
 '<td><b>Delete</b>',
 '<td><b> Statistics reset </b>';
select '<tr><td>'||datname, 
	'<td align="right">'||numbackends, 
	'<td align="right">'||xact_commit, 
	'<td align="right">', round(xact_commit/EXTRACT( EPOCH FROM (now()-stats_reset))::decimal,2),
	'<td align="right">'||xact_rollback, 
	'<td align="right">'||blks_read, 
	'<td align="right">'||blks_hit, 
   '<td align="right">'||round((blks_hit)*100.0/nullif(blks_read+blks_hit, 0),2) hit_ratio, 
	'<td align="right">'||tup_returned, 
	'<td align="right">'||tup_fetched, 
	'<td align="right">'||tup_inserted, 
	'<td align="right">'||tup_updated, 
	'<td align="right">'||tup_deleted,
	'<td>'|| stats_reset
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
 '<td><b> checkpoint_write (s) </b>',
 '<td><b> checkpoint_sync (s) </b>',
 '<td><b> Statistics reset </b>';
select '<tr><td align="right">'||checkpoints_timed, 
	'<td align="right">'|| checkpoints_req, 
	'<td align="right">'|| buffers_checkpoint, 
	'<td align="right">'|| buffers_clean, 
	'<td align="right">'|| maxwritten_clean, 
	'<td align="right">'|| buffers_backend, 
	'<td align="right">'|| buffers_alloc,
	'<td align="right">'|| round(checkpoint_write_time/1000),
	'<td align="right">'|| round(checkpoint_sync_time/1000),
	'<td>'|| stats_reset
 from pg_stat_bgwriter;
select '</table><p>' as info;

select '<P><table border="2"><tr><td colspan=2><b>Checkpointer/BGWriter KPI</b>' as info;
select '<tr><td><b>Timed CP Ratio%</b>',
 '<td><b> Minutes between CP </b>',
 '<td><b> Clean by CP Ratio% </b>',
 '<td><b> Clean by BGW Ratio% </b>',
 '<td><b> BGW Halt Ratio% </b>';
select '<tr><td align="right">'||round(100.0*checkpoints_timed/nullif(checkpoints_req+checkpoints_timed,0),2),
       '<td align="right">'||round((extract('epoch' from now() - stats_reset)/60)::numeric/nullif(checkpoints_req+checkpoints_timed,0),2),
       '<td align="right">'||round(100.0*buffers_checkpoint/nullif(buffers_checkpoint + buffers_clean + buffers_backend,0),2),
       '<td align="right">'||round(100.0*buffers_clean/nullif(buffers_checkpoint + buffers_clean + buffers_backend,0),2),
       '<td align="right">'||coalesce(round(100.0*maxwritten_clean/nullif(buffers_clean,0),4),0)
 from pg_stat_bgwriter;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Cache statistics</b>' as info;
select '<tr><td><b>Object Type</b><td><b>#Read</b>',
 '<td><b> #Hit </b>',
 '<td><b> Hit Ratio% </b>';
SELECT '<tr><td>Table',
  '<td align="right">'||sum(heap_blks_read) as heap_read,
  '<td align="right">'||sum(heap_blks_hit)  as heap_hit,
  '<td align="right">'||trunc(100*sum(heap_blks_hit) / nullif(sum(heap_blks_hit) + sum(heap_blks_read),0),2) as ratio
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
\if :var_version_14p
SELECT '<p>Instance restart: '|| pg_postmaster_start_time(),
       '<br>Statement statistics reset: '|| stats_reset,
       ' Dealloc: '|| dealloc
  FROM pg_stat_statements_info;
\endif

select '<!-- Report running: '|| now() || ' -->';

select '<P><table border="2"><tr><td><b>Statement statistics</b>' as info;
select '<tr><td><b>Query</b>',
 '<td><b>User</b>',
 '<td><b>Calls</b>',
 '<td><b>Average (sec.)</b>',
 '<td><b>Max (sec.)</b>',
 '<td><b>Total Time</b>',
-- '<td><b>I/O Time</b>',
 '<td><b>Rows</b>',
 '<td><b>Hit Ratio%</b>'
as info;

\if :var_version_14p
SELECT '<td><b>WAL MB</b> <td><b>T</b>';
SELECT '<tr><td>'||replace(query,',',', '), ' <td>'||pg_get_userbyid(userid), '<td align="right">'||calls,
  '<td align="right">'||round((total_exec_time::numeric / nullif(calls::numeric, 0))/1000,3),
  '<td align="right">'||round((max_exec_time::numeric)/1000,3),
  '<td align="right">'||round(total_exec_time),
-- '<td align="right">'||round(blk_read_time+blk_write_time),
  '<td align="right">'||rows,
  '<td align="right">'||round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2)  AS hit_percent,
  '<td align="right">'||round((wal_bytes::numeric)/(1024*1024),0),
  '<td>'||CASE WHEN toplevel THEN 'T' ELSE 'F' END
  FROM pg_stat_statements 
 ORDER BY total_exec_time DESC LIMIT 20;
\else
 \if :var_version_13p
SELECT '<td><b>WAL MB</b>';
SELECT '<tr><td>'||replace(query,',',', '), ' <td>'||pg_get_userbyid(userid), '<td align="right">'||calls,
  '<td align="right">'||round((total_exec_time::numeric / nullif(calls::numeric, 0))/1000,3),
  '<td align="right">'||round((max_exec_time::numeric)/1000,3),
  '<td align="right">'||round(total_exec_time),
  '<td align="right">'||rows,
  '<td align="right">'||round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2)  AS hit_percent,
  '<td align="right">'||round((wal_bytes::numeric)/(1024*1024),0)
  FROM pg_stat_statements 
 ORDER BY total_exec_time DESC LIMIT 20;
 \else
SELECT '<tr><td>'||replace(query,',',', '), ' <td>'||pg_get_userbyid(userid), '<td align="right">'||calls,
  '<td align="right">'||round((total_time::numeric / nullif(calls::numeric, 0))/1000,3),
  '<td align="right">'||round((max_time::numeric)/1000,3),
  '<td align="right">'||round(total_time),
  '<td align="right">'||rows,
  '<td align="right">'||round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2)  AS hit_percent
  FROM pg_stat_statements 
 ORDER BY total_time DESC LIMIT 20;
 \endif
\endif

select '</table><p>' as info;

select '<P><A NAME="slow"></A><P>' as info;
select '<P><table border="2"><tr><td><b>Slowest Statements</b>' as info;
select '<tr><td><b>Query</b>',
 '<td><b>User</b>',
 '<td><b>Calls</b>',
 '<td><b>Average (sec.)</b>',
 '<td><b>Max (sec.)</b>',
 '<td><b>Total Time</b>',
-- '<td><b>I/O Time</b>',
 '<td><b>Rows</b>',
 '<td><b>Hit Ratio%</b>'
as info;
\if :var_version_13p
SELECT '<td><b>WAL MB</b>';
SELECT '<tr><td>'||replace(query,',',', '), ' <td>'||pg_get_userbyid(userid), '<td align="right">'||calls,
  '<td align="right">'||round((total_exec_time::numeric / nullif(calls::numeric, 0))/1000,3),
  '<td align="right">'||round((max_exec_time::numeric)/1000,3),
  '<td align="right">'||round(total_exec_time),
--  '<td align="right">'||round(blk_read_time+blk_write_time),
  '<td align="right">'||rows,
  '<td align="right">'||round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2)  AS hit_percent,
  '<td align="right">'||round((wal_bytes::numeric)/(1024*1024),0)
  FROM pg_stat_statements 
 WHERE pg_get_userbyid(userid) not in ('enterprisedb', 'efm')  -- Comment if needed
   AND calls>0
 ORDER BY (total_exec_time::numeric/nullif(calls::numeric, 0)) DESC
 LIMIT 10;
\else
SELECT '<tr><td>'||replace(query,',',', '), ' <td>'||pg_get_userbyid(userid), '<td align="right">'||calls,
  '<td align="right">'||round((total_time::numeric / nullif(calls::numeric, 0))/1000,3),
  '<td align="right">'||round((max_time::numeric)/1000,3),
  '<td align="right">'||round(total_time),
--  '<td align="right">'||round(blk_read_time+blk_write_time),
  '<td align="right">'||rows,
  '<td align="right">'||round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2)  AS hit_percent
  FROM pg_stat_statements 
 WHERE pg_get_userbyid(userid) not in ('enterprisedb', 'efm')  -- Comment if needed
   AND calls>0
 ORDER BY (total_time::numeric/nullif(calls::numeric, 0)) DESC
 LIMIT 10;
\endif
select '</table><p>' as info;


select '<P><table border="2">' as info;
select '<tr><td><b>Database</b>',
 '<td><b>Calls</b>',
 '<td><b>DBcpu</b>',
 '<td><b>IOcpu</b>',
 '<td><b>Stmt/sec.</b>'
as info;
\if :var_version_13p
\if :var_version_14p
select '<tr><td>', datname,
       '<td align="right">'||sum(calls),
       '    <td>', round(sum( (total_exec_time)/(EXTRACT(EPOCH FROM (now()-stats_reset))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-stats_reset))*1000) )::numeric,5) IOcpu,
       '<td align="right">'||round(sum( (calls)/(EXTRACT(EPOCH FROM (now()-stats_reset))) )::numeric,3) Exec
  from pg_stat_statements, pg_database, pg_stat_statements_info
 where pg_stat_statements.dbid=pg_database.oid
   and pg_stat_statements.toplevel
 group by datname;
select '<tr><td>TOTAL',
       '<td align="right">'||sum(calls),
       '    <td>', round(sum( (total_exec_time)/(EXTRACT(EPOCH FROM (now()-stats_reset))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-stats_reset))*1000) )::numeric,5) IOcpu
  from pg_stat_statements, pg_stat_statements_info where toplevel;
\else
select '<tr><td>', datname,
       '<td align="right">'||sum(calls),
       '    <td>', round(sum( (total_exec_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) IOcpu
  from pg_stat_statements, pg_database
 where pg_stat_statements.dbid=pg_database.oid
 group by datname;
select '<tr><td>TOTAL',
       '<td align="right">'||sum(calls),
       '    <td>', round(sum( (total_exec_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) IOcpu
  from pg_stat_statements;
\endif
\else
select '<tr><td>', datname,
       '<td align="right">'||sum(calls),
       '    <td>', round(sum( (total_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) IOcpu
  from pg_stat_statements, pg_database
 where pg_stat_statements.dbid=pg_database.oid
 group by datname;

select '<tr><td>TOTAL',
       '<td align="right">'||sum(calls),
       '    <td>',  round(sum( (total_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) IOcpu
  from pg_stat_statements;
\endif
select '</table><p><hr>' as info;

select '<P><A NAME="tbl"></A><P>' as info;
select '<P><table border="2"><tr><td colspan="3"><b>Table Statistics</b>' as info;
select '(reset: '|| coalesce(stats_reset::text, 'never') ||')' from pg_stat_database where datname=current_database();
select '<tr><td><b>Schema</b><td><b>Table</b>',
 '<td><b>#Rows</b>',
 '<td><b>Seq. Readed Tuples</b>',
 '<td><b>Idx. Readed Tuples</b>',
 '<td><b>Sequential Scan</b>',
 '<td><b>Index Scan</b>',
 '<td><b>Insert</b>',
 '<td><b>Update</b>',
 '<td><b>Hot Update</b>',
 '<td><b>Delete</b>',
 '<td><b>Index Usage Ratio%</b>',
 '<td><b>HOT Update Ratio%</b>';
select '<tr><td>'||schemaname,
  '<td>'||relname,
  '<td align="right">'||n_live_tup,
  '<td align="right">'||coalesce(seq_tup_read, 0),
  '<td align="right">'||coalesce(idx_tup_fetch, 0),
  '<td align="right">'||coalesce(seq_scan, 0),
  '<td align="right">'||coalesce(idx_scan, 0),
  '<td align="right">'||coalesce(n_tup_ins, 0),
  '<td align="right">'||coalesce(n_tup_upd, 0),
  '<td align="right">'||coalesce(n_tup_hot_upd, 0),
  '<td align="right">'||coalesce(n_tup_del, 0),
  '<td align="right">'||coalesce(idx_scan*100/nullif(idx_scan+seq_scan,0), -1) as idx_hit_ratio,
  '<td align="right">'||coalesce(n_tup_hot_upd*100/nullif(n_tup_upd,0), -1) as hot_hit_ratio
 from pg_stat_user_tables
 order by (coalesce(seq_tup_read,0) +coalesce(idx_tup_fetch,0) +coalesce(n_tup_ins,0) +
           coalesce(n_tup_upd,0) +coalesce(n_tup_del,0)) desc
 limit 20;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Tables Caching</b>' as info;
select '<tr><td><b>Schema</b><td><b>Table</b>',
 '<td><b>Heap Reads</b>',
 '<td><b>Index Reads</b>',
 '<td><b>TOAST Reads</b>',
 '<td><b>Heap Hit Ratio%</b>',
 '<td><b>Index Hit Ratio%</b>',
 '<td><b>TOAST Hit Ratio%</b>';
select '<tr><td>'||schemaname,
  '<td>'||relname,
  '<td align="right">'||coalesce(heap_blks_read, 0),
  '<td align="right">'||coalesce(idx_blks_read, 0),
  '<td align="right">'||coalesce(toast_blks_read, 0),
  '<td align="right">'||coalesce(heap_blks_hit*100/nullif(heap_blks_read+heap_blks_hit,0), -1) as tb_hit_ratio,
  '<td align="right">'||coalesce(idx_blks_hit*100/nullif(idx_blks_read+idx_blks_hit,0), -1) as idx_hit_ratio,
  '<td align="right">'||coalesce(toast_blks_hit*100/nullif(toast_blks_read+toast_blks_hit,0), -1) as toast_hit_ratio
 from pg_statio_user_tables
 where heap_blks_read>0
 order by heap_blks_read desc
 limit 20;
select '</table><p>' as info;

select '<P><A NAME="idx"></A><P>' as info;
select '<pre><P><table border="2"><tr><td><b>Index Usage - Details</b></td></tr></table>' ;

select '<P><table border="2"><tr><td><b>Defined indexes</b>' as info;
select '<tr><td><b>Schema</b><td><b>Type</b><td><b>Count</b>', '<td><b> Primary </b>',
       '<td><b> Unique </b>', '<td><b> Avg #keys </b>', '<td><b> Max #keys </b>';
SELECT '<tr><td>',ns.nspname, '<td>',am.amname, '<td align="right">',count(*),
       '<td align="right">',sum(case when idx.indisprimary then 1 else 0 end) pk,
       '<td align="right">',sum(case when idx.indisunique then 1 else 0 end) uq,
       '<td align="right">',round(avg(idx.indnkeyatts),2), '<td align="right">',max(idx.indnkeyatts)
  FROM pg_index idx 
  JOIN pg_class cls ON cls.oid=idx.indexrelid
  JOIN pg_class tbl ON tbl.oid=idx.indrelid
  JOIN pg_am am ON am.oid=cls.relam
  JOIN pg_namespace ns ON cls.relnamespace = ns.oid
 WHERE ns.nspname not in ('pg_catalog', 'sys')
   AND ns.nspname not like 'pg_toast_temp%'
 GROUP BY ns.nspname, am.amname
 ORDER BY ns.nspname, am.amname;
select '</table><p>' as info;

select '<P><A NAME="constr2"></A>' as info;
select '<P><table border="2"><tr><td><b>Constraints</b></td></tr>' as info;
select '<tr><td><b>Schema</b>',
 '<td><b> Primary</b>',
 '<td><b> Unique</b>',
 '<td><b> Foreign</b>',
 '<td><b> Check</b>',
 '<td><b> Trigger</b>',
 '<td><b> Exclusion</b>'
as info;
select '<tr><td>'||nspname,
 '<td align="right">'||sum(case when contype ='p' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when contype ='u' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when contype ='f' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when contype ='c' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when contype ='t' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when contype ='x' THEN 1 ELSE 0 end)
from pg_constraint, pg_namespace
where connamespace=pg_namespace.oid
  and nspname NOT IN('information_schema', 'pg_catalog', 'sys')
group by nspname
order by nspname;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Invalid indexes</b>' as info;
select '<tr><td><b>Schema</b>', '<td><b>Index</b>', '<td><b>On Table</b>';
SELECT '<tr><td>'|| n.nspname ||'<td>'|| c1.relname ||'<td>'|| c2.relname
  FROM pg_class c1, pg_index i, pg_namespace n, pg_class c2
 WHERE c1.relnamespace = n.oid
   AND i.indexrelid = c1.oid
   AND c2.oid = i.indrelid
   AND i.indisvalid = false;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Missing indexes</b><td colspan="6">(using foreign constraints)' as info;
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

select '<P><table border="2"><tr><td><b>Most used indexes</b>' as info;
select '<tr><td><b>Schema</b><td><b>Table</b>', '<td><b>Index</b>', '<td><b>Size</b>', '<td><b>Scan</b>', '<td><b>Tuples</b>';
SELECT '<tr><td>',s.schemaname, '<td>',s.relname,
       '<td>',s.indexrelname, '<td align="right">',pg_relation_size(s.indexrelid),
       '<td align="right">',s.idx_scan, '<td align="right">',s.idx_tup_fetch  
  FROM pg_catalog.pg_stat_user_indexes s
  JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
 WHERE s.idx_scan>0
 ORDER BY s.idx_scan DESC
 LIMIT 16;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>All indexes</b>' as info;
select '<tr><td><b>Schema</b><td><b>Relation</b>',
       '<td><b>Index</b><td><b>DDL</b>';

SELECT '<tr><td>',schemaname, '<td>',tablename,
       '<td>',indexname, '<td>',indexdef
  FROM pg_indexes
 WHERE schemaname not in ('pg_catalog', 'sys')
   AND tablename not like 'pgstatspack%'
 ORDER BY schemaname, tablename, indexname;  -- no more limits
select '</table><p></pre><hr>' as info;

select '<!-- Report running: '|| now() || ' -->';

select '<P><pre><A NAME="partdet"></A>' as info;
select '<P><table border="2"><tr><td><b>Partitions</b></td></tr>' as info;
select '<tr><td><b>Schema</b><td><b>Owner</b>',
 '<td><b> Partitioned Object</b>',
 '<td><b> # Partition</b>',
 '<td><b> Tuples</b>';
select '<tr><td>'||nspname, '<td>'||rolname,
   '<td>', t.relname,
   '<td>', count(distinct(p.relname)),
   '<td align="right">', to_char(sum( case when p.reltuples>0 then p.reltuples else 0 end ),'999G999G999G999G999G999G999')
  from pg_class t, pg_inherits i, pg_class p, pg_roles r, pg_namespace n
 where i.inhparent = t.oid 
   and p.oid = i.inhrelid
   and t.relowner=r.oid
   and t.relnamespace=n.oid
   and p.relkind in ('r', 'p')
 group by nspname, rolname, t.relname
 order by nspname, rolname, t.relname;
select '</table>' as info;

select '<P><table border="2"><tr><td><b>Partitioning Details</b></td></tr>' as info;
select '<tr><td><b>Schema</b><td><b>Owner</b>',
 '<td><b> Partitioned Object</b>',
 '<td><b> Partition</b>',
 '<td><b> Expression</b>',
 '<td><b> Tuples</b>';
select '<tr><td>'||nspname, '<td>'||rolname,
   '<td>', t.relname,
   '<td>', p.relname,
   '<td>', pg_get_partkeydef ( t.oid ),' ', pg_get_expr(p.relpartbound, p.oid, true),
   '<td align="right">', to_char(p.reltuples,'999G999G999G999G999G999G999')
  from pg_class t, pg_inherits i, pg_class p, pg_roles r, pg_namespace n
 where i.inhparent = t.oid 
   and p.oid = i.inhrelid
   and t.relowner=r.oid
   and t.relnamespace=n.oid
   and p.relkind in ('r', 'p')
 order by nspname, rolname, t.relname, pg_get_expr(p.relpartbound, p.oid, true);
select '</table></pre><p>' as info;

select '<P><A NAME="param"></A>' as info;
select '<P><table border="2"><tr><td><b>Tuning Parameters (most important ones)</b></td></tr>'
 as info;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>',
 '<td><b>Min</b>',
 '<td><b>Max</b>',
 '<td><b>Unit</b>',
 '<td><b>Context</b>',
 '<td><b>Description</b>',
 '<td><b>Setting</b>',
 '<td><b>Source</b>'
as info;
select '<tr><td>',name,
   '<td align=right>',
   replace(replace(
           case when unit='kB'  then pg_size_pretty(setting::bigint*1024)
                when unit='8kB' then pg_size_pretty(setting::bigint*1024*8)
                when unit='B'   then pg_size_pretty(setting::bigint)
                when unit='MB'  then pg_size_pretty(setting::bigint*1024*1024)
                else coalesce(setting||' '||unit,setting) end,
           '<','&lt;'),'>','&gt;'),
   '<td align=right>',min_val,'<td align=right>',max_val,
   '<td>',unit, '<td>',context, '<td>',short_desc,
   '<td align=right>',replace(replace(setting,'<','&lt;'),'>','&gt;'),
   '<td>',source
  from pg_settings
 where name in ('max_connections','shared_buffers','effective_cache_size','work_mem', 'temp_buffers', 'wal_buffers',
               'checkpoint_completion_target', 'checkpoint_segments', 'synchronous_commit', 'wal_writer_delay',
               'max_fsm_pages','fsync','commit_delay','commit_siblings','random_page_cost', 'synchronous_standby_names',
               'checkpoint_timeout', 'max_wal_size',
               'bgwriter_lru_maxpages', 'bgwriter_lru_multiplier', ' bgwriter_delay',
               'autovacuum_vacuum_cost_limit', 'autovacuum_vacuum_cost_delay') 
 order by name; 
select '</table><p><hr>' as info;


select '<P><A NAME="big"></A>'  as info;
select '<P><table border="2"><tr><td><b>Biggest Objects</b></td></tr>'
 as info;
select '<tr><td><b>Object</b>',
 '<td><b>Type</b>',
 '<td><b>Owner</b>', '<td><b>Schema</b>',
 '<td><b>Rows</b>',
 '<td><b>Bytes</b>';
select '<tr><td>'||relname,
 '<td>'||case WHEN relkind='r' THEN 'Table' 
    WHEN relkind='i' THEN 'Index'
    WHEN relkind='t' THEN 'TOAST Table'
    ELSE relkind::text||'' end,
 '<td>'||rolname,  '<td>'||n.nspname,
 '<td align=right>'||to_char(reltuples,'999G999G999G999G999G999G999'),
 '<td align=right>'||to_char(relpages::INT8*8*1024,'999G999G999G999G999G999G999')
  from pg_class, pg_roles, pg_catalog.pg_namespace n
 where relowner=pg_roles.oid
   and n.oid=pg_class.relnamespace
 order by relpages desc, reltuples desc
 limit 32;
select '</table><p>' as info;

select '<P><A NAME="toast"></A>'  as info;
select '<P><table border="2"><tr><td><b>Largest TOASTs</b></td></tr>'
 as info;
select '<tr><td><b>TOAST</b>',
 '<td><b>Owner</b>', '<td><b>Table</b>',
 '<td><b>Chunks</b>',
 '<td><b>Bytes</b>'
as info;
select '<tr><td>'||t.relname,
 '<td>'||rolname,  '<td>'||n.nspname||'.'||r.relname,
 '<td align=right>'||to_char(t.reltuples,'999G999G999G999G999G999G999'),
 '<td align=right>'||to_char(pg_relation_size(t.oid),'999G999G999G999G999G999G999')
  from pg_class t, pg_roles, pg_catalog.pg_namespace n, pg_class r
 where t.relowner=pg_roles.oid
   and n.oid=r.relnamespace
   and r.reltoastrelid = t.oid
   and t.relkind='t'
   and t.reltuples>0
 order by pg_relation_size(t.oid) desc
 limit 10;
select '</table><p>' as info;

select '<P><A NAME="bigp"></A>'  as info;
select '<P><table border="2"><tr><td><b>Biggest Partitioned Objects</b></td></tr>'
 as info;
select '<tr><td><b>Object</b>',
 '<td><b>Hierarchy level</b>',
 '<td><b>Partition#</b>',
 '<td><b>HR Size</b>',
 '<td><b>Bytes</b>';
WITH RECURSIVE tabs AS (
     SELECT c.oid AS parent, c.oid AS relid, 1 AS level
       FROM pg_catalog.pg_class c
       LEFT JOIN pg_catalog.pg_inherits AS i ON c.oid = i.inhrelid
      WHERE c.relkind IN ('p', 'r')
        AND i.inhrelid IS NULL
      UNION ALL
     SELECT p.parent AS parent, c.oid AS relid, p.level + 1 AS level
       FROM tabs AS p
       LEFT JOIN pg_catalog.pg_inherits AS i ON p.relid = i.inhparent
       LEFT JOIN pg_catalog.pg_class AS c ON c.oid = i.inhrelid AND c.relispartition
      WHERE c.oid IS NOT NULL
)
SELECT '<tr><td>',parent ::REGCLASS AS table_name, 
       '<td align="right">',max(level)-1 AS hierarchy_level,
       '<td align="right">',count(*) AS partition_count,
       '<td align="right">',pg_size_pretty(sum(pg_total_relation_size(relid))) AS pretty_total_size,
       '<td align="right">',to_char(sum(pg_total_relation_size(relid)),'999G999G999G999G999G999G999') AS total_size
       -- array_agg(relid :: REGCLASS) AS all_partitions
  FROM tabs
 GROUP BY parent
 HAVING max(level)>1
 ORDER BY sum(pg_total_relation_size(relid)) DESC
 LIMIT 10;
select '</table><p><hr>' as info;


select '<P><A NAME="psq"></A>'  as info;
select '<P><table border="2"><tr><td><b>Procedural Languages</b></td></tr>'
 as info;
select '<tr><td><b>Available languages</b>' as info;
select '<tr><td>'||lanname
from pg_language;
select '</table><P><table border="2"><tr><td><b>PL Objects</b></td></tr>';
select '<tr><td><b>Owner</b>',
 '<td><b>Kind</b>',
 '<td><b>Language</b>',
 '<td><b>Count</b>',
 '<td><b>Source size</b>'
as info;
select '<tr><td>'||o.rolname,
 '<td>'||case when f.prokind='f' then 'Function'
           when f.prokind='a' then 'Aggregate func.'
           when f.prokind='w' then 'Window func.'
           when f.prokind='p' then 'Procedure'
           else 'Other' end,
 '<td>'||l.lanname, '<td align="right">'||count(*),
 '<td align="right">'||sum(char_length(prosrc))
  from pg_proc f, pg_roles o, pg_language l
 where f.proowner=o.oid
   and f.prolang=l.oid
   and o.rolname not in ('postgres', 'enterprisedb')
 group by o.rolname, l.lanname, prokind
 order by o.rolname, prokind, l.lanname;
select '</table><p>' as info;

-- regexp_split_to_table(prosrc, E'\n')

select '<P><A NAME="dtype"></A>'  as info;
select '<pre><P><table border="2"><tr><td><b>Data Types - Details</b></td></tr></table>' ;

select '<P><table border="2"><tr><td><b>Tables/Columns</b></td></tr>'
 as info;
select '<tr><td><b>Owner</b>', '<td><b>Schema</b>',
 '<td><b>Tables</b>', '<td><b>Columns</b>';
select '<tr><td>'||o.rolname, '<td>'||n.nspname, '<td align="right">'||count(distinct r.relname||n.nspname),
       '<td align="right">'||count(distinct r.relname||n.nspname||a.attname)
  from pg_attribute a, pg_class r, pg_roles o, pg_catalog.pg_namespace n
 where a.attrelid=r.oid
   and r.relowner=o.oid
   and n.oid=r.relnamespace
   and r.relkind in('r', 'p')
   and not r.relispartition
   and a.attnum > 0
   and not a.attisdropped
   and o.rolname not in ('postgres', 'rdsadmin', 'enterprisedb', 'admin')
   and n.nspname not in ('information_schema', 'pg_catalog')
 group by o.rolname, n.nspname
 order by o.rolname, n.nspname;
select '</table>' as info;


select '<p><table border="2"><tr><td><b>Data Types</b></td></tr>'
 as info;
select '<tr><td><b>Owner</b>', '<td><b>Schema</b>',
 '<td><b>Data type</b>',
 '<td><b>Count</b>';
select '<tr><td>'||o.rolname, '<td>'||n.nspname, '<td>'||t.typname, '<td align="right">'||count(*)
  from pg_attribute a, pg_class r, pg_roles o, pg_type t, pg_catalog.pg_namespace n
 where a.attrelid=r.oid
   and a.atttypid=t.oid
   and r.relowner=o.oid
   and n.oid=r.relnamespace
   and r.relkind in('r', 'p')
   and not r.relispartition
   and a.attnum > 0
   and not a.attisdropped
   and o.rolname not in ('postgres', 'rdsadmin', 'enterprisedb', 'admin')
   and n.nspname not in ('information_schema', 'pg_catalog')
 group by o.rolname, n.nspname, t.typname
 order by o.rolname, n.nspname, t.typname;
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
select '<tr><td>In Recovery Mode',
 '<td><b>'||pg_is_in_recovery()||'</b>';
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>';
select '<tr><td>',name,'<td>',replace(replace(setting,'<','&lt;'),'>','&gt;')
 from pg_settings
 where name in ('wal_level', 'archive_command', 'hot_standby', 'max_wal_senders', 'checkpoint_segments', 'max_wal_size', 'archive_mode', 
                'max_standby_archive_delay', 'max_standby_streaming_delay', 'hot_standby_feedback', 'synchronous_commit',
                'wal_keep_segments', 'wal_keep_size', 'synchronous_standby_names', 'recovery_target_timeline',
                'wal_receiver_create_temp_slot', 'max_slot_wal_keep_size', 'ignore_invalid_pages',
                'primary_slot_name', 'primary_conninfo', 'max_slot_wal_keep_size',
                'vacuum_defer_cleanup_age')
 order by name; 
select '</table><p>' as info;


select '<P><table border="2"><tr><td><b>Master Statistics</b></td></tr>' ;
select '<tr><td><b>Client</b>', '<td><b>State</b>', '<td><b>Sync</b>',
       '<td><b>Current Snapshot</b>', '<td><b>Sent loc.</b>',
       '<td><b>Write loc.</b>', '<td><b>Flush loc.</b>', '<td><b>Replay loc.</b>', '<td><b>Backend Start</b>';
select '<td><b>Write lag</b>', '<td><b>Flush lag</b>', '<td><b>Replay lag</b>';
select '<tr><td>',client_addr, '<td>', state, '<td>', sync_state, '<td>', txid_current_snapshot(),
       '<td>', sent_lsn,      '<td>',write_lsn, '<td>',flush_lsn, '<td>',replay_lsn,
       '<td>', backend_start, '<td>',write_lag, '<td>',flush_lag, '<td>',replay_lag
  from pg_stat_replication;
select '</table>' as info;

select '<P><table border="2"><tr><td><b>Replication Slots</b></td></tr>' ;
select '<tr><td><b>Name</b>', '<td><b>Type</b>', '<td><b>Active</b>',
       '<td><b>XMIN</b>', '<td><b>Catalog XMIN</b>', '<td><b>Restart LSN</b>';
select '<tr><td>',slot_name, '<td>', slot_type, '<td>', active,
       '<td>', xmin, '<td>', catalog_xmin, '<td>', restart_lsn
  from pg_replication_slots;
select '</table>' as info;


select '<P><table border="2"><tr><td><b>Slave Statistics</b></td></tr>' ;
select '<tr><td><b>Last Replication</b>','<td><b>Replication Delay</b>','<td><b>Current Snapshot</b>',
       '<td><b>Receive loc.</b>','<td><b>Replay loc.</b>';
select '<tr><td>', now() - pg_last_xact_replay_timestamp(),
       '<td>', CASE WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() THEN 0
                    ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp()) END,
       '<td>', case when pg_is_in_recovery() then txid_current_snapshot() else null end,
       '<td>', pg_last_wal_receive_lsn(),  
       '<td>', pg_last_wal_replay_lsn();
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>WAL Receiver</b></td></tr>' ;
select '<tr><td><b>PID</b>','<td><b>Status</b>','<td><b>Connection</b>',
       '<td><b>Latest LSN</b>','<td><b>Latest time</b>';
select '<tr><td>',pid, '<td>', status, '<td>', conninfo,
       '<td>', latest_end_lsn, '<td>', latest_end_time
  from pg_stat_wal_receiver;
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
 '<td><b>Description</b>';
select '<tr><td>',name,'<td align=right>',setting,
   '<td>',short_desc
from pg_settings
where name like 'lc%'
order by name; 

select '<tr><td><b>OID</b>',
 '<td><b>Database</b>',
 '<td><b>Collate</b>';
select '<tr><td>'|| oid, ' <td>'|| datname, 
       ' <td>'|| datcollate
from pg_database;
select '</table>' as info;

select '<P><pre><table border="2"><tr><td><b>Columns with non default collation</b></td></tr>';
select '<tr><td><b>Schema</b>',
 '<td><b>Table</b>',
 '<td><b>Column</b>',
 '<td><b>Collate</b>';
select '<tr><td>'|| table_schema, 
       ' <td>'|| table_name, 
       ' <td>'|| column_name,
       ' <td>'|| collation_name
  from information_schema.columns
 where collation_name is not null
   and table_schema not in ('information_schema', 'pg_catalog', 'sys')
 order by table_schema,
          table_name,
          ordinal_position;
select '</table></pre><p><hr>' as info;

select '<P><A NAME="par"></A>'  as info;
select '<P><table border="2"><tr><td><b>Configured Parameters</b></td></tr>'
 as info;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>',
 '<td><b>Description</b>',
 '<td><b>Source</b>',
 '<td><b>Setting</b>'
as info;
select '<tr><td>',name,
   '<td class="split">',
   replace(replace(
           case when unit='kB'  then pg_size_pretty(setting::bigint*1024)
                when unit='8kB' then pg_size_pretty(setting::bigint*1024*8)
                when unit='B'   then pg_size_pretty(setting::bigint)
                when unit='MB'  then pg_size_pretty(setting::bigint*1024*1024)
                else coalesce(setting||' '||unit,setting) end,
           '<','&lt;'),'>','&gt;'),
   '<td>',short_desc, '<td>',source,
   '<td class="split">',
   replace(replace(setting, '<','&lt;'),'>','&gt;')
from pg_settings
where source not in ('default', 'override', 'client')
order by name; 
select '</table><p>' as info;

select '<P><A NAME="par_all"></A>'  as info;
select '<P><table border="2"><tr><td><b>PostgreSQL Parameters</b> (all)</td></tr>'
 as info;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>',
 '<td><b>Min</b>',
 '<td><b>Max</b>',
 '<td><b>Description</b>',
 '<td><b>Category</b>',
 '<td><b>Context</b>',
 '<td><b>Unit</b>',
 '<td><b>Source</b>',
 '<td><b>Setting</b>'
as info;
select '<tr><td>',name,'<td class="split">',
   replace(replace(
           case when unit='kB'  then pg_size_pretty(setting::bigint*1024)
                when unit='8kB' then pg_size_pretty(setting::bigint*1024*8)
                when unit='B'   then pg_size_pretty(setting::bigint)
                when unit='MB'  then pg_size_pretty(setting::bigint*1024*1024)
                else coalesce(setting||' '||unit,setting) end,
           '<','&lt;'),'>','&gt;'),
   '<td align=right>',min_val,'<td align=right>',max_val,
   '<td>',short_desc, '<td>',category, '<td>',context,
   '<td>',unit, '<td>',source,
   '<td class="split">',setting
from pg_settings
order by name; 
select '</table><p><hr>' as info;

select '<P><A NAME="pghba"></A>'  as info;
select '<P><table border="2"><tr><td><b>HBA file</b></td></tr>';
select '<tr><td><p><pre>' as info;
select pg_read_file('pg_hba.conf',1,10240);
select '</pre></table><p><hr>' as info;
-- SELECT * from pg_catalog.pg_read_file('pg_hba.conf');
-- WITH f(name) AS (VALUES('pg_hba.conf'))
-- SELECT pg_catalog.pg_read_file(name, 0, (pg_catalog.pg_stat_file(name)).size) FROM f;

select '<P><A NAME="pgautoconf"></A>'  as info;
select '<P><table border="2"><tr><td><b>Autoconf file</b></td></tr>';
select '<tr><td><p><pre>' as info;
select pg_read_file('postgresql.auto.conf',1,10240);
select '</pre></table><p><hr>' as info;


select '<P><A NAME="logs"></A>'  as info;
select '<P><table border="2"><tr><td><b>LOG files (latest 20 files and last messages)</b></td></tr>';
select '<tr><td><p><xmp>' as info;
\pset tuples_only
\a
select count(*) as LOG_files, pg_size_pretty(sum(size)) as LOG_total_size
  from pg_ls_logdir();
select * from pg_ls_logdir() order by modification desc limit 20;
select pg_read_file(setting||'/'||dr.name, greatest(-16384, dr.size * -1), 16384) as Log_messages
  from pg_ls_logdir() dr, pg_settings st
 where st.name ='log_directory'
 order by modification desc limit 1;
\pset tuples_only
\a
select '</xmp></table><p><hr>' as info;

select '<P><A NAME="wal"></A>'  as info;
select '<P><table border="2"><tr><td><b>WAL files (first 5 and latest 20)</b></td></tr>';
select '<tr><td><p><pre>' as info;
\pset tuples_only
\a
select count(*) as wal_files, pg_size_pretty(sum(size)) as WAL_total_size
  from pg_ls_waldir();
(select * from pg_ls_waldir() order by modification limit 5)
union all
select '...', null, null
union all
(select * from (select * from pg_ls_waldir() order by modification desc limit 20) latest_wals order by modification);
\pset tuples_only
\a
select '</pre></table><p><hr>' as info;

select '<!-- Report running: '|| now() || ' -->';

/* Extensions, fork, cloud information dynamic statistics */
-- pg_stat_statements is too important to be "optional" extensions

select '<P><A NAME="opt"></A>'  as info;
select '<P><b>Optional informations</b><P>'  as info;
SELECT
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pg_stat_statements' and installed_version is not null) as pg_stat_statements,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pg_buffercache' and installed_version is not null) as pg_buffercache,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pgstattuple' and installed_version is not null) as pgstattuple,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pg_freespacemap' and installed_version is not null) as pg_freespacemap,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='sslinfo' and installed_version is not null) as sslinfo,
    EXISTS (SELECT 1 FROM pg_stat_ssl WHERE ssl limit 1) as ssl_active,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pgaudit' and installed_version is not null) as pgaudit,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pgrowlocks' and installed_version is not null) as pgrowlocks,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='postgis' and installed_version is not null) as postgis,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='vector' and installed_version is not null) as pgvector,
    EXISTS (SELECT 1 FROM pg_settings WHERE name='max_prepared_transactions' and setting::int > 0 ) as xa_active,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='anon' and installed_version is not null) as anon,
    EXISTS (SELECT 1 FROM pg_tables WHERE tablename='pgstatspack_snap' and schemaname='public') as pgstatspack,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='edbspl') as edb,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='rds_tools') as amazon_rds,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='rds_tools' and installed_version is not null) as rds_tools,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='aurora_stat_utils') as aurora,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='aurora_stat_utils' and installed_version is not null) as aurora_stat,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='apg_plan_mgmt' and installed_version is not null) as qpm,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='yb_pg_metrics') as yugabyte
\gset opt_


\if :opt_pg_buffercache
select '<P><A NAME="pg_buffercache"></A>'  as info;
select '<P><table border="2"><tr><td><b>Buffer cache content detailed information</b></td></tr>';
select '<tr><td><p><pre>' as info;
\pset tuples_only
\a

SELECT c.relname, c.relkind, count(*) as buffers,
       pg_size_pretty(count(*) * 8192) as buffered,
       round(100.0 * count(*)/(SELECT setting FROM pg_settings WHERE name='shared_buffers')::integer,1) as buffers_pct,
       round(100.0 * count(*) * 8192 / pg_relation_size(c.oid),1) as relation_pct,
       round(avg(usagecount),2) as usage_avg
  FROM pg_class c
 INNER JOIN pg_buffercache b ON b.relfilenode = c.relfilenode
 INNER JOIN pg_database d ON (b.reldatabase = d.oid AND d.datname = current_database())
 WHERE pg_relation_size(c.oid) > 0
 GROUP BY c.oid, c.relname, c.relkind
 ORDER BY 3 DESC
 LIMIT 30;

SELECT pg_size_pretty(setting::bigint*8192::bigint) as buffer_cache_size
  FROM pg_settings
 WHERE name='shared_buffers';
SELECT pg_size_pretty(count(*) * 8192) as minimal_cache_size_est
  FROM pg_buffercache
 WHERE usagecount >= 3;

\pset tuples_only
\a
select '</pre></table><p><hr>' as info;
\endif


\if :opt_pgstattuple
select '<P><A NAME="pgstattuple"></A>'  as info;
select '<P><table border="2"><tr><td><b>Bloat detailed informations for biggest tables (can be time expensive: enable only if needed)</b></td></tr>';
select '<tr><td><p><pre>' as info;
\pset tuples_only
\a

\if 0
select n.nspname, relname Relation, relpages, (pgstattuple_approx(pg_class.oid::regclass)).*
  from pg_class, pg_roles, pg_catalog.pg_namespace n
 where relowner=pg_roles.oid
   and n.oid=pg_class.relnamespace
   and relkind = 'r'
 order by relpages desc
 limit 20;

select n.nspname, relname Relation, relpages, (pgstatindex(pg_class.oid::regclass)).*
  from pg_class, pg_roles, pg_catalog.pg_namespace n
 where relowner=pg_roles.oid
   and n.oid=pg_class.relnamespace
   and relkind = 'i'
 order by relpages desc
 limit 20;

select n.nspname, relname Relation, relpages, (pgstattuple(pg_class.oid::regclass)).*
  from pg_class, pg_roles, pg_catalog.pg_namespace n
 where relowner=pg_roles.oid
   and n.oid=pg_class.relnamespace
   and relkind = 'r'
 order by relpages desc
 limit 20;
\endif

\pset tuples_only
\a
select '</pre></table><p><hr>' as info;
\endif


select '<P><A NAME="histograms"></A>'  as info;
select '<P><table border="2"><tr><td><b>Column statistics histograms (can be quite large: enable only on most intresting objects)</b></td></tr>';
select '<tr><td><p><xmp>' as info;
\pset tuples_only
\a
\if 1
-- Default settings
select name as parameter_name, setting, min_val, max_val, source
  from pg_settings
 where name='default_statistics_target';

-- Customized statistics
select attrelid::regclass as tab_name, attname as col_name, attstattarget as custom_statistics_target
  from pg_attribute 
 where attstattarget not in (0,-1)
 order by tab_name, attname limit 100;

-- Collected histograms
select t2.*
  from (
  select row_number() over (partition by tab_name, col_name order by freq desc) as sample, tstat.*
    from (
    select schemaname||'.'||tablename as tab_name, attname as col_name, avg_width,
           array_dims(coalesce(most_common_vals::text::text[], array['-'])),
           substr(unnest(coalesce(most_common_vals::text::text[], array['-'])), 1,20) val, 
           unnest(coalesce(most_common_freqs::text::text[], array['0'])) freq, null_frac
      from pg_stats
     where schemaname not in ('pg_catalog', 'information_schema')
       and tablename in ('pgbench_accounts')
     order by 1, 2, 6 desc ) tstat ) t2
 where sample<10
order by 2,3,7 desc;

-- Extended Statistics
SELECT es.stxnamespace::pg_catalog.regnamespace::text || '.'||
       es.stxname AS statistics_name,
       es.stxrelid::regclass as tab_name,
       pg_get_userbyid(es.stxowner) AS owner,
       pg_catalog.format('%s FROM %s',
         (SELECT pg_catalog.string_agg(pg_catalog.quote_ident(a.attname),', ')
          FROM pg_catalog.unnest(es.stxkeys) s(attnum)
          JOIN pg_catalog.pg_attribute a ON (es.stxrelid = a.attrelid
                  AND a.attnum = s.attnum AND NOT a.attisdropped)),
         es.stxrelid::regclass) AS definition,
       CASE WHEN 'd' = any(es.stxkind) THEN 'X' END AS "Ndistinct",
       CASE WHEN 'f' = any(es.stxkind) THEN 'X' END AS "Dependencies",
       CASE WHEN 'm' = any(es.stxkind) THEN 'X' END AS "MCV"
  FROM pg_catalog.pg_statistic_ext es
 ORDER BY 1, 2;

-- Collected histograms for extended statistics
select t2.*
  from (
  select row_number() over (partition by statistics_name, tab_name, col_names order by freq desc) as sample, tstat.*
    from (
    select statistics_name, schemaname||'.'||tablename as tab_name, attnames as col_names, array_dims(most_common_vals),
           substr(unnest(most_common_vals[:][1:1]::text::text[]), 1,20) val1, 
           substr(unnest(most_common_vals[:][2:2]::text::text[]), 1,20) val2, 
           unnest(most_common_freqs::text::text[]) freq
      from pg_stats_ext
     where schemaname not in ('pg_catalog', 'information_schema')
     order by 1,2,3, 7 desc ) tstat
    where freq is not null ) t2
 where sample<10
order by 2,3,4,8 desc;

    \if 0
-- Inner details (debug only)
select *
  from pg_stats_ext
 limit 100;

SELECT e.stxname as stat_name, e.stxkeys, e.stxkind, d.stxdndistinct, d.stxddependencies
  FROM pg_statistic_ext e join pg_statistic_ext_data d on (e.oid = d.stxoid);

SELECT e.stxname as stat_name, m.index, m.values, m.nulls, m.frequency, m.base_frequency
  FROM pg_statistic_ext e join pg_statistic_ext_data d on (oid = stxoid),
       pg_mcv_list_items(stxdmcv) m
 WHERE m.index < 20
 ORDER BY e.stxname, m.index;
    \endif

\endif
\pset tuples_only
\a
select '</xmp></table><p><hr>' as info;


\if :opt_sslinfo
select '<P><A NAME="sslinfo"></A>'  as info;
select '<P><table border="2"><tr><td><b>SSL Informations on current connection</b></td></tr>';
select '<tr><td><b>SSL Usage</b>','<td><b>SSL Version</b>',
       '<td><b>SSL Cipher</b>',
       '<td><b>Client Certificate</b>'
as info;
SELECT '<tr><td>', ssl_is_used(), '<td>', ssl_version(), '<td>', ssl_cipher(),  '<td>', ssl_client_cert_present();
select '</table><p><hr>' as info;
\endif

\if :opt_ssl_active
select '<P><A NAME="sslactive"></A>'  as info;
select '<P><table border="2"><tr><td><b>SSL Informations on all connections</b></td></tr>';
select '<tr><td><pre>' as info;
select * from pg_stat_ssl;
select '</pre></table><p><hr>' as info;
\endif


\if :var_version_12p
select '<P><A NAME="12_stats"></A>'  as info;
select '<P><table border="2"><tr><td><b>Additional PG12+ Statistics</b></td></tr>';
select '<tr><td><pre>' as info;
\pset tuples_only
\a
SELECT *
  FROM pg_ls_tmpdir()
 ORDER BY modification DESC;

select *
  from pg_stats_ext;

SELECT *
  from pg_stat_gssapi;

\pset tuples_only
\a
select '</pre></table><p>' as info;
\endif

\if :var_version_13p
select '<P><A NAME="13_stats"></A>'  as info;
select '<P><table border="2"><tr><td><b>Additional PG13+ Statistics</b></td></tr>';
select '<tr><td><pre>' as info;
\pset tuples_only
\a
SELECT *
  from pg_stat_slru;

select replace(replace(name, '<', '-'), '>', '-') as name, off, size, allocated_size
  from pg_shmem_allocations
 order by allocated_size desc;

\pset tuples_only
\a
select '</pre></table><p>' as info;
\endif

\if :var_version_14p
select '<P><A NAME="14_stats"></A>'  as info;
select '<P><table border="2"><tr><td><b>Additional PG14+ Statistics</b></td></tr>';
select '<tr><td><pre>' as info;
\pset tuples_only
\a

select pid, datname, 'VACUUM' command, phase, heap_blks_total total, heap_blks_scanned done    -- 9.6+
  from pg_stat_progress_vacuum
union
select pid, datname, command, phase, heap_blks_total total, heap_blks_scanned done             -- 12+
  from pg_stat_progress_cluster
union
select pid, datname, command, phase, blocks_total total, blocks_done done
  from pg_stat_progress_create_index
union
select pid, datname, 'ANALYZE', phase, sample_blks_total total, sample_blks_scanned done       -- 13+
  from pg_stat_progress_analyze
union
select pid, '*', 'PG_BASE_BACKUP', phase, backup_total total, backup_streamed done
  from pg_stat_progress_basebackup
union
select pid, datname, command, type, bytes_total total, bytes_processed done                    -- 14+
  from pg_stat_progress_copy
 order by pid;

select *, 
       pg_size_pretty(wal_bytes/extract(epoch from (now()-stats_reset)/3600)) wal_hour
  from pg_stat_wal;

SELECT *
  from pg_backend_memory_contexts
 ORDER BY used_bytes DESC LIMIT 10;

SELECT *
  from pg_stat_replication_slots;

SELECT *
  from pg_stat_statements_info;

SELECT *
  from pg_stats_ext_exprs;

\pset tuples_only
\a
select '</pre></table><p><hr>' as info;
\endif


\if :var_version_15p
select '<P><A NAME="15_stats"></A>'  as info;
select '<P><table border="2"><tr><td><b>Additional PG15+ Statistics</b></td></tr>';
select '<tr><td><pre>' as info;
\pset tuples_only
\a
select *
  from pg_parameter_acl;

--  pg_publication_namespace
\pset tuples_only
\a
select '</pre></table><p>' as info;
\endif


\if :var_version_16p
select '<P><A NAME="16_stats"></A>'  as info;
select '<P><table border="2"><tr><td><b>Additional PG16+ Statistics</b></td></tr>';
select '<tr><td><pre>' as info;
\pset tuples_only
\a
select backend_type, io_object, io_context, reads, writes, extends,
       op_bytes, evictions, reuses, fsyncs
  from pg_stat_io;
\pset tuples_only
\a
select '</pre></table><p>' as info;
\endif


\if :var_version_17p
select '<P><A NAME="17_stats"></A>'  as info;
select '<P><table border="2"><tr><td><b>Additional PG17+ Statistics</b></td></tr>';
select '<tr><td><pre>' as info;
\pset tuples_only
\a
select count(*) as total, a.state, a.wait_event_type, a.wait_event, b.description
  from pg_stat_activity a 
  join pg_wait_events b on a.wait_event_type = b.type 
                       and a.wait_event = b.name
 group by a.state, a.wait_event_type, a.wait_event, b.description
 order by 1 desc;

select * from pg_stat_progress_copy;
select * from pg_stat_progress_vacuum;

select num_timed, num_requested, write_time, sync_time, buffers_written, stats_reset  
  from pg_stat_checkpointer;

select '<table>';
select '<tr><td align="right">'||buffers_clean as buffer_clean,
       '<td align="right">'||maxwritten_clean as maxwritten_clean, 
       '<td align="right">'||buffers_alloc as buffer_alloc, 
       '<td>'|| stats_reset as stats_reset
 from pg_stat_bgwriter;
select '<tr><td align="right">'||num_timed as num_timed, 
       '<td align="right">'|| num_requested as num_requested, 
       '<td align="right">'|| buffers_written as buffers_written, 
       '<td align="right">'|| round(write_time/1000) as write_time,
       '<td align="right">'|| round(sync_time/1000) as sync_time,
       '<td>'|| stats_reset as stats_reset
 from pg_stat_checkpointer;
select '</table>';

\pset tuples_only
\a
select '</pre></table><p>' as info;
\endif


\if :opt_xa_active
select '<P><A NAME="xa"></A>'  as info;
select '<P><table border="2"><tr><td><b>Pending transactions</b></td></tr>';
select '<tr><td><pre>' as info;
\pset tuples_only
\a
select gid, prepared, owner, database, transaction AS xmin, now()-prepared AS age
  from pg_prepared_xacts
 order by age(transaction) desc;
\pset tuples_only
\a
select '</pre></table><p>' as info;
\endif


\if :opt_postgis
select '<P><A NAME="postgis"></A>'  as info;
select '<P><table border="2"><tr><td><b>Postgis Statistics </b></td></tr>';
select '<tr><td><p><pre>' as info;
\pset tuples_only
\a

select 'PostgreSQL Version: ' as "component", version();
select 'PostGIS Version: ' as "component", PostGIS_version();
select 'PostGIS Full Version: ' as "component", PostGIS_full_version();

SELECT name as "Extension", installed_version 
  FROM pg_available_extensions WHERE name like 'postgis%'
 ORDER BY name;

select count(*) as "GIS Objects"
  from geometry_columns;
select count(*) as "GiST Indexes"
  from pg_index, pg_class, pg_roles
 where pg_index.indrelid=pg_class.oid
   and relowner=pg_roles.oid
   and upper(pg_get_indexdef(indexrelid)) like '%USING%GIST%(%';

select substr(proj4text, 1,10) as Projection, count(*)
  from spatial_ref_sys
 group by substr(proj4text, 1,10);

\pset tuples_only
\a
select '</pre></table><p>' as info;
\endif


\if :opt_pgvector
select '<P><A NAME="pgvector"></A>'  as info;
select '<P><table border="2"><tr><td><b>pgvector Statistics</b></td></tr>';
select '<tr><td><p><pre>' as info;
\pset tuples_only
\a

select 'PostgreSQL' as "Component", version()
union all
SELECT name as "Extension", installed_version 
  FROM pg_available_extensions WHERE name like 'vector';

select o.rolname as owner, n.nspname as schema, r.relname as table,
       a.attname as column, t.typname as vector_datatype, a.atttypmod
  from pg_attribute a, pg_class r, pg_roles o, pg_type t, pg_catalog.pg_namespace n
 where a.attrelid=r.oid
   and a.atttypid=t.oid
   and r.relowner=o.oid
   and n.oid=r.relnamespace
   and r.relkind in('r', 'p')
   and not r.relispartition
   and a.attnum > 0
   and not a.attisdropped
   and o.rolname not in ('postgres', 'rdsadmin', 'enterprisedb', 'admin')
   and n.nspname not in ('information_schema', 'pg_catalog')
   and t.typname in ('vector', 'halfvec', 'sparsevec', 'bit')
 order by o.rolname, n.nspname, t.typname;

SELECT ns.nspname as schema,  
       tbl.relname as table, cls.relname as index, am.amname as type, idx.indnkeyatts
  FROM pg_index idx 
  JOIN pg_class cls ON cls.oid=idx.indexrelid
  JOIN pg_class tbl ON tbl.oid=idx.indrelid
  JOIN pg_am am ON am.oid=cls.relam
  JOIN pg_namespace ns ON cls.relnamespace = ns.oid
 WHERE ns.nspname not in ('pg_catalog', 'sys')
   AND ns.nspname not like 'pg_toast_temp%'
   AND am.amname in ('hnsw', 'ivfflat')
 ORDER BY ns.nspname, am.amname;

\pset tuples_only
\a
select '</pre></table><p>' as info;
\endif


\if :opt_anon
select '<P><A NAME="anon"></A>'  as info;
select '<P><table border="2"><tr><td><b>Anonymizer Extension </b></td></tr>';
select '<tr><td><p><pre>' as info;
\pset tuples_only
\a

SELECT name as "Extension", installed_version 
  FROM pg_available_extensions WHERE name like 'anon%'
 ORDER BY name;

select * from pg_seclabels;

\pset tuples_only
\a
select '</pre></table><p>' as info;
\endif


\if :opt_pgstatspack
select '<P><A NAME="pgstatspack"></A>'  as info;
select '<P><table border="2"><tr><td><b>pgstatspack Info </b></td></tr>';
select '<tr><td><p><pre>' as info;
\pset tuples_only
\a

select 'pgstatspack Version: ' as "component", version
  from pgstatspack_version;
select 'Statistics Range: ' as "component" , min(ts) || ' - ' || max(ts) as "value"
  from public.pgstatspack_snap;

select ts as time, 'Top connections    ' as metric,
       sessions, actives, waits
from (
select snapid, count(*) as probes, sum(count_star) as sessions,
       sum(case when working then 1 else 0 end) as actives,
       sum(case when working then case when waiting then 1 else 0 end else 0 end) as waits
  from public.pgstatspack_activity_v a
 group by snapid ) b,
       public.pgstatspack_snap s
 where s.snapid=b.snapid
 order by sessions desc, time desc
  limit 10;

select ts as time, 'Top active sessions' as metric,
       sessions, actives, waits
from (
select snapid, count(*) as probes, sum(count_star) as sessions,
       sum(case when working then 1 else 0 end) as actives,
       sum(case when working then case when waiting then 1 else 0 end else 0 end) as waits
  from public.pgstatspack_activity_v a
 group by snapid ) b,
       public.pgstatspack_snap s
 where s.snapid=b.snapid
 order by actives desc, time desc
  limit 5;

select ts as time, 'Top waiting        ' as metric,
       sessions, actives, waits
from (
select snapid, count(*) as probes, sum(count_star) as sessions,
       sum(case when working then 1 else 0 end) as actives,
       sum(case when working then case when waiting then 1 else 0 end else 0 end) as waits
  from public.pgstatspack_activity_v a
 group by snapid ) b,
       public.pgstatspack_snap s
 where s.snapid=b.snapid
 order by waits desc, time desc
  limit 5;

\pset tuples_only
\a
select '</pre></table><p>' as info;
\endif


\if :opt_edb
select '<P><A NAME="EDB"></A>'  as info;
select '<P><table border="2"><tr><td><b>Additional EnterpriseDB Advanced Server Statistics </b></td></tr>';
select '<tr><td><p><pre>' as info;
\pset tuples_only
\a

select *
  from product_component_version;

\if :var_version_14p
select *
  from all_objects
 where schema_name not in ('SYS')
 order by last_ddl_time desc
 limit 40;

 select *
  from all_users
 order by last_ddl_time desc
 limit 20;
\endif


select *
  from all_directories;
select *
  from all_db_links;
select *
  from all_synonyms;
select *
  from all_policies;


-- EDB Performance 
-- It seems that there are differences between EDB minor versions on the following tables... edb_wait_states_data
select *
  from system_waits;
select *
  from session_waits
 limit 50;
select *
  from session_wait_history
 limit 50;
select *
  from edb$session_wait_history
 limit 50;

-- EDB Security features (Auditing and Data Redaction)
SELECT name, setting
  FROM pg_settings
 WHERE name like 'edb_audit%'
    OR name = 'edb_data_redaction';

select *
  from edb_redaction_policy;
select *
  from edb_redaction_column;

\pset tuples_only
\a
select '</pre></table><p><hr>' as info;
\endif


\if :opt_amazon_rds
select '<P><A NAME="rds"></A>'  as info;
select '<P><table border="2"><tr><td><b>Amazon RDS</b></td></tr>';
select '<tr><td><p><pre>' as info;
\pset tuples_only
\a

\if :opt_rds_tools
select *
  from rds_tools.role_password_encryption_type();
\endif

\pset tuples_only
\a
select '</pre></table><p><hr>' as info;
\endif


\if :opt_aurora
select '<P><A NAME="aurora"></A>'  as info;
select '<P><table border="2"><tr><td><b>Additional Aurora Postgres-compatible Statistics </b></td></tr>';
select '<tr><td><p><pre>' as info;
\pset tuples_only
\a

select 'Latest Aurora PostgreSQL Releases: 15.3.0, 14.8.0 13.11.0, 12.15.0, 11.20.0; (10.21.5, 1.11.1 9.6.22)';
select 'Aurora: '||AURORA_VERSION();

select server_id, case when session_id= 'MASTER_SESSION_ID' then 'Writer' else 'Reader' end as Role, 
       replica_lag_in_msec as AuroraReplicaLag
  from aurora_replica_status();

\if :opt_aurora_stat
SELECT *
  FROM aurora_wait_report();
\endif

\if :opt_qpm
SELECT *
  FROM apg_plan_mgmt.dba_plans;
\endif

\pset tuples_only
\a
select '</pre></table><p><hr>' as info;
\endif


\if :opt_pgaudit
select '<P><a id="pgaudit"></a>';
select '<P><table border="2"><tr><td><b>PGAudit logged Objects</b></td></tr>' as info;
select '<tr><td><b>Schema</b>', '<td><b>Table</b>', '<td><b>Privilege</b>';
SELECT '<tr><td>',table_schema, '<td>',table_name, '<td>',privilege_type 
  FROM information_schema.role_table_grants 
 WHERE grantee in ('rds_pgaudit', 'auditor', 'pgaudit')
 ORDER BY table_schema, table_name;
\endif


select '<p><hr>' as info;

select '<P>Statistics generated on: '|| current_date || ' ' ||localtime as info;
select '<br>More info on' as info;
select '<A HREF="http://meoshome.it.eu.org#post">this site</A>' as info;

select '<br> Copyright: 2024 meob - License: GNU General Public License v3.0 <p></body></html>' as info;
select '<br> Sources: https://github.com/meob/db2html/ <p></body></html>' as info;
\pset tuples_only
\a
\o

