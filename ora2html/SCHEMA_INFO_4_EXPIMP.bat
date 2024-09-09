@ECHO OFF
rem  ---------------------------------------------------------------
rem  -- _DEBUG=[ON|OFF]
rem  ---------------------------------------------------------------
set _DEBUG=OFF

rem  ---------------------------------------------------------------
rem  -- _SHOWOUT=[ALWAYS|ONERROR]
rem  -- _SHOWLOG=[ALWAYS|ONERROR]
rem  ---------------------------------------------------------------
set _SHOWOUT=ONERROR
set _SHOWLOG=ONERROR


rem  ---------------------------------------------------------------
rem  -- parametri di input: label e valori di default
rem  ---------------------------------------------------------------

set lb_DB_SERVICE=Servizio db a cui fare connessione
set in_DB_SERVICE=ORCL

set lb_DB_SCHEMA_USR=Utente
set in_DB_SCHEMA_USR=SYSTEM

set lb_DB_SCHEMA_PWD=Password
set in_DB_SCHEMA_PWD=manager

set lb_USER_LIST=Elenco user nel formato "'USER1'[,'USER2',...]" (default tutti non di sistema)
set in_USER_LIST="select username from all_users"

set lb_COMPILE_INVALID_OBJECTS=Compilazione degli oggetti invalidi di ciascuno schema
set in_COMPILE_INVALID_OBJECTS="YES"

set lb_FILE_NAME_REPLACE_1_Before=Stringa da cercare nel path/nome datafile
set in_FILE_NAME_REPLACE_1_Before=""

set lb_FILE_NAME_REPLACE_1_After=Stringa sostitutiva nel path/nome datafile
set in_FILE_NAME_REPLACE_1_After=""


rem  ---------------------------------------------------------------
rem  -- impostazione nome script
rem  ---------------------------------------------------------------
set my_name=%~n0
REM se il decimo carattere della data e' "/" allora il formato e' Ddd MM/DD/YYYY oppure Ggg DD/MM/YYYY
REM altrimenti si assume formato MM/DD/YYYY oppure DD/MM/YYYY
set my_10thchar=%DATE:~9,1%
IF [%my_10thchar%] EQU [/] set my_datetime=%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%
IF NOT [%my_10thchar%] EQU [/] set my_datetime=%DATE:~-4%-%DATE:~0,2%-%DATE:~3,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%
set my_datetime=%my_datetime: =0%
set my_log=log\%my_name%_%my_datetime%

TITLE %my_name%

rem  ---------------------------------------------------------------
rem  -- lista parametri
rem  ---------------------------------------------------------------
echo Inserire i seguenti dati quando richiesti:
echo . %lb_DB_SERVICE% [%in_DB_SERVICE%]
echo . %lb_DB_SCHEMA_USR% [%in_DB_SCHEMA_USR%]
echo . %lb_DB_SCHEMA_PWD% [%in_DB_SCHEMA_PWD%]
echo . %lb_USER_LIST% [%in_USER_LIST%]
echo . %lb_COMPILE_INVALID_OBJECTS% [%in_COMPILE_INVALID_OBJECTS%]
echo . %lb_FILE_NAME_REPLACE_1_Before% [%in_FILE_NAME_REPLACE_1_Before%]
echo . %lb_FILE_NAME_REPLACE_1_After% [%in_FILE_NAME_REPLACE_1_After%]
rem  ---------------------------------------------------------------


rem  ---------------------------------------------------------------
rem  -- init log
rem  ---------------------------------------------------------------
set my_dir=%~dp0
set my_bat=%my_dir%%~nx0
set my_log=%my_dir%log\%~n0.log
echo NULL > %my_dir%NULL.txt
del /q %my_dir%NULL.txt
IF NOT EXIST log md log
IF EXIST (%my_log%) del /q %my_log%
echo ### INIZIO ESECUZIONE %~n0> %my_log%
echo ### dir = [%my_dir%]>>      %my_log%
echo ### bat = [%my_bat%]>>      %my_log%
echo ### log = [%my_log%]>>      %my_log%
echo ### >>                      %my_log%


echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo .
IF EXIST ..\..\_COMMON\Version.txt TYPE ..\..\_COMMON\Version.txt
echo.
IF EXIST Banner.txt TYPE Banner.txt
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo .


rem  ---------------------------------------------------------------
rem  -- input parametri - se non forniti valgono i default
rem  ---------------------------------------------------------------

set userin=
set /p userin="%lb_DB_SERVICE% [%in_DB_SERVICE%]-->"
IF /I NOT [%userin%] EQU [] set in_DB_SERVICE=%userin%

