# Program:	my2html.sh
# 		MySQL DBA Database report in HTML
#
# Version:      1.0.19
# Author:       Bartolomeo Bogliolo mail@meo.bogliolo.name
# Date:         1-JAN-2015
# License:      GPL
#
# Note:
# Init:       1-APR-2006 meo@bogliolo.name
#               Initial version
# 1.0.9:      1-JAN-2015
#               5.7 new features and changes. Based on my2html 1.0.8
# 1.0.10:     1-JAN-2016
#               extra statistics file addendum based on SYS database
# 1.0.11:     1-JUN-2016
#               NLS, avoid temporary table creation PLANNED: gotop
# 1.0.12:     14-FEB-2017
#               Per Host threads summary
# 1.0.13:     14-FEB-2018
#               Users virtual "roles", (b) version check, (c) grant matrix, (d) 2018-07-27 last versions update
# 1.0.14:     31-OCT-2018
#               Lastest versions update
# 1.0.15:     14-FEB-2019
#               Lastest versions update
# 1.0.16:     22-JUL-2019
#               Lastest versions update
# 1.0.17:     01-JAN-2020
#               Lastest versions update, SQL scripts for different MySQL/MariaDB versions, (a) little bugs in users
# 1.0.18:     15-AUG-2020
#               Lastest versions update
# 1.0.19:     31-OCT-2023
#               MySQL 5.7 is desupported, now defaults to 8.0

USR=root
# Careful with security, Eugene!!
PSS=
HST=127.0.0.1
HSTN=`hostname`
PRT=3306

# Use my2html.80.sql  XOR  my2html.57.sql  XOR  my2html.10.sql script (XOR any older unsupported release: 5.6, 5.5, 5.1, 5.0, 3.23)
mysql --user=$USR --password=$PSS --host=$HST --port=$PRT \
   --force --skip-column-names > $HSTN.$PRT.htm < my2html.80.sql 2>/dev/null

#  Uncomment for internal MySQL and Innodb statistics
# mysql --user=$USR --password=$PSS --host=$HST --port=$PRT \
#   --force -t > $HSTN.$PRT.int.htm < my2html.int.sql 2>/dev/null

#  Uncomment for ProxySQL statistics
# USR=admin
# PSS=
# PRT=6032
# mysql --user=$USR --password=$PSS --host=$HST --port=$PRT \
#    --force --skip-column-names > $HSTN.$PRT.ProxySQL.htm < proxysql2html.sql 2>/dev/null

