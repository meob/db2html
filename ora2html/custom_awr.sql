REM Program:	custom_awr.sql
REM 		Oracle AWR PlugIn
REM Version:	1.0.6
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM              https://meoshome.it.eu.org/
REM		
REM Date:	1-APR-10 1.0.0 mail@meo.bogliolo.name
REM		Initial version with useful AWR, ADDM and ASH queries
REM		
REM Date:    	15-AUG-12 1.0.1 mail@meo.bogliolo.name
REM		Larger date interval
REM
REM Date:    	15-AUG-17 1.0.4 mail@meo.bogliolo.name
REM		Fixed a strange bug on date group by
REM
REM Date:       15-AUG-19 1.0.5 mail@meo.bogliolo.name
REM             Top sessions
REM
REM Date:       31-OCT-20 1.0.6 mail@meo.bogliolo.name
REM             Fixed a bug in ACTIVE_SESSION_HISTORY queries (Optimizer bug in 12.2 Doc ID 2294763.1)
REM
REM IMPORTANT NOTICE:
REM		This script uses tables related to:
REM		  AWR  (Automatic Workload Repository)
REM		  ASH  (Active Session History)
REM		  ADDM (Automatic Database Diagnostic Monitor)
REM		This script requires the Oracle Diagnostic Pack LICENSE

column sample_time format a20
column as_diagram format a80
column wait_event format a60
column total_wait_time format a20
column wait_class format a20
column name format a80
column time_secs format a20
column pct format a10
column name format a60
column username format a30
column sql_opname format a10 trunc
column module format a20 trunc
column machine format a24
set lines 132

REM V$ACTIVE_SESSION_HISTORY --> DBA_HIST_ACTIVE_SESS_HISTORY
ALTER SESSION SET "_optimizer_aggr_groupby_elim" = FALSE;

set heading off
SELECT '<p><a id="custP"></a><a id="awr"></a><h2>Performance statistics (Diagnostic Option based)</h2>' from dual;  
SELECT '<h3>Active Sessions Diagram (last hour, by minute)</h3><pre>' from dual; 
set heading on
select to_char(stime, 'YYYY/MM/DD HH24:MI') Sample_time,
       max(asess) Active_sessions,
       rpad('|', max(asess), '=') as_diagram
 from (select count(*) asess, sample_time stime 
        from V$ACTIVE_SESSION_HISTORY 
	where sample_time > sysdate-1/24
	  and session_type ='FOREGROUND'
        group by sample_time)
 group by to_char(stime, 'YYYY/MM/DD HH24:MI')
 order by 1 desc;

set heading off
SELECT '</pre><h3>Active Sessions Diagram (up to last week, by hour)</h3><pre>' from dual; 
set heading on
select to_char(stime, 'YYYY/MM/DD HH24') Sample_time,
       max(asess) Active_sessions,
       rpad('|', max(asess), '=') as_diagram
 from (select count(*) asess, sample_time stime 
        from DBA_HIST_ACTIVE_SESS_HISTORY 
	where sample_time > sysdate-7
	  and session_type ='FOREGROUND'
        group by sample_time)
 group by to_char(stime, 'YYYY/MM/DD HH24')
 order by 1 desc;

set heading off
SELECT '</pre><h3>Active Sessions Peaks (more than 10 Active Sessions, by hour)</h3><pre>' from dual;  
set heading on
select to_char(stime, 'YYYY/MM/DD HH24') Sample_time,
       max(asess) Active_sessions,
       rpad('|', max(asess), '=') as_diagram
 from (select count(*) asess, sample_time stime 
        from DBA_HIST_ACTIVE_SESS_HISTORY 
	where sample_time > sysdate-31
	  and session_type ='FOREGROUND'
        group by sample_time)
 group by to_char(stime, 'YYYY/MM/DD HH24')
 having max(asess) >= 10
 order by 1 desc;

set heading off
SELECT '</pre><h3>Active Sessions Average</h3><pre>' from dual;  
set heading on
select round((count(ash.sample_id)/((CAST(end_time.sample_time AS DATE) - CAST(start_time.sample_time AS DATE))*24*60*60)),2) as ActiveSessionsAvg
  from	(select min(sample_time) sample_time 
	   from  v$active_session_history ash) start_time,
	(select max(sample_time) sample_time
	   from  v$active_session_history) end_time,
	v$active_session_history ash
 where ash.sample_time between start_time.sample_time and end_time.sample_time
 group by end_time.sample_time,start_time.sample_time;

