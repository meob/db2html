REM Program:	custom_clientv.sql
REM 		Oracle Client Version PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	14-FEB-14 mail@meo.bogliolo.name
REM		First version
REM		
REM		NB Use internal SYS tables and requires Oracle 11g version

column item format a20
column CLIENT_VERSION format a20
column PROGRAM format a30 trunc
column MODULE format a40 trunc
column ALLOCATED_SPACE format 999,999,999,999,999
column owner format a20
column NETWORK_SERVICE_BANNER format a118 trunc
column MOVE_PROC format a40 trunc
set lines 132
set define off

set heading off
select '<P><a id="cust0"></a><a id="cust_cli_ver"></a><h2>Oracle Clients Version</h2><pre>' h from dual; 
set heading on

WITH x AS
 (SELECT DISTINCT ksusenum sid,ksuseclvsn,TRIM(TO_CHAR(ksuseclvsn,'xxxxxxxxxxxxxx')) to_c,
   TO_CHAR(ksuseclvsn,'xxxxxxxxxxxxxx') v
  FROM
    sys.x$ksusecon )
 SELECT x.sid,
   DECODE(to_c,'0','Unknown',TO_NUMBER(SUBSTR(v,8,2),'xx') || '.' ||  -- maj_rel
             SUBSTR(v,10,1)      || '.' ||  -- mnt_rel
             SUBSTR(v,11,2)      || '.' ||  -- ias_rel
             SUBSTR(v,13,1)      || '.' ||  -- ptc_set
             SUBSTR(v,14,2)) client_version,  -- port_mnt
   username,program, module
 FROM x, v$session s
 WHERE x.sid like s.sid AND type != 'BACKGROUND';

set heading off
select '<P><a id="custO"></a><a id="cust_cliver"></a><h3>Connect info</h3>' h from dual; 
set heading on

rem NETWORK_SERVICE_BANNER intresting but seldom useful
select OSUSER, CLIENT_CONNECTION, CLIENT_OCI_LIBRARY, CLIENT_VERSION,
 CLIENT_DRIVER, CLIENT_LOBATTR, 
 count(*)
from v$session_connect_info
group by OSUSER, CLIENT_CONNECTION, CLIENT_OCI_LIBRARY, CLIENT_VERSION,
 CLIENT_DRIVER, CLIENT_LOBATTR
order by 7 desc;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
