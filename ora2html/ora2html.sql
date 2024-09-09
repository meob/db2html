REM Programma:	ora2html.sql
REM 		Oracle configuration HTML report
REM Autore:	Bartolomeo Bogliolo mail@meo.bogliolo.name meo
REM               http://meoshome.it.eu.org/
REM Data:	1-APR-98
REM Versione:	1.0.35d 2024-08-15
REM Note:	
REM      	1-APR-98 mail@meo.bogliolo.name
REM		 Versione HTML iniziale basata su gen.sql, passaggio alla lingua inglese
REM 		1-MAY-98 mail@meo.bogliolo.name
REM		 Better formatting, totals on TBS
REM		 Invalid objects and tuning paramters
REM		 Fragmented objs
REM		 IAS Schemas Versions, 10g compatibility
REM		 JOBS and DB Links
REM		 no IAS, more performance and status infos
REM		 tabled menu contents, 1.0.18c: faster lock select, 1.0.19 log switching
REM		 1.0.20 more summary info, 1.0.21 Partitioning, (b) Custom statistics, (c) Spatial
REM		 1.0.22 OS Infos (10g, 11g only), minor changes
REM 		30-JUN-11 mail@meo.bogliolo.name
REM		 1.0.23 Rule hint on dba_jobs_running (to avoid a performance bug in 9.2)
REM 		1-JAN-12 mail@meo.bogliolo.name
REM		 1.0.24 A bit more info on partitioning
REM 		1-MAY-12 mail@meo.bogliolo.name
REM		 1.0.25 More default password checks
REM 		1-AUG-12 mail@meo.bogliolo.name
REM		 1.0.26 Recycle Bin space usage
REM 		1-OCT-12 mail@meo.bogliolo.name
REM		 1.0.27 More RAC info, more custom plugins (a,b) bug fixing
REM 		24-MAY-13 mail@meo.bogliolo.name
REM		 1.0.28 More licensing info: feature_info details on DBA_FEATURE_USAGE_STATISTICS
REM		 1.0.29 DBcpu (a) segment_type, per schema size (b) OPEN user count
REM                    (c) Partitions compression (d) SQLcl checked
REM 		14-FEB-17 mail@meo.bogliolo.name
REM		 1.0.30 New CSS, new plugins (Oracle 12c, RMAN, ...)  (a) SGA parameters (b) Users' expiry date
REM 		1-AUG-19 mail@meo.bogliolo.name
REM		 1.0.31 RU and RUP updated
REM 		14-JAN-20 mail@meo.bogliolo.name
REM		 1.0.32 RU and RUP updated
REM 		31-OCT-20 mail@meo.bogliolo.name
REM		 1.0.33 RU and RUP updated
REM 		1-APR-21 mail@meo.bogliolo.name 
REM		 1.0.34 RU and RUP updated (b) Halloween release update (c) 1 April 2022 release update (d) Enabled jobs (e) Last RUs
REM 		1-AUG-22 mail@meo.bogliolo.name 
REM		 1.0.35 RU and RUP updated, CS in Summary  (a) List all parameters (b) data types (c,d) version updates


create view v_tab_occ as
 select tablespace_name,sum(bytes) bytes, max(extent_id)+1 max_extent
 from sys.dba_extents
 group by tablespace_name;
create view v_tab_free
 as select tablespace_name,max(bytes) bytes
 from sys.dba_free_space
 group by tablespace_name;
create table v_big_obj
 as select segment_name, segment_type,
    tablespace_name, owner, sum(bytes) bytes
 from sys.dba_extents
 group by segment_name, segment_type, tablespace_name, owner
 order by bytes desc;
create table v_frg_obj
 as select segment_name, segment_type,
    tablespace_name, owner, count(*) extents, sum(bytes) bytes
 from sys.dba_extents
 group by segment_name, segment_type, tablespace_name, owner
 order by extents desc;
create table v_log_sd
 as select count(*)/7 log_sd
 from sys.v_$log_history
 where first_time > sysdate-7;

set colsep ' '
set pagesize 9999
set linesize 130
set heading off
set feedback off
set timing off
set define off
set sqlprompt ''
ttitle off
spool ora2html.htm

select '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8" /><link rel="stylesheet" href="ux3.css" /> <title>', value,
  ' - ora2html Oracle Statistics</title> </head>'||
 '<body>'
from v$parameter
where name like 'db_name';

select '<P><a id="top"></A>' from dual;
select '<h1 align=center>'||substr(value,1,25)||'</h1>'
from v$parameter
where name ='db_name';

select '<table><tr><td><ul>' from dual;
select '<li><A HREF="#status">Summary Status</A></li>' from dual;
select '<li><A HREF="#ver">Versions</A></li>' from dual;
select '<li><A HREF="#tbs">Tablespaces</A></li>' from dual;
select '<li><A HREF="#obj">Schema/Object Matrix</A></li>' from dual;
select '<li><A HREF="#inv">Invalid Objects</A></li>' from dual;
select '<li><A HREF="#usg">Space Usage</A></li>' from dual;
select '<li><A HREF="#part">Partitioning</A></li>' from dual;
select '<li><A HREF="#spatial">Spatial</A></li>' from dual;
select '<li><A HREF="#sga">SGA</A></li>' from dual;
select '<li><A HREF="#dat">Datafiles</A></li>' from dual;
select '<li><A HREF="#roll">Rollbacks</A></li>' from dual;
select '<li><A HREF="#log">Log Files</A></li>' from dual;
select '<li><A HREF="#usr">Users</A></li>' from dual;
select '<li><A HREF="#lic">Licensing</A></li>' from dual;
select '</ul><td><ul>' from dual;
select '<li><A HREF="#sess">Sessions</A></li>' from dual;
select '<li><A HREF="#sql">Running SQL</A></li>' from dual;
select '<li><A HREF="#lock">Locks</A></li>' from dual;
select '<li><A HREF="#stat">Performance Statistics</A></li>' from dual;
select '<li><A HREF="#big">Biggest Objects</A></li>' from dual;
select '<li><A HREF="#frag">Most Fragmented Objects</A></li>' from dual;
select '<li><A HREF="#psq">PL/SQL</A></li>' from dual;
select '<li><A HREF="#job">Scheduled Jobs</A></li>' from dual;
select '<li><A HREF="#rman">RMAN</A></li>' from dual;
select '<li><A HREF="#dbl">Remote Database links</A></li>' from dual;
select '<li><A HREF="#par">Tuning Parameters</A></li>' from dual;
select '<li><A HREF="#nls">NLS Settings</A></li>' from dual;
select '<li><A HREF="#os">Operating System Infos</A></li>' from dual;
select '<li><A HREF="#custMenu">Plugins</A> (<A HREF="#custO">DB Options</a>, <A HREF="#custP">Performance</a>, <A HREF="#custC">Custom</a>, ...)</li>' from dual;
select '</ul></table><p><hr>' from dual;
 
select '<P>Statistics generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
from dual;
 
select 'by: '||user
from dual;

select 'using: <I><b>ora2html.sql</b> v.1.0.35d'
from dual;
select '<br>Software by ' from dual;
select '<A HREF="http://meoshome.it.eu.org/">Meo Bogliolo</A></I><p>'
from dual;
 
select '<hr><P><a id="status"></A>' "Status" from dual;
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>'
 from dual;
select '<tr><td><b>Item</b>',
 '<td><b>Value</b>'
from dual;

select '<tr><td>'||' Database :', '<! 10>',
 '<td>'||value
from v$parameter
where name like 'db_name'
union
select '<tr><td>'||' Version :', '<! 12>',
 '<td>'||substr(banner,instr(banner, '.',1,1)-2,11)
from sys.v_$version
where banner like 'Oracle%'
union
select '<tr><td>'||' Created :', '<! 15>',
 '<td >'|| to_char(created,'DD-MON-YYYY HH24:MI:SS')
from v$database
union
select '<tr><td>'||' Started :', '<! 16>',
 '<td>'|| to_char(startup_time,'DD-MON-YYYY HH24:MI:SS')
from v$instance
union
select '<tr><td>'||' DB Size (MB) :', '<! 20>',
 '<td align="right">'||to_char(sum(bytes)/(1024*1024),'999,999,999,999')
from sys.dba_data_files
union
select '<tr><td>'||' SGA (MB) :', '<! 24>',
 '<td align="right">'||to_char(sum(value)/(1024*1024),'999,999,999,999')
from sys.v_$sga
union
select '<tr><td>'||' Log archiving :', '<! 26>',
 '<td>'||log_mode
from v$database
union
select '<tr><td>'||' Defined Users / OPEN:', '<! 30>',
 '<td align="right">'||to_char(count(*),'999999999999')
 ||' / '|| to_char(sum(decode(account_status,'OPEN',1,0)),'999999999999')
from sys.dba_users
union
select '<tr><td>'||' Defined Schemata :', '<! 32>',
 '<td align="right">'||to_char(count(distinct owner),'999999999')
from dba_objects
where owner not in ('SYS', 'SYSTEM')
and object_type = 'TABLE'
union
select '<tr><td>'||' Defined Tables :', '<! 34>',
 '<td align="right">'||to_char(count(*),'999999999999')
from dba_objects
where owner not in ('SYS', 'SYSTEM')
and object_type = 'TABLE'
union
select '<tr><td>'||' Used Space (MB) :', '<! 22>',
 '<td align="right">'||to_char(sum(bytes)/(1024*1024),'999,999,999,999')
