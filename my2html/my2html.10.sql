-- Program:	 my2html.10.sh
--		 MariaDB (10.3+) DBA Database SQL report in HTML
-- Date:         2015-01-01
-- Version:      1.0.22: latest releases (2024-08-15)
-- Author:       Bartolomeo Bogliolo mail@meo.bogliolo.name
-- License:      GPL
--
-- Notes:
-- Init:       1-APR-2006 meo@bogliolo.name
--               Initial version
-- 1.0.13.mar: 1-APR-2018
--               First MariaDB script based on MySQL one
-- 1.0.17:     01-JAN-2020
--               Lastest versions update, SQL scripts for different MySQL/MariaDB, (a) little bugs in users

-- Usage:        mysql --user=$USR --password=$PSS --host=$HST --port=$PRT --force --skip-column-names < my2html.103.sql > $HSTN.$PRT.htm 2> /dev/null

use information_schema;

select '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8" /><link rel="stylesheet" href="ux3.css" /> <title>';
select @@hostname, ':', @@port, '-';
select 'my2html MariaDB (10.3+) Statistics</title></head><body>';

select '<h1>MariaDB Database</h1>';

select '<P><A NAME="top"></A>' ;
select '<p>Table of contents:' ;
select '<table><tr><td><ul>' ;
select '<li><A HREF="#status">Summary Status</A></li>' ;
select '<li><A HREF="#ver">Versions</A></li>' ;
select '<li><A HREF="#eng">Engines</A></li>' ;
select '<li><A HREF="#obj">Schema/Object Matrix</A></li>' ;
select '<li><A HREF="#tbs">Space Usage</A></li>' ;
select '<li><A HREF="#sga">Tuning Parameters</A> </li>' ;
select '<li><A HREF="#part">Partitioning</A></li>' ;
select '<li><A HREF="#usr">Users</A>' ;
select '   (<A HREF="#usr_sec">Security</A>)' ;
select '<li><A HREF="#prc">Processes</A></li>' ;
select '<li><A HREF="#run">Running SQL</A> </li>' ;
select '<li><A HREF="#lock">Table Locks</A> </li>' ;
select '</ul><td><ul>' ;
select '<li><A HREF="#stat_innodb">InnoDB Statistics</A> </li>' ;
select '<li><A HREF="#stat">Performance Statistics</A> (<A HREF="#stat56">Details</A>)</li>' ;
select '<li><A HREF="#big">Biggest Objects</A></li>' ;
select '<li><A HREF="#hostc">Host Statistics</A></li>' ;
select '<li><A HREF="#repl">Replication</A></li>' ;
select '<li><A HREF="#stor">Stored Routines</A></li>' ;
select '<li><A HREF="#sche">Scheduled Jobs</A> </li>' ;
select '<li><A HREF="#nls">NLS</A> </li>' ;
select '<li><A HREF="#par">Configuration Parameters</A></li>' ;
select '<li><A HREF="#gstat">Global Status</A></li>' ;
select '</ul></table><p><hr>' ;
 
select '<P>Statistics generated on: ', now();
select ' by: ', user(), 'as: ',current_user();
 
select 'using: <I><b>my2html.10.sql</b> v.1.0.22';
select '<br>Software by ';
select '<A HREF="http://meoshome.it.eu.org/#dwn">Meo</A></I><p><HR>';

select '<P><A NAME="status"></A>';
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>';
select '<tr><td><b>Item</b>', '<td><b>Value</b>';

select '<tr><td>Version :', '<td>', version()
union
select '<tr><td>Created :', '<td>', min(create_time)
from tables
union
select '<tr><td>Started :', '<td>', date_format(date_sub(now(), INTERVAL variable_value second),'%Y-%m-%d %T')
from global_status
where variable_name='UPTIME'
union
select '<tr><td>DB Size (MB):',
	'<td align=right>',
        format(sum(data_length+index_length)/(1024*1024),0)
from tables
union
select '<tr><td>Buffer Size (MB):',
	'<td align="right">',
	format(sum(variable_value+0)/(1024*1024),0)
from global_variables
where lower(variable_name) like '%buffer_size' or lower(variable_name) like '%buffer_pool_size'
union
select '<tr><td>Logging Bin. :', '<td>', variable_value
from global_status
where variable_name='LOG_BIN'
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
	'<td align=right>', format(count(*),0)
from tables
union
select '<tr><td>Sessions :', '<td align="right">', format(count(*),0)
  from processlist
 union
select '<tr><td>Sessions (active) :', '<td align="right">', format(count(*),0)
  from processlist
 where command <> 'Sleep'
union
select '<tr><td>Questions (#/sec.) :',
 '<td align=right>', format(g1.variable_value/g2.variable_value,5)
  from global_status g1,global_status g2
 where g1.variable_name='QUESTIONS'
   and g2.variable_name='UPTIME'
union
select '<tr><td>BinLog Writes Day (MB) :',
 '<td align=right>', format((g1.variable_value*60*60*24)/(g2.variable_value*1024*1024),0)
  from global_status g1,global_status g2
 where g1.variable_name='INNODB_OS_LOG_WRITTEN'
   and g2.variable_name='UPTIME'
union
select '<tr><td>Hostname :', '<td>', variable_value
  from information_schema.global_variables
 where variable_name ='hostname'
union
select '<tr><td>Port :', '<td>', variable_value
  from information_schema.global_variables
 where variable_name ='port';
select '</table><p><hr>' ;


select '<P><A NAME="ver"></A>';
select '<P><table border="2"><tr><td><b>Version check</b></td></tr>' ;
select '<tr><td><b>Version</b>',
 '<td><b> Supported</b>',
 '<td><b> Last releases (N or LTS)</b>',
 '<td><b> Last updates (N or N-1)</b>',
 '<td><b> Last update (N) </b>',
 '<td><b> Notes</b>';
select '<tr><td>', version();
select ' <td>', if(SUBSTRING_INDEX(version(),'.',2) in ('8.0', '10.11','10.10','10.9','10.8','10.7','10.6','10.5','10.4'), 'YES', 'NO') ; -- supported version BOTH MySQL MariaDB
select ' <td>', if(SUBSTRING_INDEX(version(),'.',2) in ('8.0', '10.11','10.6'), 'YES', 'NO') ; -- last releases or LTS

