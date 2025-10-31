-- Program: pg2html.sql
-- Info:    PostgreSQL psql report in HTML
--          Works with PostgreSQL 10 or sup. (tested and updated up to PG 18)
-- Date:    2008-08-15
-- Version: 1.0.32a on 2025-10-31
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
--          1.0.28 pgvector, ... (a) minor changes, waitstart (b) unidexed tables, minor changes (c) Cloud SQL and AlloyDB (d) FDW
--          1.0.29 Latest versions update, minor changes. (a) Latest versions update (b) amcheck, bug fixing (c) PG18 stub
--          1.0.30 Latest versions update, pg_largeobject, table storage parameters. (a) Latest versions update
--                 (b) Redundant indexes (c) preview features (d) as_admin variable for cloud administrators
--          1.0.31 Latest versions update (a) bug fixing, PG18 full support
--          1.0.32 Latest versions update; modernized HTML with sortable tables and better formatting;
--                 added QueryID where possible, operational and performance KPIs
--                 **NB** To take advantage of the new graphic features style.css and util.js files must be downloaded too.
--                 (a) more KPIs

\set var_as_admin 1

\pset tuples_only
\pset fieldsep ' '
\pset footer off
\a
\o pg.htm

select '<!DOCTYPE html><html><head><meta charset="UTF-8"><link rel="stylesheet" href="style.css">';
select '<title>'||current_database()||' - PostgreSQL Statistics - pg2html</title></head><body>';
select '<h1>PostgreSQL - '||current_database()||'</h1>' ;

select '<div id="top"></div>';
select '<p>Table of contents:' ;
select '<table><tr><td>' ;
select '<a href="#status">Summary Status</a><br>' ;
select '<a href="#ver">Versions</a><br>' ;
select '<a href="#dbs">Databases</a><br>' ;
select '<a href="#obj">Schema/Object Matrix</a><br>' ;
select '<a href="#tbs">Tablespaces</a><br>' ;
select '<a href="#usg">Space Usage</a> (<a href="#vacuum">VACUUM</a>, <a href="#bloat">Bloat</a>, <a href="#xid">XID</a>)<br>';
select '<a href="#usr">Users</a><br>' ;
select '<a href="#sql">Sessions</a>  (<a href="#sql_g">Grouped</a>, <a href="#sql_x">All</a>, <a href="#sql_x">Active</a>) <br>' ;
select '<a href="#lockd">Locks</a><br>' ;
select '<a href="#sga">Memory</a><br>' ;
select '<td>' ;
select '<a href="#stat">Performance Statistics</a><br>' ;
select '&nbsp;(<a href="#stat">Instance</a>, <a href="#stmt">Statements</a>, <a href="#slow">Slow</a>, <a href="#tbl">Tables</a>, ';
select '   <a href="#idx">Indexes</a>, <a href="#partdet">Partitions</a>, <a href="#param">Tuning Parameters</a>)<br>';
select '<a href="#big">Biggest Objects</a><br>' ;
select '<a href="#psq">PL/pgSQL, Data Types</a><br>' ;
select '<a href="#rman">Backup</a><br>' ;
select '<a href="#repl">Replication</a><br>' ;
select '<a href="#ext">Extensions</a><br>' ;
select '<a href="#nls">NLS Settings</a><br>' ;
select '<a href="#par">Parameters</a><br>' ;
select '<a href="#pghba">Files</a> (<a href="#pghba">pghba</a>, <a href="#pgautoconf">autoconf</a>,';
select '   <a href="#logs">logs</a>, <a href="#wal">WAL</a>)<br>' ;
select '<a href="#opt">Additional Statistics</a>';
select '  (<a href="#opt">Extensions</a>, <a href="#96_stats">Version specific</a>, <a href="#fork">Forks</a>)' ;
select '</table><p><hr>' ;

select '<p>Report generated on: '|| now();
select 'on database: <strong>'||current_database()||'</strong>' ;
select 'by user: '||user ;
select 'using: <em><strong>pg2html.sql</strong> v.1.0.32a</em>' ;
 
select '<hr><h2 id="status">Summary</h2>';
select '<table class="bordered"><thead><tr><th scope="col">Item</th><th scope="col">Value</th></tr></thead><tbody>' ;

select '<tr><td>'||' Database :', '<!-- 10 -->',
 '<td>'||current_database()
union
select '<tr><td>'||' Version :', '<!-- 12 -->',
 '<td>'||substring(version() for  position('on' in version())-1)
union
select '<tr><td>'||' DB Size:', '<!-- 20 -->',
 '<td class="align-right">'||pg_size_pretty(sum(pg_database_size(datname)))
  from pg_database;
\if :var_as_admin
select '<tr><td>'||' Created :',
   '<!-- 15 -->', '<td>'|| (pg_stat_file('base/'||oid ||'/PG_VERSION')).modification
  from pg_database
 where datname='template0';
\endif
select '<tr><td>'||' Started :',
   '<!-- 16 -->', '<td>'||pg_postmaster_start_time()
union
select '<tr><td>'||' Memory buffers (MB) :',
   '<!-- 24 -->', '<td class="align-right">'||trunc(sum(setting::int*8)/1024)
  from pg_settings
 where name in ('shared_buffers', 'wal_buffers', 'temp_buffers')
union
select '<tr><td>'||' Work area (MB) :',
   '<!-- 25 -->', '<td class="align-right">'||trunc(sum(setting::int)/1024)
  from pg_settings
 where name like '%mem'
union
select '<tr><td>'||' Wal Archiving :',
   '<!-- 26 -->', '<td class="align-right">'||setting
  from pg_settings
 where name like 'archive_mode';
select '<tr><td>'||' Databases :', '<!-- 30 -->', '<td class="align-right">'||count(*)
  from pg_database
 where not datistemplate
union
select '<tr><td>'||' Defined Users/Roles :',
   '<!-- 31 -->', '<td class="align-right">'||sum(case when rolcanlogin then 1 else 0 end)||
   ' / '|| sum(case when rolcanlogin then 0 else 1 end)
  from pg_roles
union
select '<tr><td>'||' Defined Schemata :',
   '<!-- 32 -->', '<td class="align-right">'||count(distinct relowner)
  from pg_class
union
select '<tr><td>'||' Defined Tables :',
   '<!-- 34 -->', '<td class="align-right">'||count(*)
  from pg_class
 where relkind='r';
select '<tr><td>'||' Sessions :', '<!-- 40 -->', '<td class="align-right">'||count(*)
 from pg_stat_activity
union
select '<tr><td>'||' Sessions (active) :', '<!-- 42 -->', '<td class="align-right">'||count(*)
  from pg_stat_activity
 where state = 'active';
select '<tr><td>'||' Host IP :',
   '<!-- 51 -->', '<td class="align-right">'||inet_server_addr()
union
select '<tr><td>'||' Port (used):',
   '<!-- 52 -->', '<td class="align-right">'||inet_server_port()
union
select '<tr><td>'||' Port (configured):',
   '<!-- 53 -->', '<td class="align-right">'||setting
  from pg_settings where name='port'
order by 2;
select '</table><p><hr>' ;


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

SELECT cast(current_setting('server_version_num')as integer)>= 180000 as version_18p
\gset var_

select '<h2 id="ver">Version</h2>' ;
select '<table class="bordered">' ;
select '<tr><td>'||version()||'<td>'|| current_setting('server_version')||'<td>'|| current_setting('server_version_num');
select '</table><p>' ;

select '<p><table class="bordered"><caption>Version check</caption>' ;
select '<tr><th>Version</th>',
 '<th> Supported</th>',
 '<th> Recent major release (up to N-2)</th>',
 '<th> Recent minor release (up to N-1)</th>',
 '<th> Notes</th>';
SELECT '<tr><td>'||substring(version() for  position('on' in version())-1);
SELECT '<td>', CASE WHEN trunc(cast(current_setting('server_version_num') as integer)/100)
  in (1300, 1400, 1500, 1600, 1700) THEN 'YES'
  ELSE 'NO' END;
SELECT '<td>', CASE WHEN trunc(cast(current_setting('server_version_num')
  as integer)/100)
  in (1500, 1600, 1700, 1800) THEN 'YES'
  ELSE 'NO' END; -- last2 release
SELECT '<td>', CASE WHEN cast(current_setting('server_version_num') as integer)
  in (90624,100023,110022,120022,
  130021,130022,130023,
  140018,140019,140020,
  150013,150014,150015,
  160009,160010,160011,
  170005,170006,170007,
  180000,180001,180002) THEN 'YES'
  ELSE 'NO' END; -- last2 update
select '<td>Latest Releases: 18.0, 17.6, 16.10, 15.14, 14.19, 13.22';
select '    <br>Latest Unsupported: 12.22, 11.22, 10.23, 9.6.24, 9.5.25, 9.4.26, 9.3.25, 9.2.24, 9.1.24, 9.0.23,';
select '    8.4.21, 8.3.23, 8.2.23, 8.1.23, 8.0.26; 7.4.30, 6.5.3';
select '</table><p><hr>';

select '<h2 id="dbs">Databases</h2>' ;
select '<table class="bordered">' ;
select '<tr><th>Name</th>', '<th>OID</th>', '<th>Owner</th>',
 '<th>Size</th>',
 '<th>HR Size</th>'
as info;
select '<tr><td>'||datname, '<td>',oid, '<td>',datdba::regrole::text,
 '<td class="align-right">'||pg_database_size(datname),
 '<td class="align-right">'||pg_size_pretty(pg_database_size(datname))
  from pg_database
 where not datistemplate
 order by oid;
select '<tr><td>TOTAL',
 '<td class="align-right">'||count(*),'<td>',
 '<td class="align-right">'||sum(pg_database_size(datname)),
 '<td class="align-right">'||pg_size_pretty(sum(pg_database_size(datname))::int8)
  from pg_database
 where not datistemplate;
select '</table><p><hr>' ;


select '<h2 id="obj">Schema/Object Matrix</h2>' ;
select '<table class="bordered">' ;
select '<tr><th>Schema</th><th>Owner</th>',
 '<th> Table</th>',
 '<th> Index</th>',
 '<th> Part. Table</th>',
 '<th> Part. Index</th>',
 '<th> View</th>',
 '<th> Sequence</th>',
 '<th> Composite type</th>',
 '<th> Foreign table</th>',
 '<th> TOAST table</th>',
 '<th> Materialized view</th>',
 '<th> TOTAL</th>'
 '<th> Partitions</th>',
 '<th> Not Partitions</th>',
 '<th> Unlogged</th>',
 '<th> Temporary</th>';
select '<tr><td>'||nspname, '<td>'||rolname,
 '<td class="align-right">'||sum(case when relkind='r' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='i' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='p' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='I' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='v' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='S' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='c' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='f' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='t' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='m' THEN 1 ELSE 0 end),
 '<td class="align-right">'||count(*),
 '<td class="align-right">'||coalesce(sum(case when relkind in ('r','p') THEN case when relispartition then 1 else 0 end else 0 end),0),
 '<td class="align-right">'||coalesce(sum(case when relkind in ('r','p') THEN case when relispartition then 0 else 1 end else 0 end),0),
 '<td class="align-right">'||sum(case when relpersistence='u' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relpersistence='t' THEN 1 ELSE 0 end)
from pg_class, pg_roles, pg_namespace
where relowner=pg_roles.oid
  and relnamespace=pg_namespace.oid
  and rolname not in ('enterprisedb', 'alloydbadmin', 'cloudsqladmin')
group by rolname, nspname
order by nspname, rolname;
select '<tr><td>TOTAL<td>',
 '<td class="align-right">'||sum(case when relkind='r' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='i' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='p' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='I' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='v' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='S' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='c' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='f' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='t' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relkind='m' THEN 1 ELSE 0 end),
 '<td class="align-right">'||count(*),
 '<td class="align-right">'||coalesce(sum(case when relkind in ('r','p') THEN case when relispartition then 1 else 0 end else 0 end),0),
 '<td class="align-right">'||coalesce(sum(case when relkind in ('r','p') THEN case when relispartition then 0 else 1 end else 0 end),0),
 '<td class="align-right">'||sum(case when relpersistence='u' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when relpersistence='t' THEN 1 ELSE 0 end)
from pg_class, pg_roles
where relowner=pg_roles.oid
  and rolname not in ('enterprisedb', 'alloydbadmin', 'cloudsqladmin');
select '</table><p>' ;

select '<h2 id="const">Constraints</h2>' ;
select '<table class="bordered">' ;
select '<tr><th>Schema</th>',
 '<th> Primary</th>',
 '<th> Unique</th>',
 '<th> Foreign</th>',
 '<th> Check</th>',
 '<th> Trigger</th>',
 '<th> Exclusion</th>',
 '<th> TOTAL</th>';
select '<tr><td>'||nspname,
 '<td class="align-right">'||sum(case when contype ='p' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when contype ='u' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when contype ='f' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when contype ='c' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when contype ='t' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when contype ='x' THEN 1 ELSE 0 end),
 '<td class="align-right">'||count(*)
from pg_constraint, pg_namespace
where connamespace=pg_namespace.oid
  and nspname NOT IN('information_schema', 'pg_catalog', 'sys')
group by nspname
order by nspname;
select '</table><p>' ;

select '<h2 id="part">Partitions</h2>' ;
select '<table class="bordered">' ;
select '<tr><th>Schema</th><th>Owner</th>',
 '<th> Object Type</th>',
 '<th> Partitioned Objects</th>',
 '<th> <a href="#partdet">Partitions</a></th>';
select '<tr><td>'||nspname, '<td>'||rolname, '<td>'||t.relkind::text,
   '<td class="align-right">', count(distinct t.relname),
   '<td class="align-right">', count(*)
  from pg_class t, pg_inherits i, pg_class p, pg_roles r, pg_namespace n
 where i.inhparent = t.oid 
   and p.oid = i.inhrelid
   and t.relowner=r.oid
   and t.relnamespace=n.oid
 group by rolname, nspname, t.relkind
 order by t.relkind desc, nspname, rolname;
select '</table><p>' ;

select '<h2 id="fnc">Schema/Function Matrix</h2>' ;
select '<table class="bordered">' ;
select '<tr><th>Schema</th><th>Owner</th>',
 '<th> Functions</th>',
 '<th> Procedures</th>',
 '<th> TOTAL</th>'
as info;
select '<tr><td>'||nspname, '<td>'||rolname, 
  '<td class="align-right">'||sum(case when prokind='p' THEN 0 ELSE 1 end),
  '<td class="align-right">'||sum(case when prokind='p' THEN 1 ELSE 0 end),
  '<td class="align-right">'||count(*)
  from pg_proc, pg_roles, pg_language, pg_namespace n
 where proowner=pg_roles.oid
   and prolang=pg_language.oid
   and pronamespace=n.oid
   and rolname not in ('postgres', 'enterprisedb', 'alloydbadmin', 'cloudsqladmin')
 group by nspname, rolname
 order by nspname, rolname;
select '<tr><td>TOTAL<td>TOTAL',
  '<td class="align-right">'||sum(case when prokind='p' THEN 0 ELSE 1 end),
  '<td class="align-right">'||sum(case when prokind='p' THEN 1 ELSE 0 end),
  '<td class="align-right">'||count(*)
  from pg_proc, pg_roles, pg_language, pg_namespace n
 where proowner=pg_roles.oid
   and prolang=pg_language.oid
   and pronamespace=n.oid
   and rolname not in ('postgres', 'enterprisedb', 'alloydbadmin', 'cloudsqladmin');
select '</table><p>' ;

select '<h2 id="trg">Triggers</h2>' ;
select '<table class="bordered"><caption>Schema/Trigger Matrix</caption>' ;
select '<tr><th>Schema</th>',
 '<th> INSERT</th>',
 '<th> UPDATE</th>',
 '<th> DELETE</th>',
 '<th> Row</th>',
 '<th> Statement</th>',
 '<th> BEFORE</th>',
 '<th> AFTER</th>',
 '<th> INSTEAD</th>',
 '<th> TOTAL</th>';
select '<tr><td>'||trigger_schema,
 '<td class="align-right">'||sum(case when event_manipulation='INSERT' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when event_manipulation='UPDATE' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when event_manipulation='DELETE' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when action_orientation='ROW' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when action_orientation='STATEMENT' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when action_timing='BEFORE' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when action_timing='AFTER' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when action_timing='INSTEAD OF' THEN 1 ELSE 0 end),
 '<td class="align-right">'||count(*)
  from information_schema.triggers
 group by trigger_schema
 order by trigger_schema;
select '</table><p>' ;

select '<table class="bordered"><caption>Event Triggers</caption>' ;
select '<tr><th>Event</th>',
 '<th> Name</th>',
 '<th> Owner</th>',
 '<th> Function</th>',
 '<th> Enabled</th>',
 '<th> Enable mode</th>',
 '<th> Tags</th>';
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
select '</table><p><hr>' ;

select '<h2 id="tbs">Tablespaces</h2>' ;
select '<table class="bordered">' ;
select '<tr><th>Name</th>', '<th>Owner</th>', '<th>Location</th>', '<th>HR Size</th>' ;
select '<tr><td>'||spcname, '<td>',pg_catalog.pg_get_userbyid(spcowner),
  '<td>',pg_catalog.pg_tablespace_location(oid),
  '<td class="align-right">', pg_size_pretty (pg_tablespace_size (spcname))
  from pg_tablespace
 order by spcname;
select '</table><p>' ;

select '<table class="bordered"><caption>Space Usage</caption>' ;
select '<tr><th>Tablespace</th>',
 '<th>Table#</th>',
 '<th>Tables rows</th>',
 '<th>Tables KBytes</th>',
 '<th>Indexes KBytes</th>',
 '<th>TOAST KBytes</th>',
 '<th>Total KBytes</th>'
