-- Program:	 ProxySQL2html.sql
--		 ProxySQL SQL report in HTML
-- Version:      1.0.4: latest releases (2025-04-01)
-- Author:       Bartolomeo Bogliolo mail@meo.bogliolo.name
-- Date:         2018-02-14
-- License:      GPL

select '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8" /><link rel="stylesheet" href="ux3.css" /> <title>';
select 'ProxySQL Statistics</title></head><body>';

select '<h1> ProxySQL </h1>';

select '<P><A NAME="top"></A>' ;
select '<p>Table of contents:' ;
select '<table><tr><td><ul>' ;
select '<li><A HREF="#summ">Summary</A>' ;
select '<li><A HREF="#status">Status</A>' ;
select '<li><A HREF="#conf">Configuration</A>' ;
select '<li><A HREF="#stats">Statistics</A>' ;

select '<li><A HREF="#det">Details</A><ul>' ;
select '<li><A HREF="#err">Errors</A>' ;
select '<li><A HREF="#log">Logs</A>' ;
select '<li><A HREF="#par">ProxySQL Parameters</A>' ;
select '<li><A HREF="#par">ProxySQL Variables</A></ul>' ;

select '</ul></table><p><hr>' ;
 
select '<P>Statistics generated at: ', current_timestamp;
select ' by: ';
select user();
 
select 'using: <I><b>proxysql2html.sql</b> v.1.0.4';
select '<br>Software by ';
select '<A HREF="https://meoshome.it.eu.org/#dwn">Meo</A></I><p><HR>';

select '<P><A NAME="summ"></A>';
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>';
select '<tr><td><b>Item</b>', '<td><b>Value</b>';

select '<tr><td>Version :', '<td>', variable_value
  from main.global_variables
 where variable_name='admin-version';

select '<tr><td>Running for (days) :', '<td>', round(variable_value/3600/24.0, 1)
  from stats.stats_mysql_global
 where variable_name='ProxySQL_Uptime';

select '<tr><td>MySQL Interface :', '<td>', variable_value
  from main.global_variables
 where variable_name='mysql-interfaces';
select '<tr><td>MySQL Version :', '<td>', variable_value
  from main.global_variables
 where variable_name='mysql-server_version';
select '<tr><td>Max connections :', '<td>', variable_value
  from main.global_variables
 where variable_name='mysql-max_connections';

select '<tr><td>Admin Interface :', '<td>', variable_value
  from main.global_variables
 where variable_name='admin-mysql_ifaces';

select '<tr><td>Users (Runtime/Memory/Disk):', '<td>', count(*)
  from main.runtime_mysql_users;
select ' / ', count(*)
  from main.mysql_users;
select ' / ', count(*)
  from disk.mysql_users;

select '<tr><td>Servers (R/M/D):', '<td>', count(*)
  from main.runtime_mysql_servers;
select ' / ', count(*)
  from main.mysql_servers;
select ' / ', count(*)
  from disk.mysql_servers;

select '<tr><td>Replication Hostgroups (R/M/D):', '<td>', count(*)
  from main.runtime_mysql_replication_hostgroups;
select ' / ', count(*)
  from main.mysql_replication_hostgroups;
select ' / ', count(*)
  from disk.mysql_replication_hostgroups;

select '<tr><td>Galera Hostgroups (R/M/D):', '<td>', count(*)
  from main.runtime_mysql_galera_hostgroups;
select ' / ', count(*)
  from main.mysql_galera_hostgroups;
select ' / ', count(*)
  from disk.mysql_galera_hostgroups;

select '<tr><td>Group Replication Hostgroups (R/M/D):', '<td>', count(*)
  from main.runtime_mysql_group_replication_hostgroups;
select ' / ', count(*)
  from main.mysql_group_replication_hostgroups;
select ' / ', count(*)
  from disk.mysql_group_replication_hostgroups;

select '<tr><td>Frontend Users (R/M/D):', '<td>', count(*)
  from main.runtime_mysql_users
 where active=1
   and frontend=1;
