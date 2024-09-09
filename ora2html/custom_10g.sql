REM Program:	custom_10g.sql
REM 		Oracle 10g PlugIn
REM Version:	1.0.3
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	15-AUG-12 mail@meo.bogliolo.name
REM		First version with useful new 10g queries
REM		1.0.3 Added MAX PCT for autoextensible TBS

column TABLESPACE_SIZE format 9,999,999,999,999
column TABLESPACE_NAME format A32
column NAME format A32
column USED_SPACE format 9,999,999,999,999
column USED_PERCENT format 99.99
column STARTUP_TIME format a30
column HOST_NAME format a36
column bg format a18 trunc
column ed format a18 trunc
column MIN_USED format 9,999,999,999,999
column MAX_USED format 9,999,999,999,999
column maxbytes format 9,999,999,999,999,999
set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="10g"></a><h2>Oracle 10g features</h2>' h from dual;

SELECT '<h3>Tablespace Usage</h3><pre>' from dual;  
set heading on
select TABLESPACE_NAME, USED_SPACE, TABLESPACE_SIZE, USED_PERCENT
  from dba_tablespace_usage_metrics
 order by TABLESPACE_NAME;

SELECT df.tablespace_name tspace,                                                              
       df.bytes/(1024*1024) tot_ts_size,   
       round((df.bytes-sum(fs.bytes))/(1024*1024),0) used_MB,                                                   
       round(sum(fs.bytes)/(1024*1024),0) free_ts_size,                                                 
       round(sum(fs.bytes)*100/df.bytes) free_pct,                                               
       round((df.bytes-sum(fs.bytes))*100/df.bytes) used_pct,
       round((df.bytes-sum(fs.bytes))*100/df.max_sz) used_pct_of_max
  FROM (select tablespace_name, sum(bytes) bytes,sum(decode(autoextensible, 'YES', maxbytes, bytes)) max_sz
          from dba_data_files
         where tablespace_name in (select tablespace_name from dba_tablespaces where contents = 'PERMANENT')
         group by tablespace_name ) df,
       dba_free_space fs
 WHERE fs.tablespace_name = df.tablespace_name                                                  
 GROUP BY df.tablespace_name, df.bytes,df.max_sz
 ORDER BY 1;

set heading off
SELECT '</pre><h3>Tablespaces</h3><pre>' from dual;  
set heading on
select TS#, name, bigfile big, FLASHBACK_ON fsh, INCLUDED_IN_DATABASE_BACKUP bck, ENCRYPT_IN_BACKUP enc
from v$tablespace
order by TS#;

select file_id, a.tablespace_name, autoextensible, maxbytes
from (select file_id, tablespace_name, autoextensible, maxbytes from dba_data_files where autoextensible='YES' and maxbytes = 35184372064256) a, (select tablespace_name from dba_tablespaces where bigfile='YES') b
where a.tablespace_name = b.tablespace_name
union
select file_id,a.tablespace_name, autoextensible, maxbytes
from (select file_id, tablespace_name, autoextensible, maxbytes from dba_temp_files where autoextensible='YES' and maxbytes = 35184372064256) a, (select tablespace_name from dba_tablespaces where bigfile='YES') b
where a.tablespace_name = b.tablespace_name;

set heading off
SELECT '</pre><h3>Instance startup</h3><pre>' from dual;  
set heading on
select *
from (select STARTUP_TIME,VERSION,DB_NAME,INSTANCE_NAME,HOST_NAME
      from DBA_HIST_DATABASE_INSTANCE
      order by startup_time desc)
where rownum <= 30
order by startup_time desc;
set heading off

select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