as info;
select '<tr><td>', spcname,
 '<td class="align-right">'||to_char(sum(case when relkind='r' THEN 1 ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(sum(case when relkind='r' THEN greatest(reltuples,0) ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(case when relkind='r' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(case when relkind='i' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(case when relkind='t' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(cast(1 as bigint)* relpages *8)),'999G999G999G999G999G999G999')
from pg_class
left join pg_tablespace on reltablespace=pg_tablespace.oid
group by spcname
order by spcname;
select '</table><p><hr>' ;

select '<h2 id="usg">Space Usage</h2>' ;
select '<table class="bordered">' ;
select '<tr><th>Schema</th><th>Owner</th>',
 '<th>Table#</th>',
 '<th>Tables rows</th>',
 '<th>Tables KBytes</th>',
 '<th>Indexes KBytes</th>',
 '<th>TOAST KBytes</th>',
 '<th>Total KBytes</th>'
as info;
select '<tr><td>'||nspname, '<td>'||rolname,
 '<td class="align-right">'||to_char(sum(case when relkind='r' THEN 1 ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(sum(case when relkind='r' THEN greatest(reltuples,0) ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(case when relkind='r' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(case when relkind='i' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(case when relkind='t' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(cast(1 as bigint)* relpages *8)),'999G999G999G999G999G999G999')
from pg_class, pg_roles, pg_namespace
where relowner=pg_roles.oid
  and relnamespace=pg_namespace.oid
  and rolname not in ('enterprisedb', 'alloydbadmin', 'cloudsqladmin')
group by rolname, nspname
order by nspname, rolname;
select '<tr><td>TOTAL<td> ',
 '<td class="align-right">'||to_char(sum(case when relkind='r' THEN 1 ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(sum(case when relkind='r' THEN reltuples ELSE 0 end),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(case when relkind='r' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(case when relkind='i' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(case when relkind='t' THEN cast(1 as bigint)* relpages *8 ELSE 0 end)),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(trunc(sum(cast(1 as bigint)* relpages *8)),'999G999G999G999G999G999G999')
from pg_class, pg_roles, pg_namespace
where relowner=pg_roles.oid
  and relnamespace=pg_namespace.oid
  and rolname not in ('enterprisedb', 'alloydbadmin', 'cloudsqladmin');
select '</table><p>' ;

select '<table class="bordered"><caption>Internals</caption>' ;
select '<tr><th>Tables#</th>',
 '<th>Rows</th>',
 '<th>Relpages*8</th>',
 '<th>Total Size</th>',
 '<th>Main Fork</th>',
 '<th>Free Space Map</th>',
 '<th>Visibility Map</th>',
 '<th>Initialization Fork</th>'
as info;
select
 '<tr><td class="align-right">'||to_char(count(*),'999G999G999999G999G999G999') obj,
 '<td class="align-right">'||to_char(sum(reltuples),'999G999G999G999G999G999G999') as rowcount,
 '<td class="align-right">'||to_char(trunc(sum(cast(1 as bigint)*relpages *8)),'999G999G999G999G999G999G999') relpages,
 '<td class="align-right">'||to_char(trunc(sum(pg_total_relation_size(oid))/1024),'999G999G999G999G999G999G999') total,
 '<td class="align-right">'||to_char(trunc(sum(pg_relation_size(oid, 'main'))/1024),'999G999G999G999G999G999G999') main,
 '<td class="align-right">'||to_char(trunc(sum(pg_relation_size(oid, 'fsm'))/1024),'999G999G999G999G999G999G999') fsm,
 '<td class="align-right">'||to_char(trunc(sum(pg_relation_size(oid, 'vm'))/1024),'999G999G999G999G999G999G999') vm,
 '<td class="align-right">'||to_char(trunc(sum(pg_relation_size(oid, 'init'))/1024),'999G999G999G999G999G999G999') init
from pg_class
where relkind='r';
select '</table><p>' ;


select '<h2 id="vacuum">Vacuum and Analyze</h2><table class="bordered"><caption>Last VACUUM and ANALYZE</caption>' ;
select '<tr><th># Tables</th>',
 '<th>Last autoVACUUM</th>',
 '<th>Last VACUUM</th>',
 '<th>Last autoANALYZE</th>',
 '<th>Last ANALYZE</th>'
as info;
select '<tr><td class="align-right">'||count(*), '<td>'||coalesce(max(last_autovacuum)::TEXT, ' '), '<td>'||coalesce(max(last_vacuum)::TEXT, ' '),
 '<td>'||coalesce(max(last_autoanalyze)::TEXT, ' '), '<td>'||coalesce(max(last_analyze)::TEXT, ' ')
 from pg_stat_user_tables;
select '</table><p>' ;

select '<table id="vacuum2" class="bordered"><caption>Active VACUUMs</caption>' ;
select '<tr><th>Pid</th>',
 '<th>Phase</th>',
 '<th>Heap blocks total</th>',
 '<th>Heap blocks scanned</th>',
 '<th>Heap blocks VACUUMed</th>',
 '<th>Relation</th>',
 '<th>State</th>',
 '<th>Wait event type</th>',
 '<th>Wait event</th>',
 '<th>Query</th>'
as info;
select '<tr><td>'||p.pid, '<td>'||p.phase, 
       '<td class="align-right">'||p.heap_blks_total, '<td class="align-right">'||p.heap_blks_scanned, 
       '<td class="align-right">'||p.heap_blks_vacuumed,
       '<td>'||c.relname, '<td>'||a.state, '<td>'||a.wait_event_type, '<td>'||a.wait_event, 
       '<td>'||a.query
  from pg_stat_progress_vacuum p, pg_stat_activity a, pg_class c
 where p.pid=a.pid
   and p.relid=c.oid;
select '</table><p>' ;

select '<table id="dead" class="bordered"><caption>High dead tuples</caption>' ;
select '<tr><th>Table</th>',
 '<th>Tuples</th>',
 '<th>Dead tuples</th>',
 '<th>Dead%</th>',
 '<th>Last autoVACUUM</th>',
 '<th>Last VACUUM</th>',
 '<th>Last autoANALYZE</th>',
 '<th>Last ANALYZE</th>'
as info;
select '<tr><td>'||schemaname||'.'||relname,
 '<td class="align-right">'||n_live_tup, '<td class="align-right">'||n_dead_tup,
 '<td class="align-right">'||round(100*n_dead_tup/(n_live_tup+n_dead_tup)::float),
 '<td>'||coalesce(last_autovacuum::TEXT, ' '), '<td>'||coalesce(last_vacuum::TEXT, ' '),
 '<td>'||coalesce(last_autoanalyze::TEXT, ' '), '<td>'||coalesce(last_analyze::TEXT, ' ')
  from pg_stat_all_tables
 where n_dead_tup>1000
   and n_dead_tup>n_live_tup*0.05
 order by n_dead_tup desc
 limit 20;

select '<tr><th>Big Table</th>',
 '<th>Tuples</th>',
 '<th>Dead tuples</th>',
 '<th>-</th>',
 '<th>Last autoVACUUM</th>',
 '<th>Last VACUUM</th>',
 '<th>Last autoANALYZE</th>',
 '<th>Last ANALYZE</th>'
as info;
select '<tr><td>'||schemaname||'.'||relname,
 '<td class="align-right">'||n_live_tup, '<td class="align-right">'||n_dead_tup,
 '<td class="align-right">-',
 '<td>'||coalesce(last_autovacuum::TEXT, ' '), '<td>'||coalesce(last_vacuum::TEXT, ' '),
 '<td>'||coalesce(last_autoanalyze::TEXT, ' '), '<td>'||coalesce(last_analyze::TEXT, ' ')
  from pg_stat_all_tables
 order by n_live_tup+n_dead_tup desc
 limit 5;
select '</table><p>' ;

select '<table id="bloat" class="bordered"><caption>Bloated tables (estimated size)</caption>' ;
select '<tr><th>Table (top size)</th>',
 '<th>Fillfactor</th>',
 '<th>Table Size</th>',
 '<th>HR Size</th>',
 '<th>Bloat</th>',
 '<th>HR Bloat</th>',
 '<th>Bloat%</th>'
as info;
SELECT '<tr><td>'||schemaname||'.'||tblname, '<td class="align-right">'||fillfactor, 
       '<td class="align-right">'||bs*tblpages AS real_size, '<td class="align-right">'||pg_size_pretty(bs*tblpages) as HR_size,
  '<td class="align-right">', CASE WHEN tblpages - est_tblpages_ff > 0
    THEN (tblpages-est_tblpages_ff)*bs
    ELSE 0
  END AS bloat_size,
  '<td class="align-right">', CASE WHEN tblpages - est_tblpages_ff > 0
    THEN pg_size_pretty( ((tblpages-est_tblpages_ff)*bs)::bigint)
    ELSE '0'
  END AS hr_bloat_size,
  '<td class="align-right">', CASE WHEN tblpages > 0 AND tblpages - est_tblpages_ff > 0
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
  and tblpages-est_tblpages_ff>1
  and est_tblpages_ff>2
ORDER BY 6 desc limit 20;

select '<tr><th>Table (top percentage)</th>',
 '<th>Fillfactor</th>',
 '<th>Table Size</th>',
 '<th>HR Size</th>',
 '<th>Bloat</th>',
 '<th>HR Bloat</th>',
 '<th>Bloat%</th>'
as info;
SELECT '<tr><td>'||schemaname||'.'||tblname, '<td class="align-right">'||fillfactor, 
       '<td class="align-right">'||bs*tblpages AS real_size, '<td class="align-right">'||pg_size_pretty(bs*tblpages) as HR_size,
  '<td class="align-right">', CASE WHEN tblpages - est_tblpages_ff > 0
    THEN (tblpages-est_tblpages_ff)*bs
    ELSE 0
  END AS bloat_size,
  '<td class="align-right">', CASE WHEN tblpages - est_tblpages_ff > 0
    THEN pg_size_pretty( ((tblpages-est_tblpages_ff)*bs)::bigint)
    ELSE '0'
  END AS hr_bloat_size,
  '<td class="align-right">', CASE WHEN tblpages > 0 AND tblpages - est_tblpages_ff > 0
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
  and tblpages-est_tblpages_ff>1
  and tblpages>2
ORDER BY 10 desc, 6 desc limit 5;
select '</table><p>' ;


select '<table class="bordered"><caption>Total Table Bloat (estimated)</caption>' ;
select '<tr><th>Total table size</th>',
 '<th>Max table bloat</th>', 
 '<th>Total table bloat</th>',
 '<th>Bloat%</th>';
WITH raw AS (
  SELECT
    bs * tblpages AS real_size,
    CASE WHEN tblpages - est_tblpages_ff > 0
         THEN (tblpages - est_tblpages_ff) * bs
         ELSE 0
    END AS bloat_size
  FROM (
    SELECT ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
      tblpages, fillfactor, bs, tblid, schemaname, tblname, heappages, toastpages, is_na
    FROM (
      SELECT
        ( 4 + tpl_hdr_size + tpl_data_size + (2*ma)
          - CASE WHEN tpl_hdr_size%ma = 0 THEN ma ELSE tpl_hdr_size%ma END
          - CASE WHEN ceil(tpl_data_size)::int%ma = 0 THEN ma ELSE ceil(tpl_data_size)::int%ma END
        ) AS tpl_size, bs - page_hdr AS size_per_block, (heappages + toastpages) AS tblpages,
        heappages, toastpages, reltuples, toasttuples, bs, page_hdr, tblid, schemaname, tblname,
        fillfactor, is_na
      FROM (
        SELECT
          tbl.oid AS tblid, ns.nspname AS schemaname, tbl.relname AS tblname, tbl.reltuples,
          tbl.relpages AS heappages, COALESCE(toast.relpages, 0) AS toastpages,
          COALESCE(toast.reltuples, 0) AS toasttuples,
          COALESCE(SUBSTRING(array_to_string(tbl.reloptions, ' ')
                   FROM 'fillfactor=([0-9]+)')::smallint, 100) AS fillfactor,
          current_setting('block_size')::numeric AS bs,
          CASE WHEN version()~'64-bit|x86_64|amd64' THEN 8 ELSE 4 END AS ma,
          24 AS page_hdr,
          23 + CASE WHEN MAX(COALESCE(s.null_frac,0)) > 0 THEN (7 + COUNT(s.attname))/8 ELSE 0::int END
             + CASE WHEN BOOL_OR(att.attname = 'oid' AND att.attnum < 0) THEN 4 ELSE 0 END AS tpl_hdr_size,
          SUM((1-COALESCE(s.null_frac,0)) * COALESCE(s.avg_width,0)) AS tpl_data_size,
          BOOL_OR(att.atttypid = 'pg_catalog.name'::regtype)
            OR SUM(CASE WHEN att.attnum > 0 THEN 1 ELSE 0 END) <> COUNT(s.attname) AS is_na
        FROM pg_attribute AS att
          JOIN pg_class AS tbl ON att.attrelid = tbl.oid
          JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
          LEFT JOIN pg_stats AS s ON s.schemaname = ns.nspname
              AND s.tablename = tbl.relname AND s.inherited = false AND s.attname = att.attname
          LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
        WHERE NOT att.attisdropped AND tbl.relkind IN ('r','m')
        GROUP BY 1,2,3,4,5,6,7,8,9,10
      ) AS s
    ) AS s2
  ) AS s3
  WHERE NOT is_na AND tblpages - est_tblpages_ff > 1 AND est_tblpages_ff > 2
)
SELECT
  '<tr><td>'||pg_size_pretty(SUM(real_size)) AS total_table_size,
  '<td class="align-right">', pg_size_pretty(max(bloat_size)::numeric) AS max_table_bloat,
  '<td class="align-right">', pg_size_pretty(SUM(bloat_size)::numeric) AS total_bloat_size,
  '<td class="align-right">', round(100 * SUM(bloat_size)::numeric / NULLIF(SUM(real_size),0), 2) AS bloat_pct
FROM raw;
select '</table><p>' ;


select '<table id="xid" class="bordered"><caption>Database Max Age</caption>' ;
select '<tr><th>Database</th>',
 '<th>Max XID age</th>', 
 '<th>% Wraparound</th>';
SELECT '<tr><td>'||datname||'<td class="align-right">', age(datfrozenxid), '<td class="align-right">',
       (age(datfrozenxid)::numeric/2000000000*100)::numeric(4,2) as wraparound
  FROM pg_database
 ORDER BY 2 DESC
 limit 32;
select '</table><p>' ;

select '<table class="bordered"><caption>Object Max Age</caption>' ;
select '<tr><th>Object</th>', '<th>Type</th>', '<th>XID age</th>',  '<th>Overdue</th>',  '<th>HR Size</th>', '<th>HR Total Size</th>';
select  '<th>% AV Aggressive</th>', '<th>% AV Anti-wrap</th>', '<th>% Wraparound</th>';
SELECT '<tr><td>'|| nspname ||'.'|| relname, '<td>',
       case WHEN relkind='r' THEN 'Table' 
            WHEN relkind='i' THEN 'Index'
            WHEN relkind='p' THEN 'Partitioned Table'
            WHEN relkind='I' THEN 'Partitioned Index'
            WHEN relkind='v' THEN 'View'
            WHEN relkind='S' THEN 'Sequence'
            WHEN relkind='c' THEN 'Composite Type'
            WHEN relkind='f' THEN 'Foreign Table'
            WHEN relkind='t' THEN 'TOAST Table'
            WHEN relkind='m' THEN 'Materialized View'
            ELSE relkind::text end ||
       case when relispartition then '  Partition'
            else '' end,
       '<td class="align-right">', age(relfrozenxid),
       '<td class="align-right">', age(relfrozenxid) - current_setting('vacuum_freeze_table_age')::integer,
       '<td class="align-right">', pg_size_pretty(pg_relation_size(pg_class.oid)),
       '<td class="align-right">', pg_size_pretty(pg_total_relation_size(pg_class.oid)),
       '<td class="align-right">',round(100.0 * age(relfrozenxid) / current_setting('vacuum_freeze_table_age')::int, 2) AS "%AV Freeze",
       '<td class="align-right">',round(100.0 * age(relfrozenxid) / current_setting('autovacuum_freeze_max_age')::int, 2) AS "%AV Anti-wraparound",
       '<td class="align-right">',round(100.0 * (age(relfrozenxid)::numeric/2^31)::numeric(6,4), 2) "%Wraparound"
  FROM pg_class
  JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
 WHERE relkind in ('r', 'm', 't')
 ORDER by 5 DESC
 LIMIT 5;
select '</table><p><hr>' ;

select '<h2 id="usr">Users/Roles</h2>' ;
select '<table class="bordered">' ;
select '<tr><th>Role</th>',
 '<th>Login</th>',
 '<th>Inherit</th>',
 '<th>Superuser</th>',
 '<th>Expiry time</th>',
 '<th>Max Connections</th>',
 '<th>Config</th>' 
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
	'<td class="align-right">'||count(*)
from pg_roles where rolcanlogin;
select '<tr><td>TOTAL Roles',
	'<td class="align-right">'||count(*)
from pg_roles where not rolcanlogin;
select '</table><p>' ;

select '<div id="ownerDB" class="pre-like"><table class="bordered"><caption>Non-Superuser Ownership</caption>' ;
select '<tr><th>Object Type</th>', '<th>Name</th>', '<th>Owner</th>';
select '<tr><td>Database', '<td>', datname, '<td>',datdba::regrole::text
  from pg_database
 where not datistemplate
   and datdba::regrole::text not in ('postgres', 'rdsadmin', 'enterprisedb', 'alloydbadmin', 'cloudsqladmin')
 order by datname;
select '<tr><td>Schema', '<td>', nspname, '<td>',nspowner::regrole::text
  from pg_namespace
 where nspowner::regrole::text not in ('postgres', 'rdsadmin', 'enterprisedb', 'alloydbadmin', 'cloudsqladmin')
 order by nspname;
select '</table></div>' ;

select '<table class="bordered"><caption>Granted Roles</caption>' ;
select '<tr><th>Grantee</th>', '<th>Admin Option</th>', '<th>Granted Roles</th>';
select '<tr><td>',member::regrole::text, '<td>',admin_option, '<td>',string_agg(roleid::regrole::text, ', ' order by roleid)
  from pg_auth_members
 where member::regrole::text not in ('postgres')
 group by member::regrole::text, admin_option
 order by member::regrole::text;
select '</table>' ;

-- There is a logical error in the following query... but it is more concise
select '<table id="GrantO" class="bordered"><caption>Grants on Objects</caption>' ;
select '<tr><th>Grantee</th>', '<th>Schema</th>', '<th>Count</th>', '<th>Privileges</th>';
with grt as (
select grantee as gr, table_schema ts, privilege_type pt, count(*) as cnt
  from information_schema.table_privileges
 where grantee not in ('postgres', 'pg_monitor', 'rdsadmin', 'enterprisedb')
   and table_schema not in ('pg_catalog', 'information_schema', 'sys')
   and table_schema not like 'pg_temp_%'
 group by grantee, table_schema, privilege_type
 order by grantee, table_schema, privilege_type ) 
select '<tr><td>',gr, '<td>',ts, '<td>',cnt, '<td>',string_agg(pt, ', ' order by pt)
  from grt
 group by gr, ts, cnt;
select '</table><p></div>';

\if :var_as_admin
select '<table id="usr_sec" class="bordered"><caption>Users with poor password</caption>' ;
select '<tr><th>Username</th>','<th>Password</th>',
 '<th>Note</th>' ;
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

select '<h2 id="usr_hba">HBA Rules</h2>' ;
select '<table class="bordered">' ;
select '<tr><th>Type</th>','<th>Database</th>',
 '<th>User</th>',  '<th>Address</th>', '<th>Netmask</th>',
 '<th>Auth</th>',  '<th>Options</th>', '<th>Error</th>';
select '<tr><td>',type,
       '<td>',database, '<td>',user_name, '<td>',address, '<td>',netmask,
       '<td>',auth_method, '<td class="split">',options, '<td>',error
  from pg_hba_file_rules
 order by line_number;
select '</table><p>';
\endif
select '<hr>';

select '<h2 id="sql">Sessions</h2>' ;
select '<div id="sql_g"></div>' ;
select '<table><tr>';
select '<td class="vtop"><table class="bordered sfont"><caption>Per-User Sessions (First 16)</caption>'
 ;
select '<tr><th>User</th>', '<th>Database</th>',
       '<th>Count</th>', '<th>Active</th>', '<th>Idle TX</th>';
select '<tr><td>',usename,
       '<td>',datname,
 	'<td>', count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end),
 	'<td>', sum(case when state='idle in transaction' then 1 else 0 end)
  from pg_stat_activity
 group by usename, datname
 order by 6 desc, 1
 limit 16;
select 	'<tr><td>TOTAL (', count(distinct usename),
 	' distinct users)<td><td>'|| count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end),
 	'<td>', sum(case when state='idle in transaction' then 1 else 0 end)
  from pg_stat_activity;
select '</table>' ;

select '<td class="vtop"><table class="bordered sfont"><caption>Per-Host Sessions (First 16)</caption>'
 ;
select '<tr><th>Address</th>', '<th>Host</th>', '<th>Database</th>',
       '<th>Count</th>', '<th>Active</th>', '<th>Idle TX</th>';
select '<tr><td>',client_addr, '<td>',client_hostname,
       '<td>',datname,
 	'<td>', count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end),
 	'<td>', sum(case when state='idle in transaction' then 1 else 0 end)
  from pg_stat_activity
 group by client_addr, client_hostname, datname
 order by 8 desc, 2
 limit 16;
select 	'<tr><td>TOTAL (', count(distinct client_addr),
 	' distinct clients)<td><td><td>'|| count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end),
 	'<td>', sum(case when state='idle in transaction' then 1 else 0 end)
  from pg_stat_activity;
select '</table>' ;

select '<td class="vtop"><table class="bordered sfont"><caption>Per-APP Sessions (First 16)</caption>'
 ;
select '<tr><th>APP</th>', '<th>Database</th>',
       '<th>Count</th>', '<th>Active</th>', '<th>Idle TX</th>';
select '<tr><td>', replace(replace(application_name,'<','&lt;'), '>','&gt;') appl,
       '<td>',datname,
 	'<td>', count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end),
 	'<td>', sum(case when state='idle in transaction' then 1 else 0 end)
  from pg_stat_activity
 group by replace(replace(application_name,'<','&lt;'), '>','&gt;'), datname
 order by 6 desc, 2
 limit 16;
select 	'<tr><td>TOTAL (', count(distinct application_name),
 	' distinct applications)<td><td>'|| count(*),
 	'<td>', sum(case when state='active' then 1 else 0 end),
 	'<td>', sum(case when state='idle in transaction' then 1 else 0 end)
  from pg_stat_activity;
select '</table> </table>' ;

select '<div id="sql_a"></div>' ;
select '<table class="bordered sortable sfont"><caption>Sessions (now: ', now(),')</caption>';

\if :var_version_14p
select '<thead><tr><th>Pid</th>',
 '<th>Database</th>',
 '<th>User</th>',
 '<th>Address</th>',
 '<th>Session start</th>',
 '<th>State</th>',
 '<th>Query start</th>',
 '<th>Duration</th>',
 '<th>Backend</th>',
 '<th>Application</th>',
 '<th>Query</th>',
 '<th>Query_ID</th></tr></thead><tbody>';
select 	'<tr><td>',pid,
 	'<td>',datname,
 	'<td>',usename,
 	'<td>',client_addr,
 	'<td>',to_char(backend_start, 'YYYY-MM-DD HH24:MI:SS'),
 	'<td>',state,
 	'<td>',query_start,
 	'<td>',now()-query_start,
 	'<td>',backend_type,
 	'<td>',replace(replace(application_name,'<','&lt;'), '>','&gt;'),
 	'<td><div class="truncate">',replace(replace(replace(query,'<','&lt;'), '>','&gt;'),',',', '), '</div>',
 	'<td>',query_id
  from pg_stat_activity
 where pid<>pg_backend_pid()
 order by case when state='active' then 0
               when state='idle in transaction' then 1
               when state='idle' then 3
               when state is null then 4
               else 2
           end, query_start;
select '</tbody></table><p>' ;

select '<div id="sql_x"></div>' ;
select '<table class="bordered"><caption>Active Sessions details (now: ', now(),')</caption>' ;
select '<tr><th>Pid</th>',
 '<th>Database</th>',
 '<th>User</th>',
 '<th>Query start</th>',
 '<th>State</th>',
 '<th>Wait Event</th>',
 '<th>Wait Type</th>',
 '<th>Backend</th>',
 '<th>Query</th>',
 '<th>query_id</th>';
select 	'<tr><td>',pid,
 	'<td>',datname,
 	'<td>',usename,
 	'<td>',query_start,
 	'<td>',state,
 	'<td>',wait_event,
 	'<td>',wait_event_type,
 	'<td>',backend_type,
 	'<td><div class="truncate">',replace(replace(replace(query,'<','&lt;'), '>','&gt;'),',',', ') as query, '</div>',
 	'<td>',query_id
  from pg_stat_activity
 where pid<>pg_backend_pid()
   and state='active'
   and backend_type<>'walsender'
 order by query_start;
select '</table>' ;
\else
select '<thead><tr><th>Pid</th>',
 '<th>Database</th>',
 '<th>User</th>',
 '<th>Address</th>',
 '<th>Session start</th>',
 '<th>State</th>',
 '<th>Query start</th>',
 '<th>Duration</th>',
 '<th>Backend</th>',
 '<th>Application</th>',
 '<th>Query</th></tr></thead><tbody>' ;
select 	'<tr><td>',pid,
 	'<td>',datname,
 	'<td>',usename,
 	'<td>',client_addr,
 	'<td>',to_char(backend_start, 'YYYY-MM-DD HH24:MI:SS'),
 	'<td>',state,
 	'<td>',query_start,
 	'<td>',now()-query_start,
 	'<td>',backend_type,
 	'<td>',replace(replace(application_name,'<','&lt;'), '>','&gt;'),
 	'<td><div class="truncate">',replace(replace(replace(query,'<','&lt;'), '>','&gt;'),',',', '), '</div>'
  from pg_stat_activity
 where pid<>pg_backend_pid()
 order by case when state='active' then 0
               when state='idle in transaction' then 1
               when state='idle' then 3
               when state is null then 4
               else 2
           end, query_start;
select '</tbody></table><p>' ;
\endif

select '<p><hr>' ;

select '<h2 id="lockd">Locks</h2>'  ;
select '<div id="wlock"></div>'  ;
select '<table class="bordered"><caption>Waiting Locks  (now: ', now(), ')</caption>';
select '<tr><th>Pid</th>',
 '<th>Type</th>',
 '<th>Database</th>',
 '<th>Relation</th>',
 '<th>Mode</th>',
 '<th>Granted</th>',
 '<th>Wait start</th>'
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
select '</table><p>' ;

select '<table id="block" class="bordered"><caption>Blocking Locks</caption>';
select '<tr><th>Blocked Pid</th>',
 '<th>Blocked User</th>',
 '<th>Blocking Pid</th>',
 '<th>Blocking User</th>',
 '<th> Blocked Statement</th>',
 '<th> Blocking Session Current Statement</th>'
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
 WHERE NOT blocked_locks.GRANTED
 ORDER BY blocked_locks.pid, blocking_locks.pid;
select '</table><p>' ;

\if :var_version_14p
select '<table class="bordered"><caption>Blocking Locks (PG14+)</caption>';
select '<tr><th>Blocked Pid</th>',
 '<th>Blocked User</th>',
 '<th>Blocking Pid</th>',
 '<th>Blocking User</th>',
 '<th> Blocked Statement</th>',
 '<th> Blocking Session Current Statement</th>',
 '<th> Mode</th>',
 '<th> Lock Type</th>',
 '<th> Wait Start</th>'
as info;
SELECT '<tr><td>',blocked.pid AS blocked_pid,
       '<td>',blocked.usename AS blocked_user,
       '<td>',blocking.pid AS blocking_pid,
       '<td>',blocking.usename AS blocking_user,
       '<td>',blocked.query AS blocked_statement,
       '<td>',blocking.query AS current_statement_in_blocking_process,
       '<td>',mode, '<td>',locktype, '<td>',waitstart
  FROM pg_stat_activity AS blocked
  JOIN pg_locks AS lck ON blocked.pid = lck.pid
  JOIN pg_stat_activity AS blocking ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
 WHERE NOT lck.GRANTED
 ORDER BY waitstart;
select '</table><p>' ;
\endif

select '<table class="bordered"><caption>All Locks</caption>' ;
select '<tr><th>Pid</th>',
 '<th>Type</th>',
 '<th>Database</th>',
 '<th>Relation</th>',
 '<th>Mode</th>',
 '<th>Granted</th>'
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
select '</table><p><hr>' ;

select '<h2 id="sga">Memory</h2>' ;
select '<table class="bordered">' ;
select '<tr><th>Element</th>',
 '<th>Value</th>',
 '<th>Description</th>'
as info;
select '<tr><td>'||name,
	'<td class="align-right">'||case when unit='kB'  then pg_size_pretty(setting::bigint*1024)
                when unit='8kB' then pg_size_pretty(setting::bigint*1024*8)
                when unit='B'   then pg_size_pretty(setting::bigint)
                when unit='MB'  then pg_size_pretty(setting::bigint*1024*1024)
                else coalesce(setting||' '||unit,setting) end,
	'<td>'||short_desc
from pg_settings
where name like '%buffers';
select '<tr><td>'||name,
	'<td class="align-right">'||case when unit='kB'  then pg_size_pretty(setting::bigint*1024)
                when unit='8kB' then pg_size_pretty(setting::bigint*1024*8)
                when unit='B'   then pg_size_pretty(setting::bigint)
                when unit='MB'  then pg_size_pretty(setting::bigint*1024*1024)
                else coalesce(setting||' '||unit,setting) end,
	'<td>'||short_desc
from pg_settings
where name like '%mem';
select '</table><p><hr>' ;

select '<h2 id="stat">Instance Statistics</h2>' ;
select '<table class="bordered"><caption>Database Statistics</caption>' ;
select '<tr><th>Database</th>',
 '<th>Backends</th>',
 '<th>Commit</th>',
 '<th>TPS</th>',
 '<th>Rollback</th>',
 '<th>Read</th>',
 '<th>Hit</th>',
 '<th>Hit Ratio%</th>',
 '<th>Return</th>',
 '<th>Fetch</th>',
 '<th>Insert</th>',
 '<th>Update</th>',
 '<th>Delete</th>',
 '<th> Statistics reset </th>';
select '<tr><td>'||datname, 
	'<td class="align-right">'||numbackends, 
	'<td class="align-right">'||xact_commit, 
	'<td class="align-right">',
        round(xact_commit/coalesce(EXTRACT(EPOCH FROM (now()-stats_reset)),
                                   EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time())))::decimal,2),
	'<td class="align-right">'||xact_rollback, 
	'<td class="align-right">'||blks_read, 
	'<td class="align-right">'||blks_hit, 
   '<td class="align-right">'||round((blks_hit)*100.0/nullif(blks_read+blks_hit, 0),2) hit_ratio, 
	'<td class="align-right">'||tup_returned, 
	'<td class="align-right">'||tup_fetched, 
	'<td class="align-right">'||tup_inserted, 
	'<td class="align-right">'||tup_updated, 
	'<td class="align-right">'||tup_deleted,
	'<td>'|| stats_reset
from pg_stat_database
where datname not like 'template%';

select '<tr><td>TOTAL (', count(*),
	')<td class="align-right">'||sum(numbackends), 
	'<td class="align-right">'||sum(xact_commit), 
	'<td class="align-right"> ',
	'<td class="align-right">'||sum(xact_rollback), 
	'<td class="align-right">'||sum(blks_read), 
	'<td class="align-right">'||sum(blks_hit), 
   '<td class="align-right">', 
	'<td class="align-right">'||sum(tup_returned), 
	'<td class="align-right">'||sum(tup_fetched), 
	'<td class="align-right">'||sum(tup_inserted), 
	'<td class="align-right">'||sum(tup_updated), 
	'<td class="align-right">'||sum(tup_deleted),
	'<td>'|| min(stats_reset)
from pg_stat_database
where datname not like 'template%';
select '</table><p>' ;

select '<table class="bordered"><caption>BG Writer statistics</caption>' ;
select '<tr><th>checkpoints_timed</th>',
 '<th> checkpoints_req </th>',
 '<th> buffers_checkpoint </th>',
 '<th> buffers_clean </th>',
 '<th> maxwritten_clean </th>',
 '<th> buffers_backend </th>',
 '<th> buffers_alloc </th>',
 '<th> checkpoint_write (s) </th>',
 '<th> checkpoint_sync (s) </th>',
 '<th> Statistics reset </th>';
select '<tr><td class="align-right">'||checkpoints_timed, 
	'<td class="align-right">'|| checkpoints_req, 
	'<td class="align-right">'|| buffers_checkpoint, 
	'<td class="align-right">'|| buffers_clean, 
	'<td class="align-right">'|| maxwritten_clean, 
	'<td class="align-right">'|| buffers_backend, 
	'<td class="align-right">'|| buffers_alloc,
	'<td class="align-right">'|| round(checkpoint_write_time/1000),
	'<td class="align-right">'|| round(checkpoint_sync_time/1000),
	'<td>'|| stats_reset
 from pg_stat_bgwriter;
select '</table><p>' ;

select '<table class="bordered"><caption>Checkpointer/BGWriter KPI</caption><thead><tr><th scope="col">Timed CP Ratio%</th><th scope="col">Minutes between CP</th><th scope="col">Clean by CP Ratio%</th><th scope="col">Clean by BGW Ratio%</th><th scope="col">BGW Halt Ratio%</th></tr></thead><tbody>' ;
select '<tr><td class="align-right">'||round(100.0*checkpoints_timed/nullif(checkpoints_req+checkpoints_timed,0),2),
       '<td class="align-right">'||round((extract('epoch' from now() - stats_reset)/60)::numeric/nullif(checkpoints_req+checkpoints_timed,0),2),
       '<td class="align-right">'||round(100.0*buffers_checkpoint/nullif(buffers_checkpoint + buffers_clean + buffers_backend,0),2),
       '<td class="align-right">'||round(100.0*buffers_clean/nullif(buffers_checkpoint + buffers_clean + buffers_backend,0),2),
       '<td class="align-right">'||coalesce(round(100.0*maxwritten_clean/nullif(buffers_clean,0),4),0)
 from pg_stat_bgwriter;
select '</tbody></table><p>' ;

select '<table class="bordered"><caption>Cache statistics</caption><thead><tr><th scope="col">Object Type</th><th scope="col">#Read</th><th scope="col">#Hit</th><th scope="col">Hit Ratio%</th></tr></thead><tbody>' ;
SELECT '<tr><td>Table',
  '<td class="align-right">'||sum(heap_blks_read) as heap_read,
  '<td class="align-right">'||sum(heap_blks_hit)  as heap_hit,
  '<td class="align-right">'||trunc(100*sum(heap_blks_hit) / nullif(sum(heap_blks_hit) + sum(heap_blks_read),0),2) as ratio
FROM 
  pg_statio_user_tables;
SELECT '<tr><td>Index',
  '<td class="align-right">'||sum(idx_blks_read) as idx_read,
  '<td class="align-right">'||sum(idx_blks_hit)  as idx_hit,
  '<td class="align-right">'||trunc(100*(sum(idx_blks_hit) - sum(idx_blks_read)) / nullif(sum(idx_blks_hit),0),2) as ratio
FROM 
  pg_statio_user_indexes;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Statement Statistics Summary</caption><thead><tr><th scope="col">Database</th><th scope="col">Calls</th><th scope="col">Total Time</th><th scope="col">DBcpu</th><th scope="col">IOcpu</th><th scope="col">Stmt/sec.</th></tr></thead><tbody>' ;
\if :var_version_13p
\if :var_version_14p
select '<tr><td>', datname,
       '<td class="align-right">'||sum(calls),
       '<td class="align-right">'||round(sum(total_exec_time)),
       '    <td>', round(sum( (total_exec_time)/(EXTRACT(EPOCH FROM (now()-stats_reset))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-stats_reset))*1000) )::numeric,5) IOcpu,
       '<td class="align-right">'||round(sum( (calls)/(EXTRACT(EPOCH FROM (now()-stats_reset))) )::numeric,3) Exec
  from pg_stat_statements, pg_database, pg_stat_statements_info
 where pg_stat_statements.dbid=pg_database.oid
   and pg_stat_statements.toplevel
 group by datname;
select '<tr><td>TOTAL',
       '<td class="align-right">'||sum(calls),
       '<td class="align-right">'||round(sum(total_exec_time)),
       '    <td>', round(sum( (total_exec_time)/(EXTRACT(EPOCH FROM (now()-stats_reset))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-stats_reset))*1000) )::numeric,5) IOcpu,
       '<td class="align-right">'||round(sum( (calls)/(EXTRACT(EPOCH FROM (now()-stats_reset))) )::numeric,3) Exec
  from pg_stat_statements, pg_stat_statements_info where toplevel;
\else
select '<tr><td>', datname,
       '<td class="align-right">'||sum(calls),
       '<td class="align-right">'||round(sum(total_exec_time)),
       '    <td>', round(sum( (total_exec_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) IOcpu
  from pg_stat_statements, pg_database
 where pg_stat_statements.dbid=pg_database.oid
 group by datname;
select '<tr><td>TOTAL',
       '<td class="align-right">'||sum(calls),
       '<td class="align-right">'||round(sum(total_exec_time)),
       '    <td>', round(sum( (total_exec_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) IOcpu
  from pg_stat_statements;
\endif
\else
select '<tr><td>', datname,
       '<td class="align-right">'||sum(calls),
       '<td class="align-right">'||round(sum(total_time)),
       '    <td>', round(sum( (total_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) IOcpu
  from pg_stat_statements, pg_database
 where pg_stat_statements.dbid=pg_database.oid
 group by datname;
select '<tr><td>TOTAL',
       '<td class="align-right">'||sum(calls),
       '<td class="align-right">'||round(sum(total_time)),
       '    <td>',  round(sum( (total_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) DBcpu,
       '    <td>', round(sum( (blk_read_time+blk_write_time)/(EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time()))*1000) )::numeric,5) IOcpu
  from pg_stat_statements;
\endif
select '</tbody></table><p>' ;


select '<p><table class="bordered"><caption>Operational and Performance KPIs</caption><thead><tr><th scope="col">Statistic</th><th scope="col">Value</th><th scope="col">Advisory Level</th></tr></thead><tbody>' ;

select '<tr><td>Supported Version',' <td class="align-right">', --  Major version check
       current_setting('server_version_num')::integer/10000,
       '<td> &gt; 12';

select '<tr><td>Connection usage %',' <td class="align-right">', -- Connection Utilization Percentage
       round(count(*)/current_setting('max_connections')::numeric*100,2),
       '<td> &lt; 70'
  from pg_stat_activity;

select '<tr><td>Active sessions',' <td class="align-right">', -- Active sessions
       count(*),
       '<td> &lt; 5'
  from pg_stat_activity
 where state='active'
   and pid <> pg_backend_pid()
   and backend_type <> 'walsender';

select '<tr><td>Waiting locks',' <td class="align-right">', -- Waiting locks
       count(*),
       '<td> = 0'
  from pg_locks
 where not granted;

select '<tr><td>Long-running active queries',' <td class="align-right">', -- Long-running active queries
       count(*),
       '<td> = 0'
  from pg_stat_activity
 where state = 'active'
   and backend_type not in ('walsender', 'autovacuum worker')
   and (now() - query_start) > '5 minutes'::interval;

select '<tr><td>Idle in Transaction',' <td class="align-right">', -- Idle in Transaction Count
       count(*),
       '<td> = 0'
  from pg_stat_activity
 where state='idle in transaction'
   and (now() - state_change) > '30 second'::interval;

select '<tr><td>Oldest transaction age (s)',' <td class="align-right">',  -- Oldest transaction age (s)
       round(EXTRACT(EPOCH FROM (now() - min(query_start))), 2),
       '<td> &lt; 3600'
  from pg_stat_activity
 where state='active'
   and pid <> pg_backend_pid()
   and backend_type <> 'walsender';

select '<tr><td>Invalid indexes',' <td class="align-right">', -- Invalid indexes
       count(*),
       '<td> = 0'
  from pg_index i
 where i.indisvalid = false;

select '<tr><td>Max Dead Tuples %',' <td class="align-right">', -- High Dead Tuples Percentage
       round(coalesce(max(n_dead_tup/(n_live_tup+n_dead_tup+0.0)*100.0), 0),2),
       '<td> &lt; 20'
  from pg_stat_all_tables
 where n_dead_tup>1000;

WITH raw AS (
  SELECT
    bs * tblpages AS real_size,
    CASE WHEN tblpages - est_tblpages_ff > 0
         THEN (tblpages - est_tblpages_ff) * bs
         ELSE 0
    END AS bloat_size
  FROM (
    SELECT ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
      tblpages, fillfactor, bs, tblid, schemaname, tblname, heappages, toastpages, is_na
    FROM (
      SELECT
        ( 4 + tpl_hdr_size + tpl_data_size + (2*ma)
          - CASE WHEN tpl_hdr_size%ma = 0 THEN ma ELSE tpl_hdr_size%ma END
          - CASE WHEN ceil(tpl_data_size)::int%ma = 0 THEN ma ELSE ceil(tpl_data_size)::int%ma END
        ) AS tpl_size, bs - page_hdr AS size_per_block, (heappages + toastpages) AS tblpages,
        heappages, toastpages, reltuples, toasttuples, bs, page_hdr, tblid, schemaname, tblname,
        fillfactor, is_na
      FROM (
        SELECT
          tbl.oid AS tblid, ns.nspname AS schemaname, tbl.relname AS tblname, tbl.reltuples,
          tbl.relpages AS heappages, COALESCE(toast.relpages, 0) AS toastpages,
          COALESCE(toast.reltuples, 0) AS toasttuples,
          COALESCE(SUBSTRING(array_to_string(tbl.reloptions, ' ')
                   FROM 'fillfactor=([0-9]+)')::smallint, 100) AS fillfactor,
          current_setting('block_size')::numeric AS bs,
          CASE WHEN version()~'64-bit|x86_64|amd64' THEN 8 ELSE 4 END AS ma,
          24 AS page_hdr,
          23 + CASE WHEN MAX(COALESCE(s.null_frac,0)) > 0 THEN (7 + COUNT(s.attname))/8 ELSE 0::int END
             + CASE WHEN BOOL_OR(att.attname = 'oid' AND att.attnum < 0) THEN 4 ELSE 0 END AS tpl_hdr_size,
          SUM((1-COALESCE(s.null_frac,0)) * COALESCE(s.avg_width,0)) AS tpl_data_size,
          BOOL_OR(att.atttypid = 'pg_catalog.name'::regtype)
            OR SUM(CASE WHEN att.attnum > 0 THEN 1 ELSE 0 END) <> COUNT(s.attname) AS is_na
        FROM pg_attribute AS att
          JOIN pg_class AS tbl ON att.attrelid = tbl.oid
          JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
          LEFT JOIN pg_stats AS s ON s.schemaname = ns.nspname
              AND s.tablename = tbl.relname AND s.inherited = false AND s.attname = att.attname
          LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
        WHERE NOT att.attisdropped AND tbl.relkind IN ('r','m')
        GROUP BY 1,2,3,4,5,6,7,8,9,10
      ) AS s
    ) AS s2
  ) AS s3
  WHERE NOT is_na AND tblpages - est_tblpages_ff > 1 AND est_tblpages_ff > 2
)
select '<tr><td>Table Bloat %',' <td class="align-right">',    -- Table Bloat Percentage
       round(100 * SUM(bloat_size)::numeric / NULLIF(SUM(real_size),0), 2),
       '<td> &lt; 50',
       '<tr><td>Largest Bloat Table',' <td class="align-right">',    -- Largest Table Bloat
       pg_size_pretty(max(bloat_size)::numeric),
       '<td> &lt; 10 GB'
FROM raw;

select '<tr><td>Autovacuum Freeze %',' <td class="align-right">', -- Autovacuum Freeze
       max(round(100.0 * age(relfrozenxid) / current_setting('vacuum_freeze_table_age')::int, 2)),
       '<td> &lt; 95'
  FROM pg_class
 WHERE relkind in ('r', 'm', 't');

select '<tr><td>Transaction ID wraparound risk',' <td class="align-right">', -- Transaction ID wraparound risk
       round(100.0 * (age(datfrozenxid) / (SELECT setting::numeric FROM pg_settings WHERE name = 'autovacuum_freeze_max_age'))::numeric, 2),
       '<td> &lt; 95'
  from pg_database
 where datname = current_database();

select '<tr><td>Replication lag',' <td class="align-right">', -- Replication lag 
       max(replay_lag),
       '<td> &lt; 1'
  from pg_stat_replication;

select '<tr><td>Replication slot lag (bytes)',' <td class="align-right">',  -- Replication slot lag (bytes)
       max(pg_current_wal_lsn() - restart_lsn),
       '<td> &lt; 1 GB'
  from pg_replication_slots
 where active;

select '<tr><td>Cache Hit %',' <td class="align-right">', -- Cache Hit
       round(100.0 * blks_hit / (blks_hit + blks_read), 2),
       '<td> &gt; 95'
  from pg_stat_database
 where datname=current_database();

select '<tr><td>Indexes Cache Hit %',' <td class="align-right">', -- Indexes Cache Hit
       round(100.0 * sum(idx_blks_hit) / nullif(sum(idx_blks_hit) + sum(idx_blks_read), 0), 2),
       '<td> &gt; 98'
  from pg_statio_user_indexes;

select '<tr><td>Timed Checkpoint %',' <td class="align-right">', -- Timed Checkpoint
       round(100.0*checkpoints_timed/nullif(checkpoints_req+checkpoints_timed,0),2),
       '<td> &gt; 90'
  from pg_stat_bgwriter;

select '<tr><td>Checkpoints requested %',' <td class="align-right">',   -- Checkpoints requested percentage
       round(100.0 * checkpoints_req / nullif(checkpoints_timed + checkpoints_req, 0), 2),
       '<td> &lt; 10'
  from pg_stat_bgwriter;

select '<tr><td>Database size',' <td class="align-right">', -- Database size
       pg_size_pretty(pg_database_size(datname)),
       '<td> &lt; 1 TB'
  from pg_database
 where datname=current_database();

\if :var_version_14p
select '<tr><td>DBcpu %',' <td class="align-right">', -- DB CPU
       round((sum(total_exec_time) / (EXTRACT(EPOCH FROM (now() - (SELECT stats_reset FROM pg_stat_statements_info))) * 1000) * 100)::numeric, 2),
       '<td> &lt; 50'
  from pg_stat_statements
 where toplevel;
\endif

select '<tr><td>Active time %',' <td class="align-right">', -- Database Active Time
       round(active_time::decimal/1000*100/coalesce(EXTRACT(EPOCH FROM (now()-stats_reset)), EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time())))::decimal,2),
       '<td> &lt; 50'
  from pg_stat_database
 where datname=current_database();

select '<tr><td>TPS',' <td class="align-right">', -- TPS
       round(xact_commit/coalesce(EXTRACT(EPOCH FROM (now()-stats_reset)), EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time())))::decimal,2),
       '<td> &lt; 1000'
  from pg_stat_database
 where datname=current_database();

select '<tr><td>Rollback %',' <td class="align-right">', -- Rollback Ratio
       round((xact_rollback::decimal/xact_commit)*100, 2),
       '<td> &lt; 1'
  from pg_stat_database
 where datname=current_database();

select '<tr><td>Rows inserted /hour',' <td class="align-right">', -- Rows inserted /hour
       replace(replace(pg_size_pretty(round(tup_inserted::decimal*3600/coalesce(EXTRACT(EPOCH FROM (now()-stats_reset)),
                 EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time())), 2))::decimal),'bytes',''),'B',''),
       '<td> &lt; 1 M'
  from pg_stat_database
 where datname=current_database();

select '<tr><td>Temporary bytes /hour',' <td class="align-right">', -- Temporary bytes writen /hour
       pg_size_pretty(round(temp_bytes::decimal*3600/coalesce(EXTRACT(EPOCH FROM (now()-stats_reset)), EXTRACT(EPOCH FROM (now()-pg_postmaster_start_time())), 2))::decimal),
       '<td> &lt;1 GB'
  from pg_stat_database
 where datname=current_database();

select '<tr><td>Unindexed tables',' <td class="align-right">', -- Unindexed tables
       count(*),
       '<td> = 0'
  from information_schema.tables tab
  left join pg_indexes tco 
         on tab.table_schema = tco.schemaname
         and tab.table_name = tco.tablename 
         and (tco.indexdef like 'CREATE INDEX%' OR tco.indexdef like 'CREATE UNIQUE%')
 where tab.table_type = 'BASE TABLE'
   and tab.table_schema not in ('pg_catalog', 'information_schema', 'sys')
   and tco. indexname is null;

select '<tr><td>Duplicate indexes',' <td class="align-right">', -- Duplicate indexes
       count(*),
       '<td> = 0'
  FROM pg_index i
  JOIN pg_class ct ON i.indrelid=ct.oid
  JOIN pg_class ci ON i.indexrelid=ci.oid
  JOIN pg_namespace ni ON ci.relnamespace=ni.oid
  JOIN pg_index ii ON ii.indrelid=i.indrelid
                  AND ii.indexrelid != i.indexrelid
                  AND (array_to_string(ii.indkey, ' ')) = (array_to_string(i.indkey, ' '))
                  AND (array_to_string(ii.indcollation, ' ')) = (array_to_string(i.indcollation, ' '))
                  AND (array_to_string(ii.indclass, ' ')) = (array_to_string(i.indclass, ' '))
                  AND (array_to_string(ii.indoption, ' ')) = (array_to_string(i.indoption, ' '))
                  AND NOT (ii.indkey::integer[] @> ARRAY[0])      
                  AND NOT (i.indkey::integer[] @> ARRAY[0])        
                  AND i.indpred IS NULL                           
                  AND ii.indpred IS NULL                          
                  AND CASE WHEN i.indisunique THEN ii.indisunique 
                      AND array_to_string(ii.indkey, ' ') = array_to_string(i.indkey, ' ')
                      ELSE true END
  JOIN pg_class ctii ON ii.indrelid=ctii.oid
  JOIN pg_class cii ON ii.indexrelid=cii.oid
 WHERE ci.relname > cii.relname    
   AND NOT i.indisprimary;

select '<tr><td>Too much objects',' <td class="align-right">', -- Too much objects
       count(*),
       '<td> &lt;20 K'
 from pg_class, pg_roles
where relowner=pg_roles.oid
  and rolname not in ('enterprisedb', 'alloydbadmin', 'cloudsqladmin');

select '<tr><td>Overpartitioning count',' <td class="align-right">', -- Overpartitioning count (small partitions excluding newest)
       count(sp.oid),
       '<td> = 0'
  from (
        SELECT p.oid, p.relname, p.reltuples, pg_relation_size(p.oid) as rel_size
        FROM pg_class p
        JOIN pg_namespace n ON n.oid = p.relnamespace
        WHERE p.relispartition
          AND p.relkind = 'r' -- regular table
          AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
          AND (pg_relation_size(p.oid) < 8192 * 10 OR p.reltuples < 1000)
    ) AS sp
    WHERE sp.oid NOT IN (SELECT oid FROM pg_class WHERE relispartition AND relkind = 'r' ORDER BY oid DESC LIMIT 1);

select '</tbody></table><p><hr>' ;


select '<h2 id="stmt">Statements Statistics</h2>';
\if :var_version_14p
SELECT '<p>Instance restart: '|| pg_postmaster_start_time(),
       '  Now: '|| now(),
       '<br>Statement statistics reset: '|| stats_reset,
       ' Dealloc: '|| dealloc
  FROM pg_stat_statements_info;
\else
SELECT '<p>Instance restart: '|| pg_postmaster_start_time(),
       '  Now: '|| now();
\endif

select '<!-- Report running: '|| now() || ' -->';
select '<p><table class="bordered sortable sfont"><caption>Statement Statistics</caption><thead><tr>';
select '<th scope="col" class="tac tooltip">Query <span class="tooltiptext">Query, click on the text to see the full query text</span></th>';
select '<th scope="col" class="tac tooltip">User <span class="tooltiptext">The user executing the statement</span></th>';
select '<th scope="col" class="tac tooltip">Calls <span class="tooltiptext">Total executions</span></th>';
select '<th scope="col" class="tac tooltip">Average<span class="tooltiptext">Average execution time expressed in seconds</span></th>';
select '<th scope="col" class="tac tooltip">Max<span class="tooltiptext">Maximum execution time expressed in seconds</span></th>';
select '<th scope="col" class="tac tooltip">Total Time <span class="tooltiptext">Total execution time expressed in seconds</span></th>';
select '<th scope="col" class="tac tooltip">Reads /Call <span class="tooltiptext">Bytes readed for each call</span></th>';
select '<th scope="col" class="tac tooltip">Rows /Call <span class="tooltiptext">Average number of rows returned by the statement</span></th>';
select '<th scope="col" class="tac tooltip">Hit Ratio% <span class="tooltiptext">Percentage of blocks readed from the buffer cache</span></th>';

\if :var_version_14p
select '<th scope="col" class="tac tooltip">WAL /Call<span class="tooltiptext">Bytes written in WALs (Write-A-head Logs) for each call</span></th>';
select '<th scope="col" class="tac tooltip">tmp /Call<span class="tooltiptext">Bytes written in temporary files for each call</span></th>';
select '<th scope="col" class="tac tooltip">QueryID<span class="tooltiptext">Unique identifier for the query</span></th>';
select '<th scope="col" class="tac tooltip">T<span class="tooltiptext">True when is a top level statement, false when is called by a function</span></th>';
SELECT '</thead><tbody>';

SELECT '<tr><td><div class="truncate">'||replace(substring(replace(replace(query,'<','&lt;'), '>','&gt;'),1,8192),',',', '),
  '</div> <td>'||pg_get_userbyid(userid), '<td class="align-right">'||calls,
  '<td class="align-right">'||round((total_exec_time::numeric / nullif(calls::numeric, 0))/1000,3),
  '<td class="align-right">'||round((max_exec_time::numeric)/1000,3),
  '<td class="align-right">'||round((total_exec_time::numeric)/1000,3),
  '<td class="align-right"><span class="nobr">'||pg_size_pretty( coalesce(round(((shared_blks_hit + shared_blks_read)::numeric*8192 / nullif(calls::numeric, 0)),0),0) ),
                          '</span>',
  '<td class="align-right">'||round((rows::numeric / nullif(calls::numeric, 0)),2),
  '<td class="align-right">'||coalesce(round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2),0)  AS hit_percent,
  '<td class="align-right">'||pg_size_pretty( coalesce(round((wal_bytes::numeric)/nullif(calls::numeric, 0),0),0) ),
  '<td class="align-right">'||pg_size_pretty( coalesce(round((temp_blks_written::numeric)*8192/nullif(calls::numeric, 0),0),0) ),
  '<td>'||queryid,
  '<td>'||CASE WHEN toplevel THEN 'T' ELSE 'F' END
  FROM pg_stat_statements 
 ORDER BY total_exec_time DESC LIMIT 30;
\else
 \if :var_version_13p
SELECT '<th>WAL /Call</th> <th>tmp /Call</th> <th>QueryID</th> </thead><tbody>';
SELECT '<tr><td>'||replace(substring(replace(replace(query,'<','&lt;'), '>','&gt;'),1,8192),',',', '),
  ' <td>'||pg_get_userbyid(userid), '<td class="align-right">'||calls,
  '<td class="align-right">'||round((total_exec_time::numeric / nullif(calls::numeric, 0))/1000,3),
  '<td class="align-right">'||round((max_exec_time::numeric)/1000,3),
  '<td class="align-right">'||round((total_exec_time::numeric)/1000,3),
  '<td class="align-right">'||pg_size_pretty( coalesce(round(((shared_blks_hit + shared_blks_read)::numeric*8192 / nullif(calls::numeric, 0)),0),0) ),
  '<td class="align-right">'||round((rows::numeric / nullif(calls::numeric, 0)),2),
  '<td class="align-right">'||coalesce(round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2),0)  AS hit_percent,
  '<td class="align-right">'||pg_size_pretty( coalesce(round((wal_bytes::numeric)/nullif(calls::numeric, 0),0),0) ),
  '<td class="align-right">'||pg_size_pretty( coalesce(round((temp_blks_written::numeric)*8192/nullif(calls::numeric, 0),0),0) ),
  '<td>'||queryid
  FROM pg_stat_statements 
 ORDER BY total_exec_time DESC LIMIT 30;
 \else
SELECT '</thead><tbody>';
SELECT '<tr><td>'||replace(substring(replace(replace(query,'<','&lt;'), '>','&gt;'),1,8192),',',', '),
  ' <td>'||pg_get_userbyid(userid), '<td class="align-right">'||calls,
  '<td class="align-right">'||round((total_time::numeric / nullif(calls::numeric, 0))/1000,3),
  '<td class="align-right">'||round((max_time::numeric)/1000,3),
  '<td class="align-right">'||round((total_time::numeric)/1000,3),
  '<td class="align-right">'||pg_size_pretty( coalesce(round(((shared_blks_hit + shared_blks_read)::numeric*8192 / nullif(calls::numeric, 0)),0),0) ),
  '<td class="align-right">'||round((rows::numeric / nullif(calls::numeric, 0)),2),
  '<td class="align-right">'||coalesce(round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2),0)  AS hit_percent
  FROM pg_stat_statements 
 ORDER BY total_time DESC LIMIT 30;
 \endif