select ' / ', count(*)
  from main.mysql_users
 where active=1
   and frontend=1;
select ' / ', count(*)
  from disk.mysql_users
 where active=1
   and frontend=1;

select '<tr><td>Query Rules (R/M/D):', '<td>', count(*)
  from main.runtime_mysql_query_rules;
select ' / ', count(*)
  from main.mysql_query_rules;
select ' / ', count(*)
  from disk.mysql_query_rules;

select '<tr><td>Connected Clients:', '<td>', variable_value
  from stats.stats_mysql_global
 where variable_name ='Client_Connections_connected';
select '<tr><td>Non idle connections:', '<td>', variable_value
  from stats.stats_mysql_global
 where variable_name ='Client_Connections_non_idle';
select '<tr><td>Active transactions:', '<td>', variable_value
  from stats.stats_mysql_global
 where variable_name ='Active_Transactions';
select '</table><p><hr>' ;
select '</table><p>' ;


select '<P><A NAME="status"></A>';
select '<P><table border="2"><tr><td><b>Servers Status</b></td></tr>';
select '<tr><td><b>Hostgroup</b>', '<td><b>Host</b>', '<td><b>Port</b>', '<td><b>Status</b>';
SELECT '<tr><td>',hostgroup_id, '<td>',hostname, '<td>',port, '<td>',status
  FROM runtime_mysql_servers
 ORDER BY hostgroup_id, status, hostname;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Replication/Galera/Cluster Status</b></td></tr>';
select '<tr><td><b>Type</b>', '<td><b>Hostgroup</b>', '<td><b>Role</b>', '<td><b>Host</b>', '<td><b>Status</b>';
SELECT '<tr><td>Galera<td>',hostgroup_id, '<td><b>Writer</b>', '<td>',hostname, '<td>',status, '<!-- 1 -->' for_sort
  FROM runtime_mysql_servers s, mysql_galera_hostgroups h
 WHERE s.hostgroup_id=h.writer_hostgroup
   AND status='ONLINE'
UNION
SELECT '<tr><td>Galera<td>',hostgroup_id, '<td>Disabled Writer', '<td>',hostname, '<td>',status, '<!-- 2 -->'
  FROM runtime_mysql_servers s, mysql_galera_hostgroups h
 WHERE s.hostgroup_id=h.writer_hostgroup
   AND status<>'ONLINE'
UNION
SELECT '<tr><td>Galera<td>',hostgroup_id, '<td><b>Reader</b>', '<td>',hostname, '<td>',status, '<!-- 3 -->'
  FROM runtime_mysql_servers s, mysql_galera_hostgroups h
 WHERE s.hostgroup_id=h.reader_hostgroup
UNION
SELECT '<tr><td>Galera<td>',hostgroup_id, '<td>Backup Writer', '<td>',hostname, '<td>',status, '<!-- 4 -->'
  FROM runtime_mysql_servers s, mysql_galera_hostgroups h
 WHERE s.hostgroup_id=h.backup_writer_hostgroup
UNION
SELECT '<tr><td>Galera<td>',hostgroup_id, '<td>Offline', '<td>',hostname, '<td>',status, '<!-- 5 -->'
  FROM runtime_mysql_servers s, mysql_galera_hostgroups h
 WHERE s.hostgroup_id=h.offline_hostgroup
 ORDER BY 8, hostgroup_id, status, hostname;

select '</table><p>' ;


select '<P><table border="2"><tr><td><b>Active Connections</b></td></tr>';
select '<tr><td><b>Thread</b>', '<td><b>User</b>', '<td><b>Database</b>',
       '<td><b>Hostgroup</b>', '<td><b>Host</b>', '<td><b>Command</b>', '<td><b>Time</b>', '<td><b>Info</b>';
