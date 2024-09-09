REM Program:	custom_10g.sql
REM 		Oracle 10g PlugIn
REM Version:	1.0.3
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	15-AUG-12 mail@meo.bogliolo.name
REM		First version with useful new 10g queries
REM
REM		BE CAREFULL: those views require Diagnostic Pack Option License

column TABLESPACE_SIZE format 9,999,999,999,999
column TABLESPACE_NAME format A32
column NAME format A32
column USED_SPACE format 9,999,999,999,999
column USED_PERCENT format 99.99
column STARTUP_TIME format a30
column HOST_NAME format a30
column bg format a18 trunc
column ed format a18 trunc
column MIN_USED format 9,999,999,999,999
column MAX_USED format 9,999,999,999,999
column maxbytes format 9,999,999,999,999,999
set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="10g"></a><h2>Oracle 10g features</h2>' h from dual;

SELECT '</pre><h3>Tablespace Usage History</h3><pre>' from dual;  
set heading on
select B.NAME, avg(tablespace_size) TABLESPACE_SIZE, 
       min(TABLESPACE_USEDSIZE) min_used,max(TABLESPACE_USEDSIZE) max_used,
       min(begin_interval_time) bg, max(begin_interval_time) ed
  FROM DBA_HIST_TBSPC_SPACE_USAGE A
  JOIN V$TABLESPACE B ON (A.TABLESPACE_ID = B.TS#)
  JOIN DBA_HIST_SNAPSHOT C ON (A.SNAP_ID = C.SNAP_ID)
group by B.NAME
ORDER BY 1;

set heading off
SELECT '</pre><h3>Tablespace Depletion Forecast</h3><pre>' from dual;  
set heading on

select B.NAME,
       round( (max(tablespace_size)-max(TABLESPACE_USEDSIZE)) 
              / decode(max(TABLESPACE_USEDSIZE)-min(TABLESPACE_USEDSIZE),0,null,
                       max(TABLESPACE_USEDSIZE)-min(TABLESPACE_USEDSIZE)) *7) depletion
  FROM DBA_HIST_TBSPC_SPACE_USAGE A
  JOIN V$TABLESPACE B ON (A.TABLESPACE_ID = B.TS#)
group by B.NAME
ORDER BY 1;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;