select ' <td>', if(SUBSTRING_INDEX(version(),'-',1)
    in ('10.11.2','10.10.3','10.9.5','10.8.7','10.7.8','10.6.12','10.5.19','10.4.28','10.3.38',
                  '10.10.2','10.9.4','10.8.6','10.7.7','10.6.11','10.5.18','10.4.27','10.3.37',
        '10.11.3','10.10.4','10.9.6','10.8.8','10.7.9','10.6.13','10.5.20','10.4.29','10.3.39'), 'YES', 'NO') ; -- last2 MariaDB updates (and the next)
select ' <td>', if(SUBSTRING_INDEX(version(),'-',1)
    in ('10.11.2','10.10.3','10.9.5','10.8.7','10.7.8','10.6.12','10.5.19','10.4.28','10.3.38',
        '10.11.3','10.10.4','10.9.6','10.8.8','10.7.9','10.6.13','10.5.20','10.4.29','10.3.39'), 'YES', 'NO') ;  -- last updates (and the next)

select '<td>Latest Releases: <b>8.4.0</b>, <b>8.0.37</b>; 8.3.0,  8.2.0, 8.1.0, <b>5.7.44</b>, 5.6.51, 5.5.62, 5.1.73, 5.0.96'; 
select ' <br>Latest Releases (MariaDB): 11.3.2, 11.2.3, 11.1.4, 11.0.5, <b>10.11.7</b>, 10.10.7, <b>10.6.15</b>, 10.5.22, 10.4.31;';
select '     10.9.8, 10.8.8, 10.7.8, 10.3.39, 10.2.44, 10.1.48, 10.0.38, 5.5.68';
select '</table><p><hr>' ;

select '<P><A NAME="eng"></A>' ;
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

select '<P><A NAME="obj"></A>' ;
select '<P><table border="2"><tr><td><b>Schema/Object Matrix</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b> Tables</b>',
 '<td><b> Indexes</b>',
 '<td><b> Routines</b>',
 '<td><b> Triggers</b>',
 '<td><b> Views</b>',
 '<td><b> Primary Keys</b>',
 '<td><b> Foreign Keys</b>',
 '<td><b> All</b>' ;

select '<tr><td>', sk,
	'<td align=right>', sum(if(otype='T',1,0)),
	'<td align=right>', sum(if(otype='I',1,0)),
	'<td align=right>', sum(if(otype='R',1,0)),
	'<td align=right>', sum(if(otype='E',1,0)),
	'<td align=right>', sum(if(otype='V',1,0)),
	'<td align=right>', sum(if(otype='P',1,0)),
	'<td align=right>', sum(if(otype='F',1,0)),
	'<td align=right>', count(*)
from ( select 'T' otype, table_schema sk, table_name name
  from tables
  union
 select 'I' otype, constraint_schema sk, concat(table_name,'.',constraint_name) name
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
  from views 
  union
 select distinct 'P' otype, CONSTRAINT_SCHEMA sk, TABLE_NAME name
  from KEY_COLUMN_USAGE
  where  CONSTRAINT_NAME='PRIMARY'
  union
 select distinct 'F' otype, CONSTRAINT_SCHEMA sk, concat(TABLE_NAME,'-',CONSTRAINT_NAME) name
  from KEY_COLUMN_USAGE
  where REFERENCED_TABLE_NAME is not null
     ) a
group by sk with rollup;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Index Types</b></td></tr>' ;
select  '<td><b> Type</b>',
 '<td><b> Uniqueness</b>',
 '<td><b> Avg keys</b>',
 '<td><b> Max Keys</b>',
 '<td><b> Count</b>',
 '<td><b> Columns</b>';
select '<tr><td>', index_type,
        '<td>', if(non_unique, 'Not Unique', 'UNIQUE'),
        '<td align=right>', avg(seq_in_index),
        '<td align=right>', max(seq_in_index),
        '<td align=right>', count(distinct table_schema,table_name, index_name),
	'<td align=right>', count(*)
  from statistics
 group by index_type, non_unique;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Orphaned Tables</b></td></tr>' ;
select  '<td><b> Table ID</b>',
 '<td><b> Name</b>',
 '<td><b> Flags</b>',
 '<td><b> Row Format</b>';
select '<tr><td>', TABLE_ID,
        '<td>', NAME,
        '<td>', FLAG,
        '<td>', ROW_FORMAT
  from INNODB_SYS_TABLES
 where name like "%/#%"
 limit 100;
select '</table><p><hr>' ;

select '<P><A NAME="tbs"></A>' ;
select '<P><table border="2"><tr><td><b>Space Usage</b></td></tr>' ;
select '<tr><td><b>Database',
 '<td><b>Row#</b>',
 '<td><b>Data size</b>',
 '<td><b>Index size</b>',
 '<td><b>Free</b>',
 '<td><b>Total size</b>',
 '<td><b></b>',
 '<td><b>MyISAM</b>',
 '<td><b>InnoDB</b>',
 '<td><b>Memory</b>',
 '<td><b>Other Engines</b>',
 '<td><b>Created</b>';
select '<tr><td>', table_schema,
	'<td align=right>', format(sum(table_rows),0),
	'<td align=right>', format(sum(data_length),0),
	'<td align=right>', format(sum(index_length),0),
	'<td align=right>', format(sum(data_free),0),
	'<td align=right>', format(sum(data_length+index_length),0),
	'<td>',
	'<td align=right>', format(sum((data_length+index_length)*
	if(engine='MyISAM',1,0)),0),
	'<td align=right>', format(sum((data_length+index_length)*
	if(engine='InnoDB',1,0)),0),
	'<td align=right>', format(sum((data_length+index_length)*
	if(engine='Memory',1,0)),0),
	'<td align=right>', format(sum((data_length+index_length)*
	if(engine='Memory',0,if(engine='MyISAM',0,if(engine='InnoDB',0,1)))),0),
	'<td>', date_format(min(create_time),'%Y-%m-%d')
from tables
group by table_schema with rollup;
select '</table><p>' ;

select '<P><A NAME="tbs_os"></A>' ;
select '<P><table border="2"><tr><td><b>InnoDB Tablespace OS Space Usage</b></td></tr>' ;
select '<tr><td><b>Database',
 '<td><b>OS size</b>';
select '<tr><td>',SUBSTRING_INDEX(name,'/',1),
	'<td align=right>', format(sum(FILE_SIZE),0)
  from information_schema.INNODB_SYS_TABLESPACES
 group by SUBSTRING_INDEX(name,'/',1) with rollup;
