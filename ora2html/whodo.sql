REM Programma:	WhoDo.sql
REM		Who do What on Oracle
REM 		Chi fa cosa su Oracle
REM Versione:	1.0.3
REM Autore:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM Data:	1-APR-09

set space 1
set pagesize 9999
set linesize 130
set heading on
set feedback off
ttitle off
set arraysize 1
set newpage 2
column bytes format 999,999,999
column lock_mode format a15
column request format a10
column oracle_user format a10
column os_user format a14
column process format a10
column username format a18
column exec  format 9999999
column parse format 99999999
column read  format 999999999
column get   format 999999999
column sid_ser format a16
column sid   format 99999
column command format a12
column machine format a16
column terminal format a16
column program format a30
column sql1 format a128
column sql2 format a80
column lock_id format a40
column statistics format a78
column parameter format a20
column value format a20
spool whodo.lst

select '1. Date :' parameter, to_char(sysdate,'YYYY-MM-DD HH:MI:SS') value
from dual
union
select '2. Instance :' , value
from v$parameter
where name like 'db_name'
union
select '3. Version :', substr(banner,instr(banner, '.',1,1)-2,11)
from sys.v_$version
where banner like 'Oracle%'
union
select '4. DB Size (GB) :', to_char(sum(bytes)/(1024*1024*1024),'999,999,999,999')
from sys.dba_data_files
union
select '5. SGA (MB) :', to_char(sum(value)/(1024*1024),'999,999,999,999')
from sys.v_$sga
union
select '6. Log archiving :', log_mode
from v$database;

select  
 s.sid||','||s.serial# sid_ser, 
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
 substr(s.program,1,25) program
from v$process p, v$session s
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
from v$lock l
where l.lmode=0
order by 1;

select /*+use_nl(a,b,c) ordered*/ distinct a.sid||','||a.serial# sid_ser,
 a.username, a.terminal, a.machine, a.program, c.hash_value, c.sql_text
from v$session a, v$process b, v$sql c
where a.paddr = b.addr(+)
and a.sql_hash_value = c.hash_value
and a.sql_address = c.address
and a.status = 'ACTIVE'
and a.type = 'USER';

break on sid on exec on parse on read on get
select 	s.sid,
  q.executions exec,
  q.parse_calls parse,
  q.disk_reads read,
  q.buffer_gets get,
  t.sql_text sql2
from v$process p, v$session s, v$sql q, v$sqltext t
where p.addr=s.paddr
and   s.sql_address=q.address
and   q.address=t.address
and   s.type <> 'BACKGROUND'
order by s.sid, t.piece;
clear breaks

select l.sid,
 l.type,
 decode(l.lmode, 0, 'WAITING', 1,'Null', 2, 'Row Share', 
  3, 'Row Exclusive', 4, 'Share',
  5, 'Share Row Exclusive', 6,'Exclusive', l.lmode) lock_mode, 
 decode(l.request, 0,'HOLD', 1,'Null', 2, 'Row Share',
  3, 'Row Exclusive', 4, 'Share', 5, 'Share Row Exclusive',
  6,'Exclusive', l.request) request, 
 substr(id1 || '-'|| id2,1,12) lock_id
from v$lock l
where l.lmode=0 or l.request=0
order by l.sid;

select 'A)  Hit ratio buffer cache (>80%): '||
  to_char(round(1-(
   sum(decode(name,'physical reads',1,0)*value) 
   /(sum(decode(name,'db block gets',1,0)*value) 
   +sum(decode(name,'consistent gets',1,0)*value))
  ), 3)*100) || '%'  statistics
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

set heading off
set space 0
set newpage 1
select 'WhoDo? Oracle Report generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') ||
 ' by: '||user 
from dual;
select 'whodo.sql v.1.0.3 - Software by Meo Bogliolo (c)'  from dual;
spool off
set heading on
host cp -p whodo.lst whodo.`date +"%Y%m%d%H%M"`.lst
