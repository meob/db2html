# CH2coll
# by mail@meo.bogliolo.name
# 0.0.1  2019-04-01 First statistics collector
# 0.0.2  2021-04-01 Fixed duplicated metrics
#
# cron: */10 * * * * /home/ch/ch2coll.sh

clickhouse-client -mn --user=batch <<EOF
-- Create Database, Tables for My2 dashboard
create database IF NOT EXISTS my2;
use my2;
CREATE TABLE IF NOT EXISTS my2.status (timestamp DateTime,  metric String,  value Int64)
 ENGINE = MergeTree
 PARTITION BY toYYYYMM(timestamp)
 ORDER BY (timestamp, metric)
 SETTINGS index_granularity = 8192;

-- Collect data
insert into my2.status
select now() timestamp,
      if(metric='Query', 'CurrentQueries', if(metric='Merge', 'CurrentMerges', metric) ) as metric,
      value
  from system.metrics
 where metric not like 'MemoryTrackingIn%'
union all
select now(), metric, cast(value, 'Int64')
  from system.asynchronous_metrics
union all
select now(), event, cast(value, 'Int64')
  from system.events;
EOF




