-- Program:	 my2html.80.sh
-- Info:	 MySQL (8.0) DBA Database SQL report in HTML
-- Date:         2018-04-19
-- Version:      1.0.24: latest releases (2025-10-31), new CSS file
-- Author:       Bartolomeo Bogliolo mail@meo.bogliolo.name
-- License:      GPL
--
-- Notes:
-- Init:       1-APR-2006 meo@bogliolo.name
--               Initial version
-- 1.0.14:     19-APR-2018
--               Production 8.0 script version based on 1.0.13c MySQL 5.7 script
-- 1.0.15:     14-FEB-2019
--               Latests versions update
--
-- Usage:        mysql --user=$USR --password=$PSS --host=$HST --port=$PRT --force --skip-column-names < my2html.80.sql > $HSTN.$PRT.htm 2> /dev/null

use information_schema;

select '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8" /><link rel="stylesheet" href="style.css" /> <title>';
select @@hostname, ':', @@port, '-';
select ' MySQL Statistics - my2html</title></head><body>';

select '<h1>MySQL Database</h1>';

select '<p><a id="\1"></a>' ;
select '<p>Table of contents:' ;
select '<table><tr><td><ul>' ;
select '<li><a href="#status">Summary Status</a></li>' ;
select '<li><a href="#ver">Versions</a></li>' ;
select '<li><a href="#obj">Schema/Object Matrix</a></li>' ;
select '<li><a href="#tbs">Space Usage</a></li>' ;
select '<li><a href="#part">Partitioning</a></li>' ;
select '<li><a href="#usr">Users</a>' ;
select '   (<a href="#usr_sec">Security</a>)' ;
select '<li><a href="#tune">Tuning Parameters</a> </li>' ;
select '<li><a href="#eng">Engines</a></li>' ;
select '<li><a href="#prc">Threads</a></li>' ;
select '<li><a href="#run">Running SQL</a> </li>' ;
select '<li><a href="#lock">Table Locks</a> </li>' ;
select '</ul><td><ul>' ;
select '<li><a href="#stat_innodb">InnoDB Statistics</a> </li>' ;
select '<li><a href="#stat">Performance Statistics</a></li>' ;
select '<li><a href="#big">Biggest Objects</a></li>' ;
select '<li><a href="#hostc">Host Statistics</a></li>' ;
select '<li><a href="#repl">Replication</a></li>' ;
select '<li><a href="#stor">Stored Routines</a></li>' ;
select '<li><a href="#sche">Scheduled Jobs</a> </li>' ;
select '<li><a href="#nls">NLS</a> </li>' ;
select '<li><a href="#par">Configuration Parameters</a></li>' ;
select '<li><a href="#gstat">Global Status</a></li>' ;
select '</ul></table><p><hr>' ;
 
select '<p>Statistics generated on: ', now();
select ' by: ', user(), 'as: ',current_user();
select 'using: <I><b>my2html.80.sh</b> v.1.0.24';

select '<hr><p><a id="status"></a>';
select '<p><table class="bordered sortable"><caption>Summary</caption><thead><tr>';
select '<th scope="col" class="tac tooltip">Item<span class="tooltiptext">Item</span></th>';
select '<th scope="col" class="tac tooltip">Value<span class="tooltiptext">Value</span></th>';
select '</thead><tbody>';

select '<tr><td>Version :', '<td>', version()
union
select '<tr><td>Created :', '<td>', min(create_time)
from tables
union
select '<tr><td>Started :', '<td>', date_format(date_sub(now(), INTERVAL variable_value second),'%Y-%m-%d %T')
from performance_schema.global_status
where variable_name='UPTIME'
union
select '<tr><td>DB Size (MB):',
	'<td class="align-right">',
        format(sum(data_length+index_length)/(1024*1024),0)
from tables
union
select '<tr><td>Buffers Size (MB):',
	'<td class="align-right">',
	format(sum(variable_value+0)/(1024*1024),0)
from performance_schema.global_variables
where lower(variable_name) like '%buffer_size' or lower(variable_name) like '%buffer_pool_size'
union
select '<tr><td>Logging Bin. :', '<td>', variable_value
from performance_schema.global_status
where variable_name='LOG_BIN'
union
select '<tr><td>Defined Users :',
 '<td class="align-right">', format(count(*),0)
from mysql.user
union
select '<tr><td>Defined Schemata :',
 '<td class="align-right">', count(*)
from schemata
where schema_name not in ('information_schema')
union
select '<tr><td>Defined Tables :',
	'<td class="align-right">', format(count(*),0)
from tables
union
select '<tr><td>Sessions :', '<td class="align-right">', format(count(*),0)
  from processlist
 union
select '<tr><td>Sessions (active) :', '<td class="align-right">', format(count(*),0)
  from processlist
 where command <> 'Sleep'
union
select '<tr><td>Questions (#/sec.) :',
 '<td class="align-right">', format(g1.variable_value/g2.variable_value,5)
  from performance_schema.global_status g1, performance_schema.global_status g2
 where g1.variable_name='QUESTIONS'
   and g2.variable_name='UPTIME'
union
select '<tr><td>BinLog Writes Day (MB) :',
 '<td class="align-right">', format((g1.variable_value*60*60*24)/(g2.variable_value*1024*1024),0)
  from performance_schema.global_status g1, performance_schema.global_status g2
 where g1.variable_name='INNODB_OS_LOG_WRITTEN'
   and g2.variable_name='UPTIME'
union
select '<tr><td>Hostname :', '<td>', variable_value
  from performance_schema.global_variables
 where variable_name ='hostname'
union
select '<tr><td>Port :', '<td>', variable_value
  from performance_schema.global_variables
 where variable_name ='port';
select '</tbody></table><p><hr>' ;

select '<p><a id="ver"></a>';
select '<p><table class="bordered sortable"><caption>Version check</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Version<span class="tooltiptext">Version</span></th>';
select '<th scope="col" class="tac tooltip">Supported<span class="tooltiptext">Supported</span></th>';
select '<th scope="col" class="tac tooltip">Last LTS release (N or N-1)<span class="tooltiptext">Last LTS release (N or N-1)</span></th>';
select '<th scope="col" class="tac tooltip">Last update (N or N-1)<span class="tooltiptext">Last update (N or N-1)</span></th>';
select '<th scope="col" class="tac tooltip">Notes<span class="tooltiptext">Notes</span></th>';
select '</thead><tbody>';
select '<tr><td>', version();
select ' <td>', if(SUBSTRING_INDEX(version(),'.',2) in ('8.4', '8.0'), 'YES', 'NO') ;

select ' <td>', if(SUBSTRING_INDEX(version(),'.',2) in ('8.4', '8.0'), 'YES', 'NO') ; -- last2 LTS releases

select ' <td>', if(SUBSTRING_INDEX(version(),'-',1)
    in ('8.4.5','8.0.42','5.7.44', 
        '8.4.6','8.0.43','5.7.44'), 'YES', 'NO') ; -- last2 MySQL updates

select '<td>Latest Releases (MySQL): 9.5.0, <b>8.4.7</b>, <b>8.0.44</b>;';
select '      9.0.1; 8.3.0, 8.2.0, 8.1.0, <b>5.7.44</b>, 5.6.51, 5.5.62, 5.1.73, 5.0.96'; 
select ' <br>Latest Releases (MariaDB): 12.0, <b>11.8.3</b>, 11.7.2, 11.6.2, 11.5.2, <b>11.4.8</b>, 11.3.2, 11.2.6, ';
select '     11.1.6, 11.0.6, <b>10.11.14</b>, 10.10.7, <b>10.6.22</b>, 10.5.29, 10.4.34;';
select '     10.9.8, 10.8.8, 10.7.8, 10.3.39, 10.2.44, 10.1.48, 10.0.38, 5.5.68';
select ' <br>Latest Releases (Aurora): 3.08.1-8.0.39, <b>3.05.2-8.0.32</b> (def.), 2.12.4-5.7.44, 1.23.4-5.6 ';
select '</tbody></table><p><hr>' ;

 
select '<p><a id="obj"></a>' ;
select '<p><table class="bordered sortable"><caption>Schema/Object Matrix</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Database<span class="tooltiptext">Database</span></th>';
select '<th scope="col" class="tac tooltip">Tables<span class="tooltiptext">Tables</span></th>';
select '<th scope="col" class="tac tooltip">Indexes<span class="tooltiptext">Indexes</span></th>';
select '<th scope="col" class="tac tooltip">Routines<span class="tooltiptext">Routines</span></th>';
select '<th scope="col" class="tac tooltip">Triggers<span class="tooltiptext">Triggers</span></th>';
select '<th scope="col" class="tac tooltip">Views<span class="tooltiptext">Views</span></th>';
select '<th scope="col" class="tac tooltip">Primary Keys<span class="tooltiptext">Primary Keys</span></th>';
select '<th scope="col" class="tac tooltip">Foreign Keys<span class="tooltiptext">Foreign Keys</span></th>';
select '<th scope="col" class="tac tooltip">All<span class="tooltiptext">All</span></th>' ;
select '</thead><tbody>';

select '<tr><td>', sk,
	'<td class="align-right">', sum(if(otype='T',1,0)),
	'<td class="align-right">', sum(if(otype='I',1,0)),
	'<td class="align-right">', sum(if(otype='R',1,0)),
	'<td class="align-right">', sum(if(otype='E',1,0)),
	'<td class="align-right">', sum(if(otype='V',1,0)),
	'<td class="align-right">', sum(if(otype='P',1,0)),
	'<td class="align-right">', sum(if(otype='F',1,0)),
	'<td class="align-right">', count(*)
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
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Index Types</caption><thead><tr>' ;
select  '<th scope="col" class="tac tooltip">Type<span class="tooltiptext">Type</span></th>';
select '<th scope="col" class="tac tooltip">Uniqueness<span class="tooltiptext">Uniqueness</span></th>';
select '<th scope="col" class="tac tooltip">Avg keys<span class="tooltiptext">Avg keys</span></th>';
select '<th scope="col" class="tac tooltip">Max Keys<span class="tooltiptext">Max Keys</span></th>';
select '<th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th>';
select '<th scope="col" class="tac tooltip">Columns<span class="tooltiptext">Columns</span></th>';
select '</thead><tbody>';
select '<tr><td>', index_type,
        '<td>', if(non_unique, 'Not Unique', 'UNIQUE'),
        '<td class="align-right">', avg(seq_in_index),
        '<td class="align-right">', max(seq_in_index),
        '<td class="align-right">', count(distinct table_schema,table_name, index_name),
	'<td class="align-right">', count(*)
  from statistics
 group by index_type, non_unique;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Unindexed Tables</caption><thead><tr>' ;
select  '<th scope="col" class="tac tooltip">Schema<span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">Table<span class="tooltiptext">Table</span></th>';
select '<th scope="col" class="tac tooltip">Engine<span class="tooltiptext">Engine</span></th>';
select '<th scope="col" class="tac tooltip">Estimated rows<span class="tooltiptext">Estimated rows</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>', t.TABLE_SCHEMA, '<td>', t.TABLE_NAME,'<td>', t.ENGINE,'<td class="align-right">', t.TABLE_ROWS
  FROM information_schema.TABLES t
 INNER JOIN information_schema.COLUMNS c ON t.TABLE_SCHEMA=c.TABLE_SCHEMA
            AND t.TABLE_NAME=c.TABLE_NAME
 WHERE t.TABLE_SCHEMA NOT IN ('performance_schema','information_schema','mysql','sys')
   AND t.TABLE_ROWS >100
   AND t.TABLE_TYPE in ('BASE TABLE')
 GROUP BY t.TABLE_SCHEMA,t.TABLE_NAME, t.ENGINE, t.TABLE_ROWS
   HAVING sum(if(column_key in ('PRI','UNI'), 1,0))=0
 ORDER BY 2, 4
 limit 100;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Orphaned Tables</caption><thead><tr>' ;
