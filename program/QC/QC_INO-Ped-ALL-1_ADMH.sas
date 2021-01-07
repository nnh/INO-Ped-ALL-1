**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADMH.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-12-28
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
%let output_file_name=ADMH;
libname libinput "&outputpath." ACCESS=READONLY;
%READ_CSV(&inputpath., mh);
data adsl;
    set libinput.adsl;
run;
proc sql noprint;
    create table temp_admh_1 as
    select b.STUDYID, b.USUBJID, b.SUBJID, b.TRTSDT, b.TRTEDT, b.RFICDT, b.DTHDT, b.SITEID, 
           b.SITENM, b.AGE, b.AGEGR1, b.AGEGR1N, b.AGEU, b.SEX, b.SEXN, b.RACE, b.ARM, b.TRT01P, 
           b.TRT01PN, b.COMPLFL, b.FASFL, b.PPSFL, b.SAFFL, b.DLTFL, a.MHSEQ, a.MHTERM, a.MHDECOD, 
           a.MHCAT, a.MHENRTPT, a.MHENTPT
    from (select * from mh where MHCAT="GENERAL") a left join adsl b on a.USUBJID = b.USUBJID
    order by mhseq;
quit;
data &output_file_name.;
    length STUDYID $200. USUBJID $200. SUBJID $200. TRTSDT 8. TRTEDT 8. RFICDT 8. DTHDT 8. SITEID 8.
           SITENM $200. AGE 8. AGEGR1 $200. AGEGR1N 8. AGEU $200. SEX $200. SEXN 8. RACE $200. 
           ARM $200. TRT01P $200. TRT01PN 8. COMPLFL $200. FASFL $200. PPSFL $200. SAFFL $200. 
           DLTFL $200. MHSEQ 8. MHTERM $200. MHDECOD $200. MHCAT $200. MHENRTPT $200. MHENTPT $200.; 
    set temp_admh_1;
    label STUDYID='Study Identifier' USUBJID='Unique Subject Identifier' 
          SUBJID='Subject Identifier for the Study' TRTSDT='Date of First Exposure to Treatment' 
          TRTEDT='Date of Last Exposure to Treatment' RFICDT='Date of Informed Consent' 
          DTHDT='Date of Death' SITEID='Study Site Identifier' SITENM='Study Site Name' AGE='Age' 
          AGEGR1='Pooled Age Group 1' AGEGR1N='Pooled Age Group 1 (N)' AGEU='Age Units' SEX='Sex' 
          SEXN='Sex (N)' RACE='Race' ARM='Description of Planned Arm' 
          TRT01P='Planned Treatment for Period 01' TRT01PN='Planned Treatment for Period 01 (N)' 
          COMPLFL='Completers Population Flag' FASFL='Full Analysis Set Population Flag' 
          PPSFL='Per Protocol Set Population Flag' SAFFL='Safety Population Flag' 
          DLTFL='DLT Population Flag' MHSEQ='Sequence Number' 
          MHTERM='Reported Name of Drug, Med, or Therapy' MHDECOD='Standardized Medication Name' 
          MHCAT='Category for Medication' MHENRTPT='End Relative to Reference Time Point' 
          MHENTPT='End Reference Time Point';
    format _ALL_;
    informat _ALL_;
    format TRTSDT YYMMDD10. TRTEDT YYMMDD10. RFICDT YYMMDD10. DTHDT YYMMDD10.;
    keep STUDYID USUBJID SUBJID TRTSDT TRTEDT RFICDT DTHDT SITEID SITENM AGE AGEGR1 AGEGR1N AGEU 
         SEX SEXN RACE ARM TRT01P TRT01PN COMPLFL FASFL PPSFL SAFFL DLTFL MHSEQ MHTERM MHDECOD 
         MHCAT MHENRTPT MHENTPT ; 
run;
data libout.&output_file_name.;
    set &output_file_name.;
run;
%SDTM_FIN(&output_file_name.);
