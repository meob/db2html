REM Program:	custom_mixen_dd.sql
REM 		miXen 1st DD PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	01-NOV-17 mail@meo.bogliolo.name
REM		miXen DataDictionary 1st Discovery query
REM Date:    	01-AUG-19 mail@meo.bogliolo.name
REM		Excluded 12c, 18c, 19c demo users

column OWNER format a20
column TABLE_NAME format a32
column COLUMN_NAME format a32
column DATA_TYPE format a20
set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="mixen"></a><h2>miXen Data Dictonary 1st Discoverer</h2>' h from dual;

SELECT '<h3>Sensitive/Confidential/Critical candidate tables</h3><pre>' from dual;  
set heading on
select OWNER, TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_LENGTH
 from dba_tab_columns
 where OWNER not in ('SYS','SYSTEM', 'APEX_030200','DBSNMP','GSMADMIN_INTERNAL','OUTLN',
                     'ORDDATA','ORDSYS','SQLTXADMIN','SQLTXPLAIN','SYSMAN','WMSYS',
                     'AUDSYS','DVSYS','LBACSYS','MDSYS','OLAPSYS','XDB')
   and (column_name like '%FIRST%NAME%' OR
	column_name like '%LAST%NAME%' OR
	column_name like '%SURNAME%' OR
	column_name like '%FULL%NAME%' OR
	column_name like '%USER%NAME%' OR
	column_name like '%COGNOME%' OR
	column_name like '%MAIL%' OR
	column_name like '%POSTA%' OR
	column_name like '%TELEP%' OR
	column_name like '%EXTENS%' OR
	column_name like '%TELEF%' OR
	column_name like '%SSN%' OR
	column_name like '%FISC%' OR
	column_name like '%IBAN%' OR
	column_name like '%CCARD%' OR
	column_name like '%BANK%' OR
	column_name like '%BANCA%' OR
	column_name like '%PAYP%' OR
	column_name like '%PASS%' OR
	column_name like '%RELIGIO%' OR
	column_name like '%ACUZIE%' OR
	column_name like '%PATHOL%')
 order by 1,2,3;

set heading off

select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;