select '</table><p><hr>' ;

select '<P><table border="2"><tr><td><b>Free Space</b></td></tr>' ;
select '<tr><td><b>Engine',
 '<td><b>Table#</b>',
 '<td><b>Free (MB)</b>';
select '<tr><td>', engine, 
	'<td align=right>', count(*),
	'<td align=right>', format(data_free/(1024*1024),0)
      from tables
      where engine='InnoDB'
      group by engine, data_free
      having data_free> 10*1024*1024
      order by engine, data_free desc
      limit 8;
select '<tr><td>', engine, 
	'<td>TOTAL'
	'<td align=right>', format(sum(data_free)/(1024*1024),0)
      from tables
      where data_free>0
      group by engine
      order by engine
      limit 8;
select '</table><p><hr>' ;

select '<P><A NAME="sga"></A>' ;
select '<P><table border="2"><tr><td><b>MySQL Memory Usage</b>';
select '<tr><td><b>Type</b>',
 '<td><b>Value (MB)</b>' ;
select '<tr><td>Global Caches <td align=right>', format(sum(variable_value)/(1024*1024),0)
from global_variables
where lower(variable_name) in (
'innodb_buffer_pool_size',
'query_cache_size',
'innodb_additional_mem_pool_size',
'innodb_log_file_size',
'innodb_log_buffer_size',
'key_buffer_size',
'table_open_cache',
'tmp_table_size');
select '<tr><td>Estimated Client Alloc. (max conn:', g2.variable_value,')<td align=right>',
       format(sum(g1.variable_value*g2.variable_value)/(1024*1024),0)
from global_variables g1, global_status g2
where lower(g1.variable_name) in (
'binlog_cache_size',
'binlog_stmt_cache_size',
'read_buffer_size',
'read_rnd_buffer_size',
'sort_buffer_size',
'join_buffer_size',
'thread_stack')
and lower(g2.variable_name)='max_used_connections';
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Tuning Parameters (most used ones)</b></td></tr>';
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b><td><b>Type</b>' ;
select '<tr><td>', variable_name, '<td align=right>', variable_value, '<td>Flag'
from global_variables
where lower(variable_name) in (
'log_bin',
'query_cache_type',
'slow_query_log',
'foo')
union
select '<tr><td>', variable_name, '<td align=right>', format(variable_value,0), '<td>Cache'
from global_variables
where lower(variable_name) in (
'innodb_buffer_pool_size',
'query_cache_size',
'innodb_additional_mem_pool_size',
'innodb_log_file_size',
'innodb_log_buffer_size',
'key_buffer_size',
'table_open_cache',
'tmp_table_size',
'max_heap_table_size',
'foo')
union
select '<tr><td>', variable_name, '<td align=right>', format(variable_value,0), '<td>Tuning and timeout'
from global_variables
where lower(variable_name) in (
'innodb_flush_log_at_trx_commit',
'innodb_flush_log_at_timeout',
'innodb_log_files_in_group',
'innodb_lock_wait_timeout',
'innodb_thread_concurrency',
'skip-external-locking',
'wait_timeout',
'long_query_time',
'sync_binlog',
'foo')
union
select '<tr><td>', variable_name, '<td align=right>', format(variable_value,0), '<td>Client Cache'
from global_variables
where lower(variable_name) in (
'binlog_cache_size',
'binlog_stmt_cache_size',
'max_connections',
'read_buffer_size',
'read_rnd_buffer_size',
'sort_buffer_size',
'join_buffer_size',
'thread_stack',
'foo')
order by variable_name;
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

select '<P><A NAME="usr"></A>';
select '<P><table border="2"><tr><td><b>Users</b></td></tr>' ;
select '<tr><td><b>Host</b>',
 '<td><b>DB</b>',
 '<td><b>User</b>',
 '<td><b>Password</b>',
 '<td><b>Select</b>',
 '<td><b>Execute</b>',
 '<td><b>Grant</b>',
 '<td><b>Expired</b>';
SELECT '<tr><td>',host, 
	'<td>', 
	'<td>', user, 
	'<td>', if(password<>'','','NO PWD'),
	'<td>', select_priv, 
	'<td>', execute_priv, 
	'<td>', grant_priv,
	'<td>', password_expired
FROM mysql.user d
order by user,host;
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
order by user,host;
select '</table><p>' ;

select '<P><a id="usr_sec"></a><a name="vrole"></a>';
select '<P><table border="2"><tr><td><b>Virtual <i>Roles</i></b></td></tr>' ;
select '<tr><td><b>Access Level</b><td><b>Users</b>' ;
select '<tr><td>Admin<td>' ;
select distinct concat(user,'@',host) User
  from mysql.user
 where insert_priv='Y' or delete_priv='Y'
 order by 1;
select '<tr><td>Oper<td>' ;
select distinct concat(user,'@',host)
  from mysql.user
 where select_priv='Y'
   and concat(user,'@',host) not in (
	select concat(user,'@',host)
	  from mysql.user
	 where insert_priv='Y' or delete_priv='Y')
 order by 1;
select '<tr><td>Schema Owner<td>' ;
select distinct concat(user,'@',host)
  from mysql.db
 where create_priv='Y';
select '<tr><td>CRUD<td>' ;
select distinct concat(user,'@',host)
  from mysql.db
 where insert_priv='Y'
   and concat(user,'@',host) not in (
	select concat(user,'@',host)
	  from mysql.db
	 where create_priv='Y')
 order by 1;
select '<tr><td>Read Only<td>' ; 
select distinct concat(user,'@',host)
  from mysql.db
 where select_priv='Y'
   and concat(user,'@',host) not in (
	select concat(user,'@',host)
	  from mysql.db
	 where insert_priv='Y')
 order by 1;
select '<tr><td>Other<td>' ;
select distinct concat(user,'@',host)
  from mysql.user
 where concat(user,'@',host) not in (
	select concat(user,'@',host)
	  from mysql.db
	 where select_priv='Y')
   and concat(user,'@',host) not in (
	select concat(user,'@',host)
	  from mysql.user
	 where select_priv='Y')
 order by 1;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Users with poor passwords</b></td></tr>' ;
select '<tr><td><b>Host</b>',
 '<td><b>User</b>',
 '<td><b>Password</b>',
 '<td><b>Note</b>';
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
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>', password,
	'<td>Same as username'
