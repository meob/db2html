--
--   Definizione Tool:
--
DEFINE _TOOL = "SCHEMA_INFO_4_EXPIMP"
DEFINE _DESCRIPTION = "Estrazione informazioni per moving schemi Oracle"
DEFINE _AUTHOR = "Gianluigi Tagliafico mailto:gltagliafico@yahoo.it"
DEFINE _VERSION = "2022-08"

-- Nota
-- Da eseguirsi da connessione al database cme utente SYS o altro utente dotato di grant sufficienti
-- necessario "GRANT SELECT ANY DICTIONARY TO utente" per utente diverso da SYS (quindi anche SYSTEM)

-- Modalità di esecuzione
-- Editare SCHEMA_INFO_4_EXPIMP.def ed impostare i parametri di esecuzione seguendo i commenti ivi presenti
-- Da command prompt (shell) eseguire connessione al db con sqlplus, quindi esecuzione dello script:
-- sqlplus USER/PASSWORD[@DBSERVICE] [as SYSDBA] @&SCHEMA_INFO_4_EXPIMP
-- Esempi:
-- sqlplus sys/manager@tst-aslto4-odb01_HTH.aslto4.piemonte.it as sysdba @SCHEMA_INFO_4_EXPIMP.sql
-- sqlplus "/ as sysdba" @SCHEMA_INFO_4_EXPIMP.sql

-- Note per Oracle 9 e precedenti
-- 1. Ignorare errori "SP2-0333: Illegal spool file name....lst append" (bad character: ' ')" alla fine di ogni paragrafo.
--   Sono dovuti alla presenza della clausola "append" che consente di chiudere (ed aprire esternamente) lo spool ad ogni paragrafo.
--   Tale clausola non era disponibile nelle versioni anteriori alla 10

-- Esecuzione integrata in ux2html
-- Lo script può essere integrato nella componente ora2html.sql di ux2html.
-- In tal caso sara' generalmente sufficiente eseguire ux2html in modalita' limitata, utilizzando SUMMARY=1 in ux2c.hostname.sh o ux2c.sh
-- ./ux2html.sh > hostname.htm 2> hostname.err

---------------------------------------------------------------------------
-- Inizializzazione ambiente
---------------------------------------------------------------------------
DEFINE _WHAT_STRING = "&_TOOL - &_VERSION"
HOST TITLE &_WHAT_STRING - &_DESCRIPTION

-- valori di default dei parametri
DEFINE _KEEP_USERS              = "(select USERNAME from v_##_KEEP_USERS   )"
DEFINE _SKIP_USERS              = "(select USERNAME from v_##_SYS_USERS    )"
DEFINE _KEEP_ROLES              = "(select ROLE     from v_##_KEEP_ROLES   )"
DEFINE _SKIP_ROLES              = "(select role     from v_##_SYS_ROLES    )"
DEFINE _KEEP_PROFILES           = "(select PROFILE  from v_##_KEEP_PROFILES)"
DEFINE _SKIP_PROFILES           = "(select PROFILE  from v_##_SYS_PROFILES )"

START &_TOOL..def

-- reset default values (nel caso il chiamante li abbia impostati diversamente)
set feedb off
set trims ON
set head ON
set serveroutput OFF
set sqlprompt "SQL> "
-- SQL-Plus env default values
define D_verify=ON
-- SQL-Plus env global values
define G_linesize=200
define G_pagesize=1000
define G_verify=OFF
define G_nls_date_format="YYYY-MM-DD HH24:MI:SS"
-- set non default global env values
set lines &G_linesize
set pages &G_pagesize
set verif &G_verify

alter session set nls_date_format='&G_nls_date_format';

set echo on
col p_DATABASE new_val p_DATABASE for a50
col p_LOG_FILE new_val p_LOG_FILE for a70
col p_LOG_FILE_NOEXT new_val p_LOG_FILE_NOEXT for a70
select
  'log/&_TOOL._' || sys_context('USERENV','DB_NAME') || '_' || to_char(sysdate, 'yyyymmdd_hh24miss') || '.lst' p_LOG_FILE,
  'log/&_TOOL._' || sys_context('USERENV','DB_NAME') || '_' || to_char(sysdate, 'yyyymmdd_hh24miss') p_LOG_FILE_NOEXT,
  sys_context('USERENV','DB_NAME') p_DATABASE
from dual;
set echo off


PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + &_WHAT_STRING
PROMPT + &_DESCRIPTION
PROMPT + Database: &p_DATABASE
PROMPT + Log: &p_LOG_FILE
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


---------------------------------------------------------------------------
-- Inizio spool
---------------------------------------------------------------------------
HOST mkdir log
spool &p_LOG_FILE
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + &_WHAT_STRING
PROMPT + &_DESCRIPTION
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Contenuti
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Revisione parametri
PROMPT + Ambiente di esecuzione
PROMPT + Attributi database
PROMPT + Versione Oracle Server
PROMPT + Utenti considerati (KEEP and not SKIP)
PROMPT + Ruoli considerati (KEEP and not SKIP)
PROMPT + Profili considerati (KEEP and not SKIP)
PROMPT + Elenco ruoli
PROMPT + Elenco profili
PROMPT + Elenco risorse dei profili
PROMPT + Elenco utenti
PROMPT + Ruoli di ciascun utente/ruolo
PROMPT + Privilegi di sistema di ciascun utente/ruolo
PROMPT + Privilegi esterni di ciascun utente/ruolo
PROMPT + Privilegi JAVA di ciascun utente/ruolo
PROMPT + Elenco sinonimi globali
PROMPT + Elenco db link
PROMPT + Elenco job
PROMPT + Elenco tablespace
PROMPT + Elenco datafile
PROMPT + Elenco tempfile
PROMPT + Conteggio oggetti di ciascuno schema
PROMPT + Quote tablespace di ciascuno schema
PROMPT + Stima storage utilizzato da ciascuno schema
PROMPT + Tipi utente di ciascuno schema
PROMPT + Compilazione oggetti invalidi di ciascuno schema
PROMPT + Oggetti invalidi di ciascuno schema
PROMPT + 
PROMPT + File sql separati:
PROMPT + 00_EXPORT (esportazione dump con expdp o exp da db origine)
PROMPT + 01_LockUsers.sql (blocco connessione utenti)
PROMPT + 08_MakeKillSessions.sql (generazione comandi di kill sessioni)
PROMPT + 09_DropUsers.sql (eliminazione utenti)
PROMPT + 10_DropTablespaces.sql (eliminazione tablespace dedicati)
PROMPT + 11_CreateTablespaces.sql (creazione tablespace)
PROMPT + 20_CreateProfiles.sql (creazione profili)
PROMPT + 30_CreateRoles.sql (creazione ruoli)
PROMPT + 40_CreateUsers.sql (creazione utenti)
PROMPT + 50_CreatePrivs.sql (attribuzione privilegi esterni di ciascun utente/ruolo)
PROMPT + 60_CreateJavaPrivs.sql (attribuzione privilegi JAVA di ciascun utente/ruolo)
PROMPT + 70_AssignTbspQuotas.sql (attribuzione quote tablespace)
PROMPT + 80_IMPORT (importazione dump con impdp o imp su db destinazione)
PROMPT + 90_Compilation.sql (compilazione scherma)
PROMPT + 91_UnLockUsers.sql (sblocco connessione utenti)


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Revisione parametri
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + _USER_LIST                  : &_USER_LIST
PROMPT + _COMPILE_INVALID_OBJECTS    : &_COMPILE_INVALID_OBJECTS
PROMPT + _FILE_NAME_REPLACE_1_Before : &_FILE_NAME_REPLACE_1_Before
PROMPT + _FILE_NAME_REPLACE_1_After  : &_FILE_NAME_REPLACE_1_After


---------------------------------------------------------------------------
-- Creazione oggetti di supporto
---------------------------------------------------------------------------
-- DBA_TABLESPACES.BIGFILE presente dalla 10
CREATE OR REPLACE FUNCTION f_##_BIGFILE_TBSP (in_TABLESPACE_NAME VARCHAR2) RETURN VARCHAR2 AS
  my_RELEASE varchar2(3);
  my_SQL varchar2(1000);
  my_BIGFILE varchar2(3);
BEGIN
  select substr(BANNER,instr(BANNER,'Release')+8,instr(BANNER,'.')-instr(BANNER,'Release')-8) into my_RELEASE
  from   v$version where banner like 'Oracle%';
  IF my_RELEASE>9
  THEN
    my_SQL := 'SELECT BIGFILE FROM DBA_TABLESPACES WHERE TABLESPACE_NAME=:TS';
    execute immediate my_SQL into my_BIGFILE using in_TABLESPACE_NAME;
	RETURN my_BIGFILE;
  ELSE
	RETURN 'NO';
  END IF;
END;
/
show err

