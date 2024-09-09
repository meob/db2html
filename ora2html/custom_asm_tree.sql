REM Program:	custom_asm_tree.sql
REM 		Oracle ASM Tree PlugIn
REM Version:	1.0.2
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             https://meoshome.it.eu.org/
REM		
REM Date:    	01-APR-14 mail@meo.bogliolo.name

column full_path format a60 trunc
column file_type format a13 trunc
column bytes format 999,999,999,999,999
column space_alloc format 999,999,999,999,999
set linesize 132
set heading off

select '<P><a id="asm_tree"></a><h2>ASM Object Tree</h2>' h from dual;
set heading on
select concat('+'||gname, sys_connect_by_path(aname, '/')) full_path,
       file_type, bytes, space_alloc, redundancy, system_created, alias_directory dir
from ( select b.name gname, a.parent_index pindex, a.name aname,
              a.reference_index rindex , a.system_created, a.alias_directory,
              c.type file_type, c.bytes bytes, c.space space_alloc, c.REDUNDANCY
       from v$asm_alias a, v$asm_diskgroup b, v$asm_file c
       where a.group_number = b.group_number
             and a.group_number = c.group_number(+)
             and a.file_number = c.file_number(+)
             and a.file_incarnation = c.incarnation(+)
     )
start with (mod(pindex, power(2, 24))) = 0
            and rindex in
                ( select a.reference_index
                  from v$asm_alias a, v$asm_diskgroup b
                  where a.group_number = b.group_number
                        and (mod(a.parent_index, power(2, 24))) = 0
                )
connect by prior rindex = pindex;

set heading off