SELECT '<tr><td>', ThreadID, '<td>',user, '<td>',db,
       '<td>',hostgroup, '<td>',srv_host, '<td>',command, '<td>',(time_ms/1000), '<td>',info
  FROM stats.stats_mysql_processlist
 order by time_ms desc;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Connections per User</b></td></tr>';
select '<tr><td><b>User</b>', '<td><b>Connections</b>', '<td><b>Max conn.</b>';
SELECT '<tr><td>',username, '<td>',frontend_connections, '<td>',frontend_max_connections
  FROM stats_mysql_users
 ORDER BY frontend_connections desc, username;
select '</table><p><hr>' ;

select '<P><A NAME="conf"></A>';
select '<P><table border="2"><tr><td><b>Configured Servers</b></td></tr>';
select '<tr><td><b> Hostgroup </b>', '<td><b>Host</b>', '<td><b>Port</b>',
       '<td><b>GTID Port</b>', '<td><b>Status</b>', '<td><b>Weight</b>', 
       '<td><b>Compression</b>', '<td><b>Max connn.</b>', '<td><b>Max LAG</b>',
       '<td><b>SSL</b>', '<td><b>Max lat.</b>';
SELECT '<tr><td>', hostgroup_id, '<td>',hostname, '<td>',port, '<td>',gtid_port, '<td>', status,
       '<td>', weight, '<td>', compression, '<td>',  max_connections, '<td>', max_replication_lag,
       '<td>', use_ssl, '<td>', max_latency_ms
  from main.mysql_servers
 order by hostname;
select '</table><p><br>' ;

select '<P><table border="2"><tr><td><b>Replication Configuration</b></td></tr>';
select '<tr><td><b> Writer Hostgroup </b>', '<td><b>Reader HG</b>',
       '<td><b>Check</b>';
SELECT '<tr><td>',writer_hostgroup, '<td>',reader_hostgroup,
       '<td>',check_type
  from main.mysql_replication_hostgroups;
select '</table><p>' ;
select '<P><table border="2">';
select '<tr><td><b>Replication Parameters</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', variable_value
  from main.global_variables
 where variable_name like '%monitor_replication%'
 order by variable_name;
select '</table><p><br>' ;

select '<P><table border="2"><tr><td><b>Galera Cluster Configuration</b></td></tr>';
select '<tr><td><b> Writer Hostgroup </b>', '<td><b>BackupWr HG</b>', '<td><b>Reader HG</b>',
       '<td><b>Offline HG</b>', '<td><b>Active</b>', '<td><b>Max Writers</b>', 
       '<td><b>Writer is reader</b>', '<td><b>Max TX behind</b>';
SELECT '<tr><td>',writer_hostgroup, '<td>',backup_writer_hostgroup, '<td>',reader_hostgroup,
       '<td>',offline_hostgroup, '<td>',active, '<td>',max_writers, '<td>',writer_is_also_reader,
       '<td>',max_transactions_behind
  from main.mysql_galera_hostgroups;
select '</table><p>' ;
select '<P><table border="2">';
select '<tr><td><b>Galera Parameters</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', variable_value
  from main.global_variables
 where variable_name like '%monitor_galera%'
 order by variable_name;
select '</table><p><br>' ;

select '<P><table border="2"><tr><td><b>Group Replication Configuration</b></td></tr>';
select '<tr><td><b> Writer Hostgroup </b>', '<td><b>BackupWr HG</b>', '<td><b>Reader HG</b>',
       '<td><b>Offline HG</b>', '<td><b>Active</b>', '<td><b>Max Writers</b>', 
       '<td><b>Writer is reader</b>', '<td><b>Max TX behind</b>';
SELECT '<tr><td>',writer_hostgroup, '<td>',backup_writer_hostgroup, '<td>',reader_hostgroup,
       '<td>',offline_hostgroup, '<td>',active, '<td>',max_writers, '<td>',writer_is_also_reader,
       '<td>',max_transactions_behind
  from main.mysql_group_replication_hostgroups;
