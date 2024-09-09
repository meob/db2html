# db2html

db2html contains powerful SQL scripts that collect database configuration from most common RDBMS:  
+ Oracle  
+ MySQL  
+ PostgreSQL   
+ DB2
The scripts are periodically upgraded in order to use the newest functionality from RDBMS
while maintaining backward compatibility (eg. Oracle 12c, Postgres 9.2, PostGIS 2.0, MySQL 5.5, ...)

Each database has its own .zip file but the structure is the same:
there are simple and easy to customize SQL scripts that discover
the Database configuration and generate a comprensive HTML report.
The only user requirement is that the user using the script has
the right environment to connect to the database.
db2html contains very useful scripts for DBAs and database power users.

## ora2html - Oracle
ora2html.zip contains several useful Oracle DBA scripts:
-  ora2html.sql: is an easy and flexible script to collect Oracle RDBMS Configuration.  
   ora2html.sql has been designed to work on all Oracle RDBMS releases since 7.1.
   ora2html.sql supports all Oracle versions from 7.3.4 (with few complaints) to 12c
-  custom.sql: ora2html Plug-in script launcher (eg. RAC, Data Guard, ASM, Oracle 12c, ...)
-  whodo.sql: current database usage
-  dg2html.sql: Data Guard Standby Instance configuration
-  whodoRAC.sql: current database usage for RAC instances


The zip file contains other useful scripts like:  
-  ora2fast is similar to ora2html but simpler, faster, and  with less complaints on older Oracle versions  
-  oas2html to extract useful information from Oracle Application Server DBs (OAS)   
-  ebs2html to extract useful information from Oracle Applications (EBS)   
-  emp7 is a simple Oracle CPU performance benchmark  
-  whodo a simple script to extract current DB status (eg. sessions, locks, ...)
-  whodoRAC extracts current DB status on RAC environments
-  dg2html to collect current status from a Data Guard secondary node (Standby)

### Usage
> sqlplus / as sysdba  
> SQL> start ora2html


## my2html - MySQL
my2html is an easy and flexible tool to collect MySQL DBs configuration
my2html works fine on MySQL >= 5.0 but version specific scripts are also available (eg. for 3.23)
The script uses the default test database to create temporary views.

### Usage
> vi my2html.sh		# If Your need to change the password  
> sh my2html.sh		# Execute the report and generate an HTML file  


## pg2html - PostgreSQL
pg2html is an easy and flexible tool to collect PostgreSQL configuration
pg2html has been designed to work on all PostgreSQL releases and had been tested up to 9.2

### Usage
Login as postgres user then  
> psql [database] < pg2html.sql


## db2html - DB2
db2html is an easy and flexible tool to collect DB2 configuration
db2html has been designed to work on DB2 9.7 releases or newer
db2html in a Beta version script

### Usage
Login as db2admin user then  
> clpplus db2admin@localhost:50000/sample @db2html.sql



# License
Copyright 1996-2024 mail@meo.bogliolo.name 

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
