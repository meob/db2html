REM Programma:	whodoRAC.sql
REM		Who do What on Oracle RAC
REM 		Chi fa cosa su Oracle RAC
REM Versione:	1.0.5
REM Autore:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM Data:	1-JAN-14

set space 1
set pagesize 9999
set linesize 180
set heading on
set feedback off
ttitle off
set arraysize 1
set newpage 2
column bytes format 999,999,999
column lock_mode format a15
column holding_session format a30
column request format a10
column inst_id format a6
column oracle_user format a10
column os_user format a12
column process format a10
column username format a20
column exec  format 999999999
column parse format 999999999
column read  format 999999999
column get   format 99999999999
column sid_serial_inst format a16
column sid   format 99999
column command format a12
column machine format a10
column program format a40
column sql1 format a128
column sql2 format a68
column lock_id format a40
column statistics format a78
column parameter format a20
column value format a60
column noOut noprint
spool whodoRAC.lst

select '1. Date :' parameter, to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') value
from dual
union
select '2. Database :' , value
from v$parameter
where name like 'db_name'
union
select '3. Version :', substr(banner,instr(banner, '.',1,1)-2,11)
from sys.v_$version
where banner like 'Oracle%'
union
select '4. DB Size (GB) :', to_char(sum(bytes)/(1024*1024*1024),'999,999,999,999,999')
from sys.dba_data_files
union
select '5. SGA (MB) :', to_char(sum(value)/(1024*1024),'999,999,999,999,999')
from sys.v_$sga
union
select '6. Node - SID :', host_name||' - '||instance_name
from gv$instance
union
select '7. Log archiving :', log_mode
from v$database
order by 1,2;

select  
 s.sid||','||s.serial#||',@'||s.inst_id sid_serial_inst, 
 s.schemaname username,  
 s.osuser os_user,
 p.spid process,
 s.type type,
 s.status status,
 decode(s.command, 1, 'Create table',2,'Insert', 3, 'Select',
  4,'Create cluster',5,'Alter cluster',6,'Update',7,'Delete',
  8,'Drop',9,'Create index',10,'Drop index',11,'Alter index',
  12,'Drop table',15,'Alter table', 16, 'Drop Seq.', 17,'Grant',18,'Revoke',
  19,'Create synonym',20,'Drop synonym',21,'Create view',
  22,'Drop view',26,'Lock table',27,'No operation',28,'Rename',
  29,'Comment',30,'Audit',31,'Noaudit',32,'Create ext. database',
  33,'Drop ext. database',34,'Create database',35,'Alter database',
  36,'Create rollback segment',37,'Alter rollback segment',
  38,'Drop rollback segment',39,'Create tablespace',
  40,'Alter tablespace',41,'Drop tablespace',42,'Alter session',
  43,'Alter user',44,'Commit',45,'Rollback',46,'Savepoint',
  23,'Validate index',24,'Create procedure',25,'Alter procedure',
  47,'PL/SQL Exec',48,'Set Transaction',
  60,'Alter trigger',62,'Analyze Table',
  63,'Analyze index',71,'Create Snapshot Log',
  72,'Alter Snapshot Log',73,'Drop Snapshot Log',
  74,'Create Snapshot',75,'Alter Snapshot',
  76,'Drop Snapshot',85,'Truncate table',
  0,'No command',
   'Other') Command,
 to_char(logon_time, 'YYYY-MM-DD HH24:MI:SS') logon,
 substr(s.program,1,40) program
from gv$process p, gv$session s
where s.paddr = p.addr
and   s.type <> 'BACKGROUND'
order by s.status, s.type, s.sid;

select l.sid,
 l.type,
 decode(l.lmode, 0, 'WAITING', 1,'Null', 2, 'Row Share', 
  3, 'Row Exclusive', 4, 'Share',
  5, 'Share Row Exclusive', 6,'Exclusive', l.lmode) lock_mode, 
 decode(l.request, 0,'HOLD', 1,'Null', 2, 'Row Share',
  3, 'Row Exclusive', 4, 'Share', 5, 'Share Row Exclusive',
  6,'Exclusive', l.request) request, 
 substr(l.id1 || '-'|| l.id2,1,12) lock_id
from gv$lock l
where l.lmode=0
order by 1;

SELECT gvh.SID||','||gvs.serial#||',@'||gvh.inst_id holding_session, 'LOCKS' locks,
       gvw.SID sessid, gvw.inst_id instance_id
FROM gv$lock gvh, gv$lock gvw, gv$session gvs
WHERE (gvh.id1, gvh.id2) IN
      (SELECT id1, id2 FROM gv$lock
        WHERE request = 0
       INTERSECT
       SELECT id1, id2 FROM gv$lock
        WHERE lmode = 0)
AND gvh.id1 = gvw.id1
AND gvh.id2 = gvw.id2
AND gvh.request = 0
AND gvw.lmode = 0
AND gvh.SID = gvs.SID
AND gvh.inst_id = gvs.inst_id
order by gvw.SID;

select count(*), event waiting_on_event
from gv$SESSION_WAIT 
group by event
order by 1 desc;

break on sid on exec on parse on read on get
select distinct s.sid,
  sum(q.executions) exec,
  sum(q.parse_calls) parse,
  sum(q.disk_reads) read,
  sum(q.buffer_gets) get,
  t.sql_text sql2, t.piece noOut
from gv$process p, gv$session s, gv$sql q, gv$sqltext t
where p.addr=s.paddr
and   s.sql_address=q.address
and   q.address=t.address
and   s.type <> 'BACKGROUND'
group by s.sid, t.sql_text, t.piece
order by s.sid, t.piece;
clear breaks

