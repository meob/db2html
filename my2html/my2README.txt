MY2HTML Readme File

my2html is an easy and flexible tool to collect MySQL DBs configuration
my2html works on MySQL 5.x but version specific scripts are also available


Usage:
1) update the file my2html.sh to change USR, PSS, HST, and PRT variables accordingly to Your configuration
2) sh my2html.sh	# Execute the report and generate an HTML file  


Notes:
There are version specific scripts:
my2html.sh		# Works with all MySQL versions, by default uses MySQL Community Production Version 5.7 scripts

my2html.80.sql		# Best with MySQL >=8.0. Differences in the data dictionary
my2html.57.sql		# Best with MySQL ==5.7. 
my2html.56.sql		# Best with MySQL ==5.6. 	
my2html.55.sql		# Best with MySQL ==5.5. 
my2html.51.sql		# Best with MySQL ==5.1. 
my2html.50.sql		# Best with MySQL ==5.0. 
my2html.323.sh		# MySQL 3.23.x and newer. Less information available.
my2html.103.sql		# Best with MariaDB 10.3+.
my2html.int.sql		# Internal statistics for MySQL 5.6+ 

Some old scripts use the default TEST database to create a temporary view.


License:

Copyright 2006-2024 mail@meo.bogliolo.name 

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
