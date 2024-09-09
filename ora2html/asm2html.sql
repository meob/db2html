REM Programma:	asm2html.sql
REM 		Configurazione di Oracle +ASM in formato HTML
REM Autore:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM Data:	1-APR-12
REM Versione:	1.0.2 	1-SEP-12
REM Versione:	1.0.3 	1-JAN-14 A small bug fixed
REM Versione:	1.0.4 	14-FEB-14 More totals (a) optional plugin: ASM object tree; (b) ASM clients
REM Versione:	1.0.5 	15-AUG-16 Performance statistics
REM Note:	

set space 1
set pagesize 9999
set linesize 120
set heading off
set feedback off
set timing off
ttitle off
spool ora2html.htm

select '<html> <head> <title>', value,
  ' - asm2html Oracle Statistics</title> </head>'||
 '<body>'
from v$parameter
where name = 'db_unique_name';

select '<h1 align=center>'||substr(value,1,25)||'</h1>'
from v$parameter
where name = 'db_unique_name';

select '<P><A NAME="top"></A>' from dual;
select '<table><tr><td><ul>' from dual;
select '<li><A HREF="#status">Summary Status</A></li>' from dual;
select '<li><A HREF="#asm">ASM Configuration</A></li>' from dual;
select '<li><A HREF="#use">ASM Usage</A></li>' from dual;
select '<li><A HREF="#cust">Performance Statistics</A>' from dual;
select '</ul><td><ul>' from dual;
select '<li><A HREF="#sess">Processes</A></li>' from dual;
select '<li><A HREF="#par">Tuning Parameters</A></li>' from dual;
select '<li><A HREF="#os">Operating System Infos</A></li>' from dual;
select '<li><A HREF="#asm_tree">Object Tree</A> [Optional]</li>' from dual;
select '</ul></table><p><hr>' from dual;
select '<P>Statistics generated on: '|| to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
from dual;
 
select 'by: '||user
from dual;

select 'using: <I><b>asm2html.sql</b> v.1.0.6'
from dual;
select '<br>Software by ' from dual;
select '<A HREF="http://www.xenialab.it/meo/web/index5.htm#dwn">Meo Bogliolo</A></I><p>'
from dual;
 
select '<hr><P><A NAME="status"></A>' from dual;
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>' from dual;
select '<tr><td><b>Item</b>', '<td><b>Value</b>' from dual;

select '<tr><td>'||' Instance :', '<! 10>', '<td>'||value
  from v$parameter
 where name like 'db_name';
select '<tr><td>'||' Hostname :', '<! 14>', '<td>'|| host_name
  from v$instance;
select '<tr><td>'||' Clustername :', '<! 15>', '<td>'|| max(cluster_name)
  from gv$asm_client;
select '<tr><td>'||' Startup :', '<! 36>', '<td>'|| to_char(startup_time,'DD-MON-YYYY HH24:MI:SS')
  from v$instance;
select '</table><p><hr>' from dual;

select '<P><A NAME="asm"></A>' "ASM Configuration" from dual;
select '<P><table border="2">'
 from dual;

select '<tr><td><b>Disk Groups</b>' from dual;
select '<tr><td><b>Disk Group</b>',
 '<td><b>Disk Group#</b>',
 '<td><b>Type</b>',
 '<td><b>Total GB</b>',
 '<td><b>Free GB</b>',
 '<td><b>Used GB</b>',
 '<td><b>Used%</b>',
 '<td><b>Free%</b>',
 '<td><b>Allocation Unit</b>',
 '<td><b>State</b>',
 '<td><b>Offline Disks</b>',
 '<td><b>Usable GB</b>'
from dual;

