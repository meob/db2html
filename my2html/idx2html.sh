# Program:	idx2html.sh
# 		Indexes report in HTML
#
# Version:      1.0.0
# Author:       Bartolomeo Bogliolo mail@meo.bogliolo.name
# Date:         1-APR-2015
# License:      GPL
#
# Note:
# Init:         1-APR-2015 meo@bogliolo.name
#               Initial version

USR=root
# Careful with security, Eugene!!
PSS=
HST=127.0.0.1
HSTN=`hostname`
PRT=3306

echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8" /><link rel="stylesheet" href="ux3.css" /> <title>' $HSTN : $PRT \
   ' - idx2html MySQL Indexes Statistics</title></head><body>' > $HSTN.$PRT.idx.htm

mysql --user=$USR --password=$PSS --host=$HST --port=$PRT \
   --force --skip-column-names >> $HSTN.$PRT.idx.htm <<EOF

use information_schema;

select '<h1>MySQL Database Indexes</h1>';
select '<P><A NAME="top"></A>' ;
select '<P>Statistics generated on: ', now();
select ' by: ', user(), 'as: ',current_user();
select 'using: <i><b>idx2html.sh</b> v.1.0.0</i>';
select '<p><HR><p>';


select '<P><A NAME="idx"></A>' ;
select '<P><table border="2"><tr><td><b>Schema</b>';
select '<td><b>Table</b>',
 '<td><b>Index</b>',
 '<td><b>Columns</b>',
 '<td><b>Unique</b>',
 '<td><b>Type</b>';

SELECT '<tr><td>', table_schema,
       '<td>', table_name,
       '<td>', index_name,
       '<td>', GROUP_CONCAT(column_name ORDER BY seq_in_index SEPARATOR ', '),
       '<td>', GROUP_CONCAT(distinct if(non_unique=0,'UNIQUE','')),
       '<td>', GROUP_CONCAT(distinct index_type)
  FROM information_schema.statistics
 WHERE table_schema not in ('mysql','my2', 'excluded_database')
 GROUP BY 2,4,6
 ORDER BY 2,4,6;

select '</table><p>' ;


select '<hr><P>Statistics generated on: ', now();
select '<p>For more info on my2html contact' ;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo Bogliolo</A>.<p></body></html>' ;

EOF
