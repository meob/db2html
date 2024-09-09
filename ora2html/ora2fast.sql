REM Programma:	ora2fast.sql
REM 		Struttura del database Oracle in formato HTML (Fast version)
REM		Funzionante dalla versione Oracle 7.3 alla 12c
REM              (con qualche table does not exists... nelle versioni meno recenti)
REM Autore:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM Data:	1-APR-98
REM Versione:	1.0.22 (FAST)
REM Note:	
REM 		1-JAN-10 mail@meo.bogliolo.name
REM		 1.0.22c minor changes

set space 1
set pagesize 9999
set linesize 130
set heading off
set feedback off
set timing off
ttitle off
spool ora2html.htm

select '<html> <head> <title>', value,
  ' - ora2html Oracle Statistics</title> </head>'||
 '<body>'
from v$parameter
where name like 'db_name';

select '<h1 align=center>'||substr(value,1,25)||'</h1>'
from v$parameter
where name ='db_name';

select '<P><A NAME="top"></A>' from dual;
select '<table><tr><td><ul>' from dual;
select '<li><A HREF="#status">Summary Status</A></li>' from dual;
select '<li><A HREF="#ver">Versions</A></li>' from dual;
select '<li><A HREF="#tbs">Tablespaces</A></li>' from dual;
select '<li><A HREF="#obj">Schema/Object Matrix</A></li>' from dual;
select '<li><A HREF="#sga">SGA</A></li>' from dual;
select '<li><A HREF="#dat">Datafiles</A></li>' from dual;
select '<li><A HREF="#roll">Rollbacks</A></li>' from dual;
select '<li><A HREF="#log">Log Files</A></li>' from dual;
select '<li><A HREF="#inv">Invalid Objects</A></li>' from dual;
select '</ul><td><ul>' from dual;
select '<li><A HREF="#usr">Users</A></li>' from dual;
select '<li><A HREF="#sess">Sessions</A></li>' from dual;
select '<li><A HREF="#sql">Running SQL</A></li>' from dual;
select '<li><A HREF="#stat">Performance Statistics</A></li>' from dual;
select '<li><A HREF="#job">Scheduled Jobs</A></li>' from dual;
select '<li><A HREF="#dbl">Remote Database links</A></li>' from dual;
select '<li><A HREF="#par">Tuning Parameters</A></li>' from dual;
select '<li><A HREF="#nls">NLS Settings</A></li>' from dual;
select '</ul></table><p><hr>' from dual;
 
select '<P>Statistics generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
from dual;
 
select 'by: '||user
from dual;

select 'using: <I><b>ora2html.sql</b> v.1.0.22c (Fast)'
from dual;
select '<br>Software by ' from dual;
select '<A HREF="https://meoshome.it.eu.org/">Meo</A></I><p>'
from dual;
 
select '<hr><P><A NAME="status"></A>' "Status" from dual;
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>'
 from dual;
select '<tr><td><b>Item</b>',
 '<td><b>Value</b>'
from dual;

select '<tr><td>'||' Instance :', '<! 10>',
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
 '<td >'|| created
from v$database
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
select '<tr><td>'||' Defined Schemata :', '<! 32>',
 '<td align="right">'||to_char(count(distinct owner),'999999999')
from dba_objects
where owner not in ('SYS', 'SYSTEM', 'SCOTT')
and object_type = 'TABLE'
union
select '<tr><td>'||' Defined Tables :', '<! 34>',
 '<td align="right">'||to_char(count(*),'999999999999')
from dba_objects
where owner not in ('SYS', 'SYSTEM', 'SCOTT')
and object_type = 'TABLE'
union
select '<tr><td>'||' Defined Users :', '<! 30>',
 '<td align="right">'||to_char(count(*),'999999999999')
from sys.dba_users
union
select '<tr><td>'||' Sessions :', '<! 40>',
 '<td align="right">'||to_char(count(*),'999999999999')
from v$session
union
select '<tr><td>'||' Sessions (active) :', '<! 42>',
 '<td align="right">'||to_char(count(*),'999999999999')
from v$session
where status='ACTIVE'
and type='USER'
order by 2;

