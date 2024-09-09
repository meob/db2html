-- Program: pgis2html.sql
-- Info:    PostGIS report in HTML
--          Should work with PostgreSQL > 7.0 and PostGIS > 1.0.0
-- Creation date:    1-APR-11
-- Version: 1.0.1  1-JAN-12
-- Author:  Bartolomeo Bogliolo (aka meo) mail@meo.bogliolo.name
-- Usage:   psql [-U USERNAME] [DBNAME] < pgis2html.sql
-- Notes:   1-APR-11 mail@meo.bogliolo.name
--          First version based on pg2html.sql (PostgreSQL report in HTML)
--          1-JAN-12 mail@meo.bogliolo.name
--          HTML5, Few graphical changes

\pset tuples_only
\pset fieldsep ' '
\a
\o pgis.htm

select '<!doctype html><html> <head><meta charset="UTF-8"><title>pgis2html - PostGIS Statistics</title></head><body>' as info;
select '<h1 align=center>PostGIS - '||current_database()||'<br></h1>' as info;

select '<P><A NAME="top"></A>' as info;
select '<p>Table of contents:' as info;
select '<table><tr><td><ul>' as info;
select '<li><A HREF="#status">Summary Status</A></li>' as info;
select '<li><A HREF="#ver">Versions</A></li>' as info;
select '<li><A HREF="#dbs">Database</A></li>' as info;
select '<li><A HREF="#spa">GIS Objects</A></li>' as info;
select '<li><A HREF="#obj">Schema/Object Matrix</A></li>' as info;
select '<li><A HREF="#usg">Space Usage</A></li>' as info;
select '<li><A HREF="#big">Biggest Objects</A></li>' as info;
select '<li><A HREF="#ref">Spatial Reference Systems</A></li>' as info;
select '<li><A HREF="#spd">GIS Objects Details</A></li>' as info;
select '<li><A HREF="#par">Parameters</A></li>' as info;
select '</ul></table><p><hr>' as info;
 
select '<P>Statistics generated on: '|| current_date || ' ' ||localtime
as info;

select 'on database: <b>'||current_database()||'</b>' as info;
select 'by user: '||user as info;

select 'using: <I><b>pgis2html.sql</b> v.1.0.1b' as info;
select '<br>Software by ' as info;
select '<A HREF="https://meoshome.it.eu.org">Meo Bogliolo</A></I><p>'
as info;
 
select '<hr><P><A NAME="status"></A>' as info;
select '<P><table border="2"><tr><td><b>Summary</b></td></tr>' as info;
select '<tr><td><b>Item</b>', '<td><b>Value</b>' as info;

select '<tr><td>'||' PostgreSQL Version :', '<! 10>',
 '<td>'||substring(version() for  position('on' in version())-1)
union
select '<tr><td>'||' PostGIS Version :', '<! 20>',
 '<td>'||substring(PostGIS_version() for  position(' ' in PostGIS_version())-1)
union
select '<tr><td>'||' DB Size (MB):', '<! 30>',
 '<td align="right">'||trunc(sum(pg_database_size(datname))/(1024*1024))
from pg_database
where datname=current_database()
union
select '<tr><td>'||' Databases :', '<! 40>', '<td align="right">'||count(*)
from pg_database where not datistemplate
union
select '<tr><td>'||' Tablespaces :', '<! 50>', '<td align="right">'||count(*)
from pg_tablespace
union
select '<tr><td>'||' GIS Objects :', '<! 60>', '<td align="right">'||count(*)
from geometry_columns
union
select '<tr><td>'||' GiST Indexes :', '<! 70>', '<td align="right">'||count(*)
from pg_index, pg_class, pg_roles
where pg_index.indrelid=pg_class.oid
and relowner=pg_roles.oid
and upper(pg_get_indexdef(indexrelid)) like '%GIST%'
order by 2;
select '</table><p><hr>' as info;