set userin=
set /p userin="%lb_DB_SCHEMA_USR% [%in_DB_SCHEMA_USR%]-->" 
IF /I NOT [%userin%] EQU [] set in_DB_SCHEMA_USR=%userin%

set userin=
set /p userin="%lb_DB_SCHEMA_PWD% [%in_DB_SCHEMA_PWD%]-->" 
IF /I NOT [%userin%] EQU [] set in_DB_SCHEMA_PWD=%userin%

set userin=
set /p userin="%lb_USER_LIST% [%in_USER_LIST%]-->"
IF /I NOT [%userin%] EQU [] set in_USER_LIST=%userin%

set userin=
set /p userin="%lb_COMPILE_INVALID_OBJECTS% [%in_COMPILE_INVALID_OBJECTS%]-->"
IF /I NOT [%userin%] EQU [] set in_COMPILE_INVALID_OBJECTS=%userin%

set userin=
set /p userin="%lb_FILE_NAME_REPLACE_1_Before% [%in_FILE_NAME_REPLACE_1_Before%]-->"
IF /I NOT [%userin%] EQU [] set in_FILE_NAME_REPLACE_1_Before=%userin%

set userin=
set /p userin="%lb_FILE_NAME_REPLACE_1_After% [%in_FILE_NAME_REPLACE_1_After%]-->"
IF /I NOT [%userin%] EQU [] set in_FILE_NAME_REPLACE_1_After=%userin%


rem  ---------------------------------------------------------------
rem  -- log parametri
rem  ---------------------------------------------------------------
echo ### PARAMETRI>> %my_log%
IF /I NOT [%_DEBUG%] EQU [OFF] echo ### Debug = [%_DEBUG%]>> %my_log%
echo ### %lb_DB_SERVICE% = [%in_DB_SERVICE%]>> %my_log%
echo ### %lb_DB_SCHEMA_USR% = [%in_DB_SCHEMA_USR%]>> %my_log%
echo ### %lb_USER_LIST% = [%in_USER_LIST%]>> %my_log%
echo ### %lb_COMPILE_INVALID_OBJECTS% = [%in_COMPILE_INVALID_OBJECTS%]>> %my_log%
echo ### %lb_FILE_NAME_REPLACE_1_Before% = [%in_FILE_NAME_REPLACE_1_Before%]>> %my_log%
echo ### %lb_FILE_NAME_REPLACE_1_After% = [%in_FILE_NAME_REPLACE_1_After%]>> %my_log%
echo ### >> %my_log%


rem  ---------------------------------------------------------------
rem  -- display parametri
rem  ---------------------------------------------------------------
echo.
echo ---------------------------------------------------------------
echo -- Revisione parametri forniti (escluse password) o calcolati:
IF /I NOT [%_DEBUG%] EQU [OFF] echo . Debug = [%_DEBUG%]
rem echo -- . log = [%my_log%]
echo . %lb_DB_SERVICE% = [%in_DB_SERVICE%]
echo . %lb_DB_SCHEMA_USR% = [%in_DB_SCHEMA_USR%]
echo . %lb_USER_LIST% = [%in_USER_LIST%]
echo . %lb_COMPILE_INVALID_OBJECTS% = [%in_COMPILE_INVALID_OBJECTS%]
echo . %lb_FILE_NAME_REPLACE_1_Before% = [%in_FILE_NAME_REPLACE_1_Before%]
echo . %lb_FILE_NAME_REPLACE_1_After% = [%in_FILE_NAME_REPLACE_1_After%]
echo ---------------------------------------------------------------


IF /I [%_DEBUG%] EQU [ON] (
echo DEBUG Esecuzione in DEBUG mode. Per ciascuno step e' possibile...
echo DEBUG . eseguire lo step premendo invio [default]
echo DEBUG . saltare allo step successivo premendo S
echo DEBUG . terminare l'esecuzione premendo E
)

IF /I [%_DEBUG%] EQU [ON] set /p userin="DEBUG Creazione .def - Premere un tasto per continuare-->" 

