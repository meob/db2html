REM Programma:	ebs2html.sql
REM 		Oracle EBS aka Applications report in HTML
REM Versione:	1.0.0
REM Autore:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM Data:	1-APR-09
REM
REM Note:
REM Init:	1-APR-09 mail@meo.bogliolo.name
REM		First version
REM

set space 1
set pagesize 9999
set linesize 80
set heading off
set feedback off
ttitle off
spool ebs2html.htm

select '<html> <head> <title>ebs2html Oracle Applications Statistics</title> </head>'||
 '<body>'
from dual;
select '<h1 align=center>Oracle EBS on '||value||'</h1>'
from sys.v$parameter
where name ='db_name';

select '<P><A NAME="top"></A>' from dual;
select '<table><tr><td><ul>' from dual;
select '<li><A HREF="#status">Summary</A></li>' from dual;
select '<li><A HREF="#rel">Release</A></li>' from dual;
select '<li><A HREF="#langs">Languages/Features</A></li>' from dual;
select '<li><A HREF="#appls">Applications List</A></li>' from dual;
select '<li><A HREF="#users">Users</A></li>' from dual;
select '<li><A HREF="#servers">Servers</A></li>' from dual;
select '<li><A HREF="#nodes">Nodes</A></li>' from dual;
select '<li><A HREF="#url">URL</A></li>' from dual;
select '<li><A HREF="#cproc">Concurrent Processes</A></li>' from dual;
select '<li><A HREF="#cprog">Concurrent Programs count</A></li>' from dual;
select '<li><A HREF="#patches">Patches</A></li>' from dual;
select '<li><A HREF="#bug">Bugs</A></li>' from dual;

select '</ul></table><p><hr>' from dual;
 
select '<P>Statistics generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
from dual;
 
select 'by: '||user
from dual;

select 'using: <I><b>ebs2html.sql</b> v.1.0.0b'
from dual;
select '<br>Software by ' from dual;
select '<A HREF="http://www.xenialab.it/meo/web/index5.htm">Meo</A></I><p>'
from dual;
 
select '<hr><P><A NAME="status"></A>' "Status" from dual;
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>'
 from dual;
select '<tr><td><b>Items (EBS)</b>',
 '<td><b>Value</b>'
from dual;

select '<tr><td>'||' Release :', '<! 12>',
 '<td>'||release_name 
FROM APPLSYS.fnd_product_groups
union
select '<tr><td>'||' Instance : ', '<! 10>',
 '<td>'||applications_system_name 
FROM APPLSYS.fnd_product_groups
union
select '<tr><td>'||' URL :', '<! 14>',
 '<td>'||home_url
from ICX.ICX_PARAMETERS
union
select '<tr><td>'||' Application Servers IP :', '<! 16>',
 '<td>'||server_address
from APPLSYS.FND_APPLICATION_SERVERS
union
select '<tr><td>'||' Defined Users :', '<! 30>',
 '<td align="right">'||to_char(count(*),'999,999,999,999')
from APPLSYS.FND_USER
union
select '<tr><td>'||' Active Users (last year) :', '<! 32>',
 '<td align="right">'||to_char(count(*),'999,999,999,999')
from APPLSYS.FND_USER
where last_logon_date > sysdate-365
union
select '<tr><td>'||' Connected Users :', '<! 34>',
 '<td align="right">'||to_char(count(*),'999,999,999,999')
from apps.icx_sessions
where last_connect > sysdate-1/96
order by 2;

select '<tr><td><b>Items (RDBMS)</b>',
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
select '<tr><td>'||' DB Size (MB) :', '<! 20>',
 '<td align="right">'||to_char(sum(bytes)/(1024*1024),'999,999,999,999')
from sys.dba_data_files
union
select '<tr><td>'||' SGA (MB) :', '<! 24>',
 '<td align="right">'||to_char(sum(value)/(1024*1024),'999,999,999,999')
from sys.v_$sga
union
select '<tr><td>'||' Log archiving :', '<! 26>',
 '<td>'||value
from v$parameter
where name like 'log_archive_start'
union
select '<tr><td>'||' Defined Schemata :', '<! 32>',
 '<td align="right">'||to_char(count(distinct owner),'999,999,999,999')
from dba_objects
where owner not in ('SYS', 'SYSTEM', 'SCOTT')
and object_type = 'TABLE'
union
select '<tr><td>'||' Defined Tables :', '<! 34>',
 '<td align="right">'||to_char(count(*),'999,999,999,999')
from dba_objects
where owner not in ('SYS', 'SYSTEM', 'SCOTT')
and object_type = 'TABLE'
union
select '<tr><td>'||' Defined Users :', '<! 30>',
 '<td align="right">'||to_char(count(*),'999,999,999,999')
from sys.dba_users
union
select '<tr><td>'||' Sessions :', '<! 40>',
 '<td align="right">'||to_char(count(*),'999,999,999,999')
from v$session
union
select '<tr><td>'||' Sessions (active) :', '<! 42>',
 '<td align="right">'||to_char(count(*),'999,999,999,999')
from v$session
where status='ACTIVE'
and type='USER'
order by 2;

select '</table><p><hr>' from dual;

select '<P><A NAME="rel"></A>' from dual;
select '<P><table border="2"><tr><td><b>Release</b><td><b>Type</b><td><b>System</b></tr>' from dual;
SELECT '<tr><td>'||release_name Release, '<td>'||product_group_type GroupType, '<td>'||applications_system_name
FROM APPLSYS.fnd_product_groups;  
select '</table><p><hr>' from dual;

