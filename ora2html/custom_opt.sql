REM Program:	custom_opt.sql
REM 		Oracle Optimizer features PlugIn
REM Version:	1.0.1
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://www.md-c.it/meo/
REM		
REM Date:    	15-AUG-12 mail@meo.bogliolo.name
REM		First version
REM Date:    	15-AUG-18 mail@meo.bogliolo.name
REM		Small graphical changes

COLUMN sql_feature FORMAT A34
COLUMN value FORMAT 99999
COLUMN optimizer_feature_enable FORMAT A9
COLUMN description format A40 trunc
COLUMN event FORMAT 999999
COLUMN def FORMAT A1
set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="cust_opt"></a><h2>Oracle Optimizer</h2>' h from dual;
SELECT '<h3>Optimizer features enabled</h3><pre>' from dual;  
set heading on

SELECT 'Not Default SQL_features' Item, count(*)
  FROM   v$system_fix_control
 where IS_DEFAULT<>1;

SELECT BUGNO, VALUE,SQL_FEATURE,DESCRIPTION,OPTIMIZER_FEATURE_ENABLE,EVENT,decode(IS_DEFAULT,1,'Y','N') def
  FROM   v$system_fix_control
 order by IS_DEFAULT, OPTIMIZER_FEATURE_ENABLE;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
