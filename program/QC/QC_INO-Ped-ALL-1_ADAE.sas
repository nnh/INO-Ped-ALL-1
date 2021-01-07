**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADAE.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-1-7
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
%let output_file_name=ADAE;
libname libinput "&outputpath." ACCESS=READONLY;
libname libmdr "&extpath." ACCESS=READONLY;
%READ_CSV(&inputpath., ae);
%READ_CSV(&inputpath., co);
data adsl;
    set libinput.adsl;
run;
data meddra;
    set libmdr.Meddra;
run;
proc sql noprint;
    create table temp_ae_1 as
    select a.*, b.SUBJID, b.TRTSDT, b.TRTEDT, b.RFICDT, b.DTHDT, b.SITEID, b.SITENM, b.AGE, 
           b.AGEGR1, b.AGEGR1N, b.AGEU, b.SEX, b.SEXN, b.RACE, b.ARM, b.TRT01P, b.TRT01PN, b.COMPLFL, b.FASFL, 
           b.PPSFL, b.SAFFL, b.DLTFL 
    from ae a left join adsl b on a.USUBJID = b.USUBJID
    order by AESEQ;
quit;
data temp_ae_2;
    set temp_ae_1(rename=(AESTDTC=ASTDT AEENDTC=AENDT));
    AESTDTC=put(ASTDT, YYMMDD10.);
    AEENDTC=put(AENDT, YYMMDD10.);
    if ASTDT>=TRTSDT then do;
      ASTDY=ASTDT-TRTSDT+1;
    end;
    else if ASTDT<TRTSDT then do;
      ASTDY=AENDT-TRTSDT;
    end;
    else do;
      ASTDY=.;
    end;
    if AENDT>=TRTSDT then do;
      AENDY=AENDT-TRTSDT+1;
    end;
    else if AENDT<TRTSDT then do;
      AENDY=AENDT-TRTSDT;
    end;
    else do;
      AENDY=.;
    end;
    ADURN=AENDT-ASTDT+1;
    if ADURN ne . then do;
      ADURU="DAYS";
    end;
    if AEREL="RELATED" then do;
      AERELN=1;
    end;
    else if AEREL="NOT RELATED" then do;
      AERELN=2;
    end;
    else do;
      AERELN=.;
    end;
run;
proc sql noprint;
    create table temp_ae_3 as
    select a.*, b.COVAL
    from temp_ae_2 a left join co b on a.AESEQ = b.IDVARVAL;
quit;
data temp_ae_4;
    set temp_ae_3;
    drop AEBODSYS AEBDSYCD AEDECOD AEPTCD AESOC AESOCCD;
run;
proc sql noprint;
    create table temp_ae_5 as
    select *, b.soc_name as AEBODSYS, b.soc_code as AEBDSYCD, b.pt_name as AEDECOD,
           b.pt_code as AEPTCD, b.soc_name as AESOC, b.soc_code as AESOCCD, 
           'MedDRA V23.1' as AEDICT
    from temp_ae_4 a left join meddra b on a.AELLTCD=b.llt_code
    order by AESEQ;