select '</table><p><hr>' from dual;


select '<P><A NAME="ver"></A>' from dual;
select '<P><table border="2"><tr><td><b>Versions</b></td></tr>' from dual;
select '<tr><td>'||banner||' </tr></td>' version from sys.v_$version;
select '</table><p><hr>' from dual;

select '<P><A NAME="tbs"></A>' from dual;
select '<P><table border="2"><tr><td><b>Tablespaces</b></td></tr>' from dual;
select '<tr><td><b>Tablespace',
 '<td><b>Total</b>'
from dual;
select '<tr><td>'|| a.tablespace_name tablespace,
 '<td align="right">'||to_char(sum(a.bytes),'999,999,999,999,999') total
from sys.dba_data_files a
group by a.tablespace_name
order by a.tablespace_name;
select '<tr><td>TOTAL' tablespace,
 '<td align="right">'||to_char(round(sum(a.bytes)/(1024*1024)),'999,999,999,999')||' MB' total
from sys.dba_data_files a;
select '</table><p><hr>' from dual;

set numwidth  5
select '<P><A NAME="obj"></A>' from dual;
select '<P><table border="2"><tr><td><b>Schema/Object Matrix</b></td></tr>' from dual;
select '<tr><td><b>Owner</b>',
 '<td><b> Tabs</b>',
 '<td><b> Idxs</b>',
 '<td><b> Trgs</b>',
 '<td><b> Pkgs</b>',
 '<td><b> PBod</b>',
 '<td><b> Proc</b>',
 '<td><b> Func</b>',
 '<td><b> Seqs</b>',
 '<td><b> Syns</b>',
 '<td><b> Views</b>',
 '<td><b> Type</b>',
 '<td><b> LOB</b>',
 '<td><b> Total</b>'
from dual;
select '<tr><td>'||owner owner,
 '<td align="right">'||sum(decode(object_type, 'TABLE',1,0))    tabs,
 '<td align="right">'||sum(decode(object_type, 'INDEX',1,0))    idxs,
 '<td align="right">'||sum(decode(object_type, 'TRIGGER',1,0))  trgs,
 '<td align="right">'||sum(decode(object_type, 'PACKAGE',1,0))  pkgs,
 '<td align="right">'||sum(decode(object_type, 'PACKAGE BODY',1,0))  pbod,
 '<td align="right">'||sum(decode(object_type, 'PROCEDURE',1,0))  proc,
 '<td align="right">'||sum(decode(object_type, 'FUNCTION',1,0))  func,
 '<td align="right">'||sum(decode(object_type, 'SEQUENCE',1,0)) seqs,
 '<td align="right">'||sum(decode(object_type, 'SYNONYM',1,0))  syns,
 '<td align="right">'||sum(decode(object_type, 'VIEW',1,0))  viws,
 '<td align="right">'||sum(decode(object_type, 'TYPE',1,0))  typ,
 '<td align="right">'||sum(decode(object_type, 'LOB',1,0))  lobb,
 '<td align="right">'||count(*) alls
from sys.dba_objects
group by owner
order by owner;
select '<tr><td>TOTAL' total,
 '<td align="right">'||sum(decode(object_type, 'TABLE',1,0))    tabs,
 '<td align="right">'||sum(decode(object_type, 'INDEX',1,0))    idxs,
 '<td align="right">'||sum(decode(object_type, 'TRIGGER',1,0))  trgs,
 '<td align="right">'||sum(decode(object_type, 'PACKAGE',1,0))  pkgs,
 '<td align="right">'||sum(decode(object_type, 'PACKAGE BODY',1,0))  pbod,
 '<td align="right">'||sum(decode(object_type, 'PROCEDURE',1,0))  proc,
 '<td align="right">'||sum(decode(object_type, 'FUNCTION',1,0))  func,
 '<td align="right">'||sum(decode(object_type, 'SEQUENCE',1,0)) seqs,
 '<td align="right">'||sum(decode(object_type, 'SYNONYM',1,0))  syns,
 '<td align="right">'||sum(decode(object_type, 'VIEW',1,0))  viws,
 '<td align="right">'||sum(decode(object_type, 'TYPE',1,0))  typ,
 '<td align="right">'||sum(decode(object_type, 'LOB',1,0))  lobb,
 '<td align="right">'||count(*) alls
