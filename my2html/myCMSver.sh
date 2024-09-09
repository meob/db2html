# Program:	myCMSver.sh
# 		Get CMS versions from the DB		
#		All recent CMS have a "Database Schema Version" that can be used to recognize the version
#
# Version:      1.0.11
# Author:       Bartolomeo Bogliolo meo@bogliolo.name
# Date:         2014-02-14
# License:      GPL
# Note:		myCMSver needs a MySQL 5.0 version or better and uses, as default, the test database
#
# Initial:      2014-02-14 mail@meo.bogliolo.name
#               First version based on the following sources and SQL hacking:
# 		Joomla!         http://docs.joomla.org/Joomla!_CMS_versions   /libraries/Joomla/version.php
# 		Drupal          https://www.drupal.org/project/Drupal         /modules/system/system.module
# 		WordPress       https://codex.wordpress.org/WordPress_Versions   wp-incudes/version.php   
# 		Moodle          http://docs.moodle.org/dev/Releases
#
# 1.0.1:	2014-10-01
#		New versions (eg. WP 4.0), Drupal versions, MySQL Old password detection (pre 4.1)
# 1.0.2:	2015-11-01
#		CMS versions upgrade, Supported versions hint
# 1.0.3:	2016-06-01
#		CMS versions upgrade
# 1.0.4:	17-10-17
#		CMS versions upgrade
# 1.0.5:	2018-01-01
#		CMS versions upgrade
# 1.0.6:	2018-09-01
#		CMS versions upgrade
# 1.0.7:	2019-02-14
#		CMS versions upgrade
# 1.0.8:	2019-07-14
#		CMS versions upgrade
# 1.0.8:	2020-01-01
#		CMS versions upgrade
# 1.0.9:	2021-08-15
#		CMS versions upgrade
# 1.0.10:	2022-08-15
#		CMS versions upgrade
# 1.0.11:	2023-04-01
#		CMS versions upgrade
# 1.0.12:	2023-08-15
#		CMS versions upgrade

USR=root
PSS=
HST=127.0.0.1
HSTN=`localhost`
PRT=3306
TMP_DB=test

mysql --user=$USR --password=$PSS --host=$HST --port=$PRT --force --skip-column-names > CMS.$HSTN.$PRT.htm <<EOF

use information_schema;
select '<html><head><title>myCMSver</title></head><body>';
select '<h1>CMS hosting</h1>';

select '<p><A NAME="top"></A>' ;
select '<p>Table of contents:' ;
select '<li><A HREF="#status">Database Summary</A></li>' ;
select '<p><li>CMS:<ul><li><A HREF="#joo">Joomla!</A></li>' ;
select '<li><A HREF="#moo">Moodle</A></li>' ;
select '<li><A HREF="#wp">WordPress</A></li>' ;
select '<li><A HREF="#dru">Drupal</A></li>' ;
select '</ul><li><A HREF="#sectab">Security info</A></li>' ;
select '<p><hr>' ;
 
select '<p>Statistics generated on: ', now();
select ' by: ', user(), 'as: ',current_user();
select 'using: <I><b>myCMSver.sh</b> v.1.0.11</I><p><HR>';
select '<br>CMS production/support info update: 1st April 2023';
select '<p>For more information on CMS releases see' ;
select '<A HREF="http://meoshome.it.eu.org/unix/trans.htm#cms">this document</A>.' ;

select '<P><A NAME="status"></A>';
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>';
select '<tr><td><b>Item</b>', '<td><b>Value</b>';

select '<tr><td>Version :', '<td>', version()
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
	'<td><p align=right>', format(count(*),0)
from tables;

select '<tr><td>Started :', '<td>', date_format(date_sub(now(), INTERVAL variable_value second),'%Y-%m-%d %T')
from global_status
where variable_name='UPTIME'
union
select '<tr><td>Buffer Size (MB):',
	'<td><p align=right>',
	format(sum(variable_value+0)/(1024*1024),0)
from global_variables
where lower(variable_name) like '%buffer_size' or lower(variable_name) like '%buffer_pool_size'
union
select '<tr><td>Logging Bin. :', '<td>', variable_value
from global_status
where variable_name='LOG_BIN'
union
select '<tr><td>Sessions :',
 '<td align="right">', format(count(*),0)