-- v$database.DATABASE_ROLE presente dalla 9
CREATE OR REPLACE FUNCTION f_##_DATABASE_ROLE RETURN VARCHAR2 AS
  my_RELEASE varchar2(3);
  my_SQL varchar2(1000);
  my_DATABASE_ROLE varchar2(100);
BEGIN
  select substr(BANNER,instr(BANNER,'Release')+8,instr(BANNER,'.')-instr(BANNER,'Release')-8) into my_RELEASE
  from   v$version where banner like 'Oracle%';
  IF my_RELEASE>8
  THEN
    my_SQL := 'SELECT DATABASE_ROLE FROM v$database';
    execute immediate my_SQL into my_DATABASE_ROLE;
	RETURN my_DATABASE_ROLE;
  ELSE
	RETURN 'UNSUPPORTED';
  END IF;
END;
/
show err



CREATE OR REPLACE VIEW v_##_KEEP_USERS AS SELECT USERNAME FROM ALL_USERS WHERE USERNAME IN (&_USER_LIST);

CREATE OR REPLACE VIEW v_##_SYS_USERS AS
/* system users */
SELECT '$$$DUMMY$$$'        USERNAME FROM DUAL UNION ALL
SELECT 'ANONYMOUS'                   FROM DUAL UNION ALL
SELECT 'APEX_030200'                 FROM DUAL UNION ALL
SELECT 'APEX_050000'                 FROM DUAL UNION ALL
SELECT 'APEX_PUBLIC_USER'            FROM DUAL UNION ALL
SELECT 'APPQOSSYS'                   FROM DUAL UNION ALL
SELECT 'AUDSYS'                      FROM DUAL UNION ALL
SELECT 'CTXSYS'                      FROM DUAL UNION ALL
SELECT 'DBSNMP'                      FROM DUAL UNION ALL
SELECT 'DIP'                         FROM DUAL UNION ALL
SELECT 'DVF'                         FROM DUAL UNION ALL
SELECT 'DVSYS'                       FROM DUAL UNION ALL
SELECT 'EXFSYS'                      FROM DUAL UNION ALL
SELECT 'FLOWS_FILES'                 FROM DUAL UNION ALL
SELECT 'GGSYS'                       FROM DUAL UNION ALL
SELECT 'GSMADMIN_INTERNAL'           FROM DUAL UNION ALL
SELECT 'GSMCATUSER'                  FROM DUAL UNION ALL
SELECT 'GSMUSER'                     FROM DUAL UNION ALL
SELECT 'LBACSYS'                     FROM DUAL UNION ALL
SELECT 'MDDATA'                      FROM DUAL UNION ALL
SELECT 'MDSYS'                       FROM DUAL UNION ALL
SELECT 'OJVMSYS'                     FROM DUAL UNION ALL
SELECT 'OLAPSYS'                     FROM DUAL UNION ALL
SELECT 'ORACAPTL'                    FROM DUAL UNION ALL
SELECT 'ORACLE_OCM'                  FROM DUAL UNION ALL
SELECT 'ORDDATA'                     FROM DUAL UNION ALL
SELECT 'ORDPLUGINS'                  FROM DUAL UNION ALL
SELECT 'ORDSYS'                      FROM DUAL UNION ALL
SELECT 'OUTLN'                       FROM DUAL UNION ALL
SELECT 'PDBADMIN'                    FROM DUAL UNION ALL
SELECT 'PERFSTAT'                    FROM DUAL UNION ALL
SELECT 'PUBLIC'                      FROM DUAL UNION ALL
SELECT 'SI_INFORMTN_SCHEMA'          FROM DUAL UNION ALL
SELECT 'SPATIAL_CSW_ADMIN_USR'       FROM DUAL UNION ALL
SELECT 'SYS'                         FROM DUAL UNION ALL
SELECT 'SYSBACKUP'                   FROM DUAL UNION ALL
SELECT 'SYSDG'                       FROM DUAL UNION ALL
SELECT 'SYSKM'                       FROM DUAL UNION ALL
SELECT 'SYSMAN'                      FROM DUAL UNION ALL
SELECT 'SYSRAC'                      FROM DUAL UNION ALL
SELECT 'SYSTEM'                      FROM DUAL UNION ALL
SELECT 'SYS$UMF'                     FROM DUAL UNION ALL
SELECT 'SYS_TRG_LOGON'               FROM DUAL UNION ALL
SELECT 'WMSYS'                       FROM DUAL UNION ALL
SELECT 'XDB'                         FROM DUAL UNION ALL
SELECT 'XS$NULL'                     FROM DUAL UNION ALL
/* CSI users */
SELECT 'C##CSIMON'                   FROM DUAL UNION ALL
SELECT 'C##EIDP'                     FROM DUAL UNION ALL
SELECT 'CSIMON'                      FROM DUAL UNION ALL
SELECT 'DBSFWUSER'                   FROM DUAL UNION ALL
SELECT 'EI'                          FROM DUAL UNION ALL
SELECT 'EI_DBA'                      FROM DUAL UNION ALL
SELECT 'EIDP'                        FROM DUAL UNION ALL
SELECT 'FWALLDB'                     FROM DUAL UNION ALL
SELECT 'REMOTE_SCHEDULER_AGENT'      FROM DUAL UNION ALL
SELECT '$$$DUMMY$$$'        USERNAME FROM DUAL;

CREATE OR REPLACE VIEW v_##_KEEP_ROLES AS (SELECT ROLE FROM DBA_ROLES WHERE ROLE IN (select distinct GRANTED_ROLE  from DBA_ROLE_PRIVS where grantee in (select USERNAME from v_##_KEEP_USERS)));

