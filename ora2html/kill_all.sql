set heading off
set termout off
set verify off
set echo off
set feedback off

ALTER SYSTEM enable restricted session;

ALTER SYSTEM checkpoint global;

spool kill_all.sql

SELECT 'execute kill_session('|| chr(39) || sid || chr(39) || ',' || chr(39) || serial# || chr(39) || ');'
FROM gv_$session
WHERE (username IS NOT NULL OR username <> 'SYS');

spool off

@kill_all