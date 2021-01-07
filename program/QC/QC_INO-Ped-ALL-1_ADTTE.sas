**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADTTE.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-1-7
SAS version : 9.4
**************************************************************************;
proc datasets library=work kill nolist; quit;
options mprint mlogic symbolgen;
%macro GET_THISFILE_FULLPATH;
    %local _fullpath _path;
    %let _fullpath=;
    %let _path=;

    %if %length(%sysfunc(getoption(sysin)))=0 %then
      %let _fullpath=%sysget(sas_execfilepath);
    %else
      %let _fullpath=%sysfunc(getoption(sysin));
    &_fullpath.
%mend GET_THISFILE_FULLPATH;
%macro GET_DIRECTORY_PATH(input_path, directory_level);
    %let input_path_len=%length(&input_path.);
    %let temp_path=&input_path.;

    %do i = 1 %to &directory_level.;
      %let temp_len=%scan(&temp_path., -1, '\');
      %let temp_path=%substr(&temp_path., 1, %length(&temp_path.)-%length(&temp_len.)-1);
      %put &temp_path.;
    %end;
    %let _path=&temp_path.;
    &_path.
%mend GET_DIRECTORY_PATH;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_ADaM_LIBNAME.sas";
* Main processing start;
%let output_file_name=ADTTE;
libname libinput "&outputpath." ACCESS=READONLY;
%READ_CSV(&inputpath., pr);
%READ_CSV(&inputpath., ds);
data adsl;
    set libinput.adsl;
run;
proc sql noprint;
    create table temp_adtte_ds as
    select *
    from ds
    where (DSDECOD = "DEATH") or (EPOCH = "FOLLOW-UP");

    create table temp_adtte_ds_dd_pr_1 as
    select a.*, 
           case
             when b.PROCCUR is missing then "N"
             else b.PROCCUR
           end as AHSCT, b.PRSTDTC, b.PRTRT, b.PRCAT, a.DSSTDTC as ADT
    from temp_adtte_ds a left join (select * from pr where PRSPID="HSCT") b 
      on a.USUBJID = b.USUBJID
    order by USUBJID, DSSTDTC desc; 
quit;
data temp_adtte_ds_dd_pr_2;
    set temp_adtte_ds_dd_pr_1;
    by USUBJID descending DSSTDTC;
    if first.USUBJID then output;
run;
proc sql noprint;
    create table temp_adtte_os as
    select *, "Overall Survival" as PARAM, "OS" as PARAMCD,
           case
             when DSDECOD = "DEATH" then 0
             else 1
           end as CNSR 
    from temp_adtte_ds_dd_pr_2;
quit;
proc sql noprint;
    create table temp_adtte_nonr as
    select *, "Non-Relapse Mortality" as PARAM, "NONR" as PARAMCD,
           case
             when DSDECOD = "DEATH" then 2
             else 1
           end as CNSR 
    from temp_adtte_ds_dd_pr_2;
quit;
data temp_adtte_os_nonr;
    length PARAM $200. PARAMCD $200;
    set temp_adtte_os
        temp_adtte_nonr;
run;
proc sql noprint;
    create table temp_adtte_1 as
    select distinct a.*, b.SUBJID, b.TRTSDT, b.TRTEDT, b.RFICDT, b.DTHDT, b.SITEID, b.SITENM, 
           b.AGE, b.AGEGR1, b.AGEGR1N, b.AGEU, b.SEX, b.SEXN, b.RACE, b.ARM, b.TRT01P, b.TRT01PN,
           b.COMPLFL, b.FASFL, b.PPSFL, b.SAFFL, b.DLTFL, b.HSCT, b.TRTSDT as STARTDT,
           ADT - STARTDT + 1 as AVAL
    from temp_adtte_os_nonr a left join adsl b on a.USUBJID = b.USUBJID 
    where ADT ne . and STARTDT ne .
    order by USUBJID, PARAMCD, ADT;
quit;
data &output_file_name.;
    length STUDYID $200. USUBJID $200. SUBJID $200. TRTSDT 8. TRTEDT 8. RFICDT 8. DTHDT 8. 
           SITEID 8. SITENM $200. AGE 8. AGEGR1 $200. AGEGR1N 8. AGEU $200. SEX $200. SEXN 8. 
           RACE $200. ARM $200. TRT01P $200. TRT01PN 8. COMPLFL $200. FASFL $200. PPSFL $200.
           SAFFL $200. DLTFL $200. HSCT $200. AHSCT $200. PARAM $200. PARAMCD $200. STARTDT 8. 
           AVAL 8. ADT 8. CNSR 8.;
    set temp_adtte_1;
    label STUDYID='Study Identifier' USUBJID='Unique Subject Identifier' SUBJID='Subject Identifier for the Study' 
          TRTSDT='Date of First Exposure to Treatment' TRTEDT='Date of Last Exposure to Treatment' 
          RFICDT='Date of Informed Consent' DTHDT='Date of Death' SITEID='Study Site Identifier'
          SITENM='Study Site Name' AGE='Age' AGEGR1='Pooled Age Group 1' AGEGR1N='Pooled Age Group 1 (N)' 
          AGEU='Age Units' SEX='Sex' SEXN='Sex (N)' RACE='Race' ARM='Description of Planned Arm' 
          TRT01P='Planned Treatment for Period 01' TRT01PN='Planned Treatment for Period 01 (N)' 
          COMPLFL='Completers Population Flag' FASFL='Full Analysis Set Population Flag' 
          PPSFL='Per Protocol Set Population Flag' SAFFL='Safety Population Flag' DLTFL='DLT Population Flag' 
          HSCT='Prior HSCT' AHSCT='After HSCT' PARAM='Parameter' PARAMCD='Parameter Code'
          STARTDT='Time to Event Origin Date for Subject' AVAL='Analysis Value' ADT='Analysis Date' CNSR='Censor';
    format _ALL_;
    informat _ALL_;
    format TRTSDT YYMMDD10. TRTEDT YYMMDD10. RFICDT YYMMDD10. DTHDT YYMMDD10. STARTDT YYMMDD10. ADT YYMMDD10.;
    keep STUDYID USUBJID SUBJID TRTSDT TRTEDT RFICDT DTHDT SITEID SITENM AGE AGEGR1 AGEGR1N AGEU 
         SEX SEXN RACE ARM TRT01P TRT01PN COMPLFL FASFL PPSFL SAFFL DLTFL HSCT AHSCT PARAM PARAMCD 
         STARTDT AVAL ADT CNSR; 
run;
data libout.&output_file_name.;
    set &output_file_name.;
run;
%SDTM_FIN(&output_file_name.);
