REM Programma:	baan_htm.sql
REM 		Struttura del database Oracle in formato HTML
REM Versione:	1.1.1
REM Autore:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM Data:	1-JAN-99
REM
REM Note:
REM Init:	
REM 		15-AUG-98 mail@meo.bogliolo.name
REM		First release
REM
REM 		1-JAN-99 mail@meo.bogliolo.name
REM		HTML formatting

set space 1
set pagesize 9999
set linesize 80
set heading off
set feedback off
ttitle off
spool baanhtm.htm


select '<html> <head> <title>baanHTM Oracle Statistics</title> </head>'||
 '<body background="fondonew.gif" bgcolor="#FFFFB7">'
from dual;
select '<h1 align=center>BAAN Oracle configuration</h1>'
from dual;

select '<P>This document contains information on the BAAN installation on'
from dual;
select 'Oracle.'
from dual;

select '<P><A NAME="top"></A>' from dual;
select '<p>Table of contents: <ul>' from dual;
select '<li><A HREF="#com">Companies</A></li>' from dual;
select '<li><A HREF="#tbs">Tables physical distribution</A></li>' from dual;
select '<li><A HREF="#idx">Indexes physical distribution</A></li>' from dual;
select '<li><A HREF="#big">Biggest tables</A></li>' from dual;
select '<li><A HREF="#fra">Most fragmented objects</A></li>' from dual;
select '<li><A HREF="#was">Wasted space</A></li>' from dual;
select '</ul><P><HR>' from dual;
 
select '<P>Statistics generated on: '||
 to_char(sysdate,'DD-MON-YYYY HH24:MI')||'<P>' 
from dual;
 
select '<P><I>Baan on Oracle: <b>baan2HTM.sql</b> v.1.1.1'
from dual;
select '<p>Software by ' from dual;
select '<A HREF="http://www.xenialab.it/meo/web/index1.htm">Meo</A></I><p><HR>'
from dual;
 
select '<P><A NAME="com"></A>' from dual;
select '<P><table border="2"><tr><td><b>Companies</b></td></tr>' from dual;
select '<tr><td><b>Company',
 '<td><b># Tables</b>'
from dual;
select '<tr><td>'||substr(table_name,10,3) company,
  '<td align="right">'||to_char(count(*)) tab_count
 from user_tables
 group by substr(table_name,10,3);
select '</table><p><hr>' from dual;

select '<P><A NAME="tbs"></A>' from dual;
select '<P><table border="2">'
from dual;
select '<tr><td><b>Tables physical distribution</b></td></tr>' 
 from dual;
select '<tr><td><b>Company',
 '<td><b>Tablespace</b>',
 '<td><b># Tables</b>'
from dual;
select '<tr><td>'||substr(table_name,10,3) company,
  '<td>'||tablespace_name tab_space,
  '<td align="right">'||to_char(count(*)) tab_count
 from user_tables
 group by substr(table_name,10,3), tablespace_name;
select '</table><p><hr>' from dual;

select '<P><A NAME="idx"></A>' from dual;
select '<P><table border="2">'
from dual;
select '<tr><td><b>Indexes physical distribution</b></td></tr>' 
 from dual;
select '<tr><td><b>Company',
 '<td><b>Tablespace</b>',
 '<td><b># Indexes</b>'
from dual;
select '<tr><td>'||substr(index_name,10,3) company,
  '<td>'||tablespace_name tab_space,
  '<td align="right">'||to_char(count(*)) tab_count
 from user_indexes
 group by substr(index_name,10,3), tablespace_name;
select '</table><p><hr>' from dual;

select '<P><A NAME="big"></A>' from dual;
select '<P><table border="2">' from dual;
select '<tr><td><b>Biggest tables (record count)</b></td></tr>' from dual;
select '<tr><td><b>Table</b>',
 '<td><b># Record</b>'
from dual;
select  '<tr><td>'||table_name, 
	'<td align="right">'||to_char(num_rows)
from user_tables
where num_rows*10 > (select max(num_rows) from user_tables)
order by num_rows desc;
select '</table><p><hr>' from dual;

select '<P><A NAME="fra"></A>' from dual;
select '<P><table border="2">' from dual;
select '<tr><td><b>Most fragmented objects (>50 exts)</b></td></tr>' from dual;
select '<tr><td><b>Object</b>',
 '<td><b># Extents</b>',
 '<td><b>Bytes</b>'
from dual;
select '<tr><td>'||substr(segment_name,1,20) segment, 
	'<td align="right">'||to_char(count(*)), 
	'<td align="right">'||to_char(sum(bytes))
from user_extents
having count(*)>50
group by segment_name, segment_type
order by count(*) desc;
select '</table><p><hr>' from dual;
 
select '<P><A NAME="was"></A>' from dual;
select '<P><table border="2">' from dual;
select '<tr><td><b>Wasted space (empty blocks)</b></td></tr>' from dual;
select '<tr><td><b>Table</b>',
 '<td><b># Free Blocks</b>', '<td><b># Used Blocks</b>'
from dual;
select  '<tr><td>'||table_name,
        '<td align="right">'||to_char(empty_blocks),
        '<td align="right">'||to_char(blocks)
from user_tables
where empty_blocks*10 > (select max(empty_blocks) from user_tables)
order by empty_blocks desc;
select '</table><p><hr>' from dual;

select '<hr><p>For more info on baan2HTML contact' from dual;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo</A>.<p>' from dual;

select '<p>Web site:<br>' from dual;
select '<A HREF="http://www.xenialab.it/meo/web/index1.htm">Italian WWW tech site</A><p></body></html>'
 from dual;

spool off
set newpage 1

exit