\endif
select '</tbody></table><p>' ;

select '<p><a id="slow"></a><p>' ;
select '<p><table class="bordered sfont"><caption>Slowest Statements</caption><thead><tr><th scope="col">Query</th><th scope="col">User</th><th scope="col">Calls</th><th scope="col">Average (sec.)</th><th scope="col">Max (sec.)</th><th scope="col">Total Time</th><th scope="col">Blks read /Call</th><th scope="col">Rows /Call</th><th scope="col">Hit Ratio%</th>' ;
\if :var_version_13p
SELECT '<th>WAL MB</th> <th>tmp MB</th> <th>QueryID</th> </thead><tbody>';
SELECT '<tr><td><div class="truncate">'||replace(substring(replace(replace(query,'<','&lt;'), '>','&gt;'),1,8192),',',', '),
  '</div> <td>'||pg_get_userbyid(userid), '<td class="align-right">'||calls,
  '<td class="align-right">'||round((total_exec_time::numeric / nullif(calls::numeric, 0))/1000,3),
  '<td class="align-right">'||round((max_exec_time::numeric)/1000,3),
  '<td class="align-right">'||round((total_exec_time::numeric)/1000,3),
  '<td class="align-right">'||round(((shared_blks_hit + shared_blks_read)::numeric / nullif(calls::numeric, 0)),2),
  '<td class="align-right">'||round((rows::numeric / nullif(calls::numeric, 0)),2),
  '<td class="align-right">'||coalesce(round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2),0)  AS hit_percent,
  '<td class="align-right">'||round((wal_bytes::numeric)/(1024*1024),0),
  '<td class="align-right">'||coalesce(round((temp_blks_written::numeric)/128/nullif(calls::numeric, 0),0), 0),
  '<td>'||queryid
  FROM pg_stat_statements 
 WHERE pg_get_userbyid(userid) not in ('enterprisedb', 'efm', 'alloydbadmin', 'cloudsqladmin')  -- Comment if needed
   AND calls>0
 ORDER BY max_exec_time DESC
 LIMIT 10;