CREATE OR REPLACE VIEW v_##_SYS_ROLES AS
/* system roles */
SELECT '$$$DUMMY$$$'   ROLE                   FROM DUAL UNION ALL
SELECT 'CONNECT'                              FROM DUAL UNION ALL
SELECT 'RESOURCE'                             FROM DUAL UNION ALL
SELECT 'DBA'                                  FROM DUAL UNION ALL
SELECT 'SELECT_CATALOG_ROLE'                  FROM DUAL UNION ALL
SELECT 'EXECUTE_CATALOG_ROLE'                 FROM DUAL UNION ALL
SELECT 'DELETE_CATALOG_ROLE'                  FROM DUAL UNION ALL
SELECT 'EXP_FULL_DATABASE'                    FROM DUAL UNION ALL
SELECT 'IMP_FULL_DATABASE'                    FROM DUAL UNION ALL
SELECT 'LOGSTDBY_ADMINISTRATOR'               FROM DUAL UNION ALL
SELECT 'DBFS_ROLE'                            FROM DUAL UNION ALL
SELECT 'AQ_ADMINISTRATOR_ROLE'                FROM DUAL UNION ALL
SELECT 'AQ_USER_ROLE'                         FROM DUAL UNION ALL
SELECT 'DATAPUMP_EXP_FULL_DATABASE'           FROM DUAL UNION ALL
SELECT 'DATAPUMP_IMP_FULL_DATABASE'           FROM DUAL UNION ALL
SELECT 'ADM_PARALLEL_EXECUTE_TASK'            FROM DUAL UNION ALL
SELECT 'GATHER_SYSTEM_STATISTICS'             FROM DUAL UNION ALL
SELECT 'RECOVERY_CATALOG_OWNER'               FROM DUAL UNION ALL
SELECT 'SCHEDULER_ADMIN'                      FROM DUAL UNION ALL
SELECT 'HS_ADMIN_SELECT_ROLE'                 FROM DUAL UNION ALL
SELECT 'HS_ADMIN_EXECUTE_ROLE'                FROM DUAL UNION ALL
SELECT 'HS_ADMIN_ROLE'                        FROM DUAL UNION ALL
SELECT 'OEM_ADVISOR'                          FROM DUAL UNION ALL
SELECT 'OEM_MONITOR'                          FROM DUAL UNION ALL
SELECT 'WM_ADMIN_ROLE'                        FROM DUAL UNION ALL
SELECT 'JAVAUSERPRIV'                         FROM DUAL UNION ALL
SELECT 'JAVAIDPRIV'                           FROM DUAL UNION ALL
SELECT 'JAVASYSPRIV'                          FROM DUAL UNION ALL
SELECT 'JAVADEBUGPRIV'                        FROM DUAL UNION ALL
SELECT 'EJBCLIENT'                            FROM DUAL UNION ALL
SELECT 'JMXSERVER'                            FROM DUAL UNION ALL
SELECT 'CTXAPP'                               FROM DUAL UNION ALL
SELECT 'XDBADMIN'                             FROM DUAL UNION ALL
SELECT 'XDB_SET_INVOKER'                      FROM DUAL UNION ALL
SELECT 'AUTHENTICATEDUSER'                    FROM DUAL UNION ALL
SELECT 'XDB_WEBSERVICES'                      FROM DUAL UNION ALL
SELECT 'XDB_WEBSERVICES_WITH_PUBLIC'          FROM DUAL UNION ALL
SELECT 'XDB_WEBSERVICES_OVER_HTTP'            FROM DUAL UNION ALL
SELECT 'ORDADMIN'                             FROM DUAL UNION ALL
SELECT 'GLOBAL_AQ_USER_ROLE'                  FROM DUAL UNION ALL
SELECT 'MGMT_USER'                            FROM DUAL UNION ALL
SELECT 'OLAP_DBA'                             FROM DUAL UNION ALL
SELECT 'OLAP_USER'                            FROM DUAL UNION ALL
SELECT 'OLAP_XS_ADMIN'                        FROM DUAL UNION ALL
SELECT 'OWB$CLIENT'                           FROM DUAL UNION ALL
SELECT 'OWB_DESIGNCENTER_VIEW'                FROM DUAL UNION ALL
SELECT 'OWB_USER'                             FROM DUAL UNION ALL
SELECT 'SPATIAL_CSW_ADMIN'                    FROM DUAL UNION ALL
SELECT 'SPATIAL_WFS_ADMIN'                    FROM DUAL UNION ALL
SELECT 'WFS_USR_ROLE'                         FROM DUAL UNION ALL
SELECT 'CSW_USR_ROLE'                         FROM DUAL UNION ALL
SELECT 'CWM_USER'                             FROM DUAL UNION ALL
SELECT 'APEX_ADMINISTRATOR_ROLE'              FROM DUAL UNION ALL
SELECT 'APEX_GRANTS_FOR_NEW_USERS_ROLE'       FROM DUAL UNION ALL
SELECT 'APPLICATION_TRACE_VIEWER'             FROM DUAL UNION ALL
SELECT 'AUDIT_ADMIN'                          FROM DUAL UNION ALL
SELECT 'AUDIT_VIEWER'                         FROM DUAL UNION ALL
SELECT 'CAPTURE_ADMIN'                        FROM DUAL UNION ALL
SELECT 'CDB_DBA'                              FROM DUAL UNION ALL
SELECT 'DATAPATCH_ROLE'                       FROM DUAL UNION ALL
SELECT 'DBJAVASCRIPT'                         FROM DUAL UNION ALL
SELECT 'DBMS_MDX_INTERNAL'                    FROM DUAL UNION ALL
SELECT 'DV_ACCTMGR'                           FROM DUAL UNION ALL
SELECT 'DV_ADMIN'                             FROM DUAL UNION ALL
SELECT 'DV_AUDIT_CLEANUP'                     FROM DUAL UNION ALL
SELECT 'DV_DATAPUMP_NETWORK_LINK'             FROM DUAL UNION ALL
SELECT 'DV_GOLDENGATE_ADMIN'                  FROM DUAL UNION ALL
SELECT 'DV_GOLDENGATE_REDO_ACCESS'            FROM DUAL UNION ALL
SELECT 'DV_MONITOR'                           FROM DUAL UNION ALL
SELECT 'DV_OWNER'                             FROM DUAL UNION ALL
SELECT 'DV_PATCH_ADMIN'                       FROM DUAL UNION ALL
SELECT 'DV_POLICY_OWNER'                      FROM DUAL UNION ALL
SELECT 'DV_PUBLIC'                            FROM DUAL UNION ALL
SELECT 'DV_REALM_OWNER'                       FROM DUAL UNION ALL
SELECT 'DV_REALM_RESOURCE'                    FROM DUAL UNION ALL
SELECT 'DV_SECANALYST'                        FROM DUAL UNION ALL
SELECT 'DV_STREAMS_ADMIN'                     FROM DUAL UNION ALL
SELECT 'DV_XSTREAM_ADMIN'                     FROM DUAL UNION ALL
SELECT 'EM_EXPRESS_ALL'                       FROM DUAL UNION ALL
SELECT 'EM_EXPRESS_BASIC'                     FROM DUAL UNION ALL
SELECT 'GDS_CATALOG_SELECT'                   FROM DUAL UNION ALL
SELECT 'GGSYS_ROLE'                           FROM DUAL UNION ALL
SELECT 'GSMADMIN_ROLE'                        FROM DUAL UNION ALL
SELECT 'GSM_POOLADMIN_ROLE'                   FROM DUAL UNION ALL
SELECT 'GSMUSER_ROLE'                         FROM DUAL UNION ALL
SELECT 'LBAC_DBA'                             FROM DUAL UNION ALL
SELECT 'OPTIMIZER_PROCESSING_RATE'            FROM DUAL UNION ALL
SELECT 'PDB_DBA'                              FROM DUAL UNION ALL
SELECT 'PROVISIONER'                          FROM DUAL UNION ALL
SELECT 'RDFCTX_ADMIN'                         FROM DUAL UNION ALL
SELECT 'RECOVERY_CATALOG_OWNER_VPD'           FROM DUAL UNION ALL
SELECT 'RECOVERY_CATALOG_USER'                FROM DUAL UNION ALL
SELECT 'SODA_APP'                             FROM DUAL UNION ALL
SELECT 'SYSUMF_ROLE'                          FROM DUAL UNION ALL
SELECT 'XS_CACHE_ADMIN'                       FROM DUAL UNION ALL
SELECT 'XS_CONNECT'                           FROM DUAL UNION ALL
SELECT 'XS_NAMESPACE_ADMIN'                   FROM DUAL UNION ALL
SELECT 'XS_SESSION_ADMIN'                     FROM DUAL UNION ALL
/* CSI roles */
SELECT 'BDSQL_ADMIN'                          FROM DUAL UNION ALL
SELECT 'C##CSIMON_ROLE'                       FROM DUAL UNION ALL
SELECT 'CSIMON_ROLE'                          FROM DUAL UNION ALL
SELECT 'JAVA_ADMIN'                           FROM DUAL UNION ALL
SELECT 'JAVA_DEPLOY'                          FROM DUAL UNION ALL
SELECT '$$$DUMMY$$$'   ROLE                   FROM DUAL;

CREATE OR REPLACE VIEW v_##_KEEP_PROFILES AS (SELECT ROLE FROM DBA_ROLES WHERE ROLE IN (select distinct GRANTED_ROLE from DBA_ROLE_PRIVS where grantee in (select USERNAME from v_##_KEEP_USERS)));

CREATE OR REPLACE VIEW v_##_SYS_PROFILES AS
SELECT '$$$DUMMY$$$' PROFILE                  FROM DUAL UNION ALL
SELECT 'DEFAULT'                              FROM DUAL UNION ALL
SELECT 'ORA_STIG_PROFILE'                     FROM DUAL UNION ALL
/* CSI profiles */
SELECT '$$$DUMMY$$$' PROFILE                  FROM DUAL;

-- wrapper proc for DBMS_OUTPUT.put_line (workaround per il limite di 32767 caratteri per riga nelle versioni oracle precedenti la 12)
/* usage
declare
  ddl long; --VARCHAR2(4000);
begin
  for p in (SELECT DISTINCT profile from DBA_PROFILES where profile='DEFAULT') loop
      SELECT DBMS_METADATA.GET_DDL('PROFILE',p.profile) into ddl from DUAL;
      p_##_PRINT_LINES(ddl,chr(13),255);
   end loop;
 end;
/
*/
create or replace procedure p_##_PRINT_LINES( p_LINES varchar2, p_LINESEP varchar2 := NULL, p_MAX_CHAR integer := 32767, p_DEBUG VARCHAR2 := 'OFF') is
        my_LINESEP varchar2(10);
        my_LINESEP_position integer;
        s               varchar2(32767);
        p               number;
		my_LINE_length integer;
		my_MAX_lines integer := 32767;
		my_COUNT_lines integer :=0;
        my_LINESEP_HEX varchar2(20);
        my_pLINESEP_HEX varchar2(20);
begin
        IF p_LINESEP IS NULL THEN
		  my_LINESEP := CHR(10) /* CHR(13)||CHR(10) */ ;
		ELSE
		  my_LINESEP := p_LINESEP;
		END IF;
--		my_pLINESEP_HEX := to_char(RAWTOHEX(p_LINESEP));
--		my_LINESEP_HEX := to_char(RAWTOHEX(my_LINESEP));
        p := 1;
		if p_DEBUG = 'ON' then
		  DBMS_OUTPUT.put_line( '**p_LINES=['||p_LINES||']');
		  DBMS_OUTPUT.put_line( '**p_LINESEP=['||p_LINESEP||'] my_LINESEP=['||my_LINESEP||'] p_MAX_CHAR='||p_MAX_CHAR);
		end if;
        loop
                my_LINESEP_position := INSTR(p_LINES,my_LINESEP,p);
		        if my_LINESEP_position between p and p+p_MAX_CHAR-1 then
				  my_LINE_length := my_LINESEP_position - p;
				else
				  my_LINE_length := p_MAX_CHAR;
				end if;
                s := substr( p_LINES, p, my_LINE_length );
						my_COUNT_lines := my_COUNT_lines+1;
				if p_DEBUG = 'ON' then
				  DBMS_OUTPUT.put_line( '**p='||p||' my_LINESEP_position='||my_LINESEP_position||' my_LINE_length='||my_LINE_length||' my_COUNT_lines='||my_COUNT_lines);
				end if;
                DBMS_OUTPUT.put_line( s );
		        if my_LINESEP_position between p and p+p_MAX_CHAR-1 then
				  p := my_LINESEP_position + length(my_LINESEP);
				else
				  p := p + p_MAX_CHAR;
				end if;
                exit when p > length( p_LINES ) or my_COUNT_lines = my_MAX_lines;
        end loop;
