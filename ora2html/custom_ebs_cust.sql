REM Program:	custom_ebs_cust.sql
REM 		Oracle EBS Customizations PlugIn
REM Version:	1.0.0a
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	15-AUG-14 mail@meo.bogliolo.name
REM             (a) created by > 7 moved to > 1000

column description format a60 trunc
column APPLICATION_NAME FORMAT A60
column SHT_NAME FORMAT A10
column PATCH_LEVEL FORMAT A20
column multi_org format a10
column multi_lingual format a10
column multi_currency format a10
set lines 132
set define off

set heading off
select '<P><a id="cust0"></a><a id="ebs_cust"></a><h2>Oracle eBS Customizations</h2><pre>' h from dual;

SELECT '<b>Customizations Summary</b>' from dual; 
rem SELECT '<p>The following report is only a suggestion since customization <i>standards</i> can vary a lot' from dual;  
set heading on

rem select distinct lookup_code,meaning from apps.fnd_lookup_values where lookup_type='CP_EXECUTION_METHOD_CODE'...
select 'Custom Concurrent Programs = '||count(*) "CUSTOM_Summary"
  from (SELECT application_id
          FROM apps.FND_CONCURRENT_PROGRAMS_VL
         WHERE APPLICATION_ID>20000 or (APPLICATION_ID<20000 AND created_by>1000)) a, -- WAS created_by>7
       apps.fnd_application_vl b
 where a.application_id=b.application_id
union
select 'Custom Concurrent Programs by type ('||execution_method_code||') = '||count(*) mesg
  from (SELECT DECODE(EXECUTION_METHOD_CODE,'Q','SQL*Plus', 'P','Oracle Reports', 'I','PL/SQL SP', 
              'L','SQL*Loader', 'H','Host', 'A','Spawned', 'J','Java SP', 'R','SQLReport', 'X','Flexrpt',
              'S','Immediate', 'E', 'Perl', 'K', 'Java', 'M', 'Multi Language', 'F', 'FlexSQL',
              'B', 'Set Stage Function', EXECUTION_METHOD_CODE) EXECUTION_METHOD_CODE
          FROM apps.FND_CONCURRENT_PROGRAMS_VL
         WHERE APPLICATION_ID>20000 or (APPLICATION_ID<20000 AND created_by>1000)) group by execution_method_code
union
select 'Custom Forms Defined = '||count(*) mesg
  from apps.FND_FORM_FUNCTIONS_VL a, apps.fnd_form_vl b
 where a.created_by>1000
   and a.form_id not in (51614, 20589)
   and a.form_id=b.form_id
union
select 'Custom Database Objects by yype (SI Prefix) '||object_type||' = '||count(*) 
  from dba_objects
 where object_name like 'SI%'
 GROUP BY OBJECT_TYPE
union
select 'Custom Database Objects by Object Type (XX Prefix) '||object_type||' = '||count(*) 
  from dba_objects
 where object_name like 'XX%'
 GROUP BY OBJECT_TYPE;

select 'Custom Concurrent Programs by Application = '||count(*) "CUSTOM_SummaryByApplication"
  from (SELECT application_id
          FROM apps.FND_CONCURRENT_PROGRAMS_VL
         WHERE APPLICATION_ID>20000
            OR ( APPLICATION_ID<20000
                 AND created_by>1000)) a,
       apps.fnd_application_vl b
 where a.application_id=b.application_id
union
select 'Custom Concurrent Programs Defined Under '||b.application_name||' = '||count(*)
  from (SELECT application_id
          FROM apps.FND_CONCURRENT_PROGRAMS_VL
         WHERE APPLICATION_ID>20000
            OR ( APPLICATION_ID<20000
                 AND created_by>1000)) a,
       apps.fnd_application_vl b
 where a.application_id=b.application_id
 group by b.application_name;

set heading off
SELECT '<b>Customization Details</b>' from dual;  
set heading on

column custom_form_name format a40 trunc
column application_name format a40 trunc
column directory format a20
column form_os_file_name format a26
select distinct a.user_function_name custom_form_name,
       b.form_name form_os_file_name,
       c.basepath directory,
       c.application_name
  from apps.FND_FORM_FUNCTIONS_VL a, apps.fnd_form_vl b, apps.fnd_application_vl c
 where a.created_by>1000
   and a.form_id not in(51614, 20589)
   and a.form_id=b.form_id
   and c.application_id=b.application_id
 order by c.application_name,basepath, a.user_function_name;

column object_NAME format a40 trunc
select object_NAME,OBJECT_TYPE,OWNER
  from dba_objects
 where object_name like 'SI%' or object_name like 'XX%'
 ORDER BY OBJECT_TYPE, object_NAME;

column user_concurrent_program_name format a40 trunc
column application_name format a20 trunc
column filename format a28 trunc
column user_concurrent_program_name format a40
select distinct a.user_concurrent_program_name,b.application_name, c.user_executable_name filename,
       DECODE(c.EXECUTION_METHOD_CODE,'Q','SQL*Plus', 'P','Oracle Reports', 'I','PL/SQL SP', 
              'L','SQL*Loader', 'H','HOST', 'A','Spawned', 'J','Java SP', 'R','SQLReport', 'X','FlexRPT',
              'S','Immediate', 'E', 'Perl', 'K', 'Java', 'M', 'Multi Language', 'F', 'FlexSQL',
              'B', 'Set Stage Function', c.EXECUTION_METHOD_CODE) type_of_program,
       b.basepath directory_name
  from
       (SELECT USER_CONCURRENT_PROGRAM_NAME,executable_id,application_id
	 FROM apps.FND_CONCURRENT_PROGRAMS_VL
	 WHERE APPLICATION_ID>20000 or (APPLICATION_ID<20000 and created_by>1000) ) a,
       apps.fnd_application_vl b, apps.fnd_executables_vl c
 where a.application_id=b.application_id
   and a.executable_id=c.executable_id
   and rownum <100;

column Personalized_Form format a60
SELECT distinct f.user_function_name Personalized_Form, c.description, c.rule_type, c.enabled
  FROM apps.fnd_form_custom_rules c, apps.fnd_form_functions_vl f
 WHERE c.ID = f.function_id
 ORDER BY 1;
 
set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