from sys.dba_extents
union
select '<tr><td>'||' Sessions / USER / ACTIVE:', '<! 40>',
 '<td align="right">'||to_char(count(*),'999999999999')
from gv$session
order by 2;
select ' / '|| to_char(count(*),'999999999999')
from gv$session
where type='USER';
select ' / '|| to_char(count(*),'999999999999')
from gv$session
where status='ACTIVE'
and type='USER';

select '<tr><td>'||' Character set :', '<! 49>',
 '<td>'|| value$
from sys.props$
where name = 'NLS_CHARACTERSET';

select '<tr><td>'||' Hostname :', '<! 50>',
 '<td>'|| host_name
from gv$instance
union
select '<tr><td>'||' Instance :', '<! 55>',
 '<td>'||instance_name
from gv$instance;

select '<tr><td>'||' Archiver :', '<! 60>',
 '<td>'|| archiver
from v$instance;

select '<tr><td>'||' RedoLog Writes Day (MB) :', '<! 65>',
 '<td align="right">'||to_char(avg(bytes)*log_sd/(1024*1024),'999999999999')
from v_log_sd, sys.v_$log
group by log_sd;
select '</table><p><hr>' from dual;

select '<P><A NAME="ver"></A>' from dual;
select '<P><table border="2"><tr><td><b>Version check</b></td></tr>' from dual;
select '<tr><td><b>Version</b>',
 '<td><b> Supported Release</b>',
 '<td><b> Last releases</b>',
 '<td><b> Notes</b>' from dual;
select '<tr><td>', banner from v$version where banner like 'Oracle%';
REM supported
select ' <td>', decode(substr(banner,instr(banner, '.',1,1)-2, instr(banner, '.',1,2)-instr(banner, '.',1,1)+2),
                       '12.2', 'NO', '18.0', 'NO', '19.0', 'YES', '21.0', 'NO', '23.0', 'YES',
                               'NO')
  from v$version where banner like 'Oracle%'; 
REM last releases (n, n-1)
select ' <td>', decode(substr(banner,instr(banner, '.',1,1)-2, instr(banner, '.',1,2)-instr(banner, '.',1,1)+2),
                       '12.2', 'NO', '18.0', 'NO', '19.0', 'YES', '21.0', 'NO', '23.0', 'YES',
                               'NO')
  from v$version where banner like 'Oracle%'; 
select ' <td>Last Release Updates (12.2+): <b>23.4</b>, 21.15, <b>19.24</b>; 20.2, 18.14, 12.2.0.1.220118' from dual;
select ' <br>Last Patch Set Updates (12.1-): 12.1.0.2.221018, 11.2.0.4.201020, 10.2.0.5.19; 9.2.0.8, 8.1.7.4, 7.3.4.5' from dual;
select '</table><p>' from dual;
select '<P><table border="2"><tr><td><b>Versions</b></td></tr>' from dual;
select '<tr><td>'||banner||' </tr></td>' version from sys.v_$version;
select '</table><p>' from dual;
select '<P><table border="2"><tr><td><b>Component</b><td><b>Description</b>',
 '<td><b>Version</b>' from dual;
select '<tr><td>'||comp_id comp,
 '<td>'||comp_name des,
 '<td>'||version ver
  from dba_registry
  order by 1;
select '</table><p><hr>' from dual;


select '<P><a id="tbs"></A>' from dual;
select '<P><table border="2"><tr><td><b>Tablespaces</b></td></tr>' from dual;
select '<tr><td><b>Tablespace</b>',
 '<td><b>Total</b>',
 '<td><b>Occuped</b>',
 '<td><b>PCT</b>',
 '<td><b>Max_free</b>',
 '<td><b>Max_extent</b>'
from dual;
select '<tr><td>'|| a.tablespace_name tablespace,
 '<td align="right">'||to_char(sum(a.bytes),'999,999,999,999,999') total,
 '<td align="right">'||to_char(nvl(b.bytes,0),'999,999,999,999,999') occuped,
 '<td align="right">'||nvl(substr(to_char(trunc(b.bytes/sum(a.bytes)*100)),1,3),'0')||'%' pct,
 '<td align="right">'||to_char(nvl(c.bytes,0),'999,999,999,999,999') max_free,
 '<td align="right">'||to_char(nvl(b.max_extent,0),'999,999') max_extent
from sys.dba_data_files a,
     v_tab_occ b,
     v_tab_free c
where a.tablespace_name = b.tablespace_name (+)
and   a.tablespace_name = c.tablespace_name (+)
group by a.tablespace_name,b.bytes,c.bytes,b.max_extent
order by a.tablespace_name;
select '<tr><td>TOTAL' tablespace,
 '<td align="right">'||to_char(round(sum(a.bytes)/(1024*1024)),'999,999,999,999')||' MB' total
from sys.dba_data_files a;
select
 '<td align="right">'||to_char(round(sum(b.bytes)/(1024*1024)),'999,999,999,999')||' MB' total,
 '<td align="right"> -' pct,
 '<td align="right"> -' max_free,
 '<td align="right"> -' max_extent
from v_tab_occ b;
select '</table>' from dual;

select '<P><a id="segs"></A>' from dual;
select '<P><table border="2"><tr><td><b>Segments</b></td></tr>' from dual;
select '<tr><td><b>Segment Type',
 '<td><b>Used Space</b>'
from dual;
select '<tr><td>'|| segment_type,
 '<td align="right">'||to_char(sum(bytes),'999,999,999,999,999') total
from sys.dba_segments
group by segment_type
order by 2 desc;
select '<tr><td>TOTAL',
 '<td align="right">'||to_char(round(sum(bytes)/(1024*1024)),'999,999,999,999,999')||' MB' total
from sys.dba_segments;
select '</table><p><hr>' from dual;

set numwidth  5
select '<P><a id="obj"></A>' from dual;
select '<P><table border="2"><tr><td><b>Schema/Object Matrix</b></td></tr>' from dual;
select '<tr><td><b>Owner</b>',
 '<td><b> Tabs</b>',
 '<td><b> Prts</b>',
 '<td><b> Idxs</b>',
 '<td><b> Trgs</b>',
 '<td><b> Pkgs</b>',
 '<td><b> Body</b>',
 '<td><b> Proc</b>',
 '<td><b> Func</b>',
 '<td><b> Seqs</b>',
 '<td><b> Syns</b>',
 '<td><b> Views</b>',
 '<td><b> MVws</b>',
 '<td><b> Jobs</b>',
 '<td><b> Type</b>',
 '<td><b> Oper</b>',
 '<td><b> LOB</b>',
 '<td><b> XML</b>',
 '<td><b> Total</b>'
from dual;
select '<tr><td>'||owner owner,
 '<td align="right">'||sum(decode(object_type, 'TABLE',1,0))    tabs,
 '<td align="right">'||sum(decode(object_type, 'TABLE PARTITION',1,0))    patrs,
 '<td align="right">'||sum(decode(object_type, 'INDEX',1,0))    idxs,
 '<td align="right">'||sum(decode(object_type, 'TRIGGER',1,0))  trgs,
 '<td align="right">'||sum(decode(object_type, 'PACKAGE',1,0))  pkgs,
 '<td align="right">'||sum(decode(object_type, 'PACKAGE BODY',1,0))  pbod,
 '<td align="right">'||sum(decode(object_type, 'PROCEDURE',1,0))  proc,
 '<td align="right">'||sum(decode(object_type, 'FUNCTION',1,0))  func,
 '<td align="right">'||sum(decode(object_type, 'SEQUENCE',1,0)) seqs,
 '<td align="right">'||sum(decode(object_type, 'SYNONYM',1,0))  syns,
 '<td align="right">'||sum(decode(object_type, 'VIEW',1,0))  viws,
 '<td align="right">'||sum(decode(object_type, 'MATERIALIZED VIEW',1,0))  mvs,
 '<td align="right">'||sum(decode(object_type, 'JOB',1,0))  jbs,
 '<td align="right">'||sum(decode(object_type, 'TYPE',1,0))  typ,
 '<td align="right">'||sum(decode(object_type, 'OPERATOR',1,0))  oper,
 '<td align="right">'||sum(decode(object_type, 'LOB',1,0))  lobb,
 '<td align="right">'||sum(decode(object_type, 'XML SCHEMA',1,0))  xml,
 '<td align="right">'||count(*) alls
from sys.dba_objects
group by owner
order by owner;
select '<tr><td>TOTAL' total,
 '<td align="right">'||sum(decode(object_type, 'TABLE',1,0))    tabs,
 '<td align="right">'||sum(decode(object_type, 'TABLE PARTITION',1,0))    patrs,
 '<td align="right">'||sum(decode(object_type, 'INDEX',1,0))    idxs,
 '<td align="right">'||sum(decode(object_type, 'TRIGGER',1,0))  trgs,
 '<td align="right">'||sum(decode(object_type, 'PACKAGE',1,0))  pkgs,
 '<td align="right">'||sum(decode(object_type, 'PACKAGE BODY',1,0))  pbod,
 '<td align="right">'||sum(decode(object_type, 'PROCEDURE',1,0))  proc,
 '<td align="right">'||sum(decode(object_type, 'FUNCTION',1,0))  func,
 '<td align="right">'||sum(decode(object_type, 'SEQUENCE',1,0)) seqs,
 '<td align="right">'||sum(decode(object_type, 'SYNONYM',1,0))  syns,
 '<td align="right">'||sum(decode(object_type, 'VIEW',1,0))  viws,
 '<td align="right">'||sum(decode(object_type, 'MATERIALIZED VIEW',1,0))  mvs,
 '<td align="right">'||sum(decode(object_type, 'JOB',1,0))  jbs,
 '<td align="right">'||sum(decode(object_type, 'TYPE',1,0))  typ,
 '<td align="right">'||sum(decode(object_type, 'OPERATOR',1,0))  oper,
 '<td align="right">'||sum(decode(object_type, 'LOB',1,0))  lobb,
 '<td align="right">'||sum(decode(object_type, 'XML SCHEMA',1,0))  xml,
 '<td align="right">'||count(*) alls
