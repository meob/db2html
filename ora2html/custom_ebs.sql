REM Program:	custom_ebs.sql
REM 		Oracle EBS PlugIn
REM Version:	1.0.2
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	15-AUG-12 mail@meo.bogliolo.name
REM 	    	14-FEB-22 Module names
REM 	    	15-AUG-23 Concurrent program executions, 12.2 online patching

set linesize 132
set heading off

select '<P><a id="cust0"></a><a id="ebs"></a><h2>Oracle EBS Statistics</h2>' h from dual;
select '<hr><P><a id="status"></A>' "Status" from dual;
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>'
 from dual;
select '<tr><td><b>Item</b>',
 '<td><b>Value</b>'
from dual;

select '<tr><td>'||' Instance: ', '<! 10>', '<td>'||applications_system_name 
  FROM APPLSYS.fnd_product_groups;
select '<tr><td>'||' eBS Release :', '<! 12>', '<td>'||release_name 
  FROM APPLSYS.fnd_product_groups;
select '<tr><td>'||' Languages :', '<! 13>', '<td>'
  from dual;
select distinct language
  from APPLSYS.FND_APPLICATION_TL;

select '<tr><td>'||' DB Version :', '<! 13>',
 '<td>'||substr(banner,instr(banner, '.',1,1)-2,11)
from sys.v_$version
where banner like 'Oracle%'
union
select '<tr><td>'||' URL:', '<! 14>',
 '<td>'||home_url
from ICX.ICX_PARAMETERS
union
select '<tr><td>'||' Application Servers IPs:', '<! 16>',
 '<td>'||server_address
from APPLSYS.FND_APPLICATION_SERVERS
union
select '<tr><td>'||' Defined Users :', '<! 30>',
 '<td align="right">'||to_char(count(*),'999,999,999,999')
from APPLSYS.FND_USER
union
select '<tr><td>'||' Active Users (last year):', '<! 32>',
 '<td align="right">'||to_char(count(*),'999,999,999,999')
from APPLSYS.FND_USER
where last_logon_date > sysdate-366
union
select '<tr><td>'||' Connected Users :', '<! 34>',
 '<td align="right">'||to_char(count(*),'999,999,999,999')
from apps.icx_sessions
where last_connect > sysdate-1/96
order by 2;

select '</table><p><hr>' from dual;

select '<P><a id="rel"></A>' from dual;
select '<P><table border="2"><tr><td><b>Release</b><td><b>Type</b><td><b>System</b></tr>' from dual;
SELECT '<tr><td>'||release_name Release, '<td>'||product_group_type GroupType, '<td>'||applications_system_name
FROM APPLSYS.fnd_product_groups;  
select '</table><p>' from dual;

select '<P><a id="langs"></A>' from dual;
select '<P><table border="2"><tr><td><b>Features count for Language' from dual;
select '<tr><td><b>Language</b><td><b>Applications Count</b></tr>' from dual;
select '<tr><td>'|| language, '<td>'||count(*)
  from APPLSYS.FND_APPLICATION_TL
 group by language;
select '</table><p>' from dual;

select '<P><a id="appls"></A>' from dual;
select '<P><table border="2"><tr><td><b>Applications List</b></td></tr><tr><td>' from dual;
select application_short_name
from APPLSYS.FND_APPLICATION
order by 1;
select '</table><p><hr>' from dual;

select '<P><a id="servers"></A>' from dual;
select '<P><table border="2"><tr><td><b>Application Server Address</b><td><b>Description</b></tr>' from dual;
select '<tr><td>'|| server_address, '<td>'||description
from APPLSYS.FND_APPLICATION_SERVERS;
select '</table><p>' from dual;

select '<P><a id="nodes"></A>' from dual;
select '<P><table border="2"><tr><td><b>Node</b><td><b>IP</b>',
 '<td>Concurrent Process',
 '<td>Forms',
 '<td>Web',
 '<td>Admin',
 '<td>DB'
from dual;
-- node_name
select '<tr><td>'|| host,
 '<td>'||server_address,
 '<td>'||support_cp,
 '<td>'||support_forms,
 '<td>'||support_web,
 '<td>'||support_admin,
 '<td>NA'
from APPLSYS.FND_NODES
where host is not null;
select '</table><p>' from dual;

select '<P><a id="url"></A>' from dual;
select '<P><table border="2"><tr><td><b>URL</b></td></tr>' from dual;
select '<tr><td>'|| home_url
from ICX.ICX_PARAMETERS;
select '</table><p><hr>' from dual;