select '<P><A NAME="ver"></A>' as info;
select '<P><table border="2"><tr><td><b>Software Versions</b></td></tr>' as info;
select '<tr><td><b>Component</b><td><b>Version Details</b></td></tr>' as info;
select '<tr><td>PostgreSQL<td>'||version()||'</tr></td>'
 union
select '<tr><td>PostGIS<td>'||PostGIS_version()||'</tr></td>'
 union
select '<tr><td>PostGIS full<td>'||PostGIS_full_version()||'</tr></td>'
order by 1 desc;
select '</table><p><hr>' as info;

select '<P><A NAME="dbs"></A>' as info;
select '<P><table border="2"><tr><td><b>Database</b></td></tr>' as info;
select '<tr><td><b>Name</b>',
 '<td><b>Size</b>',
 '<td><b>UR Size</b>'
as info;
select '<tr><td>'||datname,
 '<td align=right>'||pg_database_size(datname),
 '<td align=right>'||pg_size_pretty(pg_database_size(datname))
from pg_database
where datname=current_database();
select '</table><p><hr>' as info;

select '<P><A NAME="spa"></A>' as info;
select '<P><table><tr><td><table border="2"><tr><td><b>GIS Tables</b></td></tr>' as info;
select '<tr><td><b>Schema</b>', '<td><b>Count</b>'
as info;
select '<tr><td>'||f_table_schema,
 '<td align=right>'|| count(*)
from geometry_columns
group by f_table_schema
order by f_table_schema;
select '<tr><td>TOTAL',
 '<td align=right>'|| count(*)
from geometry_columns;
select '</table>' as info;

select '<td><table border="2"><tr><td><b>GiST Indexes</b></td></tr>' as info;
select '<tr><td><b>Schema</b>','<td><b>Count</b>'
as info;
select '<tr><td>'||rolname,
 '<td align=right>'|| count(*)
from pg_index, pg_class, pg_roles
where pg_index.indrelid=pg_class.oid
and relowner=pg_roles.oid
and upper(pg_get_indexdef(indexrelid)) like '%GIST%'
group by rolname
order by rolname;
select '<tr><td>TOTAL',
 '<td align=right>'|| count(*)
from pg_index, pg_class, pg_roles
where pg_index.indrelid=pg_class.oid
and relowner=pg_roles.oid
and upper(pg_get_indexdef(indexrelid)) like '%GIST%';
select '</table></table><p>' as info;

select '<P><table border="2"><tr><td><b>GIS Objects</b></td></tr>' as info;
select '<tr><td><b>Schema</b>',
 '<td><b>Type</b>', '<td><b>Dim.</b>', '<td><b>Count</b>'
as info;
select '<tr><td>'||f_table_schema,
 '<td>'||type, '<td align=right>'||coord_dimension, '<td align=right>'|| count(*)
from geometry_columns
group by f_table_schema, type, coord_dimension
order by f_table_schema, type, coord_dimension;
select '<tr><td>TOTAL',
 '<td>', '<td align=right>', '<td align=right>'|| count(*)
from geometry_columns;
select '</table><p><hr>' as info;

select '<P><A NAME="obj"></A>' as info;
select '<P><table><tr><td><table border="2"><tr><td><b>Schema/Object Matrix</b></td></tr>' as info;
select '<tr><td><b>Owner</b>',
 '<td><b> Table</b>',
 '<td><b> Index</b>',
 '<td><b> View</b>',
 '<td><b> Sequence</b>',
 '<td><b> Composite</b>',
 '<td><b> TOAST</b>'
as info;
select '<tr><td>'||rolname,
 '<td align="right">'||sum(case when relkind='r' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='i' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='v' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='S' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='c' THEN 1 ELSE 0 end),
 '<td align="right">'||sum(case when relkind='t' THEN 1 ELSE 0 end)
from pg_class, pg_roles
where relowner=pg_roles.oid
group by rolname
order by rolname;
select '</table>' as info;

