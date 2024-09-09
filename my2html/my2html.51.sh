# Program:	my2html.sh
# 		MySQL (5.1) Database report in HTML
#
# Version:      1.0.8
# Author:       Bartolomeo Bogliolo mail@meo.bogliolo.name
# Date:         1-MAY-2008
# License:      GPL
#
# Note:
# Init:         1-APR-2006 meo@bogliolo.name
#               Initial version (from the Oracle ora2html.sql script)
# 1.0.1:        1-JUL-2006
#               First online version
# 1.0.5.1:      2-JUN-2008
#               5.1 Version: partitioning, scheduler, ...
# 1.0.6:      31-DEC-2008
#               More infos
# 1.0.8:      14-FEB-2014
#               Backported 5.6 statistics and bug solving, reduced index space usage report, user security

USR=root
# Careful with security, Eugene!!
PSS=
HST=127.0.0.1
HSTN=`hostname`
PRT=3306

echo '<html> <head> <title>' $HSTN : $PRT \
   ' - my2html MySQL (5.1) Statistics</title></head><body>' > $HSTN.$PRT.htm

mysql --user=$USR --password=$PSS --host=$HST --port=$PRT \
   --force --skip-column-names >> $HSTN.$PRT.htm <<EOF

use information_schema;

select '<h1>MySQL Database</h1>';

select '<P><a ida id="top"></A>' ;
select '<p>Table of contents:' ;
select '<table><tr><td><ul>' ;
select '<li><A HREF="#status">Summary Status</A></li>' ;
select '<li><A HREF="#ver">Versions</A></li>' ;
select '<li><A HREF="#eng">Engines</A></li>' ;
select '<li><A HREF="#obj">Schema/Object Matrix</A></li>' ;
select '<li><A HREF="#tbs">Space Usage</A></li>' ;
select '<li><A HREF="#sga">Tuning Parameters</A> </li>' ;
select '<li><A HREF="#part">Partitioning</A></li>' ;
select '<li><A HREF="#usr">Users</A></li>' ;
select '   (<A HREF="#usr_sec">Security</A>)' ;
select '<li><A HREF="#prc">Processes</A></li>' ;
select '</ul><td><ul>' ;
select '<li><A HREF="#run">Running SQL</A> </li>' ;
select '<li><A HREF="#lock">Table Locks</A> </li>' ;
select '<li><A HREF="#stat">Performance Statistics</A> </li>' ;
select '<li><A HREF="#big">Biggest Objects</A></li>' ;
select '<li><A HREF="#repl">Replication</A></li>' ;
select '<li><A HREF="#stor">Stored Routines</A></li>' ;
select '<li><A HREF="#sche">Scheduled Jobs</A> </li>' ;
select '<li><A HREF="#par">Configuration Parameters</A></li>' ;
select '<li><A HREF="#gstat">Global Status</A></li>' ;
select '</ul></table><p><hr>' ;
 
select '<P>Statistics generated on: ', now();
select ' by: ', user(), 'as: ',current_user();
 
select 'using: <I><b>my2html.51.sh</b> v.1.0.8';
select '<br>Software by ';
select '<A HREF="http://meoshome.it.eu.org/#dwn">Meo</A></I><p><HR>';

select '<P><a id="status"></A>';
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>';
select '<tr><td><b>Item</b>', '<td><b>Value</b>';

select '<tr><td>Version :', '<td>', version()
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
from tables
union
select '<tr><td>Sessions :',
 '<td align="right">', format(count(*),0)
from processlist
union
select '<tr><td>Sessions (active) :',
 '<td align="right">', format(count(*),0)
from processlist
where command <> 'Sleep'
union
select '<tr><td>Hostname :', '<td>', variable_value
from information_schema.global_variables
where variable_name ='hostname';

select '</table><p><hr>' ;

select '<P><a id="ver"></A>';
select '<P><table border="2"><tr><td><b>Versions</b></td></tr>' ;
select '<tr><td>','MySQL:', variable_value
from information_schema.global_variables
where variable_name ='version'
union
select '<tr><td>plugin:',plugin_name, plugin_version
from plugins
union
select '<tr><td>',concat(variable_name, ': '), variable_value
from information_schema.global_variables
where variable_name like 'version%';
select '</table><p><hr>' ;
 