\else
SELECT '</thead><tbody>';
SELECT '<tr><td>'||replace(substring(replace(replace(query,'<','&lt;'), '>','&gt;'),1,8192),',',', '),
  ' <td>'||pg_get_userbyid(userid), '<td class="align-right">'||calls,
  '<td class="align-right">'||round((total_time::numeric / nullif(calls::numeric, 0))/1000,3),
  '<td class="align-right">'||round((max_time::numeric)/1000,3),
  '<td class="align-right">'||round((total_time::numeric)/1000,3),
  '<td class="align-right">'||coalesce(round(((shared_blks_hit + shared_blks_read)::numeric / nullif(calls::numeric, 0)),2),0),
  '<td class="align-right">'||round((rows::numeric / nullif(calls::numeric, 0)),2),
  '<td class="align-right">'||round((100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0)),2)  AS hit_percent
  FROM pg_stat_statements 
 WHERE pg_get_userbyid(userid) not in ('enterprisedb', 'efm', 'alloydbadmin', 'cloudsqladmin')  -- Comment if needed
   AND calls>0
 ORDER BY max_exec_time DESC
 LIMIT 10;
\endif
select '</tbody></table><p><hr>' ;


select '<h2 id="tbl">Table Statistics</h2>' ;
select '<p><table class="bordered"><caption>Table Statistics (reset: '|| coalesce(stats_reset::text, 'never') || ')</caption>'
  from pg_stat_database where datname=current_database();
