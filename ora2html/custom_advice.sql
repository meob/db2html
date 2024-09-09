REM Program:	custom_advice.sql
REM 		Oracle Cache Advice PlugIn
REM Version:	1.0.0
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:	1-APR-14 mail@meo.bogliolo.name
REM		
REM Note:
REM		Needs DB_CACHE_ADVICE=ON. With STATISTICS_LEVEL is TIPICAL or ALL DB_CACHE_ADVICE default is ON.


COLUMN size_for_estimate FORMAT 999,999,999,999 heading 'Cache Size (MB)'
COLUMN buffers_for_estimate FORMAT 999,999,999 heading 'Buffers'
COLUMN estd_physical_read_factor FORMAT 999.90 heading 'Estd Phys|Read Factor'
COLUMN estd_physical_reads FORMAT 999,999,999,999 heading 'Estd Phys| Reads'
column namespace format a32
set lines 132

set heading off
SELECT '<p><a id="custP"></a><a id="cache_advice"></a><h2>Buffer Cache Advice</h2>' from dual;
SELECT '<h3>Default pool</h3><pre>' from dual;  
set heading on

SELECT size_for_estimate, buffers_for_estimate, estd_physical_read_factor, estd_physical_reads
FROM V$DB_CACHE_ADVICE
WHERE name = 'DEFAULT'
AND block_size = (SELECT value FROM V$PARAMETER WHERE name = 'db_block_size')
AND advice_status = 'ON';

set heading off
COLUMN size_for_estimate FORMAT 999,999,999,999 heading 'Keep Size (MB)'
SELECT '</pre><h3>Keep pool</h3><pre>' from dual;  
set heading on

SELECT size_for_estimate, buffers_for_estimate, estd_physical_read_factor, estd_physical_reads
FROM V$DB_CACHE_ADVICE
WHERE name = 'KEEP'
AND block_size = (SELECT value FROM V$PARAMETER WHERE name = 'db_block_size')
AND advice_status = 'ON';

set heading off
SELECT '</pre><h3>Library cache</h3><pre>' from dual;  
set heading on

SELECT NAMESPACE, PINS, PINHITS, RELOADS, INVALIDATIONS
FROM V$LIBRARYCACHE
ORDER BY NAMESPACE;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