from processlist
union
select '<tr><td>Sessions (active) :',
 '<td align="right">', format(count(*),0)
from processlist
where command <> 'Sleep'
union
select '<tr><td>Hostname :', '<td>', variable_value
from information_schema.global_variables
where variable_name ='hostname'
union
select '<tr><td>Port :', '<td>', variable_value
from information_schema.global_variables
where variable_name ='port';

select '</table><p><hr>';


select '<P><A NAME="joo"></A>';
select '<P><table border="2"><tr><td><b>Joomla</b>' ;
select '<tr><td>Production (last)<br>Supported (first)<td>4.3.4<br>3.10.11' ;

select '<tr><td><b>Schema</b><td><b>Version</b>' ;
use $TMP_DB;
drop procedure if exists jml_versions;
DELIMITER '//';
CREATE PROCEDURE jml_versions()
BEGIN
  DECLARE ts, tn char(64);
  DECLARE done boolean;
  DECLARE cur1 CURSOR FOR select TABLE_SCHEMA, TABLE_NAME from information_schema.tables where table_name like '%schemas' order by TABLE_SCHEMA;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur1;
  read_loop: LOOP
    FETCH cur1 INTO ts, tn;
    IF done THEN
      LEAVE read_loop;
    END IF;
    set @sql1=concat('select "<tr><td>", \'', ts, '\', "<td>", version_id  from ', ts, '.', tn,' where extension_id=700');
    prepare stmt from @sql1;
    execute stmt;
 END LOOP;
  CLOSE cur1;
END;
//
DELIMITER ';'//
call jml_versions();

use information_schema;
select distinct "<tr><td>", TABLE_SCHEMA, "<td>1.5 or less"
 from information_schema.tables
 where table_schema like 'jml%' and table_name like '%users'
 and table_schema not in
  (select TABLE_SCHEMA from information_schema.tables where table_name like '%schemas')
order by TABLE_SCHEMA;
select '</table><p><hr>';


select '<P><A NAME="moo"></A>';
select '<P><table border="2"><tr><td><b>Moodle</b>' ;
select '<tr><td>Production (last)<br>Supported (first)<td>4.2.1<br>3.9.22' ;

select '<tr><td><b>Schema</b><td><b>Version</b>' ;
use $TMP_DB;
drop procedure if exists mdl_versions;
DELIMITER '//';
CREATE PROCEDURE mdl_versions()
BEGIN
  DECLARE ts, tn char(64);
  DECLARE done boolean;
  DECLARE cur1 CURSOR FOR select TABLE_SCHEMA, TABLE_NAME from information_schema.tables where table_name ='mdl_config' order by TABLE_SCHEMA;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur1;
  read_loop: LOOP
    FETCH cur1 INTO ts, tn;
    IF done THEN
      LEAVE read_loop;
    END IF;
    set @sql1=concat('select "<tr><td>", \'', ts, '\', "<td>", value  from ', ts, '.', tn,' where name=\'release\'');
    prepare stmt from @sql1;
    execute stmt;
 END LOOP;
  CLOSE cur1;
END;
//
DELIMITER ';'//
call mdl_versions();
use information_schema;
select '</table><p><hr>';


select '<P><A NAME="wp"></A>';
select '<P><table border="2"><tr><td><b>WordPress</b>' ;
select '<tr><td>Production (last)<br>Supported (first)<td>6.3<br>4.1.37' ;

select '<tr><td><b>Schema</b><td><b>Option Table</b><td><b> Version </b><td><b>DB Version</b>' ;
use $TMP_DB;
drop procedure if exists wp_versions;
drop table if exists wp_conv;
create table wp_conv(id int, ver char(6));

