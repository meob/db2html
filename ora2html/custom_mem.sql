REM Program:	custom_mem.sql
REM 		Oracle Memory Usage PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	01-JAN-18 mail@meo.bogliolo.name
REM		First version based on:
REM 		 Gathering Initial Troubleshooting Information for Analysis of ORA-4030 Errors (Doc ID 1675986.1) - Step 4/5

SET PAGESIZE 9999
SET LINESIZE 256
SET TRIMOUT ON
SET TRIMSPOOL ON
COL statistic# FORM 999
COL name HEADING "Name" FORM A40
COL val HEADING "Value" FORM A20
COL value HEADING "Value" FORM 9999999999999999
COL totsga HEADING "Total SGA Size (Fixed + Variable; MB)" FORM 9999999999999999
COL totpga HEADING "Total PGA Allocated (MB)" FORM 9999999999999999
COL inactivepga HEADING "Inactive PGA (MB)" FORM 9999999999999999
COL SID FORMAT 999999
ALTER SESSION SET nls_date_format='DD-MON-YYYY HH24:MI:SS';
BREAK ON sid

/* Database identification */
SELECT name, platform_id, database_role FROM v$database;
SELECT * FROM v$version WHERE banner LIKE 'Oracle Database%';

/* Current instance parameter values */
SELECT n.ksppinm name, v.KSPPSTVL val
  FROM x$ksppi n, x$ksppsv v
 WHERE n.indx = v.indx
   AND (n.ksppinm LIKE '%pga%target%' OR n.ksppinm LIKE '%sga%target%'
    OR n.ksppinm LIKE '%memory%target%' OR n.ksppinm  LIKE '%indirect%')
 ORDER BY 1;

/* Current memory settings */
SELECT component, current_size
  FROM v$sga_dynamic_components;

/* Memory resizing operations */
SELECT start_time, end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status
  FROM v$memory_resize_ops
 ORDER BY 1, 2;

/* Historical memory resizing operations */
SELECT start_time, end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status
  FROM dba_hist_memory_resize_ops
 ORDER BY 1, 2;

/* Total SGA allocated */
SELECT SUM(value) totsga
  FROM v$sga;

/* Total PGA allocated */
SELECT SUM(pga_alloc_mem)/1024/1024 totpga
  FROM v$process p, v$session s
 WHERE p.addr = s.paddr;

/* Inactive total process PGA memory use */
SELECT SUM(pga_alloc_mem)/1024/1024 inactivepga
  FROM v$process p, v$session s
 WHERE p.addr = s.paddr
   AND s.status = 'INACTIVE';

/* Inactive PGA memory use grouped per Oracle user */
SELECT p.username, SUM(pga_alloc_mem)/1024/1024 inactivepga
  FROM v$process p, v$session s
 WHERE p.addr = s.paddr
   AND s.status = 'INACTIVE'
 GROUP BY p.username
 ORDER BY p.username, SUM(pga_alloc_mem) DESC;

/* Get cumulative session memory statistics */
SELECT n.name, s.value
  FROM (SELECT statistic#, SUM(value) value
          FROM v$sesstat
         GROUP BY statistic#) s, v$statname n
 WHERE s.statistic# = n.statistic#
   AND n.name LIKE '%memory%'
 ORDER BY s.statistic#;

/* Get per-session memory statistics */
SELECT s.sid, n.name, s.value
  FROM v$sesstat s, v$statname n
 WHERE s.statistic# = n.statistic#
   AND n.name LIKE 'session%memory%'
 ORDER BY s.sid, s.statistic#;

/* UGA memory allocation cumulative statistics; necessary for Shared Server analysis */
SELECT SUM(value) || ' Bytes' "Total UGA (All Sessions)"
  FROM v$sesstat, v$statname
 WHERE name = 'session uga memory'
   AND v$sesstat.statistic# = v$statname.statistic#;

/* UGA maximum memory allocation cumulative statistics; necessary for Shared Server analysis */
SELECT SUM(value) || ' Bytes' "Total Max UGA (All Sessions)"
  FROM v$sesstat, v$statname
 WHERE name = 'session uga memory max'
   AND v$sesstat.statistic# = v$statname.statistic#;

/* Shared Server Wait Queue Statistics */
SELECT DECODE(TOTALQ, 0, 'No Requests', WAIT/TOTALQ || ' Hundredths Of Seconds') "Average Wait Time Per Request"
  FROM V$QUEUE
 WHERE TYPE = 'COMMON';

/* Shared Server process count */
SELECT COUNT(*) "Shared Server Processes"
  FROM V$SHARED_SERVER
 WHERE STATUS != 'QUIT';

/* Session PGA */
select sum(bytes)/1024/1024 SessionPgaMB
  from (select bytes
          from v$sgastat
         union select value bytes
          from v$sesstat s, v$statname n
         where n.STATISTIC# = s.STATISTIC#
           and n.name = 'session pga memory'); 