select '<thead><tr><th scope="col">Schema</th><th scope="col">Table</th><th scope="col">#Rows</th><th scope="col">Seq. Readed Tuples</th><th scope="col">Idx. Readed Tuples</th><th scope="col">Sequential Scan</th><th scope="col">Index Scan</th><th scope="col">Insert</th><th scope="col">Update</th><th scope="col">Hot Update</th><th scope="col">Delete</th><th scope="col">Index Usage Ratio%</th><th scope="col">HOT Update Ratio%</th></tr></thead><tbody>' ;
select '<tr><td>'||schemaname,
  '<td>'||relname,
  '<td class="align-right">'||n_live_tup,
  '<td class="align-right">'||coalesce(seq_tup_read, 0),
  '<td class="align-right">'||coalesce(idx_tup_fetch, 0),
  '<td class="align-right">'||coalesce(seq_scan, 0),
  '<td class="align-right">'||coalesce(idx_scan, 0),
  '<td class="align-right">'||coalesce(n_tup_ins, 0),
  '<td class="align-right">'||coalesce(n_tup_upd, 0),
  '<td class="align-right">'||coalesce(n_tup_hot_upd, 0),
  '<td class="align-right">'||coalesce(n_tup_del, 0),
  '<td class="align-right">'||coalesce(idx_scan*100/nullif(idx_scan+seq_scan,0), -1) as idx_hit_ratio,
  '<td class="align-right">'||coalesce(n_tup_hot_upd*100/nullif(n_tup_upd,0), -1) as hot_hit_ratio
 from pg_stat_user_tables
 order by (coalesce(seq_tup_read,0) +coalesce(idx_tup_fetch,0) +coalesce(n_tup_ins,0) +
           coalesce(n_tup_upd,0) +coalesce(n_tup_del,0)) desc
 limit 20;
select '</tbody></table><p>' ;

select '<p><table class="bordered"><caption>Tables Custom Storage Definition</caption><thead><tr><th scope="col">Schema</th><th scope="col">Object</th><th scope="col">Storage Parameter</th></tr></thead><tbody>' ;
select '<tr><td>'||n.nspname,
   '<td>', t.relname,
   '<td>', unnest(t.reloptions)
  from pg_class t, pg_namespace n
 where t.relnamespace=n.oid
   and n.nspname not in('pg_catalog')
 order by n.nspname, t.relname
 limit 20;
select '</tbody></table><p>' ;

select '<p><table class="bordered"><caption>Tables Caching</caption><thead><tr><th scope="col">Schema</th><th scope="col">Table</th><th scope="col">Heap Reads</th><th scope="col">Index Reads</th><th scope="col">TOAST Reads</th><th scope="col">Heap Hit Ratio%</th><th scope="col">Index Hit Ratio%</th><th scope="col">TOAST Hit Ratio%</th></tr></thead><tbody>' ;
select '<tr><td>'||schemaname,
  '<td>'||relname,
  '<td class="align-right">'||coalesce(heap_blks_read, 0),
  '<td class="align-right">'||coalesce(idx_blks_read, 0),
  '<td class="align-right">'||coalesce(toast_blks_read, 0),
  '<td class="align-right">'||coalesce(heap_blks_hit*100/nullif(heap_blks_read+heap_blks_hit,0), -1) as tb_hit_ratio,
  '<td class="align-right">'||coalesce(idx_blks_hit*100/nullif(idx_blks_read+idx_blks_hit,0), -1) as idx_hit_ratio,
  '<td class="align-right">'||coalesce(toast_blks_hit*100/nullif(toast_blks_read+toast_blks_hit,0), -1) as toast_hit_ratio
 from pg_statio_user_tables
 where heap_blks_read>0
 order by heap_blks_read desc
 limit 20;
select '</tbody></table><p>' ;

select '<p><div class="pre-like"><strong>Tables without any Index</strong><br>' ;
select tab.table_schema ||'.'|| tab.table_name
  from information_schema.tables tab
  left join pg_indexes tco 
         on tab.table_schema = tco.schemaname
         and tab.table_name = tco.tablename 
         and (tco.indexdef like 'CREATE INDEX%' OR tco.indexdef like 'CREATE UNIQUE%')
 where tab.table_type = 'BASE TABLE'
   and tab.table_schema not in ('pg_catalog', 'information_schema', 'sys')
   and tco. indexname is null
 order by tab.table_schema, tab.table_name
 limit 1000;
select '<br><br><strong>Tables without Unique Indexes</strong><br>' ;
select tab.table_schema ||'.'|| tab.table_name
  from information_schema.tables tab
  left join pg_indexes tco 
         on tab.table_schema = tco.schemaname
         and tab.table_name = tco.tablename 
         and tco.indexdef like 'CREATE UNIQUE%'
 where tab.table_type = 'BASE TABLE'
   and tab.table_schema not in ('pg_catalog', 'information_schema', 'sys')
   and tco. indexname is null
 order by tab.table_schema, tab.table_name
 limit 1000;
select '<br><br><strong>Tables without Primary Key</strong><br>' ;
select tab.table_schema ||'.'|| tab.table_name
  from information_schema.tables tab
  left join information_schema.table_constraints tco 
         on tab.table_schema = tco.table_schema
         and tab.table_name = tco.table_name 
         and tco.constraint_type = 'PRIMARY KEY'
 where tab.table_type = 'BASE TABLE'
   and tab.table_schema not in ('pg_catalog', 'information_schema', 'sys')
   and tco.constraint_name is null
 order by tab.table_schema, tab.table_name
 limit 1000;
select '</div><p><hr>' ;


select '<h2 id="idx">Index Statistics</h2>' ;
select '<a href="#constr2">Defined indexes</a>, <a href="#constr3">Constraints</a>, <a href="#idx_inv">Invalid indexes</a>,';
select '<a href="#idx_mis">Missing indexes</a>, <a href="#idx_most">Most used indexes</a>, <a href="#idx_un">Unused indexes</a>,';
select '<a href="#idx_dup">Duplicate indexes</a>, <a href="#idx_red">Redundant indexes</a>, <a href="#idx_all">All indexes</a>';
select '<p><div class="pre-like">' ;

select '<p><a id="constr2"></a>' ;
select '<table class="bordered"><caption>Defined indexes</caption><thead><tr><th scope="col">Schema</th><th scope="col">Type</th><th scope="col">Count</th><th scope="col">Primary</th><th scope="col">Unique</th><th scope="col">Avg #keys</th><th scope="col">Max #keys</th></tr></thead><tbody>' ;
SELECT '<tr><td>',ns.nspname, '<td>',am.amname, '<td class="align-right">',count(*),
       '<td class="align-right">',sum(case when idx.indisprimary then 1 else 0 end) pk,
       '<td class="align-right">',sum(case when idx.indisunique then 1 else 0 end) uq,
       '<td class="align-right">',round(avg(idx.indnkeyatts),2), '<td class="align-right">',max(idx.indnkeyatts)
  FROM pg_index idx 
  JOIN pg_class cls ON cls.oid=idx.indexrelid
  JOIN pg_class tbl ON tbl.oid=idx.indrelid
  JOIN pg_am am ON am.oid=cls.relam
  JOIN pg_namespace ns ON cls.relnamespace = ns.oid
 WHERE ns.nspname not in ('pg_catalog', 'sys', 'pg_toast')
   AND ns.nspname not like 'pg_toast_temp%'
 GROUP BY ns.nspname, am.amname
 ORDER BY ns.nspname, am.amname;
select '</tbody></table><p>' ;

select '<p><a id="constr3"></a>' ;
select '<table class="bordered"><caption>Constraints</caption><thead><tr><th scope="col">Schema</th><th scope="col">Primary</th><th scope="col">Unique</th><th scope="col">Foreign</th><th scope="col">Check</th><th scope="col">Trigger</th><th scope="col">Exclusion</th></tr></thead><tbody>' ;
select '<tr><td>'||nspname,
 '<td class="align-right">'||sum(case when contype ='p' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when contype ='u' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when contype ='f' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when contype ='c' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when contype ='t' THEN 1 ELSE 0 end),
 '<td class="align-right">'||sum(case when contype ='x' THEN 1 ELSE 0 end)
from pg_constraint, pg_namespace
where connamespace=pg_namespace.oid
  and nspname NOT IN('information_schema', 'pg_catalog', 'sys')
group by nspname
order by nspname;
select '</tbody></table><p>' ;

select '<p><a id="idx_inv"></a>' ;
select '<p><table class="bordered"><caption>Invalid indexes</caption><thead><tr><th scope="col">Schema</th><th scope="col">Index</th><th scope="col">On Table</th></tr></thead><tbody>' ;
SELECT '<tr><td>'|| n.nspname ||'<td>'|| c1.relname ||'<td>'|| c2.relname
  FROM pg_class c1, pg_index i, pg_namespace n, pg_class c2
 WHERE c1.relnamespace = n.oid
   AND i.indexrelid = c1.oid
   AND c2.oid = i.indrelid
   AND i.indisvalid = false;
select '</tbody></table><p>' ;

select '<p><a id="idx_mis"></a>' ;
select '<p><table class="bordered"><caption>Missing indexes (using foreign constraints, excluding small/unused tables)</caption><thead><tr><th scope="col">Schema</th><th scope="col">Relation</th><th scope="col">Constraint</th><th scope="col">Issue</th><th scope="col">Parent</th><th scope="col">Columns</th><th scope="col">#Table Writes</th><th scope="col">#Table Scan</th><th scope="col">#Parent Scan</th><th scope="col">Table Size</th><th scope="col">Parent Size</th></tr></thead><tbody>' ;
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
        pg_relation_size(conrelid)::numeric as table_size,
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
        seq_scan as parent_scans,
        pg_relation_size(parentid)::numeric as parent_size
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
    '<td>', parent_name,
    '<td>', replace(cols_list::text, ',', ', '),
    '<td>', writes,
    '<td>', table_scans,
    '<td>', parent_scans,
    '<td>', pg_size_pretty(table_size),
    '<td>', pg_size_pretty(parent_size)
FROM fk_index_check
    JOIN parent_table_stats USING (fkoid)
    JOIN fk_table_stats USING (fkoid)
WHERE table_size > 5*1024^2
  AND ( writes > 1000
        OR parent_writes > 1000
        OR parent_size > 10*1024^2 )
  AND parent_size>8*1024
ORDER BY parent_scans DESC, table_size DESC, table_name, fk_name
 LIMIT 64;
select '</tbody></table>' ;

select '<p><a id="idx_most"></a>' ;
select '<p><table class="bordered"><caption>Most used indexes</caption><thead><tr><th scope="col">Schema</th><th scope="col">Relation</th><th scope="col">Index</th><th scope="col">Size</th><th scope="col">Idx Scan</th><th scope="col">Idx Tuples Fetch</th><th scope="col">Idx Tuples Read</th></tr></thead><tbody>' ;
SELECT '<tr><td>',s.schemaname, '<td>',s.relname,
       '<td>',s.indexrelname, '<td class="align-right">',pg_relation_size(s.indexrelid),
       '<td class="align-right">',s.idx_scan, '<td class="align-right">',s.idx_tup_fetch, '<td class="align-right">',s.idx_tup_read  
  FROM pg_catalog.pg_stat_user_indexes s
  JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
 WHERE s.idx_scan>0
 ORDER BY s.idx_scan DESC
 LIMIT 16;
select '</tbody></table><p>' ;

select '<p><a id="idx_un"></a>' ;
select '<p><table class="bordered"><caption>Unused indexes</caption><thead><tr><th scope="col">Schema</th><th scope="col">Relation</th><th scope="col">Index</th><th scope="col">Size</th></tr></thead><tbody>' ;
SELECT '<tr><td>',s.schemaname, '<td>',s.relname,
       '<td>',s.indexrelname, '<td class="align-right">',pg_relation_size(s.indexrelid)
  FROM pg_catalog.pg_stat_user_indexes s
  JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
 WHERE s.idx_scan = 0      
   AND 0 <>ALL (i.indkey)  
   AND NOT i.indisunique   
   AND NOT EXISTS (SELECT 1 FROM pg_catalog.pg_constraint c
          WHERE c.conindid = s.indexrelid)
 ORDER BY pg_relation_size(s.indexrelid) DESC
 LIMIT 64;
select '</tbody></table><p>' ;