set heading off
SELECT '</pre><h3>Top sessions</h3><pre>' from dual;  
set heading on
select * from (
select username, sql_opname, module, machine,
       sum(delta_read_io_bytes)/(1024) io_r_k, sum(delta_write_io_bytes)/(1024) io_w_k,
       sum(delta_read_io_requests) rq_r_k, sum(delta_write_io_requests) rq_w_k
  from gv$active_session_history, dba_users
 where gv$active_session_history.user_id = dba_users.user_id
   and username not in ('SYS')
 group by username, sql_opname, module, machine
 order by 5 desc)
 where rownum < 21;

set heading off
SELECT '</pre><h3>Top wait event (Last Day)</h3><pre>' from dual;  
set heading on
SELECT  h.event Wait_Event, 
   to_char( SUM(h.wait_time + h.time_waited), '999,999,999,999') Total_Wait_Time
FROM  v$active_session_history h,  v$event_name e
WHERE h.sample_time BETWEEN sysdate - 1 AND sysdate
  AND h.event_id = e.event_id
  AND e.wait_class <> 'Idle'
GROUP BY h.event
HAVING SUM(h.wait_time + h.time_waited) > 0.1
ORDER BY 2 DESC;

set heading off
SELECT '<a name="cust4"></a></pre><h3>Wait Event Details</h3><pre>' from dual;  
set heading on

SELECT wait_class, NAME, to_char(ROUND(time_secs, 2),'999,999,990.00') time_secs,
   to_char(ROUND(time_secs*100 / SUM(time_secs) OVER (), 2), '990.0') pct
FROM (SELECT n.wait_class, e.event NAME, e.time_waited / 100 time_secs
       FROM  v$system_event e, v$event_name n
       WHERE n.NAME = e.event AND n.wait_class <> 'Idle'
       AND   time_waited > 0
      UNION
      SELECT 'CPU', 'server CPU', SUM(VALUE/1000000) time_secs
       FROM  v$sys_time_model
       WHERE stat_name IN ('background cpu time', 'DB CPU'))
WHERE time_secs >10
ORDER BY time_secs DESC;

set heading off
SELECT '</pre><h3>Advisor Recommendations (SQL)</h3><pre>' from dual;  
set heading on
column OBJECT_FOUND format a40
column ACTION_FOUND format a90

select * from (
SELECT o.TYPE||' '||o.attr1||'.'||o.attr2 Object_found, f.message Action_found
FROM DBA_ADVISOR_RECOMMENDATIONS r, DBA_ADVISOR_FINDINGS f, DBA_ADVISOR_OBJECTS o
WHERE r.TASK_ID = f.TASK_ID AND
r.TASK_NAME = f.TASK_NAME AND
r.FINDING_ID = f.FINDING_ID AND
f.TASK_ID = o.TASK_ID AND
f.TASK_NAME = o.TASK_NAME AND
f.OBJECT_ID = o.OBJECT_ID
and o.type = 'SQL'
order by o.attr1, o.attr2)
where rownum <21;

set heading off
SELECT '</pre><h3>Advisor Recommendations (Objects)</h3><pre>' from dual;  
set heading on
column OBJECT_FOUND format a60
column ACTION_FOUND format a70

select * from (
SELECT o.TYPE||' '||o.attr1||'.'||substr(o.attr2,1,40) Object_found, 
  substr(f.message, 1, decode(instr(f.message,','),0,length(f.message), instr(f.message,',')-1)) Action_found
FROM DBA_ADVISOR_RECOMMENDATIONS r, DBA_ADVISOR_FINDINGS f, DBA_ADVISOR_OBJECTS o
WHERE r.TASK_ID = f.TASK_ID AND
r.TASK_NAME = f.TASK_NAME AND
r.FINDING_ID = f.FINDING_ID AND
f.TASK_ID = o.TASK_ID AND
f.TASK_NAME = o.TASK_NAME AND
f.OBJECT_ID = o.OBJECT_ID
and o.type <> 'SQL'
group by  o.attr1, o.attr2, o.type,
 substr(f.message, 1, decode(instr(f.message,','),0,length(f.message), instr(f.message,',')-1))
order by o.attr1, o.attr2)
where rownum <21;

set heading off
select '</pre><p>' from dual;
