REM Program:	custom_tde.sql
REM 		Oracle TDE (Transparent Data Encryption) PlugIn
REM Version:	1.0.1
REM Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
REM             http://www.xenialab.it/meo/web/index5.htm
REM		
REM Date:    	14-FEB-17 mail@meo.bogliolo.name
REM		First release, (1.0.1) better formatting

column owner format a12
column table_name format a20
column total_size format 999,999,999,999,999
column distrib format a8 trunc
column WRL_PARAMETER format a50
column ts_name format a30
column encr_blk format 999,999,999
column decr_blk format 999,999,999

set lines 132
set define off

set heading off
select '<P><a id="custO"></a><a id="tde"></a><h2>Oracle TDE</h2>' h from dual;

SELECT '<h3>Wallet</h3><pre>' from dual;
set heading on
select *
  from V$WALLET;
set heading off

SELECT '</pre><h3>Encryption Wallet</h3><pre>' from dual;
set heading on
select *
  from V$ENCRYPTION_WALLET;
set heading off

SELECT '</pre><h3>Encrypted Tablespaces</h3><pre>' from dual;
set heading on
rem status, key_version since 12cR2
select e.ts#, t.name ts_name, e.ENCRYPTIONALG, e.ENCRYPTEDTS,
       e.MASTERKEYID, e.BLOCKS_ENCRYPTED encr_blk, e.BLOCKS_DECRYPTED decr_blk,
       t.ENCRYPT_IN_BACKUP, t.INCLUDED_IN_DATABASE_BACKUP bck
  from V$ENCRYPTED_TABLESPACES e, V$TABLESPACE t
 where e.TS#=t.TS#;
set heading off

SELECT '</pre><h3>Encrypted Columns</h3><pre>' from dual;
set heading on
rem owner, table_name, column_name, encryption_alg, salt, INTEGRITY_ALG
select *
  from DBA_ENCRYPTED_COLUMNS;
set heading off

select '</pre><p><a href="#top">Top</a> <a href="#custMenu">Plugins</a><hr><p>' from dual;