FROM mysql.user
WHERE password = BINARY old_password(user);
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
      password('prova'), password('test'), password('demo'), password('qwerty'), password('manager'),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('moodle'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('drupal'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('admin01'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('joomla'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('wp'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('ilikerandompasswords'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('changeme'))) AS CHAR))) );
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>', password,
	'<td>Weak password'
FROM mysql.user
WHERE password in (old_password('root'), old_password('secret'), old_password('password'), old_password('mypass'),
      old_password('public'), old_password('private'), old_password('1234'), old_password('admin'),
      old_password('secure'), old_password('pass'), old_password('mysql'), old_password('my123'),
      old_password('prova'), old_password('test'), old_password('demo'), old_password('qwerty'),
      old_password('manager'), old_password('moodle'), old_password('drupal'), old_password('admin01'),
      old_password('joomla'), old_password('wp'), old_password('ilikerandompasswords'), old_password('changeme') );
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>', password,
	'<td>Old [pre 4.1] password format'
FROM mysql.user
WHERE password not like '*%' and password<>'' and password<>'invalid';
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>', password,
	'<td>Suspect backdoor user'
FROM mysql.user
WHERE user in ('hanako', 'kisadminnew1', '401hk$', 'guest', 'Huazhongdiguo110');
select '</table><p>' ;

select '<P><a id="secsql"></A>' ;
select '<P><table border="2"><tr><td><b>Suspect SQL Statements</b></td></tr>' ;
select '<tr><td><b>Schema</b>',
 '<td><b>Statement</b>',
 '<td><b>Count</b>';
select '<tr><td>',SCHEMA_NAME,'<td>', DIGEST_TEXT, '<td>', COUNT_STAR  -- FIRST_SEEN, LAST_SEEN 
  from performance_schema.events_statements_summary_by_digest
 where DIGEST_TEXT like '% OR %? = ?%'
 limit 20;
select '<tr><td>',SCHEMA_NAME,'<td>', DIGEST_TEXT, '<td>', COUNT_STAR  -- FIRST_SEEN, LAST_SEEN 
  from performance_schema.events_statements_summary_by_digest
 where DIGEST_TEXT like '%mysql.user%
 limit 20';
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
        '<td align=right>', format(table_rows,0),
        '<td align=right>', format((data_length+index_length)/(1024*1024),0)
from tables
where (table_name like '%comments'
       or table_name like '%redirection')
and table_rows > 1000
order by table_rows desc;
select '</table><p><hr>' ;

select '<P><A NAME="prc"></A>' ;
select '<P><table><tr><td><table border="2"><tr><td><b>Per-User Processes</b></td></tr>' ;
select '<tr><td><b>User</b><td><b>Count</b>';
select '<tr><td>', user,
	'<td>', count(*)
from processlist
group by user
order by 4 desc;
select '<tr><td>TOTAL (', count(distinct user),
	' distinct users)<td>',
	count(*)
from processlist;
select '</table>' ;
select '<td><table border="2"><tr><td><b>Per-User/Database Processes</b></td></tr>' ;
select '<tr><td><b>User</b><td><b>Database</b><td><b>Count</b>';
select '<tr><td>', user,
	'<td>', db,
	'<td>', count(*)
from processlist
group by user, db
order by 6 desc;
select '<tr><td>TOTAL (', count(distinct user,coalesce(db,'')),
	' distinct users)<td>',
	'<td>', count(*)
from processlist;
select '</table>' ;
select '<td><table border="2"><tr><td><b>Per-Host Processes</b></td></tr>' ;
select '<tr><td><b>Host</b><td><b>Count</b>';
select '<tr><td>', SUBSTRING_INDEX(host,':',1),
	'<td>', count(*)
from processlist
group by SUBSTRING_INDEX(host,':',1)
order by 4 desc;
select '<tr><td>TOTAL (', count(distinct SUBSTRING_INDEX(host,':',1)),
	' distinct hosts)',
	'<td>', count(*)
from processlist;
select '</table></table>' ;

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

select '<P><A NAME="run"></A>' ;
select '<P><table border="2"><tr><td><b>Running SQL</b></td></tr>' ;
select '<tr><td><b>Id</b><td><b>User</b><td><b>Time</b>';
select '<td><b>State</b><td><b>Info</b>';
select '<tr><td>',id,
	'<td>', user,
	'<td>', time,
	'<td>', state,
	'<td>', substr(replace(replace(info,'<','&lt;'),'>','&gt;'),0,512)
from processlist
where command <> 'Sleep'
  and command <> 'Daemon'
order by id;
select '</table><p><hr>' ;

select '<P><A NAME="lock"></A>' ;
select '<P><table border="2" width="75%">' ;
select '<tr><td><pre><b>Table Locks</b>' ;
show open tables WHERE In_use > 0;
select '</pre><p></table><hr>' ;

select '<P><A NAME="stat_innodb"></A>' ;
select '<P><table border="2"><tr><td><b>InnoDB Statistics</b></table>' ;

select '<P><table border="2"><tr><td><b>Transactions</b></td></tr>' ;
select '<tr><td><b>Id</b><td><b>TRX Id</b><td><b>State</b><td><b>Started</b>';
select  '<td><b>Weight</b><td><b>Req. lock</b><td><b>Query</b><td><b>Operation</b><td><b>Isolation</b>';
select '<tr><td>',trx_mysql_thread_id, '<td>',trx_id, '<td>',trx_state, '<td>',trx_started, '<td>',trx_weight,
       '<td>',trx_requested_lock_id, '<td>',trx_query, '<td>',trx_operation_state, '<td>',trx_isolation_level
 from INFORMATION_SCHEMA.innodb_trx;
select '</table>' ;

select '<P><A NAME="innodb_lock"></A>' ;
select '<P><table border="2"><tr><td><b>Waiting Locks</b></td></tr>' ;
select '<tr><td><b>TRX Id</b><td><b>Lock Id</b><td><b>Blocking TRX</b><td><b>Blocking Lock</b>';
select '<tr><td>',requesting_trx_id, '<td>',requested_lock_id, '<td>',blocking_trx_id, '<td>',blocking_lock_id
 from INFORMATION_SCHEMA.INNODB_LOCK_WAITS;
select '</table>' ;

