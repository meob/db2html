REM Program:	custom_lic.sql
REM 		Oracle Licensing PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	14-FEB-14 mail@meo.bogliolo.name
REM		Second version (less queries since most of them are already done in ora2html)

set lines 132
set define off

set heading off
select '<P><a id="cust_lic"></a><a id="cust_lic"></a><h2>Oracle Licensing Report</h2><pre>' h from dual; 
set heading on

select replace(replace(output,'<','&lt;'),'>','&gt;') report
  from table(dbms_feature_usage_report.display_text);

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;