from sys.dba_objects;
select '</table><p>' from dual;

select '<P><a id="schema_size"></A>' from dual;
select '<P><table border="2"><tr><td><b>Schema/Segments Size</b></td></tr>' from dual;
select '<tr><td><b>Owner</b>',
 '<td><b> Tables</b>',
 '<td><b> Indexes</b>',
 '<td><b> Total Size</b>'
from dual;
select '<tr><td>'||owner owner,
 '<td align="right">'||to_char(sum(decode(segment_type, 'TABLE',bytes,0)),'999,999,999,999,999')    tabs,
 '<td align="right">'||to_char(sum(decode(segment_type, 'INDEX', bytes,0)),'999,999,999,999,999')    idxs,
 '<td align="right">'||to_char(sum(bytes),'999,999,999,999,999') tot
from sys.dba_segments
group by owner
order by owner;
select '<tr><td>TOTAL' total,
 '<td align="right">'||to_char(sum(decode(segment_type, 'TABLE',bytes,0)),'999,999,999,999,999')    tabs,
 '<td align="right">'||to_char(sum(decode(segment_type, 'INDEX', bytes,0)),'999,999,999,999,999')    idxs,
 '<td align="right">'||to_char(sum(bytes),'999,999,999,999,999') tot
from sys.dba_segments;
select '</table><p><a href="#top">Top</a><hr>' from dual;

select '<P><a id="inv"></A>' "Invalid Objects" from dual;
select '<P><table border="2"><tr><td><b>Invalid Objects</b></td></tr>' 
from dual;
select '<tr><td><b>Owner</b>',
 '<td><b>Table</b>',
 '<td><b>Index</b>',
 '<td><b>Trigger</b>',
 '<td><b>Package</b>',
 '<td><b>P. Body</b>',
 '<td><b>Proc.</b>',
 '<td><b>Func.</b>',
 '<td><b>Sequence</b>',
 '<td><b>Synonym</b>',
 '<td><b>View</b>',
 '<td><b>Total</b>'
from dual;
select 
 '<tr><td>'||owner
 ||'<td>'||sum(decode(object_type, 'TABLE',1,0))   
 ||'<td>'||sum(decode(object_type, 'INDEX',1,0))   
 ||'<td>'||sum(decode(object_type, 'TRIGGER',1,0))
 ||'<td>'||sum(decode(object_type, 'PACKAGE',1,0))
 ||'<td>'||sum(decode(object_type, 'PACKAGE BODY',1,0))
 ||'<td>'||sum(decode(object_type, 'PROCEDURE',1,0))
 ||'<td>'||sum(decode(object_type, 'FUNCTION',1,0))
 ||'<td>'||sum(decode(object_type, 'SEQUENCE',1,0))
 ||'<td>'||sum(decode(object_type, 'SYNONYM',1,0))
 ||'<td>'||sum(decode(object_type, 'VIEW',1,0))  
 ||'<td>'||count(*)
from sys.dba_objects
where status <> 'VALID'
group by owner
order by owner;
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Invalid Indexes</b></td></tr>' from dual;
select '<tr><td><b>Owner</b>',
 '<td><b>Indexes</b>',
 '<td><b>Status</b>'
from dual;
select 
 '<tr><td>'||owner ||'<td>'|| count(*) ||'<td>'|| status
from sys.dba_indexes
where status <> 'VALID' and partitioned <>'YES'
group by owner, status
order by owner;
select '<tr><td><b>Owner</b>',
 '<td><b>Index Partitions</b>',
 '<td><b>Status</b>'
from dual;
select 
 '<tr><tr><td>'||index_owner ||'<td>'|| count(*) ||'<td>'|| status
from sys.dba_ind_partitions
where status <> 'USABLE'
group by index_owner, status
order by index_owner;
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Invalid Datafiles</b></td></tr>' 
from dual;
select '<tr><td><b>Datafile</b>',
 '<td><b>Status</b>'
from dual;
select 
 '<tr><td>#'||file#||' - '||name ||'<td>'|| status ||'<td>'|| enabled
from sys.v$datafile
where status <> 'ONLINE'
 and status <> 'SYSTEM';
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Invalid Blocks</b></td></tr>' 
from dual;
select '<tr><td><b>File#</b>',
 '<td><b>Block#</b>',
 '<td><b>Corruption Type</b>'
from dual;
select 
 '<tr><td>#'||file#, '<td>'|| block#, '<td>'|| CORRUPTION_TYPE
from sys.v$database_block_corruption;
select '</table><p><hr>' from dual;

select '<P><a id="usg"></A>' from dual;
rem missing: UNDO, NEXTED TABLE, TYPE2 UNDO, ... I know but they are a bit less important here
select '<P><table border="2"><tr><td><b>Space Usage</b></td></tr>' from dual;
select '<tr><td><b>Tablespace</b>',
 '<td><b>Total (MB)</b>',
 '<td><b>Tables</b>',
 '<td><b>Table Part.s</b>',
 '<td><b>Table SubP.s</b>',
 '<td><b>Indexes</b>',
 '<td><b>Index Part.s</b>',
 '<td><b>LOBs</b>',
 '<td><b>Clusters</b>'
from dual;
select '<tr><td>'||tablespace_name tablespace,
 '<td align="right">'||to_char(round(sum(bytes/1048576)),
		'999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'TABLE',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'TABLE PARTITION',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'TABLE SUBPARTITION',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'INDEX',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'INDEX PARTITION',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(substr(segment_type,1,3),'LOB',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'CLUSTER',round(bytes/1048576),0)),
		'999,999,999,999')
from sys.dba_extents
group by tablespace_name
order by tablespace_name;

select '<tr><td>TOTAL (MB)',
 '<td align="right">'||to_char(round(sum(bytes/1048576)),
		'999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'TABLE',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'TABLE PARTITION',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'TABLE SUBPARTITION',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'INDEX',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'INDEX PARTITION',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(substr(segment_type,1,3),'LOB',round(bytes/1048576),0)),
		'99,999,999,999,999'),
 '<td align="right">'||to_char(sum(decode(segment_type,'CLUSTER',round(bytes/1048576),0)),
		'999,999,999,999')
from sys.dba_extents;
select '</table><p>' from dual;

select '<P><table border="2">' from dual;
select '<tr><td><b>Container</b>',
 '<td><b>Bytes</b>'
from dual;
select '<tr><td>Recycle Bin', 
 '<td align="right">'||to_char(sum(space*8)*1024,'999,999,999,999') 
from dba_recyclebin;
select '</table><p><hr>' from dual;

select '<P><a id="part"></A>' from dual;
select '<P><table border="2"><tr><td><b>Partitioning</b></td></tr>' from dual;
select '<tr><td><b>Owner</b>', '<td><b>#Partitioned Tables</b>' from dual;
select '<tr><td>', table_owner,'<td align=right>', count(distinct table_name)
 from dba_tab_partitions
 where table_owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
 group by table_owner
 order by table_owner;
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Partitioning Details</b></td></tr>' from dual;
select '<tr><td><b>Owner</b>', '<td><b>Table</b>', '<td><b>Partitions</b>', '<td><b>Rows</b>', '<td><b>Est. Size</b>'
from dual;
select '<tr><td>',table_owner, '<td>', TABLE_NAME, '<td align="right">', 
       count(*), '<td align="right">',to_char(sum(num_rows),'999,999,999,999,999'),
       '<td align="right">',to_char(sum(blocks/128),'999,999,999,999')
from dba_tab_partitions
where table_owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
group by TABLE_OWNER, TABLE_NAME
order by TABLE_OWNER, TABLE_NAME;
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Partitions Details</b></td></tr>' from dual;
select '<tr><td><b>Owner</b>', '<td><b>Table</b>', '<td><b>Tablespace</b>', '<td><b>Partition</b>', '<td><b>Rows</b>', '<td><b>Sub.Partitions</b>' from dual;
select '<tr><td>', table_owner,'<td>', table_name,'<td>', tablespace_name,'<td>', partition_name,'<td align=right>', to_char(num_rows,'999,999,999,999'),'<td align=right>', subpartition_count
 from dba_tab_partitions
 where table_owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
 and rownum < 101
 order by table_owner,table_name,partition_position;
select '<tr><td>...</table><p>' from dual;

select '<a id="parallel"></A>' from dual;
select '<P><table border="2"><tr><td><b>Parallel degree</b></td></tr>' from dual;
select '<tr><td><b>Degree</b>', '<td><b>Instances</b>', '<td><b>#Tables</b>' from dual;
select '<tr><td>', degree,'<td>', instances,'<td>', count(*)
 from dba_tables
 where owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
 group by degree, instances
 order by degree desc, instances desc;
