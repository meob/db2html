# Program:	my2html.schema.sh
# 		MySQL Schema report in HTML for
#
# Version:      1.0.1
# Author:       Bartolomeo Bogliolo meo@bogliolo.name
# Date:         31-JUN-2010
# License:      GPL
#
# Note:
# Init:         1-APR-2006 meo@bogliolo.name
#               Initial version (from the Oracle my2html.sh script)
# 1.0.1:      	31-JUN-2010
#               Bug fixing, added new 5.1 features (not available on previous versions)

USR=root
# Careful with security, Eugene!!
PSS=
HST=localhost
HSTN=localhost
PRT=3306
DBS=test

echo '<html> <head> <title>' $HSTN : $PRT - $DBS \
   ' - my2html MySQL (Schema) Statistics</title></head><body>' > $HSTN.$PRT.$DBS.htm

mysql --user=$USR --password=$PSS --host=$HST --port=$PRT \
   --force --skip-column-names >> $HSTN.$PRT.$DBS.htm <<EOF 2> /dev/null

use information_schema;

select '<h1>MySQL Schema Report </h1>';
select '<h2>$HSTN:$PRT - $DBS </h2>';

select '<P><A NAME="top"></A>' ;
select '<p>Table of contents:' ;
select '<table><tr><td><ul>' ;
select '<li><A HREF="#status">Summary</A></li>' ;
select '<li><A HREF="#obj">Schema/Object Matrix</A></li>' ;
select '<li><A HREF="#tbs">Space Usage</A></li>' ;
select '<li><A HREF="#big">Biggest Objects</A></li>' ;
select '<li><A HREF="#usr">Users</A></li>' ;
select '</ul><td><ul>' ;
select '<li><A HREF="#prc">Processes</A></li>' ;
select '<li><A HREF="#run">Running SQL</A> </li>' ;
select '<li><A HREF="#stor">Stored Routines</A></li>' ;
select '<li><A HREF="#part">Partitioning</A></li>' ;
select '<li><A HREF="#lock">Open Tables / Locks</A> </li>' ;
select '</ul></table><p><hr>' ;
 
select '<P>Statistics generated on: ', now();
select ' by: ', user(), 'as: ',current_user();
 
select 'using: <I><b>my2html.schema.sh</b> v.1.0.l';
select '<br>Software by ';
select '<A HREF="http://www.xenialab.it/meo/web/index1.htm#dwn">Meo</A></I><p><HR>';

select '<P><A NAME="status"></A>';
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>';
select '<tr><td><b>Server</b>', '<td><b>Value</b>';

select '<tr><td>Version :', '<td>', left(version(), locate('-',version())-1)
union
select '<tr><td>Size (MB):',
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
from tables
union
select '<tr><td><b>Schema</b>', '<td>', '<b>Value</b>'
union
select '<tr><td>Schema Size (MB):',
	'<td><p align=right>',
	format(sum(data_length+index_length)/(1024*1024),0)
from tables
where table_schema like '$DBS%'
union
select '<tr><td>Schema Users :',
 '<td align="right">', format(count(*),0)
from mysql.user
where user like '$DBS%'
union
select '<tr><td>Schema Tables :',
	'<td><p align=right>', format(count(*),0)
from tables
where table_schema like '$DBS%' ;
select '</table><p><hr>' ;

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
where sk like '$DBS%'
group by sk with rollup;
drop view test.my_tmp_obj;
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
		if(engine="MyISAM",1,0)),0),
	'<td><p align=right>', format(sum((data_length+index_length)*
		if(engine="InnoDB",1,0)),0)
from tables
where table_schema like '$DBS%'
group by table_schema with rollup;
select '</table><p><hr>' ;

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
where table_schema like '$DBS%'
order by data_length+index_length desc
limit 10;
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
FROM mysql.user d
where user like '$DBS%';
select '<tr>';
select '<tr><td><b>DB Access</b></td></tr>' ;
SELECT '<tr><td>',host, 
	'<td>', db, 
	'<td>', user, 
	'<td>', 
	'<td>', select_priv, 
	'<td>', execute_priv, 
	'<td>', grant_priv