select '<tr><td>'||name||'<td align="right">'||GROUP_NUMBER||'<td>'||TYPE, 
       '<td align="right">'||round(TOTAL_MB/1024)||'<td align="right">'||round(FREE_MB/1024),
       '<td align="right">'||round((TOTAL_MB-FREE_MB)/1024),
       '<td align="right">'||to_char((1-free_mb/total_mb)*100,'999.99'),
       '<td align="right">'||to_char(free_mb/total_mb*100,'999.99'),
       '<td align="right">'||ALLOCATION_UNIT_SIZE||'<td>'||STATE||'<td align="right">'||OFFLINE_DISKS,
       '<td align="right">'||round(USABLE_FILE_MB/1024)
from v$asm_diskgroup;
select '<tr><td>TOTAL<td align="right"><td>', 
       '<td align="right">'||round(sum(TOTAL_MB)/1024)||'<td align="right">'||round(sum(FREE_MB)/1024),
       '<td align="right">'||round((sum(TOTAL_MB-FREE_MB))/1024),
       '<td align="right">'||to_char((1-(sum(free_mb)/sum(total_mb)))*100,'999.99'),
       '<td align="right">'||to_char(sum(free_mb)/sum(total_mb)*100,'999.99'),
       '<td align="right"><td><td align="right">'||sum(OFFLINE_DISKS)
from v$asm_diskgroup;
select '</table><p>' from dual;

select '<P><table border="2">' from dual;
select '<tr><td><b>ASM Clients</b>' from dual;
select '<tr><td><b>Instance ID</b>',
 '<td><b>Group#</b>',
 '<td><b>Instance Name</b>',
 '<td><b>DB Name</b>',
 '<td><b>Client ID</b>',
 '<td><b>Version</b>',
 '<td><b>Status</b>'
from dual;

select '<tr><td>',INST_ID, '<td>',GROUP_NUMBER, '<td>',INSTANCE_NAME, '<td>',DB_NAME,
       '<td>',INSTANCE_NAME||':'||DB_NAME,
       '<td>',SOFTWARE_VERSION, '<td>',STATUS
from gv$asm_client;
select '</table><p><hr>' from dual;

select '<P><table border="2">' from dual;
select '<tr><td><b>Disks</b>' from dual;
select '<tr><td><b>Disk#</b>',
 '<td><b>Path</b>',
 '<td><b>Disk Group</b>',
 '<td><b>Total MB</b>',
 '<td><b>Free MB</b>',
 '<td><b>State</b>',
 '<td><b>Type</b>',
 '<td><b>Failgroup</b>',
 '<td><b>Mount Status</b>',
 '<td><b>State</b>',
 '<td><b>Header Status</b>',
 '<td><b>Mode Status</b>'
from dual;

select '<tr><td>'||d.disk_number||'<td>'||d.path||'<td>'||dg.name||'<td align="right">'||d.TOTAL_MB||'<td align="right">'||d.FREE_MB,
	'<td>'||dg.state||'<td>'||dg.type||'<td>'||d.FAILGROUP||'<td>'||d.mount_status||'<td>'||d.state,
	'<td>'||d.HEADER_STATUS||'<td>'||d.MODE_STATUS
from v$asm_diskgroup dg, v$asm_disk d
where dg.group_number=d.group_number
order by dg.name, d.disk_number;
select '<tr><td>'||d.disk_number||'<td>'||d.path||'<td>'||'<td align="right">'||d.TOTAL_MB||'<td align="right">'||d.FREE_MB,
	'<td>'||'<td>'||'<td>'||d.FAILGROUP||'<td>'||d.mount_status||'<td>'||d.state,
	'<td>'||d.HEADER_STATUS||'<td>'||d.MODE_STATUS
from  v$asm_disk d
where not exists (select 1 from v$asm_diskgroup dg where dg.group_number=d.group_number)
order by d.disk_number;
select '</table><p>' from dual;

select '<hr><P><A NAME="use"></A>' "ASM Usage" from dual;
select '<P><table border="2">'
 from dual;

select '<tr><td><b>Clients Access</b>' from dual;
select '<tr><td><b>Disk Group</b>',
 '<td><b>Instance</b>',
 '<td><b>DB Name</b>',
 '<td><b>Status</b>'
from dual;