select '</table><p>' ;
select '<P><table border="2">';
select '<tr><td><b>Group Replication Parameters</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', variable_value
  from main.global_variables
 where variable_name like '%monitor_groupreplication%'
 order by variable_name;
select '</table><p><br>' ;

select '<P><table border="2"><tr><td><b>Configured Users</b></td></tr>';
select '<tr><td><b> User </b>', '<td><b>Active</b>', '<td><b>SSL</b>',
       '<td><b>Hostgroup</b>', '<td><b>Schema</b>', '<td><b>Schema Lock</b>', 
       '<td><b>Tx pers.</b>', '<td><b>FastForward</b>',
       '<td><b>Frontend</b>', '<td><b>Backend</b>',
       '<td><b>Max conn.</b>', '<td><b>Attributes</b>';
SELECT '<tr><td>', username, '<td>', active, '<td>', use_ssl,
       '<td>', default_hostgroup, '<td>', default_schema, '<td>', schema_locked,
       '<td>', transaction_persistent, '<td>', fast_forward, 
       '<td>', frontend, '<td>', backend,
       '<td>',max_connections, '<td>', attributes
  FROM main.mysql_users
 ORDER BY username;
select '</table><p><br>' ;

select '<P><table border="2"><tr><td><b>Configured Rules </b></td></tr>';
select '<tr><td><b> Rule </b>', '<td><b>Active</b>', '<td><b>User</b>',
       '<td><b>Schema</b>', '<td><b>Digest</b>', '<td><b>TTL</b>', '<td><b>Apply</b>',
       '<td><b>Destination HG</b>', '<td><b>Match Digest</b>';
SELECT '<tr><td>',rule_id, '<td>',active, '<td>',username,
       '<td>',schemaname, '<td>',digest, '<td>',cache_ttl, '<td>',apply,
       '<td>',destination_hostgroup, '<td>',match_digest
  FROM main.mysql_query_rules
 ORDER BY rule_id;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Used Rules </b></td></tr>';
select '<tr><td><b> Rule </b>', '<td><b>Hits</b>';
SELECT '<tr><td>',rule_id, '<td>',hits
  FROM stats_mysql_query_rules
 WHERE hits>0
 ORDER BY rule_id;
select '</table><p><hr>' ;

select '<P><A NAME="stats"></A>';
select '<P><table border="2"><tr><td><b>ProxySQL Statistics</b></td></tr>';
select '<tr><td><b>Variable</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td align="right">', replace(variable_value,',',', ')
  from stats.stats_mysql_global
 where variable_name in ('Questions', 'Active_Transactions', 'ProxySQL_Uptime',
       'Client_Connections_aborted', 'Client_Connections_connected', 'Client_Connections_created', 
       'Client_Connections_non_idle', 'Questions', 'Queries_frontends_bytes_recv', 
       'Queries_frontends_bytes_sent', 'MySQL_Thread_Workers', 'Server_Connections_created', 
       'Server_Connections_connected', 'Server_Connections_delayed', 'Server_Connections_aborted',
       'Query_Cache_count_GET', 'Query_Cache_count_GET_OK'
       )
 order by variable_name;
select '</table><p>' ;


select '<P><table border="2"><tr><td><b>Connection Pool Statistics</b></td></tr>';
select '<tr><td><b>HG</b>', '<td><b>Host</b>', '<td><b>Port</b>', '<td><b>Status</b>', '<td><b>Conn. Used</b>', 
       '<td><b>Conn. Free</b>', '<td><b>Conn. OK</b>', '<td><b>Conn. Err.</b>', '<td><b>Max Conn.</b>',
       '<td><b>Queries</b>', '<td><b>Queries GTID sync</b>', '<td><b>Byte sent</b>', '<td><b>Bytes rec.</b>',
       '<td><b>Latency</b>';