select '<P><A NAME="langs"></A>' from dual;
select '<P><table border="2"><tr><td><b>Features count for Language' from dual;
select '<tr><td><b>Language</b><td><b>Applications Count</b></tr>' from dual;
select '<tr><td>'|| language, '<td>'||count(*)
from APPLSYS.FND_APPLICATION_TL
group by language;
select '</table><p>' from dual;

select '<P><A NAME="appls"></A>' from dual;
select '<P><table border="2"><tr><td><b>Applications List</b></td></tr><tr><td>' from dual;
select application_short_name
from APPLSYS.FND_APPLICATION
order by 1;
select '</table><p><hr>' from dual;

select '<P><A NAME="users"></A>' from dual;
select '<P><A NAME="cusr"></A>' from dual;
select '<P><table border="2"><tr><td><b>Connected User</b></td>',
       '<td><b>Responsability</b>', '<td><b>Login</b>',
       '<td><b>Logout</b>', '<td><b>Machine</b>', '<td><b>Status</b>'
 from dual;
select '<tr><td>'||fnd.user_name, '<td>'||frt.responsibility_name,
 '<td>'||to_char(icx.first_connect,'YYYY-MM-DD hh24:mi') log_ini,
 '<td>'||to_char(icx.last_connect,'YYYY-MM-DD hh24:mi') log_out,
 '<td>'||nod.node_name machine,
 '<td>'||DECODE ((icx.disabled_flag),'N', 'ACTIVE', 'Y', 'INACTIVE') status
from apps.fnd_user fnd, apps.icx_sessions icx, apps.fnd_responsibility_tl frt, apps.fnd_nodes nod
where fnd.user_id = icx.user_id
  and icx.responsibility_id = frt.responsibility_id
  and icx.disabled_flag <> 'Y'
  and trunc(icx.last_connect) = trunc(sysdate)
  and icx.last_connect >= sysdate -(4/24) 
  and frt.language='US'
  and nod.node_id=icx.node_id
order by icx.last_connect desc;
select '</table><p>' from dual;

select '<P><table border="2"><tr><td><b>User</b>',
 '<td><b>Description</b><td><b>Last Logon</b></tr>' from dual;
select '<tr><td>'|| user_name, '<td>'||description, '<td>'||to_char(last_logon_date,'YYYY-MM-DD hh24:mi') 
from APPLSYS.FND_USER
where last_logon_date > sysdate - 366
order by last_logon_date desc;
select '</table><p><hr>' from dual;

select '<P><A NAME="servers"></A>' from dual;
select '<P><table border="2"><tr><td><b>Application Server Address</b><td><b>Description</b></tr>' from dual;
select '<tr><td>'|| server_address, '<td>'||description
from APPLSYS.FND_APPLICATION_SERVERS
order by 1;
select '</table><p>' from dual;

select '<P><A NAME="nodes"></A>' from dual;
select '<P><table border="2"><tr><td><b>Node</b><td><b>IP</b>',
 '<td>Concurrent Process',
 '<td>Forms',
 '<td>Web',
 '<td>Admin',
 '<td>DB'
from dual;
select '<tr><td>'|| node_name,
 '<td>'||server_address,
 '<td>'||support_cp,
 '<td>'||support_forms,
 '<td>'||support_web,
 '<td>'||support_admin,
 '<td>NA'
from APPLSYS.FND_NODES
where node_name <> 'AUTHENTICATION'
order by 1;
select '</table><p>' from dual;

select '<P><A NAME="url"></A>' from dual;
select '<P><table border="2"><tr><td><b>URL</b></td></tr>' from dual;
select '<tr><td>'|| home_url
from ICX.ICX_PARAMETERS;
select '</table><p><hr>' from dual;

select '<P><A NAME="cproc"></A>' from dual;
select '<P><table border="2"><tr><td><b>Concurrent Processor Name</b>',
 '<td><b>Description</b></tr>' from dual;
select '<tr><td>'|| CONCURRENT_PROCESSOR_NAME, '<td>'||description
from APPLSYS.FND_CONCURRENT_PROCESSORS
order by 1;
select '</table><p>' from dual;

select '<P><A NAME="cprog"></A>' from dual;
select '<P><table border="2"><tr><td><b>Concurrent Programs</b></td></tr>' from dual;
select '<tr><td align=right>'|| count(*)
from APPLSYS.FND_CONCURRENT_PROGRAMS;
select '</table><p><hr>' from dual;

select '<P><A NAME="patches"></A>' from dual;
select '<P><table border="2"><tr><td><b>Patches</b></td></tr>' from dual;
select '<tr><td><b>Name</b><td><b>Type</b><td><b>Date</b></tr>' from dual;
select '<tr><td>'||patch_name, '<td>'||patch_type, '<td>'||to_char(trunc(max(creation_date)),'YYYY-MM-DD hh24:mi')
from APPLSYS.AD_APPLIED_PATCHES
group by  patch_name, patch_type
order by  trunc(max(creation_date)) desc, patch_type, patch_name desc;
select '</table><p><hr>' from dual;

select '<P><A NAME="bug"></A>' from dual;
select '<P><table border="2"><tr><td><b>Bugs</b></td></tr>' from dual;
select '<tr><td><b>Release</b><td><b>Application</b><td><b>Count</b></tr>' from dual;
select '<tr><td>'||aru_release_name, '<td>'||application_short_name, '<td>'|| count(*)
from applsys.ad_bugs
group by aru_release_name, application_short_name
order by aru_release_name, application_short_name;
select '</table><p><hr>' from dual;

select '<hr> <P>Statistics generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||'<P>' 
from dual;

select '<p>For more information visit' from dual;
select '<A HREF="http://www.xenialab.it/meo/web/index1.htm#dwn">this site</A>' from dual;
select 'or contact' from dual;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo</A>.<p></body></html>' from dual;

spool off
set newpage 1
exit

