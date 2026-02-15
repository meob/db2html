REM Program:	custom_26ai.sql
REM 		Oracle 26ai PlugIn
REM Version:	1.0.1
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://www.meo.bogliolo.name/
REM		
REM Date:    	31-OCT-25 mail@meo.bogliolo.name
REM		First version with new useful queries available on 26ai
REM             1.0.1 Fix: DBA_ instead of USER_

column model_name format a20
column pool format a10
column parameter_name format a40
column parameter_value format a20

set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="26ai"></a><h2>Oracle 26ai features</h2>' h from dual;
SELECT '<h3>Mining Models</h3><pre>' from dual;
set heading on
SELECT OWNER, MODEL_NAME, MINING_FUNCTION, ALGORITHM, ALGORITHM_TYPE, MODEL_SIZE
  FROM DBA_MINING_MODELS
 ORDER BY MODEL_NAME;
set heading off

SELECT '</pre><h3>Models Attributes</h3><pre>' from dual; 
set heading on
SELECT OWNER, MODEL_NAME, ATTRIBUTE_NAME, ATTRIBUTE_TYPE, DATA_TYPE, VECTOR_INFO
  FROM DBA_MINING_MODEL_ATTRIBUTES
 ORDER BY MODEL_NAME, ATTRIBUTE_NAME;
set heading off

SELECT '</pre><h3>Vector Memory Pool</h3><pre>' from dual; 
set heading on
select * from V$VECTOR_MEMORY_POOL
 order by USED_BYTES desc, ALLOC_BYTES desc;
set heading off

SELECT '</pre><h3>AI Vector Parameters</h3><pre>' from dual; 
set heading on
select name as parameter_name, value as parameter_value
  from v$parameter
 where upper(name) IN ('COMPATIBLE', 'VECTOR_MEMORY_SIZE', 'VECTOR_INDEX_NEIGHBOR_GRAPH_RELOAD', 'VECTOR_QUERY_CAPTURE')
 order by name;
set heading off

select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;