exception when OTHERS then
          raise;
end;
/
show err


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Ambiente di esecuzione
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
set pages 0
select           'Database               : ' || sys_context('USERENV','DB_NAME') FROM DUAL
union all select 'Instance               : ' || INSTANCE_NAME FROM v$instance
union all select 'Server Host            : ' || HOST_NAME FROM v$instance
union all select 'Connected as           : ' || USER FROM DUAL
union all select 'Client Host            : ' || sys_context('USERENV','HOST') FROM DUAL
union all select 'Terminal               : ' || sys_context('USERENV','TERMINAL') FROM DUAL
--solo>=10g union all select 'Service                : ' || sys_context('USERENV','SERVICE_NAME') FROM DUAL
union all select 'Service                : ' || value FROM v$parameter where name like '%service_name%'
union all select 'User                   : ' || sys_context('USERENV','OS_USER') FROM DUAL
union all select 'Language               : ' || sys_context('USERENV','LANGUAGE') FROM DUAL
;
set pages &G_pagesize


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Attributi database
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col dummy for a100 HEADING "Nome                   : Valore"
          select 'Database               : ' || sys_context('USERENV','DB_NAME') dummy FROM DUAL
union all select 'Created                : ' || to_char(created, 'dd/mm/yyyy hh24:mi:ss') FROM v$database
union all select 'NLS_CHARACTERSET       : ' || value FROM NLS_DATABASE_PARAMETERS where PARAMETER = 'NLS_CHARACTERSET'
union all select 'NLS_NCHAR_CHARACTERSET : ' || value FROM NLS_DATABASE_PARAMETERS where PARAMETER = 'NLS_NCHAR_CHARACTERSET'
union all select 'SYSDATE                : ' || Sysdate FROM DUAL
--solo>8 union all select 'SYSTIMESTAMP           : ' || Systimestamp FROM DUAL
union all select 'LOG MODE               : ' || LOG_MODE FROM v$database
union all select 'OPEN_MODE              : ' || OPEN_MODE FROM v$database
union all select 'DATABASE ROLE          : ' || f_##_DATABASE_ROLE FROM dual
union all select 'Datafiles nr           : ' || trim(TO_CHAR(COUNT(*),'9,990')) FROM v$datafile
union all select 'Datafiles size(Gb)     : ' || trim(TO_CHAR(SUM(bytes)/1073741824, '9,990')) FROM v$datafile
union all select 'Tempfiles nr           : ' || trim(TO_CHAR(COUNT(*),'9,990')) FROM v$tempfile
union all select 'Tempfile size(Gb)      : ' || trim(TO_CHAR(SUM(bytes)/1073741824, '9,990')) FROM v$tempfile
;


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Versione Oracle Server
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
SELECT banner FROM v$version;


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Utenti considerati (KEEP and not SKIP)
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col USERNAME for a30
col KEEP for a4
col SKIP for a4
col considerato for a12
select sub.*, case when KEEP='Y' and SKIP='N' then '*' end considerato from (
select username,
	case when username in &_KEEP_USERS then 'Y' else 'N' end KEEP,
	case when username in &_SKIP_USERS then 'Y' else 'N' end SKIP
from all_users
) sub
order by 1;
col USERNAME clear
col KEEP clear
col SKIP clear
col considerato clear

spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Ruoli considerati (KEEP and not SKIP)
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col role for a30
col KEEP for a4
col SKIP for a4
col considerato for a12
select sub.*, case when KEEP='Y' and SKIP='N' then '*' end considerato from (
select role,
	case when role in &_KEEP_ROLES then 'Y' else 'N' end KEEP,
	case when role in &_SKIP_ROLES then 'Y' else 'N' end SKIP
from DBA_ROLES
) sub
order by 1;
col role clear
col KEEP clear
col SKIP clear
col considerato clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Profili considerati (KEEP and not SKIP)
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col PROFILE  for a30
col KEEP for a4
col SKIP for a4
col considerato for a12
select sub.*, case when KEEP='Y' and SKIP='N' then '*' end considerato from (
select distinct profile,
	case when profile in &_KEEP_PROFILES then 'Y' else 'N' end KEEP,
	case when profile in &_SKIP_PROFILES then 'Y' else 'N' end SKIP
from DBA_PROFILES
) sub
order by 1;
col PROFILE clear
col KEEP clear
col SKIP clear
col considerato clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Elenco ruoli
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col ROLE          for a30
col EXTERNAL_NAME for a30
SELECT *
FROM dba_roles
where role in &_KEEP_ROLES and role not in &_SKIP_ROLES
ORDER BY ROLE;
col ROLE          clear
col EXTERNAL_NAME clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Elenco profili
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col PROFILE for a30
SELECT DISTINCT PROFILE
from  dba_profiles
where PROFILE in &_KEEP_PROFILES and PROFILE not in &_SKIP_PROFILES
ORDER BY 1;
col PROFILE clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Elenco risorse dei profili
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col PROFILE       for a30
col RESOURCE_NAME for a30
SELECT PROFILE, RESOURCE_NAME, LIMIT
from  dba_profiles
where
      PROFILE in &_KEEP_PROFILES and PROFILE not in &_SKIP_PROFILES
ORDER BY 1,2;
col PROFILE       clear
col RESOURCE_NAME clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Elenco utenti
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col USERNAME for a30
col PROFILE  for a30
SELECT USERNAME, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, PROFILE, ACCOUNT_STATUS
FROM dba_users
where
      USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
ORDER BY 1;
col USERNAME clear
col PROFILE  clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Ruoli di ciascun utente/ruolo
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col GRANTEE      for a30
col GRANTED_ROLE for a30
select GRANTEE, GRANTED_ROLE, ADMIN_OPTION, DEFAULT_ROLE
from   DBA_ROLE_PRIVS
where  GRANTEE IN &_KEEP_USERS AND GRANTEE NOT IN &_SKIP_USERS
order by 1,2;
col GRANTEE      clear
col GRANTED_ROLE clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Privilegi di sistema di ciascun utente/ruolo
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col GRANTEE for a30
select GRANTEE, PRIVILEGE, ADMIN_OPTION
from dba_SYS_PRIVS
where grantee in &_KEEP_USERS and grantee not in &_SKIP_USERS
      OR
      grantee in (select GRANTED_ROLE from DBA_ROLE_PRIVS where GRANTEE IN &_KEEP_USERS AND GRANTEE NOT IN &_SKIP_USERS) 
order by 1,2;
col GRANTEE clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Privilegi esterni di ciascun utente/ruolo
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col GRANTEE    for a30
col OWNER      for a30
col TABLE_NAME for a30
select GRANTEE, OWNER, TABLE_NAME, PRIVILEGE, GRANTABLE --, HIERARCHY
from dba_TAB_PRIVS
where (grantee in &_KEEP_USERS and grantee not in &_SKIP_USERS) and (OWNER not in &_KEEP_USERS or OWNER in &_SKIP_USERS)
	  OR
      grantee in (select GRANTED_ROLE from DBA_ROLE_PRIVS where GRANTEE IN &_KEEP_USERS AND GRANTEE NOT IN &_SKIP_USERS)
order by 1,2,3,4;
col GRANTEE    clear
col OWNER      clear
col TABLE_NAME clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Privilegi JAVA di ciascun utente/ruolo
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
set lines 300
col GRANTEE     for a30
col TYPE_SCHEMA for a30
col TYPE_NAME   for a50
col NAME        for a50
col ACTION      for a30
select GRANTEE,KIND,TYPE_SCHEMA,TYPE_NAME,NAME,ACTION,ENABLED,SEQ
from DBA_JAVA_POLICY
where (grantee in &_KEEP_USERS and grantee not in &_SKIP_USERS)
	  OR
      grantee in (select GRANTED_ROLE from DBA_ROLE_PRIVS where GRANTEE IN &_KEEP_USERS AND GRANTEE NOT IN &_SKIP_USERS)
order by 1,2,3,4,5,6;
col GRANTEE     clear
col TYPE_SCHEMA clear
col TYPE_NAME   clear
col NAME        clear
col ACTION      clear
set lines &G_linesize


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Elenco sinonimi globali
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col TABLE_OWNER  for a30
col SYNONYM_NAME for a30
col TABLE_NAME   for a30
col db_link      for a50
select TABLE_OWNER, SYNONYM_NAME, TABLE_NAME, DB_LINK
from dba_synonyms
where owner = 'PUBLIC' and
      TABLE_OWNER in &_KEEP_USERS and TABLE_OWNER not in &_SKIP_USERS