select '<P><table border="2"><tr><td><b>Locks</b></td></tr>' ;
select '<tr><td><b>TRX Id</b><td><b>Lock Id</b><td><b>Mode</b><td><b>Type</b>';
select '<td><b>Table</b><td><b>Index</b>';
select '<tr><td>',lock_trx_id, '<td>',lock_id, '<td>',lock_mode, '<td>',lock_type, '<td>',lock_table, '<td>',lock_index
 from INFORMATION_SCHEMA.INNODB_LOCKS;
select '</table>' ;

select '<P><table border="2"><tr><td><b>Pool Statistics</b></td></tr>' ;
select '<tr><td><b>Pool Id</b><td><b>Size</b><td><b>Free buffers</b><td><b>Database pages</b>';
select '<td><b>Old pages</b><td><b>Modified pages</b><td><b>Pages read</b><td><b>Pages created</b>';
select '<td><b>Pages written</b><td><b>Hit rate</b>';
select '<tr><td>',POOL_ID, '<td>',POOL_SIZE, '<td>',FREE_BUFFERS, '<td>',DATABASE_PAGES,
       '<td>',OLD_DATABASE_PAGES, '<td>',MODIFIED_DATABASE_PAGES,
       '<td>',NUMBER_PAGES_READ, '<td>',NUMBER_PAGES_CREATED, '<td>',NUMBER_PAGES_WRITTEN, '<td>',HIT_RATE
 from INFORMATION_SCHEMA.INNODB_BUFFER_POOL_STATS;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Tablespaces</b></td></tr>' ;
select '<tr><td><b>Tablespace Type</b><td><b>Row Format</b><td><b>Tables</b>',
       '<td><b>Columns</b>';
SELECT '<tr><td>',if(SPACE=0,'System','FilePerTable') TBS,'<td>', ROW_FORMAT,'<td>',
       count(*) TABS,'<td>', sum(N_COLS-3) COLS
  FROM INFORMATION_SCHEMA.INNODB_SYS_TABLES
 group by ROW_FORMAT, if(SPACE=0,'System','FilePerTable');
select '</table><p><hr>' ;

select '<P><A NAME="stat"></A>' ;
select '<P><table border="2"><tr><td><b>Performance Statistics Summary</b></td></tr>' ;
select '<tr><td><b>Statistic</b><td><b>Value</b><td><b>Suggested value</b><td><b>Action to correct</b>';
select '<tr><!01><td>', variable_name, ' (days)<td align=right>', round(variable_value/(3600*24),1), '', ''
from global_status
where variable_name='UPTIME'
union
select '<tr><!15><td>', 'Buffer Cache: MyISAM Read Hit Ratio',
 '<td align=right>', format(100-t1.variable_value*100/t2.variable_value,2), '<td> >95', '<td>Increase KEY_BUFFER_SIZE'
from global_status t1, global_status t2
where t1.variable_name='KEY_READS' and t2.variable_name='KEY_READ_REQUESTS'
union
select '<tr><!16><td>', 'Buffer Cache: InnoDB Read Hit Ratio',
 '<td align=right>', format(100-t1.variable_value*100/t2.variable_value,2), '<td> >95', '<td>Increase INNODB_BUFFER_SIZE'
from global_status t1, global_status t2
where t1.variable_name='INNODB_BUFFER_POOL_READS' and t2.variable_name='INNODB_BUFFER_POOL_READ_REQUESTS'
union
select '<tr><!17><td>', 'Buffer Cache: MyISAM Write Hit Ratio',
 '<td align=right>', format(100-t1.variable_value*100/t2.variable_value,2), '<td> >95', '<td>Increase KEY_BUFFER_SIZE'
from global_status t1, global_status t2
where t1.variable_name='KEY_WRITES' and t2.variable_name='KEY_WRITE_REQUESTS'
union
select '<tr><!18><td>', 'Log Cache: InnoDB Log Write Ratio',
 '<td align=right>', format(100-t1.variable_value*100/t2.variable_value,2), '<td> >95', '<td>Increase INNODB_LOG_BUFFER_SIZE'
from global_status t1, global_status t2
where t1.variable_name='INNODB_LOG_WRITES' and t2.variable_name='INNODB_LOG_WRITE_REQUESTS'
union
select '<tr><!19a><td>', 'Query Cache: Efficiency',
 '<td align=right>', format(t1.variable_value*100/(t1.variable_value+t2.variable_value),2), '<td> >30', '<td>'
from global_status t1, global_status t2
where t1.variable_name='QCACHE_HITS'
  and t2.variable_name='COM_SELECT'
union
select '<tr><!19b><td>', 'Query Cache: Hit Ratio',
 '<td align=right>', format(t1.variable_value*100/(t1.variable_value+t2.variable_value),2), '<td> >80', '<td>'
from global_status t1, global_status t2
where t1.variable_name='QCACHE_HITS'
  and t2.variable_name='QCACHE_INSERTS'
union
select '<tr><!20><td>', s.variable_name, '<td align=right>', concat(s.variable_value, ' /', v.variable_value),
 '<td>Far from maximum', '<td>Increase MAX_CONNECTIONS'
from global_status s, global_variables v
where s.variable_name='THREADS_CONNECTED'
and v.variable_name='MAX_CONNECTIONS'
union
select '<tr><!21><td>', variable_name, '<td align=right>', variable_value, '<td>LOW', '<td>Check user load'
from global_status
where variable_name='THREADS_RUNNING'
union
select '<tr><!30><td>', variable_name, '<td align=right>', format(variable_value,0), '<td>LOW', '<td>Check application'
from global_status
where variable_name='SLOW_QUERIES'
union
select '<tr><!40><td>', g1.variable_name, ' #/sec.<td align=right>', format(g1.variable_value/g2.variable_value,5), '', ''
from global_status g1,global_status g2
where g1.variable_name='QUESTIONS'
  and g2.variable_name='UPTIME'
union
select '<tr><!41><td>', g1.variable_name, ' #/sec.<td align=right>', format(g1.variable_value/g2.variable_value,5), '', ''
from global_status g1,global_status g2
where g1.variable_name='COM_SELECT'
  and g2.variable_name='UPTIME'
union
select '<tr><!42><td>', g1.variable_name, ' #/sec. (TPS)<td align=right>', format(g1.variable_value/g2.variable_value,5), '', ''
from global_status g1,global_status g2
where g1.variable_name='COM_COMMIT'
  and g2.variable_name='UPTIME'