select '<A NAME="usg"></A>' as info;
select '<td><table border="2"><tr><td><b>Space Usage</b></td></tr>' as info;
select '<tr><td><b>Owner</b>',
 '<td><b>Tables rows</b>',
 '<td><b>Tables MBytes</b>',
 '<td><b>Indexes MBytes</b>'
as info;
select '<tr><td>'||rolname,
 '<td align="right">'||to_char(sum(case when relkind='r' THEN reltuples ELSE 0 end),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='r' THEN relpages *8/1024 ELSE 0 end)),'999G999G999'),
 '<td align="right">'||to_char(trunc(sum(case when relkind='i' THEN relpages *8/1024 ELSE 0 end)),'999G999G999')
from pg_class, pg_roles
where relowner=pg_roles.oid
group by rolname
order by rolname;
select '</table></table><p><hr>' as info;

select '<P><A NAME="big"></A>'  as info;
select '<P><table><tr><td><table border="2"><tr><td><b>Biggest GIS Objects</b></td></tr>'
 as info;
select '<tr><td><b>Object</b>',
 '<td><b>Type</b>',
 '<td><b>Owner</b>',
 '<td><b>Bytes</b>',
 '<td><b>Rows</b>'
as info;
select '<tr><td>'||relname,
 '<td>'||case WHEN relkind='r' THEN 'Table' 
    WHEN relkind='i' THEN 'Index'
    WHEN relkind='t' THEN 'TOAST Table'
    ELSE relkind||'' end,
 '<td>'||rolname,
 '<td align=right>'||to_char(relpages::INT8*8*1024,'999G999G999G999'),
 '<td align=right>'||to_char(reltuples,'999G999G999G999')
from pg_class, pg_roles, geometry_columns
where relowner=pg_roles.oid
 and geometry_columns.f_table_schema=rolname
 and geometry_columns.f_table_name=relname
order by relpages desc, reltuples desc
limit 10;
select '</table>' as info;

select '<td><table border="2"><tr><td><b>Biggest Objects</b></td></tr>'
 as info;
select '<tr><td><b>Object</b>',
 '<td><b>Type</b>',
 '<td><b>Owner</b>',
 '<td><b>Bytes</b>',
 '<td><b>Rows</b>'
as info;
select '<tr><td>'||relname,
 '<td>'||case WHEN relkind='r' THEN 'Table' 
    WHEN relkind='i' THEN 'Index'
    WHEN relkind='t' THEN 'TOAST Table'
    ELSE relkind||'' end,
 '<td>'||rolname,
 '<td align=right>'||to_char(relpages::INT8*8*1024,'999G999G999G999'),
 '<td align=right>'||to_char(reltuples,'999G999G999G999')
from pg_class, pg_roles
where relowner=pg_roles.oid
order by relpages desc, reltuples desc
limit 10;
select '</table></table><p><hr>' as info;

select '<P><A NAME="ref"></A>' as info;
select '<P><table border="2"><tr><td><b>Used SRID (SRS Identifier)</b></td></tr>' as info;
select '<tr><td><b>SRID</b>','<td><b>Projection</b>','<td><b>Text</b>','<td><b>Count</b>'
as info;
select '<tr><td>'||geometry_columns.srid, '<td>'||substr(proj4text,0,51), '<td>'||substr(srtext,0,51), '<td align=right>'||count(*)
from spatial_ref_sys, geometry_columns
where spatial_ref_sys.srid=geometry_columns.srid
group by geometry_columns.srid, proj4text, srtext
order by count(*) desc;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Spatial Reference Systems</b></td></tr>' as info;
select '<tr><td><b>Projection</b>',
  '<td><b>Count</b>'
as info;
select '<tr><td>'||substr(proj4text, 1,10), '<td align=right>'||count(*)
from spatial_ref_sys
group by substr(proj4text, 1,10)
union
select '<tr><td>TOTAL', '<td align=right>'||count(*)
from spatial_ref_sys
order by 1;
select '</table><p>' as info;

