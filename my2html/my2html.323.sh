# Program:	my2html.3_23.sh
# 		MySQL (3.x) Database report in HTML
#
# Version:      1.0.0
# Author:       Bartolomeo Bogliolo meo@bogliolo.name
# Date:         1-MAY-2008
# License:      GPL
#
# Note:
# Init:         1-APR-2010 meo@bogliolo.name
#               Initial version (from my2html.sh v.1.0.6i)

USR=root
# Careful with security, Eugene!!
PSS=
# HST=`hostname`
# PRT=3306
HST=localhost

echo '<html> <head> <title>' $HST : $PRT \
     ' - my2html MySQL Statistics</title></head><body>' > $HST.$PRT.htm

mysql --user=$USR --password=$PSS --host=$HST --port=$PRT \
      --force --skip-column-names >> $HST.$PRT.htm <<EOF

use mysql;

select '<h1>MySQL Database</h1>';

select '<P><A NAME="top"></A>' ;
select '<p>Table of contents:' ;
select '<table><tr><td><ul>' ;
select '<li><A HREF="#status">Summary Status</A></li>' ;
select '<li><A HREF="#ver">Versions</A></li>' ;
select '<li><A HREF="#dbs">Databases</A></li>' ;
select '<li><A HREF="#usr">Users</A></li>' ;
select '</ul><td><ul>' ;
select '<li><A HREF="#prc">Processes</A></li>' ;
select '<li><A HREF="#lock">Open Tables / Locks</A></li>' ;
select '<li><A HREF="#repl">Replication</A></li>' ;
select '<li><A HREF="#par">Configuration Parameters</A></li>' ;
select '<li><A HREF="#gstat">Global Status</A></li>' ;
select '</ul></table><p><hr>' ;
 
select '<P>Statistics generated on: ', now();
select ' by: ', user();
 
select 'using: <I><b>my2html.3_23.sh</b> v.1.0.0';
select '<br>Software by ';
select '<A HREF="http://meoshome.it.eu.org/#dwn">Meo</A></I><p><HR>';


select '<P><A NAME="status"></A>';
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>';
select '<tr><td><b>Item</b>', '<td><b>Value</b>';

select '<tr><td>Version :', '<td>', left(version(), locate('-',version())-1);
select '<tr><td>Defined Users :',
 '<td align="right">', format(count(*),0)
from mysql.user;

select '</table><p><hr>' ;

select '<P><A NAME="ver"></A>';
select '<P><table border="2"><tr><td><b>Versions</b></td></tr>' ;
select '<tr><td>', version();
select '</table><p><hr>' ;
 
select '<P><A NAME="dbs"></A>' ;
select '<P><table border="2" width="75%"><tr><td><b>Databases</b></td></tr>';
select '<tr><td>';
select '<pre>' ;
show databases;
select '</pre></table><p><hr>' ;

select '<P><A NAME="usr"></A>';
select '<P><table border="2"><tr><td><b>Users</b></td></tr>' ;
select '<tr><td><b>Host</b>',
 '<td><b>DB</b>',
 '<td><b>User</b>',
 '<td><b>Password</b>',
 '<td><b>Select</b>',
 '<td><b>Grant</b>'
;
SELECT '<tr><td>',host, 
	'<td>', 
	'<td>', user, 
	'<td>', if(password<>'','','NO PWD'),
	'<td>', select_priv, 
	'<td>', grant_priv
FROM mysql.user d;
select '<tr>';
select '<tr><td><b>DB Access</b></td></tr>' ;
SELECT '<tr><td>',host, 
	'<td>', db, 
	'<td>', user, 
	'<td>', 
	'<td>', select_priv, 
	'<td>', grant_priv
FROM mysql.db d;
select '<tr>';
select '<tr><td><b>Host Access</b></td></tr>' ;
SELECT '<tr><td>',host, 
	'<td>', db, 
	'<td>', 
	'<td>', 
	'<td>', select_priv, 
	'<td>', grant_priv
FROM mysql.host d;
select '</table><p><hr>' ;

select '<P><A NAME="prc"></A>' ;
select '<P><table border="2" width="100%"><tr><td><b>Processes</b></td></tr>' ;
select '<tr><td><b><pre><b>' ;
select '( id      user   host        db     command   time   state   info )' ;
select '</b>' ;
show processlist;
select '</pre>' ;
select '</table><p><hr>' ;

select '<P><A NAME="lock"></A>' ;
select '<P><table border="2" width="75%"><tr><td><b>Open Tables / Locks</b></td></tr>' ;
select '<tr><td><pre><b>Open Tables / Locks</b>' ;
show open tables;
select '</pre></table><p><hr>' ;

select '<P><A NAME="repl"></A>' ;
select '<P><table border="2"><tr><td><b>Replication</b></td></tr>' ;
select '<tr><td><pre><b>Master</b>' ;
show master status;
select '</pre><tr><td><pre><b>Slave</b>' ;
show slave status\G
select '</pre></table><p><hr>' ;

select '<P><A NAME="par"></A>' ;
select '<P><table border="2" width="75%"><tr><td><b>MySQL Configuration</b></td></tr>';
select '<tr><td>';
select '<pre>' ;
show variables;
select '</pre></table><p><hr>' ;

select '<P><A NAME="gstat"></A>' ;
select '<P><table border="2" width="75%"><tr><td><b>MySQL Global Status</b></td></tr>';
select '<tr><td>';
select '<pre>' ;
show status;
select '</pre></table><p><hr>' ;

select '<hr><P>Statistics generated on: ', now();
select '<p>For more info on my2html contact' ;
select '<A HREF="mailto:meo@bogliolo.name">Meo</A>.<p></body></html>' ;

EOF