union
select '<tr><!37><td>', g1.variable_name, ' #/sec.<td align=right>', format(g1.variable_value/g2.variable_value,5), '', ''
from global_status g1,global_status g2
where g1.variable_name='CONNECTIONS'
  and g2.variable_name='UPTIME'
union
select '<tr><!45><td>','COM DML #/sec.','<td align=right>',
       format((g1.variable_value+g3.variable_value+g4.variable_value+g5.variable_value+g6.variable_value
               +g7.variable_value+g8.variable_value+g9.variable_value)/g2.variable_value,5),
       '', ''
from global_status g1,global_status g2,global_status g3,global_status g4,global_status g5,
     global_status g6,global_status g7,global_status g8,global_status g9
where g1.variable_name='COM_INSERT'
  and g2.variable_name='UPTIME'
  and g3.variable_name='COM_UPDATE'
  and g4.variable_name='COM_DELETE'
  and g5.variable_name='COM_INSERT_SELECT'
  and g6.variable_name='COM_UPDATE_MULTI'
  and g7.variable_name='COM_DELETE_MULTI'
  and g8.variable_name='COM_REPLACE'
  and g9.variable_name='COM_REPLACE_SELECT'
union
select '<tr><!50><td>', g1.variable_name, ' Mb/sec.<td align=right>',
       format(g1.variable_value*8/(g2.variable_value*1024*1024),5), '', ''
from global_status g1,global_status g2
where g1.variable_name='BYTES_SENT'
  and g2.variable_name='UPTIME'
union
select '<tr><!51><td>', g1.variable_name, ' Mb/sec.<td align=right>',
       format(g1.variable_value*8/(g2.variable_value*1024*1024),5), '', ''
from global_status g1,global_status g2
where g1.variable_name='BYTES_RECEIVED'
  and g2.variable_name='UPTIME'
union
select '<tr><!35><td>', 'DBcpu (SUM_TIMER_WAIT)', '<td align=right>',
       format((sum(SUM_TIMER_WAIT)/1000000000000)/variable_value, 5), '', ''
  from information_schema.global_status, performance_schema.events_statements_summary_global_by_event_name
 where variable_name='UPTIME'
order by 1;

select '<tr><td><b>Expert suggestions on</b><td><b>Value</b><td><td><b>Action to correct</b>';
select '<tr><!01><td>', g1.variable_name, ' #/hour<td align=right>',
       format((g1.variable_value*60*60)/g2.variable_value,5), '<td>', '<td>Increase TABLE_OPEN_CACHE'
from global_status g1,global_status g2
where g1.variable_name='OPENED_TABLES'
  and g2.variable_name='UPTIME'
  and g1.variable_value*60*60/g2.variable_value>12
union
select '<tr><!02><td>', g1.variable_name, ' #/hour<td align=right>',
       format((g1.variable_value*60*60)/g2.variable_value,5), '<td>', '<td>Increase SORT_BUFFER_SIZE'
from global_status g1,global_status g2
where g1.variable_name='SORT_MERGE_PASSES'
  and g2.variable_name='UPTIME'
  and g1.variable_value*60*60/g2.variable_value>12
union
select '<tr><!03><td>', g1.variable_name, ' %<td align=right>',
       format(g1.variable_value*100/(g1.variable_value+g2.variable_value),5), '<td>', '<td>Increase MAX_HEAP_TABLE_SIZE and TMP_TABLE_SIZE'
from global_status g1,global_status g2
where g1.variable_name='CREATED_TMP_DISK_TABLES'
  and g2.variable_name='CREATED_TMP_TABLES'
  and g1.variable_value/g2.variable_value>0.2
union
select '<tr><!04><td>', g1.variable_name, ' %<td align=right>',
       format(g1.variable_value*100/(g2.variable_value),5), '<td>', '<td>Increase BINLOG_CACHE_SIZE'
from global_status g1,global_status g2
where g1.variable_name='BINLOG_CACHE_DISK_USE'
  and g2.variable_name='BINLOG_CACHE_USE'
  and g1.variable_value/g2.variable_value>0.2
union
select '<tr><!05><td>', g1.variable_name, ' #/hour<td align=right>',
       format((g1.variable_value*60*60)/g2.variable_value,5), '<td>', '<td>Increase INNODB_LOG_BUFFER_SIZE'
from global_status g1,global_status g2
where g1.variable_name='INNODB_LOG_WAITS'
  and g2.variable_name='UPTIME'
  and g1.variable_value*60*60/g2.variable_value>1
union
select '<tr><!06><td>', g1.variable_name, ' MB/hour<td align=right>',
       format((g1.variable_value*60*60)/(g2.variable_value*1024*1024),5), '<td>', '<td>Tune INNODB_LOG_FILE_SIZE'
from global_status g1,global_status g2
where g1.variable_name='INNODB_OS_LOG_WRITTEN'
  and g2.variable_name='UPTIME'
  and (g1.variable_value*60*60)/(g2.variable_value*1024*1024)>5
order by 1;
select '</table><p>' ;

select '<P><A NAME="stat56"></A>' ;
select '<P><table border="2"><tr><td><b>Performance Schema Statistics</b></td></tr>' ;
select '</table><p>';

select '<P><table border="2"><tr><td><b>Consumers</b></td></tr>' ;
select '<tr><td><b>Name</b>',
       '<td><b>Enabled</b>';
select '<tr><td>', NAME, '<td>',ENABLED
 from performance_schema.setup_consumers
 order by enabled, name;
select '</table><p>';

select '<P><table border="2"><tr><td><b>Uptime</b><td>', truncate(variable_value/(3600*24),0),
       'g ', SEC_TO_TIME(mod(variable_value, 3600*24)), '</table>'
  from global_status
 where variable_name='UPTIME';

select '<P><table border="2"><tr><td><b>Statement Events</b></td></tr>' ;
select '<tr><td><b>Event</b>',
       '<td><b>Count</b>','<td><b>Sum Timer</b>';
select '<tr><td>',EVENT_NAME, '<td align="right">',COUNT_STAR, '<td align="right">',SUM_TIMER_WAIT,
       '<td align="right">', SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000)
  from performance_schema.events_statements_summary_global_by_event_name
 where count_star > 0 
 order by SUM_TIMER_WAIT desc 
 limit 10;
select '</table><p>';

select '<P><table border="2"><tr><td><b>Wait Events</b></td></tr>' ;
select '<tr><td><b>Event</b>',
       '<td><b>Count</b>','<td><b>Sum Timer</b>';