echo -- Impostazione parametri di esecuzione per SCHEMA_INFO_4_EXPIMP                                                                       >   SCHEMA_INFO_4_EXPIMP.def
echo --                                                                                                                                     >>  SCHEMA_INFO_4_EXPIMP.def
echo -- _USER_LIST l'elenco degli user di cui estrarre le informazioni                                                                      >>  SCHEMA_INFO_4_EXPIMP.def
echo -- l'elenco va racchiuso tra virgolette;                                                                                               >>  SCHEMA_INFO_4_EXPIMP.def
echo -- i nomi vanno indicati tenendo conto dei aratteri maiuscoli/minuscoli, racchiusi tra apici singoli e separati da virgole             >>  SCHEMA_INFO_4_EXPIMP.def
echo -- ad esempio: DEFINE _USER_LIST = "'USER1','USER2'"                                                                                   >>  SCHEMA_INFO_4_EXPIMP.def
echo -- per considerare tutti gli user, impostare: DEFINE _USER_LIST = "select username from all_users"                                     >>  SCHEMA_INFO_4_EXPIMP.def
echo DEFINE _USER_LIST = %in_USER_LIST%                                                                                                     >>  SCHEMA_INFO_4_EXPIMP.def
echo --                                                                                                                                     >>  SCHEMA_INFO_4_EXPIMP.def
echo -- _COMPILE_INVALID_OBJECTS consente di eseguire la compilazione degli oggetti invalidi di ciascuno schema prima di                    >>  SCHEMA_INFO_4_EXPIMP.def
echo -- proseguire con la loro elencazione                                                                                                  >>  SCHEMA_INFO_4_EXPIMP.def
echo DEFINE _COMPILE_INVALID_OBJECTS = %in_COMPILE_INVALID_OBJECTS%                                                                         >>  SCHEMA_INFO_4_EXPIMP.def
echo --                                                                                                                                     >>  SCHEMA_INFO_4_EXPIMP.def
echo -- _FILE_NAME_REPLACE... consentono di sostituire stringhe nei path/nomi dei datafile utilizzati nei comandi di creazione              >>  SCHEMA_INFO_4_EXPIMP.def
echo -- Da utilizzare neld caso in cui i path/nomi dei datafile del db di origine sono diversi dai corrispondenti del db di destinazione    >>  SCHEMA_INFO_4_EXPIMP.def
echo -- ..._Before è la stringa da cercare nel path/nome                                                                                    >>  SCHEMA_INFO_4_EXPIMP.def
echo -- ..._After è la stringa da inserire nel path/nome al posto della ..._Before                                                          >>  SCHEMA_INFO_4_EXPIMP.def
echo DEFINE _FILE_NAME_REPLACE_1_Before = %in_FILE_NAME_REPLACE_1_Before%                                                                   >>  SCHEMA_INFO_4_EXPIMP.def
echo DEFINE _FILE_NAME_REPLACE_1_After  = %in_FILE_NAME_REPLACE_1_After%                                                                    >>  SCHEMA_INFO_4_EXPIMP.def

IF /I [%_DEBUG%] EQU [ON] set /p userin="DEBUG Inizio esecuzione - Premere un tasto per continuare-->" 

set my_out=log\%my_name%_%in_DB_SCHEMA_USR%_%in_DB_SERVICE%.out
move %my_log% log\%my_name%_%in_DB_SCHEMA_USR%_%in_DB_SERVICE%.log >> %my_dir%NULL.txt
set my_log=log\%my_name%_%in_DB_SCHEMA_USR%_%in_DB_SERVICE%.log



:init_STEP_1
rem  ---------------------------------------------------------------
rem  -- esecuzione passo 1
rem  ---------------------------------------------------------------
echo -- Esecuzione passo 1 in corso...
set my_step=%my_name%
set my_step_required=Y
set my_dir_step=.\
set my_sql_step=%my_step%.sql
set my_out_step=out\%my_step%.lst
set my_par_step=%my_dir%%my_step%.par

echo UNUSED > %my_par_step%

echo ### INIZIO ESECUZIONE STEP %my_step%>> %my_log%
echo ###   dir: %my_dir_step%>> %my_log%
echo ###   sql: %my_sql_step%>> %my_log%
echo ###   out: %my_out_step%>> %my_log%
echo ### >> %my_log%

set userin=
IF /I [%_DEBUG%] EQU [ON] set /p userin="DEBUG step %my_step% - (S)alta (E)sci [esegui]-->"
IF /I [%_DEBUG%] EQU [ON] echo ### DEBUG %my_step% userin=[%userin%]>> %my_log%
IF /I [%userin%] EQU [E] goto chiude_STEP_1
IF /I [%userin%] EQU [S] goto chiude_STEP_1

cd %my_dir_step%
sqlplus  -L -S %in_DB_SCHEMA_USR%/%in_DB_SCHEMA_PWD%@%in_DB_SERVICE% @%my_sql_step% < %my_par_step% >> %my_dir%NULL.txt
set STEP_ERROR=%ERRORLEVEL%
echo ### FINE ESECUZIONE STEP %my_step% RESULT=[%STEP_ERROR%]>> %my_log%