FROM mysql.db d
where user like '$DBS%'
   or db like '$DBS%';
select '<tr>';
select '<tr><td><b>Host Access</b></td></tr>' ;
SELECT '<tr><td>',host, 
	'<td>', db, 
	'<td>', 
	'<td>', 
	'<td>', select_priv, 
	'<td>', execute_priv, 
	'<td>', grant_priv
FROM mysql.host d
where db like '$DBS%';
select '</table><p><hr>' ;

select '<P><A NAME="prc"></A>' ;
select '<P><table border="2"><tr><td><b>Processes</b></td></tr>' ;
select '<tr><td><b>Id</b><td><b>User</b><td><b>Host</b>';
select '<td><b>DB</b><td><b>Command</b><td><b>Time</b><td><b>State</b>';
select '<tr><td>',id,
	'<td>', user,
	'<td>', host,
	'<td>', db,
	'<td>', command,
	'<td>', time,
	'<td>', state
from processlist
where user like '$DBS%'
order by id;
select '</table><p><hr>' ;

select '<P><A NAME="run"></A>' ;
select '<P><table border="2"><tr><td><b>Running SQL</b></td></tr>' ;
select '<tr><td><b>Id</b><td><b>User</b><td><b>Time</b>';
select '<td><b>State</b><td><b>Info</b>';
select '<tr><td>',id,
	'<td>', user,
	'<td>', time,
	'<td>', state,
	'<td>', replace(replace(info,'<','&lt;'),'>','&gt;')
from processlist
where user like '$DBS%'
  and command <> 'Sleep'
order by id;
select '</table><p><hr>' ;

select '<P><A NAME="stor"></A>' ;
select '<P><table border="2"><tr><td><b>Stored Routines</b></td></tr>' ;
select '<tr><td><b>Schema</b>',
 '<td><b>Type</b>',
 '<td><b>Objects</b>' ;
 select '<tr><td>',routine_schema, 
  '<td>', routine_type, 
  '<td>', count(*)
 from routines
 where routine_schema like '$DBS%'
 group by routine_schema, routine_type;
select '</table><p><hr>' ;

select '<P><A NAME="part"></A>' ;
select '<P><table border="2"><tr><td><b>Partitioning</b></td></tr>';
select '<tr><td><b>Schema</b>',
 '<td><b>Partitioned Tables</b>',
 '<td><b>Partitions</b>' ;
select '<tr><td>', table_schema, '<td align=right>',
  count(distinct table_name), '<td align=right>',  count(*)
 from information_schema.partitions
 where partition_name is not null
   and table_schema like '$DBS%'
 group by table_schema;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Partition details</b></td></tr>' ;
select '<tr><td><b>Schema</b>',
 '<td><b>Table</b>',
 '<td><b>Method</b>',
 '<td><b>Partition Count</b>',
 '<td><b>SubPartition Count</b>'
;
select '<tr><td>', table_schema,
	'<td>', table_name,
	'<td>', partition_method, ifnull(subpartition_method,''),
	'<td>', count(distinct partition_name),
	'<td>', count(distinct subpartition_name)
from partitions
where partition_name is not null
  and table_schema like '$DBS%'
group by table_schema, table_name, subpartition_name
order by table_schema, table_name, subpartition_name;
select '</table><p><hr>' ;

select '<P><A NAME="lock"></A>' ;
select '<P><table border="2" width="75%">' ;
select '<tr><td><pre><b>Open Tables/Active Locks</b>' ;
show open tables from $DBS;
select '</pre><p></table><hr>' ;

select '<hr><P>Statistics generated on: ', now();
select '<p>For more info on my2html contact' ;
select '<A HREF="mailto:meo@bogliolo.name">Meo</A>.<p></body></html>' ;

EOF
