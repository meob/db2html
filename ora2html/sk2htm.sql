REM Programma:	sk2html.sql
REM 		Rapporto sulle strutture dati di uno schema
REM Versione:	2.1.5
REM Data:	17-NOV-96
REM Note:
REM Modifiche:	17-JUN-98 mail@meo.bogliolo.name
REM		Versione HTML
REM
REM Modifiche:	17-JUL-99 mail@meo.bogliolo.name
REM		Versione short

rem define OWN="TEST01"
define '&&OWN' from dual;

set space 1
set linesize 80
set pagesize 9999
set long 1024
set feedback off
set verify off
set newpage 2
set heading off
spool sk2html.htm

select '<html> <head> <title>sskHTML Oracle User Schema</title> </head> <body>'
from dual;

select '<h1 align=center>sskHTML Oracle Short User Schema</h1>'
from dual;

select '<P><I>Oracle RDBMS User Schema: <b>sskHTML.sql</b> v.2.1.5'
from dual;
select '<p>Software by ' from dual;
select '<A HREF="https://meoshome.it.eu.org/">Meo</A></I><p><HR>'
from dual;
 
select '<P><A NAME="top"></A>' from dual;
select '<p>Table of contents: <ul>' from dual;
select '<li><A HREF="#usr">User</A></li>' from dual;
select '<li><A HREF="#tab">Table definition</A></li>' from dual;
select '<li><A HREF="#pri">Primary and Unique Keys</A></li>' from dual;
select '<li><A HREF="#for">Foreign Constraints</A></li>' from dual;
select '<li><A HREF="#ind">Indexes</A></li>' from dual;
select '<li><A HREF="#seq">Sequences</A></li>' from dual;
select '<li><A HREF="#syn">Synonyms</A></li>' from dual;
select '<li><A HREF="#pac">Stored Procedures and Packages</A></li>' from dual;
select '</ul><P><HR>' from dual;
 
select '<P><A NAME="usr"></A>' from dual;
select '<P><b>Oracle User: ', substr('&OWN',1,20) || '</b>'
from dual;

select '<P>Date:'|| to_char(sysdate,'DD-MON-YYYY HH24:MI')||'<P><HR>' from dual;
 
select '<P><A NAME="tab"></A>' from dual;
select '<P><table border="2"><tr><td><b>Table Name</b></td>' from dual;
select ' <td><b>Column Name</b></td>' from dual;
select ' <td><b>Data Type</b></td>' from dual;
select ' <td><b>Length</b></td>' from dual;
select ' <td><b>Nulls</b></td>' from dual;
select 
  '<tr><td>'||table_name||'</td>' table_name,
  '<td>'||column_name||'</td>' column_name,
  '<td>'||substr(data_type,1,10)||'</td>' data_type,
  '<td>'||decode(data_type,'DATE','','NUMBER', substr(data_precision,1,5),
     substr(data_length,1,5))||'</td>' length,
  '<td>'||decode(nullable,'N','NOT NULL')||'</td>' nulls
from dba_tab_columns
where owner='&OWN'
order by table_name,column_id;
select '</table><p><hr>' from dual;

select '<P><A NAME="pri"></A>' from dual;
select '<P><table border="2"><tr><td><b>Table Name</b></td>' from dual;
select ' <td><b>Constraint Name</b></td>' from dual;
select ' <td><b>Constraint Type</b></td>' from dual;
select ' <td><b>Column Name</b></td>' from dual;
select 
  '<tr><td>'||rpad(c2.table_name,55)||'</td>' table_name,
  '<td>'||rpad(c1.constraint_name,35)||'</td>' constraint_name,
  '<td>'||rpad(decode(c1.constraint_type,
              'P','Primary key','Unique key'),11)||'</td>' type,
  '<td>'||rpad(c2.column_name,55)||'</td>' column_name
from  dba_constraints c1,dba_cons_columns c2
where c1.table_name in (select table_name from tabs)
and   c1.constraint_type in ('P','U')
and   c1.constraint_name = c2.constraint_name
and c1.owner='&OWN'
and c2.owner='&OWN'
order by c2.table_name,c1.constraint_type,c1.constraint_name,c2.position;
select '</table><p><hr>' from dual;

select '<P><A NAME="for"></A>' from dual;
select '<P><table border="2"><tr><td><b>Foreing Constraint</b></td>' from dual;
select '<tr><td>'||rpad(c1.constraint_name,35)||' : '||rpad(c2.table_name,35)||
' '||rpad(c2.column_name,35)||' => '||rpad(c3.table_name,35)||' '||
rpad(c3.column_name,35)||'</td>' "Foreign keys"
from  dba_constraints c1,dba_cons_columns c2,dba_cons_columns c3
where c1.table_name in (select table_name from tabs)
and   c1.constraint_type = 'R'
and   c1.constraint_name = c2.constraint_name
and   c1.r_constraint_name = c3.constraint_name
and c1.owner='&OWN'
and c2.owner='&OWN'
and c3.owner='&OWN'
order by c2.table_name,c1.constraint_name,c2.position;
select '</table><p><hr>' from dual;

select '<P><A NAME="ind"></A>' from dual;
select '<P><table border="2"><tr><td><b>Index Name</b></td>' from dual;
select ' <td><b>Index Type</b></td>' from dual;
select ' <td><b>Table Name</b></td>' from dual;
select ' <td><b>Column Name</b></td>' from dual;
select
  '<tr><td>'||substr(i.index_name,1,35)||'</td>' index_name,
  '<td>'||rpad(decode(i.uniqueness,'NONUNIQUE',' ', i.uniqueness),35)||'</td>' index_type,
  '<td>'||substr(i.table_name,1,35)||'</td>' table_name,
  '<td>'||substr(column_name,1,35)||'</td>' column_name
from dba_indexes i, dba_ind_columns c
where i.index_name = c.index_name
and i.owner='&OWN'
order by i.table_name, i.index_name, column_position;
select '</table><p><hr>' from dual;

select '<P><A NAME="view"></A>' from dual;
select '<P><table border="2"><tr><td><b>View Name</b></td>' from dual;
select ' <td><b>Text</b></td>' from dual;
select 
  '<tr><td>'||substr(view_name,1,55)||'</td>' view_name, 
  '<td>', text, '</td>'
from dba_views
where owner='&OWN'
order by view_name;
select '</table><p><hr>' from dual;

select '<P><A NAME="seq"></A>' from dual;
select '<P><table border="2"><tr><td><b>Sequence Name</b></td>' from dual;
select 
  '<tr><td>'||substr(sequence_name,1,55)||'</td>' sequence_name
from dba_sequences
where SEQUENCE_OWNER='&OWN'
order by sequence_name;
select '</table><p><hr>' from dual;

select '<P><A NAME="syn"></A>' from dual;
select '<P><table border="2"><tr><td><b>Synonym Name</b></td>' from dual;
select 
  '<tr><td>'||substr(synonym_name,1,55)||'</td>' synonym_name
from dba_synonyms
where owner='&OWN'
order by synonym_name;
select '</table><p><hr>' from dual;


select '<P><A NAME="pac"></A>' from dual;
select '<b>Stored Procedures and Packages</b><p><PRE>'
 from dual;
set linesize 132
select 
  text cod
from dba_source
where owner='&OWN'
order by name,type,line;
select '</pre><p><hr>' from dual;


select '<hr><p>For more info refer to the' from dual;
select '<A HREF="https://meoshome.it.eu.org/">' from dual;
select 'online documentation</A>.' from dual;

select '<p>For more info on sskHTML contact' from dual;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo</A><p>' from dual;
spool off

exit