insert into wp_conv(id,ver) values(55853 ,'6.3');
insert into wp_conv(id,ver) values(53496 ,'6.0.1+,6.1,6.2');
insert into wp_conv(id,ver) values(51917 ,'5.9,6.0');
insert into wp_conv(id,ver) values(49752 ,'5.6,5.7,5.8');
insert into wp_conv(id,ver) values(48748 ,'5.5+, 5.4.3+,5.3.5+,5.2.8+,5.1.7+,5.0.11+,4.9.16+, ...');
insert into wp_conv(id,ver) values(47018 ,'5.4');
insert into wp_conv(id,ver) values(45805 ,'5.3');
insert into wp_conv(id,ver) values(44719 ,'5.1');
insert into wp_conv(id,ver) values(43764 ,'5.0');
insert into wp_conv(id,ver) values(38590 ,'4.7+');
insert into wp_conv(id,ver) values(37965,'4.6');
insert into wp_conv(id,ver) values(36686,'4.5');
insert into wp_conv(id,ver) values(35700,'4.4');
insert into wp_conv(id,ver) values(33055,'4.3'),(33056,'4.3.1+');
insert into wp_conv(id,ver) values(31536,'4.2.3+'),(31535,'4.2.2'),(31533,'4.2.1'),(31532,'4.2');
insert into wp_conv(id,ver) values(30135,'4.1.5+'),(30134,'4.1.4'),(30133,'4.1');
insert into wp_conv(id,ver) values(29632,'4.0.5+'),(29631,'4.0.4'),(29630,'4.0'),(27918,'3.9.6+'),(27916,'3.9');
insert into wp_conv(id,ver) values(26691,'3.8.8+'),(26692,'3.8.3+'),(26691,'3.8');
insert into wp_conv(id,ver) values(26151,'3.7.8+'),(26149,'3.7.3+'),(26148,'3.7.2'),(25824,'3.7');
insert into wp_conv(id,ver) values(24448,'3.6'),(22442,'3.5.2'),(22441,'3.5'),(21707,'3.4.2'),(21115,'3.4.1'),(20596,'3.4');
insert into wp_conv(id,ver) values(19470,'3.3'),(18226,'3.2.x'),(17516,'3.1.x'),(15477,'3.0.x'),(15477,'3.0');
insert into wp_conv(id,ver) values(12329,'2.9.x'),(11548,'2.8.x'),(9872,'2.7.x');
insert into wp_conv(id,ver) values(8204,'2.6.x'),(8201,'2.6'),(7796,'2.5.1'),(7558,'2.5');
insert into wp_conv(id,ver) values(6124,'2.3.x'),(5183,'2.2.x'),(4773,'2.1.x'),(4772,'2.1');
insert into wp_conv(id,ver) values(3441,'2.0.x'),(2541,'1.5.x'),(2540,'1.2.2');
DELIMITER '//';
CREATE PROCEDURE wp_versions()
BEGIN
  DECLARE ts, tn char(64);
  DECLARE done boolean;
  DECLARE wp boolean;
  DECLARE cur1 CURSOR FOR select distinct TABLE_SCHEMA, TABLE_NAME from information_schema.tables where table_name like '%_options' order by TABLE_SCHEMA;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  DECLARE CONTINUE HANDLER FOR 1054 SET wp = FALSE;
  OPEN cur1;
  read_loop: LOOP
    set wp = TRUE;
    FETCH cur1 INTO ts, tn;
    IF done THEN
      LEAVE read_loop;
    END IF;
    set @sql1=concat('select distinct "<tr><td>", \'', ts, '\', "<td>", \'', tn, '\', "<td>",ver, "<td>", option_value from ', ts, '.', tn,',$TMP_DB.wp_conv where option_name=\'db_version\' and option_value=id');
    prepare stmt from @sql1;
    IF wp THEN
       execute stmt;
    END IF;
 END LOOP;
  CLOSE cur1;
END;
//
DELIMITER ';'//
call wp_versions();

use information_schema;
select '</table><p><hr>';

select '<P><A NAME="dru"></A>';
select '<P><table border="2"><tr><td><b>Drupal</b>' ;
select '<tr><td>Production (last)<br>Supported (first)<td>10.1.2<br>7.98' ;

select '<tr><td><b>Schema</b><td><b>Version</b>' ;
use $TMP_DB;
drop procedure if exists dru_versions;
DELIMITER '//';
CREATE PROCEDURE dru_versions()
BEGIN
  DECLARE ts, tn char(64);
  DECLARE done boolean;
  DECLARE cur1 CURSOR FOR select TABLE_SCHEMA, TABLE_NAME from information_schema.tables where table_name ='system' order by TABLE_SCHEMA;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur1;
  read_loop: LOOP
    FETCH cur1 INTO ts, tn;
    IF done THEN
      LEAVE read_loop;
    END IF;
    set @sql1=concat('select "<tr><td>", \'', ts, '\', "<td>", replace(replace(substr(substr(info,1,1000),locate(\'version\',substr(info,1,1000))+13,6),\';\',\' \'), \'"\',\' \') value from ', ts, '.', tn,' where name=\'node\' and type=\'module\'');
    prepare stmt from @sql1;
    execute stmt;
 END LOOP;
  CLOSE cur1;