select 'A)  Hit ratio buffer cache (>80%): '||
  to_char(round(1-(
   sum(decode(name,'physical reads',1,0)*value) 
   /(sum(decode(name,'db block gets',1,0)*value) 
   +sum(decode(name,'consistent gets',1,0)*value))
  ), 3)*100) || '%'  statistics
 from gv$sysstat
 where name in ('db block gets', 'consistent gets', 'physical reads')
 union
select 'B1) Misses library cache (<1%): '
  ||to_char(round(sum(reloads)/sum(pins)*100, 3)) || '%' 
 from gv$librarycache
 union
select 'B2) Misses dictionary cache (<10%): '
  ||to_char(round(sum(getmisses)/sum(gets)*100, 3)) || '%' 
 from gv$rowcache
 union
select 'C1) System undo header frequence (<1%): '
  ||to_char(round(avg(count)/sum(value)*100, 3)) || '%' 
 from gv$waitstat w, gv$sysstat s
 where w.class='system undo header' and
  name in ('db_block_gets', 'consistent gets')
 union
select 'C2) System undo block frequence (<1%): '
  ||to_char(round(avg(count)/sum(value)*100, 3)) || '%' 
 from gv$waitstat w, gv$sysstat s
 where w.class='system undo block' and
  name in ('db_block_gets', 'consistent gets')
 union
select 'C3) Undo header frequence (<1%): '
  ||to_char(round(avg(count)/sum(value)*100, 3)) || '%' 
 from gv$waitstat w, gv$sysstat s
 where w.class='undo header' and
  name in ('db_block_gets', 'consistent gets')
 union
select 'C4) Undo block frequence (<1%): '
  ||to_char(round(avg(count)/sum(value)*100, 3)) || '%' 
 from gv$waitstat w, gv$sysstat s
 where w.class='undo block' and
  name in ('db_block_gets', 'consistent gets')
 union
select 'D @'||inst_id||')  Redo log space req. (near 0): '||to_char(value)  
 from gv$sysstat
 where name ='redo log space requests'
 union
select 'E1 @'||inst_id||') Hit ratio redo alloc (<1%): '
  ||decode(gets,0,'NA',to_char(round(misses/gets*100, 3)) || '%' )
 from gv$latch
 where latch#=15
 union
select 'E2) Hit ratio immediate redo alloc (<1%): '
  ||decode(immediate_gets,0,'NA',
   to_char(round(immediate_misses/immediate_gets*100, 3)) || '%' )
 from gv$latch
 where latch#=15
 union
select 'E3) Hit ratio redo copy (<1%): '
  ||decode(gets,0,'NA',to_char(round(misses/gets*100, 3)) || '%') 
 from gv$latch
 where latch#=16
 union
select 'E4) Hit ratio immediate redo copy (<1%): '
  ||decode(immediate_gets,0,'NA',
   to_char(round(immediate_misses/immediate_gets*100, 3)) || '%' )
 from gv$latch
 where latch#=16
 union
select 'F)  Free list contention (<1%): '
  || to_char(round(count/value*100, 3)) || '%' 
 from gv$waitstat w, gv$sysstat s
 where w.class='free list' and
  name in ('consistent gets')
 union
select 'G1 @'||inst_id||') Sorts in memory: '||to_char(value)  
 from gv$sysstat
 where name in ('sorts (memory)')
 union
select 'G2 @'||inst_id||') Sorts on disk: '||to_char(value)  
 from gv$sysstat
 where name in ('sorts (disk)')
 union
select 'H1 @'||inst_id||') Short tables full scans: '||to_char(value)  
 from gv$sysstat
 where name in ('table scans (short tables)')
 union
select 'H2 @'||inst_id||') Long tables full scans: '||to_char(value)  
 from gv$sysstat
 where name in ('table scans (long tables)')
 union
select 'I1 @'||inst_id||') Logon: '||to_char(value)  
 from gv$sysstat
 where name in ('logons cumulative')
 union
select 'I2 @'||inst_id||') Commit: '||to_char(value)  
 from gv$sysstat
 where name in ('user commits')
 union
select 'I3 @'||inst_id||') Rollback: '||to_char(value)  
 from gv$sysstat
 where name in ('user rollbacks')
;

SELECT event, SUM(total_waits) total_waits, ROUND(SUM(time_waited_micro) / 1000000, 2) time_waited_secs,       ROUND(SUM(time_waited_micro)/1000 / SUM(total_waits), 2) avg_ms  FROM gv$system_event WHERE wait_class <> 'Idle' 	AND( event LIKE 'gc%block%way' 	    OR event LIKE 'gc%multi%'	    OR event like 'gc%grant%'	    OR event = 'db file sequential read') GROUP BY event HAVING SUM(total_waits) > 0 ORDER BY event;

SELECT wait_class time_category ,ROUND ( (time_secs), 2) time_secs,       ROUND ( (time_secs) * 100 / SUM (time_secs) OVER (), 2) pctFROM (SELECT wait_class wait_class,             sum(time_waited_micro) / 1000000 time_secs        FROM gv$system_event       WHERE wait_class <> 'Idle'         AND time_waited > 0       GROUP BY wait_class      UNION SELECT 'CPU', ROUND ((SUM(VALUE) / 1000000), 2) time_secs        FROM gv$sys_time_model       WHERE stat_name IN ('background cpu time', 'DB CPU'))ORDER BY time_secs DESC;
set heading off


set heading off
set space 0
set newpage 1
select 'WhoDo RAC? Oracle Report generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') ||
 ' by: '||user 
from dual;
select 'whodoRAC.sql v.1.0.5 - Software by Meo Bogliolo (c)'  from dual;
spool off
set heading on
host cp -p whodoRAC.lst whodo.`date +"%Y%m%d%H%M"`.lst