select '</table><p><hr>' from dual;

select '<a id="compression"></A>' from dual;
select '<P><table border="2"><tr><td><b>Compression</b></td></tr>' from dual;
select '<tr><td><b>Owner</b><td><b>Compression</b>', '<td><b>#Tables</b>' from dual;
select '<tr><td>', owner,'<td>', compression,'<td>', count(*)
 from dba_tables
 where owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
   and compression='ENABLED'
 group by owner, compression
 order by owner, compression;
select '<tr><td>TOTAL<td>Compressed Tables<td>', count(*)
 from dba_tables
 where owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
   and compression='ENABLED';
select '<tr><td><b>Owner</b><td><b>Compression</b>', '<td><b>#Indexes</b>' from dual;
select '<tr><td>', owner,'<td>', compression,'<td>', count(*)
 from dba_indexes
 where owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
   and compression='ENABLED'
 group by owner, compression
 order by owner, compression;
select '<tr><td>TOTAL<td>Compressed Indexes<td>', count(*)
 from dba_indexes
 where owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
   and compression='ENABLED';
select '<tr><td><b>Owner</b><td><b>Compression</b>', '<td><b>#Partitions</b>' from dual;
select '<tr><td>', table_owner,'<td>', compression,'<td>', count(*)
 from dba_tab_partitions
 where table_owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
   and compression='ENABLED'
 group by table_owner, compression
 order by table_owner, compression;
select '<tr><td>TOTAL<td>Compressed Tablespaces<td>', count(*)
 from dba_tab_partitions
 where table_owner not in ('SYS','SYSTEM','SYSMAN','WMSYS')
   and compression='ENABLED';
select '</table><p><hr>' from dual;

select '<P><a id="spatial"></A>' from dual;
select '<P><table border="2"><tr><td><b>Oracle Spatial</b></td></tr>' from dual;
select '<tr><td><b>Owner</b>', '<td><b>Spatial Tables</b>' from dual;
select '<tr><td>', owner,'<td align=right>', count(*)
 from all_sdo_geom_metadata
 group by owner;
select '<tr><td>TOTAL<td align=right>', count(*)
 from all_sdo_geom_metadata;
select '</table><p><a href="#top">Top</a><hr>' from dual;

select '<P><a id="sga"></A>' from dual;
select '<P><table><tr><td valign=top><table border="2"><tr><td><b>SGA</b></td></tr>' from dual;
select '<tr><td><b>SGA element</b>', '<td><b>Bytes</b>', '<td><b>MB</b>' from dual;
select '<tr><td>'||substr(name,1,25),
 '<td align="right">'||to_char(value,'999,999,999,999'),
 '<td align="right">'||to_char(value/(1024*1024),'999,999,999,999')
from sys.v_$sga
order by value desc;
select '</table><p>' from dual;

select '<td valign=top><table border="2"><tr><td><b>Memory Usage</b></td></tr>' from dual;
select '<tr><td><b>Pool</b>', '<td><b>Name</b>','<td><b>MB</b>'
from dual;
select '<tr><td>'||pool, '<td>'||name, 
 '<td align="right">'||to_char(bytes/(1024*1024),'999,999,999,999')
from (select pool, name, bytes from V$sgastat order by bytes desc)
where rownum <=20;
select '<tr><td>...</table><p>' from dual;

select '<td valign=top><table border="2"><tr><td><b>Free Memory</b></td></tr>' from dual;
select '<tr><td><b>Pool</b>', '<td><b>Name</b>','<td><b>MB</b>'
from dual;
select '<tr><td>'||pool, '<td>'||name, 
 '<td align="right">'||to_char(bytes/(1024*1024),'999,999,999,999')
from V$sgastat
where name like 'free memory%';
select '</table><p>' from dual;

select '<td valign=top><table border="2"><tr><td><b>Parameters</b></td></tr>' from dual;
select '<tr><td><b>Parameter</b>', '<td><b>Value</b>','<td><b>IsDefault</b>'
from dual;
select  '<tr><td>'||name||'<td align="right">'||to_char(value,'999,999,999,999')||'<td>'||isdefault
  from sys.v$parameter
 where name in ('sga_target', 'sga_max_size', 'db_cache_size', 'shared_pool_size', 'memory_target',
                'large_pool_size', 'java_pool_size', 'streams_pool_size', 'inmemory_size',
                'memory_max_target', 'log_buffer', 'db_keep_cache_size', 'db_recycle_cache_size')
order by isdefault, name;
select '</table></table><p><hr>' from dual;

select '<P><a id="dat"></A>' from dual;
select '<P><table border="2"><tr><td><b>Datafiles</b></td></tr>' from dual;
select '<tr><td><b>Tablespace</b>',
 '<td><b>Datafile</b>',
 '<td><b>Bytes</b>',
 '<td><b>Read #</b>',
 '<td><b>Write #</b>'
from dual;
select '<tr><td>'||tablespace_name tablespace,
 '<td>'||file_name data_file,
 '<td align="right">'||to_char(bytes,'999,999,999,999,999'), 
 '<td align="right">'||to_char(phyrds,'999,999,999,999') "Read #", 
 '<td align="right">'||to_char(phywrts,'999,999,999,999') "Write #"
from sys.dba_data_files, v$filestat
where file_id=file#
order by tablespace_name,file_name;
select '</table><p>' from dual;
select '<b>Autoextend datafiles: </b>' from dual;
select file_name data_file
 from sys.dba_data_files
 where autoextensible='YES';
select '<p><b>Not autoextensible datafiles: </b>' from dual;
select file_name data_file
 from sys.dba_data_files
 where autoextensible<>'YES';
select '<p><hr>' from dual;

set numwidth  8
select '<P><a id="roll"></A>' "Rollbacks" from dual;
select '<P><table border="2"><tr><td><b>Rollbacks</b></td></tr>' from dual;
select '<tr><td><b>Rollback Segment</b>',
 '<td><b>Tablespace</b>',
 '<td><b>Bytes</b>',
 '<td><b>Extents</b>',
 '<td><b>Status</b>'
from dual;
select '<tr><td>'||substr(a.segment_name,1,25) rollback_segment,
 '<td>'||substr(a.tablespace_name,1,25) tablespace,
 '<td align="right">'||to_char(sum(bytes),'999,999,999,999') bytes,
 '<td align="right">'||substr(max(extent_id)+1,1,7) extents,
 '<td>'||substr(status,1,7) status
from sys.dba_extents a, sys.dba_rollback_segs b
where a.segment_name = b.segment_name
and   segment_type='ROLLBACK'
group by a.tablespace_name,a.segment_name,status
order by a.tablespace_name,a.segment_name;
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Undo Parameters</b></td></tr>'
 from dual;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||name||'<td>'||value
from sys.v$parameter
where name like 'undo%'
order by name; 
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Undo Datafiles</b></td></tr>'
 from dual;
select '<tr><td><b>Tablespace</b>',
 '<td><b>Datafile</b>',
 '<td><b>Bytes</b>',
 '<td><b>Autoextensible</b>'
from dual;
select '<tr><td>'||tablespace_name tablespace,
 '<td>'||file_name data_file,
 '<td align="right">'||to_char(bytes,'999,999,999,999,999'), 
 '<td>'||autoextensible
from sys.dba_data_files
where tablespace_name like 'UNDO%'
order by tablespace_name,file_name;
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Undo Extents</b></td></tr>'
 from dual;
select '<tr><td><b>Tablespace</b>',
 '<td><b>Status</b>',
 '<td><b>#</b>',
 '<td><b>Bytes</b>'
from dual;
select '<tr><td>'||tablespace_name tablespace,
 '<td>'||status, '<td>'||count(*),
 '<td align="right">'||to_char(sum(BYTES),'999,999,999,999,999')
from sys.DBA_UNDO_EXTENTS
group by tablespace_name,status
order by tablespace_name,status;
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Tuned retention</b></td></tr>'
 from dual;
select '<tr><td><b>AVG</b>',
 '<td><b>MAX</b>',
 '<td><b>MIN</b>', '<td><b>Std DEV</b>'
from dual;
select '<tr><td>'||round(avg(TUNED_UNDORETENTION)),
 '<td>'||max(TUNED_UNDORETENTION),
 '<td>'||min(TUNED_UNDORETENTION),
 '<td>'||round(stddev(TUNED_UNDORETENTION))
from v$undostat;
select '</table><p><hr>' from dual;

select '<P><a id="log"></A>' from dual;
select '<P><table border="2"><tr><td><b>Log Files</b></td></tr>' from dual;
select '<tr><td><b>Group#</b>', '<td><b>Log File</b>', '<td><b>Status</b>',
 '<td><b>Bytes</b>', '<td><b>Thread</b>'
from dual;
select '<tr><td>'||sys.v_$logfile.group# group_id, '<td>'||member log_file, '<td>'||sys.v_$log.status || ' ' ||sys.v_$logfile.status group_status,
       '<td align="right">'||to_char(bytes,'999,999,999,999') bytes, '<td align="right">'||thread#
from sys.v_$logfile, sys.v_$log
where sys.v_$logfile.group# = sys.v_$log.group#
order by thread#, 1;
select '</table><p>' from dual;