order by 1,2;
col TABLE_OWNER  clear
col SYNONYM_NAME clear
col TABLE_NAME   clear
col db_link      clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Elenco db link
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col owner    for a30
col db_link  for a50
col username for a30
col host     for a50
SELECT owner, db_link, username, host FROM dba_db_links
where OWNER in &_KEEP_USERS and OWNER not in &_SKIP_USERS
order by 1,2;
col owner    clear
col db_link  clear
col username clear
col host     clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Elenco job
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
set lines 500
col schema_user for a15  
col job         for 99999
col log_user    for a15  
col priv_user   for a15  
col interval    for a30  
col what        for a300 
SELECT SCHEMA_USER, INTERVAL, LOG_USER, PRIV_USER, JOB, NEXT_DATE, WHAT FROM dba_jobs
where SCHEMA_USER in &_KEEP_USERS and SCHEMA_USER not in &_SKIP_USERS
order by SCHEMA_USER,INTERVAL,WHAT;
col schema_user clear
col job         clear
col log_user    clear
col priv_user   clear
col interval    clear
col what        clear
set lines &G_linesize


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Elenco tablespace
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
set lines 300
col MAX_TS_MB  for 999,999,999
col BUSY_DF_MB for 999,999,999
col TOT_DF_MB  for 999,999,999
col FREE_DF_MB for 999,999,999
col MAX_DF_MB  for 999,999,999
COLUMN DUMMY NOPRINT;
COMPUTE SUM LABEL 'Totali' OF TOT_DF_MB MAX_DF_MB ON DUMMY;
BREAK ON DUMMY;
select NULL DUMMY, t.tablespace_name, t.contents, t.block_size, t.extent_management, t.allocation_type,
       t.SEGMENT_SPACE_MANAGEMENT, t.status, f_##_BIGFILE_TBSP(t.tablespace_name) BIGFILE, s.autoextensible,
	   (select count(1) from dba_extents where tablespace_name=t.tablespace_name) extents,
	   (select count(1) from dba_segments where tablespace_name=t.tablespace_name) segments
--	   ,round(t.max_size / 1024 / 1024) MAX_TS_MB
	   ,round(s.busy) BUSY_DF_MB
	   ,round(s.total) TOT_DF_MB
	   ,round(s.free) FREE_DF_MB
	   ,round(s.maximum, 2) MAX_DF_MB
--	   ,round(s.busy / t.max_size * 100) "USED_TSMAX%"
	   ,round(s.busy / s.total * 100) "USED_DFTOT%"
	   ,round(s.busy / s.maximum * 100) "USED_DFMAX%"
from dba_tablespaces t
	,(
		SELECT tablespace_name
			,sum(total) TOTAL
			,sum(TOTAL - NVL(FREE, 0)) BUSY
			,sum(nvl(FREE, 0)) FREE
			,max(AUTOEXTENSIBLE) AUTOEXTENSIBLE
			,sum(MAXIMUM) MAXIMUM
		FROM (
			SELECT df.tablespace_name
				,df.bytes / (1024 * 1024) total
				,free
				,autoextensible
				,decode(autoextensible, 'YES', df.maxbytes / (1024 * 1024), 'NO', df.bytes / (1024 * 1024)) maximum
			FROM dba_data_files df
				,(
					SELECT file_id
						,sum(bytes / (1024 * 1024)) free
					FROM dba_free_space
					GROUP BY file_id
					) fs
			WHERE fs.file_id(+) = df.file_id
			)
		GROUP BY tablespace_name
		) s
WHERE s.tablespace_name = t.tablespace_name
and t.tablespace_name in
      (
        select TABLESPACE_NAME from dba_ts_quotas where username in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TABLESPACE_NAME from dba_segments where OWNER in &_KEEP_USERS and OWNER not in &_SKIP_USERS
        union
        select DEFAULT_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
        union
        select TEMPORARY_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
      )
order by 2;
CLEAR BREAKS
CLEAR COMPUTES
COLUMN DUMMY clear
col MAX_TS_MB  clear
col BUSY_DF_MB clear
col TOT_DF_MB  clear
col FREE_DF_MB clear
col MAX_DF_MB  clear
set lines &G_linesize


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Elenco datafile
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
set lines 300
col file_name for a100
col SIZE_MB   for 999,999,999
col NEXT_MB   for 999,999,999
col MAX_MB    for 999,999,999
COLUMN DUMMY NOPRINT;
COMPUTE SUM LABEL 'Totali' OF SIZE_MB MAX_MB ON DUMMY;
BREAK ON DUMMY;
select NULL DUMMY, t.tablespace_name, df.file_name, df.autoextensible, df.bytes/1024/1024 SIZE_MB, df.increment_by, df.increment_by*t.block_size/1024/1024 NEXT_MB, df.maxbytes/1024/1024 MAX_MB
from dba_tablespaces t, dba_data_files df
where df.tablespace_name=t.tablespace_name and
      t.tablespace_name in
      (
        select TABLESPACE_NAME from dba_ts_quotas where username in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TABLESPACE_NAME from dba_segments where OWNER in &_KEEP_USERS and OWNER not in &_SKIP_USERS
        union
        select DEFAULT_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
        union
        select TEMPORARY_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
      )
order by 2,3;
CLEAR BREAKS
CLEAR COMPUTES
col file_name clear
col SIZE_MB   clear
col NEXT_MB   clear
col MAX_MB    clear

-- Versione Oracle < 9
col file_name for a100
col SIZE_MB   for 999,999,999
col NEXT_MB   for 999,999,999
col MAX_MB    for 999,999,999
COLUMN DUMMY NOPRINT;
COMPUTE SUM LABEL 'Totali' OF SIZE_MB MAX_MB ON DUMMY;
BREAK ON DUMMY;
select NULL DUMMY, t.tablespace_name, df.file_name, df.autoextensible, df.bytes/1024/1024 SIZE_MB, df.increment_by, df.maxbytes/1024/1024 MAX_MB
from dba_tablespaces t, dba_data_files df
where df.tablespace_name=t.tablespace_name and
      t.tablespace_name in
      (
        select TABLESPACE_NAME from dba_ts_quotas where username in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TABLESPACE_NAME from dba_segments where OWNER in &_KEEP_USERS and OWNER not in &_SKIP_USERS
        union
        select DEFAULT_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
        union
        select TEMPORARY_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
      )
and   (select substr(BANNER,instr(BANNER,'Release')+8,instr(BANNER,'.')-instr(BANNER,'Release')-8) from v$version where banner like 'Oracle%')<9
order by 2,3;
CLEAR BREAKS
CLEAR COMPUTES
COLUMN DUMMY clear
col file_name clear
col SIZE_MB   clear
col NEXT_MB   clear
col MAX_MB    clear
set lines &G_linesize


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Elenco tempfile
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
set lines 300
col file_name for a100
col SIZE_MB   for 999,999,999
col NEXT_MB   for 999,999,999
col MAX_MB    for 999,999,999
COLUMN DUMMY NOPRINT;
COMPUTE SUM LABEL 'Totali' OF SIZE_MB MAX_MB ON DUMMY;
BREAK ON DUMMY;
select NULL DUMMY, t.tablespace_name, df.file_name, df.autoextensible, df.bytes/1024/1024 SIZE_MB, df.increment_by, df.increment_by*t.block_size/1024/1024 NEXT_MB, df.maxbytes/1024/1024 MAX_MB
from dba_tablespaces t, dba_temp_files df
where df.tablespace_name=t.tablespace_name and
      t.tablespace_name in
      (
        select TABLESPACE_NAME from dba_ts_quotas where username in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TABLESPACE_NAME from dba_segments where OWNER in &_KEEP_USERS and OWNER not in &_SKIP_USERS
        union
        select DEFAULT_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
        union
        select TEMPORARY_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
      )
order by 2,3;
CLEAR BREAKS
CLEAR COMPUTES
COLUMN DUMMY clear
col file_name clear
col SIZE_MB   clear
col NEXT_MB   clear
col MAX_MB    clear
set lines &G_linesize

-- Versione Oracle < 9
set lines 300
col file_name for a100
col SIZE_MB   for 999,999,999
col NEXT_MB   for 999,999,999
col MAX_MB    for 999,999,999
COLUMN DUMMY NOPRINT;
COMPUTE SUM LABEL 'Totali' OF SIZE_MB MAX_MB ON DUMMY;
BREAK ON DUMMY;
select NULL DUMMY, t.tablespace_name, df.file_name, df.autoextensible, df.bytes/1024/1024 SIZE_MB, df.increment_by, df.maxbytes/1024/1024 MAX_MB
from dba_tablespaces t, dba_temp_files df
where df.tablespace_name=t.tablespace_name and
      t.tablespace_name in
      (
        select TABLESPACE_NAME from dba_ts_quotas where username in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TABLESPACE_NAME from dba_segments where OWNER in &_KEEP_USERS and OWNER not in &_SKIP_USERS
        union
        select DEFAULT_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
        union
        select TEMPORARY_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and USERNAME not in &_SKIP_USERS
      )
