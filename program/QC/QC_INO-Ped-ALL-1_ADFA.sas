**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADFA.sas
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
%let output_file_name=ADFA;
libname libinput "&outputpath." ACCESS=READONLY;
%READ_CSV(&outputpath., adsl);
%READ_CSV(&inputpath., fa);
data temp_adfa_1;
    set fa;
    where FAORRES is not missing;
    numcheck=VERIFY(TRIM(FAORRES), '0123456789.');
    if numcheck=0 then do;
      AVAL=input(FAORRES, best12.);
    end;
    else do;
      AVALC=FAORRES;
    end;
    PARCAT1=FACAT;
    PARCAT2=FAOBJ;
    PARCAT3=FAMETHOD;
    PARCAT4=FALOC;
    PARAM=FATEST;
    PARAMCD=FATESTCD;
    ADT=FADTC;
    AVISITN=VISITNUM;
run;
proc sql noprint;
    create table temp_adfa_2 as
    select a.*, b.SUBJID, b.TRTSDT, b.TRTEDT, b.RFICDT, b.DTHDT, b.SITEID, b.SITENM, 
           b.AGE, b.AGEGR1, b.AGEGR1N, b.AGEU, b.SEX, b.SEXN, b.RACE, b.ARM, b.TRT01P, b.TRT01PN,
           b.COMPLFL, b.FASFL, b.PPSFL, b.SAFFL, b.DLTFL
    from temp_adfa_1 a left join adsl b on a.USUBJID = b.USUBJID 
    order by USUBJID, PARCAT1, PARAMCD, AVISITN, ADT;
quit;
%SET_ADY(temp_adfa_2, temp_adfa_3);
%SET_AVISIT(temp_adfa_3, temp_adfa_4);
data &output_file_name.;
    length STUDYID $200. USUBJID $200. SUBJID 8. TRTSDT 8. TRTEDT 8. RFICDT 8. DTHDT 8. SITEID 8. 
           SITENM $200. AGE 8. AGEGR1 $8. AGEGR1N 8. AGEU $200. SEX $200. SEXN 8. RACE $200. ARM $200. 
           TRT01P $200. TRT01PN 8. COMPLFL $200. FASFL $200. PPSFL $200. SAFFL $200. DLTFL $200. 
           PARCAT1 $200. PARCAT2 $200. PARCAT3 $200. PARCAT4 $200. PARAM $200. PARAMCD $200. AVALC $200. 
           AVAL 8. ADT 8. ADY 8. AVISIT $200. AVISITN 8.;
    set temp_adfa_4;
    label STUDYID='Study Identifier' USUBJID='Unique Subject Identifier' 
          SUBJID='Subject Identifier for the Study' TRTSDT='Date of First Exposure to Treatment'
          TRTEDT='Date of Last Exposure to Treatment' RFICDT='Date of Informed Consent' DTHDT='Date of Death' 
          SITEID='Study Site Identifier' SITENM='Study Site Name' AGE='Age' AGEGR1='Pooled Age Group 1' 
          AGEGR1N='Pooled Age Group 1 (N)' AGEU='Age Units' SEX='Sex' SEXN='Sex (N)' RACE='Race' 
          ARM='Description of Planned Arm' TRT01P='Planned Treatment for Period 01' 
          TRT01PN='Planned Treatment for Period 01 (N)' COMPLFL='Completers Population Flag' 
          FASFL='Full Analysis Set Population Flag' PPSFL='Per Protocol Set Population Flag' 
          SAFFL='Safety Population Flag' DLTFL='DLT Population Flag' PARCAT1='Parameter Category 1' 
          PARCAT2='Parameter Category 2' PARCAT3='Parameter Category 3' PARCAT4='Parameter Category 4'
          PARAM='Parameter' PARAMCD='Parameter Code' AVALC='Analysis Value (C)' AVAL='Analysis Value' 
          ADT='Analysis Date' ADY='Analysis Relative Day' AVISIT='Analysis Visit' AVISITN='Analysis Visit (N)';
    format _ALL_;
    informat _ALL_;
    format TRTSDT YYMMDD10. TRTEDT YYMMDD10. RFICDT YYMMDD10. DTHDT YYMMDD10. ADT YYMMDD10.;
    keep STUDYID USUBJID SUBJID TRTSDT TRTEDT RFICDT DTHDT SITEID SITENM AGE AGEGR1 AGEGR1N AGEU 
         SEX SEXN RACE ARM TRT01P TRT01PN COMPLFL FASFL PPSFL SAFFL DLTFL PARCAT1 PARCAT2 PARCAT3
         PARCAT4 PARAM PARAMCD AVALC AVAL ADT ADY AVISIT AVISITN; 
run;
data libout.&output_file_name.;
    set &output_file_name.;
run;
%WRITE_CSV(&output_file_name., &output_file_name.);
%SDTM_FIN(&output_file_name.);