select '<tr><td>',EVENT_NAME, '<td align="right">',COUNT_STAR, '<td align="right">',SUM_TIMER_WAIT,
       '<td align="right">', SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000)  
  from performance_schema.events_waits_summary_global_by_event_name  
 where count_star > 0 
   and event_name != 'idle'
 order by SUM_TIMER_WAIT desc 
 limit 10;
select '</table><p>';

select '<P><table border="2"><tr><td><b>Lock Wait</b></td></tr>' ;
select '<tr><td><b>Type</b>','<td><b>Schema</b>','<td><b>Name</b>',
       '<td><b>Count</b>','<td><b>Sum Timer</b>';
select '<tr><td>',OBJECT_TYPE, '<td>', OBJECT_SCHEMA, '<td>', OBJECT_NAME,
       '<td align="right">', COUNT_STAR, '<td align="right">', SUM_TIMER_WAIT,
       '<td align="right">', SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000) 
  from performance_schema.table_lock_waits_summary_by_table
 where count_star > 0 
 order by SUM_TIMER_WAIT desc 
 limit 10;
select '</table><p>';

select '<P><table border="2"><tr><td><b>File events</b></td></tr>' ;
select '<tr><td><b>Event</b>',
       '<td><b>Count</b>','<td><b>Sum Timer</b>';
select '<tr><td>',EVENT_NAME,'<td align="right">',COUNT_STAR,'<td align="right">',SUM_TIMER_WAIT,
       '<td align="right">', SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000) 
  from performance_schema.file_summary_by_event_name order by SUM_TIMER_WAIT desc limit 10;
select '</table><p>';

select '<P><table border="2"><tr><td><b>File access</b></td></tr>' ;
select '<tr><td><b>File Name</b>','<td><b>Event Name</b>',
       '<td><b>Count</b>','<td><b>Sum Timer</b>','<td><b>Human Timer</b>',
       '<td><b>#Read</b>','<td><b>Timer Read</b>','<td><b>Byte Read</b>',
       '<td><b>#Write</b>','<td><b>Timer Write</b>','<td><b>Byte Write</b>';
select '<tr><td>',FILE_NAME,'<td>',EVENT_NAME,'<td align="right">',COUNT_STAR,'<td align="right">',SUM_TIMER_WAIT,'<td align="right">',
 SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000),'<td align="right">',
 COUNT_READ,'<td align="right">',SUM_TIMER_READ,'<td align="right">',SUM_NUMBER_OF_BYTES_READ,'<td align="right">',
 COUNT_WRITE,'<td align="right">',SUM_TIMER_WRITE,'<td align="right">',SUM_NUMBER_OF_BYTES_WRITE
  from performance_schema.file_summary_by_instance order by SUM_TIMER_WAIT desc limit 10;
select '</table><p>';

select '<a id="sqls"></a><P><table border="2"><tr><td><b>SQL Statements</b></td>' ;
select '<td align="right">Representativeness:',
       round((1-sum(if(digest is null, count_star,0))/sum(count_star))*100,2), '%'
  from performance_schema.events_statements_summary_by_digest;
select '<tr><td><b>Schema</b>','<td><b>Text</b>',
       '<td><b>Count</b>','<td><b>Sum Timer</b>','<td><b>Human Timer</b>','<td><b>Average (sec.)</b>',
       '<td><b>Rows affected</b>','<td><b>Rows Sent</b>','<td><b>Rows Examined</b>',
       '<td><b>TMP Disk Create</b>','<td><b>TMP Create</b>',
       '<td><b>Sort Merge#</b>','<td><b>No Index</b>','<td><b>No Good Index</b>';
select '<tr><td>',SCHEMA_NAME,'<td>',DIGEST_TEXT,'<td align="right">',COUNT_STAR,'<td align="right">',
 SUM_TIMER_WAIT,'<td align="right">',SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000),'<td align="right">',
 round(AVG_TIMER_WAIT/1000000000000,3) AVG_TIMER_WAIT,'<td align="right">',
 SUM_ROWS_AFFECTED,'<td align="right">',SUM_ROWS_SENT,'<td align="right">',SUM_ROWS_EXAMINED,'<td align="right">',
 SUM_CREATED_TMP_DISK_TABLES,'<td>',SUM_CREATED_TMP_TABLES,'<td>',SUM_SORT_MERGE_PASSES,'<td>', 
 SUM_NO_INDEX_USED,'<td align="right">',SUM_NO_GOOD_INDEX_USED
  from performance_schema.events_statements_summary_by_digest order by SUM_TIMER_WAIT desc limit 20;
select '</table><p>';

select '<a id="sqlslow"></a><P><table border="2"><tr><td><b>Slowest Statements</b>' ;
select '<tr><td><b>Schema</b>','<td><b>Text</b>',
       '<td><b>Count</b>','<td><b>Sum Timer</b>','<td><b>Human Timer</b>','<td><b>Average (sec.)</b>',
       '<td><b>Rows affected</b>','<td><b>Rows Sent</b>','<td><b>Rows Examined</b>',
       '<td><b>TMP Disk Create</b>','<td><b>TMP Create</b>',
       '<td><b>Sort Merge#</b>','<td><b>No Index</b>','<td><b>No Good Index</b>';
select '<tr><td>',SCHEMA_NAME,'<td>',DIGEST_TEXT,'<td align="right">',COUNT_STAR,'<td align="right">',
 SUM_TIMER_WAIT,'<td align="right">',SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000),'<td align="right">',
 round(AVG_TIMER_WAIT/1000000000000,3) AVG_TIMER_WAIT,'<td align="right">',
 SUM_ROWS_AFFECTED,'<td align="right">',SUM_ROWS_SENT,'<td align="right">',SUM_ROWS_EXAMINED,'<td align="right">',
 SUM_CREATED_TMP_DISK_TABLES,'<td>',SUM_CREATED_TMP_TABLES,'<td>',SUM_SORT_MERGE_PASSES,'<td>', 
 SUM_NO_INDEX_USED,'<td align="right">',SUM_NO_GOOD_INDEX_USED
  from performance_schema.events_statements_summary_by_digest order by AVG_TIMER_WAIT desc limit 5;
select '</table><p><hr>';

select '<P><A NAME="big"></A>' ;
select '<P><table border="2"><tr><td><b>Biggest Objects</b></td></tr>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Object</b>',
 '<td><b>Type</b>',
 '<td><b>Engine</b>',
 '<td><b>Bytes</b>',
 '<td><b>Est. rows</b>';