select '<tr><td>', hostgroup, '<td>',srv_host, '<td>',srv_port, '<td>',status , '<td align="right">',ConnUsed,
       '<td align="right">',ConnFree, '<td align="right">',ConnOK, '<td align="right">',ConnERR, '<td align="right">',MaxConnUsed, 
       '<td align="right">',Queries, '<td align="right">',Queries_GTID_sync,
       '<td align="right">',Bytes_data_sent, '<td align="right">',Bytes_data_recv, 
       '<td align="right">',Latency_us
  from stats_mysql_connection_pool
 order by hostgroup, status, srv_host;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>ProxySQL Connections</b></td></tr>';
select '<tr><td><b>Connected Clients</b>', '<td><b>Non idle connections</b>', '<td><b>Active transactions</b>';
select '<tr><td align="right">', variable_value
  from stats.stats_mysql_global
 where variable_name ='Client_Connections_connected';
select '  <td align="right">', variable_value
  from stats.stats_mysql_global
 where variable_name ='Client_Connections_non_idle';
select '  <td align="right">', variable_value
  from stats.stats_mysql_global
 where variable_name ='Active_Transactions';
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Commands Statistics</b></td></tr>';
select '<tr><td><b>Command</b>', '<td><b>Count</b>', '<td><b>Total Time</b>';
select '<tr><td>',Command, '<td align="right">',Total_cnt, '<td align="right">',(Total_Time_us/1000000)
  from stats.stats_mysql_commands_counters
 where Total_cnt>0
   and Total_Time_us>=0
 order by Total_cnt DESC limit 20;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Duration Statistics</b></td></tr>';
select '<tr><td><b>Command</b>', '<td><b>Count</b>', '<td><b>Total time</b>', '<td><b>Avg time s</b>',
       '<td><b>cnt_1ms</b>', '<td><b>cnt_10ms</b>','<td><b>cnt_100ms</b>',
       '<td><b>cnt_1s</b>', '<td><b>cnt_10s</b>','<td><b>cnt_INFs</b>';
select '<tr><td>',Command, '<td align="right">',total_cnt, '<td align="right">',total_time_us/1000000,
       '<td align="right">',round(total_time_us/1000000.0/total_cnt,6),
       '<td align="right">',cnt_100us+cnt_500us+cnt_1ms, '<td align="right">',cnt_5ms+cnt_10ms,
       '<td align="right">',cnt_50ms+cnt_100ms, '<td align="right">',cnt_500ms+cnt_1s,
       '<td align="right">',cnt_5s+cnt_10s, '<td align="right">',cnt_INFs
  from stats.stats_mysql_commands_counters
 where Total_cnt>0
   and Total_Time_us>=0
 order by Total_cnt desc limit 30; 
select '</table><p>';

select '<P><table border="2"><tr><td colspan="4"><b>Query Statistics</b> (Heaviest)</td></tr>';
select '<tr><td><b>Hostgroup</b>', '<td><b>Schema</b>', '<td><b>Count</b>', '<td><b>Total Time</b>',
       '<td><b>Min Time</b>', '<td><b>Max Time</b>','<td><b>Digest</b>','<td><b>Query</b>';
select '<tr><td>',hostgroup, '<td>',schemaname, '<td align="right">',count_star, '<td align="right">',(sum_time/1000000),
       '<td align="right">', (min_time/1000000), '<td align="right">',(max_time/1000000), '<td>',digest, '<td>',substr(replace(replace(digest_text,'<','&lt;'),'>','&gt;'), 1,512)
  from stats.stats_mysql_query_digest
 order by sum_time desc limit 30;
select '</table><p>' ;

select '<P><table border="2"><tr><td colspan="4"><b>Query Statistics</b> (Most EXECed)</td></tr>';
select '<tr><td><b>Hostgroup</b>', '<td><b>Schema</b>', '<td><b>Count</b>', '<td><b>Total Time</b>',
       '<td><b>Min Time</b>', '<td><b>Max Time</b>','<td><b>Digest</b>','<td><b>Query</b>';