from sys.dba_objects;
select '</table><p><hr>' from dual;

select '<P><A NAME="sga"></A>' from dual;
select '<P><table border="2"><tr><td><b>SGA</b></td></tr>' from dual;
select '<tr><td><b>SGA element</b>', '<td><b>Bytes</b>' from dual;
select '<tr><td>'||substr(name,1,25),
 '<td align="right">'||to_char(value,'999,999,999,999')
from sys.v_$sga
order by value desc;
select '</table><p><hr>' from dual;

select '<P><A NAME="dat"></A>' from dual;
select '<P><table border="2"><tr><td><b>Datafiles</b></td></tr>' from dual;
select '<tr><td><b>Tablespace</b>',
 '<td><b>Datafile</b>',
 '<td><b>Bytes</b>',
 '<td><b>Read #</b>',
 '<td><b>Write #</b>'
from dual;
select '<tr><td>'||tablespace_name tablespace,
 '<td>'||file_name data_file,
 '<td align="right">'||to_char(bytes,'999,999,999,999'), 
 '<td align="right">'||to_char(phyrds,'999,999,999,999') "Read #", 
 '<td align="right">'||to_char(phywrts,'999,999,999,999') "Write #"
from sys.dba_data_files, v$filestat
where file_id=file#
order by tablespace_name,file_name;
select '</table><p>' from dual;
select '<p><hr>' from dual;

set numwidth  8
select '<P><A NAME="roll"></A>' "Rollbacks" from dual;
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
select '</table><p><hr>' from dual;

select '<P><A NAME="log"></A>' from dual;
select '<P><table border="2"><tr><td><b>Log Files</b></td></tr>' from dual;
select '<tr><td><b>Log File</b>',
 '<td><b> Bytes</b>'
from dual;
select '<tr><td>'||member log_file,
       '<td align="right">'||to_char(bytes,'999,999,999,999') bytes
from sys.v_$logfile, sys.v_$log
where sys.v_$logfile.group# = sys.v_$log.group#;
select '</table><p><hr>' from dual;

select '<P><A NAME="inv"></A>' "Invalid Objects" from dual;
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
select '</table><p><hr>' from dual;

select '<P><A NAME="usr"></A>' "Users" from dual;
select '<P><table border="2"><tr><td><b>Users</b></td></tr>' from dual;
select '<tr><td><b>Username</b>',
 '<td><b>Default Tablespace</b>',
 '<td><b>Temporary Tablespace</b>'
from dual;
select '<tr><td>'||substr(username,1,25) username,
 '<td>'||substr(default_tablespace,1,25) default_tablespace,
 '<td>'||substr(temporary_tablespace,1,25) temp_tablespace
from sys.dba_users
order by username;
select '<tr><td>TOTAL<td>'||count(*) users
from sys.dba_users;
select '</table><p><hr>' from dual;

select '<P><A NAME="sess"></A>' "Sessions" from dual;
select '<P><table border="2"><tr><td><b>Current sessions</b></td></tr>'
 from dual;
select '<tr><td><b>SID</b>',
 '<td><b>User</b>',
 '<td><b>OS User</b>',
 '<td><b>Process</b>',
 '<td><b>Type</b>',
 '<td><b>Status</b>',
 '<td><b>Command</b>',
 '<td><b>Program</b>'
from dual;
 
select  
 '<tr><td>'|| s.sid||','||s.serial# sid, 
 '<td>'||s.schemaname username,  
 '<td>'||s.osuser os_user,
 '<td>'||p.spid process,
 '<td>'||s.type type,
 '<td>'||s.status status,
 '<td>'||decode(s.command, 1, 'Create table',2,'Insert', 3, 'Select',
  4,'Create cluster',5,'Alter cluster',6,'Update',7,'Delete',
  8,'Drop',9,'Create index',10,'Drop index',11,'Alter index',
  12,'Drop table',15,'Alter table', 17,'Grant',18,'Revoke',
  19,'Create synonym',20,'Drop synonym',21,'Create view',
  22,'Drop view',26,'Lock table',27,'No operation',28,'Rename',
  29,'Comment',30,'Audit',31,'Noaudit',32,'Create ext. database',
  33,'Drop ext. database',34,'Create database',35,'Alter database',
  36,'Create rollback segment',37,'Alter rollback segment',
  38,'Drop rollback segment',39,'Create tablespace',
  40,'Alter tablespace',41,'Drop tablespace',42,'Alter session',
  43,'Alter user',44,'Commit',45,'Rollback',46,'Savepoint','Other') Command,
 '<td>'||substr(s.program,1,25) program