select '<P><a id="cproc"></A>' from dual;
select '<P><table border="2"><tr><td><b>Concurrent Processor Name</b>',
 '<td><b>Description</b></tr>' from dual;
select '<tr><td>'|| CONCURRENT_PROCESSOR_NAME, '<td>'||description
from APPLSYS.FND_CONCURRENT_PROCESSORS
order by 1;
select '</table><p>' from dual;

select '<P><a id="cprog"></A>' from dual;
select '<P><table border="2"><tr><td><b>Concurrent Programs</b></td></tr>' from dual;
select '<tr><td align=right>'|| count(*)
from APPLSYS.FND_CONCURRENT_PROGRAMS;
select '</table><p>' from dual;

select '<P><a id="reqs"></A>' from dual;
select '<P><table border="2"><tr><td><b>Concurrent Requests</b></td></tr>' from dual;
select '<tr><td><b>Requests</b> <td><b>Phase</b><td><b>Phase description</b> <td><b>Status</b><td><b>Status description</b>' from dual;
select '<tr><td align=right>'||count(*),
       '<td>'||PHASE_CODE,
       '<td>'||decode(PHASE_CODE, 'C','Completed', 'I','Inactive',
              'P','Pending', 'R','Running', 'Other'),
       '<td>'||STATUS_CODE, 
       '<td>'||decode(STATUS_CODE, 'A','Waiting', 'B','Resuming',
              'C','Normal', 'D','Cancelled', 'E', 'Error',  'F', 'Scheduled',
              'G','Warning', 'H','On Hold', 'I', 'Normal',  'M', 'No Manager',
              'Q','Standby', 'R','Normal', 'S', 'Suspended',  'T', 'Terminating',
              'U','Disabled', 'W','Paused', 'X', 'Terminated',  'Z', 'Waiting',
              'Other')
  from APPLSYS.FND_CONCURRENT_REQUESTS
 group by PHASE_CODE, STATUS_CODE
 order by count(*) desc ;
select '</table><p>' from dual;


select '<P><a id="exec"></A>' from dual;
select '<P><table border="2"><tr><td><b>Last hour executions</b></td></tr>' from dual;
select '<tr><td><b>Program Name</b> <td><b>ReqID</b><td><b>Started</b><td><b>Completed</b>' from dual;
select '    <td><b>Phase</b> <td><b>Status</b><td><b>Arguments</b><td><b>User</b>' from dual;
SELECT distinct '<tr><td>'||ft.user_concurrent_program_name,
       '<td>'||fr.REQUEST_ID,
       '<td>'||to_char(fr.ACTUAL_START_DATE,'yyyy-mm-dd hh24:mi:ss'),
       '<td>'||to_char(fr.ACTUAL_COMPLETION_DATE,'yyyy-mm-dd hh24:mi:ss'),
       '<td>'||decode(fr.PHASE_CODE, 'C','Completed', 'I','Inactive',
              'P','Pending', 'R','Running', 'Other'),
       '<td>'||decode(fr.STATUS_CODE, 'A','Waiting', 'B','Resuming',
              'C','Normal', 'D','Cancelled', 'E', 'Error',  'F', 'Scheduled',
              'G','Warning', 'H','On Hold', 'I', 'Normal',  'M', 'No Manager',
              'Q','Standby', 'R','Normal', 'S', 'Suspended',  'T', 'Terminating',
              'U','Disabled', 'W','Paused', 'X', 'Terminated',  'Z', 'Waiting',
              'Other'),
       '<td>'||fr.argument_text,
       '<td>'||fu.user_name
  FROM apps.fnd_concurrent_requests fr, apps.fnd_concurrent_programs fp,
       apps.fnd_concurrent_programs_tl ft, apps.fnd_user fu
 WHERE fr.CONCURRENT_PROGRAM_ID = fp.CONCURRENT_PROGRAM_ID
   AND fr.actual_start_date >= (sysdate - 0.04)
   AND fr.PROGRAM_APPLICATION_ID = fp.APPLICATION_ID
   AND ft.concurrent_program_id=fr.concurrent_program_id
   AND fr.REQUESTED_BY=fu.user_id
 order by '<td>'||to_char(fr.ACTUAL_START_DATE,'yyyy-mm-dd hh24:mi:ss') desc; 
select '</table><p><hr>' from dual;


select '<P><a id="users"></A>' from dual;
select '<P><table border="2"><tr><td><b>Active EBS Users</b>',
 '<td><b>Description</b><td><b>Last Logon</b><td><b>Created on</b>' from dual;
select '<tr><td>'|| user_name, '<td>'||description, '<td>'||last_logon_date,
       '<td>'||CREATION_DATE
  from APPLSYS.FND_USER
 where last_logon_date > sysdate - 366
 order by last_logon_date desc;