select '<P><a id="eng"></A>' ;
select '<P><table border="2"><tr><td><b>Engines</b></td></tr>';
select '<tr><td><b>Engine</b>',
 '<td><b> Support</b>',
 '<td><b> Comment</b>';
select '<tr><td>', engine,
	'<td>', support,
	'<td>', comment
from engines
order by support;
select '</table><p><hr>' ;

select '<P><a id="obj"></A>' ;
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

select '<P><table border="2"><tr><td><b>Index Usage</b></td></tr>' ;
select  '<td><b> Type</b>',
 '<td><b> Uniqueness</b>',
 '<td><b> Avg keys</b>',
 '<td><b> Max Keys</b>',
 '<td><b> Count</b>';
select '<tr><td>', index_type,
        '<td>', if(non_unique, 'Not Unique', 'UNIQUE'),
        '<td><p align=right>', avg(seq_in_index),
        '<td><p align=right>', max(seq_in_index),
        '<td><p align=right>', count(*)
from statistics
group by index_type, non_unique;
select '</table><p><hr>' ;

select '<P><a id="tbs"></A>' ;
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
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Data free</b></td></tr>' ;
select '<tr><td><b>Engine',
 '<td><b>Table#</b>',
 '<td><b>Free (MB)</b>';
select '<tr><td>', engine, 
	'<td><p align=right>', count(*),
	'<td><p align=right>', format(data_free/(1024*1024),0)
      from tables
      where engine='InnoDB'
      group by engine, data_free
      order by engine, data_free desc
      limit 8;
select '</table><p><hr>' ;

select '<P><a id="sga"></A>' ;
select '<P><table border="2"><tr><td><b>Tuning Parameters (most used)</b></td></tr>';
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>' ;

select '<tr><td>', variable_name, '<td align=right>', variable_value
from global_variables
where lower(variable_name) in (
'query_cache_type',
'foo')
union
select '<tr><td>', variable_name, '<td align=right>', format(variable_value,0)
from global_variables
where lower(variable_name) in (
'innodb_flush_log_at_trx_commit',
'innodb_buffer_pool_size',
'query_cache_size',
'innodb_additional_mem_pool_size',
'innodb_log_file_size',
'innodb_log_buffer_size',
'innodb_log_files_in_group',
'innodb_lock_wait_timeout',
'innodb_thread_concurrency',
'binlog_cache_size',
'max_connections',
'skip-external-locking',
'read_buffer_size',
'sort_buffer_size',
'key_buffer_size',
'table_open_cache',
'wait_timeout',
'foo')
order by variable_name;
select '</table><p><hr>' ;

select '<P><a id="part"></A>' ;
select '<P><table border="2"><tr><td><b>Partitioning</b></td></tr>';
select '<tr><td><b>Schema</b>',
 '<td><b>Partitioned Tables</b>',
 '<td><b>Partitions</b>' ;
select '<tr><td>', table_schema, '<td align=right>',
  count(distinct table_name), '<td align=right>',  count(*)
 from information_schema.partitions
 where partition_name is not null
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
group by table_schema, table_name, subpartition_name
order by table_schema, table_name, subpartition_name;
select '</table><p><hr>' ;

select '<P><a id="usr"></a>';
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
select '</table><p>' ;

select '<P><a id="usr_sec"></a><table border="2"><tr><td><b>Users with poor security</b></td></tr>' ;
select '<tr><td><b>Host</b>',
 '<td><b>User</b>',
 '<td><b>Password</b>',
 '<td><b>Note</b>'
;
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>',
	'<td>Empty password'
FROM mysql.user
WHERE password='';
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>', password,
	'<td>Same as username'
FROM mysql.user
WHERE password =UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1(user))) AS CHAR)));
-- Known hash: root, secret, password, mypass, public, private, 1234, admin, secure, pass, mysql, my123, ...
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>', password,
	'<td>Weak password'