select '<tr><td>',hostgroup, '<td>',schemaname, '<td align="right">',count_star, '<td align="right">',(sum_time/1000000),
       '<td align="right">', (min_time/1000000), '<td align="right">',(max_time/1000000), '<td>',digest, '<td>',substr(replace(replace(digest_text,'<','&lt;'),'>','&gt;'), 1,512)
  from stats.stats_mysql_query_digest
 order by count_star desc limit 10;
select '</table><p>' ;

select '<P><table border="2"><tr><td colspan="4"><b>Query Statistics</b> (Slowest)</td></tr>';
select '<tr><td><b>Hostgroup</b>', '<td><b>Schema</b>', '<td><b>Count</b>', '<td><b>Total Time</b>',
       '<td><b>Min Time</b>', '<td><b>Max Time</b>','<td><b>Digest</b>','<td><b>Query</b>';
select '<tr><td>',hostgroup, '<td>',schemaname, '<td align="right">',count_star, '<td align="right">',(sum_time/1000000),
       '<td align="right">', (min_time/1000000), '<td align="right">',(max_time/1000000), '<td>',digest, '<td>',substr(replace(replace(digest_text,'<','&lt;'),'>','&gt;'), 1,512)
  from stats.stats_mysql_query_digest
 order by max_time desc limit 10;
select '</table><p><hr>' ;

select '<P><A NAME="det"></A>';
select '<P><A NAME="err"></A>';
select '<P><table border="2"><tr><td><b>Errors</b></td></tr>';
select '<tr><td><b>Hostgroup</b>', '<td><b>Host</b>', '<td><b>Port</b>',
       '<td><b>User</b>', '<td><b>Client</b>','<td><b>Schema</b>',
       '<td><b>ERRNO</b>', '<td><b>Count</b>','<td><b>Time First</b>',
       '<td><b>Time Last</b>', '<td><b>Error</b>';
select '<tr><td>',hostgroup, '<td>',hostname, '<td>',port, '<td>',username, 
       '<td>',client_address, '<td>',schemaname, '<td>',errno, '<td align="right">',count_star, 
       '<td>',from_unixtime(first_seen), '<td>',from_unixtime(last_seen), '<td>',last_error 
  from stats_mysql_errors
 order by last_seen desc
 limit 50;
select '</table><p>' ;

select '<P><A NAME="log"></A>';
select '<P><table border="2"><tr><td><b>Host PING LOG</b></td></tr>';
select '<tr><td><b>Host</b>', '<td><b>Time</b>', '<td><b>Error</b>';
select '<tr><td>',hostname, '<td>',from_unixtime(time_start_us/1000000), '<td>',ping_error
  from monitor.mysql_server_ping_log
 order by time_start_us desc
 limit 10;
select '<tr><td>...';
select '<tr><td>',hostname, '<td>',from_unixtime(time_start_us/1000000), '<td>',ping_error
  from monitor.mysql_server_ping_log
 where ping_error <> 'NULL'
 order by time_start_us desc
 limit 10; 
select '</table><p>' ;
select '<P><table border="2"><tr><td><b>Connect LOG</b></td></tr>';
select '<tr><td><b>Host</b>', '<td><b>Port</b>', '<td><b>Time</b>', '<td><b>Connect Time</b>', '<td><b>Error</b>';
select '<tr><td>',hostname, '<td>',port, '<td>',from_unixtime(time_start_us/1000000),
       '<td>',from_unixtime(connect_success_time_us/1000000), '<td>', connect_error
  from monitor.mysql_server_connect_log
 order by time_start_us desc
 limit 10;