select '<p><a id="idx_dup"></a>' ;
select '<p><table class="bordered"><caption>Duplicate indexes</caption><thead><tr><th scope="col">Schema</th><th scope="col">Relation</th><th scope="col">Index</th><th scope="col">DDL</th><th scope="col">Size</th></tr></thead><tbody>' ;
SELECT '<tr><td>',ni.nspname, '<td>',ct.relname, 
       '<td>',ci.relname AS dup_idx,
       '<td>',pg_get_indexdef(i.indexrelid) AS dup_def,
       '<td class="align-right">',pg_relation_size(i.indexrelid), 
       '<tr><td><td><td>',cii.relname AS enc_idx, 
       '<td>',pg_get_indexdef(ii.indexrelid) AS enc_def,
       '<td class="align-right">',pg_relation_size(ii.indexrelid)
  FROM pg_index i
  JOIN pg_class ct ON i.indrelid=ct.oid
  JOIN pg_class ci ON i.indexrelid=ci.oid
  JOIN pg_namespace ni ON ci.relnamespace=ni.oid
  JOIN pg_index ii ON ii.indrelid=i.indrelid
                  AND ii.indexrelid != i.indexrelid
                  AND (array_to_string(ii.indkey, ' ')) = (array_to_string(i.indkey, ' '))
                  AND (array_to_string(ii.indcollation, ' ')) = (array_to_string(i.indcollation, ' '))
                  AND (array_to_string(ii.indclass, ' ')) = (array_to_string(i.indclass, ' '))
                  AND (array_to_string(ii.indoption, ' ')) = (array_to_string(i.indoption, ' '))
                  AND NOT (ii.indkey::integer[] @> ARRAY[0])      
                  AND NOT (i.indkey::integer[] @> ARRAY[0])        
                  AND i.indpred IS NULL                           
                  AND ii.indpred IS NULL                          
                  AND CASE WHEN i.indisunique THEN ii.indisunique 
                      AND array_to_string(ii.indkey, ' ') = array_to_string(i.indkey, ' ')
                      ELSE true END
  JOIN pg_class ctii ON ii.indrelid=ctii.oid
  JOIN pg_class cii ON ii.indexrelid=cii.oid
 WHERE ci.relname > cii.relname  -- Trick to show the couples only once (works for 2)
 ORDER BY ni.nspname, ct.relname, ci.relname;
select '</tbody></table><p>' ;

select '<p><a id="idx_red"></a>' ;
select '<p><table class="bordered"><caption>Redundant indexes</caption><thead><tr><th scope="col">Schema</th><th scope="col">Relation</th><th scope="col">Index</th><th scope="col">DDL</th><th scope="col">Size</th></tr></thead><tbody>' ;
SELECT '<tr><td>',ni.nspname, '<td>',ct.relname, 
       '<td>',ci.relname AS dup_idx,
       '<td>',pg_get_indexdef(i.indexrelid) AS dup_def,
       '<td class="align-right">',pg_relation_size(i.indexrelid), 
       -- i.indkey,
       '<tr><td><td><td>',cii.relname AS enc_idx,   -- Encompassing index
       '<td>',pg_get_indexdef(ii.indexrelid) AS enc_def,
       '<td class="align-right">',pg_relation_size(ii.indexrelid),
       '<!-- -->'
       -- ii.indkey
  FROM pg_index i
  JOIN pg_class ct ON i.indrelid=ct.oid
  JOIN pg_class ci ON i.indexrelid=ci.oid
  JOIN pg_namespace ni ON ci.relnamespace=ni.oid
  JOIN pg_index ii ON ii.indrelid=i.indrelid
                  AND ii.indexrelid != i.indexrelid
                  AND (array_to_string(ii.indkey, ' ') || ' ') like (array_to_string(i.indkey, ' ') || '%')
                  AND (array_to_string(ii.indcollation, ' ')  || ' ') like (array_to_string(i.indcollation, ' ') || '%')
                  AND (array_to_string(ii.indclass, ' ')  || ' ') like (array_to_string(i.indclass, ' ') || '%')
                  AND (array_to_string(ii.indoption, ' ')  || ' ') like (array_to_string(i.indoption, ' ') || '%')
                  AND NOT (ii.indkey::integer[] @> ARRAY[0])      -- Remove for expression indexes 
                  AND NOT (i.indkey::integer[] @> ARRAY[0])       -- Remove for expression indexes 
                  AND i.indpred IS NULL                           -- Remove for indexes with predicates
                  AND ii.indpred IS NULL                          -- Remove for indexes with predicates
                  AND CASE WHEN i.indisunique THEN ii.indisunique 
                           AND array_to_string(ii.indkey, ' ') = array_to_string(i.indkey, ' ') 
                           ELSE true END
  JOIN pg_class ctii ON ii.indrelid=ctii.oid
  JOIN pg_class cii ON ii.indexrelid=cii.oid
 WHERE NOT i.indisprimary  
    -- ct.relname NOT LIKE 'pg_%'
 ORDER BY ni.nspname, ct.relname, ci.relname;
select '</tbody></table><p>' ;

select '<p><a id="idx_all"></a>' ;
select '<p><table class="bordered"><caption>All indexes</caption><thead><tr><th scope="col">Schema</th><th scope="col">Relation</th><th scope="col">Index</th><th scope="col">DDL</th></tr></thead><tbody>' ;

SELECT '<tr><td>',schemaname, '<td>',tablename,
       '<td>',indexname, '<td>',indexdef
  FROM pg_indexes
 WHERE schemaname not in ('pg_catalog', 'sys')
   AND tablename not like 'pgstatspack%'
 ORDER BY schemaname, tablename, indexname
 LIMIT 10000;
select '</tbody></table><p></div><hr>' ;

select '<!-- Report running: '|| now() || ' -->';

select '<h2 id="partdet">Partitioning Statistics</h2>' ;
select '<p><div class="pre-like">' ;

select '<p><table class="bordered"><caption>Partitions</caption><thead><tr><th scope="col">Schema</th><th scope="col">Owner</th><th scope="col">Partitioned Object</th><th scope="col"># Partition</th><th scope="col">Tuples</th></tr></thead><tbody>' ;
select '<tr><td>'||nspname, '<td>'||rolname,
   '<td>', t.relname,
   '<td>', count(distinct(p.relname)),
   '<td class="align-right">', to_char(sum( case when p.reltuples>0 then p.reltuples else 0 end ),'999G999G999G999G999G999G999')
  from pg_class t, pg_inherits i, pg_class p, pg_roles r, pg_namespace n
 where i.inhparent = t.oid 
   and p.oid = i.inhrelid
   and t.relowner=r.oid
   and t.relnamespace=n.oid
   and p.relkind in ('r', 'p')
 group by nspname, rolname, t.relname
 order by nspname, rolname, t.relname;
select '</tbody></table>' ;

select '<p><table class="bordered"><caption sortable>Partitioning Details</caption><thead><tr><th scope="col">Schema</th><th scope="col">Owner</th><th scope="col">Partitioned Object</th><th scope="col">Partition</th><th scope="col">Expression</th><th scope="col">Tuples</th></tr></thead><tbody>' ;
select '<tr><td>'||nspname, '<td>'||rolname,
   '<td>', t.relname,
   '<td>', p.relname,
   '<td>', pg_get_partkeydef ( t.oid ),' ', pg_get_expr(p.relpartbound, p.oid, true),
   '<td class="align-right">', to_char(p.reltuples,'999G999G999G999G999G999G999')
  from pg_class t, pg_inherits i, pg_class p, pg_roles r, pg_namespace n
 where i.inhparent = t.oid 
   and p.oid = i.inhrelid
   and t.relowner=r.oid
   and t.relnamespace=n.oid
   and p.relkind in ('r', 'p')
 order by nspname, rolname, t.relname, pg_get_expr(p.relpartbound, p.oid, true);
select '</tbody></table></div><p>' ;


select '<h2 id="param">Tuning Parameters</h2>' ;
select '<p><table class="bordered"><caption>Most Important Tuning Parameters</caption><thead><tr><th scope="col">Parameter</th><th scope="col">Value</th><th scope="col">Min</th><th scope="col">Max</th><th scope="col">Unit</th><th scope="col">Context</th><th scope="col">Description</th><th scope="col">Setting</th><th scope="col">Source</th></tr></thead><tbody>' ;
select '<tr><td>',name,
   '<td class="align-right">',
   replace(replace(
           case when unit='kB'  then pg_size_pretty(setting::bigint*1024)
                when unit='8kB' then pg_size_pretty(setting::bigint*1024*8)
                when unit='B'   then pg_size_pretty(setting::bigint)
                when unit='MB'  then pg_size_pretty(setting::bigint*1024*1024)
                else coalesce(setting||' '||unit,setting) end,
           '<','&lt;'),'>','&gt;'),
   '<td class="align-right">',min_val,'<td class="align-right">',max_val,
   '<td>',unit, '<td>',context, '<td>',short_desc,
   '<td class="align-right">',replace(replace(setting,'<','&lt;'),'>','&gt;'),
   '<td>',source
  from pg_settings
 where name in ('max_connections','shared_buffers','effective_cache_size','work_mem', 'temp_buffers', 'wal_buffers',
               'checkpoint_completion_target', 'checkpoint_segments', 'synchronous_commit', 'wal_writer_delay',
               'max_fsm_pages','fsync','commit_delay','commit_siblings','random_page_cost', 'synchronous_standby_names',
               'checkpoint_timeout', 'max_wal_size', 'min_wal_size', 'random_page_cost', 'default_toast_compression',
               'bgwriter_lru_maxpages', 'bgwriter_lru_multiplier', ' bgwriter_delay', 'maintenance_work_mem',
               'autovacuum_vacuum_cost_limit', 'vacuum_cost_limit', 'autovacuum_vacuum_cost_delay', 'vacuum_cost_delay') 
 order by context, name; 
select '</tbody></table><p><hr>' ;


select '<h2 id="big">Biggest Objects</h2>' ;
select '<p><table class="bordered"><caption>Biggest Objects</caption><thead><tr><th scope="col">Object</th><th scope="col">Type</th><th scope="col">Owner</th><th scope="col">Schema</th><th scope="col">Rows</th><th scope="col">Size (relpages main)</th><th scope="col">Bytes (relation)</th><th scope="col">HR Size (total)</th></tr></thead><tbody>' ;
select '<tr><td>'||relname,
 '<td>'||case WHEN relkind='r' THEN 'Table' 
    WHEN relkind='i' THEN 'Index'
    WHEN relkind='t' THEN 'TOAST Table'
    ELSE relkind::text||'' end,
 '<td>'||rolname,  '<td>'||n.nspname,
 '<td class="align-right">'||to_char(reltuples,'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(relpages::INT8*8*1024,'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(pg_relation_size(pg_class.oid),'999G999G999G999G999G999G999'),
 '<td class="align-right">'||case WHEN relkind='r' THEN pg_size_pretty(pg_total_relation_size(pg_class.oid)) ELSE '' end
  from pg_class, pg_roles, pg_catalog.pg_namespace n
 where relowner=pg_roles.oid
   and n.oid=pg_class.relnamespace
 order by relpages desc, reltuples desc
 limit 32;
select '</tbody></table><p>' ;

select '<p><a id="bigp"></a>'  ;
select '<p><table class="bordered"><caption>Biggest Partitioned Objects</caption><thead><tr><th scope="col">Object</th><th scope="col">Hierarchy level</th><th scope="col">Partition#</th><th scope="col">HR Size</th><th scope="col">Bytes</th></tr></thead><tbody>' ;
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
       '<td class="align-right">',max(level)-1 AS hierarchy_level,
       '<td class="align-right">',count(*) AS partition_count,
       '<td class="align-right">',pg_size_pretty(sum(pg_total_relation_size(relid))) AS pretty_total_size,
       '<td class="align-right">',to_char(sum(pg_total_relation_size(relid)),'999G999G999G999G999G999G999') AS total_size
       -- array_agg(relid :: REGCLASS) AS all_partitions
  FROM tabs
 GROUP BY parent
 HAVING max(level)>1
 ORDER BY sum(pg_total_relation_size(relid)) DESC
 LIMIT 10;
select '</tbody></table><p>' ;

select '<p><a id="toast"></a>'  ;
select '<p><table class="bordered"><caption>Biggest TOASTs</caption>' ;
select '<tr><th>TOAST</th>',
 '<th>Owner</th>', '<th>Table</th>',
 '<th>Chunks</th>',
 '<th>Bytes</th>'
as info;
select '<tr><td>'||t.relname,
 '<td>'||rolname,  '<td>'||n.nspname||'.'||r.relname,
 '<td class="align-right">'||to_char(t.reltuples,'999G999G999G999G999G999G999'),
 '<td class="align-right">'||to_char(pg_relation_size(t.oid),'999G999G999G999G999G999G999')
  from pg_class t, pg_roles, pg_catalog.pg_namespace n, pg_class r
 where t.relowner=pg_roles.oid
   and n.oid=r.relnamespace
   and r.reltoastrelid = t.oid
   and t.relkind='t'
   and t.reltuples>0
 order by pg_relation_size(t.oid) desc
 limit 10;
select '</tbody></table><p>' ;

select '<p><a id="lo"></a>'  ;
select '<p><table class="bordered"><caption>Large Objects</caption>' ;
select '<thead><tr><th scope="col">Owner</th><th scope="col">Large Objects</th><th scope="col">Pages</th><th scope="col">Pages Largest</th></tr></thead><tbody>' ;
select '<tr><td>',lomowner::regrole as owner, '<td class="align-right">',count(distinct loid) as large_obj, 
       '<td class="align-right">',count(*) pages,  '<td class="align-right">',max(pageno)+1 pages_largest
  from pg_largeobject l join pg_largeobject_metadata m on l.loid=m.oid
 group by lomowner;
select '</tbody></table><p><hr>' ;

select '<h2 id="psq">PL/pgSQL, Data types</h2>' ;
select '<p><table class="bordered"><caption>Procedural Languages</caption>' ;
select '<thead><tr><th scope="col">Available languages</th></tr></thead><tbody>' ;
select '<tr><td>'||lanname
from pg_language;
select '</tbody></table><p><table class="bordered"><caption>PL Objects</caption>';
select '<thead><tr><th scope="col">Owner</th><th scope="col">Kind</th><th scope="col">Language</th><th scope="col">Count</th><th scope="col">Source size</th></tr></thead><tbody>' ;
select '<tr><td>'||o.rolname,
 '<td>'||case when f.prokind='f' then 'Function'
           when f.prokind='a' then 'Aggregate func.'
           when f.prokind='w' then 'Window func.'
           when f.prokind='p' then 'Procedure'
           else 'Other' end,
 '<td>'||l.lanname, '<td class="align-right">'||count(*),
 '<td class="align-right">'||sum(char_length(prosrc))
  from pg_proc f, pg_roles o, pg_language l
 where f.proowner=o.oid
   and f.prolang=l.oid
   and o.rolname not in ('postgres', 'enterprisedb', 'alloydbadmin', 'cloudsqladmin')
 group by o.rolname, l.lanname, prokind
 order by o.rolname, prokind, l.lanname;
select '</tbody></table><p>' ;

-- regexp_split_to_table(prosrc, E'\n')

select '<p><a id="dtype"></a>'  ;
select '<div class="pre-like"><p><table class="bordered"><tr><th>Data Types - Details</th></tr></table>' ;

select '<p><table class="bordered"><caption>Tables/Columns</caption>' ;
select '<thead><tr><th scope="col">Owner</th><th scope="col">Schema</th><th scope="col">Tables</th><th scope="col">Columns</th></tr></thead><tbody>' ;
select '<tr><td>'||o.rolname, '<td>'||n.nspname, '<td class="align-right">'||count(distinct r.relname||n.nspname),
       '<td class="align-right">'||count(distinct r.relname||n.nspname||a.attname)
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
select '</tbody></table>' ;


select '<p><table class="bordered"><caption>Data Types</caption>' ;
select '<thead><tr><th scope="col">Owner</th><th scope="col">Schema</th><th scope="col">Data type</th><th scope="col">Count</th></tr></thead><tbody>' ;
select '<tr><td>'||o.rolname, '<td>'||n.nspname, '<td>'||t.typname, '<td class="align-right">'||count(*)
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
select '</tbody></table></div><p><hr>' ;


select '<h2 id="rman">Backup</h2>' ;
select '<p><table class="bordered"><caption>Physical Backup</caption>' ;
select '<thead><tr><th scope="col">Parameter</th><th scope="col">Value</th></tr></thead><tbody>' ;
select '<tr><td>',name,'<td>',setting
 from pg_settings
 where name in ('archive_mode', 'archive_timeout')
 order by name; 
select '<tr><td>Write xlog location',
 '<td>'||pg_current_wal_lsn();
select '<tr><td>Insert xlog location',
 '<td>'||pg_current_wal_insert_lsn();
select '</tbody></table><p>' ;

select '<p><a id="arch"></a>' ;
select '<p><table class="bordered"><caption>Archiver Statistics</caption>' ;
select '<thead><tr><th scope="col">Archived Count</th><th scope="col">Last Archived WAL</th><th scope="col">Last Archived Time</th><th scope="col">Failed Count</th><th scope="col">Last Failed WAL</th><th scope="col">Last Failed Time</th><th scope="col">Statistics Reset</th><th scope="col">Archiving</th><th scope="col">WALS ps</th></tr></thead><tbody>' ;

select '<tr><td>',archived_count, '<td>',last_archived_wal, '<td>',last_archived_time, '<td>',failed_count,
       '<td>',last_failed_wal, '<td>',last_failed_time, '<td>',stats_reset,
       '<td>', current_setting('archive_mode')::BOOLEAN
                 AND (last_failed_wal IS NULL
                  OR last_failed_wal <= last_archived_wal),
       '<td>', CAST (archived_count AS NUMERIC) / EXTRACT (EPOCH FROM age(now(), stats_reset))
  from pg_stat_archiver;
select '</tbody></table><p><hr>' ;

select '<p><a id="repl"></a><h2>Replication</h2>'  ;
select '<p><table class="bordered"><caption>Replication Summary</caption>' ;
select '<thead><tr><th scope="col">Item</th><th scope="col">Value</th></tr></thead><tbody><tr><td>In Recovery Mode</td><td>'||pg_is_in_recovery()||'</td></tr></tbody></table><p>' ;
select '<p><table class="bordered"><caption>Replication Parameters</caption><thead><tr><th scope="col">Parameter</th><th scope="col">Value</th></tr></thead><tbody>' ;
select '<tr><td>',name,'<td>',replace(replace(setting,'<','&lt;'),'>','&gt;')
 from pg_settings
 where name in ('wal_level', 'archive_command', 'hot_standby', 'max_wal_senders', 'checkpoint_segments', 'max_wal_size', 'archive_mode', 
                'max_standby_archive_delay', 'max_standby_streaming_delay', 'hot_standby_feedback', 'synchronous_commit',
                'wal_keep_segments', 'wal_keep_size', 'synchronous_standby_names', 'recovery_target_timeline',
                'wal_receiver_create_temp_slot', 'max_slot_wal_keep_size', 'ignore_invalid_pages',
                'primary_slot_name', 'primary_conninfo', 'max_slot_wal_keep_size',
                'vacuum_defer_cleanup_age')
 order by name; 
select '</tbody></table><p>' ;


select '<p><table class="bordered"><caption>Primary Server Statistics</caption>' ;
select '<thead><tr><th scope="col">Client</th><th scope="col">State</th><th scope="col">Sync</th><th scope="col">Current Snapshot</th><th scope="col">Sent loc.</th><th scope="col">Write loc.</th><th scope="col">Flush loc.</th><th scope="col">Replay loc.</th><th scope="col">Backend Start</th><th scope="col">Write lag</th><th scope="col">Flush lag</th><th scope="col">Replay lag</th></tr></thead><tbody>' ;
select '<tr><td>',client_addr, '<td>', state, '<td>', sync_state, '<td>', txid_current_snapshot(),
       '<td>', sent_lsn,      '<td>',write_lsn, '<td>',flush_lsn, '<td>',replay_lsn,
       '<td>', backend_start, '<td>',write_lag, '<td>',flush_lag, '<td>',replay_lag
  from pg_stat_replication;
select '</tbody></table>' ;

select '<p><table class="bordered"><caption>Replication Slots</caption>' ;
select '<thead><tr><th scope="col">Name</th><th scope="col">Type</th><th scope="col">Active</th><th scope="col">XMIN</th><th scope="col">Catalog XMIN</th><th scope="col">Restart LSN</th></tr></thead><tbody>' ;
select '<tr><td>',slot_name, '<td>', slot_type, '<td>', active,
       '<td>', xmin, '<td>', catalog_xmin, '<td>', restart_lsn
  from pg_replication_slots;
select '</tbody></table>' ;


select '<p><table class="bordered"><caption>Secondary Server Statistics</caption>' ;
select '<thead><tr><th scope="col">Last Replication</th><th scope="col">Replication Delay</th><th scope="col">Current Snapshot</th><th scope="col">Receive loc.</th><th scope="col">Replay loc.</th></tr></thead><tbody>' ;
select '<tr><td>', now() - pg_last_xact_replay_timestamp(),
       '<td>', CASE WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() THEN 0
                    ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp()) END,
       '<td>', case when pg_is_in_recovery() then txid_current_snapshot() else null end,
       '<td>', pg_last_wal_receive_lsn(),  
       '<td>', pg_last_wal_replay_lsn();