select '<P><table><tr><td valign=top><table border="2"><tr><td><b>Log Switches</b><td>Daily</tr>' from dual;
select '<tr><td><b>Date</b>', '<td><b> Count</b>'
from dual;

select '<tr>' from dual;
select '<tr><td>'||trunc(first_time) switch_date,
       '<td align="right">'||to_char(count(*),'999,999,999,999') counter
from sys.v_$log_history
where first_time > sysdate -31
group by trunc(first_time)
order by trunc(first_time) desc;
select '</table>' from dual;

select '<td valign=top><table border="2"><tr><td><b>Log Switches</b><td>Hourly</tr>' from dual;
select '<tr><td><b>Date</b>','<td><b> Count</b>'
from dual;
select '<tr><td>'||to_char(first_time, 'YYYY-MM-DD HH24')||':00:00' switch_date,
       '<td align="right">'||to_char(count(*),'999,999,999,999') counter
from sys.v_$log_history
where first_time > sysdate -1.3
group by to_char(first_time, 'YYYY-MM-DD HH24')
order by to_char(first_time, 'YYYY-MM-DD HH24') desc;
select '</table></table><p>' from dual;

select '<P><table border="2"><tr><td><b>Archived Logs</b>' from dual;
select '<tr><td><b>Creator</b>','<td><b>Registrar</b>','<td><b>Status</b>','<td><b>Archived</b>','<td><b>Count</b>'
from dual;
select '<tr><td>'||creator, '<td>'||registrar, '<td>'||status, '<td>'||archived,
       '<td align="right">'||to_char(count(*),'999,999,999,999') counter
from v$archived_log
where deleted='NO'
group by creator, registrar, archived, status
order by status,creator,registrar;
select '</table><p><a href="#top">Top</a><hr>' from dual;

select '<P><a id="control"></a>' "Control Files" from dual;
select '<P><table border="2"><tr><td><b>Control File Informations</b></table><pre>' from dual;
set heading on
column type format a32
select value files
 from v$parameter
 where name='control_files';
select *
 from v$controlfile_record_section;
set heading off
select '</pre><p>' from dual;

select '<P><a id="recovery"></a>' "Recovery Area" from dual;
select '<P><table border="2"><tr><td><b>Recovery Area Usage </b></table><pre>' from dual;
set heading on
column RECOVERY_DEST_SIZE format a50
column FREE_RECOVERY_PCT format a20
select substr(name||': '||value||'  ('||round(value/(1024*1024*1024))||'GB)',1,60) Recovery_Dest_Size 
from v$parameter where name='db_recovery_file_dest_size';
select * from v$flash_recovery_area_usage;
select trunc(100-sum(PERCENT_SPACE_USED)-sum(PERCENT_SPACE_RECLAIMABLE))||'%' Free_Recovery_pct  from v$flash_recovery_area_usage;
set heading off
select '</pre><p><a href="#top">Top</a><hr>' from dual;

select '<P><a id="usr"></a>' "Users" from dual;
select '<P><table border="2"><tr><td><b>Users</b></td></tr>' from dual;
select '<tr><td><b>Username</b>',
 '<td><b>Default Tablespace</b>',
 '<td><b>Temporary Tablespace</b>', '<td><b>Status</b>',
 '<td><b>Profile</b>', '<td><b>Expiry date</b>'
  from dual;
select '<tr><td>'||substr(username,1,25) username,
 '<td>'||substr(default_tablespace,1,25) default_tablespace,
 '<td>'||substr(temporary_tablespace,1,25) temp_tablespace,
 '<td>'||account_status,
 '<td>'||profile,
 '<td>'||expiry_date
  from sys.dba_users
 order by username;
select '<tr><td>TOTAL<td>'||count(*)||'<td><td>OPEN: '||sum(decode(account_status,'OPEN',1,0))
  from sys.dba_users;
select '</table><p>' from dual;

select '<P><a id="profile"></a>' "Profile" from dual;
select '<P><table border="2"><tr><td><b>DEFAULT Profile</b></td></tr>' from dual;
select '<tr><td><b>Resource</b>',
 '<td><b>Limit</b>'
from dual;
select '<tr><td>'||resource_name,
 '<td>'||limit
  from sys.dba_profiles
 where profile='DEFAULT'
 order by resource_name;
select '</table><p>' from dual;

select '<P><a id="pw_users"></a>' "PW users" from dual;
select '<P><table border="2"><tr><td><b>Password file users</b></table><pre>' from dual;
set heading on
column username format a40
select USERNAME,INST_ID,SYSDBA,SYSOPER
  from gv$pwfile_users
 order by INST_ID,USERNAME;
set heading off
select '</pre>' from dual;

select '<P><a id="usr_sec"></a>' "defaultpw" from dual;
select '<P><table border="2"><tr><td><b>Users with default passwords</b></td></tr>' from dual;
select '<tr><td><b>Username</b>',
 '<td><b>Status</b>'
from dual;
select '<tr><td>',username, '<td>', account_status
 from dba_users
 where password in
('E066D214D5421CCC', '24ABAB8B06281B4C', '72979A94BAD2AF80', '9AAEB2214DCC9A31',
 'C252E8FA117AF049', 'A7A32CD03D3CE8D5', '88A2B2C183431F00', '7EFA02EC7EA6B86F',
 '9B616F5489F90AD7', '4A3BA55E08595C81', 'F894844C34402B67', '3F9FBD883D787341',
 '79DF7A1BD138CF11', '7C9BA362F8314299', '88D8364765FCE6AF', 'F9DA8977092B7B81',
 '9300C0977D7DC75E', 'A97282CE3D94E29E', 'AC9700FD3F1410EB', 'E7B5D92911C831E1',
 'AC98877DE1297365', '66F4EF5650C20355', '84B8CBCA4D477FA3', 'D4C5016086B2DC6A',
 '5638228DAF52805F', 'D4DF7931AB130E37', 'D728438E8A5925E0', '545E13456B7DDEA0', 
 '2FFDCBB4FD11D9DC', '56DB3E89EAE5788E', '402B659C15EAF6CB', '71E687F036AD56E5',
 '24ABAB8B06281B4C', 'A13C035631643BA0', '72979A94BAD2AF80', '4A3BA55E08595C81', 
 '355CBEC355C10FEF', '80294AE45A46E77B', 'E7B5D92911C831E1', 'E74B15A3F7A19CA8', 
 'BEAA1036A464F9F0', 'B1344DC1B5F3D903', '58872B4319A76363', 'F894844C34402B67', 
 '8A8F025737A9097A', '4DE42795E66117AE', '639C32A115D2CA57', '447B729161192C24', 
 '8BF0DA8E551DE1B9', '482B65ME0BEAF6BB', '2D594E86F93B17A1', '970BAA5B81930A40')
order by account_status desc, username;
select '</table><p>See also <a href="#usr_sec_11g">11g Users</a>.<p><hr>' from dual;

select '<P><a id="lic"></A>' "Licensing info" from dual;

select '<P><table border="2"><tr><td><b>Licensing</b></td></tr>'
 from dual;
select '<tr><td><b>Detected Edition:</b>',
 '<td>'
from dual;

select '<b>Enterprise</b>'
  from sys.v_$version
 where banner like '%Enterprise%' and banner like 'Oracle%';
select '<b>XE (Express)</b>'
  from sys.v_$version
 where banner like '%Express%' and banner like 'Oracle%';
select '<b>Free (Developer-Release)</b>'
  from sys.v_$version
 where banner like '%Developer-Release%' and banner like 'Oracle%';
select '<b>Standard</b>'
  from (select banner from sys.v_$version where banner like 'Oracle%') a
 where banner not like '%Enterprise%' and banner not like '%Express%' and banner not like '%Developer-Release%';

select '<tr><tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
from dual;
 
select  
 '<tr><td>USER max<td align="right">'|| users_max,
 '<tr><td>SESSION max<td align="right">'|| sessions_max,
 '<tr><td>SESSION curr./HiW.<td align="right">'|| sessions_current|| ' / ' || sessions_highwater
from v$license;

select  
 '<tr><td>CPU curr./HiW.<td align="right">'|| cpu_count_current|| ' / ' || cpu_count_highwater,
 '<tr><td>CORE curr./HiW.<td align="right">'|| cpu_core_count_current|| ' / ' || cpu_core_count_highwater,
 '<tr><td>SOCKET curr./HiW.<td align="right">'|| cpu_socket_count_current|| ' / ' || cpu_socket_count_highwater
from v$license;

select  
 '<tr><td>Diagnostic and tuning pack enabled<td>'|| value
from sys.v$parameter
where name in ('control_management_pack_access');
select  
 '<tr><td>In-Memory enabled (12c)<td>'|| value
from sys.v$parameter
where name in ('inmemory_query');
select  
 '<tr><td>Max PDBS (12cR2)<td>'|| value
from sys.v$parameter
where name in ('max_pdbs');
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Options</b></td></tr>' from dual;
select '<tr><td><b>Installed</b>',
 '<td><b>Not installed</b><tr><td>'
from dual;
select parameter ||', '
 from v$option
 where value='TRUE';
select '<td>' from dual;
select parameter ||', '
 from v$option
 where value='FALSE';
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Features Used</b></td></tr>' from dual;
select '<tr><td><b>Name</b>', '<td><b>Count</b>', '<td><b>First</b>', '<td><b>Last</b>',
 '<td><b>Description</b>'
  from dual;
