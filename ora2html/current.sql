REM Programma:	current.sql
REM 		Stato corrente di un'istanza Oracle
REM Versione:	1.0.7
REM Autore:	Meo Bogliolo mail@meo.bogliolo.name
REM Data:	17-JAN-98
REM Note:
REM Modifiche:	
REM		18-JAN-98 mail@meo.bogliolo.name
REM		Aggiunti commenti
REM
REM		26-MAR-98 mail@meo.bogliolo.name
REM		Aggiunti lockid
REM
REM		26-APR-98 mail@meo.bogliolo.name
REM		Aggiunti gli oggetti acceduti
REM
REM		 7-JUL-98 
REM		Aggiunto l'accesso ai rollback
REM
REM		 6-APR-00
REM		Aggiunta select da v$sqltext per avere il comando in corso completo
REM
REM		 1-APR-11
REM		Formattazione a 132 caratteri, commentato l'elenco di oggetti
REM

set feedback off
set space 1
set pagesize 9999
set linesize 132
set heading off
set arraysize 1
ttitle off
set newpage 2
column bytes format 999,999,999
column lock_mode format a15
column request format a10
column oracle_user format a16
column os_user format a16
column username format a12
column sid format 9999
column command format a12
column machine format a10
column program format a23
column piece format 999

spool current

select to_char(sysdate,'DD-MON-YYYY HH24:MI') ||
  '   Oracle Instance Status'
from dual;

select 'CURRENT.SQL v.1.0.7 by Meo' disclaimer
from dual;

select 'Oracle Instance: ', substr(value,1,20)
from sys.v$parameter     
where name ='db_name';

set heading on

select  s.sid, 
 s.schemaname username,  
 s.osuser os_user,
 p.spid process,
 substr(s.type,1,1) type,
 decode(s.command, 1, 'Create table',2,'Insert', 3, 'Select',
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
 substr(s.program,1,23) program
from v$process p, v$session s
where s.paddr = p.addr
order by s.sid;


select s.sid,
 s.schemaname username,
 decode(s.command, 1, 'Create table', 2,'Insert', 3, 'Select',
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
 l.type,
 decode(l.lmode, 0, 'WAITING', 1,'Null', 2, 'Row Share', 
  3, 'Row Exclusive', 4, 'Share',
  5, 'Share Row Exclusive', 6,'Exclusive', l.lmode) lock_mode, 
 decode(l.request, 0,'HOLD', 1,'Null', 2, 'Row Share',
  3, 'Row Exclusive', 4, 'Share', 5, 'Share Row Exclusive',
  6,'Exclusive', l.request) request, 
 substr(id1 || '-'|| id2,1,12) lock_id
from v$lock l, v$session s
where l.sid=s.sid
and   s.type <> 'BACKGROUND'
order by s.sid;

column program format a30
select 	s.sid,
	s.username,
	p.username os_user, 
	p.spid process,
	s.program, 
	substr(s.status,1,6) status,
	q.executions exec,
	q.parse_calls parse,
	q.disk_reads read,
	q.buffer_gets get  --,     6/4/00 ndp
	---- t.sql_text sql        6/4/00 ndp
from v$process p, v$session s, v$sql q
where p.addr=s.paddr
and   s.sql_address=q.address
and   s.type <> 'BACKGROUND'
order by s.sid;
rem	q.rows_processed rows,
rem	q.optimizer_mode mode,

break on sid
select 	distinct s.sid, t.piece,
	t.sql_text sql
from v$process p, v$session s, v$sql q, v$sqltext t
where p.addr=s.paddr
and   s.sql_address=q.address
and   q.address=t.address
and   s.type <> 'BACKGROUND'
order by s.sid, t.piece;
clear breaks

select  r.name rollback_name,
	l.sid sid,
	s.schemaname username,
	s.osuser os_user
from v$lock l, v$session s, v$rollname r
where l.sid = s.sid(+)
and   trunc(l.id1(+)/65535) = r.usn
and   l.type(+) = 'TX'
and   l.lmode(+) = 6
order by r.name;
 
REM Quite long and not always useful
REM 
REM select sid, 
REM	type,
REM	substr(owner||'.'||object,1,50) object
REM from v$access
REM order by sid;

spool off
exit