select '</table><p><hr>' from dual;

select '<P><a id="modules"></A>' from dual;
select '<P><table border="2"><tr><td><b>Modules</b></td></tr>' from dual;
select '<tr><td><b>Short Name</b><td><b>Name</b><td><b>Patch Level</b><td><b>Installed/Shared</b></tr>' from dual;
select distinct '<tr><td>'||FAP.APPLICATION_SHORT_NAME,
       '<td>'||FAT.APPLICATION_NAME, '<td>'||FPI.PATCH_LEVEL,
       '<td>'||DECODE(FPI.STATUS,'I','  Installed', 'S','  Shared', 'N', ' Inactive', FPI.STATUS) St
  FROM APPS.fnd_product_installations FPI, APPLSYS.FND_APPLICATION FAP, APPS.fnd_application_tl FAT
 WHERE FPI.APPLICATION_ID = FAT.APPLICATION_ID
   AND FPI.APPLICATION_ID = FAP.APPLICATION_ID
   AND FAT.LANGUAGE='US' AND FPI.STATUS in ('I', 'S')
 ORDER BY 4,1;
select '</table><p><hr>' from dual;

select '<P><a id="patches"></A>' from dual;
select '<P><table border="2"><tr><td><b>Patches</b></td></tr>' from dual;
select '<tr><td><b>Name</b><td><b>Type</b><td><b>Date</b></tr>' from dual;
select '<tr><td>'||patch_name, '<td>'||patch_type, '<td>'||to_char(max(creation_date),'YYYY-MM-DD HH24:MI:SS')
from APPLSYS.AD_APPLIED_PATCHES
group by  patch_name, patch_type
order by  max(creation_date) desc, patch_type, patch_name desc;
select '<tr><td>TOTAL<td>'||patch_type, '<td align="right">'||count(*)
  from APPLSYS.AD_APPLIED_PATCHES
 group by patch_type
 order by patch_type;
select '<tr><td>TOTAL<td>*<td align="right">'
  from APPLSYS.AD_APPLIED_PATCHES
 group by  patch_name, patch_type;
select '</table><p>' from dual;

select '<P><a id="bug"></A>' from dual;
select '<P><table border="2"><tr><td><b>Bugs</b></td></tr>' from dual;
select '<tr><td><b>Release</b><td><b>Application</b><td><b>Count</b>' from dual;
select '<tr><td>'||aru_release_name, '<td>'||application_short_name, '<td align=right>'|| count(*)
  from applsys.ad_bugs
 group by aru_release_name, application_short_name
 order by aru_release_name, application_short_name;
select '<tr><td>TOTAL<td><td align=right>'|| count(*)
  from applsys.ad_bugs;
select '</table><p>' from dual;

select '<P><a id="spatch"></A>' from dual;
select '<P><table border="2"><tr><td><b>Patch sessions</b></td></tr>' from dual;
select '<tr><td><b>Session</b><td><b>Bug number</b><td><b>Type</b>' from dual;
select '    <td><b>Status</b><td><b>Start</b><td><b>End</b>' from dual;
SELECT '<tr><td>'||adop_session_id, '<td>'||bug_number, '<td>'||session_type, 
       '<td>'||DECODE(status,'N','Applied on other nodes', 'R','Running', 'H','Failed (Hard)',
                     'F','Failed (Jobs Skipped)', 'S','Success (Jobs Skipped)', 'Y','Success',
                     'C','Clone Complete') status,
       '<td>'||to_char(start_date, 'yyyy-mm-dd hh24:mi:ss') patch_start, 
       '<td>'||to_char(end_date, 'yyyy-mm-dd hh24:mi:ss') patch_end 
--       ,applied_file_system_base, patch_file_system_base,
--       node_name, start_date, end_date, 
--       ROUND((end_date - start_date) * 24*60,2) exec_time,
--       adpatch_options, autoconfig_status, driver_file_name
  FROM applsys.ad_adop_session_patches
 WHERE session_type IN ('ADPATCH','HOTPATCH','DOWNTIME','ONLINE')
 ORDER BY adop_session_id, end_date;
select '</table><p>' from dual;
-- select ad_patch.is_patch_applied('R12',-1, 69696969) from dual;  -- R12.2 check

--  Auditing   FND_LOGIN_RESP_FORMS   FND_LOGIN_RESPONSIBILITIES   FND_LOGINS   FND_UNSUCCESSFUL_LOGIN   FND_APPL_SESSIONS

select '</pre>' from dual;

select '<p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;