select  '<th scope="col" class="tac tooltip">Table ID<span class="tooltiptext">Table ID</span></th>';
select '<th scope="col" class="tac tooltip">Name<span class="tooltiptext">Name</span></th>';
select '<th scope="col" class="tac tooltip">Flags<span class="tooltiptext">Flags</span></th>';
-- '<td><b> File Format</b>',
select '<th scope="col" class="tac tooltip">Row Format<span class="tooltiptext">Row Format</span></th>';
select '</thead><tbody>';
select '<tr><td>', TABLE_ID,
        '<td>', NAME,
        '<td>', FLAG,
        -- '<td>', FILE_FORMAT,
        '<td>', ROW_FORMAT
  from INNODB_TABLES
 where name like "%/#%"
 limit 100;
select '</tbody></table><p><hr>' ;

select '<p><a id="tbs"></a>' ;
select '<p><table class="bordered sortable"><caption>Space Usage</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Database<span class="tooltiptext">Database</span></th>';
select '<th scope="col" class="tac tooltip">Row#<span class="tooltiptext">Row#</span></th>';
select '<th scope="col" class="tac tooltip">Data size<span class="tooltiptext">Data size</span></th>';
select '<th scope="col" class="tac tooltip">Index size<span class="tooltiptext">Index size</span></th>';
select '<th scope="col" class="tac tooltip">Free<span class="tooltiptext">Free</span></th>';
select '<th scope="col" class="tac tooltip">Total size<span class="tooltiptext">Total size</span></th>';
select '<th scope="col" class="tac tooltip"><span class="tooltiptext"></span></th>';
select '<th scope="col" class="tac tooltip">MyISAM<span class="tooltiptext">MyISAM</span></th>';
select '<th scope="col" class="tac tooltip">InnoDB<span class="tooltiptext">InnoDB</span></th>';
select '<th scope="col" class="tac tooltip">Memory<span class="tooltiptext">Memory</span></th>';
select '<th scope="col" class="tac tooltip">Other Engines<span class="tooltiptext">Other Engines</span></th>';
select '<th scope="col" class="tac tooltip">Created<span class="tooltiptext">Created</span></th>';
select '</thead><tbody>';
select '<tr><td>', table_schema,
	'<td class="align-right">', format(sum(table_rows),0),
	'<td class="align-right">', format(sum(data_length),0),
	'<td class="align-right">', format(sum(index_length),0),
	'<td class="align-right">', format(sum(data_free),0),
	'<td class="align-right">', format(sum(data_length+index_length),0),
	'<td>',
	'<td class="align-right">', format(sum((data_length+index_length)*
	if(engine='MyISAM',1,0)),0),
	'<td class="align-right">', format(sum((data_length+index_length)*
	if(engine='InnoDB',1,0)),0),
	'<td class="align-right">', format(sum((data_length+index_length)*
	if(engine='Memory',1,0)),0),
	'<td class="align-right">', format(sum((data_length+index_length)*
	if(engine='Memory',0,if(engine='MyISAM',0,if(engine='InnoDB',0,1)))),0),
	'<td>', date_format(min(create_time),'%Y-%m-%d')
from tables
group by table_schema with rollup;
select '</tbody></table><p>' ;

select '<p><a id="tbs_os"></a>' ;
select '<p><table class="bordered sortable"><caption>InnoDB Tablespace OS Space Usage</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Database<span class="tooltiptext">Database</span></th>';
select '<th scope="col" class="tac tooltip">OS size<span class="tooltiptext">OS size</span></th>';
select '</thead><tbody>';
select '<tr><td>',SUBSTRING_INDEX(name,'/',1),
	'<td class="align-right">', format(sum(FILE_SIZE),0)
  from information_schema.INNODB_TABLESPACES
 group by SUBSTRING_INDEX(name,'/',1) with rollup;
select '</tbody></table><p><hr>' ;

select '<p><a id="part"></a>' ;
select '<p><table class="bordered sortable"><caption>Partitioning</caption><thead><tr>';
select '<th scope="col" class="tac tooltip">Schema<span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">Partitioned Tables<span class="tooltiptext">Partitioned Tables</span></th>';
select '<th scope="col" class="tac tooltip">Partitions<span class="tooltiptext">Partitions</span></th>' ;
select '</thead><tbody>';
select '<tr><td>', table_schema, '<td class="align-right">',
  count(distinct table_name), '<td class="align-right">',  count(*)
 from information_schema.partitions
 where partition_name is not null
 group by table_schema;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Partitioning details</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Schema<span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">Table<span class="tooltiptext">Table</span></th>';
select '<th scope="col" class="tac tooltip">Method<span class="tooltiptext">Method</span></th>';
select '<th scope="col" class="tac tooltip">Partitions<span class="tooltiptext">Partitions</span></th>';
select '<th scope="col" class="tac tooltip">Subpartitions<span class="tooltiptext">Subpartitions</span></th>';
select '<th scope="col" class="tac tooltip">From partition<span class="tooltiptext">From partition</span></th>';
select '<th scope="col" class="tac tooltip">To partition<span class="tooltiptext">To partition</span></th>';
select '<th scope="col" class="tac tooltip">Est. Rows<span class="tooltiptext">Est. Rows</span></th>';
select '<th scope="col" class="tac tooltip">Size<span class="tooltiptext">Size</span></th>';
select '</thead><tbody>';
select '<tr><td>', table_schema,
	'<td>', table_name,
	'<td>', partition_method, ifnull(subpartition_method,''),
	'<td class="align-right">', count(distinct partition_name),
	'<td class="align-right">', count(distinct subpartition_name),
	'<td>', min(partition_name),
	'<td>', max(partition_name),
	'<td class="align-right">', sum(table_rows),
	'<td class="align-right">', sum(coalesce(DATA_LENGTH,0)+coalesce(INDEX_LENGTH,0))
  from partitions
 where partition_name is not null
 group by table_schema, table_name, subpartition_name, partition_method, subpartition_method
 order by table_schema, table_name, subpartition_name;
select '</tbody></table><p><hr>' ;


select '<p><a id="usr"></a>';
select '<p><table class="bordered sortable"><caption>Users</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">User<span class="tooltiptext">User</span></th>';
select '<th scope="col" class="tac tooltip">Host<span class="tooltiptext">Host</span></th>';
select '<th scope="col" class="tac tooltip"><code>SL IUD CDGRIA CCS CAE RR SSPFSR</code><span class="tooltiptext">SL IUD CDGRIA CCS CAE RR SSPFSR</span></th>';
select '<th scope="col" class="tac tooltip">Select<span class="tooltiptext">Select</span></th>';
select '<th scope="col" class="tac tooltip">Execute<span class="tooltiptext">Execute</span></th>';
select '<th scope="col" class="tac tooltip">Grant<span class="tooltiptext">Grant</span></th>';
select '<th scope="col" class="tac tooltip">Empty Password<span class="tooltiptext">Empty Password</span></th>';
select '<th scope="col" class="tac tooltip">Expired<span class="tooltiptext">Expired</span></th>';
select '<th scope="col" class="tac tooltip">Password lifetime<span class="tooltiptext">Password lifetime</span></th>';
select '<th scope="col" class="tac tooltip">Locked<span class="tooltiptext">Locked</span></th>';
select '<th scope="col" class="tac tooltip">Auth. Plugin<span class="tooltiptext">Auth. Plugin</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>',user, 
	'<td>', host,
	'<td><code>', CONCAT(Select_priv, Lock_tables_priv,' ',
       Insert_priv, Update_priv, Delete_priv, ' ', Create_priv, Drop_priv,
       Grant_priv, References_priv, Index_priv, Alter_priv, ' ',
       Create_tmp_table_priv, Create_view_priv, Show_view_priv, ' ',
       Create_routine_priv, Alter_routine_priv, Execute_priv, ' ',
       Repl_slave_priv, Repl_client_priv, ' ',
       Super_priv, Shutdown_priv, Process_priv, File_priv, Show_db_priv, Reload_priv) AS grt,
	'</code><td>', select_priv, 
	'<td>', execute_priv, 
	'<td>', grant_priv,
	'<td>', if(authentication_string<>'','','NO PWD'),
	'<td>', password_expired,
	'<td>', password_lifetime,
	'<td>', account_locked,
	'<td>', plugin
FROM mysql.user d
order by user,host;
select '<tr>';
select '<tr><td><b>DB Access</b></td></tr>' ;
select '<tr><td><b>User</b>',
 '<td><b>Host</b>',
 '<td><b>DB</b>',
 '<td><b>Select</b>',
 '<td><b>Execute</b>',
 '<td><b>Grant</b>';
SELECT '<tr><td>',user, 
	'<td>', host, 
	'<td>', db, 
	'<td>', select_priv, 
	'<td>', execute_priv, 
	'<td>', grant_priv
FROM mysql.db d
order by user,host;
select '</tbody></table><p>' ;

select '<p><a id="usr_sec"></a><a id="role"></a>';
select '<p><table class="bordered sortable"><caption>Roles</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Role Name<span class="tooltiptext">Role Name</span></th><th scope="col" class="tac tooltip">Active<span class="tooltiptext">Active</span></th>' ;
select '</thead><tbody>';
SELECT DISTINCT '<tr><td>', User, '<td>', if(from_user is NULL, 0, 1) 
  FROM mysql.user LEFT JOIN mysql.role_edges ON from_user=user 
 WHERE account_locked='Y'
   AND password_expired='Y'
   AND authentication_string='';
select '</tbody></table><p>' ;

select '<p><a id="usr_sec"></a><a id="vrole"></a>';
select '<p><table class="bordered sortable"><caption>Virtual <i>Roles</i></caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Access Level<span class="tooltiptext">Access Level</span></th><th scope="col" class="tac tooltip">Users<span class="tooltiptext">Users</span></th>' ;
select '</thead><tbody>';
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
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Users with poor passwords</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">User<span class="tooltiptext">User</span></th>';
select '<th scope="col" class="tac tooltip">Host<span class="tooltiptext">Host</span></th>';
select '<th scope="col" class="tac tooltip">Password<span class="tooltiptext">Password</span></th>';
select '<th scope="col" class="tac tooltip">Note<span class="tooltiptext">Note</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>',user, 
	'<td>', host, 
	'<td>',
	'<td>Empty password'
FROM mysql.user
WHERE authentication_string = ''
  AND (account_locked<>'Y' OR password_expired<>'Y');

SELECT '<tr><td>',user, 
	'<td>', host, 
	'<td>', authentication_string,
	'<td>Same as username'
FROM mysql.user
WHERE authentication_string = UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1(user))) AS CHAR)))
   OR authentication_string = UPPER(CONCAT('*', CAST(SHA2(UNHEX(SHA2(user,256)),256) AS CHAR)));

-- Known hash: root, secret, password, mypass, public, private, 1234, admin, secure, pass, mysql, my123, ...
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>', authentication_string,
	'<td>Weak password'
