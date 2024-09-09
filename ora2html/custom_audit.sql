REM Programma:	audit.sql
REM 		Controllo AUDIT del database
REM Versione:	2.2.2
REM Autori:	Fabio Maggiora, meo
REM Data:	17-NOV-96
REM Note:
REM Modifiche:	17-DEC-96 meo@archesis.it
REM		Aggiunti commenti
REM Modifiche:	9-APR-97 meo@archesis.it
REM		Aggiunta la visualizzazione dei parametri di INIT.ORA
REM Modifiche:	14-APR-97 meo@archesis.it
REM		Aggiunti commenti "pubblicitari"
REM Modifiche:	26-MAR-98 meo@archesis.it
REM		Aggiunte maggiori informazioni
REM
REM Modifiche:	1-APR-14 meo@xenialab.it
REM		Integrato come plugin custom in ora2html, aggiornato con le nuove funzionalita'
rem		fga: all_audit_policies

column parameter format A30
column value format A60
column username format A20
column os_username format A11
column owner format A10
column grantee format A10
column object format A20
column privilege format A25
column statement format A25
column success format A10
column failure format A10
column LOGIN_TIME format a20
column LOGOUT_TIME format a20
column time_stamp format a20
column alt format a3
column aud format a3
column com format a3
column del format a3
column gra format a3
column ind format a3
column ins format a3
column loc format a3
column ren format a3
column sel format a3
column upd format a3
column ref format a3
column exe format a3
column cre format a3
column rea format a3
column wri format a3
column fbk format a3
column returncode format a20
set lines 132
set heading off
SELECT '<p><a id="custF"></a><a id="aud"></a><h2>Oracle RDBMS SECURITY AUDITING</h2><pre>' from dual; 
 
SELECT '<b>Configuration</b>' from dual; 
select 'System Parameters' from dual;
set heading on
select substr(name,1,20) parameter, substr(value,1,60) value
from v$parameter
where upper(name) like '%AUDIT%';

set heading off
select 'Privileges' from dual;
set heading on
select substr(nvl(user_name,'*'),1,10) username,
       substr(privilege,1,25) privilege,
       success,failure
from sys.dba_priv_audit_opts;

set heading off
select 'Statements' from dual;
set heading on
select substr(nvl(user_name,'*'),1,10) username,
       substr(audit_option,1,25) statement,
       success,failure
from sys.dba_stmt_audit_opts;

set heading off
select 'Objects' from dual;
set heading on
select substr(owner,1,10) owner,
       substr(object_name,1,20) object,object_type,
       alt,aud,com,del,gra,ind,ins,loc,ren,sel,upd,ref,exe,cre,rea,wri
  from sys.dba_obj_audit_opts 
 where alt != '-/-' 
    or aud != '-/-'
    or com != '-/-'
    or del != '-/-'
    or gra != '-/-'
    or ind != '-/-'
    or ins != '-/-'
    or loc != '-/-'
    or ren != '-/-'
    or sel != '-/-'
    or upd != '-/-'
    or ref != '-/-'
    or exe != '-/-'
order by object_name;

set heading off
select 'Defauts' from dual;
set heading on
SELECT * FROM ALL_DEF_AUDIT_OPTS;

set heading off
select 'Management' from dual;
set heading on
rem Available with 11gR2 
select parameter_name parameter, parameter_value value, audit_trail
from   dba_audit_mgmt_config_params;

set heading off
select '<b>AUDITING LOG</b>' from dual;
select 'Connections' from dual;
set heading on
select substr(username,1,20) username,
       substr(to_char(timestamp,'YYYY-MON-DD HH24:MI:SS'),1,20) login_time,
       substr(to_char(LOGOFF_TIME,'YYYY-MON-DD HH24:MI:SS'),1,20) logout_time,
       substr(action_name,1,25) statement,substr(os_username,1,13) os_username,
       sessionid,
       substr(returncode||decode(returncode,
          '1004','-Connessione errata',
          '1005','-Password nulla',
          '1017','-Password errata',
          '1045','-Privilegi insufficienti',
          ''),1,20) returncode
from   sys.dba_audit_session
where  timestamp > sysdate-7
  and  username not in ('DBSNMP')
  and  returncode<>0
order  by timestamp;

set heading off
select 'Statements' from dual;
set heading on
select substr(username,1,10) username,
       substr(to_char(timestamp,'YYYY-MON-DD HH24:MI:SS'),1,20) time_stamp,
       substr(action_name,1,25) statement,substr(obj_name,1,13) object,
       substr(grantee,1,10) grantee,
       sessionid,
       substr(returncode||decode(returncode,
          '1031','-Privilegi insufficienti',
          '1917','-Utente inesistente',
          '1951','-Ruolo non presente',
          ''),1,20) returncode
from   sys.dba_audit_statement
where  timestamp > sysdate-7
  and  username not in ('DBSNMP')
order  by timestamp;

set heading off
select 'Objects' from dual;
set heading on
select substr(username,1,10) username,
       substr(to_char(timestamp,'YYYY-MON-DD HH24:MI:SS'),1,20) time_stamp,
       substr(action_name,1,25) statement,
       substr(obj_name,1,13) object,substr(owner,1,10) owner,
       sessionid,
       substr(returncode||decode(returncode,
           '904','-Nome colonna non valido',
           '922','-Opzione non valida',
           '955','-Oggetto esistente',
           '988','-Password non valida',
          '1935','-Manca il nome utente',
          '2004','-Violazione sicurezza',
          '2157','-Opzione non specificata',
          '2220','-MINEXTENTS non valido',
          ''),1,20) returncode
from   sys.dba_audit_object
where  timestamp > sysdate-7
  and  username not in ('DBSNMP')
order  by timestamp;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
