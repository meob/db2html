REM Program:	custom_ebs_app.sql
REM 		Oracle EBS Application Statistics PlugIn
REM Version:	1.0.2
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	15-AUG-14 mail@meo.bogliolo.name
REM		1.0.1 CVE-2015-0393 vulnerability check
REM		1.0.2 MGD (EBS Payables Master Generic Data Fix Diagnostic Analyzer) version

column description format a60
set lines 132
set define off

set heading off
select '<P><a id="cust0"></a><a id="ebs_app"></a><h2>Oracle eBS Application Statistics</h2><pre>' h from dual;

SELECT '<b>General Informations</b>' from dual;  
set heading on

select NAME HR_legalEntity
  from apps.hr_legal_entities
 order by ORGANIZATION_ID;

select count(distinct BUSINESS_GROUP_ID) HR_BusinessGroups,
       count(distinct ORGANIZATION_ID) Organizations
  from apps.hr_all_organization_units;

select PERIOD_SET_NAME GL_PeriodSet,
       DESCRIPTION Description
  from apps.gl_period_sets;

select count(*) GL_SetOfBooks 
  from apps.gl_sets_of_books;

select distinct CURRENCY_CODE GL_CurrencyCodes 
  from apps.gl_sets_of_books;

SELECT 'CVE-2015-0393' "Vulnerability", 'OracleEBS SYS.DUAL Public Privilege' "Description",
       decode(count(*),0,'Not affected','***Possibly affected***') "Result"
  FROM sys.dba_tab_privs WHERE owner = 'SYS' 
   AND table_name = 'DUAL'
   AND privilege != 'SELECT';

set heading off
SELECT '<b>Details</b>' from dual;  
set heading on

select count(*) AP_TaxCodes 
  from apps.ap_tax_codes_all;

select count(*) AP_Terms
  from apps.ap_terms;

select count(*) AR_vat_taxes, TAX_TYPE 
  from apps.ar_vat_tax_all_b
 group by TAX_TYPE;

select count(*) AR_vatTaxTl
  from apps.ar_vat_tax_all_tl;

select count(*) RA_Terms
  from apps.ra_terms;

select count(*) FND_LookupValues
  from apps.fnd_lookup_values;

select count(*) FND_FlexValueSets,
       DECODE(VALIDATION_TYPE, 'N', 'None', 'I', 'Independent', 'D', 'Dependent', 'F', 'Table',
              'U', 'Special', 'P', 'Pair', 'Y', 'Tx Independent', 'X Dependent', VALIDATION_TYPE) VALIDATION_TYPE
  from apps.fnd_flex_value_sets
 group by VALIDATION_TYPE
 order by 1 desc;

select count(*) FND_FormVl
  from apps.FND_FORM_VL;

select count(*) FND_CustomRules
  from apps.FND_FORM_CUSTOM_RULES;

select count(*) FND_Executables,
       DECODE(EXECUTION_METHOD_CODE, 'Q','SQL*Plus', 'P','Oracle Reports', 'I','PL/SQL SP', 
              'L','SQL*Loader', 'H','Host', 'A','Spawned', 'J','Java SP', 'R','SQLReport', 'X','Flexrpt',
              'S','Immediate', 'E', 'Perl', 'K', 'Java', 'M', 'Multi Language', 'F', 'FlexSQL',
              'B', 'Set Stage Function', EXECUTION_METHOD_CODE) EXECUTION_METHOD_CODE
  from apps.FND_EXECUTABLES
 group by EXECUTION_METHOD_CODE
 order by 1 desc;

select count(*) FND_ConcurrentRequests, nvl(resubmit_interval_unit_code, 'USER REQUEST') Frequency,
       resubmit_interval Interval
  from apps.fnd_concurrent_requests
 group by nvl(resubmit_interval_unit_code, 'USER REQUEST'), resubmit_interval
 order by 1 desc;

SELECT trunc(REQUESTED_START_DATE) "Concurrent Requests by date", count(*)
  FROM apps.FND_CONCURRENT_REQUESTS
 WHERE REQUESTED_START_DATE BETWEEN sysdate-7 AND sysdate
 group by rollup(trunc(REQUESTED_START_DATE));

column multi_org format a10
column multi_lingual format a10
column multi_currency format a10
select MULTI_ORG_FLAG multi_org, MULTI_LINGUAL_FLAG multi_lingual, MULTI_CURRENCY_FLAG multi_currency
  from apps.FND_PRODUCT_GROUPS ; 

column PRODUCT_GROUP_NAME format a40
select product_group_name,product_group_type,release_name
  from apps.fnd_product_groups;

column APPLICATION_NAME FORMAT A60
column PATCH_LEVEL FORMAT A20
SELECT substr(a.application_short_name, 1, 5) code,
       substr(t.application_name, 1, 50) application_name,
       p.product_version version,
       DECODE (p.status, 'I', 'Inst.', 'S', 'Shared', 'N/A') status,
       NVL(p.PATCH_LEVEL, 'n/a') PATCH_LEVEL, p.db_status
FROM   apps.fnd_application a,
       apps.fnd_application_tl t,
       apps.fnd_product_installations p
WHERE  a.application_id = p.application_id
AND    a.application_id = t.application_id
AND    t.language = USERENV('LANG')
order by 1;

SELECT name, text MGD_version
  FROM dba_source
 WHERE name = 'AP_GDF_DETECT_PKG'
   AND text like '%$Id%';

set heading off
select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
