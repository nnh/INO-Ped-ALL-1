**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADCM.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-1-18
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
%let output_file_name=ADCM;
libname libinput "&outputpath." ACCESS=READONLY;
%READ_CSV(&inputpath., cm);
data adsl;
    set libinput.adsl;
run;
data temp_cm;
    set cm;
    if CMPRESP='Y' and CMOCCUR='N' then delete;
run;
proc sql noprint;
    create table temp_adcm_0 as
    select b.STUDYID, b.USUBJID, b.SUBJID, b.TRTSDT, b.TRTEDT, b.RFICDT, b.DTHDT, b.SITEID, 
           b.SITENM, b.AGE, b.AGEGR1, b.AGEGR1N, b.AGEU, b.SEX, b.SEXN, b.RACE, b.ARM, 
           b.TRT01P, b.TRT01PN, b.COMPLFL, b.FASFL, b.PPSFL, b.SAFFL, b.DLTFL, a.CMSEQ, 
           a.CMTRT,
           case 
             when a.CMDECOD='' then CMTRT
             when a.CMDECOD='BLINATUMOMAB' then 'Blinatumomab'
             else CMDECOD
           end as CMDECOD, 
           a.CMCAT, a.CMSTDTC, a.CMENDTC
    from temp_cm a left join adsl b on a.USUBJID = b.USUBJID
    order by USUBJID, CMCAT, CMSTDTC, CMENDTC, CMTRT, CMDECOD, CMSEQ;
quit;
proc sort data=temp_adcm_0 out=temp_adcm_1 nodupkey; 
    by USUBJID CMCAT CMSTDTC CMENDTC CMTRT CMDECOD; 
run;
data temp_adcm_2;
    length CMDECOD $200.;
    set temp_adcm_1 (rename=(CMDECOD=temp_CMDECOD));
    if temp_CMDECOD='BLINATUMOMAB' then do;
      CMDECOD='Blinatumomab';
    end;
    else do;
      CMDECOD=temp_CMDECOD;
    end;
    drop temp_CMDECOD;
run;
data &output_file_name.;
    length STUDYID $200. USUBJID $200. SUBJID $200. TRTSDT 8. TRTEDT 8. RFICDT 8. DTHDT 8. 
           SITEID 8. SITENM $200. AGE 8. AGEGR1 $200. AGEGR1N 8. AGEU $200. SEX $200. SEXN 8. 
           RACE $200. ARM $200. TRT01P $200. TRT01PN 8. COMPLFL $200. FASFL $200. PPSFL $200. 
           SAFFL $200. DLTFL $200. CMSEQ 8. CMTRT $200. CMDECOD $200. CMCAT $200. ASTDT 8. AENDT 8.; 
    set temp_adcm_2;
    ASTDT=input(CMSTDTC, best12.);
    AENDT=input(CMENDTC, best12.);
    label STUDYID='Study Identifier' USUBJID='Unique Subject Identifier' 
          SUBJID='Subject Identifier for the Study' TRTSDT='Date of First Exposure to Treatment' 
          TRTEDT='Date of Last Exposure to Treatment' RFICDT='Date of Informed Consent' 
          DTHDT='Date of Death' SITEID='Study Site Identifier' SITENM='Study Site Name' AGE='Age' 
          AGEGR1='Pooled Age Group 1' AGEGR1N='Pooled Age Group 1 (N)' AGEU='Age Units' SEX='Sex' 
          SEXN='Sex (N)' RACE='Race' ARM='Description of Planned Arm' TRT01P='Planned Treatment for Period 01' 
          TRT01PN='Planned Treatment for Period 01 (N)' COMPLFL='Completers Population Flag' 
          FASFL='Full Analysis Set Population Flag' PPSFL='Per Protocol Set Population Flag' 
          SAFFL='Safety Population Flag' DLTFL='DLT Population Flag' CMSEQ='Sequence Number' 
          CMTRT='Reported Name of Drug, Med, or Therapy' CMDECOD='Standardized Medication Name' 
          CMCAT='Category for Medication' ASTDT='Analysis Start Date' AENDT='Analysis End Date'; 
    format _ALL_;
    informat _ALL_;
    format TRTSDT YYMMDD10. TRTEDT YYMMDD10. RFICDT YYMMDD10. DTHDT YYMMDD10. ASTDT YYMMDD10. AENDT YYMMDD10.;
    keep STUDYID USUBJID SUBJID TRTSDT TRTEDT RFICDT DTHDT SITEID SITENM AGE AGEGR1 AGEGR1N AGEU 
         SEX SEXN RACE ARM TRT01P TRT01PN COMPLFL FASFL PPSFL SAFFL DLTFL CMSEQ CMTRT CMDECOD CMCAT ASTDT AENDT; 
run;
data libout.&output_file_name.;
    set &output_file_name.;
run;
%SDTM_FIN(&output_file_name.);