FROM mysql.user
WHERE authentication_string in ('*81F5E21E35407D884A6CD4A731AEBFB6AF209E1B', '*14E65567ABDB5135D0CFD9A70B3032C179A49EE7',
      '*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19', '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4',
      '*A80082C9E4BB16D9C8E41B0D7EED46126DF4A46E', '*85BB02300F877EB061967510E83F68B1A7325252',
      '*A4B6157319038724E3560894F7F932C8886EBFCF', '*4ACFE3202A5FF5CF467898FC58AAB1D615029441',
      '*A36BA850A6E748679226B01E159EF1A7BF946195', '*196BDEDE2AE4F84CA44C47D54D78478C7E2BD7B7',
      '*E74858DB86EBA20BC33D0AECAE8A8108C56B17FA', '*AF35041D44DF3E88C9F97CC8D3ACAF4695E65B69',
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('prova'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('test'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('demo'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('qwerty'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('manager'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('supervisor'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('toor'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('Qwerty'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('xxx'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('moodle'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('drupal'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('admin01'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('joomla'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('wp'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('ilikerandompasswords'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('changeme'))) AS CHAR))) );
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>', authentication_string,
	'<td>Old [pre 4.1] password format'
FROM mysql.user
WHERE authentication_string not like '*%'
  AND authentication_string not like '$%'
  AND authentication_string <> '';
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>', authentication_string,
	'<td>Suspected backdoor user'
FROM mysql.user
WHERE user in ('hanako', 'kisadminnew1', '401hk$', 'guest', 'Huazhongdiguo110');
select '</tbody></table><p>' ;

select '<p><a id="secsql"></a>' ;
select '<p><table class="bordered sortable"><caption>Suspect SQL Statements</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Schema<span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">Statement<span class="tooltiptext">Statement</span></th>';
select '<th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th>';
select '</thead><tbody>';
select '<tr><td>',SCHEMA_NAME,'<td>', DIGEST_TEXT, '<td>', COUNT_STAR  -- FIRST_SEEN, LAST_SEEN 
  from performance_schema.events_statements_summary_by_digest
 where DIGEST_TEXT like '% OR %? = ?%'
    or DIGEST_TEXT like '%mysql.user%'
 limit 20;
select '</tbody></table><p>' ;

select '<p><a id="sectab"></a>' ;
select '<p><table class="bordered sortable"><caption>Spammable tables</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Database<span class="tooltiptext">Database</span></th>';
select '<th scope="col" class="tac tooltip">Object<span class="tooltiptext">Object</span></th>';
select '<th scope="col" class="tac tooltip">Type<span class="tooltiptext">Type</span></th>';
select '<th scope="col" class="tac tooltip">Rows<span class="tooltiptext">Rows</span></th>';
select '<th scope="col" class="tac tooltip">MBytes<span class="tooltiptext">MBytes</span></th>' ;
select '</thead><tbody>';
select '<tr><td>', table_schema,
        '<td>', table_name,
        '<td>T',
        '<td class="align-right">', format(table_rows,0),
        '<td class="align-right">', format((data_length+index_length)/(1024*1024),0)
from tables
where (table_name like '%comments'
       or table_name like '%redirection')
and table_rows > 1000
order by table_rows desc;
select '</tbody></table><p><hr>' ;

select '<p><a id="sga"></a>' ;
select '<p><table class="bordered sortable"><caption>MySQL Memory Usage</caption><thead><tr>';
select '<th scope="col" class="tac tooltip">Type<span class="tooltiptext">Type</span></th>';
select '<th scope="col" class="tac tooltip">Value (MB)<span class="tooltiptext">Value (MB)</span></th>' ;
select '</thead><tbody>';
select '<tr><td>Global Caches <td class="align-right">', format(sum(variable_value)/(1024*1024),0)
from performance_schema.global_variables
where lower(variable_name) in (
'innodb_buffer_pool_size',
'query_cache_size',
'innodb_additional_mem_pool_size',
'innodb_log_file_size',
'innodb_log_buffer_size',
'key_buffer_size',
'table_open_cache',
'tmp_table_size');
select '<tr><td>Session\'\'s Memory<td class="align-right">', sum(total_memory_allocated)  
  from sys.user_summary;
select '<tr><td>Estimated Client Alloc. (max conn:', max(g2.variable_value),')<td class="align-right">',
       format(sum(g1.variable_value*g2.variable_value)/(1024*1024),0)
from performance_schema.global_variables g1, performance_schema.global_status g2
where lower(g1.variable_name) in (
'binlog_cache_size',
'binlog_stmt_cache_size',
'read_buffer_size',
'read_rnd_buffer_size',
'sort_buffer_size',
'join_buffer_size',
'thread_stack')
and lower(g2.variable_name)='max_used_connections';
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Performance Schema Memory Footprint</caption><thead><tr>';
select '<th scope="col" class="tac tooltip">Total Allocated<span class="tooltiptext">Total Allocated</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>', total_allocated FROM sys.memory_global_total;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>PS Memory Details</caption><thead><tr>';
select '<th scope="col" class="tac tooltip">Event<span class="tooltiptext">Event</span></th>';
select '<th scope="col" class="tac tooltip">#<span class="tooltiptext">#</span></th>';
select '<th scope="col" class="tac tooltip">#Free<span class="tooltiptext">#Free</span></th>';
select '<th scope="col" class="tac tooltip">Total Alloc.<span class="tooltiptext">Total Alloc.</span></th>';
select '<th scope="col" class="tac tooltip">Total Free<span class="tooltiptext">Total Free</span></th>';
select '<th scope="col" class="tac tooltip">Current<span class="tooltiptext">Current</span></th>';
select '<th scope="col" class="tac tooltip">Max<span class="tooltiptext">Max</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>',EVENT_NAME, '<td>',COUNT_ALLOC, '<td>',COUNT_FREE, '<td>',sys.format_bytes(SUM_NUMBER_OF_BYTES_ALLOC),
       '<td>',sys.format_bytes(SUM_NUMBER_OF_BYTES_FREE), '<td>',sys.format_bytes(CURRENT_NUMBER_OF_BYTES_USED),
       '<td>',sys.format_bytes(HIGH_NUMBER_OF_BYTES_USED)
  FROM performance_schema.memory_summary_global_by_event_name
 WHERE CURRENT_NUMBER_OF_BYTES_USED > 5000000
 ORDER BY CURRENT_NUMBER_OF_BYTES_USED DESC;
select '</tbody></table><p>' ;

select '<hr><p><a id="tune"></a>' ;
select '<p><table class="bordered sortable"><caption>Tuning Parameters (most used ones)</caption><thead><tr>';
select '<th scope="col" class="tac tooltip">Parameter<span class="tooltiptext">Parameter</span></th>';
select '<th scope="col" class="tac tooltip">Value<span class="tooltiptext">Value</span></th><th scope="col" class="tac tooltip">Type<span class="tooltiptext">Type</span></th>' ;
select '</thead><tbody>';
select '<tr><td>', variable_name, '<td class="align-right">', variable_value, '<td>Cache'
from performance_schema.global_variables
where lower(variable_name) in ('query_cache_type')
union
select '<tr><td>', variable_name, '<td class="align-right">', variable_value, '<td>Tuning and timeout'
from performance_schema.global_variables
where lower(variable_name) in (
'log_bin',
'slow_query_log')
union
select '<tr><td>', variable_name, '<td class="align-right">', format(variable_value,0), '<td>Cache'
from performance_schema.global_variables
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
select '<tr><td>', variable_name, '<td class="align-right">', format(variable_value,0), '<td>Tuning and timeout'
from performance_schema.global_variables
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
select '<tr><td>', variable_name, '<td class="align-right">', format(variable_value,0), '<td>Client Cache'
from performance_schema.global_variables
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
order by 5, variable_name;
select '</tbody></table><p><hr>' ;

select '<p><a id="eng"></a>' ;
select '<p><table class="bordered sortable"><caption>Engines</caption><thead><tr>';
select '<th scope="col" class="tac tooltip">Engine<span class="tooltiptext">Engine</span></th>';
select '<th scope="col" class="tac tooltip">Support<span class="tooltiptext">Support</span></th>';
select '<th scope="col" class="tac tooltip">Comment<span class="tooltiptext">Comment</span></th>';
select '</thead><tbody>';
select '<tr><td>', engine,
	'<td>', support,
	'<td>', comment
from engines
order by support;
select '</tbody></table><p><hr>' ;

select '<p><a id="prc"></a>' ;
select '<p><table><tr><td><table class="bordered sortable"><caption>Per-User Processes</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">User<span class="tooltiptext">User</span></th><th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th>';
select '</thead><tbody>';
select '<tr><td>', user,
	'<td>', count(*)
from processlist
group by user
order by 4 desc;
select '<tr><td>TOTAL (', count(distinct user),
	' distinct users)',
	'<td>', count(*)
from processlist;
select '</tbody></table>' ;
select '<td><table class="bordered sortable"><caption>Per-User/Database Processes</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">User<span class="tooltiptext">User</span></th><th scope="col" class="tac tooltip">Database<span class="tooltiptext">Database</span></th><th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th>';
select '</thead><tbody>';
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
select '</tbody></table>' ;
select '<td><table class="bordered sortable"><caption>Per-Host Processes</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Host<span class="tooltiptext">Host</span></th><th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th>';
select '</thead><tbody>';
select '<tr><td>', SUBSTRING_INDEX(host,':',1),
	'<td>', count(*)
from processlist
group by SUBSTRING_INDEX(host,':',1)
order by 4 desc;
select '<tr><td>TOTAL (', count(distinct SUBSTRING_INDEX(host,':',1)),
	' distinct hosts)',
	'<td>', count(*)
from processlist;
select '</tbody></table></table>' ;

select '<p><table class="bordered sortable"><caption>Processes</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Id<span class="tooltiptext">Id</span></th><th scope="col" class="tac tooltip">User<span class="tooltiptext">User</span></th><th scope="col" class="tac tooltip">Host<span class="tooltiptext">Host</span></th>';
select '<th scope="col" class="tac tooltip">DB<span class="tooltiptext">DB</span></th><th scope="col" class="tac tooltip">Command<span class="tooltiptext">Command</span></th><th scope="col" class="tac tooltip">Time<span class="tooltiptext">Time</span></th><th scope="col" class="tac tooltip">State<span class="tooltiptext">State</span></th>';
select '</thead><tbody>';
select '<tr><td>',id,
	'<td>', user,
	'<td>', host,
	'<td>', db,
	'<td>', command,
	'<td>', time,
	'<td>', state
from processlist
order by id;
select '</tbody></table><p>' ;

select '<p><a id="run"></a>' ;
select '<p><table class="bordered sortable"><caption>Running SQL</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Id<span class="tooltiptext">Id</span></th><th scope="col" class="tac tooltip">User<span class="tooltiptext">User</span></th><th scope="col" class="tac tooltip">Time<span class="tooltiptext">Time</span></th>';
select '<th scope="col" class="tac tooltip">State<span class="tooltiptext">State</span></th><th scope="col" class="tac tooltip">Info<span class="tooltiptext">Info</span></th>';
select '</thead><tbody>';
select '<tr><td>',id,
	'<td>', user,
	'<td>', time,
	'<td>', state,
	'<td>', substr(replace(replace(info,'<','&lt;'),'>','&gt;'),1,2024)
from processlist
where command <> 'Sleep'
order by id;
select '</tbody></table><p><hr>' ;

select '<p><a id="stat_innodb"></a>' ;
select '<p><h2>InnoDB Statistics</h2>' ;

select '<p><table class="bordered sortable"><caption>Transactions</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Id<span class="tooltiptext">Id</span></th><th scope="col" class="tac tooltip">TRX Id<span class="tooltiptext">TRX Id</span></th><th scope="col" class="tac tooltip">State<span class="tooltiptext">State</span></th><th scope="col" class="tac tooltip">Started<span class="tooltiptext">Started</span></th>';
select  '<th scope="col" class="tac tooltip">Weight<span class="tooltiptext">Weight</span></th><th scope="col" class="tac tooltip">Req. lock<span class="tooltiptext">Req. lock</span></th><th scope="col" class="tac tooltip">Query<span class="tooltiptext">Query</span></th><th scope="col" class="tac tooltip">Operation<span class="tooltiptext">Operation</span></th><th scope="col" class="tac tooltip">Isolation<span class="tooltiptext">Isolation</span></th>';
select '</thead><tbody>';
select '<tr><td>',trx_mysql_thread_id, '<td>',trx_id, '<td>',trx_state, '<td>',trx_started, '<td>',trx_weight,
       '<td>',trx_requested_lock_id, '<td>',trx_query, '<td>',trx_operation_state, '<td>',trx_isolation_level
 from INFORMATION_SCHEMA.innodb_trx;
select '</tbody></table>' ;

select '<p><a id="innodb_lock"></a>' ;
select '<p><table class="bordered sortable"><caption>Waiting Locks (performance_schema)</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">TRX Id<span class="tooltiptext">TRX Id</span></th><th scope="col" class="tac tooltip">Lock Id<span class="tooltiptext">Lock Id</span></th><th scope="col" class="tac tooltip">Blocking TRX<span class="tooltiptext">Blocking TRX</span></th><th scope="col" class="tac tooltip">Blocking Lock<span class="tooltiptext">Blocking Lock</span></th>';
select '</thead><tbody>';
select '<tr><td>',REQUESTING_ENGINE_TRANSACTION_ID, '<td>',REQUESTING_ENGINE_LOCK_ID,
       '<td>', BLOCKING_ENGINE_TRANSACTION_ID, '<td>', BLOCKING_ENGINE_LOCK_ID
  from performance_schema.data_lock_waits;
select '</tbody></table>' ;
select '<p><a id="innodb_lock2"></a>' ;
select '<p><table class="bordered sortable"><caption>Waiting Locks (sys)</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">TRX Id<span class="tooltiptext">TRX Id</span></th><th scope="col" class="tac tooltip">PID<span class="tooltiptext">PID</span></th><th scope="col" class="tac tooltip">Query<span class="tooltiptext">Query</span></th>';
select '    <th scope="col" class="tac tooltip">Blocking TRX Id<span class="tooltiptext">Blocking TRX Id</span></th><th scope="col" class="tac tooltip">PID<span class="tooltiptext">PID</span></th><th scope="col" class="tac tooltip">Query<span class="tooltiptext">Query</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>',waiting_trx_id,
  '<td>', waiting_pid,
  '<td>', waiting_query,
  '<td>', blocking_trx_id,
  '<td>', blocking_pid,
  '<td>', blocking_query
FROM sys.innodb_lock_waits;
select '</tbody></table>' ;

select '<p><table class="bordered sortable"><caption>Locks</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">TRX Id<span class="tooltiptext">TRX Id</span></th><th scope="col" class="tac tooltip">Lock Id<span class="tooltiptext">Lock Id</span></th><th scope="col" class="tac tooltip">Mode<span class="tooltiptext">Mode</span></th><th scope="col" class="tac tooltip">Type<span class="tooltiptext">Type</span></th>';
select '<th scope="col" class="tac tooltip">Status<span class="tooltiptext">Status</span></th><th scope="col" class="tac tooltip">Data<span class="tooltiptext">Data</span></th>';
select '</thead><tbody>';
select '<tr><td>',engine_transaction_id, '<td>',engine_lock_id, '<td>',lock_mode, '<td>',lock_type, '<td>',lock_status, '<td>',lock_data
  from performance_schema.data_locks;
select '</tbody></table>' ;

select '<p><table class="bordered sortable"><caption>Pool Statistics</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Pool Id<span class="tooltiptext">Pool Id</span></th><th scope="col" class="tac tooltip">Size<span class="tooltiptext">Size</span></th><th scope="col" class="tac tooltip">Free buffers<span class="tooltiptext">Free buffers</span></th><th scope="col" class="tac tooltip">Database pages<span class="tooltiptext">Database pages</span></th>';
select '<th scope="col" class="tac tooltip">Old pages<span class="tooltiptext">Old pages</span></th><th scope="col" class="tac tooltip">Modified pages<span class="tooltiptext">Modified pages</span></th><th scope="col" class="tac tooltip">Pages read<span class="tooltiptext">Pages read</span></th><th scope="col" class="tac tooltip">Pages created<span class="tooltiptext">Pages created</span></th>';
select '<th scope="col" class="tac tooltip">Pages written<span class="tooltiptext">Pages written</span></th><th scope="col" class="tac tooltip">Hit rate<span class="tooltiptext">Hit rate</span></th>';
select '</thead><tbody>';
select '<tr><td>',POOL_ID, '<td>',POOL_SIZE, '<td>',FREE_BUFFERS, '<td>',DATABASE_PAGES,
       '<td>',OLD_DATABASE_PAGES, '<td>',MODIFIED_DATABASE_PAGES,
       '<td>',NUMBER_PAGES_READ, '<td>',NUMBER_PAGES_CREATED, '<td>',NUMBER_PAGES_WRITTEN, '<td>',HIT_RATE
 from INFORMATION_SCHEMA.INNODB_BUFFER_POOL_STATS;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Tablespaces</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Tablespace Type<span class="tooltiptext">Tablespace Type</span></th><th scope="col" class="tac tooltip">Row Format<span class="tooltiptext">Row Format</span></th><th scope="col" class="tac tooltip">Tables<span class="tooltiptext">Tables</span></th>',
       '<th scope="col" class="tac tooltip">Columns<span class="tooltiptext">Columns</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>',if(SPACE=0,'System','FilePerTable') TBS,'<td>', ROW_FORMAT,'<td>',
       count(*) TABS,'<td>', sum(N_COLS-3) COLS
  FROM INFORMATION_SCHEMA.INNODB_TABLES
 group by ROW_FORMAT, if(SPACE=0,'System','FilePerTable');
select '</tbody></table><p><hr>' ;

select '<p><a id="stat"></a>' ;

select '<p><table class="bordered sortable"><caption>Performance Statistics Summary</caption><thead><tr>' ;

select '<th scope="col" class="tac tooltip">Statistic<span class="tooltiptext">Statistic</span></th><th scope="col" class="tac tooltip">Value<span class="tooltiptext">Value</span></th><th scope="col" class="tac tooltip">Suggested value<span class="tooltiptext">Suggested value</span></th><th scope="col" class="tac tooltip">Potential Action<span class="tooltiptext">Potential Action</span></th>';

select '</thead><tbody>';

select '<tr><!01><td>', variable_name, ' (days)<td class="align-right">', round(variable_value/(3600*24),1), '', ''

from performance_schema.global_status

where variable_name='UPTIME'

union

select '<tr><!15><td>', 'Buffer Cache: MyISAM Read Hit Ratio',

 '<td class="align-right">', format(100-t1.variable_value*100/t2.variable_value,2), '<td> >95', '<td>Increase KEY_BUFFER_SIZE'

from performance_schema.global_status t1, performance_schema.global_status t2

where t1.variable_name='KEY_READS' and t2.variable_name='KEY_READ_REQUESTS'

union

select '<tr><!16><td>', 'Buffer Cache: InnoDB Read Hit Ratio',

 '<td class="align-right">', format(100-t1.variable_value*100/t2.variable_value,2), '<td> >95', '<td>Increase INNODB_BUFFER_SIZE'

from performance_schema.global_status t1, performance_schema.global_status t2

where t1.variable_name='INNODB_BUFFER_POOL_READS' and t2.variable_name='INNODB_BUFFER_POOL_READ_REQUESTS'

union

select '<tr><!17><td>', 'Buffer Cache: MyISAM Write Hit Ratio',

 '<td class="align-right">', format(100-t1.variable_value*100/t2.variable_value,2), '<td> >95', '<td>Increase KEY_BUFFER_SIZE'

from performance_schema.global_status t1, performance_schema.global_status t2

where t1.variable_name='KEY_WRITES' and t2.variable_name='KEY_WRITE_REQUESTS'

union

select '<tr><!18><td>', 'Log Cache: InnoDB Log Write Ratio',

 '<td class="align-right">', format(100-t1.variable_value*100/t2.variable_value,2), '<td> >95', '<td>Increase INNODB_LOG_BUFFER_SIZE'

from performance_schema.global_status t1, performance_schema.global_status t2

where t1.variable_name='INNODB_LOG_WRITES' and t2.variable_name='INNODB_LOG_WRITE_REQUESTS'

union

select '<tr><!19a><td>', 'Query Cache: Efficiency (Hit/Select)',

 '<td class="align-right">', format(t1.variable_value*100/(t1.variable_value+t2.count_star),2), '<td> >30', '<td>'

from performance_schema.global_status t1, performance_schema.events_statements_summary_global_by_event_name t2

where t1.variable_name='QCACHE_HITS'

  and t2.event_name='statement/sql/select'

union

select '<tr><!19b><td>', 'Query Cache: Hit ratio (Hit/Query Insert)',

 '<td class="align-right">', format(t1.variable_value*100/(t1.variable_value+t2.variable_value),2), '<td> >80', '<td>'

from performance_schema.global_status t1, performance_schema.global_status t2

where t1.variable_name='QCACHE_HITS'

  and t2.variable_name='QCACHE_INSERTS'

union

select '<tr><!20><td>', s.variable_name, '<td class="align-right">', concat(s.variable_value, ' / ', v.variable_value),

 '<td>Far from maximum', '<td>Increase MAX_CONNECTIONS'

from performance_schema.global_status s, performance_schema.global_variables v

where s.variable_name='THREADS_CONNECTED'

and v.variable_name='MAX_CONNECTIONS'

union

select '<tr><!21><td>', variable_name, '<td class="align-right">', variable_value, '<td>LOW', '<td>Check user load'

from performance_schema.global_status

where variable_name='THREADS_RUNNING'

union

select '<tr><!30><td>', variable_name, '<td class="align-right">', format(variable_value,0), '<td>LOW', '<td>Check application'

from performance_schema.global_status

where variable_name='SLOW_QUERIES'

union

select '<tr><!40><td>', g1.variable_name, ' #/sec.<td class="align-right">', format(g1.variable_value/g2.variable_value,5), '', ''

from performance_schema.global_status g1, performance_schema.global_status g2

where g1.variable_name='QUESTIONS'

  and g2.variable_name='UPTIME'

union

select '<tr><!41><td>', 'SELECT', ' #/sec.<td class="align-right">', format(g1.count_star/g2.variable_value,5), '', ''

from performance_schema.events_statements_summary_global_by_event_name g1, performance_schema.global_status g2

where g1.EVENT_NAME = 'statement/sql/select'

  and g2.variable_name='UPTIME'

union

select '<tr><!42><td>', 'COMMIT', ' #/sec. (TPS)<td class="align-right">', format(g1.count_star/g2.variable_value,5), '', ''

from performance_schema.events_statements_summary_global_by_event_name g1, performance_schema.global_status g2

where g1.EVENT_NAME = 'statement/sql/commit'

  and g2.variable_name='UPTIME'

union

select '<tr><!37><td>', g1.variable_name, ' #/sec.<td class="align-right">', format(g1.variable_value/g2.variable_value,5), '', ''

from performance_schema.global_status g1, performance_schema.global_status g2

where g1.variable_name='CONNECTIONS'

  and g2.variable_name='UPTIME'

union

select '<tr><!45><td>','COM DML #/sec.','<td class="align-right">',

       format((g2.count_star+g3.count_star+g4.count_star+g5.count_star+g6.count_star

               +g7.count_star+g8.count_star+g9.count_star)/g1.variable_value,5),

       '', ''

from performance_schema.global_status g1, performance_schema.events_statements_summary_global_by_event_name g2,

     performance_schema.events_statements_summary_global_by_event_name g3, performance_schema.events_statements_summary_global_by_event_name g4,

     performance_schema.events_statements_summary_global_by_event_name g5, performance_schema.events_statements_summary_global_by_event_name g6,

     performance_schema.events_statements_summary_global_by_event_name g7, performance_schema.events_statements_summary_global_by_event_name g8,

     performance_schema.events_statements_summary_global_by_event_name g9

where g1.variable_name='UPTIME'

  and g2.event_name='statement/sql/insert'

  and g3.event_name ='statement/sql/update'

  and g4.event_name ='statement/sql/delete'

  and g5.event_name ='statement/sql/select'

  and g6.event_name ='statement/sql/update_multi'

  and g7.event_name ='statement/sql/delete_multi'

  and g8.event_name ='statement/sql/replace'

  and g9.event_name ='statement/sql/replace_select'

union

select '<tr><!50><td>', g1.variable_name, ' Mb/sec.<td class="align-right">',

       format(g1.variable_value*8/(g2.variable_value*1024*1024),5), '', ''

from performance_schema.global_status g1, performance_schema.global_status g2

where g1.variable_name='BYTES_SENT'

  and g2.variable_name='UPTIME'

union

select '<tr><!51><td>', g1.variable_name, ' Mb/sec.<td class="align-right">',

       format(g1.variable_value*8/(g2.variable_value*1024*1024),5), '', ''

from performance_schema.global_status g1, performance_schema.global_status g2

where g1.variable_name='BYTES_RECEIVED'

  and g2.variable_name='UPTIME'

union

select '<tr><!35><td>', 'DBcpu (SUM_TIMER_WAIT)', '<td class="align-right">',

       format((sum(SUM_TIMER_WAIT)/1000000000000)/variable_value, 5), '', ''

  from performance_schema.global_status, performance_schema.events_statements_summary_global_by_event_name

 where variable_name='UPTIME'

 group by variable_value

order by 1;

select '</table><p><table class="bordered sortable"><caption>Performance Advice</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Expert suggestions on<span class="tooltiptext">Expert suggestions on</span></th><th scope="col" class="tac tooltip">Value<span class="tooltiptext">Value</span></th><th scope="col" class="tac tooltip"><span class="tooltiptext"></span></th><th scope="col" class="tac tooltip">Action to correct<span class="tooltiptext">Action to correct</span></th>';
select '</thead><tbody>';
select '<tr><!01><td>', g1.variable_name, ' #/hour<td class="align-right">',
       format((g1.variable_value*60*60)/g2.variable_value,5), '<td>', '<td>Increase TABLE_OPEN_CACHE'
from performance_schema.global_status g1, performance_schema.global_status g2
where g1.variable_name='OPENED_TABLES'
  and g2.variable_name='UPTIME'
  and g1.variable_value*60*60/g2.variable_value>12
union
select '<tr><!02><td>', g1.variable_name, ' #/hour<td class="align-right">',
       format((g1.variable_value*60*60)/g2.variable_value,5), '<td>', '<td>Increase SORT_BUFFER_SIZE'
from performance_schema.global_status g1, performance_schema.global_status g2
where g1.variable_name='SORT_MERGE_PASSES'
  and g2.variable_name='UPTIME'
  and g1.variable_value*60*60/g2.variable_value>12
union
select '<tr><!03><td>', g1.variable_name, ' %<td class="align-right">',
       format(g1.variable_value*100/(g1.variable_value+g2.variable_value),5), '<td>', '<td>Increase MAX_HEAP_TABLE_SIZE and TMP_TABLE_SIZE'
from performance_schema.global_status g1, performance_schema.global_status g2
where g1.variable_name='CREATED_TMP_DISK_TABLES'
  and g2.variable_name='CREATED_TMP_TABLES'
  and g1.variable_value/g2.variable_value>0.1
union
select '<tr><!04><td>', g1.variable_name, ' %<td class="align-right">',
       format(g1.variable_value*100/(g2.variable_value),5), '<td>', '<td>Increase BINLOG_CACHE_SIZE'
from performance_schema.global_status g1, performance_schema.global_status g2
where g1.variable_name='BINLOG_CACHE_DISK_USE'
  and g2.variable_name='BINLOG_CACHE_USE'
  and g1.variable_value/g2.variable_value>0.2
union
select '<tr><!05><td>', g1.variable_name, ' #/hour<td class="align-right">',
       format((g1.variable_value*60*60)/g2.variable_value,5), '<td>', '<td>Increase INNODB_LOG_BUFFER_SIZE'
from performance_schema.global_status g1, performance_schema.global_status g2
where g1.variable_name='INNODB_LOG_WAITS'
  and g2.variable_name='UPTIME'
  and g1.variable_value*60*60/g2.variable_value>1
union
select '<tr><!06><td>', g1.variable_name, ' MB/hour<td class="align-right">',
       format((g1.variable_value*60*60)/(g2.variable_value*1024*1024),5), '<td>', '<td>Tune INNODB_LOG_FILE_SIZE'
from performance_schema.global_status g1, performance_schema.global_status g2
where g1.variable_name='INNODB_OS_LOG_WRITTEN'
  and g2.variable_name='UPTIME'
  and (g1.variable_value*60*60)/(g2.variable_value*1024*1024)>5
order by 1;
select '</tbody></table><p>' ;

select '<p><a id="stat56"></a>' ;
select '<p><table class="bordered sortable"><caption>Uptime</caption><tr><td>', truncate(variable_value/(3600*24),0),
       'days ', SEC_TO_TIME(mod(variable_value, 3600*24)), '</td></tr></table>'
  from performance_schema.global_status
 where variable_name='UPTIME';

select '<p><table class="bordered sortable"><caption>Statement Events</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Event<span class="tooltiptext">Event</span></th>';
select '<th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th><th scope="col" class="tac tooltip">Sum Timer<span class="tooltiptext">Sum Timer</span></th><th scope="col" class="tac tooltip">Human Timer<span class="tooltiptext">Human Timer</span></th>';
select '</thead><tbody>';
select '<tr><td>',EVENT_NAME, '<td class="align-right">',COUNT_STAR, '<td class="align-right">',SUM_TIMER_WAIT,
       '<td class="align-right">', SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000)
  from performance_schema.events_statements_summary_global_by_event_name
 where count_star > 0 
 order by SUM_TIMER_WAIT desc 
 limit 10;
select '</tbody></table><p>';

select '<p><table class="bordered sortable"><caption>Wait Events</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Event<span class="tooltiptext">Event</span></th>';
select '<th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th><th scope="col" class="tac tooltip">Sum Timer<span class="tooltiptext">Sum Timer</span></th><th scope="col" class="tac tooltip">Human Timer<span class="tooltiptext">Human Timer</span></th>';
select '</thead><tbody>';
select '<tr><td>',EVENT_NAME, '<td class="align-right">',COUNT_STAR, '<td class="align-right">',SUM_TIMER_WAIT,
       '<td class="align-right">', SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000)  
  from performance_schema.events_waits_summary_global_by_event_name  
 where count_star > 0 
   and event_name != 'idle'
 order by SUM_TIMER_WAIT desc 
 limit 10;
select '</tbody></table><p>';

select '<p><table class="bordered sortable"><caption>Lock Wait</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Type<span class="tooltiptext">Type</span></th><th scope="col" class="tac tooltip">Schema<span class="tooltiptext">Schema</span></th><th scope="col" class="tac tooltip">Name<span class="tooltiptext">Name</span></th>';
select '<th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th><th scope="col" class="tac tooltip">Sum Timer<span class="tooltiptext">Sum Timer</span></th><th scope="col" class="tac tooltip">Human Timer<span class="tooltiptext">Human Timer</span></th>';
select '</thead><tbody>';
select '<tr><td>',OBJECT_TYPE, '<td>', OBJECT_SCHEMA, '<td>', OBJECT_NAME,
       '<td class="align-right">', COUNT_STAR, '<td class="align-right">', SUM_TIMER_WAIT,
       '<td class="align-right">', SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000) 
  from performance_schema.table_lock_waits_summary_by_table
 where count_star > 0 
 order by SUM_TIMER_WAIT desc 
 limit 10;
select '</tbody></table><p>';

select '<p><table class="bordered sortable"><caption>File events</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Event<span class="tooltiptext">Event</span></th>';
select '<th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th><th scope="col" class="tac tooltip">Sum Timer<span class="tooltiptext">Sum Timer</span></th><th scope="col" class="tac tooltip">Human Timer<span class="tooltiptext">Human Timer</span></th>';
select '</thead><tbody>';
select '<tr><td>',EVENT_NAME,'<td class="align-right">',COUNT_STAR,'<td class="align-right">',SUM_TIMER_WAIT,
       '<td class="align-right">', SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000) 
  from performance_schema.file_summary_by_event_name order by SUM_TIMER_WAIT desc limit 10;
select '</tbody></table><p>';

select '<p><table class="bordered sortable sfont"><caption>File access</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">File Name<span class="tooltiptext">File Name</span></th><th scope="col" class="tac tooltip">Event Name<span class="tooltiptext">Event Name</span></th>';
select '<th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th><th scope="col" class="tac tooltip">Sum Timer<span class="tooltiptext">Sum Timer</span></th><th scope="col" class="tac tooltip">Human Timer<span class="tooltiptext">Human Timer</span></th>';
select '<th scope="col" class="tac tooltip">#Read<span class="tooltiptext">#Read</span></th><th scope="col" class="tac tooltip">Timer Read<span class="tooltiptext">Timer Read</span></th><th scope="col" class="tac tooltip">Byte Read<span class="tooltiptext">Byte Read</span></th>';
select '<th scope="col" class="tac tooltip">#Write<span class="tooltiptext">#Write</span></th><th scope="col" class="tac tooltip">Timer Write<span class="tooltiptext">Timer Write</span></th><th scope="col" class="tac tooltip">Byte Write<span class="tooltiptext">Byte Write</span></th>';
select '</thead><tbody>';
select '<tr><td>',FILE_NAME,'<td>',EVENT_NAME,'<td class="align-right">',COUNT_STAR,'<td class="align-right">',SUM_TIMER_WAIT,'<td class="align-right">',
 SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000),'<td class="align-right">',
 COUNT_READ,'<td class="align-right">',SUM_TIMER_READ,'<td class="align-right">',SUM_NUMBER_OF_BYTES_READ,'<td class="align-right">',
 COUNT_WRITE,'<td class="align-right">',SUM_TIMER_WRITE,'<td class="align-right">',SUM_NUMBER_OF_BYTES_WRITE
  from performance_schema.file_summary_by_instance order by SUM_TIMER_WAIT desc limit 10;
select '</tbody></table><p>';

select '<a id="sqls"></a> <p><table class="bordered sortable sfont"><caption>SQL Statements (',
       round((1-sum(if(digest is null, count_star,0))/sum(count_star))*100,2),
       '% )</caption><thead><tr>'
  from performance_schema.events_statements_summary_by_digest;
select '<th scope="col" class="tac tooltip">Schema <span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">Text <span class="tooltiptext">Query, click on the text to see the full query text</span></th>';
select '<th scope="col" class="tac tooltip">Count <span class="tooltiptext"> Count </span></th>';
select '<th scope="col" class="tac tooltip">Sum Timer <span class="tooltiptext">Total time spent</span></th>';
select '<th scope="col" class="tac tooltip">Human Timer <span class="tooltiptext">Human Timer</span></th>';
select '<th scope="col" class="tac tooltip">Average <span class="tooltiptext">Average execution in seconds</span></th>';
select '<th scope="col" class="tac tooltip">Rows affected <span class="tooltiptext">Rows affected</span></th>';
select '<th scope="col" class="tac tooltip">Rows Sent <span class="tooltiptext">Rows Sent</span></th>';
select '<th scope="col" class="tac tooltip">Rows Examined <span class="tooltiptext">Rows Examined</span></th>';
select '<th scope="col" class="tac tooltip">TMP Disk Create <span class="tooltiptext">TMP Disk Create</span></th>';
select '<th scope="col" class="tac tooltip">TMP Create <span class="tooltiptext">TMP Create</span></th>';
select '<th scope="col" class="tac tooltip">Sort Merge# <span class="tooltiptext">Number of Sort Merge</span></th>';
select '<th scope="col" class="tac tooltip">No Index <span class="tooltiptext">No Index</span></th>';
select '<th scope="col" class="tac tooltip">No Good Index <span class="tooltiptext">No Good Index</span></th>';
select '</thead><tbody>';
select '<tr><td>',SCHEMA_NAME,'<td><div class="truncate">',DIGEST_TEXT,
 '</div><td class="align-right">',COUNT_STAR,'<td class="align-\1">',
 SUM_TIMER_WAIT,'<td class="align-\1">',SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000),'<td class="align-right">',
 round(AVG_TIMER_WAIT/1000000000000,3) AVG_TIMER_WAIT,'<td class="align-right">',
 SUM_ROWS_AFFECTED,'<td class="align-right">',SUM_ROWS_SENT,'<td class="align-right">',SUM_ROWS_EXAMINED,'<td class="align-right">',
 SUM_CREATED_TMP_DISK_TABLES,'<td>',SUM_CREATED_TMP_TABLES,'<td>',SUM_SORT_MERGE_PASSES,'<td>', 
 SUM_NO_INDEX_USED,'<td class="align-right">',SUM_NO_GOOD_INDEX_USED
  from performance_schema.events_statements_summary_by_digest order by SUM_TIMER_WAIT desc limit 50;
select '</tbody></table><p>';

select '<a id="sqlslow"></a> <p><table class="bordered sortable sfont"><caption>Slowest Statements</caption><thead><tr>';
select '<th scope="col" class="tac tooltip">Schema <span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">Text <span class="tooltiptext">Query, click on the text to see the full query text</span></th>';
select '<th scope="col" class="tac tooltip">Count <span class="tooltiptext"> Count </span></th>';
select '<th scope="col" class="tac tooltip">Sum Timer <span class="tooltiptext">Total time spent</span></th>';
select '<th scope="col" class="tac tooltip">Human Timer <span class="tooltiptext">Human Timer</span></th>';
select '<th scope="col" class="tac tooltip">Average <span class="tooltiptext">Average execution in seconds</span></th>';
select '<th scope="col" class="tac tooltip">Rows affected <span class="tooltiptext">Rows affected</span></th>';
select '<th scope="col" class="tac tooltip">Rows Sent <span class="tooltiptext">Rows Sent</span></th>';
select '<th scope="col" class="tac tooltip">Rows Examined <span class="tooltiptext">Rows Examined</span></th>';
select '<th scope="col" class="tac tooltip">TMP Disk Create <span class="tooltiptext">TMP Disk Create</span></th>';
select '<th scope="col" class="tac tooltip">TMP Create <span class="tooltiptext">TMP Create</span></th>';
select '<th scope="col" class="tac tooltip">Sort Merge# <span class="tooltiptext">Number of Sort Merge</span></th>';
select '<th scope="col" class="tac tooltip">No Index <span class="tooltiptext">No Index</span></th>';
select '<th scope="col" class="tac tooltip">No Good Index <span class="tooltiptext">No Good Index</span></th>';
select '</thead><tbody>';
select '<tr><td>',SCHEMA_NAME,'<td><div class="truncate">',DIGEST_TEXT,
 '</div><td class="align-right">',COUNT_STAR,'<td class="align-\1">',
 SUM_TIMER_WAIT,'<td class="align-\1">',SEC_TO_TIME(SUM_TIMER_WAIT/1000000000000),'<td class="align-right">',
 round(AVG_TIMER_WAIT/1000000000000,3) AVG_TIMER_WAIT,'<td class="align-right">',
 SUM_ROWS_AFFECTED,'<td class="align-right">',SUM_ROWS_SENT,'<td class="align-right">',SUM_ROWS_EXAMINED,'<td class="align-right">',
 SUM_CREATED_TMP_DISK_TABLES,'<td>',SUM_CREATED_TMP_TABLES,'<td>',SUM_SORT_MERGE_PASSES,'<td>', 
 SUM_NO_INDEX_USED,'<td class="align-right">',SUM_NO_GOOD_INDEX_USED
  from performance_schema.events_statements_summary_by_digest order by AVG_TIMER_WAIT desc limit 20;
select '</tbody></table><p>';

select '<p><table class="bordered sortable"><caption>Consumers</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Name<span class="tooltiptext">Name</span></th>';
select '<th scope="col" class="tac tooltip">Enabled<span class="tooltiptext">Enabled</span></th>';
select '</thead><tbody>';
select '<tr><td>', NAME, '<td>',ENABLED
 from performance_schema.setup_consumers
 order by enabled, name;
select '</tbody></table><p><hr>';

select '<p><a id="idx"></a>' ;
select '<p><pre><table class="bordered sortable"><caption>Indexes</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Table<span class="tooltiptext">Table</span></th>', '<th scope="col" class="tac tooltip">Index<span class="tooltiptext">Index</span></th>', '<th scope="col" class="tac tooltip">Unique<span class="tooltiptext">Unique</span></th>', '<th scope="col" class="tac tooltip">Columns<span class="tooltiptext">Columns</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>',concat(table_schema, '.',table_name) as table_name, '<td>',index_name, 
       '<td>',if(NON_UNIQUE, '','UNIQUE'), '<td>',group_concat(column_name order by SEQ_IN_INDEX asc separator ', ')
  FROM information_schema.statistics
 GROUP BY table_schema, table_name, index_name, NON_UNIQUE
 ORDER BY table_schema, table_name, index_name;
select '</tbody></table></pre><p><hr>';

select '<p><a id="big"></a>' ;
select '<p><table class="bordered sortable"><caption>Biggest Objects</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Database<span class="tooltiptext">Database</span></th>';
select '<th scope="col" class="tac tooltip">Object<span class="tooltiptext">Object</span></th>';
select '<th scope="col" class="tac tooltip">Type<span class="tooltiptext">Type</span></th>';
select '<th scope="col" class="tac tooltip">Engine<span class="tooltiptext">Engine</span></th>';
select '<th scope="col" class="tac tooltip">Bytes<span class="tooltiptext">Bytes</span></th>';
select '<th scope="col" class="tac tooltip">Est. rows<span class="tooltiptext">Est. rows</span></th>';
select '</thead><tbody>';
select '<tr><td>', table_schema,
	'<td>', table_name,
	'<td>T','<td>',engine,
	'<td class="align-right">', format(data_length+index_length,0),
	'<td class="align-right">', format(table_rows,0)
from tables
order by data_length+index_length desc
limit 32;
select '</tbody></table><p><hr>' ;

select '<p><a id="hostc"></a>' ;
select '<p><table class="bordered sortable"><caption>Host Connections</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Host<span class="tooltiptext">Host</span></th>';
select '<th scope="col" class="tac tooltip">Current Connections<span class="tooltiptext">Current Connections</span></th>';
select '<th scope="col" class="tac tooltip">Total Connections<span class="tooltiptext">Total Connections</span></th>';
select '</thead><tbody>';
select '<tr><td>',HOST, '<td>', CURRENT_CONNECTIONS, '<td>', TOTAL_CONNECTIONS
  from performance_schema.hosts
 order by CURRENT_CONNECTIONS desc, TOTAL_CONNECTIONS desc;

select '<tr><td>TOTAL HOSTS:',count(distinct HOST), '<td>', sum(CURRENT_CONNECTIONS), '<td>', sum(TOTAL_CONNECTIONS)
  from performance_schema.hosts;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Host Cache</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Host<span class="tooltiptext">Host</span></th>';
select '<th scope="col" class="tac tooltip">IP<span class="tooltiptext">IP</span></th>';
select '<th scope="col" class="tac tooltip">Validated<span class="tooltiptext">Validated</span></th>';
select '<th scope="col" class="tac tooltip">SUM Errors<span class="tooltiptext">SUM Errors</span></th>';
select '<th scope="col" class="tac tooltip">First Seen<span class="tooltiptext">First Seen</span></th>';
select '<th scope="col" class="tac tooltip">Last Seen<span class="tooltiptext">Last Seen</span></th>';
select '<th scope="col" class="tac tooltip">Last Error Seen<span class="tooltiptext">Last Error Seen</span></th>';
select '<th scope="col" class="tac tooltip"># Handshake Err.<span class="tooltiptext"># Handshake Err.</span></th>';
select '<th scope="col" class="tac tooltip"># Authentication Err.<span class="tooltiptext"># Authentication Err.</span></th>';
select '<th scope="col" class="tac tooltip"># ACL Err.<span class="tooltiptext"># ACL Err.</span></th>';
select '</thead><tbody>';
select '<tr><td>', host, '<td>', ip, '<td>', host_validated,
       '<td class="align-right"><b>', SUM_CONNECT_ERRORS ERR,
       '</b><td>', FIRST_SEEN, '<td>', LAST_SEEN, '<td>', LAST_ERROR_SEEN,
       '<td class="align-right">', COUNT_HANDSHAKE_ERRORS,
       '<td class="align-right">', COUNT_AUTHENTICATION_ERRORS,
       '<td class="align-right">', COUNT_HOST_ACL_ERRORS
from performance_schema.host_cache;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Max Connect Errors</caption><tr><td>', @@global.max_connect_errors, '</td></tr></table><p><hr>' ;

select '<p><a id="repl"></a>' ;
select '<p><table class="bordered sortable"><caption>Replication</caption>' ;
select '<tr><td><pre><b>Source</b>' ;
-- show master status
SHOW BINARY LOG STATUS; 
SHOW VARIABLES LIKE 'rpl_semi_sync_master_%';
SHOW STATUS LIKE 'rpl_semi_sync_master_status';
select '<p>' ;
show binary logs;
select '</pre><tr><td><pre><b>Replica</b>' ;
SHOW VARIABLES LIKE '%READ_ONLY%';
SHOW VARIABLES LIKE 'rpl_semi_sync_slave_enabled';
SHOW STATUS LIKE 'rpl_semi_sync_slave_status';
select '</pre><tr><td><pre><b>Galera Cluster</b>' ;
show status where variable_name in ('wsrep_cluster_size', 'wsrep_cluster_status', 'wsrep_flow_control_paused', 'wsrep_ready', 'wsrep_connected', 'wsrep_local_state_comment');
show status where variable_name in ('wsrep_local_state', 'wsrep_local_recv_queue', 'wsrep_reject_queries', 'wsrep_sst_donor_rejects_queries', 'wsrep_cluster_status', 'wsrep_desync');
select '</pre></table><p>' ;

select '<p><table class="bordered sortable"><caption>Replica Connection configuration</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">CHANNEL NAME<span class="tooltiptext">CHANNEL NAME</span></th>';
select '<th scope="col" class="tac tooltip">MASTER HOST<span class="tooltiptext">MASTER HOST</span></th>';
select '<th scope="col" class="tac tooltip">PORT<span class="tooltiptext">PORT</span></th>';
select '<th scope="col" class="tac tooltip">USER<span class="tooltiptext">USER</span></th>';
select '<th scope="col" class="tac tooltip">AUTO POSITION<span class="tooltiptext">AUTO POSITION</span></th>';
select '<th scope="col" class="tac tooltip">SSL<span class="tooltiptext">SSL</span></th>';
select '<th scope="col" class="tac tooltip">HEARTBEAT_INTERVAL<span class="tooltiptext">HEARTBEAT_INTERVAL</span></th>';
select '</thead><tbody>';
select '<tr><td>',CHANNEL_NAME, '<td>',HOST, '<td>',PORT, '<td>',USER, '<td>',AUTO_POSITION,
       '<td>',SSL_ALLOWED, '<td>',HEARTBEAT_INTERVAL
  from performance_schema.replication_connection_configuration;
select '</tbody></table><p>' ;
select '<p><table class="bordered sortable"><caption>Connection status</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">CHANNEL NAME<span class="tooltiptext">CHANNEL NAME</span></th>';
select '<th scope="col" class="tac tooltip">GROUP NAME<span class="tooltiptext">GROUP NAME</span></th>';
select '<th scope="col" class="tac tooltip">SOURCE UUID<span class="tooltiptext">SOURCE UUID</span></th>';
select '<th scope="col" class="tac tooltip">THREAD ID<span class="tooltiptext">THREAD ID</span></th>';
select '<th scope="col" class="tac tooltip">SERVICE STATE<span class="tooltiptext">SERVICE STATE</span></th>';
select '<th scope="col" class="tac tooltip">RECEIVED HEARTBEATS<span class="tooltiptext">RECEIVED HEARTBEATS</span></th>';
select '<th scope="col" class="tac tooltip">LAST HEARTBEAT<span class="tooltiptext">LAST HEARTBEAT</span></th>';
select '<th scope="col" class="tac tooltip">RECEIVED TRANSACTION SET<span class="tooltiptext">RECEIVED TRANSACTION SET</span></th>';
select '<th scope="col" class="tac tooltip">LAST_ERROR NUMBER<span class="tooltiptext">LAST_ERROR NUMBER</span></th>';
select '<th scope="col" class="tac tooltip">LAST_ERROR MESSAGE<span class="tooltiptext">LAST_ERROR MESSAGE</span></th>';
select '<th scope="col" class="tac tooltip">LAST_ERROR TIMESTAMP<span class="tooltiptext">LAST_ERROR TIMESTAMP</span></th>';
select '</thead><tbody>';
select '<tr><td>',CHANNEL_NAME, '<td>',GROUP_NAME, '<td>',SOURCE_UUID, '<td>',THREAD_ID,
       '<td>',SERVICE_STATE, '<td>',COUNT_RECEIVED_HEARTBEATS,
       '<td>',LAST_HEARTBEAT_TIMESTAMP, '<td>',RECEIVED_TRANSACTION_SET, '<td>',LAST_ERROR_NUMBER,
       '<td>',LAST_ERROR_MESSAGE, '<td>',LAST_ERROR_TIMESTAMP 
  from performance_schema.replication_connection_status;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Applier Status</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">CHANNEL NAME<span class="tooltiptext">CHANNEL NAME</span></th>';
select '<th scope="col" class="tac tooltip">THREAD_ID<span class="tooltiptext">THREAD_ID</span></th>';
select '<th scope="col" class="tac tooltip">SERVICE_STATE<span class="tooltiptext">SERVICE_STATE</span></th>';
select '<th scope="col" class="tac tooltip">LAST_ERROR NUMBER<span class="tooltiptext">LAST_ERROR NUMBER</span></th>';
select '<th scope="col" class="tac tooltip">LAST_ERROR MESSAGE<span class="tooltiptext">LAST_ERROR MESSAGE</span></th>';
select '<th scope="col" class="tac tooltip">LAST_ERROR TIMESTAMP<span class="tooltiptext">LAST_ERROR TIMESTAMP</span></th>';
select '</thead><tbody>';
select '<tr><td>',CHANNEL_NAME, '<td>',THREAD_ID, '<td>',SERVICE_STATE, '<td>',LAST_ERROR_NUMBER,
       '<td>',LAST_ERROR_MESSAGE, '<td>',LAST_ERROR_TIMESTAMP
  from performance_schema.replication_applier_status_by_coordinator;
select '</tbody></table><p>' ;
select '<p><table class="bordered sortable"><caption>Applier Status by worker</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">CHANNEL NAME<span class="tooltiptext">CHANNEL NAME</span></th>';
select '<th scope="col" class="tac tooltip">WORKER_ID<span class="tooltiptext">WORKER_ID</span></th>';
select '<th scope="col" class="tac tooltip">THREAD_ID<span class="tooltiptext">THREAD_ID</span></th>';
select '<th scope="col" class="tac tooltip">SERVICE_STATE<span class="tooltiptext">SERVICE_STATE</span></th>';
select '<th scope="col" class="tac tooltip">LAST_APPLIED_TRANSACTION<span class="tooltiptext">LAST_APPLIED_TRANSACTION</span></th>';
select '<th scope="col" class="tac tooltip">LAST_ERROR NUMBER<span class="tooltiptext">LAST_ERROR NUMBER</span></th>';
select '<th scope="col" class="tac tooltip">LAST_ERROR MESSAGE<span class="tooltiptext">LAST_ERROR MESSAGE</span></th>';
select '<th scope="col" class="tac tooltip">LAST_ERROR TIMESTAMP<span class="tooltiptext">LAST_ERROR TIMESTAMP</span></th>';
select '</thead><tbody>';
select '<tr><td>',CHANNEL_NAME, '<td>',WORKER_ID, '<td>',THREAD_ID,
       '<td>',SERVICE_STATE, '<td>',LAST_APPLIED_TRANSACTION,
       '<td>',LAST_ERROR_NUMBER, '<td>',LAST_ERROR_MESSAGE, '<td>',LAST_ERROR_TIMESTAMP 
  from performance_schema.replication_applier_status_by_worker;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Group Replication/InnoDB Cluster</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">MEMBER_HOST<span class="tooltiptext">MEMBER_HOST</span></th>';
select '<th scope="col" class="tac tooltip">MEMBER_PORT<span class="tooltiptext">MEMBER_PORT</span></th>';
select '<th scope="col" class="tac tooltip">MEMBER_ID<span class="tooltiptext">MEMBER_ID</span></th>';
select '<th scope="col" class="tac tooltip">MEMBER_STATE<span class="tooltiptext">MEMBER_STATE</span></th>';
select '</thead><tbody>';
select '<tr><td>', MEMBER_HOST, '<td>',MEMBER_PORT, '<td>',MEMBER_ID, '<td>',MEMBER_STATE
  from performance_schema.replication_group_members;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Primary Member</caption><thead><tr><th scope="col" class="tac tooltip">Primary Member<span class="tooltiptext">Primary Member</span></th><th scope="col" class="tac tooltip">Host<span class="tooltiptext">Host</span></th></tr></thead><tbody>' ;
SELECT '<tr><td>', VARIABLE_VALUE, '<td>', member_host, ':', member_port
  FROM performance_schema.global_status
  JOIN performance_schema.replication_group_members
 WHERE VARIABLE_NAME= 'group_replication_primary_member'
   AND member_id=variable_value;
select '</tbody></table><p>' ;

select '<p><a id="gtid"></a>' ;
select '<p><table class="bordered sortable"><caption>GTID</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Parameter<span class="tooltiptext">Parameter</span></th>';
select '<th scope="col" class="tac tooltip">Value<span class="tooltiptext">Value</span></th>' ;
select '</thead><tbody>';
select '<tr><td>', variable_name, '<td>', variable_value
  from performance_schema.global_variables
 where variable_name = 'server_uuid'
 order by variable_name;
select '<tr><td>', variable_name, '<td>', variable_value
  from performance_schema.global_variables
 where variable_name like '%gtid%'
 order by variable_name;
select '</tbody></table><p><p>' ;

select '<p><a id="repl_app"></a>' ;
select '<pre><p><b>Cluster restrictions to APPs</b><p>' ;

select '<p><table class="bordered sortable"><caption>non-InnoDB Engines</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Table<span class="tooltiptext">Table</span></th>', '<th scope="col" class="tac tooltip">Engine<span class="tooltiptext">Engine</span></th>', '<th scope="col" class="tac tooltip">Rows<span class="tooltiptext">Rows</span></th>', '<th scope="col" class="tac tooltip">Size MB<span class="tooltiptext">Size MB</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>',concat(table_schema,'.',table_name), '<td>',engine, '<td>',table_rows, 
       '<td>',round((index_length+data_length)/1024/1024,2)
  FROM information_schema.tables 
 WHERE (engine != 'InnoDB')
   AND table_schema NOT IN ('information_schema', 'mysql', 'performance_schema')
 ORDER BY table_schema, table_name;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Tables without PK or UKs</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Table<span class="tooltiptext">Table</span></th>';
select '<th scope="col" class="tac tooltip">Engine<span class="tooltiptext">Engine</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>',concat(tables.table_schema,'.',tables.table_name), '<td>',tables.engine 
  FROM information_schema.tables 
  LEFT JOIN (SELECT table_schema, table_name 
               FROM information_schema.statistics 
              GROUP BY table_schema, table_name, index_name
             HAVING SUM(case when non_unique = 0 and nullable != 'YES' then 1 else 0 end) = count(*) ) puks 
         ON tables.table_schema = puks.table_schema and tables.table_name = puks.table_name 
 WHERE puks.table_name is null ;
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>Forbidden/limited/dangerous statements used</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Statement<span class="tooltiptext">Statement</span></th>';
select '<th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th>';
select '<th scope="col" class="tac tooltip">Errors<span class="tooltiptext">Errors</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>',event_name, '<td>',count_star, '<td>',sum_errors 
  FROM performance_schema.events_statements_summary_global_by_event_name 
 WHERE event_name  like '%savepoint%'
   AND count_star>0;

SELECT '<tr><td>',event_name, '<td>',count_star, '<td>',sum_errors 
  FROM performance_schema.events_statements_summary_global_by_event_name 
 WHERE event_name  REGEXP '.*sql/(create|drop|alter).*' 
   AND event_name NOT REGEXP '.*user';
select '</tbody></table><p>' ;
select '</pre><p><hr>' ;

select '<p><a id="stor"></a>' ;
select '<p><table class="bordered sortable"><caption>Stored Routines</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Schema<span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">Type<span class="tooltiptext">Type</span></th>';
select '<th scope="col" class="tac tooltip">Objects<span class="tooltiptext">Objects</span></th>';
select '</thead><tbody>';
 select '<tr><td>',routine_schema, 
  '<td>', routine_type, 
  '<td>', count(*)
 from routines
 group by routine_schema, routine_type;
select '</tbody></table><p>' ;

select '<p><a id="\1"></a>' ;
select '<p><a id="dtype"></a>' ;
select '<p><table class="bordered sortable"><caption>Data types</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Schema<span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">Data Type<span class="tooltiptext">Data Type</span></th>';
select '<th scope="col" class="tac tooltip">Count(*)<span class="tooltiptext">Count(*)</span></th>';
select '</thead><tbody>';
 select '<tr><td>',table_schema, 
  '<td>', data_type, 
  '<td>', count(*)
 from columns
 where table_schema not in ('mysql', 'performance_schema', 'information_schema', 'sys')
 group by table_schema, data_type;
select '</tbody></table><p>' ;

select '<p><a id="\1"></a>' ;
select '<p><a id="reskey"></a>' ;
select '<p><table class="bordered sortable"><caption>Reserved Keywords Usage</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Schema<span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">Table<span class="tooltiptext">Table</span></th>';
select '<th scope="col" class="tac tooltip">Column<span class="tooltiptext">Column</span></th>';
select '</thead><tbody>';

select '<tr><td>',TABLE_SCHEMA, '<td>',TABLE_NAME, '<td> '
  from information_schema.columns
 where table_name in (
'ACCESSIBLE', 'ADD', 'ALL', 'ALTER', 'ANALYZE', 'AND', 'AS', 'ASC', 'ASENSITIVE', 'BEFORE', 'BETWEEN', 'BIGINT', 'BINARY', 'BLOB', 'BOTH', 'BY', 'CALL', 'CASCADE', 'CASE', 'CHANGE', 'CHAR', 'CHARACTER', 'CHECK', 'COLLATE', 'COLUMN', 'CONDITION', 'CONSTRAINT', 'CONTINUE', 'CONVERT', 'CREATE', 'CROSS', 'CUBE', 'CUME_DIST', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURRENT_USER', 'CURSOR', 'DATABASE', 'DATABASES', 'DAY_HOUR', 'DAY_MICROSECOND', 'DAY_MINUTE', 'DAY_SECOND', 'DEC', 'DECIMAL', 'DECLARE', 'DEFAULT', 'DELAYED', 'DELETE', 'DENSE_RANK', 'DESC', 'DESCRIBE', 'DETERMINISTIC', 'DISTINCT', 'DISTINCTROW', 'DIV', 'DOUBLE', 'DROP', 'DUAL', 'EACH', 'ELSE', 'ELSEIF', 'EMPTY', 'ENCLOSED', 'ESCAPED', 'EXCEPT', 'EXISTS', 'EXIT', 'EXPLAIN', 'FALSE', 'FETCH', 'FIRST_VALUE', 'FLOAT', 'FLOAT4', 'FLOAT8', 'FOR', 'FORCE', 'FOREIGN', 'FROM', 'FULLTEXT', 'FUNCTION', 'GENERATED', 'GET', 'GRANT', 'GROUP', 'GROUPING', 'GROUPS', 'HAVING', 'HIGH_PRIORITY', 'HOUR_MICROSECOND', 'HOUR_MINUTE', 'HOUR_SECOND', 'IF', 'IGNORE', 'IN', 'INDEX', 'INFILE', 'INNER', 'INOUT', 'INSENSITIVE', 'INSERT', 'INT', 'INT1', 'INT2', 'INT3', 'INT4', 'INT8', 'INTEGER', 'INTERSECT', 'INTERVAL', 'INTO', 'IO_AFTER_GTIDS', 'IO_BEFORE_GTIDS', 'IS', 'ITERATE', 'JOIN', 'JSON_TABLE', 'KEY', 'KEYS', 'KILL', 'LAG', 'LAST_VALUE', 'LATERAL', 'LEAD', 'LEADING', 'LEAVE', 'LEFT', 'LIKE', 'LIMIT', 'LINEAR', 'LINES', 'LOAD', 'LOCALTIME', 'LOCALTIMESTAMP', 'LOCK', 'LONG', 'LONGBLOB', 'LONGTEXT', 'LOOP', 'LOW_PRIORITY', 'MASTER_BIND', 'MASTER_SSL_VERIFY_SERVER_CERT', 'MATCH', 'MAXVALUE', 'MEDIUMBLOB', 'MEDIUMINT', 'MEDIUMTEXT', 'MIDDLEINT', 'MINUTE_MICROSECOND', 'MINUTE_SECOND', 'MOD', 'MODIFIES', 'NATURAL', 'NOT', 'NO_WRITE_TO_BINLOG', 'NTH_VALUE', 'NTILE', 'NULL', 'NUMERIC', 'OF', 'ON', 'OPTIMIZE', 'OPTIMIZER_COSTS', 'OPTION', 'OPTIONALLY', 'OR', 'ORDER', 'OUT', 'OUTER', 'OUTFILE', 'OVER', 'PARTITION', 'PERCENT_RANK', 'PRECISION', 'PRIMARY', 'PROCEDURE', 'PURGE', 'RANGE', 'RANK', 'READ', 'READS', 'READ_WRITE', 'REAL', 'RECURSIVE', 'REFERENCES', 'REGEXP', 'RELEASE', 'RENAME', 'REPEAT', 'REPLACE', 'REQUIRE', 'RESIGNAL', 'RESTRICT', 'RETURN', 'REVOKE', 'RIGHT', 'RLIKE', 'ROW', 'ROWS', 'ROW_NUMBER', 'SCHEMA', 'SCHEMAS', 'SECOND_MICROSECOND', 'SELECT', 'SENSITIVE', 'SEPARATOR', 'SET', 'SHOW', 'SIGNAL', 'SMALLINT', 'SPATIAL', 'SPECIFIC', 'SQL', 'SQLEXCEPTION', 'SQLSTATE', 'SQLWARNING', 'SQL_BIG_RESULT', 'SQL_CALC_FOUND_ROWS', 'SQL_SMALL_RESULT', 'SSL', 'STARTING', 'STORED', 'STRAIGHT_JOIN', 'SYSTEM', 'TABLE', 'TERMINATED', 'THEN', 'TINYBLOB', 'TINYINT', 'TINYTEXT', 'TO', 'TRAILING', 'TRIGGER', 'TRUE', 'UNDO', 'UNION', 'UNIQUE', 'UNLOCK', 'UNSIGNED', 'UPDATE', 'USAGE', 'USE', 'USING', 'UTC_DATE', 'UTC_TIME', 'UTC_TIMESTAMP', 'VALUES', 'VARBINARY', 'VARCHAR', 'VARCHARACTER', 'VARYING', 'VIRTUAL', 'WHEN', 'WHERE', 'WHILE', 'WINDOW', 'WITH', 'WRITE', 'XOR', 'YEAR_MONTH', 'ZEROFILL',  
'NONBLOCKING' )
 order by TABLE_SCHEMA, TABLE_NAME;

select '<tr><td>',TABLE_SCHEMA, '<td>',TABLE_NAME, '<td>',COLUMN_NAME
  from information_schema.columns
 where column_name in (
'ACCESSIBLE', 'ADD', 'ALL', 'ALTER', 'ANALYZE', 'AND', 'AS', 'ASC', 'ASENSITIVE', 'BEFORE', 'BETWEEN', 'BIGINT', 'BINARY', 'BLOB', 'BOTH', 'BY', 'CALL', 'CASCADE', 'CASE', 'CHANGE', 'CHAR', 'CHARACTER', 'CHECK', 'COLLATE', 'COLUMN', 'CONDITION', 'CONSTRAINT', 'CONTINUE', 'CONVERT', 'CREATE', 'CROSS', 'CUBE', 'CUME_DIST', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURRENT_USER', 'CURSOR', 'DATABASE', 'DATABASES', 'DAY_HOUR', 'DAY_MICROSECOND', 'DAY_MINUTE', 'DAY_SECOND', 'DEC', 'DECIMAL', 'DECLARE', 'DEFAULT', 'DELAYED', 'DELETE', 'DENSE_RANK', 'DESC', 'DESCRIBE', 'DETERMINISTIC', 'DISTINCT', 'DISTINCTROW', 'DIV', 'DOUBLE', 'DROP', 'DUAL', 'EACH', 'ELSE', 'ELSEIF', 'EMPTY', 'ENCLOSED', 'ESCAPED', 'EXCEPT', 'EXISTS', 'EXIT', 'EXPLAIN', 'FALSE', 'FETCH', 'FIRST_VALUE', 'FLOAT', 'FLOAT4', 'FLOAT8', 'FOR', 'FORCE', 'FOREIGN', 'FROM', 'FULLTEXT', 'FUNCTION', 'GENERATED', 'GET', 'GRANT', 'GROUP', 'GROUPING', 'GROUPS', 'HAVING', 'HIGH_PRIORITY', 'HOUR_MICROSECOND', 'HOUR_MINUTE', 'HOUR_SECOND', 'IF', 'IGNORE', 'IN', 'INDEX', 'INFILE', 'INNER', 'INOUT', 'INSENSITIVE', 'INSERT', 'INT', 'INT1', 'INT2', 'INT3', 'INT4', 'INT8', 'INTEGER', 'INTERSECT', 'INTERVAL', 'INTO', 'IO_AFTER_GTIDS', 'IO_BEFORE_GTIDS', 'IS', 'ITERATE', 'JOIN', 'JSON_TABLE', 'KEY', 'KEYS', 'KILL', 'LAG', 'LAST_VALUE', 'LATERAL', 'LEAD', 'LEADING', 'LEAVE', 'LEFT', 'LIKE', 'LIMIT', 'LINEAR', 'LINES', 'LOAD', 'LOCALTIME', 'LOCALTIMESTAMP', 'LOCK', 'LONG', 'LONGBLOB', 'LONGTEXT', 'LOOP', 'LOW_PRIORITY', 'MASTER_BIND', 'MASTER_SSL_VERIFY_SERVER_CERT', 'MATCH', 'MAXVALUE', 'MEDIUMBLOB', 'MEDIUMINT', 'MEDIUMTEXT', 'MIDDLEINT', 'MINUTE_MICROSECOND', 'MINUTE_SECOND', 'MOD', 'MODIFIES', 'NATURAL', 'NOT', 'NO_WRITE_TO_BINLOG', 'NTH_VALUE', 'NTILE', 'NULL', 'NUMERIC', 'OF', 'ON', 'OPTIMIZE', 'OPTIMIZER_COSTS', 'OPTION', 'OPTIONALLY', 'OR', 'ORDER', 'OUT', 'OUTER', 'OUTFILE', 'OVER', 'PARTITION', 'PERCENT_RANK', 'PRECISION', 'PRIMARY', 'PROCEDURE', 'PURGE', 'RANGE', 'RANK', 'READ', 'READS', 'READ_WRITE', 'REAL', 'RECURSIVE', 'REFERENCES', 'REGEXP', 'RELEASE', 'RENAME', 'REPEAT', 'REPLACE', 'REQUIRE', 'RESIGNAL', 'RESTRICT', 'RETURN', 'REVOKE', 'RIGHT', 'RLIKE', 'ROW', 'ROWS', 'ROW_NUMBER', 'SCHEMA', 'SCHEMAS', 'SECOND_MICROSECOND', 'SELECT', 'SENSITIVE', 'SEPARATOR', 'SET', 'SHOW', 'SIGNAL', 'SMALLINT', 'SPATIAL', 'SPECIFIC', 'SQL', 'SQLEXCEPTION', 'SQLSTATE', 'SQLWARNING', 'SQL_BIG_RESULT', 'SQL_CALC_FOUND_ROWS', 'SQL_SMALL_RESULT', 'SSL', 'STARTING', 'STORED', 'STRAIGHT_JOIN', 'SYSTEM', 'TABLE', 'TERMINATED', 'THEN', 'TINYBLOB', 'TINYINT', 'TINYTEXT', 'TO', 'TRAILING', 'TRIGGER', 'TRUE', 'UNDO', 'UNION', 'UNIQUE', 'UNLOCK', 'UNSIGNED', 'UPDATE', 'USAGE', 'USE', 'USING', 'UTC_DATE', 'UTC_TIME', 'UTC_TIMESTAMP', 'VALUES', 'VARBINARY', 'VARCHAR', 'VARCHARACTER', 'VARYING', 'VIRTUAL', 'WHEN', 'WHERE', 'WHILE', 'WINDOW', 'WITH', 'WRITE', 'XOR', 'YEAR_MONTH', 'ZEROFILL',  
'NONBLOCKING' );
 select '</tbody></table><p><hr>' ;

select '<p><a id="sche"></a>' ;
select '<p><table class="bordered"><tr><td><b>Scheduler</b></td></tr>' ;
select '<tr><td>', variable_value
from performance_schema.global_variables
where variable_name='EVENT_SCHEDULER';
select '</table><p>' ;

select '<p><table class="bordered sortable"><caption>Scheduled Jobs</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Event<span class="tooltiptext">Event</span></th>';
select '<th scope="col" class="tac tooltip">Status<span class="tooltiptext">Status</span></th>';
select '<th scope="col" class="tac tooltip">Type<span class="tooltiptext">Type</span></th>';
select '<th scope="col" class="tac tooltip">Schedule<span class="tooltiptext">Schedule</span></th>';
select '<th scope="col" class="tac tooltip">Command<span class="tooltiptext">Command</span></th>';
select '</thead><tbody>';
 select '<tr><td>',concat(event_schema,'.',event_name), 
  '<td>', status,
  '<td>', event_type,
  '<td>', ifnull(execute_at,''),
	ifnull(interval_value,''),ifnull(interval_field,''),
  '<td>', event_definition
  from events;
select '</tbody></table><p><hr>' ;

select '<p><a id="\1"></a>' ;
select '<p><a id="nls"></a>' ;
select '<p><table class="bordered sortable"><caption>NLS</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Schema<span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">DEFAULT CHARACTER_SET_NAME<span class="tooltiptext">DEFAULT CHARACTER_SET_NAME</span></th>';
select '<th scope="col" class="tac tooltip">DEFAULT COLLATION_NAME<span class="tooltiptext">DEFAULT COLLATION_NAME</span></th>';
select '</thead><tbody>';
SELECT '<tr><td>',schema_name, '<td>', DEFAULT_CHARACTER_SET_NAME, '<td>', DEFAULT_COLLATION_NAME
  FROM information_schema.SCHEMATA
 where schema_name not in ('mysql', 'information_schema', 'sys', 'performance_schema', 'test', 'tmpdir')
   and schema_name not like '%lost+found';
select '</tbody></table><p>' ;

select '<p><table class="bordered sortable"><caption>NLS: Columns</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Schema<span class="tooltiptext">Schema</span></th>';
select '<th scope="col" class="tac tooltip">CHARACTER_SET_NAME<span class="tooltiptext">CHARACTER_SET_NAME</span></th>';
select '<th scope="col" class="tac tooltip">COLLATION_NAME<span class="tooltiptext">COLLATION_NAME</span></th>';
select '<th scope="col" class="tac tooltip">Count<span class="tooltiptext">Count</span></th>';
select '</thead><tbody>';
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
select '</tbody></table><p>' ;

select '<p><table class="bordered"><tr><td><b>NLS: Parameters</b></td></tr>';
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', replace(variable_value,',',', ')
  from performance_schema.global_variables
 where variable_name like 'character_set_%' or variable_name like 'collation_%'
 order by variable_name;
select '</table><p><hr>' ;

select '<p><a name="par"></a>' ;
select '<p><table class="bordered"><tr><td><b>MySQL Parameters</b></td></tr>';
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', replace(variable_value,',',', ')
  from performance_schema.global_variables
 where variable_name<>'server_audit_loc_info'
 order by variable_name;
select '</table><p><hr>' ;

select '<p><table class="bordered sortable"><caption>Versions</caption><tbody>' ;
select '<tr><td>','MySQL:', variable_value
  from performance_schema.global_variables
 where variable_name ='version'
union select '<tr><td>plugin:',plugin_name, plugin_version
  from plugins
union select '<tr><td>',concat(variable_name, ': '), variable_value
  from performance_schema.global_variables
 where variable_name like 'version%'
union select '<tr><td>', 'SYS version:', sys_version
  from sys.version;
select '</tbody></table><p><hr>' ;

select '<p><a id="gstat"></a>' ;
select '<p><table class="bordered sortable"><caption>MySQL Global Status</caption><thead><tr>' ;
select '<th scope="col" class="tac tooltip">Statistic<span class="tooltiptext">Statistic</span></th>';
select '<th scope="col" class="tac tooltip">Value<span class="tooltiptext">Value</span></th>';
select '</thead><tbody>';
select '<tr><td>', variable_name, '<td>', variable_value
  from performance_schema.global_status
 order by variable_name;
select '</tbody></table><p><hr>' ;
select '<div><a href="#top" class="back-to-top">⬆ Back to index</a></div>' as info;

select '<hr><p>Statistics generated on: ', now();
select '<br>More info on';
select '<a href="https://www.meo.bogliolo.name/#my">this site</a>' as info;
select '<br> Copyright: 2025 meob - License: GNU General Public License v3.0' as info;
select '<br> Sources: https://github.com/meob/db2html/ <p>' as info;
select '<script src="util.js"></script>' ;
select '</body></html>' as info;