select '<tr><td>'||a.name||'<td>'||c.instance_name||'<td>'||c.db_name||'<td>'||c.status
from v$asm_diskgroup a JOIN v$asm_client c USING (group_number)
order by a.name, c.instance_name;
select '</table><p>' from dual;

select '<p><table border=2><tr><td><b>Usage</b>' from dual;
select '<tr><td><b>Type</b>', '<td><b>Group#</b>',
 '<td><b>Total GB</b>',
 '<td><b>Bytes</b>'
from dual;
select '<tr><td>', type, '<td>', group_number,
   '<td align="right">'||to_char(round(sum(bytes)/(1024*1024*1024)),'999,999,999,999,999,999'),
   '<td align="right">'||to_char(sum(bytes),'999,999,999,999,999,999')
 from v$asm_file
 group by group_number,type
 order by group_number,type;
select '<tr><td>TOTAL', '<td>', group_number,
   '<td align="right">'||to_char(round(sum(bytes)/(1024*1024*1024)),'999,999,999,999,999,999'),
   '<td align="right">'||to_char(sum(bytes),'999,999,999,999,999,999')
 from v$asm_file
 group by group_number
 order by 2;
select '<tr><td>TOTAL<td>*',
   '<td align="right">'||to_char(round(sum(bytes)/(1024*1024*1024)),'999,999,999,999,999,999'),
   '<td align="right">'||to_char(sum(bytes),'999,999,999,999,999,999')
 from v$asm_file;
select '</table>' from dual;

select '<P><table border="2">' from dual;
select '<tr><td><b>Operations</b>' from dual;
select '<tr><td><b>Group Number</b>',
 '<td><b>Operation</b>',
 '<td><b>State</b>',
 '<td><b>Actual</b>',
 '<td><b>So far</b>',
 '<td><b>Estimated Time</b>'
from dual;

select '<tr><td>'||GROUP_NUMBER||'<td>'||OPERATION||'<td>'||STATE||'<td>'||ACTUAL||'<td>'||SOFAR||'<td>'||EST_MINUTES 
from v$asm_operation;
select '</table><hr><p>' from dual;

select '<P><A NAME="cust"></A>' "Performance Statistics" from dual;
select '<P><table border="2"><tr><td><b>Performance Statistics</b></td></tr>'
 from dual;
select '<tr><td><pre>'from dual;
column sample_time format a18
column as_diagram format a60
column wait_event format a40
column total_wait_time format a20
column wait_class format a20
column name format a40
column time_secs format a20
column pct format a10
column sample_time format a20
set lines 132

set heading off
SELECT '<a name="cust1"></a><b>Top wait event (Last Day)</b>' from dual;  
set heading on

SELECT  h.event Wait_Event, 
   to_char( SUM(h.wait_time + h.time_waited), '999,999,999,999') Total_Wait_Time
FROM  v$active_session_history h,  v$event_name e
WHERE h.sample_time BETWEEN sysdate - 1 AND sysdate
  AND h.event_id = e.event_id
  AND e.wait_class <> 'Idle'
GROUP BY h.event
HAVING SUM(h.wait_time + h.time_waited) > 0.1
ORDER BY 2 DESC;
set heading off

SELECT '<a name="cust2"></a><b>Wait Event Details</b>' from dual;  
set heading on
SELECT wait_class, NAME, to_char(ROUND(time_secs, 2),'999,999,990.00') time_secs,
   to_char(ROUND(time_secs*100 / SUM(time_secs) OVER (), 2), '990.0') pct
FROM (SELECT n.wait_class, e.event NAME, e.time_waited / 100 time_secs
       FROM  v$system_event e, v$event_name n
       WHERE n.NAME = e.event AND n.wait_class <> 'Idle'
       AND   time_waited > 0
      UNION
      SELECT 'CPU', 'server CPU', SUM(VALUE/1000000) time_secs
       FROM  v$sys_time_model
       WHERE stat_name IN ('background cpu time', 'DB CPU'))
