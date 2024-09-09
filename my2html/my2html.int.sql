select '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8" /><link rel="stylesheet" href="ux3.css" /> <title>';
select  @@hostname, ':', @@port ;
select ' - my2html MySQL Internal and SYS Statistics Addendum</title></head><body>';
select '<h1>MySQL Detailed Internal, SYS and InnoDB Statistics</h1><pre>';

select * from sys.version;
select * from sys.user_summary;
select * from sys.host_summary;
select * from sys.memory_global_by_current_bytes;

select * from sys.processlist;
select * from sys.session;
select * from sys.session_ssl_status;
select * from sys.statement_analysis limit 100;
select * from sys.sys_config;

select '</pre><p><pre>' as '';
SELECT user, host,
       CONCAT(Select_priv, Lock_tables_priv) AS selock,
       CONCAT(Insert_priv, Update_priv, Delete_priv, Create_priv, Drop_priv) AS modif,
       CONCAT(Grant_priv, References_priv, Index_priv, Alter_priv) AS meta,
       CONCAT(Create_tmp_table_priv, Create_view_priv, Show_view_priv) AS view,
       CONCAT(Create_routine_priv, Alter_routine_priv, Execute_priv) AS func,
       CONCAT(Repl_slave_priv, Repl_client_priv) AS replic,
       CONCAT(Super_priv, Shutdown_priv, Process_priv, File_priv, Show_db_priv, Reload_priv) AS admin
  FROM USER
 ORDER BY user, host;

select TABLE_SCHEMA, TABLE_NAME, PARTITION_NAME, PARTITION_ORDINAL_POSITION,
	PARTITION_METHOD, PARTITION_EXPRESSION, PARTITION_DESCRIPTION,
	TABLE_ROWS, AVG_ROW_LENGTH, DATA_LENGTH, INDEX_LENGTH,
	DATA_FREE, CREATE_TIME
  FROM information_schema.partitions 
 where partition_name is not null
 order by TABLE_SCHEMA, TABLE_NAME, PARTITION_ORDINAL_POSITION;

select (max(variable_value)-min(variable_value))/(1024*1024) as Grow_MB,
       datediff(max(timest),min(timest)) as Period,
       (max(variable_value)-min(variable_value))/(1024*1024)*30/datediff(max(timest),min(timest)) MB_Month
  FROM my2.status 
 where variable_name = 'SIZEDB.TOTAL';

SELECT TABLE_SCHEMA, TABLE_NAME, CREATE_OPTIONS
  FROM INFORMATION_SCHEMA.TABLES
 WHERE CREATE_OPTIONS LIKE '%ENCRYPTION="Y"%';
 
select '</pre><p><pre>' as '';
SELECT * FROM performance_schema.replication_group_members;
SELECT * FROM performance_schema.replication_group_member_stats;
SELECT * FROM performance_schema.replication_applier_status;

select * from mysql_innodb_cluster_metadata.schema_version;
select * from mysql_innodb_cluster_metadata.clusters;
select * from mysql_innodb_cluster_metadata.hosts;
select * from mysql_innodb_cluster_metadata.instances;
select * from mysql_innodb_cluster_metadata.routers;
select * from mysql_innodb_cluster_metadata.replicasets;

show master status;
show slave status \G

SELECT NAME, PROCESSLIST_TIME
  FROM performance_schema.threads
 WHERE NAME = 'thread/sql/slave_worker'
   AND (PROCESSLIST_STATE IS NULL  or PROCESSLIST_STATE != 'Waiting for an event from Coordinator')
 ORDER BY PROCESSLIST_TIME DESC;

select '</pre><p><pre>' as '';
SHOW BINLOG EVENTS limit 50;

SHOW ENGINE INNODB MUTEX;
SHOW ENGINE INNODB STATUS;
select '</pre><p><hr>Generated on: ', now();
select '<p></body></html>';
