# CH2coll4disk
# by mail@meo.bogliolo.name
# 0.0.1  2019-04-01 First version
#
# cron: 5 0 * * * /home/ch/ch2coll4disk.sh

clickhouse-client -mn --user=batch <<EOF
-- Collect data
insert into my2.status
select now() timestamp, concat('SIZEDB.', database), sum(bytes_on_disk)
  FROM system.parts
 GROUP BY database
 ORDER BY database;
EOF