:chiude_STEP_1
cd %my_dir%
rem del /q %my_sql_step% >> %my_dir%NULL.txt
IF /I NOT [%_DEBUG%] EQU [ON] del /q %my_par_step%
IF /I [%userin%] EQU [E] echo ### STEP %my_step% USCITA VOLUTA>> %my_log%
IF /I [%userin%] EQU [E] goto chiude
IF /I [%userin%] EQU [S] echo ### STEP %my_step% SKIP VOLUTO>> %my_log%
IF /I [%userin%%my_step_required%] EQU [SY] echo ### STEP %my_step% SKIP VOLUTO DA STEP RICHIESTO - USCITA FORZATA>> %my_log%
IF /I [%userin%%my_step_required%] EQU [SY] goto chiude
IF /I [%userin%%my_step_required%] EQU [SN] goto fine_STEP_1
SET ERRORI_STEP=N
rem IF %STEP_ERROR%==1 SET ERRORI_STEP=Y
FIND /I /C "ORA-" %my_dir_step%%my_out_step% >> %my_dir%NULL.txt
IF %ERRORLEVEL%==0 SET ERRORI_STEP=Y
FIND /I /C "SP2-" %my_dir_step%%my_out_step% >> %my_dir%NULL.txt
IF %ERRORLEVEL%==0 SET ERRORI_STEP=Y
IF %ERRORI_STEP%==N goto err_STEP_1_N

:err_STEP_1_Y
type %my_dir_step%%my_out_step% >> %my_out%
echo ### >> %my_log%
echo ### STEP %my_step% ESEGUITO CON ERRORI - Vedere %my_out% >> %my_log%
IF /I NOT [%_DEBUG%] EQU [ON] del /q %my_dir_step%%my_out_step%
echo ### >> %my_log%
IF %my_step_required%==N goto fine_STEP_1
echo ### STEP %my_step% RICHIESTO MA IN ERRORE - USCITA FORZATA >> %my_log%
echo ### >> %my_log%
goto chiude

:err_STEP_1_N
type %my_dir_step%%my_out_step% >> %my_out%
IF /I NOT [%_DEBUG%] EQU [ON] del /q %my_dir_step%%my_out_step%
echo ### >> %my_log%
echo ### STEP %my_step% ESEGUITO SENZA ERRORI>> %my_log%
echo ### >> %my_log%
:fine_STEP_1


:chiude
IF /I NOT [%_DEBUG%] EQU [ON] del /q %my_dir%NULL.txt
echo ### FINE ESECUZIONE %~n0>> %my_log%
SET ERRORI=N

ECHO.
echo -- conteggio errori ORA-...
FIND /I /C "ORA-" %my_log%
IF %ERRORLEVEL%==0 SET ERRORI=Y

ECHO.
echo -- conteggio errori SP2-...
FIND /I /C "SP2-" %my_log%
IF %ERRORLEVEL%==0 SET ERRORI=Y

IF %ERRORI%==N goto err_N


:err_Y
ECHO.
echo -- esecuzione terminata con errori
ECHO.
SET SHOWLOG=N
SET SHOWOUT=N
IF /I [%_SHOWLOG%] EQU [ONERROR] SET SHOWLOG=Y
IF /I [%_SHOWLOG%] EQU [ALWAYS] SET SHOWLOG=Y
IF /I [%_DEBUG%] EQU [ON] SET SHOWLOG=Y
IF /I [%_SHOWOUT%] EQU [ONERROR] SET SHOWOUT=Y
IF /I [%_SHOWOUT%] EQU [ALWAYS] SET SHOWOUT=Y
IF /I [%_DEBUG%] EQU [ON] SET SHOWOUT=Y
GOTO :show


:err_N
ECHO.
echo -- esecuzione terminata senza errori
ECHO.
SET SHOWLOG=N
SET SHOWOUT=N
IF /I [%_SHOWOUT%] EQU [ALWAYS] SET SHOWOUT=Y
IF /I [%_DEBUG%] EQU [ON] SET SHOWOUT=Y
IF /I [%_SHOWLOG%] EQU [ALWAYS] SET SHOWLOG=Y
IF /I [%_DEBUG%] EQU [ON] SET SHOWLOG=Y
GOTO :show


:show
IF /I [%SHOWOUT%] EQU [Y] notepad %my_out%
IF /I [%SHOWLOG%] EQU [Y] notepad %my_log%
GOTO :eof



EXIT /B