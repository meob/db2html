# Program:	my2html.sh
# 		MySQL (5.x) Database report in HTML
#
# Version:      1.0.6m
# Author:       Bartolomeo Bogliolo mail@meo.bogliolo.name
# Date:         1-MAY-2008
# License:      GPL
#
# Note:
# Init:         1-APR-2006 mail@meo.bogliolo.name
#               Initial version (from the Oracle ora2html.sql script)
# 1.0.1:        1-JUL-2006
#               First online version
# 1.0.2:        1-AUG-2006
#               Minor graphical changes
# 1.0.3:        31-SEP-2006
#               Username & password sample
# 1.0.4:        31-JUN-2007
#               Current connections, used space for Engine type
# 1.0.5:        1-MAY-2008
#               Minor fixing
# 1.0.6:        31-JUN-2008
#               Global Status, replication, locks

USR=root
# Careful with security, Eugene!!
PSS=
HST=127.0.0.1
HSTN=`hostname`
PRT=3306

echo '<html> <head> <title>' $HSTN : $PRT \
   ' - my2html MySQL Statistics</title></head><body>' > $HSTN.$PRT.htm

mysql --user=$USR --password=$PSS --host=$HST --port=$PRT \
   --force --skip-column-names >> $HSTN.$PRT.htm <<EOF

use information_schema;

select '<h1>MySQL Database</h1>';

select '<P><A NAME="top"></A>' ;
select '<p>Table of contents:' ;
select '<table><tr><td><ul>' ;
select '<li><A HREF="#status">Summary Status</A></li>' ;
select '<li><A HREF="#ver">Versions</A></li>' ;
select '<li><A HREF="#eng">Engines</A></li>' ;
select '<li><A HREF="#dbs">Databases</A></li>' ;
select '<li><A HREF="#obj">Schema/Object Matrix</A></li>' ;
select '<li><A HREF="#tbs">Space Usage</A></li>' ;
select '<li><A HREF="#usr">Users</A></li>' ;
select '</ul><td><ul>' ;
select '<li><A HREF="#prc">Processes</A></li>' ;
select '<li><A HREF="#lock">Open Tables / Locks</A></li>' ;
select '<li><A HREF="#big">Biggest Objects</A></li>' ;
select '<li><A HREF="#repl">Replication</A></li>' ;
select '<li><A HREF="#stor">Stored Routines</A></li>' ;
select '<li><A HREF="#par">Configuration Parameters</A></li>' ;
select '<li><A HREF="#gstat">Global Status</A></li>' ;
select '</ul></table><p><hr>' ;
 
select '<P>Statistics generated on: ', now();
select ' by: ', user(), 'as: ',current_user();
 
select 'using: <I><b>my2html.sh</b> v.1.0.6m';
select '<br>Software by ';
select '<A HREF="http://meoshome.it.eu.org/#dwn">Meo</A></I><p><HR>';


select '<P><A NAME="status"></A>';
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>';
select '<tr><td><b>Item</b>', '<td><b>Value</b>';

select '<tr><td>Version :', '<td>', left(version(), locate('-',version())-1)
union
select '<tr><td>DB Size (MB):',
	'<td><p align=right>',
	format(sum(data_length+index_length)/(1024*1024),0)
from tables
union
select '<tr><td>Defined Users :',
 '<td align="right">', format(count(*),0)
from mysql.user
union
select '<tr><td>Defined Schemata :',
 '<td align="right">', count(*)
from schemata
where schema_name not in ('information_schema')
union
select '<tr><td>Defined Tables :',
	'<td><p align=right>', format(count(*),0)
from tables;

select '</table><p><hr>' ;

select '<P><A NAME="ver"></A>';
select '<P><table border="2"><tr><td><b>Versions</b></td></tr>' ;
select '<tr><td>', version();
select '</table><p><hr>' ;
 
select '<P><A NAME="eng"></A>' ;
select '<P><table border="2" width="75%"><tr><td><b>Engines</b></td></tr>';
select '<tr><td>';
select '<pre>' ;
show engines;
select '</pre></table><p><hr>' ;

select '<P><A NAME="dbs"></A>' ;
select '<P><table border="2" width="75%"><tr><td><b>Databases</b></td></tr>';
select '<tr><td>';
select '<pre>' ;
show databases;
select '</pre></table><p><hr>' ;

select '<P><A NAME="obj"></A>' ;
select '<P><table border="2"><tr><td><b>Schema/Object Matrix</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b> Tables</b>',
 '<td><b> Indexes</b>',
 '<td><b> Routines</b>',
 '<td><b> Triggers</b>',
 '<td><b> Views</b>',
 '<td><b> All</b>' ;

drop view if exists test.my_tmp_obj;
create view test.my_tmp_obj as
 select 'T' otype, table_schema sk, table_name name
 from tables
union
 select 'I' otype, constraint_schema sk,
   concat(table_name,'.',constraint_name) name
 from key_column_usage
 where ordinal_position=1
union
 select 'R' otype, routine_schema sk, routine_name name
 from routines
union
 select 'E' otype, trigger_schema sk, trigger_name name
 from triggers
union
 select 'V' otype, table_schema sk, table_name name
 from views ;
select '<tr><td>', sk,
	'<td><p align=right>', sum(if(otype='T',1,0)),
	'<td><p align=right>', sum(if(otype='I',1,0)),
	'<td><p align=right>', sum(if(otype='R',1,0)),
	'<td><p align=right>', sum(if(otype='E',1,0)),
	'<td><p align=right>', sum(if(otype='V',1,0)),
	'<td><p align=right>', count(*)
