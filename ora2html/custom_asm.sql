REM Program:	custom_asm.sql
REM 		Oracle ASM PlugIn
REM Version:	1.0.2
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	15-AUG-12 mail@meo.bogliolo.name

set linesize 132
set heading off

select '<P><a id="asm2"></a><h2>ASM Configuration</h2>' h from dual;
select '<P><table border="2">'
 from dual;

select '<tr><td><b>Disk Groups</b>' from dual;
select '<tr><td><b>Disk Group</b>',
 '<td><b>Disk Group#</b>',
 '<td><b>Type</b>',
 '<td><b>Total GB</b>',
 '<td><b>Free GB</b>',
 '<td><b>Used GB</b>',
 '<td><b>Free%</b>',
 '<td><b>Allocation Unit Size</b>',
 '<td><b>State</b>',
 '<td><b>Offline Disks</b>'
from dual;
select '<tr><td>'||name||'<td align="right">'||GROUP_NUMBER||'<td>'||TYPE, 
       '<td align="right">'||round(TOTAL_MB/1024)||'<td align="right">'||round(FREE_MB/1024),
       '<td align="right">'||round((TOTAL_MB-FREE_MB)/1024)||'<td align="right">'||to_char(free_mb/total_mb*100,'999.99'),
       '<td align="right">'||ALLOCATION_UNIT_SIZE||'<td>'||STATE||'<td align="right">'||OFFLINE_DISKS 
from v$asm_diskgroup;
select '</table>' from dual;

select '<p><table border=2><tr><td><b>Usage</b>' from dual;
select '<tr><td><b>Type</b>', '<td><b>Group#</b>',
 '<td><b>GB</b>', '<td><b>Bytes</b>'
from dual;
select '<tr><td>'||type||'<td>', group_number,
   '<td align="right">'||to_char(round(sum(bytes)/(1024*1024*1024)),'999,999,999,999,999,999'),
   '<td align="right">'||to_char(sum(bytes),'999,999,999,999,999,999')
 from v$asm_file
 group by group_number,type
union
select '<tr><td>TOTAL<td>', group_number,
   '<td align="right">'||to_char(round(sum(bytes)/(1024*1024*1024)),'999,999,999,999,999,999'),
   '<td align="right">'||to_char(sum(bytes),'999,999,999,999,999,999')||'<tr><tr><tr>'
 from v$asm_file
 group by group_number
order by group_number,1;
select '</table>' from dual;

select '<P><A NAME="use"></A>' "ASM Clients" from dual;
select '<table border="2">'
 from dual;
select '<tr><td><b>Clients</b>' from dual;
select '<tr><td><b>Disk Group</b>',
 '<td><b>Instance</b>',
 '<td><b>DB Name</b>',
 '<td><b>Status</b>'
from dual;
select '<tr><td>'||a.name||'<td>'||c.instance_name||'<td>'||c.db_name||'<td>'||c.status
from v$asm_diskgroup a JOIN v$asm_client c USING (group_number)
order by a.name, c.instance_name;
select '</table><hr><p>' from dual;