select '<tr><td>'|| name, '<td>'|| sum(DETECTED_USAGES), '<td>'|| min(FIRST_USAGE_DATE), '<td>'|| max(LAST_USAGE_DATE),
 '<td>'|| DESCRIPTION || ' - ' || replace(replace(max(dbms_lob.substr(feature_info,128,1)),'<','&lt;'),'>','&gt;')
  from DBA_FEATURE_USAGE_STATISTICS
 where CURRENTLY_USED='TRUE'
 group by name, DESCRIPTION
 order by name;
select '</table><P><table border="2"><tr><td><b>Features NOT in Use</b></td></tr>' from dual;
select '<tr><td><b>Name</b>', '<td><b>Count</b>', '<td><b>Description</b>'
  from dual;
select '<tr><td>'|| name, '<td>'|| sum(DETECTED_USAGES), '<td>'|| DESCRIPTION
  from DBA_FEATURE_USAGE_STATISTICS
 where CURRENTLY_USED='FALSE'
 group by name, DESCRIPTION
 order by name;
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>High-Water Mark Statistics</b></td></tr>' from dual;
select '<tr><td><b>Name</b>', '<td><b>Maximum Value</b>', '<td><b>Description</b>'
  from dual;
select '<tr><td>'|| name, '<td>'|| HIGHWATER, '<td>'|| DESCRIPTION
  from DBA_HIGH_WATER_MARK_STATISTICS;
select '</table><p><a href="#top">Top</a><hr>' from dual;

select '<P><a id="sess"></A>' "Sessions" from dual;
select '<P><table border="2"><tr><td><b>Per-User sessions</b></td></tr>'
  from dual;
select '<tr><td><b>User</b>', '<td><b>InstID</b>', '<td><b>Count</b>', '<td><b>Active</b>'
  from dual;
select  
 '<tr><td>'||s.schemaname username,  
  '<td>'||s.inst_id,
  '<td>', count(*),
  '<td>', sum(decode(status,'ACTIVE',1,0))
  from gv$process p, gv$session s
 where s.paddr = p.addr
   and s.inst_id = p.inst_id
   and type='USER'
 group by s.schemaname, s.inst_id
 order by 4 desc;
select '<tr><td>TOTAL (', count(distinct s.schemaname),  ' distinct users )<td>', max(s.inst_id),
       '<td>', count(*), '<td>', sum(decode(status,'ACTIVE',1,0))
  from gv$process p, gv$session s
 where s.paddr = p.addr
   and s.inst_id = p.inst_id
   and type='USER';
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Current sessions</b></td></tr>'
  from dual;
select '<tr><td><b>SID,serial</b>', '<td><b>User</b>', '<td><b>OS User</b>', '<td><b>Process</b>',
       '<td><b>Type</b>', '<td><b>Status</b>', '<td><b>Command</b>', '<td><b>Program</b>',
       '<td><b>Module</b>', '<td><b>InstID</b>', '<td><b>Logon</b>', '<td><b>Client</b>'
from dual;
 
select  
 '<tr><td>'|| s.sid||','||s.serial# sid,
 '<td>'||s.schemaname username,  
 '<td>'||s.osuser os_user,
 '<td>'||p.spid process,
 '<td>'||s.type type,
 '<td>'||s.status status,
 '<td>'||decode(s.command, 1,'Create table',2,'Insert',3,'Select',
   4,'Create cluster',5,'Alter cluster',6,'Update',7,'Delete',
   8,'Drop',9,'Create index',10,'Drop index',11,'Alter index',
   12,'Drop table',15,'Alter table', 16, 'Drop Seq.', 17,'Grant',18,'Revoke',
   19,'Create synonym',20,'Drop synonym',21,'Create view',
   22,'Drop view',23,'Validate index',24,'Create procedure',25,'Alter procedure',
   26,'Lock table',27,'No operation',28,'Rename',
   29,'Comment',30,'Audit',31,'Noaudit',32,'Create ext. database',
   33,'Drop ext. database',34,'Create database',35,'Alter database',
   36,'Create rollback segment',37,'Alter rollback segment',
   38,'Drop rollback segment',39,'Create tablespace',
   40,'Alter tablespace',41,'Drop tablespace',42,'Alter session',
   43,'Alter user',44,'Commit',45,'Rollback',46,'Savepoint', 
   47,'PL/SQL Exec',48,'Set Transaction',
   60,'Alter trigger',62,'Analyze Table',
   63,'Analyze index',71,'Create Snapshot Log',
   72,'Alter Snapshot Log',73,'Drop Snapshot Log',
   74,'Create Snapshot',75,'Alter Snapshot',
   76,'Drop Snapshot',79,'Alter Role',
   85,'Truncate table',86,'Truncate Cluster', 
   88,'Alter View',91,'Create Function',92,'Alter Function',93,'Drop Function', 
   94,'Create Package',95,'Alter Package',96,'Drop Package', 
   97,'Create PKG Body',98,'Alter PKG Body',99,'Drop PKG Body',
   0,'No command',
   'Other') Command,
  '<td>'||substr(s.program,1,64) program,
  '<td>'||module,
  '<td>'||s.inst_id,
  '<td>'||to_char(logon_time, 'YYYY-MM-DD HH24:MI:SS'),
  '<td>'||s.client_identifier
  from gv$process p, gv$session s
 where s.paddr = p.addr
   and s.inst_id = p.inst_id
 order by s.type desc, s.status, s.inst_id, s.sid;
select '</table><p><hr>' from dual;

select '<P><a id="sql"></A>' "Current SQL" from dual;
select '<P><table border="2"><tr><td><b>SQL</b></td></tr>'
 from dual;
select '<tr><td><b>SID</b>',
 '<td><b>User</b>',
 '<td><b>Exec</b>',
 '<td><b>Parse</b>',
 '<td><b>Read</b>',
 '<td><b>Get</b>',
 '<td><b>Running SQL</b>'
from dual;

select 	'<tr><td>'||s.sid,
  '<td>'||s.username,
  '<td>'||q.executions exec,
  '<td>'||q.parse_calls parse,
  '<td>'||q.disk_reads read,
  '<td>'||q.buffer_gets get  ,   
  '<td>'||replace(replace(q.sql_text,'<','&lt;'),'>','&gt;') sql
from gv$session s, gv$sql q
where s.sql_address=q.address
and   s.type <> 'BACKGROUND'
and   s.status = 'ACTIVE'
and   s.username <> 'SYS'
and   s.inst_id = q.inst_id
order by s.sid;
select '</table><p><hr>' from dual;

select '<P><a id="lock"></A>' "Locks" from dual;
select '<P><table border="2"><tr><td><b>Lock</b></td></tr>'
 from dual;
select '<tr><td><b>SID</b>',
 '<td><b>Lock Type</b>',
 '<td><b>Lock Mode</b>',
 '<td><b>Request</b>',
 '<td><b>Lock Count</b>'
from dual;

select '<tr><td>'||l.sid, '<td>'||l.type, '<td>'||decode(l.lmode, 0, 'WAITING', 1,'Null', 2, 'Row Share', 
  3, 'Row Exclusive', 4, 'Share',
  5, 'Share Row Exclusive', 6,'Exclusive', l.lmode) lock_mode, 
 '<td>'||decode(l.request, 0,'HOLD', 1,'Null', 2, 'Row Share',
  3, 'Row Exclusive', 4, 'Share', 5, 'Share Row Exclusive',
  6,'Exclusive', l.request) request, 
 '<td align=right>', count(*) lock_id
from gv$lock l
group by l.sid, l.type, l.lmode, l.request
order by l.sid, l.type, l.lmode, l.request;
select '</table><p><a href="#top">Top</a><hr>' from dual;

select '<P><a id="stat"></A><P>' from dual;
select '<P><table border="2"><tr><td><b>Performance statistics</b><tr><td><pre>' from dual;
select 'A)  Hit ratio buffer cache (>80%): '||
  to_char(round(1-(
   sum(decode(name,'physical reads',1,0)*value) 
   /(sum(decode(name,'db block gets',1,0)*value) 
   +sum(decode(name,'consistent gets',1,0)*value))
  ), 3)*100) || '%'  statistic
 from v$sysstat
 where name in ('db block gets', 'consistent gets', 'physical reads')
 union
select 'B1) Misses library cache (<1%): '
  ||to_char(round(sum(reloads)/sum(pins)*100, 3)) || '%' 
 from v$librarycache
 union
select 'B1.'||ROWNUM||') Detailed misses library cache ('
  ||namespace || '-' ||to_char(pins)
  ||'): '||to_char(round(decode(pins,0,0,reloads/pins*100), 3))
  || '%' Statistica
 from v$librarycache
 union
select 'B2) Misses dictionary cache (<10%): '
  ||to_char(round(sum(getmisses)/sum(gets)*100, 3)) || '%' 
 from v$rowcache
 union
select 'C1) System undo header frequence (<1%): '
  ||to_char(round(avg(count)/sum(value)*100, 3)) || '%' 
 from v$waitstat w, v$sysstat s
 where w.class='system undo header' and
  name in ('db_block_gets', 'consistent gets')
 union