select '<tr><td>...';
select '<tr><td>',hostname, '<td>',port, '<td>',from_unixtime(time_start_us/1000000),
       '<td>',from_unixtime(connect_success_time_us/1000000), '<td>', connect_error
  from monitor.mysql_server_connect_log
 where connect_error <> 'NULL'
 order by time_start_us desc
 limit 10; 
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Galera Cluster LOG</b></td></tr>';
select '<tr><td><b>Host</b>', '<td><b>Port</b>', '<td><b>Time</b>', '<td><b>Success Time</b>',
       '<td><b>Primary</b>', '<td><b>Read Only</b>',
       '<td><b>Recv Queue</b>', '<td><b>State</b>', '<td><b>Desync</b>', '<td><b>Reject Queries</b>',
       '<td><b>SST Donor Rejects</b>', '<td><b>PXC Maint Mode</b>', '<td><b>Error</b>';
select '<tr><td>',hostname, '<td>',port, '<td>',from_unixtime(time_start_us), '<td>',from_unixtime(success_time_us),
       '<td>',primary_partition, '<td>',read_only,
       '<td>',wsrep_local_recv_queue, '<td>',wsrep_local_state, '<td>',wsrep_desync, '<td>',wsrep_reject_queries,
       '<td>',wsrep_sst_donor_rejects_queries, '<td>',pxc_maint_mode, '<td>',error
  from mysql_server_galera_log
order by time_start_us desc limit 30;
select '</table><p>' ;

select '<P><table border="2"><tr><td><b>Client Host Cache</b></td></tr>';
select '<tr><td><b>Client</b>', '<td><b>#Errors</b>', '<td><b>Time</b>';
select '<tr><td>', client_address, '<td>', error_count, '<td>',from_unixtime(last_updated/1000000)
  from stats.stats_mysql_client_host_cache
 order by last_updated desc
 limit 20; 
select '</table><p><hr>' ;

select '<P><A NAME="par"></A>' ;
select '<P><table border="2"><tr><td><b>ProxySQL Parameters</b></td></tr>';
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', replace(variable_value,',',', ')
  from main.global_variables
 where variable_name not in ('Exclusion_list')
 order by variable_name;
select '</table><p>' ;

select '<P><A NAME="var"></A>' ;
select '<P><table border="2"><tr><td><b>ProxySQL Variables</b></td></tr>';
select '<tr><td><b>Variable</b>',
 '<td><b>Value</b>' ;
select '<tr><td>', variable_name, '<td>', replace(variable_value,',',', ')
  from stats.stats_mysql_global
 where variable_name not in ('Exclusion_list')
 order by variable_name;
select '</table><p><hr>' ;

select '<P><A NAME="ver"></A>';
select '<P><table border="2"><tr><td><b>Version check</b></td></tr>' ;
select '<tr><td><b>Version</b>', '<td><b> Notes</b>';
select '<tr><td>', variable_value
  from main.global_variables
 where variable_name='admin-version';
select '<td>Latest Releases: 3.0.1, 2.7.3, 2.6.6; 2.5.5, 2.4.8, 2.3.2, 2.2.2, 2.1.1, 2.0.18; 1.4.16'; 
select '</table><p><hr>' ;


select '<hr><p>Statistics generated at: ', current_timestamp;
select '<p>For more info on ProxySQL2html contact' ;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo Bogliolo</A>.<p>' ;
select '</body></html>' ;

-- select * from monitor.mysql_server_replication_lag_log;
-- select * from monitor.mysql_server_read_only_log;

-- select from_unixtime(timestamp) as timestamp, Client_Connections_aborted, Client_Connections_connected,
--        Client_Connections_created, Server_Connections_aborted, Server_Connections_connected,
--       Server_Connections_created, Questions, Slow_queries
--  from stats_history.mysql_connections
-- order by timestamp desc limit 30;

-- select hostname, port, from_unixtime(time_start_us), from_unixtime(success_time_us), primary_partition, read_only,
--        wsrep_local_recv_queue, wsrep_local_state, wsrep_desync, wsrep_reject_queries,
--        wsrep_sst_donor_rejects_queries, pxc_maint_mode, error
--  from mysql_server_galera_log
-- order by time_start_us desc limit 30;

-- select rule_id, hits from stats_mysql_query_rules;
-- select * from stats_proxysql_servers_metrics;