WHERE time_secs >10
ORDER BY time_secs DESC;
set heading off

SELECT '<a name="cust3"></a><b>Activity Peaks</b> (available from 12c)' from dual;  
set heading on
select n max_sessions, to_char(t, 'DD-MON-YYYY HH24:MI:SS') sample_time
  from (select count(*) n, sample_time t from V$ACTIVE_SESSION_HISTORY group by sample_time)
 order by n desc
 fetch first 10 rows only;
set heading off

SELECT '<a name="cust4"></a><b>Diskgroup Statistics</b>' from dual;  
column name format a10;
column state format a10;
column type format a10;

set heading on
select GROUP_NUMBER, NAME, STATE, TYPE, TOTAL_MB, FREE_MB, HOT_USED_MB, COLD_USED_MB,
       REQUIRED_MIRROR_FREE_MB REQUIRED_FREE_MB, USABLE_FILE_MB
  from v$asm_diskgroup_stat;
set heading off

SELECT '<a name="cust5"></a><b>ASM Disks Statistics</b>' from dual;  
column INSTNAME format a10;

set heading on
select FAILGROUP,
       READS, WRITES, READ_TIME, WRITE_TIME, BYTES_READ, BYTES_WRITTEN,
       HOT_READS, COLD_READS
  from V$ASM_DISK_IOSTAT
order by READ_TIME+WRITE_TIME desc;

select *
  from V$ASM_DISK_IOSTAT;
set heading off
select '</pre></table><p><hr>' from dual;
set numwidth  8

select '<P><A NAME="lic"></A>' "Licensing info" from dual;
select '<P><table border="2"><tr><td><b>Licensing</b></td></tr>'
 from dual;
select '<tr><td><b>Parameter</b>',
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
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>Versions</b></td></tr>' from dual;
select '<tr><td><b>Product</b>'
from dual;
select '<tr><td>', banner from v$version;
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
select '</table><p><hr>' from dual;

select '<P><A NAME="sess"></A>' "Sessions" from dual;
select '<P><table border="2"><tr><td><b>Current sessions</b></td></tr>'
 from dual;
select '<tr><td><b>SID,serial</b>',
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
 '<td>'|| s.program
from v$process p, v$session s
where s.paddr = p.addr
order by s.type, s.sid;
select '</table><p><hr>' from dual;

select '<P><A NAME="par"></A>' "Oracle Parameters" from dual;
select '<P><table border="2"><tr><td><b>Oracle Parameters</b></td></tr>'
 from dual;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||name||'<td>'||value
from sys.v$parameter
where isdefault ='FALSE'
order by name; 
select '<tr><td><b>Hidden Parameter</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||ksppinm||'<td>'||ksppstvl
 from x$ksppcv cv, x$ksppi pi
 where cv.indx = pi.indx
 and  translate(ksppinm,'_','#') like '#%' 
 and bitand(ksppiflg/256,1) <> 1
 and ksppinm like '%optimizer%' 
 order by ksppinm;
select '</table><p><hr>' from dual;

select '<P><A NAME="os"></A>' "OS" from dual;
select '<P><table border="2"><tr><td><b>Operating System Infos</b></td></tr>'
 from dual;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>'
from dual;
select '<tr><td>'||stat_name||'<td align="right">'||to_char(value, '999,999,999,990')
from v$osstat
where stat_name in ('LOAD','PHYSICAL_MEMORY_BYTES','NUM_CPUS')
order by stat_name; 
select '</table><p><hr><pre>' from dual;

rem Uncomment the next line to enable the powerful plugin that displays the ASM objects tree
@custom_asm_tree.sql

select '</pre><hr> <P>Statistics generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||'<P>' 
from dual;

select 'For more info visit' from dual;
select '<A HREF="http://www.xenialab.it/meo/web/index5.htm">this site</A>' from dual;
select 'or contact' from dual;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo Bogliolo</A>.<p></body></html>' from dual;

spool off
set newpage 1
exit