END;
//
DELIMITER ';'//
call dru_versions();
use information_schema;
select '</table><p><hr>';

select '<P><a id="sectab"></A>' ;
select '<P><table border="2"><tr><td><b>Spammable tables</b><td>' ;
select '<tr><td><b>Database</b>',
 '<td><b>Object</b>',
 '<td><b>Type</b>',
 '<td><b>Rows</b>',
 '<td><b>MBytes</b>' ;
select '<tr><td>', table_schema,
        '<td>', table_name,
        '<td>T',
        '<td><p align=right>', format(table_rows,0),
        '<td><p align=right>', format((data_length+index_length)/(1024*1024),0)
from tables
where (table_name like '%comments' or table_name like '%redirection')
and table_rows > 2000
order by table_rows desc;
select '</table><p>' ;

-- select * from menu_router where access_callback in ('file_put_contents','assert','php_eval')
-- select * from users where uid=1;


select '<P><a id="usr_sec"></a><table border="2"><tr><td><b>Users with poor passwords</b></td></tr>' ;
select '<tr><td><b>User</b>',
 '<td><b>Host</b>',
 '<td><b>Note</b>';
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>Empty password'
FROM mysql.user
WHERE password='';
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>Same as username'
  FROM mysql.user
 WHERE password =UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1(user))) AS CHAR)))
union
-- Known hash: root, secret, password, mypass, public, private, 1234, admin, secure, pass, mysql, my123, ...
SELECT '<tr><td>',user, 
	'<td>', host, 
	'<td>Weak password'
  FROM mysql.user
 WHERE password in ('*81F5E21E35407D884A6CD4A731AEBFB6AF209E1B', '*14E65567ABDB5135D0CFD9A70B3032C179A49EE7',
      '*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19', '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4',
      '*A80082C9E4BB16D9C8E41B0D7EED46126DF4A46E', '*85BB02300F877EB061967510E83F68B1A7325252',
      '*A4B6157319038724E3560894F7F932C8886EBFCF', '*4ACFE3202A5FF5CF467898FC58AAB1D615029441',
      '*A36BA850A6E748679226B01E159EF1A7BF946195', '*196BDEDE2AE4F84CA44C47D54D78478C7E2BD7B7',
      '*E74858DB86EBA20BC33D0AECAE8A8108C56B17FA', '*AF35041D44DF3E88C9F97CC8D3ACAF4695E65B69',
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('Moodlebox4$'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('moodle'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('drupal'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('admin01'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('joomla'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('wp'))) AS CHAR))),
      UPPER(CONCAT('*', CAST(SHA1(UNHEX(SHA1('changeme'))) AS CHAR))) )
union
SELECT '<tr><td>',user, 
	'<td>', host,
	'<td>Weak password'
  FROM mysql.user
 WHERE password in (old_password(user),
      old_password('root'), old_password('secret'), old_password('password'), old_password('mypass'),
      old_password('public'), old_password('private'), old_password('1234'), old_password('admin'),
      old_password('secure'), old_password('pass'), old_password('mysql'), old_password('my123'),
      old_password('prova'), old_password('test'), old_password('demo'), old_password('qwerty'),
      old_password('Moodlebox4$'),
      old_password('manager'), old_password('moodle'), old_password('drupal'), old_password('admin01'),
      old_password('joomla'), old_password('wp'), old_password('changeme') )
union
SELECT '<tr><td>',host, 
	'<td>', user, 
	'<td>Old [pre 4.1] password format'
  FROM mysql.user
 WHERE password not like '*%' and password<>''
 order by user;
select '</table><p><hr>' ;

select '<hr><P>Statistics generated on: ', now();
select '<br>For more information on myCMSver contact' ;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo Bogliolo</A>.<p></body></html>' ;

EOF