from test.my_tmp_obj
group by sk with rollup;
drop view test.my_tmp_obj;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Schema Indexes</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b> Type</b>',
 '<td><b> Uniqueness</b>',
 '<td><b> Avg keys</b>',
 '<td><b> Max Keys</b>',
 '<td><b> Count</b>';
select '<tr><td>', table_schema,
        '<td>', index_type,
        '<td>', if(non_unique, 'Not Unique', 'UNIQUE'),
        '<td><p align=right>', avg(seq_in_index),
        '<td><p align=right>', max(seq_in_index),
        '<td><p align=right>', count(*)
from statistics
group by table_schema, index_type, non_unique;
select '</table><p><hr>' ;

select '<P><A NAME="tbs"></A>' ;
select '<P><table border="2"><tr><td><b>Space Usage</b></td></tr>' ;
select '<tr><td><b>Database',
 '<td><b>Row#</b>',
 '<td><b>Data size</b>',
 '<td><b>Index size</b>',
 '<td><b>Total size</b>',
 '<td><b></b>',
 '<td><b>MyISAM</b>',
 '<td><b>InnoDB</b>'
;
select '<tr><td>', table_schema,
	'<td><p align=right>', format(sum(table_rows),0),
	'<td><p align=right>', format(sum(data_length),0),
	'<td><p align=right>', format(sum(index_length),0),
	'<td><p align=right>', format(sum(data_length+index_length),0),
	'<td>',
	'<td><p align=right>', format(sum((data_length+index_length)*
		if(engine='MyISAM',1,0)),0),
	'<td><p align=right>', format(sum((data_length+index_length)*
		if(engine='InnoDB',1,0)),0)
from tables
group by table_schema with rollup;
select '</table><p><hr>' ;

select '<P><A NAME="usr"></A>';
select '<P><table border="2"><tr><td><b>Users</b></td></tr>' ;
select '<tr><td><b>Host</b>',
 '<td><b>DB</b>',
 '<td><b>User</b>',
 '<td><b>Password</b>',
 '<td><b>Select</b>',
 '<td><b>Execute</b>',
 '<td><b>Grant</b>'
;
SELECT '<tr><td>',host, 
	'<td>', 
	'<td>', user, 
	'<td>', if(password<>'','','NO PWD'),
	'<td>', select_priv, 
	'<td>', execute_priv, 
	'<td>', grant_priv
FROM mysql.user d;
select '<tr>';
select '<tr><td><b>DB Access</b></td></tr>' ;
SELECT '<tr><td>',host, 
	'<td>', db, 
	'<td>', user, 
	'<td>', 
	'<td>', select_priv, 
	'<td>', execute_priv, 
	'<td>', grant_priv
FROM mysql.db d;
select '<tr>';
select '<tr><td><b>Host Access</b></td></tr>' ;
SELECT '<tr><td>',host, 
	'<td>', db, 
	'<td>', 
	'<td>', 
	'<td>', select_priv, 
	'<td>', execute_priv, 
	'<td>', grant_priv
FROM mysql.host d;
select '</table><p><hr>' ;

select '<P><A NAME="prc"></A>' ;
select '<P><table border="2" width="100%"><tr><td><b>Processes</b></td></tr>' ;
select '<tr><td><b><pre><b>' ;
select '( id      user   host        db     command   time   state   info )' ;
select '</b>' ;
show processlist;
select '</pre>' ;
select '</table><p><hr>' ;

select '<P><A NAME="lock"></A>' ;
select '<P><table border="2" width="75%"><tr><td><b>Open Tables / Locks</b></td></tr>' ;
select '<tr><td><pre><b>Open Tables / Locks</b>' ;
show open tables;
select '</pre></table><p><hr>' ;

select '<P><A NAME="big"></A>' ;
select '<P><table border="2"><tr><td><b>Biggest Objects</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Object</b>',
 '<td><b>Type</b>',
 '<td><b>Bytes</b>'
;
select '<tr><td>', table_schema,
	'<td>', table_name,
	'<td>T',
	'<td><p align=right>', format(data_length+index_length,0)
from tables
order by data_length+index_length desc
limit 20;
select '</table><p><hr>' ;

select '<P><A NAME="repl"></A>' ;
select '<P><table border="2"><tr><td><b>Replication</b></td></tr>' ;
select '<tr><td><pre><b>Master</b>' ;
show master status;
select '<p>' ;
show binary logs;
select '</pre><tr><td><pre><b>Slave</b>' ;
show slave status\G
select '</pre></table><p><hr>' ;

select '<P><A NAME="stor"></A>' ;
select '<P><table border="2"><tr><td><b>Stored Routines</b></td></tr>' ;
select '<tr><td><b>Schema</b>',
 '<td><b>Type</b>',
 '<td><b>Objects</b>' ;
 select '<tr><td>',routine_schema, 
  '<td>', routine_type, 
  '<td>', count(*)
 from routines
 group by routine_schema, routine_type;
select '</table><p><hr>' ;

select '<P><A NAME="par"></A>' ;
select '<P><table border="2" width="75%"><tr><td><b>MySQL Configuration</b></td></tr>';
select '<tr><td>';
select '<pre>' ;
show variables;
select '</pre></table><p><hr>' ;

select '<P><A NAME="gstat"></A>' ;
select '<P><table border="2" width="75%"><tr><td><b>MySQL Global Status</b></td></tr>';
select '<tr><td>';
select '<pre>' ;
show global status;
select '</pre></table><p><hr>' ;

select '<hr><P>Statistics generated on: ', now();
select '<p>For more info on my2html contact' ;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo Bogliolo</A>.<p></body></html>' ;

EOF