FROM mysql.user
WHERE password in ('*81F5E21E35407D884A6CD4A731AEBFB6AF209E1B', '*14E65567ABDB5135D0CFD9A70B3032C179A49EE7',
      '*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19', '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4',
      '*A80082C9E4BB16D9C8E41B0D7EED46126DF4A46E', '*85BB02300F877EB061967510E83F68B1A7325252',
      '*A4B6157319038724E3560894F7F932C8886EBFCF', '*4ACFE3202A5FF5CF467898FC58AAB1D615029441',
      '*A36BA850A6E748679226B01E159EF1A7BF946195', '*196BDEDE2AE4F84CA44C47D54D78478C7E2BD7B7',
      '*E74858DB86EBA20BC33D0AECAE8A8108C56B17FA', '*AF35041D44DF3E88C9F97CC8D3ACAF4695E65B69',
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('admin'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('changeme'))) AS CHAR))) );
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>', password,
	'<td>Old [pre 4.1] password format'
FROM mysql.user
WHERE password not like '*%' and password<>'';
select '</table><p>' ;

select '<P><a id="sectab"></A>' ;
select '<P><table border="2"><tr><td><b>Spammable tables</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Object</b>',
 '<td><b>Type</b>',
 '<td><b>Rows</b>',
 '<td><b>MBytes</b>' ;
select '<tr><td>', table_schema,
        '<td>', table_name,
        '<td>T',
        '<td><p align=right>', format(table_rows,0),
        '<td><p align=right>', format((data_length+index_length)/(1024*1024),0)
from tables
where table_name in ('jos_rsgallery2_comments', 'jos_redirection')
and table_rows > 512
order by data_length+index_length desc
limit 20;
select '</table><p><hr>' ;

select '<P><A NAME="prc"></A>' ;
select '<P><table border="2"><tr><td><b>Per-User Processes</b></td></tr>' ;
select '<tr><td><b>User</b><td><b>Database</b><td><b>Count</b>';
select '<tr><td>', user,
	'<td>', db,
	'<td>', count(*)
from processlist
group by user, db
order by 6 desc;
select '<tr><td>TOTAL (', count(distinct user),
	' distinct users)<td>',
	'<td>', count(*)
from processlist;
select '</table><p>' ;

select '<P><a id="prc"></A>' ;
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
order by id;
select '</table><p><hr>' ;

select '<P><a id="run"></A>' ;
select '<P><table border="2"><tr><td><b>Running SQL</b></td></tr>' ;
select '<tr><td><b>Id</b><td><b>User</b><td><b>Time</b>';
select '<td><b>State</b><td><b>Info</b>';
select '<tr><td>',id,
	'<td>', user,
	'<td>', time,
	'<td>', state,
	'<td>', replace(replace(info,'<','&lt;'),'>','&gt;')
from processlist
where command <> 'Sleep'
order by id;
select '</table><p><hr>' ;

select '<P><a id="lock"></A>' ;
select '<P><table border="2" width="75%">' ;
select '<tr><td><pre><b>Table Locks</b>' ;
show open tables WHERE In_use > 0;
select '</pre><p></table><hr>' ;

select '<P><a id="stat"></A>' ;
select '<P><table border="2"><tr><td><b>Performance Statistics</b></td></tr>' ;
select '<tr><td><b>Statistic</b><td><b>Value</b><td><b>Suggested value</b><td><b>Action to correct</b>';
select '<tr><!10><td>', variable_name, '<td align=right>', format(variable_value,0), '<td>LOW', '<td>Check application'
from global_status
where variable_name='SLOW_QUERIES'
union
select '<tr><!69><td>', variable_name, '<td align=right>', format(variable_value,0), '', ''
from global_status
where variable_name='COM_SELECT'
union
select '<tr><!69><td>', variable_name, '<td align=right>', format(variable_value,0), '', ''
from global_status
where variable_name='COM_INSERT'
union
select '<tr><!69><td>', variable_name, '<td align=right>', format(variable_value,0), '', ''
from global_status
where variable_name='COM_UPDATE'
union
select '<tr><!69><td>', variable_name, '<td align=right>', format(variable_value,0), '', ''
from global_status
where variable_name='COM_DELETE'
union
select '<tr><!69><td>', 'COM_* (Other)', '<td align=right>', format(sum(variable_value),0), '', ''
from global_status
where variable_name like 'COM_%'
and variable_name not in ('COM_SELECT','COM_INSERT','COM_UPDATE','COM_DELETE')
union
select '<tr><!01><td>', variable_name, ' (days)<td align=right>', round(variable_value/(3600*24),1), '', ''
from global_status
where variable_name='UPTIME'
union
select '<tr><!20><td>', s.variable_name, '<td align=right>', concat(s.variable_value, '/', v.variable_value),
 '<td>Far from maximum', '<td>Increase MAX_CONNECTIONS'