from v$process p, v$session s
where s.paddr = p.addr
order by s.type, s.sid;
select '</table><p><hr>' from dual;

select '<P><A NAME="sql"></A>' "Current SQL" from dual;
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
  '<td>'||q.sql_text sql
from v$session s, v$sql q
where s.sql_address=q.address
and   s.type <> 'BACKGROUND'
and   s.status = 'ACTIVE'
and   s.username <> 'SYS'
order by s.sid;
select '</table><p><hr>' from dual;

select '<P><A NAME="stat"></A><P>' from dual;
select '<P><table border="2"><tr><td><b>Statistics</b><tr><td><pre>' from dual;
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
select 'I1) Logon: '||to_char(value)  
 from v$sysstat
 where name in ('logons cumulative')
 union
select 'I2) Commit: '||to_char(value)  
 from v$sysstat
 where name in ('user commits')
 union
select 'I3) Rollback: '||to_char(value)  
 from v$sysstat
 where name in ('user rollbacks')
;
select '</pre></table><p><hr>' from dual;


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
from dba_jobs
where rownum<40;
select '<tr><td>...</table>' from dual;

select '<P><table border="2"><tr><td><b>Scheduler Jobs</b></td></tr>'
 from dual;
select '<tr><td><b>Job Name</b>',
 '<td><b>User</b>',
 '<td><b>Interval</b>',
 '<td><b>Command</b>',
 '<td><b>Count</b>',
 '<td><b>Last Duration</b>'
from dual;
select '<tr><td>'||job_name||'<td>'||owner||'<td>'||repeat_interval||'<td>'||job_action,
       '<td>'||run_count||'<td>'||last_run_duration
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

select '<P><table border="2"><tr><td><b>Data Pump Jobs</b></td></tr>'
 from dual;
select '<tr><td><b>Owner</b>',
 '<td><b>Job Name</b>',
 '<td><b>State</b>'
from dual;
select '<tr><td>'||owner_name||'<td>'||job_name||'<td>'||state
from dba_datapump_jobs;
select '</table>' from dual;
select '<p><hr>' from dual;

select '<P><A NAME="dbl"></A>' "Remote Database Links" from dual;
select '<P><table border="2"><tr><td><b>Database Links</b></td></tr>'
 from dual;
select '<tr><td><b>Owner</b><td><b>DB Link</b>',
 '<td><b>User</b>',
 '<td><b>Instance</b>'
from dual;
select '<tr><td>'||owner||'<td>'||db_link||'<td>'||username||'<td>'||host
from dba_db_links
order by host, username, owner, db_link;
select '</table><p><hr>' from dual;

select '<P><A NAME="par"></A>' "Oracle Parameters" from dual;
select '<P><table border="2"><tr><td><b>Oracle Parameters</b></td></tr>'
 from dual;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||name||'<td>'||value
from v$parameter
where isdefault ='FALSE'
order by name; 
select '</table><p><hr>' from dual;

select '<P><A NAME="nls"></A>' "NLS Settings" from dual;
select '<P><table border="2"><tr><td><b>NLS Settings</b></td></tr>'
 from dual;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||name||'<td>'||value$
from sys.props$
where name like 'NLS%CHARACTER%'
order by name; 
select '</table><p><hr>' from dual;

select '<hr> <P>Statistics generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||'<P>' 
from dual;

select 'For more info visit' from dual;
select '<A HREF="https://meoshome.it.eu.org/">this site</A>' from dual;
select 'or contact' from dual;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo</A>.<p></body></html>' from dual;

spool off
set newpage 1

exit