select 'C2) System undo block frequence (<1%): '
  ||to_char(round(avg(count)/sum(value)*100, 3)) || '%' 
 from v$waitstat w, v$sysstat s
 where w.class='system undo block' and
  name in ('db_block_gets', 'consistent gets')
 union
select 'C3) Undo header frequence (<1%): '
  ||to_char(round(avg(count)/sum(value)*100, 3)) || '%' 
 from v$waitstat w, v$sysstat s
 where w.class='undo header' and
  name in ('db_block_gets', 'consistent gets')
 union
select 'C4) Undo block frequence (<1%): '
  ||to_char(round(avg(count)/sum(value)*100, 3)) || '%' 
 from v$waitstat w, v$sysstat s
 where w.class='undo block' and
  name in ('db_block_gets', 'consistent gets')
 union
select 'D)  Redo log space req. (near 0): '||to_char(value)  
 from v$sysstat
 where name ='redo log space requests'
 union
select 'E1) Hit ratio redo alloc (<1%): '
  ||decode(gets,0,'NA',to_char(round(misses/gets*100, 3)) || '%' )
 from v$latch
 where latch#=15
 union
select 'E2) Hit ratio immediate redo alloc (<1%): '
  ||decode(immediate_gets,0,'NA',
   to_char(round(immediate_misses/immediate_gets*100, 3)) || '%' )
 from v$latch
 where latch#=15
 union
select 'E3) Hit ratio redo copy (<1%): '
  ||decode(gets,0,'NA',to_char(round(misses/gets*100, 3)) || '%') 
 from v$latch
 where latch#=16
 union
select 'E4) Hit ratio immediate redo copy (<1%): '
  ||decode(immediate_gets,0,'NA',
   to_char(round(immediate_misses/immediate_gets*100, 3)) || '%' )
 from v$latch
 where latch#=16
 union
select 'F)  Free list contention (<1%): '
  || to_char(round(count/value*100, 3)) || '%' 
 from v$waitstat w, v$sysstat s
 where w.class='free list' and
  name in ('consistent gets')
 union
select 'G1) Sorts in memory: '||to_char(value)  
 from v$sysstat
 where name in ('sorts (memory)')
 union
select 'G2) Sorts on disk: '||to_char(value)  
 from v$sysstat
 where name in ('sorts (disk)')
 union
select 'H1) Short tables full scans: '||to_char(value)  
 from v$sysstat
 where name in ('table scans (short tables)')
 union
select 'H2) Long tables full scans: '||to_char(value)  
 from v$sysstat
 where name in ('table scans (long tables)')
 union
select 'I1 @'||inst_id||') Logon: '||to_char(value)  
 from gv$sysstat
 where name in ('logons cumulative')
 union
select 'I2 @'||gv$sysstat.inst_id||') Commit: '||to_char(value) ||
       ' TPS: '|| to_char( round(value/((sysdate-startup_time)*24*60*60),5) )
 from gv$sysstat,gv$instance
 where name in ('user commits') and gv$sysstat.inst_id=gv$instance.inst_id
 union
select 'I3 @'||inst_id||') Rollback: '||to_char(value)  
 from gv$sysstat
 where name in ('user rollbacks')
 union
select 'I4 @'||gv$sysstat.inst_id||') Exec: '||to_char(value) ||
       ' SQL/sec: '|| to_char( round(value/((sysdate-startup_time)*24*60*60),5) )
 from gv$sysstat,gv$instance
 where name in ('execute count') and gv$sysstat.inst_id=gv$instance.inst_id
 union
select 'L1 @'||gv$sysstat.inst_id||') DBcpu: '||to_char( round((value/100)/((sysdate-startup_time)*24*60*60),5) )  
 from gv$sysstat,gv$instance
 where name in ('DB time') and gv$sysstat.inst_id=gv$instance.inst_id
;
select '</pre></table><p>' from dual;

select '<P><table border="2"><tr><td><b>Stale Statistics</b></td></tr>' 
from dual;
select '<tr><td><b>Owner</b>',
 '<td><b>Table Stale Stats#</b>',
 '<td><b>Last Analyzed</b>'
from dual;
select '<tr><tr><td>'||OWNER||'<td align="right">'||count(*)||'<td>'||max(to_char(LAST_ANALYZED, 'YYYY-MM-DD HH24:MI:SS'))
from dba_tab_statistics
where STALE_STATS='YES'
group by owner
order by owner;
select '<tr><td><b>Owner</b>',
 '<td><b>Index Stale Stats#</b>',
 '<td><b>Last Analyzed</b>'
from dual;
select '<tr><tr><td>'||OWNER||'<td align="right">'||count(*)||'<td>'||max(to_char(LAST_ANALYZED, 'YYYY-MM-DD HH24:MI:SS'))
from dba_ind_statistics
where STALE_STATS='YES'
group by owner
order by owner;
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>I/O Statistics</b></td></tr>'
 from dual;
select '<tr><td><b>Name</b>',
 '<td><b>Value</b>', '<td><b>Metric</b>'
from dual;
select 
 '<tr><td>Small Reads<td align="right">'||
  sum(decode(name,'physical read total IO requests',value,0)-
  decode(name,'physical read total multi block requests',value,0)),
 '<tr><td>Small Writes<td align="right">'||
  sum(decode(name,'physical write total IO requests',value,0)-
  decode(name,'physical write total multi block requests',value,0)),
 '<tr><td>Large Reads<td align="right">'||
  sum(decode(name,'physical read total multi block requests',value,0)),
 '<tr><td>Large Writes<td align="right">'||
  sum(decode(name,'physical write total multi block requests',value,0)),
 '<td align="right">'||
  round(sum(decode(name,'physical read total IO requests',value,'physical write total IO requests',value,
                        'physical read total multi block requests',value,'physical write total multi block requests',value,0)-
  decode(name,'physical read total multi block requests',value,'physical write total multi block requests',value,0))
     /((sysdate-startup_time)*24*60*60),5), 'IOP/s',
 '<tr><td>Total MB Read<td align="right">'||
  trunc(sum(decode(name,'physical read total bytes',value,0))/(1024*1024)),
 '<td align="right">'||
  round(sum(decode(name,'physical read total bytes',value,0))/(1024*1024)
     /((sysdate-startup_time)*24*60*60),5), 'MB/s',
 '<tr><td>Total MB Written<td align="right">'||
  trunc(sum(decode(name,'physical write total bytes',value,0))/(1024*1024))
from v$sysstat,v$instance
group by startup_time;
select '</table><p><a href="#top">Top</a><hr>' from dual;

select '<P><a id="big"></A>' "Biggest Objects" from dual;
select '<P><table border="2"><tr><td><b>Biggest Objects</b></td></tr>'
 from dual;
select '<tr><td><b>Object</b>',
 '<td><b>Type</b>',
 '<td><b>Owner</b>',
 '<td><b>Tablespace</b>',
 '<td><b>Bytes</b>'
from dual;
select '<tr><td>'||segment_name,
 '<td>'||segment_type,
 '<td>'||owner,
 '<td>'||tablespace_name,
 '<td align="right"> '||to_char(bytes,'999,999,999,999,999')
from v_big_obj
where rownum <= 32
order by bytes desc;
select '<tr><td>...</table><p>' from dual;

select '<P><a id="frag"></A>' "Most Fragmented Objects" from dual;
select '<P><table border="2"><tr><td><b>Most Fragmented Objects</b></td></tr>'
 from dual;
select '<tr><td><b>Object</b>',
 '<td><b>Type</b>',
 '<td><b>Owner</b>',
 '<td><b>Tablespace</b>',
 '<td><b>Extents</b>',
 '<td><b>Bytes</b>'
  from dual;
select '<tr><td>'||segment_name,
 '<td>'||segment_type,
 '<td>'||owner,
 '<td>'||tablespace_name,
 '<td align="right"> '||to_char(extents,'999,999,999'),
 '<td align="right"> '||to_char(sum(bytes),'999,999,999,999,999')
  from v_frg_obj
 where rownum <= 32
 group by segment_name, segment_type, owner, tablespace_name, extents
 order by extents desc;
select '<tr><td>...</table><p><hr>' from dual;

select '<P><a id="psq"></A>' "PL/SQL" from dual;
select '<P><table border="2"><tr><td><b>PL/SQL</b></td></tr>'
  from dual;
select '<tr>',
 '<td><b>User</b>',
 '<td><b>Type</b>',
 '<td><b>Objects</b>',
 '<td><b>Lines</b>'
  from dual;
select '<tr><td>'||owner||'<td>'||type,
	'<td align="right">'||to_char(count(distinct name), '999,999,999')||
	'<td align="right">'||to_char(count(*), '999,999,999')
  from dba_source
 group by owner, type
 order by owner, type;

select '<tr><td>TOTAL<td>'||type,
	'<td align="right">'||to_char(count(distinct name||owner), '999,999,999')||
	'<td align="right">'||to_char(count(*), '999,999,999')
  from dba_source
 group by type
 order by type;
select '</table><p>' from dual;

select '<a id="lib"></A>' "Libraries" from dual;
select '<P><table border="2"><tr><td><b>Libraries</b></td></tr>'
  from dual;
select '<tr>',
 '<td><b>Owner</b>',
 '<td><b>Library</b>',
 '<td><b>File</b>',
 '<td><b>Status</b>',
 '<td><b>Dynamic</b>'
  from dual;