from global_status s, global_variables v
where s.variable_name='THREADS_CONNECTED'
and v.variable_name='MAX_CONNECTIONS'
union
select '<tr><!15><td>', 'Buffer Cache: MyISAM Read Hit Ratio',
 '<td align=right>', round(100-t1.variable_value*100/t2.variable_value,2), '<td> >95', '<td>Increase KEY_BUFFER_SIZE'
from global_status t1, global_status t2
where t1.variable_name='KEY_READS' and t2.variable_name='KEY_READ_REQUESTS'
union
select '<tr><!16><td>', 'Buffer Cache: InnoDB Read Hit Ratio',
 '<td align=right>', round(100-t1.variable_value*100/t2.variable_value,2), '<td> >95', '<td>Increase INNODB_BUFFER_SIZE'
from global_status t1, global_status t2
where t1.variable_name='INNODB_BUFFER_POOL_READS' and t2.variable_name='INNODB_BUFFER_POOL_READ_REQUESTS'
union
select '<tr><!21><td>', variable_name, '<td align=right>', variable_value, '<td>LOW', '<td>Check user load'
from global_status
where variable_name='THREADS_RUNNING'
order by 1;
select '</table><p><hr>' ;

select '<P><a id="big"></A>' ;
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

select '<P><a id="repl"></A>' ;
select '<P><table border="2"><tr><td><b>Replication</b></td></tr>' ;
select '<tr><td><pre><b>Master</b>' ;
show master status;
select '<p>' ;
show binary logs;
select '</pre><tr><td><pre><b>Slave</b>' ;
show slave status\G
select '</pre></table><p><hr>' ;

select '<P><a id="stor"></A>' ;
select '<P><table border="2"><tr><td><b>Stored Routines</b></td></tr>' ;
select '<tr><td><b>Schema</b>',
 '<td><b>Type</b>',
 '<td><b>Objects</b>'
;
 select '<tr><td>',routine_schema, 
  '<td>', routine_type, 
  '<td>', count(*)
 from routines
 group by routine_schema, routine_type;
select '</table><p><hr>' ;

select '<P><a id="sche"></A>' ;
select '<P><table border="2"><tr><td><b>Scheduler</b></td></tr>' ;
select '<tr><td>', variable_value
from global_variables
where variable_name='EVENT_SCHEDULER';
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Scheduled Jobs</b></td></tr>' ;
select '<tr><td><b>Event</b>',
 '<td><b>Status</b>',
 '<td><b>Type</b>',
 '<td><b>Schedule</b>',
 '<td><b>Command</b>'
;
 select '<tr><td>',concat(event_schema,'.',event_name), 
  '<td>', status,
  '<td>', event_type,
  '<td>', ifnull(execute_at,''),
	ifnull(interval_value,''),ifnull(interval_field,''),
  '<td>', event_definition
 from events;
select '</table><p><hr>' ;

select '<P><a id="par"></A>' ;
select '<P><table border="2"><tr><td><b>MySQL Parameters</b></td></tr>';
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', variable_value
from global_variables
order by variable_name;
select '</table><p><hr>' ;

select '<P><a id="gstat"></A>' ;
select '<P><table border="2"><tr><td><b>MySQL Global Status</b></td></tr>';
select '<tr><td><b>Statistic</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', variable_value
from global_status
order by variable_name;
select '</table><p><hr>' ;

select '<hr><P>Statistics generated on: ', now();
select '<p>For more info on my2html contact' ;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo Bogliolo</A>.<p></body></html>' ;

EOF
