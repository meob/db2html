sqlplus "/ as sysdba" < current.sql
cp -p current.lst current.`date +%Y%m%d-%H:%M:%S`.lst
