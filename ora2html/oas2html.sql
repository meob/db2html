REM Programma:	oas2html.sql
REM 		Principali tabelle di OAS 10g (Oracle Application Server)
REM Versione:	2.0.1
REM Autore:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM Data:	1-APR-07
REM
REM Note:
REM Init:	1-APR-98 mail@meo.bogliolo.name
REM		Versione iniziale costruita da gen.sql
REM
REM Meo:	1-APR-07 mail@meo.bogliolo.name
REM		HTML version

set space 1
set pagesize 9999
set linesize 80
set heading off
set feedback off
ttitle off
spool oas2html.htm


select '<html> <head> <title>oas2HTML Oracle Application Server Configuration</title> </head>'||
 '<body>'
from dual;
select '<h1 align=center>'||substr(value,1,20)||'</h1>'
from sys.v$parameter
where name ='db_name';

select '<P>This document contains information on the OAS configuration hosted on the '
from dual;
select 'oracle instance <b>'||value||'</b>.'
from sys.v$parameter
where name ='db_name';

select '<P><A NAME="top"></A>' from dual;
select '<p>Table of contents: <ul>' from dual;
select '<li><A HREF="#ins">Instance</A></li>' from dual;
select '<li><A HREF="#ver">Oracle Versions</A></li>' from dual;
select '<li><A HREF="#papp">Applications (orasso.WWSSO_PAPP_CONFIGURATION_INFO$)</A></li>' from dual;
select '<li><A HREF="#sec">SSO Enabler (orasso.WWSEC_ENABLER_CONFIG_INFO$)</A></li>' from dual;
select '<li><A HREF="#psec">Portal Enabler (portal.WWSEC_ENABLER_CONFIG_INFO$)</A></li>' from dual;
select '<li><A HREF="#lsconf">LS Conf (orasso.WWSSO_LS_CONFIGURATION_INFO_T)</A></li>' from dual;
select '<li><A HREF="#sub">Subscriber (portal.WWSUB_MODEL$)</A></li>' from dual;
select '<li><A HREF="#ias">IAS Schema Versions</A></li>' from dual;
select '</ul><P><HR>' from dual;


select '<P>Statistics generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI')||'<P>' 
from dual;
 
select '<P><I>Oracle Application Server info: <b>oas2HTML.sql</b> v.2.0.1'
from dual;
select '<p>Software by ' from dual;
select '<A HREF="http://www.xenialab.it/meo/web/index1.htm">Meo</A></I><p><HR>'
from dual;
 
select '<P><A NAME="ins"></A>' from dual;
select '<P><b>Oracle Instance: ', substr(value,1,20) || '</b>'
from sys.v$parameter
where name ='db_name';

select '<P><A NAME="ver"></A>' from dual;
select '<P><table border="2"><tr><td><b>Versions</b></td></tr>' from dual;
select '<tr><td>'||banner||'</tr></td>' version from sys.v_$version;
select '</table><p><hr>' from dual;

select '<P><A NAME="papp"></A>' from dual;
select '<P><table border="2"><tr><td><b>Applications</b></td></tr>' from dual;
select '<tr><td><b>Site To</b>',
 '<td><b>Site ID</b>',
 '<td><b>Site Name</b>',
 '<td><b>Enc. Key</b>',
 '<td><b>Enc. Mask</b>',
 '<td><b>URL Cookie</b>',
 '<td><b>Enc. Mask Post</b>',
 '<td><b>Success URL</b>',
 '<td><b>Failure URL</b>',
 '<td><b>Home URL</b>',
 '<td><b>Logout URL</b>'
from dual;
select
 '<tr><td>'||substr(SITE_TOKEN,1,5) ||'<td>'||
 substr(SITE_ID,1,5) ||'<td>'||
 substr(SITE_NAME,1,34) ||'<td>'||
 substr(ENCRYPTION_KEY,1,5), '<td>'||
 substr(ENCRYPTION_MASK_PRE,1,5) ||'<td>'||
 substr(URLCOOKIE_PARAM,1,5) ||'<td>'||
 substr(ENCRYPTION_MASK_POST,1,5), '<td>'||
 substr(SUCCESS_URL,1,50), '<td>'||
 substr(FAILURE_URL,1,50), '<td>'||
 substr(HOME_URL,1,50), '<td>'||
 substr(LOGOUT_URL,1,50) 
from orasso.WWSSO_PAPP_CONFIGURATION_INFO$;
select '</table><p><hr>' from dual;