select '<tr><td>', table_schema,
	'<td>', table_name,
	'<td>T','<td>',engine,
	'<td align=right>', format(data_length+index_length,0),
	'<td align=right>', format(table_rows,0)
from tables
order by data_length+index_length desc
limit 20;
select '</table><p><hr>' ;

select '<P><A NAME="hostc"></A>' ;
select '<P><table border="2"><tr><td><b>Host Connections</b></td></tr>' ;
select '<tr><td><b>Host</b>',
 '<td><b>Current Connections</b>',
 '<td><b>Total Connections</b>';
select '<tr><td>',HOST, '<td>', CURRENT_CONNECTIONS, '<td>', TOTAL_CONNECTIONS
  from performance_schema.hosts
 order by CURRENT_CONNECTIONS desc, TOTAL_CONNECTIONS desc;

select '<tr><td>TOTAL HOSTS:',count(distinct HOST), '<td>', sum(CURRENT_CONNECTIONS), '<td>', sum(TOTAL_CONNECTIONS)
  from performance_schema.hosts;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Host Cache</b></td></tr>' ;
select '<tr><td><b>Host</b>',
 '<td><b>IP</b>',
 '<td><b>Validated</b>',
 '<td><b>SUM Errors</b>',
 '<td><b>First Seen</b>',
 '<td><b>Last Seen</b>',
 '<td><b>Last Error Seen</b>',
 '<td><b># Handshake Err.</b>',
 '<td><b># Authentication Err.</b>',
 '<td><b># ACL Err.</b>'
;
select '<tr><td>', host, '<td>', ip, '<td>', host_validated,
       '<td align="right"><b>', SUM_CONNECT_ERRORS ERR,
       '</b><td>', FIRST_SEEN, '<td>', LAST_SEEN, '<td>', LAST_ERROR_SEEN,
       '<td align="right">', COUNT_HANDSHAKE_ERRORS,
       '<td align="right">', COUNT_AUTHENTICATION_ERRORS,
       '<td align="right">', COUNT_HOST_ACL_ERRORS
from performance_schema.host_cache;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Max Connect Errors</b><td>&nbsp;', @@global.max_connect_errors;
select '</table><p><hr>' ;

select '<P><A NAME="repl"></A>' ;
select '<P><table border="2"><tr><td><b>Replication</b></td></tr>' ;
select '<tr><td><pre><b>Master</b>' ;
show master status;
SHOW VARIABLES LIKE 'rpl_semi_sync_master_%';
SHOW STATUS LIKE 'rpl_semi_sync_master_status';
select '<p>' ;
show binary logs;
select '</pre><tr><td><pre><b>Slave</b>' ;
show slave status\G
SHOW VARIABLES LIKE 'rpl_semi_sync_slave_enabled';
SHOW STATUS LIKE 'rpl_semi_sync_slave_status';
select '</pre><tr><td><pre><b>Galera Cluster</b>' ;
show status where variable_name in ('wsrep_cluster_size', 'wsrep_cluster_status', 'wsrep_flow_control_paused', 'wsrep_ready', 'wsrep_connected', 'wsrep_local_state_comment');
select '</pre></table><p><hr>' ;

select '<P><A NAME="stor"></A>' ;
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

select '<P><A NAME="sche"></A>' ;
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
 '<td><b>Command</b>';
 select '<tr><td>',concat(event_schema,'.',event_name), 
  '<td>', status,
  '<td>', event_type,
  '<td>', ifnull(execute_at,''),
	ifnull(interval_value,''),ifnull(interval_field,''),
  '<td>', event_definition
 from events;
select '</table><p><hr>' ;

select '<P><A NAME="nls"></A>' ;
select '<P><table border="2"><tr><td><b>NLS</b></td></tr>';
select '<tr><td><b>Schema</b>','<td><b>DEFAULT CHARACTER_SET_NAME</b>','<td><b>DEFAULT COLLATION_NAME</b>';
SELECT '<tr><td>',schema_name, '<td>', DEFAULT_CHARACTER_SET_NAME, '<td>', DEFAULT_COLLATION_NAME
  FROM information_schema.SCHEMATA
 where schema_name not in ('mysql', 'information_schema', 'sys', 'performance_schema','test')
 order by schema_name;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>NLS: Columns</b></td></tr>';
select '<tr><td><b>Schema</b>','<td><b>CHARACTER_SET_NAME</b>','<td><b>COLLATION_NAME</b>','<td><b>Count</b>';
SELECT '<tr><td>',table_schema, '<td>', CHARACTER_SET_NAME, '<td>', COLLATION_NAME, '<td>', count(*)
  FROM information_schema.COLUMNS
 where table_schema not in ('mysql', 'information_schema', 'sys', 'performance_schema', 'test')
   and CHARACTER_SET_NAME is not null
 group by table_schema, CHARACTER_SET_NAME, COLLATION_NAME
union
SELECT '<tr><td>', 'TOTAL', '<td>', CHARACTER_SET_NAME, '<td>', COLLATION_NAME, '<td>', count(*)
  FROM information_schema.COLUMNS
 where table_schema not in ('mysql', 'information_schema', 'sys', 'performance_schema', 'test')
   and CHARACTER_SET_NAME is not null
 group by CHARACTER_SET_NAME , COLLATION_NAME;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>NLS: Parameters</b></td></tr>';
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', replace(variable_value,',',', ')
  from global_variables
 where variable_name like 'character_set_%' or variable_name like 'collation_%'
 order by variable_name;
select '</table><p><hr>' ;

select '<P><A NAME="par"></A>' ;
select '<P><table border="2"><tr><td><b>MySQL Parameters</b></td></tr>';
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', replace(variable_value,',',', ')
from global_variables
order by variable_name;
select '</table><p><hr>' ;


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

select '<P><A NAME="gstat"></A>' ;
select '<P><table border="2"><tr><td><b>MySQL Global Status</b></td></tr>';
select '<tr><td><b>Statistic</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', variable_value
from global_status
order by variable_name;
select '</table><p><hr>' ;

select '<hr><P>Statistics generated on: ', now();
select '<br>More info on';
select '<A HREF="http://meoshome.it.eu.org#my">this site</A>' as info;
select 'or contact' as info;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo Bogliolo</A>.<p></body></html>' ;