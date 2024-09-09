REM Program:	custom_io.sql
REM 		Oracle Calibrate I/O PlugIn
REM Version:	1.0.1
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	15-AUG-13 mail@meo.bogliolo.name
REM		First version
REM
REM		WARNING: I/O Calibration take some time

column chr_var format a20
column num_var format 999999999999
column CALIBRATION_TIME format a32
column START_TIME format a32
column END_TIME format a32
column con_id format a32
set lines 132
set define off

set heading off
select '<P><a id="cust0"></a><a id="cust_io"></a><h2>Calibrate I/O Performances</h2>' h from dual;
SELECT '<h3>Oracle 11g I/O Calibration Routine</h3><p><pre>' from dual;  
set heading on

SET SERVEROUTPUT ON
DECLARE
  lat  INTEGER;
  iops INTEGER;
  mbps INTEGER;
  n_disks INTEGER;
BEGIN
  FOR n_disks IN 1..4
  LOOP
    DBMS_RESOURCE_MANAGER.CALIBRATE_IO (n_disks, 10, iops, mbps, lat);
    dbms_output.put_line('#disks   = ' || n_disks);
    dbms_output.put_line('max_mbps = ' || mbps);
    dbms_output.put_line('max_iops = ' || iops);
    dbms_output.put_line('latency  = ' || lat);
    dbms_output.put_line('  ');
  END LOOP;

  DBMS_RESOURCE_MANAGER.CALIBRATE_IO (16, 10, iops, mbps, lat);
  dbms_output.put_line('#disks   = ' || 16);
  dbms_output.put_line('max_mbps = ' || mbps);
  dbms_output.put_line('max_iops = ' || iops);
  dbms_output.put_line('latency  = ' || lat);
  dbms_output.put_line('  ');
end;
/

select * from V$IO_CALIBRATION_STATUS;
select * from DBA_RSRC_IO_CALIBRATE;

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
