REM Program:    custom_hist_io.sql
REM             Oracle IO history
REM Version:    1.0.0
REM Author:     Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM
REM Date:       1-APR-14 mail@meo.bogliolo.name
REM
REM Note:
REM             Uses DBA_HIST_EVENT_HISTOGRAM for "db file sequential read"
REM		Requires Diagnostic Pack License

column avg_io format 99.99999
column event_wait format 999,999,999,999
set lines 132

set heading off
SELECT '<p><a id="custP"></a><a id="hist_io"></a><h2>Wait Events Histograms</h2><pre>' from dual;
SELECT '<b>Estimated I/O Performances</b>' from dual;
set heading on

select sum(wait_time_milli*wait_count)/sum(wait_count) avg_io,
       to_char(begin_interval_time, 'YYYY-MM-DD HH24:MI') sample_time,
       s.instance_number
  from DBA_HIST_EVENT_HISTOGRAM eh, dba_hist_snapshot s
 where s.snap_id = eh.snap_id
   and s.dbid = eh.dbid
   and s.instance_number = eh.instance_number
   and event_name  = 'db file sequential read'
   and begin_interval_time > sysdate-2
group by s.snap_id, begin_interval_time, s.instance_number
order by begin_interval_time, s.instance_number;

set heading off
SELECT '<b>Events Wait time splitted on classes</b>' from dual;
set heading on

select sum(wait_time_milli*wait_count) event_wait, wait_class,
       to_char(begin_interval_time, 'YYYY-MM-DD HH24:MI') sample_time,
       s.instance_number
  from DBA_HIST_EVENT_HISTOGRAM eh, dba_hist_snapshot s
 where s.snap_id = eh.snap_id
   and s.dbid = eh.dbid
   and s.instance_number = eh.instance_number
   and wait_class <> 'Idle'
   and begin_interval_time> sysdate-0.5
group by s.snap_id, wait_class, begin_interval_time, s.instance_number
order by begin_interval_time, wait_class, s.instance_number;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