select '<P><A NAME="sec"></A>' from dual;
select '<P><table border="2"><tr><td><b>SSO Enabler</b></td></tr>' from dual;
select '<tr><td><b>Site Token</b>',
 '<td><b>Site ID</b>',
 '<td><b>LSNR Token</b>',
 '<td><b>Enc. Key</b>',
 '<td><b>Enc. Mask</b>',
 '<td><b>Enc. Mask Post</b>',
 '<td><b>URL Check</b>',
 '<td><b>Login URL</b>'
from dual;
select
 '<tr><td>'||substr(SITE_TOKEN,1,5) ||'<td>'||
 substr(SITE_ID,1,5) ||'<td>'||
 substr(LSNR_TOKEN,1,34) ||'<td>'||
 substr(ENCRYPTION_KEY,1,5) ||'<td>'||
 substr(ENCRYPTION_MASK_PRE,1,5) ||'<td>'||
 substr(ENCRYPTION_MASK_POST,1,5) ||'<td>'||
 substr(URL_COOKIE_IP_CHECK,1,5) ||'<td>'||
 substr(LS_LOGIN_URL,1,70)
from orasso.WWSEC_ENABLER_CONFIG_INFO$;
select '</table><p><hr>' from dual;

select '<P><A NAME="psec"></A>' from dual;
select '<P><table border="2"><tr><td><b>Portal Enabler</b></td></tr>' from dual;
select '<tr><td><b>Site Token</b>',
 '<td><b>Site ID</b>',
 '<td><b>LSNR Token</b>',
 '<td><b>Enc. Key</b>',
 '<td><b>Enc. Mask</b>',
 '<td><b>Enc. Mask Post</b>',
 '<td><b>URL Check</b>',
 '<td><b>Login URL</b>'
from dual;
select
 '<tr><td>'||substr(SITE_TOKEN,1,5) ||'<td>'||
 substr(SITE_ID,1,5) ||'<td>'||
 substr(LSNR_TOKEN,1,34) ||'<td>'||
 substr(ENCRYPTION_KEY,1,5) ||'<td>'||
 substr(ENCRYPTION_MASK_PRE,1,5) ||'<td>'||
 substr(ENCRYPTION_MASK_POST,1,5) ||'<td>'||
 substr(URL_COOKIE_IP_CHECK,1,5) ||'<td>'||
 substr(LS_LOGIN_URL,1,70) 
from portal.WWSEC_ENABLER_CONFIG_INFO$;
select '</table><p><hr>' from dual;

select '<P><A NAME="lsconf"></A>' from dual;
select '<P><table border="2"><tr><td><b>LS Conf</b></td></tr>' from dual;
select '<tr><td><b>Subscriber ID</b>',
 '<td><b>Login URL</b>'
from dual;
select
 '<tr><td>'||SUBSCRIBER_ID ||'<td>'||
 substr(LOGIN_URL,1,60) 
from orasso.WWSSO_LS_CONFIGURATION_INFO_T;
select '</table><p><hr>' from dual;

select '<P><A NAME="sub"></A>' from dual;
select '<P><table border="2"><tr><td><b>Subscriber</b></td></tr>' from dual;
select '<tr><td><b>Subscriber ID</b>',
 '<td><b>Name</b>',
 '<td><b>Distinguish Name (DN)</b>',
 '<td><b>Subscriber URL</b>'
from dual;
select
 '<tr><td>'||SUBSCRIBER_ID ||'<td>'||
 substr(SUBSCRIBER_NAME,1,20) ||'<td>'||
 substr(DN,1,20) ||'<td>'||
 substr(SUBSCRIBER_URL_PATH,1,20)
from portal.WWSUB_MODEL$;
select '</table><p><hr>' from dual;

select '<P><A NAME="ias"></A>' "IAS" from dual;
select '<P><table border="2"><tr><td><b>IAS Schemas Versions</b></td></tr>'
 from dual;
select '<tr><td><b>Schema</b>',
 '<td><b>Version</b>'
from dual;
select '<tr><td>'||component_name||'<td>'||id||'<td>'||version
from ias_versions
order by 1; 
select '</table><p><hr>' from dual;

select '<hr><p>For more info on this statistics ' from dual;
select 'refer to the' from dual;
select '<A HREF="http://www.xenialab.it/meo/web/index1.htm">' from dual;
select 'online documentation</A>.' from dual;

select '<p>For more info on oas2HTML contact' from dual;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo</A>.<p></body></html>' from dual;

spool off
exit

