/* Query to find out if any patch except localisation patch is applied or not, if applied, that what all drivers it contain and time of it's application*/
select A.APPLIED_PATCH_ID, A.PATCH_NAME, A.PATCH_TYPE, B.PATCH_DRVIER_ID, B.DRIVER_FILE_NAME, B.ORIG_PATCH_NAME, B.CREATION_DATE, B.PLATFORM, B.SOURCE_CODE, B.CREATIONG_DATE, B.FILE_SIZE, B.MERGED_DRIVER_FLAG, B.MERGE_DATE from AD_APPLIED_PATCHES A, AD_PATCH_DRIVERS B where A.APPLIED_PATCH_ID = B.APPLIED_PATCH_ID and A.PATCH_NAME = '<patch number>'
     
/* To know that if the patch is applied successfully, applied on both node or not, start time of patch application and end time of patch application, patch top location , session id ... patch run id */
select D.PATCH_NAME, B.APPLICATIONS_SYSTEM_NAME, B.INSTANCE_NAME, B.NAME, C.DRIVER_FILE_NAME, A.PATCH_DRIVER_ID, A.PATCH_RUN_ID, A.SESSION_ID, A.PATCH_TOP, A.START_DATE, A.END_DATE, A.SUCCESS_FLAG, A.FAILURE_COMMENTS from AD_PATCH_RUNS A, AD_APPL_TOPS B, AD_PATCH_DRVIERS C, AD_APPLIED_PATCHES D where A.APPL_TOP_ID = B.APPL_TOP_ID AND A.PATCH_DRIVER_ID = C.PATCH_DRIVER_ID and C.APPLIED_PATCH_ID = D.APPLIED_PATCH_ID and A.PATCH_DRIVER_ID in (select PATCH_DRIVER_ID from AD_PATCH_DRIVERS where APPLIED_PATCH_ID in (select APPLIED_PATCH_ID from AD_APPLIED_PATCHES where PATCH_NAME = '<patch number>')) ORDER BY 3;
     
/* To find the latest application version */
select ARU_RELEASE_NAME||'.'||MINOR_VERSION||'.'||TAPE_VERSION version, START_DATE_ACTIVE updated,ROW_SOURCE_COMMENTS "how it is done", BASE_RELEASE_FLAG "Base version" FROM AD_RELEASES where END_DATE_ACTIVE IS NULL 

/* to find the base application version */
select ARU_RELEASE_NAME||'.'||MINOR_VERSION||'.'||TAPE_VERSION version, START_DATE_ACTIVE when updated, ROW_SOURCE_COMMENTS "how it is done" from AD_RELEASES where BASE_RELEASE_FLAG = 'Y'
 
/* To find all available application version */
select ARU_RELEASE_NAME||'.'||MINOR_VERSION||'.'||TAPE_VERSION version, START_DATE_ACTIVE when updated, END_DATE_ACTIVE "when lasted", CASE WHEN BASE_RELEASE_FLAG = 'Y' Then 'BASE VERSION' ELSE 'Upgrade' END "BASE/UPGRADE", ROW_SOURCE_COMMENTS "how it is done" from AD_RELEASES
     
/* To get file version of any application file which is changed through patch application */
select A.FILE_ID, A.APP_SHORT_NAME, A.SUBDIR, A.FILENAME, max(B.VERSION) from AD_FILES A, AD_FILE_VERSIONS B where A.FILE_ID = B.FILE_ID and B.FILE_ID = 86291 group by A.FILE_ID, A.APP_SHORT_NAME, A.SUBDIR, A.FILENAME 

 /* To get information related to how many time driver file is applied for bugs */
select * from AD_PATCH_RUN_BUGS where BUG_ID in (select BUG_ID from AD_BUGS where BUG_NUMBER = '<BUG NUMBER>'
 
/* To find latest patchset level for module installed */
select APP_SHORT_NAME, max(PATCH_LEVEL) from AD_PATCH_DRIVER_MINIPKS GROUP BY APP_SHORT_NAME
 
/* To find what is being done by the patch */
select A.BUG_NUMBER "Patch Number", B. PATCh_RUN_BUG_ID "Run Id",D.APP_SHORT_NAME appl_top, D.SUBDIR, D.FILENAME, max(F.VERSION) latest, E.ACTION_CODE action from AD_BUGS A, AD_PATCH_RUN_BUGS B, AD_PATCH_RUN_BUG_ACTIONS C, AD_FILES D, AD_PATCH_COMMON_ACTIONS E, AD_FILE_VERSIONS F where A.BUG_ID = B.BUG_ID and B.PATCH_RUN_BUG_ID = C.PATCH_RUN_BUG_ID and C.FILE_ID = D.FILE_ID and E.COMMON_ACTION_ID = C.COMMON_ACTION_ID and D.FILE_ID = F.FILE_ID and A.BUG_NUMBER = '<patch number>' and B.PATCH_RUN_BUG_ID = ' < > ' and C.EXECUTED_FLAG = 'Y' GROUP BY A.BUG_NUMBER, B.PATCH_RUN_BUG_ID, D. APP_SHORT_NAME, D>SUBDIR, D.FILENAME, E.ACTION_CODE

/* To find Merged patch Information from database in Oracle Applications */
select bug_number from ad_bugs where bug_id in ( select bug_id from ad_comprising_patches where patch_driver_id =(select patch_driver_id from ad_patch_drivers where applied_patch_id =&n) ); 