select '</tbody></table><p>' ;

select '<p><table class="bordered"><caption>WAL Receiver</caption>' ;
select '<thead><tr><th scope="col">PID</th><th scope="col">Status</th><th scope="col">Connection</th><th scope="col">Latest LSN</th><th scope="col">Latest time</th></tr></thead><tbody>' ;
select '<tr><td>',pid, '<td>', status, '<td>', conninfo,
       '<td>', latest_end_lsn, '<td>', latest_end_time
  from pg_stat_wal_receiver;
select '</tbody></table><p>' ;

select '<p><a id="confl"></a><p>' ;
select '<p><table class="bordered"><caption>Secondary Database Conflicts</caption>' ;
select '<thead><tr><th scope="col">Database</th><th scope="col">Conflicts on: tablespace</th><th scope="col">Conflicts on: lock</th><th scope="col">Conflicts on: snapshot</th><th scope="col">Conflicts on: bufferpin</th><th scope="col">Conflicts on: deadlock</th></tr></thead><tbody>' ;
select '<tr><td>'||c.datname, 
	'<td class="align-right">'|| confl_tablespace, 
	'<td class="align-right">'|| confl_lock, 
	'<td class="align-right">'|| confl_snapshot, 
	'<td class="align-right">'|| confl_bufferpin, 
	'<td class="align-right">'|| confl_deadlock
  from pg_stat_database_conflicts c
 where c.datname not like 'template%';
select '</tbody></table><p>' ;


select '<p><table class="bordered"><caption>Logical Replication - Subscriptions</caption>' ;
select '<thead><tr><th scope="col">Subscription Name</th><th scope="col">Pid</th><th scope="col">Relation OID</th><th scope="col">Received</th><th scope="col">Last Message Send</th><th scope="col">Last Message Receipt</th><th scope="col">Latest location</th><th scope="col">Latest time</th></tr></thead><tbody>' ;
select '<tr><td>',subname, '<td>',pid, '<td>',relid, '<td>',received_lsn, '<td>',last_msg_send_time, 	
       '<td>',last_msg_receipt_time, '<td>',latest_end_lsn, '<td>',latest_end_time
  from pg_stat_subscription
 order by subname;
select '</tbody></table><p>' ;

select '<div class="pre-like"><p><table class="bordered"><tr><th>Logical Replication - Details</th></tr></table>' ;

select '<p><table class="bordered"><caption>Publications (Summary)</caption>' ;
select '<thead><tr><th scope="col">Publication Name</th><th scope="col">Owner</th><th scope="col">All tables</th><th scope="col">Insert</th><th scope="col">Update</th><th scope="col">Delete</th></tr></thead><tbody>' ;
select '<tr><td>',pubname, '<td>',rolname,
       '<td>',puballtables, '<td>', pubinsert, '<td>', pubupdate, '<td>', pubdelete 
  from pg_publication p, pg_roles a
 where a.oid=p.pubowner
 order by pubname;
select '</tbody></table><p><table class="bordered"><caption>Publications (Tables)</caption><thead><tr><th scope="col">Publication Name</th><th scope="col">Schema</th><th scope="col">Table</th></tr></thead><tbody>' ;
select '<tr><td>',pubname, '<td>',schemaname, '<td>',tablename
  from pg_publication_tables
 order by pubname, tablename;
select '</tbody></table><p>';

select '<p><table class="bordered"><caption>Subscriptions (Admin View)</caption>' ;

\if :var_as_admin
select '<thead><tr><th scope="col">Subscription Name</th><th scope="col">Database</th><th scope="col">Owner</th><th scope="col">Enabled</th><th scope="col">Sync. Commit</th><th scope="col">Slot</th><th scope="col">Connection</th></tr></thead><tbody>' ;
select '<tr><td>',subname, '<td>',datname, '<td>',rolname,
       '<td>',subenabled, '<td>', subsynccommit, '<td>', subslotname, '<td>', subconninfo
  from pg_subscription s, pg_database d, pg_roles a
 where d.oid=s.subdbid
   and a.oid=s.subowner
 order by subname;
\endif
select '</tbody></table><p>';

select '<p><table class="bordered"><caption>Subscriptions (Details)</caption><thead><tr><th scope="col">Subscription Name</th><th scope="col">Schema</th><th scope="col">Table</th><th scope="col">State</th><th scope="col">LSN</th></tr></thead><tbody>' ;
select '<tr><td>',subname, '<td>', '<td>',relname,
       '<td>',srsubstate, '<td>', srsublsn 
  from pg_subscription_rel r, pg_subscription s, pg_class c
 where s.oid=r.srsubid
   and c.oid=r.srrelid
 order by subname, relname;
select '</tbody></table><p>';
select '</div><hr>';

select '<p><a id="ext"></a>'  ;
select '<p><table class="bordered"><caption>Extensions</caption>' ;
select '<thead><tr><th scope="col">Name</th><th scope="col">Default Version</th><th scope="col">Installed Version</th><th scope="col">Description</th></tr></thead><tbody>' ;
select '<tr><td>',name,'<td>',default_version,'<td>',installed_version,'<td>',comment
from pg_available_extensions
order by case when installed_version is null then 1 else 0 end, name;
select '<tr><td>postgis<td><td><td>PostGIS installed (pre-extensions check)' pg 
from pg_proc 
where proname='postgis_version';
select '</tbody></table><p><hr>' ;

select '<p><a id="nls"></a>'  ;
select '<p><table class="bordered"><caption>NLS Settings</caption>' ;

select '<thead><tr><th scope="col">Parameter</th><th scope="col">Value</th><th scope="col">Description</th></tr></thead><tbody>' ;
select '<tr><td>',name,'<td class="align-right">',setting,
   '<td>',short_desc
from pg_settings
where name like 'lc%'
order by name; 
select '</tbody></table>' ; 

select '<p><table class="bordered"><caption>Database Collations</caption><thead><tr><th scope="col">OID</th><th scope="col">Database</th><th scope="col">Collate</th></tr></thead><tbody>' ;
select '<tr><td>'|| oid, ' <td>'|| datname, 
       ' <td>'|| datcollate
from pg_database;
select '</tbody></table>' ;

select '<p><div class="pre-like"><table class="bordered"><caption>Columns with not default collation</caption>' ;
select '<thead><tr><th scope="col">Schema</th><th scope="col">Table</th><th scope="col">Column</th><th scope="col">Collate</th></tr></thead><tbody>' ;
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
select '</tbody></table></div><p><hr>' ;

select '<p><a id="par"></a>'  ;
select '<p><table class="bordered"><caption>Configured Parameters</caption>' ;
select '<thead><tr><th scope="col">Parameter</th><th scope="col">Value</th><th scope="col">Description</th><th scope="col">Source</th><th scope="col">Setting</th></tr></thead><tbody>' ;
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
select '</tbody></table><p>' ;

select '<p><a id="par_all"></a>'  ;

select '<p><table class="bordered sortable sfont"><caption>PostgreSQL Parameters (all)</caption>' ;
select '<thead><tr><th scope="col">Parameter</th><th scope="col">Value</th><th scope="col">Min</th><th scope="col">Max</th><th scope="col">Description</th><th scope="col">Category</th><th scope="col">Context</th><th scope="col">Unit</th><th scope="col">Source</th><th scope="col">Setting</th></tr></thead><tbody>' ;
select '<tr><td>',name,'<td class="split">',
   replace(replace(
           case when unit='kB'  then pg_size_pretty(setting::bigint*1024)
                when unit='8kB' then pg_size_pretty(setting::bigint*1024*8)
                when unit='B'   then pg_size_pretty(setting::bigint)
                when unit='MB'  then pg_size_pretty(setting::bigint*1024*1024)
                else coalesce(setting||' '||unit,setting) end,
           '<','&lt;'),'>','&gt;'),
   '<td class="align-right">',min_val,'<td class="align-right">',max_val,
   '<td>',short_desc, '<td>',category, '<td>',context,
   '<td>',unit, '<td>',source,
   '<td class="split">',setting
from pg_settings
where name not in ('cloudsql.supported_extensions', 'alloydb.supported_extensions')
order by name; 
select '</tbody></table><p><hr>' ;

\if :var_as_admin
select '<p><a id="pghba"></a>'  ;
select '<p><table class="bordered"><caption>HBA file</caption>' ;
select '<tbody><tr><td><p><div class="pre-like">' ;
select pg_read_file(current_setting('hba_file'),0,10240);
select '</div></td></tr></tbody></table><p>' ;
-- SELECT * from pg_catalog.pg_read_file('pg_hba.conf');
-- WITH f(name) AS (VALUES('pg_hba.conf'))
-- SELECT pg_catalog.pg_read_file(name, 0, (pg_catalog.pg_stat_file(name)).size) FROM f;

select '<p><a id="pgautoconf"></a>'  ;
select '<p><table class="bordered"><caption>Autoconf file</caption>' ;
select '<tbody><tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a
select 'postgresql.conf' as file, * from pg_stat_file(current_setting('config_file'))
 union all
select 'postgresql.auto.conf' as file, * from pg_stat_file(current_setting('data_directory') || '/postgresql.auto.conf');
\pset tuples_only
\a
select pg_read_file(current_setting('data_directory') || '/postgresql.auto.conf',0,10240);
select '</div></td></tr></tbody></table><p><hr>' ;
\endif

select '<p><a id="logs"></a>'  ;
select '<p><table class="bordered"><caption>LOG files (latest 20 files and last messages)</caption>' ;
select '<tbody><tr><td><p><xmp>' ;
\pset tuples_only
\a
select count(*) as LOG_files, pg_size_pretty(sum(size)) as LOG_total_size
  from pg_ls_logdir();
select * from pg_ls_logdir() order by modification desc limit 20;

\if :var_as_admin
select pg_read_file(setting||'/'||dr.name, greatest(-32768, dr.size * -1), 32768) as Log_messages
  from pg_ls_logdir() dr, pg_settings st
 where st.name ='log_directory'
 order by modification desc limit 1;
\endif

\pset tuples_only
\a
select '</xmp></td></tr></tbody></table><p><hr>' ;


select '<p><a id="wal"></a>'  ;
select '<p><table class="bordered"><caption>WAL files (first 5 and latest 20)</caption>' ;
select '<tbody><tr><td><p><div class="pre-like">' ;
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
select '</div></td></tr></tbody></table><p><hr>' ;

select '<p><a id="fdw"></a>'  ;
select '<p><table class="bordered"><tr><th>Foreign Data Wrappers</th></tr>';
select '<tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a

\if :var_as_admin
SELECT w.oid, w.fdwname, a.rolname as owner, ph.proname as handler, pv.proname as validator, fdwacl, fdwoptions
  from pg_foreign_data_wrapper w, pg_authid a, pg_proc ph,  pg_proc pv
 where w.fdwowner = a.oid
   and w.fdwhandler = ph.oid
   and w.fdwvalidator = pv.oid;
SELECT *  from pg_user_mapping;
\endif

SELECT c.relname as foreign_table, fs.srvname, fs.srvtype, fs.srvversion, ft.ftoptions
  FROM pg_foreign_table ft, pg_class c, pg_foreign_server fs
 WHERE ft.ftrelid = c.oid
   AND ft.ftserver = fs.oid;
SELECT *  from pg_foreign_server;

\pset tuples_only
\a
select '</div></table><p><hr>' ;

select '<!-- Report running: '|| now() || ' -->';

/* Extensions, fork, cloud information dynamic statistics */
-- pg_stat_statements is too important to be "optional" extensions

select '<p><a id="opt"></a>'  ;
select '<p><strong>Optional informations</strong><p>'  ;
SELECT
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pg_stat_statements' and installed_version is not null) as pg_stat_statements,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pg_buffercache' and installed_version is not null) as pg_buffercache,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pgstattuple' and installed_version is not null) as pgstattuple,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pg_freespacemap' and installed_version is not null) as pg_freespacemap,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='sslinfo' and installed_version is not null) as sslinfo,
    EXISTS (SELECT 1 FROM pg_stat_ssl WHERE ssl limit 1) as ssl_active,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pgaudit' and installed_version is not null) as pgaudit,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='postgres_fdw' and installed_version is not null) as postgres_fdw,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pgrowlocks' and installed_version is not null) as pgrowlocks,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='postgis' and installed_version is not null) as postgis,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='vector' and installed_version is not null) as pgvector,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='amcheck' and installed_version is not null) as amcheck,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='pgml' and installed_version is not null) as pgml,
    EXISTS (SELECT 1 FROM pg_settings WHERE name='max_prepared_transactions' and setting::int > 0 ) as xa_active,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='anon' and installed_version is not null) as anon,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='hypopg' and installed_version is not null) as hypopg,
    EXISTS (SELECT 1 FROM pg_tables WHERE tablename='pgstatspack_snap' and schemaname='public') as pgstatspack,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='edbspl') as edb,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='rds_tools') as amazon_rds,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='rds_tools' and installed_version is not null) as rds_tools,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='aurora_stat_utils') as aurora,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='aurora_stat_utils' and installed_version is not null) as aurora_stat,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='apg_plan_mgmt' and installed_version is not null) as qpm,
    EXISTS (SELECT 1 FROM pg_settings WHERE name='google_insights.enabled') as cloud_sql,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='google_columnar_engine') as alloydb,
    EXISTS (SELECT 1 FROM pg_settings WHERE name='google_columnar_engine.enabled' and setting='on') as alloy_col,
    EXISTS (SELECT 1 FROM pg_available_extensions WHERE name='yb_pg_metrics') as yugabyte
\gset opt_


\if :opt_pg_buffercache
select '<p><a id="pg_buffercache"></a>'  ;
select '<p><table class="bordered"><tr><th>Buffer cache content detailed information</th></tr>';
select '<tr><td><p><div class="pre-like">' ;
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
select '</div></table><p><hr>' ;
\endif

\if :opt_postgres_fdw
select '<p><a id="postgres_fdw"></a>'  ;
select '<p><table class="bordered"><tr><th>Postgres FDW</th></tr>';
select '<tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a

SELECT * FROM postgres_fdw_get_connections() ORDER BY 1;

\pset tuples_only
\a
select '</div></table><p><hr>' ;
\endif

select '<p><a id="bloat_approx"></a>'  ;
select '<p><table class="bordered"><tr><th>Approximate Bloat KPI </th></tr>';
select '<tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a

-- Very, very raw Bloat Estimate
WITH table_stats AS (
  SELECT
    c.oid,
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_relation_size(c.oid) AS table_size,
    c.reltuples,
    COALESCE(SUM(s.avg_width * (1 - s.null_frac)), 0) AS avg_row_size
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  LEFT JOIN pg_stats s
    ON s.schemaname = n.nspname
   AND s.tablename = c.relname
  WHERE c.relkind = 'r'                 -- solo tabelle
    AND c.reltuples > 0                 -- evita tabelle vuote
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  GROUP BY c.oid, n.nspname, c.relname, c.reltuples
),
bloat_estimate AS (
  SELECT
    SUM(table_size) AS total_size,
    SUM(GREATEST(table_size - (reltuples * avg_row_size), 0)) AS bloat_bytes
  FROM table_stats
)
SELECT
  pg_size_pretty(total_size) AS total_table_size,
  pg_size_pretty(bloat_bytes::numeric) AS approx_bloat_size,
  ROUND(100 * bloat_bytes::numeric / NULLIF(total_size, 0), 2) AS bloat_pct
FROM bloat_estimate;

\pset tuples_only
\a
select '</div></table><p><hr>' ;

\if :opt_pgstattuple
select '<p><a id="pgstattuple"></a>'  ;
select '<p><table class="bordered"><tr><th>Bloat detailed informations for biggest tables (can be time expensive: enable only if needed)</th></tr>';
select '<tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a

