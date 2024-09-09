REM Program:	custom.sql
REM 		Custom Oracle HTML Report PlugIns
REM Version:	1.0.17
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM Data:	1-APR-09
REM
REM Note:	1-JUL-13 mail@meo.bogliolo.name
REM		  Oracle 12c Plug-in added
REM Note:	1-APR-14 mail@meo.bogliolo.name
REM		  Menu
REM Note:	14-FEB-17 mail@meo.bogliolo.name
REM		  New CSS
REM Note:	14-FEB-18 mail@meo.bogliolo.name
REM		  18c stats (not enabled by default)
REM Note:	1-APR-22 mail@meo.bogliolo.name
REM		  19c stats (now enabled by default)
REM
REM		Some scripts require specific Oracle Options.
REM		 Check the acquired options before enabling the scripts.

set heading off
select '<a id="custMenu">Optional Plugins</a>:<br><ul>' from dual;
select '<li><b><A HREF="#custO">DB Versions, Options and Appliances</a></b>: ' from dual;
 select ' <A HREF="#10g">10g</a>, <A HREF="#11g">11g</a>, <A HREF="#12c">12c</a>, <A HREF="#19c">19c</a>, <A HREF="#23c">23c</a>,' from dual;
 select ' <A HREF="#asm">ASM</a>, <A HREF="#rac">RAC</a>,'  from dual;
 select ' <A HREF="#dg">Data Guard</a>,' from dual;
 select ' <A HREF="#exa">Exadata</a>, ...' from dual;
select '<li><b><A HREF="#custP">Performance</a></b>: <A HREF="#awr">AWR/ADDM</a>, <A HREF="#sqlt">SQL Tuning</a>,' from dual;
 select ' <A HREF="#cache_advice">Cache Advices</a>, <A HREF="#cust_opt">Optimizer features</a>, <A HREF="#emp7">EMP7</a>, ...' from dual;
select '<li><b><A HREF="#custF">Advanced features</a></b>: ' from dual;
 select ' <A HREF="#omf">OMF</a>, <A HREF="#aud">Audit</a>, <A HREF="#sysaux">SYSAUX</a>, <A HREF="#tde">TDE</a>, <A HREF="#ebs">eBS</a>, ...' from dual;
select '<li><b><A HREF="#cust0">Other</a></b>: <A HREF="#cust_lic">Licensing</a>, <A HREF="#cust_rman">RMAN</a>,' from dual;
 select ' <A HREF="#cust_cli_ver">Client Versions</a>, ...' from dual;
select '<li><b><A HREF="#custC">Custom</a></b>:' from dual;
 select ' <A HREF="#cust1">Custom #1</a>, <A HREF="#cust2">Custom #2</a>, <A HREF="#cust3">Custom #3</a>, ...' from dual;
select '</ul><a href="#top">Top</a>' from dual;
select '<hr>' Title from dual;

@custom_10g
@custom_11g
@custom_12c
REM @custom_18c
@custom_19c
@custom_23c
@custom_asm
@custom_rac

@custom_dg
REM @custom_adg
REM @custom_exadata
@custom_advice
REM @custom_opt
REM @custom_audit
REM @custom_mem
@custom_omf
@custom_sysaux
REM @custom_ebs
REM @custom_ebs_app
REM @custom_ebs_cust
REM @custom_lic
@custom_rman
REM @custom_clientv

REM Customer scripts
select '<a id="custC"><pre>Customer scripts' from dual;
REM @custom_Customer
select '</pre>' from dual;

REM Heavy or time consuming scripts
REM @custom_io
@custom_emp7

REM Data Security scripts
REM @custom_mixen_dd


REM Diagnostic Pack Option License required for running the following scripts
REM @custom_awr
REM @custom_10g_diag
REM @custom_hist_io

REM Tuning Pack Option License required for running the following script
REM @custom_sqlt

REM Advanced Security Option License required for running the following script
REM @custom_tde

set heading off
