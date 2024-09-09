REM Programma:	grasyn.sql
REM Easy SQL*plus script to generate GRANT and SYNONYMS for an other Oracle user
REM 1.0.1 - 1 Jan 1990 - mail@meo.bogliolo.name
REM
REM Notes:

set lines 132
set heading off
set feedback off
set verify off

select 'Running GRANT script for &&Grantee ;'
from dual;

spool giveGrant.sql
select 'grant select, insert, update, delete on '||table_name||' to &Grantee ;'
 from tabs;
select 'grant execute on '||object_name||' to &Grantee ;'
 from obj
 where object_type in ('PACKAGE', 'PROCEDURE', 'FUNCTION');
spool off


spool createSyn.sql
select 'create synonym '||table_name||' for '||user||'.'||table_name||'  ;'
 from tabs;
select 'create synonym '||object_name||' for '||user||'.'||object_name||'  ;'
 from obj
 where object_type in ('PACKAGE', 'PROCEDURE', 'FUNCTION');
spool off