\if 0
select n.nspname as schema, relname as table, relpages, (pgstattuple_approx(pg_class.oid::regclass)).*
  from pg_class, pg_roles, pg_catalog.pg_namespace n
 where relowner=pg_roles.oid
   and n.oid=pg_class.relnamespace
   and relkind = 'r'
 order by relpages desc
 limit 20;

select n.nspname as schema, relname as index, relpages, (pgstatindex(pg_class.oid::regclass)).*
  from pg_class, pg_roles, pg_catalog.pg_namespace n
 where relowner=pg_roles.oid
   and n.oid=pg_class.relnamespace
   and relkind = 'i'
 order by relpages desc
 limit 10;

select n.nspname as schema, relname as index, relpages, (pgstatginindex(pg_class.oid::regclass)).*
  from pg_class, pg_roles, pg_catalog.pg_namespace n
 where relowner=pg_roles.oid
   and n.oid=pg_class.relnamespace
   and relkind = 'i'
 order by relpages desc
 limit 10;

select n.nspname as schema, relname as table, relpages, (pgstattuple(pg_class.oid::regclass)).*
  from pg_class, pg_roles, pg_catalog.pg_namespace n
 where relowner=pg_roles.oid
   and n.oid=pg_class.relnamespace
   and relkind = 'r'
 order by relpages desc
 limit 10;
\endif

\pset tuples_only
\a
select '</div></table><p><hr>' ;
\endif


select '<p><a id="histograms"></a>'  ;
select '<p><table class="bordered"><tr><th>Column statistics histograms (can be quite large: enable only on most interesting objects)</th></tr>';
select '<tr><td><p><div class="pre-like">' ;
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
           substr(unnest(coalesce(most_common_vals::text::text[], array['-'])), 1,30) val, 
           unnest(coalesce(most_common_freqs::text::text[], array['0'])) freq, null_frac
      from pg_stats
     where schemaname not in ('pg_catalog', 'information_schema')
       and tablename in ('pgbench_accounts')
     order by 1, 2, 6 desc ) tstat ) t2
 where sample<=10
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
       CASE WHEN 'f' = any(es.stxkind) THEN 'X' END AS "Dependency",
       CASE WHEN 'e' = any(es.stxkind) THEN 'X' END AS "Expression",
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
 where sample<=10
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
select '</div></table><p><hr>' ;


\if :opt_sslinfo
select '<p><a id="sslinfo"></a>'  ;
select '<p><table class="bordered"><tr><th>SSL Informations on current connection</th></tr>';
select '<tr><th>SSL Usage</th>','<th>SSL Version</th>',
       '<th>SSL Cipher</th>',
       '<th>Client Certificate</th>'
as info;
SELECT '<tr><td>', ssl_is_used(), '<td>', ssl_version(), '<td>', ssl_cipher(),  '<td>', ssl_client_cert_present();
select '</table><p><hr>' ;
\endif

\if :opt_ssl_active
select '<p><a id="sslactive"></a>'  ;
select '<p><table class="bordered"><tr><th>SSL Informations on all connections</th></tr>';
select '<tr><td><div class="pre-like">' ;
select * from pg_stat_ssl;
select '</div></table><p><hr>' ;
\endif

select '<p><a id="96_stats"></a>'  ;
select '<p><table class="bordered"><tr><th>Additional PG9.6+ Statistics</th></tr>';
select '<tr><td><div class="pre-like">' ;
\pset tuples_only
\a
select p.pid, p.phase, p.heap_blks_total, p.heap_blks_scanned, p.heap_blks_vacuumed,
       c.relname, a.state, a.wait_event_type, a.wait_event, a.query
  from pg_stat_progress_vacuum p, pg_stat_activity a, pg_class c
 where p.pid=a.pid
   and p.relid=c.oid;

\pset tuples_only
\a
select '</div></table><p>' ;

\if :var_version_12p
select '<p><a id="12_stats"></a>'  ;
select '<p><table class="bordered"><tr><th>Additional PG12+ Statistics</th></tr>';
select '<tr><td><div class="pre-like">' ;
\pset tuples_only
\a
select p.pid, p.phase, p.heap_blks_total, p.heap_blks_scanned,
       c.relname, a.state, a.wait_event_type, a.wait_event, a.query
  from pg_stat_progress_cluster p, pg_stat_activity a, pg_class c
 where p.pid=a.pid
   and p.relid=c.oid;

SELECT name as temporary_filename, size, modification
  FROM pg_ls_tmpdir()
 ORDER BY modification DESC;

select *
  from pg_stats_ext;

SELECT *
  from pg_stat_gssapi;

\pset tuples_only
\a
select '</div></table><p>' ;
\endif

\if :var_version_13p
select '<p><a id="13_stats"></a>'  ;
select '<p><table class="bordered"><tr><th>Additional PG13+ Statistics</th></tr>';
select '<tr><td><div class="pre-like">' ;
\pset tuples_only
\a
SELECT *
  from pg_stat_slru;

\if :var_as_admin
select replace(replace(name, '<', '-'), '>', '-') as name, off, size, allocated_size
  from pg_shmem_allocations
 order by allocated_size desc;
\endif

\pset tuples_only
\a
select '</div></table><p>' ;
\endif

\if :var_version_14p
select '<p><a id="14_stats"></a>'  ;
select '<p><table class="bordered"><tr><th>Additional PG14+ Statistics</th></tr>';
select '<tr><td><div class="pre-like">' ;
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

\if :var_as_admin
SELECT *
  from pg_backend_memory_contexts
 ORDER BY used_bytes DESC LIMIT 10;
\endif

SELECT *
  from pg_stat_replication_slots;

SELECT *
  from pg_stat_statements_info;

SELECT *
  from pg_stat_database;

SELECT *
  from pg_stats_ext_exprs;

\pset tuples_only
\a
select '</div></table><p>' ;
\endif


\if :var_version_15p
select '<p><a id="15_stats"></a>'  ;
select '<p><table class="bordered"><tr><th>Additional PG15+ Statistics</th></tr>';
select '<tr><td><div class="pre-like">' ;
\pset tuples_only
\a
select *
  from pg_parameter_acl;

--  pg_publication_namespace
\pset tuples_only
\a
select '</div></table><p>' ;
\endif


\if :var_version_16p
select '<p><a id="16_stats"></a>'  ;
select '<p><table class="bordered"><tr><th>Additional PG16+ Statistics</th></tr>';
select '<tr><td><div class="pre-like">' ;
\pset tuples_only
\a
select backend_type, io_object, io_context, reads, writes, extends,
       op_bytes, evictions, reuses, fsyncs
  from pg_stat_io;
\pset tuples_only
\a
select '</div></table><p>' ;
\endif


\if :var_version_17p
select '<p><a id="17_stats"></a>'  ;
select '<p><table class="bordered"><tr><th>Additional PG17+ Statistics</th></tr>';
select '<tr><td><div class="pre-like">' ;
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
select '<tr><td class="align-right">'||buffers_clean as buffer_clean,
       '<td class="align-right">'||maxwritten_clean as maxwritten_clean, 
       '<td class="align-right">'||buffers_alloc as buffer_alloc, 
       '<td>'|| stats_reset as stats_reset
 from pg_stat_bgwriter;
select '<tr><td class="align-right">'||num_timed as num_timed, 
       '<td class="align-right">'|| num_requested as num_requested, 
       '<td class="align-right">'|| buffers_written as buffers_written, 
       '<td class="align-right">'|| round(write_time/1000) as write_time,
       '<td class="align-right">'|| round(sync_time/1000) as sync_time,
       '<td>'|| stats_reset as stats_reset
 from pg_stat_checkpointer;
select '</table>';

\pset tuples_only
\a
select '</div></table><p>' ;
\endif


\if :var_version_18p
select '<p><a id="18_stats"></a>'  ;
select '<p><table class="bordered"><tr><th>Additional PG18+ Statistics</th></tr>';
select '<tr><td><div class="pre-like">' ;
\pset tuples_only
\a

select * from pg_aios;
select * from pg_ls_summariesdir();
select * pg_get_loaded_modules();
-- select * from pg_shmem_allocations_numa;

\pset tuples_only
\a
select '</div></table><p>' ;
\endif


select '<hr>';

select '<p><a id="fullt"></a>'  ;
select '<p><table class="bordered"><tr><th>Full Text Search</th></tr>';
select '<tr><td><div class="pre-like">' ;
\pset tuples_only
\a

SELECT name, installed_version
  FROM pg_available_extensions
 WHERE name='pg_trgm' and installed_version is not null;

SELECT pg_get_indexdef(indexrelid) from pg_index
 WHERE pg_get_indexdef(indexrelid) ~* 'USING (gin |gist )';

SELECT table_schema||'.'||table_name as table, column_name, data_type
 FROM information_schema.columns
 WHERE data_type='tsvector';

-- SELECT * FROM pgstatginindex('bench.pgbench_accounts_idx_gin_filler');
-- SELECT * FROM pgstatindex('bench.pgbench_accounts_idx_gist_filler');

\pset tuples_only
\a
select '</div></table><p>' ;

\if :opt_xa_active
select '<p><a id="xa"></a>'  ;
select '<p><table class="bordered"><tr><th>Pending transactions</th></tr>';
select '<tr><td><div class="pre-like">' ;
\pset tuples_only
\a
select gid, prepared, owner, database, transaction AS xmin, now()-prepared AS age
  from pg_prepared_xacts
 order by age(transaction) desc;
\pset tuples_only
\a
select '</div></table><p>' ;
\endif


\if :opt_postgis
select '<p><a id="postgis"></a>'  ;
select '<p><table class="bordered"><tr><th>Postgis Statistics </th></tr>';
select '<tr><td><p><div class="pre-like">' ;
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
select '</div></table><p>' ;
\endif


\if :opt_pgvector
select '<p><a id="pgvector"></a>'  ;
select '<p><table class="bordered"><tr><th>pgvector Statistics</th></tr>';
select '<tr><td><p><div class="pre-like">' ;
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
select '</div></table><p>' ;
\endif


\if :opt_anon
select '<p><a id="anon"></a>'  ;
select '<p><table class="bordered"><tr><th>Anonymizer Extension </th></tr>';
select '<tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a

SELECT name as "Extension", installed_version 
  FROM pg_available_extensions WHERE name like 'anon%'
 ORDER BY name;

select * from pg_seclabels;

\pset tuples_only
\a
select '</div></table><p>' ;
\endif

\if :opt_hypopg
select '<p><a id="hypopg"></a>'  ;
select '<p><table class="bordered"><tr><th>HypoPG</th></tr>';
select '<tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a

SELECT name as "Extension", installed_version 
  FROM pg_available_extensions WHERE name like 'hypopg'
 ORDER BY name;

select *
  from hypopg_list_indexes;

\pset tuples_only
\a
select '</div></table><p>' ;
\endif


\if :opt_pgstatspack
select '<p><a id="pgstatspack"></a>'  ;
select '<p><table class="bordered"><tr><th>pgstatspack Info </th></tr>';
select '<tr><td><p><div class="pre-like">' ;
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
select '</div></table><p>' ;
\endif


\if :opt_amcheck
select '<p><a id="anon"></a>'  ;
select '<p><table class="bordered"><tr><th>amcheck</th> (customize if needed)</td></tr>';
select '<tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a
SELECT bt_index_check(index => c.oid, heapallindexed => i.indisunique),
       n.nspname, c.relname, c.relpages
  FROM pg_index i
  JOIN pg_opclass op ON i.indclass[0] = op.oid
  JOIN pg_am am ON op.opcmethod = am.oid
  JOIN pg_class c ON i.indexrelid = c.oid
  JOIN pg_namespace n ON c.relnamespace = n.oid
 WHERE am.amname = 'btree'
   AND c.relpersistence != 't'
   AND c.relkind = 'i'
   AND i.indisready
   AND i.indisvalid
   AND n.nspname = 'pg_catalog'
   AND c.relname not in('')
ORDER BY c.relpages DESC LIMIT 10;
\pset tuples_only
\a
select '</div></table><p>' ;
\endif


select '<a id="fork"></a>';

\if :opt_edb
select '<p><a id="EDB"></a>'  ;
select '<p><table class="bordered"><tr><th>Additional EnterpriseDB Advanced Server Statistics </th></tr>';
select '<tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a

select *
  from product_component_version;

\if :var_version_14p
select *
  from all_objects
 where schema_name not in ('SYS')
 order by last_ddl_time desc
 limit 100;
-- On complex databases (eg. overpartitioned) can raise ERROR:  53200: out of shared memory

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

select r.rdname, n.nspname||'.'||c.relname as relname, r.rdenable, pg_get_expr(r.rdexpr, r.rdrelid) as rd_condition
  from edb_redaction_policy r, pg_class c, pg_namespace n
 where r.rdrelid=c.oid
   and c.relnamespace=n.oid
 order by r.rdname, n.nspname, c.relname; 

select r.rdname, n.nspname||'.'||c.relname as relname, aa.attname, rdscope, rdexception,
       pg_get_expr(a.rdfuncexpr, a.rdrelid) as rd_function
  from edb_redaction_policy r, pg_class c, edb_redaction_column a, pg_attribute aa, pg_namespace n
 where r.rdrelid=c.oid
   and c.relnamespace=n.oid
   and a.rdpolicyid=r.oid
   and r.rdrelid=aa.attrelid
   and a.rdattnum=aa.attnum
 order by r.rdname, n.nspname, c.relname; 

\pset tuples_only
\a
select '</div></table><p><hr>' ;
\endif


\if :opt_amazon_rds
select '<p><a id="rds"></a>'  ;
select '<p><table class="bordered"><tr><th>Amazon RDS</th></tr>';
select '<tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a

\if :opt_rds_tools
select *
  from rds_tools.role_password_encryption_type();
\endif

\pset tuples_only
\a
select '</div></table><p><hr>' ;
\endif


\if :opt_aurora
select '<p><a id="aurora"></a>'  ;
select '<p><table class="bordered"><tr><th>Additional Aurora Postgres-compatible Statistics </th></tr>';
select '<tr><td><p><div class="pre-like">' ;
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
select '</div></table><p><hr>' ;
\endif


\if :opt_cloud_sql
select '<p><a id="cloudsql"></a>'  ;
select '<p><table class="bordered"><tr><th>Cloud SQL</th></tr>';
select '<tr><td><p><div class="pre-like">' ;
\pset tuples_only
\a

select name as gcp_parameter_name, setting,
       context, source, short_desc
  from pg_settings
 where (name like 'google%' or name like 'enable_google%' or name like 'cloudsql%')
   and name not in ('cloudsql.supported_extensions')
   and name not like ('google_columnar_engine%')
 order by name;

\if :opt_alloydb
select '<strong>AlloyDB</strong>' as Engine;
select name as alloydb_parameter_name, setting,
       context, source, short_desc
  from pg_settings
 where (name like 'alloydb%' or name like 'google_columnar_engine%')
   and name not in ('alloydb.supported_extensions')
 order by name;

select datid, datname, blks_read, blks_hit,
       blk_read_time, blk_write_time,      
       round((blks_hit)*100.0/nullif(blks_read+blks_hit, 0),2) hit_ratio_1st_level,
       blk_read_time*1.0/nullif(blks_read, 0) avg_read
  from pg_stat_database
 where datname not like 'template%';

select dbid, queryid, calls, total_exec_time, blk_read_time, blk_write_time,
       substring(regexp_replace(query, E'[\\n\\r]+', ' ', 'g' ), 1, 140) top_read_IO_query
  from pg_stat_statements
-- WHERE dbid in (SELECT oid from pg_database where current_database() = 'postgres' or datname=current_database())
 order by blk_read_time desc limit 10;
select dbid, queryid, calls, total_exec_time, blk_read_time, blk_write_time,
       substring(regexp_replace(query, E'[\\n\\r]+', ' ', 'g' ), 1, 140) top_write_IO_query
  from pg_stat_statements
-- WHERE dbid in (SELECT oid from pg_database where current_database() = 'postgres' or datname=current_database())
 order by blk_write_time desc limit 10;


select *
  from google_db_advisor_workload_report;
select *
 from google_db_advisor_recommend_indexes();

\if :opt_alloy_col
SELECT *
  FROM g_columnar_schedules;
SELECT database_name, schema_name, relation_name, column_name
  FROM g_columnar_recommended_columns;

SELECT google_columnar_engine_memory_available();
SELECT memory_name, pg_size_pretty(memory_total) as memory_total,
        pg_size_pretty(memory_available) as memory_available,
        memory_available_percentage
  FROM g_columnar_memory_usage;
SELECT * FROM google_columnar_engine_recommend(mode => 'RECOMMEND_SIZE');

SELECT database_name, schema_name, relation_name, status, size, pg_size_pretty(size) as size_hr,
       invalid_block_count, total_block_count
  FROM g_columnar_relations;

SELECT database_name, schema_name, relation_name, column_name, size_in_bytes, last_accessed_time
  FROM g_columnar_columns;

SELECT *
  FROM pg_stat_statements(TRUE) AS pg_stats
  FULL JOIN g_columnar_stat_statements AS g_stats
       ON pg_stats.userid = g_stats.user_id AND
          pg_stats.dbid = g_stats.db_id AND
          pg_stats.queryid = g_stats.query_id
 WHERE columnar_unit_read > 0;
\endif
\endif

\pset tuples_only
\a
select '</div></table><p><hr>' ;
\endif


\if :opt_pgaudit
select '<p><a id="pgaudit"></a>';
select '<p><table class="bordered"><tr><th>PGAudit logged Objects</th></tr>' ;
select '<tr><th>Schema</th>', '<th>Table</th>', '<th>Privilege</th>';
SELECT '<tr><td>',table_schema, '<td>',table_name, '<td>',privilege_type 
  FROM information_schema.role_table_grants 
 WHERE grantee in ('rds_pgaudit', 'auditor', 'pgaudit')
 ORDER BY table_schema, table_name;
\endif


select '<div><a href="#top" class="back-to-top">⬆ Back to index</a></div>' as info;
select '<p><hr>' ;

select '<p>Statistics generated on: '|| current_date || ' ' ||localtime ;
select '<br>More info on' ;
select '<a href="https://www.meo.bogliolo.name#post">this site</a>' ;
select '<br> Copyright: 2025 meob - License: GNU General Public License v3.0' ;
select '<br> Sources: https://github.com/meob/db2html/ <p>' ;
select '<script src="util.js"></script>' ;

select '</body></html>' ;
\pset tuples_only
\a
\o

