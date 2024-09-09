# Program:	ch2html.sh
# 		ClickHouse DBA Database report in HTML
#
# Version:      1.0.4a
# Author:       Bartolomeo Bogliolo mail@meo.bogliolo.name
# Date:         1-APR-2019
# License:      Apache 2.0
#
# Note:
# Init:       1-APR-2019 meo@bogliolo.name
#               Initial version based on MySQL my2html
# 1.0.1       1-MAY-2019 meo@bogliolo.name
#               Small bugs fixing
# 1.0.2       1-AUG-2019 meo@bogliolo.name
#               Small bugs fixing, config files
# 1.0.3       1-JAN-2020 meo@bogliolo.name
#               Last updates, detailed info
# 1.0.4       5-AUG-2020 meo@bogliolo.name
#               Longer logs, (a) Detached parts

USR=default
# Careful with security, Eugene!!
PSS=
HST=127.0.0.1
HSTN=`hostname`
PRT=8123
DATADIR=/var/lib/clickhouse/

clickhouse-client --user=$USR --password=$PSS -mn --ignore-error > $HSTN.$PRT.htm <ch2html.sql 2>/dev/null
# docker run --rm --link mych:clickhouse-server yandex/clickhouse-client -mn --ignore-error --host clickhouse-server > $HSTN.$PRT.htm <ch2html.sql 2>/dev/null
# /Users/meo/ch_build/ClickHouse/build/dbms/programs/clickhouse-client -mn --ignore-error > $HSTN.$PRT.htm <ch2html.sql 2>/dev/null

{
echo '<P><A NAME="os"></A>' 
echo '<hr><h3>Operating system info</h3><pre>' 
echo '<b>Process Status</b>'
ps -efa | grep click | grep -v grep 
echo 
echo '<b>Packages</b>'
rpm -qa | grep clickhouse  2>/dev/null
dpkg-query -W | grep clickhouse  2>/dev/null
echo 
echo '<b>Configuration Files</b>' 
ls -l /etc/clickhouse-server/ 
echo 
echo '<b>CPU Extensions</b>' [SSE 4.2]
grep -q sse4_2 /proc/cpuinfo && echo "SSE 4.2 supported" || echo "SSE 4.2 *not* supported"
echo
echo '<b>CPU Governor</b>' [Performance]
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | sort -u
echo
echo '<b>Memory Overcommit</b> [0 or 1]'
cat /proc/sys/vm/overcommit_memory 
echo
echo '<b>Memory Hugepages</b> [never]'
cat /sys/kernel/mm/transparent_hugepage/enabled 
echo
echo '<b>Disk Scheduler</b> [HDD:CFQ, SSD:noop]' 
ls /sys/block/*/queue/scheduler 
cat /sys/block/*/queue/scheduler 
# cat /sys/block/*/*/stripe_cache_size 
echo
echo '<b>File System Mounts</b> [ext4 with noatime,nobarrier]' 
cat /proc/mounts 
echo
df -h
echo

echo '</pre><P><A NAME="conf"></A>' 
echo '<hr><h3>ClickHouse Configuration Files</h3>' 
echo '<b>config.xml</b><xmp>'
cat /etc/clickhouse-server/config.xml
echo '</xmp><b>users.xml</b><xmp>'
cat /etc/clickhouse-server/users.xml | grep -v password
echo '</xmp>'

echo '<P><A NAME="logs"></A>' 
echo '<hr><h3>ClickHouse  Logs</h3><xmp>' 
echo '*** ClickHouse Server Log ***'
tail -100 /var/log/clickhouse-server/clickhouse-server.log
echo
echo '*** Last errors in ClickHouse Server Log ***'
grep "<Error>" /var/log/clickhouse-server/clickhouse-server.log | tail -10
echo
echo '*** ClickHouse Error Log ***'
tail -100 /var/log/clickhouse-server/clickhouse-server.err.log
echo
echo '</xmp>' 

echo '<P><A NAME="detached"></A>' 
echo '<hr><h3>Detached Parts</h3><pre>' 
echo 
find $DATADIR -name detached -not -empty -type d -exec du -sh {} \; -exec ls -l {} \; -exec echo \; | grep -v total
echo
echo '</pre>' 

#echo '<P><A NAME="bench"></A>' 
#echo '<hr><h3>Benchmark</h3><pre>'
#echo Single thread GB
#awk "BEGIN{print 8/ `clickhouse-client --user=$USR --password=$PSS -mn --ignore-error \
#  "SELECT count(*) FROM numbers(1000000000)" | grep -v 1000000000` }"
#echo
#echo Multithread GB
#awk "BEGIN{print 8/ `clickhouse-client --user=$USR --password=$PSS -mn --ignore-error \
#  "SELECT count(*) FROM numbers_mt(1000000000)" | grep -v 1000000000` }"
#echo '</pre>' 

echo '<hr><P>Statistics generated on: ' 
date  
echo '<p>More info on ' 
echo '<A HREF="http://meoshome.it.eu.org#clickhouse">this site</A>' 

echo '<br> Copyright: 2024 meob - License: GNU General Public License v3.0 <p></body></html>'
echo '<br> Sources: https://github.com/meob/db2html/ <p></body></html>'
} >> $HSTN.$PRT.htm
exit 0