select '<P><table border="2"><tr><td><b>Default Geography SRID</b></td></tr>' as info;
select '<tr><td><b>SRID</b>','<td><b>Projection</b>','<td><b>Full Text</b>'
as info;
select '<tr><td>'||srid, '<td>'||proj4text, '<td>'||replace(srtext,',',', ')
from spatial_ref_sys
where srid=4326;
select '</table><p><hr>' as info;

select '<P><A NAME="func"></A>' as info;
select '<P><table border="2"><tr><td><b>PostGIS Functions</b></td></tr>' as info;
select '<tr><td><b>Owner</b>','<td><b>Prefix</b>','<td><b>Language</b>','<td><b>Count</b>'
as info;
select '<tr><td>'||o.rolname, '<td>'||substr(proname, 1, 3),  '<td>'||l.lanname,'<td align="right">'||count(*)
from pg_proc f, pg_authid o, pg_language l
where f.proowner=o.oid
and f.prolang=l.oid
and substr(proname, 1, 3) in ('st_', 'box', 'geo', 'pos')
group by o.rolname, l.lanname, substr(proname, 1, 3)
order by o.rolname, substr(proname, 1, 3), l.lanname;
select '<tr><td> TOTAL', '<td>',  '<td>','<td align="right">'||count(*)
from pg_proc f, pg_authid o, pg_language l
where f.proowner=o.oid
and f.prolang=l.oid
and substr(proname, 1, 3) in ('st_', 'box', 'geo', 'pos');
select '</table><p><hr>' as info;

select '<P><A NAME="spd"></A>' as info;
select '<P><table border="2"><tr><td><b>Spatial Objects Details</b></td></tr>' as info;
select '<tr><td><b>Schema</b>',
 '<td><b>Table</b>', '<td><b>Column</b>', '<td><b>Type</b>', '<td><b>Dim.</b>', '<td><b>SRID</b>'
as info;
select '<tr><td>'||f_table_schema,
 '<td>'||f_table_name, '<td>'||f_geometry_column, '<td>'||type, '<td>'||coord_dimension, '<td>'||srid
from geometry_columns
order by f_table_schema, f_table_name;
select '</table><p><hr>' as info;

-- GiST indexes details
-- select pg_get_indexdef(indexrelid), pg_class.relname,rolname
-- from pg_index, pg_class, pg_roles
-- where pg_index.indrelid=pg_class.oid
-- and relowner=pg_roles.oid
-- and upper(pg_get_indexdef(indexrelid)) like '%GIST%'

select '<P><A NAME="par"></A>' as info;
select '<P><table border="2"><tr><td><b>PostGIS related parameters</b></td></tr>' as info;
select '<tr><td><b>Parameter</b>',
 '<td><b>Value</b>',
 '<td><b>Min</b>',
 '<td><b>Max</b>',
 '<td><b>Description</b>'
as info;
select '<tr><td>',name,'<td align=right>',setting,
   '<td align=right>',min_val,'<td align=right>',max_val,
   '<td>',short_desc
from pg_settings
where name in ('checkpoint_segment_size','constraint_exclusion','shared_buffers','work_mem','maintenance_work_mem',
               'max_connections','sort_mem','vacuum_mem','max_fsm_pages','max_fsm_relations','wal_buffers',
               'checkpoint_segments','effective_cache_size','random_page_cost')
order by name; 
select '</table><p><hr>' as info;
 

select '<P>Statistics generated on: '|| current_date || ' ' ||localtime
as info;

select '<br>More info on' as info;
select '<A HREF="https://meoshome.it.eu.org">this site</A>' as info;
select 'or contact' as info;
select '<A HREF="mailto:mail@meo.bogliolo.name">Meo</A>.<p></body></html>' as info;