and   (select substr(BANNER,instr(BANNER,'Release')+8,instr(BANNER,'.')-instr(BANNER,'Release')-8) from v$version where banner like 'Oracle%')<9
order by 2,3;
CLEAR BREAKS
CLEAR COMPUTES
COLUMN DUMMY clear
col file_name clear
col SIZE_MB   clear
col NEXT_MB   clear
col MAX_MB    clear
set lines &G_linesize


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Conteggio oggetti di ciascuno schema
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col owner for a30
select owner, object_type, count(1) count from dba_objects
where owner IN &_KEEP_USERS AND owner NOT IN &_SKIP_USERS
group by owner,object_type
order by owner,object_type;
col owner clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Quote tablespace di ciascuno schema
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col USERNAME for a30
col MAX_MB for 999,999,999
select USERNAME,TABLESPACE_NAME,decode(MAX_BYTES,-1,'UNLIMITED',MAX_BYTES/1024/1024) MAX_MB from dba_ts_quotas
where USERNAME IN &_KEEP_USERS AND USERNAME NOT IN &_SKIP_USERS
order by USERNAME,TABLESPACE_NAME;
col USERNAME clear
col MAX_MB clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Stima storage utilizzato da ciascuno schema
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col OWNER for a30
col MB for 999,999,999
select OWNER, TABLESPACE_NAME,sum(BYTES)/1024/1024 MB from dba_extents
where  OWNER in &_KEEP_USERS AND owner NOT IN &_SKIP_USERS
group by OWNER, TABLESPACE_NAME
order by OWNER, TABLESPACE_NAME;
col OWNER clear
col MB clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Tipi utente di ciascuno schema
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
col OWNER          for a30
col TYPE_NAME      for a30
col SUPERTYPE_NAME for a30
SELECT OWNER,TYPE_NAME,TYPE_OID,SUPERTYPE_NAME FROM DBA_TYPES WHERE owner IN &_KEEP_USERS AND owner NOT IN &_SKIP_USERS ORDER BY 1,2;
col OWNER          clear
col TYPE_NAME      clear
col SUPERTYPE_NAME clear


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Compilazione oggetti invalidi di ciascuno schema
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
BEGIN
  FOR u IN (select username from dba_users where '&_COMPILE_INVALID_OBJECTS' = 'YES' and username IN &_KEEP_USERS AND username NOT IN &_SKIP_USERS order by 1)
  LOOP
    DBMS_UTILITY.COMPILE_SCHEMA (schema=>u.username, compile_all=>FALSE);
  END LOOP;
END;
/
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


spool &p_LOG_FILE append
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Oggetti invalidi di ciascuno schema
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
set pages 0
col owner          for a30
col OBJECT_NAME    for a30
col OBJECT_TYPE    for a30
col SUBOBJECT_NAME for a30
select 'OWNER                          OBJECT_TYPE                    OBJECT_NAME                    STATUS ' from dual;
select '------------------------------ ------------------------------ ------------------------------ -------' from dual;
select owner, object_type, OBJECT_NAME, SUBOBJECT_NAME, decode(status,'INVALID','INVALID','Unknown') STATUS from dba_objects
where owner IN &_KEEP_USERS AND owner NOT IN &_SKIP_USERS
  and status <> 'VALID'
order by owner,object_type, OBJECT_NAME, SUBOBJECT_NAME;
col owner          clear
col OBJECT_NAME    clear
col OBJECT_TYPE    clear
col SUBOBJECT_NAME clear
set pages &G_pagesize


PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT segue output su file .sql separati
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT

spool OFF



PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT output su file sql separati, da eseguire su db destinazione:
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT
set serveroutput on size 1000000
set lines 200
set pages 0
set verif OFF


PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._00_Export.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++k++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT EXPORT (esportazione dump con expdp o exp da db origine)
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
set lines 500
PROMPT spool 00_Export.lst
PROMPT
PROMPT -- SQL per selezionare directory e lanciare export da SQL*Plus:
select 'set lines 500' from dual;
select 'col DIRECTORY_PATH for a100' from dual;
select 'select directory_name,directory_path from dba_directories order by 1;' from dual;
select 'accept TMP_DIRECTORY_NAME PROMPT "Inserire il nome della directory di estrazione [default DATA_PUMP_DIR]> " default DATA_PUMP_DIR' from dual;
DECLARE
  my_SQL varchar2(400);
  my_version varchar2(10);
BEGIN
  select substr(BANNER,instr(BANNER,'Release')+8,instr(BANNER,'.')-instr(BANNER,'Release')-8) into my_version from v$version where banner like 'Oracle%';
  if my_version<10 then
    my_SQL := 'HOST exp \"/ as sysdba\" FILE=&p_DATABASE._save.dmp LOG=exp&p_DATABASE._save.log PARFILE=exp&p_DATABASE..par';
  else
    my_SQL := 'HOST expdp \"/ as sysdba\" DIRECTORY='||chr(38)||'TMP_DIRECTORY_NAME DUMPFILE=&p_DATABASE._save.dmp LOGFILE=exp&p_DATABASE._save.log PARFILE=exp&p_DATABASE..par';
  end if;
  dbms_output.put_line(my_SQL);
END;
/
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool off
spool log/exp&p_DATABASE..par
DECLARE
  my_userlist varchar2(4000);
  my_version varchar2(10);
BEGIN
  for x in (select username from dba_users where username in (&_USER_LIST)) loop
    my_userlist:=my_userlist||x.username||',';
    --dbms_output.put_line(my_userlist);
  end loop;
  my_userlist:=rtrim(my_userlist,',');
  select substr(BANNER,instr(BANNER,'Release')+8,instr(BANNER,'.')-instr(BANNER,'Release')-8) into my_version from v$version where banner like 'Oracle%';
  if my_version<10 then
    dbms_output.put_line('OWNER=('||my_userlist);
  else
    dbms_output.put_line('SCHEMAS=(');
    my_userlist:=replace(my_userlist,',',','||CHR(10));
    dbms_output.put_line(my_userlist);
    dbms_output.put_line(')');
  end if;
END;
/
spool OFF


PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._01_LockUsers.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Blocco utenti
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 01_LockUsers.lst
PROMPT
PROMPT -- SQL per lock account per impedire ulteriori connessioni degli utenti da eliminare:
select 'ALTER USER "' || USERNAME || '" ACCOUNT LOCK;' from DBA_USERS where username in &_KEEP_USERS and username not in &_SKIP_USERS order by username;
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF


PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._08_MakeKillSessions.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Costruzione script di kill sessioni utenti
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 08_MakeKillSessions.lst
PROMPT
PROMPT -- verifica connessioni utenti da eliminare:
PROMPT set lines 200
select 'SELECT COUNT(1) num_sess, USERNAME, STATUS, MACHINE, PROGRAM FROM v$session WHERE username IN (' from dual;
select ''''||username||''',' from dba_users where username in &_KEEP_USERS and username not in &_SKIP_USERS order by username;
select '''$$$DUMMY$$$'' )' from dual;
select 'GROUP BY USERNAME, STATUS, MACHINE, PROGRAM ORDER BY USERNAME, STATUS, MACHINE, PROGRAM;' from dual;
PROMPT
PROMPT spool 08_MakeKillSessions.sql
PROMPT -- SQL per disconnessione forzata sessioni:
select 'SELECT ''ALTER SYSTEM DISCONNECT SESSION ''''''||SID||'',''||SERIAL#||'''''' IMMEDIATE;'' FROM v$session WHERE username IN (' from dual;
select ''''||username||''',' from dba_users where username in &_KEEP_USERS and username not in &_SKIP_USERS order by username;
select '''$$$DUMMY$$$'' )' from dual;
select 'ORDER BY USERNAME, SID,SERIAL#;' from dual;
PROMPT
PROMPT PROMPT -- verifica connessioni utenti ancora presenti:
PROMPT PROMPT set lines 200
select 'PROMPT SELECT COUNT(1) num_sess, USERNAME, STATUS, MACHINE, PROGRAM FROM v$session WHERE username IN (' from dual;
select 'PROMPT '''||username||''',' from dba_users where username in &_KEEP_USERS and username not in &_SKIP_USERS order by username;
select 'PROMPT ''$$$DUMMY$$$'' )' from dual;
select 'PROMPT GROUP BY USERNAME, STATUS, MACHINE, PROGRAM ORDER BY USERNAME, STATUS, MACHINE, PROGRAM;' from dual;
PROMPT PROMPT
PROMPT PROMPT PROMPT
PROMPT PROMPT spool OFF
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF

PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._09_DropUsers.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Eliminazione utenti
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 09_DropUsers.lst
PROMPT
PROMPT -- SQL per eliminazione utenti:
select 'DROP USER "' || USERNAME || '" CASCADE;' from DBA_USERS where username in &_KEEP_USERS and username not in &_SKIP_USERS order by username;
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF


PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._10_DropTablespaces.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Eliminazione Tablespace
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 10_DropTablespaces.lst
PROMPT
PROMPT -- SQL per verifica che tbsp siano vuoti:
select 'SELECT TABLESPACE_NAME, COUNT(1) EXTENTS FROM DBA_EXTENTS WHERE TABLESPACE_NAME='''||tablespace_name||'''  GROUP BY TABLESPACE_NAME;' sql from dba_tablespaces where tablespace_name in
      (
        select TABLESPACE_NAME from dba_ts_quotas where username in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TABLESPACE_NAME from dba_segments where OWNER in &_KEEP_USERS and OWNER not in &_SKIP_USERS
        union
        select DEFAULT_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TEMPORARY_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and username not in &_SKIP_USERS
      )
    order by 1;
PROMPT
PROMPT -- SQL per eliminazione tbsp:
select 'DROP TABLESPACE '||tablespace_name||' INCLUDING CONTENTS AND DATAFILES;' sql from dba_tablespaces where tablespace_name in
      (
        select TABLESPACE_NAME from dba_ts_quotas where username in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TABLESPACE_NAME from dba_segments where OWNER in &_KEEP_USERS and OWNER not in &_SKIP_USERS
        union
        select DEFAULT_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TEMPORARY_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and username not in &_SKIP_USERS
      )
    order by 1;
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF



PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._11_CreateTablespaces.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Creazione tablespace
PROMPT PROMPT NB Prima di eseguire, verificare file, path, size, next, etc. di destinazione
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 11_CreateTablespaces.lst
PROMPT
declare
my_DDL varchar2(4000);
my_db_create_file_dest varchar2(100);
begin
  select value into my_db_create_file_dest from v$parameter where name='db_create_file_dest';

  for t in (select tablespace_name,block_size,extent_management,allocation_type,next_extent,SEGMENT_SPACE_MANAGEMENT,status, f_##_BIGFILE_TBSP(tablespace_name) BIGFILE
            from dba_tablespaces where contents='PERMANENT' and tablespace_name in
      (
        select TABLESPACE_NAME from dba_ts_quotas where username in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TABLESPACE_NAME from dba_segments where OWNER in &_KEEP_USERS and OWNER not in &_SKIP_USERS
        union
        select DEFAULT_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TEMPORARY_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and username not in &_SKIP_USERS
      )
    order by 1) loop
	if t.BIGFILE = 'NO'  then my_DDL:='CREATE TABLESPACE "' || t.tablespace_name || '"'; END IF;
	if t.BIGFILE = 'YES' then my_DDL:='CREATE BIGFILE TABLESPACE "' || t.tablespace_name || '"'; END IF;
    if t.block_size != 8192 THEN
      my_DDL:=my_DDL || '" BLOCKSIZE ' || t.block_size;
    end if;
    my_DDL:=my_DDL || ' DATAFILE';
    for d in (select * from dba_data_files df where df.tablespace_name=t.tablespace_name) loop
--     my_DDL:=my_DDL || chr(13) || chr(10) || '  ';
     my_DDL:=my_DDL || chr(10) || '    ';
      if my_db_create_file_dest IS NULL then
        my_DDL:=my_DDL || '''' || replace(d.file_name,'&_FILE_NAME_REPLACE_1_Before','&_FILE_NAME_REPLACE_1_After') ||  '''';
      end if;
      my_DDL:=my_DDL || ' SIZE ' || d.bytes;
      if d.autoextensible='YES' then
        my_DDL:=my_DDL || ' AUTOEXTEND ON NEXT ' || d.increment_by*t.block_size || ' MAXSIZE ' || d.maxbytes;
      else
        my_DDL:=my_DDL || ' AUTOEXTEND OFF';
      end if;
      my_DDL:=my_DDL || ',';
    end loop;
    my_DDL:=rtrim(my_DDL,',');
--    my_DDL:=my_DDL || chr(13) || chr(10) || '  ';
    my_DDL:=my_DDL || chr(10) || '  ';
    my_DDL:=my_DDL || 'EXTENT MANAGEMENT ' || t.extent_management;
    if t.extent_management='LOCAL' then
      case t.allocation_type
      when 'SYSTEM'  then my_DDL:=my_DDL || ' AUTOALLOCATE';
      when 'UNIFORM' then my_DDL:=my_DDL || ' UNIFORM SIZE ' || t.next_extent;
      end case;
      my_DDL:=my_DDL || ' SEGMENT SPACE MANAGEMENT ' || t.SEGMENT_SPACE_MANAGEMENT;
    end if;
    my_DDL:=my_DDL || ' ' || t.status || ';';
    dbms_output.put_line(my_DDL);
  end loop;

  for t in (select * from dba_tablespaces where contents='TEMPORARY' and tablespace_name in
      (
        select TABLESPACE_NAME from dba_ts_quotas where username in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TABLESPACE_NAME from dba_segments where OWNER in &_KEEP_USERS and OWNER not in &_SKIP_USERS
        union
        select DEFAULT_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and username not in &_SKIP_USERS
        union
        select TEMPORARY_TABLESPACE from dba_users where USERNAME in &_KEEP_USERS and username not in &_SKIP_USERS
      )
  order by 1) loop
    my_DDL:='CREATE TEMPORARY TABLESPACE "' || t.tablespace_name || '"';
    if t.block_size != 8192 THEN
      my_DDL:=my_DDL || '"  BLOCKSIZE ' || t.block_size;
    end if;
    my_DDL:=my_DDL || ' TEMPFILE ';
    for d in (select * from dba_temp_files tf where tf.tablespace_name=t.tablespace_name) loop
--      my_DDL:=my_DDL || chr(13) || chr(10) || '  ';
      my_DDL:=my_DDL || chr(10) || '    ';
      if my_db_create_file_dest IS NULL then
        my_DDL:=my_DDL || '''' || d.file_name ||  '''';
      end if;
      my_DDL:=my_DDL || ' SIZE ' || d.bytes;
      if d.autoextensible='YES' then
        my_DDL:=my_DDL || ' AUTOEXTEND ON NEXT ' || d.increment_by*t.block_size || ' MAXSIZE ' || d.maxbytes;
      else
        my_DDL:=my_DDL || ' AUTOEXTEND OFF';
      end if;
      my_DDL:=my_DDL || ',';
    end loop;
    my_DDL:=rtrim(my_DDL,',');
--    my_DDL:=my_DDL || chr(13) || chr(10) || '  ';
    my_DDL:=my_DDL || chr(10) || '  ';
    my_DDL:=my_DDL ||  'EXTENT MANAGEMENT LOCAL  UNIFORM SIZE ' || t.next_extent || ';';
    dbms_output.put_line(my_DDL);
  end loop;
end;
/
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF



PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._20_CreateProfiles.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Creazione profili
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 20_CreateProfiles.lst
PROMPT
set long 2000000000
set lines 4000
execute dbms_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
declare
  ddl long; --VARCHAR2(4000);
begin
  for p in (SELECT DISTINCT profile from DBA_PROFILES where profile in &_KEEP_PROFILES and profile not in &_SKIP_PROFILES order by 1) loop
    SELECT DBMS_METADATA.GET_DDL('PROFILE',p.profile) into ddl from DUAL;
    --dbms_output.put_line(ddl);
	p_##_PRINT_LINES(ddl,chr(10),255);
  end loop;
end;
/
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF



PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._30_CreateRoles.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Creazione ruoli
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 30_CreateRoles.lst
PROMPT
set long 2000000000
set lines 4000
execute dbms_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
declare
  ddl long; --VARCHAR2(4000);
begin
  for r in (SELECT role from DBA_ROLES where role in (SELECT GRANTED_ROLE from DBA_ROLE_PRIVS where GRANTEE IN &_KEEP_USERS) and role in &_KEEP_ROLES and role not in &_SKIP_ROLES order by 1) loop
    SELECT DBMS_METADATA.GET_DDL('ROLE',role) into ddl from DBA_ROLES where role=r.role;
        --dbms_output.put_line(ddl);
	    p_##_PRINT_LINES(ddl,chr(10),255);
        BEGIN
                SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT',grantee) into ddl from DBA_SYS_PRIVS where grantee=r.role and rownum=1;
                --dbms_output.put_line(ddl);
	            p_##_PRINT_LINES(ddl,chr(10),255);
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;
        BEGIN
                SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT',grantee) into ddl from DBA_ROLE_PRIVS where grantee=r.role and rownum=1;
                --dbms_output.put_line(ddl);
	            p_##_PRINT_LINES(ddl,chr(10),255);
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;
        BEGIN
                SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT',grantee) into ddl from DBA_TAB_PRIVS where grantee=r.role and rownum=1;
                --dbms_output.put_line(ddl);
	            p_##_PRINT_LINES(ddl,chr(10),255);
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;
  end loop;
end;
/
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF



PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._40_CreateUsers.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Creazione utenti
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 40_CreateUsers.lst
PROMPT
set long 2000000000
set lines 10000
col DDL_CREATE_USERS for a200
col DDL_SYSTEM_GRANTS for a200
col DDL_ROLE_GRANTS for a200
col DDL_OBJECT_GRANTS for a200
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
SELECT DBMS_METADATA.GET_DDL('USER',username) as DDL_CREATE_USERS from DBA_USERS where username in &_KEEP_USERS and username not in &_SKIP_USERS order by username;
SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT',grantee) as DDL_SYSTEM_GRANTS from (SELECT DISTINCT grantee FROM DBA_SYS_PRIVS where grantee in &_KEEP_USERS and grantee not in &_SKIP_USERS order by grantee);
SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT',grantee) as DDL_ROLE_GRANTS from (SELECT DISTINCT grantee FROM DBA_ROLE_PRIVS where grantee in &_KEEP_USERS and grantee not in &_SKIP_USERS order by GRANTEE);
-- sostituito da query specializzate in quanto mischiava OWNER di KEEP_USERS con OWNER Esterni:
-- SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT',grantee) as DDL_OBJECT_GRANTS from (SELECT DISTINCT grantee FROM DBA_TAB_PRIVS where grantee in &_KEEP_USERS and grantee not in &_SKIP_USERS order by GRANTEE);
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF


PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._50_CreatePrivs.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Attribuzione privilegi esterni di ciascun utente/ruolo
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 50_CreatePrivs.lst
PROMPT
set lines 100
select 'GRANT '||p.PRIVILEGE||' ON '||decode(o.OBJECT_TYPE,'DIRECTORY','DIRECTORY ','')||o.OWNER||'.'||o.OBJECT_NAME||' TO '||p.GRANTEE||decode(GRANTABLE,'YES',' WITH GRANT OPTION','')||';' SQL
from dba_tab_privs p, dba_objects o
where p.OWNER=o.OWNER and p.TABLE_NAME=o.OBJECT_NAME
      and (p.grantee in &_KEEP_USERS and p.grantee not in &_SKIP_USERS)
      and (p.OWNER not in &_KEEP_USERS or p.OWNER in &_SKIP_USERS)
order by p.GRANTEE,o.OWNER,o.OBJECT_NAME,p.PRIVILEGE;
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF



PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._60_CreateJavaPrivs.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Attribuzione privilegi JAVA di ciascun utente/ruolo
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 60_CreateJavaPrivs.lst
PROMPT
set lines 500
select 'EXECUTE dbms_java.'||lower(KIND)||'_permission(grantee=>'''||GRANTEE||''', permission_type =>'''||TYPE_NAME||''', permission_name =>'''||NAME||''', permission_action =>'''||ACTION||''');'
from DBA_JAVA_POLICY
where (grantee in &_KEEP_USERS and grantee not in &_SKIP_USERS)
	  OR
      grantee in (select GRANTED_ROLE from DBA_ROLE_PRIVS where GRANTEE IN &_KEEP_USERS AND GRANTEE NOT IN &_SKIP_USERS
      )
order by 1;
/*
PROMPT
select 'EXECUTE dbms_java.'||lower(KIND)||'_policy_permission(grantee=>'''||GRANTEE||''', permission_type =>'''||TYPE_NAME||''', permission_name =>'''||NAME||''', permission_schema =>'''||TYPE_SCHEMA||''');'
from DBA_JAVA_POLICY
where (grantee in &_KEEP_USERS and grantee not in &_SKIP_USERS)
	  OR
      grantee in (select GRANTED_ROLE from DBA_ROLE_PRIVS where GRANTEE IN &_KEEP_USERS AND GRANTEE NOT IN &_SKIP_USERS)
order by 1;
*/
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF



PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._70_AssignTbspQuotas.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Attribuzione quote tablespace
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 70_AssignTbspQuotas.lst
PROMPT
PROMPT set lines 200
PROMPT set pages 0
select 'ALTER USER '|| USERNAME || ' QUOTA '||decode(MAX_BYTES,-1,'UNLIMITED',MAX_BYTES)||' ON '||TABLESPACE_NAME||';' SQL from dba_ts_quotas
where USERNAME IN &_KEEP_USERS AND USERNAME NOT IN &_SKIP_USERS
order by USERNAME,TABLESPACE_NAME;
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF


PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._80_Import.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT IMPORT (importazione dump con impdp o imp in db destinazione)
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
set lines 500
PROMPT spool 80_Import.lst
PROMPT
PROMPT -- SQL per selezionare directory e lanciare export da SQL*Plus:
select 'set lines 200' from dual;
select 'col DIRECTORY_PATH for a100' from dual;
select 'select directory_name,directory_path from dba_directories order by 1;' from dual;
select 'accept TMP_DIRECTORY_NAME PROMPT "Inserire il nome della directory di importazione [default DATA_PUMP_DIR]> " default DATA_PUMP_DIR' from dual;
DECLARE
  my_SQL varchar2(400);
BEGIN
  my_SQL := 'HOST impdp \"/ as sysdba\" DIRECTORY='||chr(38)||'TMP_DIRECTORY_NAME DUMPFILE=&p_DATABASE._save.dmp LOGFILE=imp&p_DATABASE._save.log PARFILE=imp&p_DATABASE..par';
  dbms_output.put_line(my_SQL);
END;
/
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF
spool log/imp&p_DATABASE..par
DECLARE
  my_userlist varchar2(4000);
BEGIN
  for x in (select username from dba_users where username in (&_USER_LIST)) loop
    my_userlist:=my_userlist||x.username||',';
    --dbms_output.put_line(my_userlist);
  end loop;
  my_userlist:=rtrim(my_userlist,',');
  my_userlist:=replace(my_userlist,',',','||CHR(10));
  dbms_output.put_line('SCHEMAS=(');
  dbms_output.put_line(my_userlist);
  dbms_output.put_line(')');
END;
/
spool OFF


PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._90_Compilation.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Compilazione
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 90_Compilation.lst
PROMPT
set lines 200
PROMPT
PROMPT -- Oggetti invalidi
PROMPT set lines 200
PROMPT set pages 0
PROMPT col owner for a30
PROMPT col object_name for a30
PROMPT col subobject_name for a30
select 'SELECT owner, object_type, object_name, subobject_name, status FROM dba_objects WHERE status <> ''VALID'' and owner IN (' from dual;
select ''''||username||''',' from dba_users where username in &_KEEP_USERS and username not in &_SKIP_USERS order by username;
select '''$$$DUMMY$$$'' )' from dual;
select 'ORDER BY owner, object_type, object_name,subobject_name;' from dual;
PROMPT
PROMPT -- Ricompilazione oggetti invalidi
select 'EXEC dbms_utility.compile_schema(schema=>''' || USERNAME || ''',compile_all=>FALSE);' from DBA_USERS where username in &_KEEP_USERS and username not in &_SKIP_USERS order by username;
PROMPT -- Oggetti invalidi
select 'SELECT owner, object_type, object_name, subobject_name, status FROM dba_objects WHERE status <> ''VALID'' and owner IN (' from dual;
select ''''||username||''',' from dba_users where username in &_KEEP_USERS and username not in &_SKIP_USERS order by username;
select '''$$$DUMMY$$$'' )' from dual;
select 'ORDER BY owner, object_type, object_name,subobject_name;' from dual;
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF


PROMPT
PROMPT
spool &p_LOG_FILE_NOEXT._91_UnLockUsers.sql
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT Sblocco utenti
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT PROMPT
PROMPT spool 91_UnLockUsers.lst
PROMPT
PROMPT -- SQL per lock account per impedire ulteriori connessioni degli utenti da eliminare:
select 'ALTER USER "' || USERNAME || '" ACCOUNT UNLOCK;' from DBA_USERS where username in &_KEEP_USERS and username not in &_SKIP_USERS order by username;
PROMPT
PROMPT PROMPT
PROMPT spool OFF
PROMPT PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool OFF



PROMPT Ripresa spool principale
set trims ON
spool &p_LOG_FILE append



---------------------------------------------------------------------------
-- Fine spool
---------------------------------------------------------------------------
PROMPT
PROMPT
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT + Fine
PROMPT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spool off

---------------------------------------------------------------------------
-- Eliminazione viste di supporto
---------------------------------------------------------------------------
DROP VIEW v_##_SYS_PROFILES;
DROP VIEW v_##_KEEP_PROFILES;
DROP VIEW v_##_SYS_ROLES;
DROP VIEW v_##_KEEP_ROLES;
DROP VIEW v_##_SYS_USERS;
DROP VIEW v_##_KEEP_USERS;
DROP FUNCTION f_##_BIGFILE_TBSP;

---------------------------------------------------------------------------
-- Fine esecuzione
---------------------------------------------------------------------------
EXIT