select '<tr><td>'||owner,'<td>'||library_name,'<td>'||file_spec,'<td>'||status,'<td>'||dynamic
  from all_libraries
 where owner not in ('SYS','XDB','MDSYS','ORDSYS');
select '</table><p><a href="#top">Top</a>' from dual;

select '<P><a id="dtype"></A>' "Data Type" from dual;
select '<P><pre><table border="2"><tr><td><b>Data Type Usage</b></td></tr>'
  from dual;
select '<tr>',
 '<td><b>User</b>',
 '<td><b>Data Type</b>',
 '<td><b>#</b>',
 '<td><b>Max Length</b>',
 '<td><b>Max Precision</b>'
  from dual;
select '<tr><td>'||owner||'<td>'|| data_type,
	'<td align="right">'||to_char(count(*), '999,999,999')||
	'<td align="right">'||to_char(max(DATA_LENGTH), '999,999,999')||
	'<td align="right">'||to_char(max(DATA_PRECISION), '999,999,999')
  from all_tab_columns
 where owner not in ('SYS','XDB','MDSYS','ORDSYS')
 group by owner, data_type
 order by owner, data_type;

select '<tr><td>TOTAL<td>'|| data_type,
	'<td align="right">'||to_char(count(*), '999,999,999')||
	'<td align="right">'||to_char(max(DATA_LENGTH), '999,999,999')||
	'<td align="right">'||to_char(max(DATA_PRECISION), '999,999,999')
  from all_tab_columns
 where owner not in ('SYS','XDB','MDSYS','ORDSYS')
 group by data_type
 order by data_type;
select '</table></pre><p><hr>' from dual;

select '<P><a id="job"></A>' "JOBS" from dual;
select '<P><table border="2"><tr><td><b>Jobs</b></td></tr>'
  from dual;
select '<tr><td><b>Job Id</b>',
 '<td><b>User</b>',
 '<td><b>Interval</b>',
 '<td><b>Command</b>',
 '<td><b>Total Time</b>'
  from dual;
select '<tr><td>'||job||'<td>'||schema_user||'<td>'||interval||'<td>'||what||'<td>'||round(total_time)
  from dba_jobs;
select '</table>' from dual;

select '<P><table border="2"><tr><td><b>Scheduler Jobs</b></td></tr>'
  from dual;
select '<tr><td><b>Job Name</b>',
 '<td><b>User</b>',
 '<td><b>Interval</b>', '<td><b>Start</b>',
 '<td><b>Command</b>',
 '<td><b>Count</b>',
 '<td><b>Last Duration</b>',
 '<td><b>Enabled</b>'
  from dual;
select '<tr><td>'||job_name||'<td>'||owner||'<td>'||repeat_interval||'<td>'||start_date,
       '<td>'||job_action, program_name,
       '<td>'||run_count||'<td>'||last_run_duration||'<td>'||enabled
  from dba_scheduler_jobs;
select '</table>' from dual;

select '<P><table border="2"><tr><td><b>Running Jobs</b></td></tr>'
  from dual;
select '<tr><td><b>Job Id</b>','<td><b>SID</b>',
 '<td><b>Last</b>',
 '<td><b>Failures</b>'
  from dual;
select /*+ rule */ '<tr><td>'||job||'<td>'||sid||'<td>'||last_date||'<td>'||failures
  from dba_jobs_running;
select '</table>' from dual;

select '<P><table border="2"><tr><td><b>Last executed Jobs</b></td></tr>'
  from dual;
select '<tr><td><b>Log Id</b>','<td><b>Name</b>',
 '<td><b>Log Date</b>',
 '<td><b>Actual Date</b>',
 '<td><b>Status</b>',
 '<td><b>Errors</b>'
  from dual;
select * from
(SELECT '<tr><td>'||l.log_id, '<td>'||l.job_name, 
       '<td>'||TO_CHAR (l.log_date, 'YYYY/MM/DD HH24:MI:SS.FF TZH:TZM'), 
       '<td>'||TO_CHAR (r.actual_start_date,'YYYY/MM/DD HH24:MI:SS.FF TZH:TZM'),
       '<td>'||r.status, '<td>'||r.errors
  FROM dba_scheduler_job_log l, dba_scheduler_job_run_details r 
 WHERE l.log_id = r.log_id(+)
 ORDER BY l.log_date DESC)
where rownum <20;
select '</table>' from dual;

select '<P><table border="2"><tr><td><b>Data Pump Jobs</b></td></tr>'
  from dual;
select '<tr><td><b>Owner</b>',
 '<td><b>Job Name</b>',
 '<td><b>State</b>'
  from dual;
select '<tr><td>'||owner_name||'<td>'||job_name||'<td>'||state
  from dba_datapump_jobs;
select '</table><p><hr>' from dual;

select '<P><a id="rman"></A>' "RMAN" from dual;
select '<P><table border="2"><tr><td><b>RMAN Configuration</b></td></tr>'
  from dual;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||name||'<td>'||value
from v$rman_configuration
order by conf#; 
select '</table><p><a href="#top">Top</a><hr>' from dual;

select '<P><a id="dbl"></A>' "Remote Database Links" from dual;
select '<P><table border="2"><tr><td><b>Database Links</b></td></tr>'
 from dual;
select '<tr><td><b>Owner</b><td><b>DB Link</b>',
 '<td><b>User</b>',
 '<td><b>Instance</b>'
from dual;
select '<tr><td>'||owner||'<td>'||db_link||'<td>'||username||'<td>'||host
from dba_db_links
order by host, username, owner, db_link;
select '</table>' from dual;

select '<P><table border="2"><tr><td><b>Directories</b></td></tr>'
 from dual;
select '<tr><td><b>Owner</b><td><b>Directory</b><td><b>Path</b>'
 from dual;
select '<tr><td>'||owner||'<td>'||directory_name||'<td>'||directory_path
 from dba_directories
 order by owner, directory_name;
select '</table><p><a href="#top">Top</a><hr>' from dual;

select '<P><a id="par"></A>' "Oracle Parameters" from dual;
select '<P><table border="2"><tr><td><b>Oracle Parameters</b></td></tr>'
 from dual;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||name||'<td>'||value
from sys.v$parameter
where isdefault ='FALSE'
order by name; 

select '<tr><td><b>Hidden Parameters</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||ksppinm||'<td>'||ksppstvl
 from x$ksppcv cv, x$ksppi pi
 where cv.indx = pi.indx
 and  translate(ksppinm,'_','#') like '#%' 
 and bitand(ksppiflg/256,1) <> 1
 and ksppinm like '%optimizer%' 
 order by ksppinm;
select '</table><p>' from dual;

select '<P><pre><table border="2"><tr><td><b>All Parameters</b></td></tr>'
 from dual;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||name||'<td>'||value
from sys.v$parameter
order by name; 
select '</table></pre><p><a href="#top">Top</a><hr>' from dual;


select '<P><a id="nls"></A>' "NLS Settings" from dual;
select '<P><table border="2"><tr><td><b>NLS Settings</b></td></tr>'
 from dual;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||name||'<td>'||value$
from sys.props$
where name like 'NLS%CHARACTER%'
order by name; 
select '</table><p>' from dual;

select '<P><a id="os"></A>' "OS" from dual;
select '<P><table border="2"><tr><td><b>Operating System Infos</b></td></tr>'
 from dual;
select '<tr><td><b>Parameter</b>', '<td><b>Value</b>'
from dual;
select '<tr><td>Platform<td>'||platform_name
from v$database;
select '<tr><td>'||stat_name||'<td align="right">'||to_char(value, '999,999,999,990.0')
from v$osstat
where stat_name in ('LOAD','PHYSICAL_MEMORY_BYTES','NUM_CPUS')
order by stat_name; 
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Timezone info</b></td></tr>'
 from dual;
select '<tr><td><b>SYSDATE</b>', '<td><b>CURRENT_DATE</b>',
       '<td><b>DB TIMEZONE</b>', '<td><b>Session TIMEZONE</b>', '<td><b>OS TIMEZONE</b>'
from dual;
SELECT '<tr><td>'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') sys_date
      ,'<td>'||TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD HH24:MI') cur_date
      ,'<td>'||DBTIMEZONE DB_TZ
      ,'<td>'||SESSIONTIMEZONE SESS_TZ
      ,'<td>'||TO_CHAR(SYSTIMESTAMP, 'TZR') OS_TZ
FROM DUAL;
select '</table><p><a href="#top">Top</a><hr>' from dual;

rem set long 100000 set pagesize 9000 SELECT dbms_xdb.cfg_get FROM dual;


select '<p><a id="cust"></A><h1>Plugins</h1>' h from dual;
start custom.sql
select '<p><a href="#top">Top</a><hr>' h from dual;

select '<p>Generating migration scripts in log directory...<br>' h from dual;

select '<P>Statistics generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||'<P>' 
from dual;

select '<br> Copyright: 2024 meob - License: GNU General Public License v3.0 <p></body></html>' from dual;
select '<br> Sources: https://github.com/meob/db2html/ <p></body></html>' from dual;

set newpage 1
spool off
drop view v_tab_occ;
drop view v_tab_free;
drop table v_big_obj;
drop table v_frg_obj;
drop table v_log_sd;


REM Generate schema migration scripts (great contribution by G. Tagliafico)
set define on
@SCHEMA_INFO_4_EXPIMP


exit
