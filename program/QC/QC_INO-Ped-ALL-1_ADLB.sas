**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADLB.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-1-5
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
%let output_file_name=ADLB;
libname libinput "&outputpath." ACCESS=READONLY;
%READ_CSV(&outputpath., adsl);
%READ_CSV(&inputpath., lb);
proc sql noprint;
    create table temp_adlb_1 as
    select USUBJID, LBTESTCD as PARAMCD, LBORRES, LBORRESU, LBDTC as ADT, VISITNUM as AVISITN, LBTEST
    from lb
    where LBTESTCD^="MRDQV" and not missing(LBORRES);
quit;
%GET_BASE_ORRES(temp_adlb_1, temp_adlb_2, LBORRES);
data temp_adlb_3;
    set temp_adlb_2;
    numcheck=VERIFY(TRIM(LBORRES), '0123456789.');
    if numcheck=0 then do;
      AVAL=input(LBORRES, best12.);
      CHG=AVAL-BASE;
    end;
    else do;
      AVALC=LBORRES;
    end;
    if not missing(LBORRESU) then do;
      PARAM=trim(LBTEST) || ' (' || trim(LBORRESU) || ') ';
    end;
    else do;
      PARAM=LBTEST;
    end;
run;
proc sql noprint;
    create table temp_adlb_4 as
    select a.*, b.STUDYID, b.SUBJID, b.TRTSDT, b.TRTEDT, b.RFICDT, b.DTHDT, b.SITEID, 
           b.SITENM, b.AGE, b.AGEGR1, b.AGEGR1N, b.AGEU, b.SEX, b.SEXN, b.RACE, b.ARM, b.TRT01P,
           b.TRT01PN, b.COMPLFL, b.FASFL, b.PPSFL, b.SAFFL, b.DLTFL
    from temp_adlb_3 a left join adsl b on a.USUBJID = b.USUBJID
    order by USUBJID, PARAMCD, AVISITN, ADT;
quit;
%SET_ADY(temp_adlb_4, temp_adlb_5);
%SET_AVISIT(temp_adlb_5, temp_adlb_6);
data &output_file_name.;
    length STUDYID $200. USUBJID $200. SUBJID 8. TRTSDT 8. TRTEDT 8. RFICDT 8. DTHDT 8. SITEID 8. 
           SITENM $200. AGE 8. AGEGR1 $8. AGEGR1N 8. AGEU $200. SEX $200. SEXN 8. RACE $200. 
           ARM $200. TRT01P $200. TRT01PN 8. COMPLFL $200. FASFL $200. PPSFL $200. SAFFL $200. 
           DLTFL $200. PARAM $200. PARAMCD $200. AVALC $200. AVAL 8. ADT 8. ADY 8. AVISIT $200. 
           AVISITN 8. BASE 8. CHG 8.;
    set temp_adlb_6;
    label STUDYID='Study Identifier' USUBJID='Unique Subject Identifier' 
          SUBJID='Subject Identifier for the Study' TRTSDT='Date of First Exposure to Treatment' 
          TRTEDT='Date of Last Exposure to Treatment' RFICDT='Date of Informed Consent' 
          DTHDT='Date of Death' SITEID='Study Site Identifier' SITENM='Study Site Name' AGE='Age'
          AGEGR1='Pooled Age Group 1' AGEGR1N='Pooled Age Group 1 (N)' AGEU='Age Units' SEX='Sex' 
          SEXN='Sex (N)' RACE='Race' ARM='Description of Planned Arm' TRT01P='Planned Treatment for Period 01'
          TRT01PN='Planned Treatment for Period 01 (N)' COMPLFL='Completers Population Flag'
          FASFL='Full Analysis Set Population Flag' PPSFL='Per Protocol Set Population Flag' 
          SAFFL='Safety Population Flag' DLTFL='DLT Population Flag' PARAM='Parameter' PARAMCD='Parameter Code'
          AVALC='Analysis Value (C)' AVAL='Analysis Value' ADT='Analysis Date' ADY='Analysis Relative Day' 
          AVISIT='Analysis Visit' AVISITN='Analysis Visit (N)' BASE='Baseline Value'
          CHG='Change from Baseline';
    format _ALL_;
    informat _ALL_;
    format TRTSDT YYMMDD10. TRTEDT YYMMDD10. RFICDT YYMMDD10. DTHDT YYMMDD10. ADT YYMMDD10.;
    keep STUDYID USUBJID SUBJID TRTSDT TRTEDT RFICDT DTHDT SITEID SITENM AGE AGEGR1 AGEGR1N AGEU 
         SEX SEXN RACE ARM TRT01P TRT01PN COMPLFL FASFL PPSFL SAFFL DLTFL PARAM PARAMCD AVALC AVAL 
         ADT ADY AVISIT AVISITN BASE CHG; 
run;
data libout.&output_file_name.;
    set &output_file_name.;
run;
%WRITE_CSV(&output_file_name., &output_file_name.);
%SDTM_FIN(&output_file_name.);