quit;
data &output_file_name.;
    length STUDYID $200. USUBJID $200. SUBJID $200. TRTSDT 8. TRTEDT 8. RFICDT 8. DTHDT 8. SITEID 8. 
           SITENM $200. AGE 8. AGEGR1 $200. AGEGR1N 8. AGEU $200. SEX $200. SEXN 8. RACE $200. 
           ARM $200. TRT01P $200. TRT01PN 8. COMPLFL $200. FASFL $200. PPSFL $200. SAFFL $200. 
           DLTFL $200. AESEQ 8. AETERM $200. AEBODSYS $200. AEBDSYCD 8. AELLT $200. AELLTCD 8. 
           AEDECOD $200. AEPTCD 8. AESOC $200. AESOCCD 8. AESTDTC $200. ASTDT 8. AEENDTC $200. 
           AENDT 8. ASTDY 8. AENDY 8. ADURN 8. ADURU $200. AESER $200. AESDTH $200. AESLIFE $200. 
           AESHOSP $200. AESDISAB $200. AESCONG $200. AESMIE $200. AEREL $200. AERELN 8. AEACN $200. 
           AEOUT $200. AETOXGR 8. AEDICT $200. COVAL $200.; 
    set temp_ae_5;
    label STUDYID='Study Identifier' USUBJID='Unique Subject Identifier' 
          SUBJID='Subject Identifier for the Study' TRTSDT='Date of First Exposure to Treatment' 
          TRTEDT='Date of Last Exposure to Treatment' RFICDT='Date of Informed Consent' 
          DTHDT='Date of Death' SITEID='Study Site Identifier' SITENM='Study Site Name' AGE='Age' 
          AGEGR1='Pooled Age Group 1' AGEGR1N='Pooled Age Group 1 (N)' AGEU='Age Units' SEX='Sex' 
          SEXN='Sex (N)' RACE='Race' ARM='Description of Planned Arm' TRT01P='Planned Treatment for Period 01'
          TRT01PN='Planned Treatment for Period 01 (N)' COMPLFL='Completers Population Flag' 
          FASFL='Full Analysis Set Population Flag' PPSFL='Per Protocol Set Population Flag' 
          SAFFL='Safety Population Flag' DLTFL='DLT Population Flag' AESEQ='Sequence Number' 
          AETERM='Reported Term for the Adverse Event' AEBODSYS='Body System or Organ Class' 
          AEBDSYCD='Body System or Organ Class Code' AELLT='Lowest Level Term' AELLTCD='Lowest Level Term Code'
          AEDECOD='Dictionary-Derived Term' AEPTCD='Preferred Term Code' AESOC='Primary System Organ Class'
          AESOCCD='Primary System Organ Class Code' AESTDTC='Start Date/Time of Adverse Event' 
          ASTDT='Analysis Start Date' AEENDTC='End Date/Time of Adverse Event' AENDT='Analysis End Date' 
          ASTDY='Analysis Start Relative Day' AENDY='Analysis End Relative Day' ADURN='AE Duration (N)' 
          ADURU='AE Duration Units' AESER='Serious Event' AESDTH='Results in Death' AESLIFE='Is Life Threatening' 
          AESHOSP='Requires or Prolongs Hospitalization' AESDISAB='Persist or Signif Disability/Incapacity' 
          AESCONG='Congenital Anomaly or Birth Defect' AESMIE='Other Medically Important Serious Event' 
          AEREL='Causality' AERELN='Causality (N)' AEACN='Action Taken with Study Treatment' 
          AEOUT='Outcome of Adverse Event' AETOXGR='Standard Toxicity Grade' AEDICT='Coding Dictionary Information' 
          COVAL='Relationship to Non-Study Treatment'; 
    format _ALL_;
    informat _ALL_;
    format TRTSDT YYMMDD10. TRTEDT YYMMDD10. RFICDT YYMMDD10. DTHDT YYMMDD10. ASTDT YYMMDD10. AENDT YYMMDD10.;
    keep STUDYID USUBJID SUBJID TRTSDT TRTEDT RFICDT DTHDT SITEID SITENM AGE AGEGR1 AGEGR1N AGEU 
         SEX SEXN RACE ARM TRT01P TRT01PN COMPLFL FASFL PPSFL SAFFL DLTFL AESEQ AETERM AEBODSYS
         AEBDSYCD AELLT AELLTCD AEDECOD AEPTCD AESOC AESOCCD AESTDTC ASTDT AEENDTC AENDT ASTDY
         AENDY ADURN ADURU AESER AESDTH AESLIFE AESHOSP AESDISAB AESCONG AESMIE AEREL AERELN AEACN 
         AEOUT AETOXGR AEDICT COVAL; 
run;
data libout.&output_file_name.;
    set &output_file_name.;
run;
%SDTM_FIN(&output_file_name.);
