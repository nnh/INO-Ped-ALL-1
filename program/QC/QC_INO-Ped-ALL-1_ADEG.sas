**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADEG.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-1-6
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
%macro GET_MEANS(input_ds, output_ds);
    %local colnames cmiss_cols;
    %let colnames=%str(USUBJID PARAM PARAMCD AVISITN ATPTN EGORRESU ADT);
    %let cmiss_cols=%sysfunc(tranwrd(&colnames., %str( ),%str(,)));
    proc means data=&input_ds. noprint;
        var AVAL;
        class &colnames.;
        output out=temp_means_1;
    run;
    data &output_ds.;
        set temp_means_1;
        if cmiss(&cmiss_cols.)=0 then do;
          check=1;
        end;
        if _STAT_="MEAN" and check=1 then output;
        drop check;
    run;
%mend GET_MEANS;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_ADaM_LIBNAME.sas";
* Main processing start;
%let output_file_name=ADEG;
libname libinput "&outputpath." ACCESS=READONLY;
%READ_CSV(&outputpath., adsl);
%READ_CSV(&inputpath., eg);
proc sql noprint;
    create table temp_adeg_1 as
    select USUBJID, EGTESTCD as PARAMCD, EGORRES, EGORRESU, EGDTC as ADT, VISITNUM as AVISITN,
           EGTEST, EGTPTNUM,
           case 
             when EGTPTNUM = 10 or EGTPTNUM = 20 or EGTPTNUM = 30 then 1
             when EGTPTNUM = 40 or EGTPTNUM = 50 or EGTPTNUM = 60 then 2
             else .
           end as ATPTN
    from eg
    where EGTESTCD^="INTP" and not missing(EGORRES);
quit;
* QTCB, QTCF;
proc sql noprint;
    create table temp_adeg_qt_rr_1 as
    select a.USUBJID, a.EGORRES as QT_ORRES, a.EGORRESU, 
           a.AVISITN, a.EGTPTNUM, b.EGORRES as RR_ORRES, 
           a.ATPTN, a.ADT
    from (select * from temp_adeg_1 where PARAMCD = "QTINTNOS") a, 
         (select * from temp_adeg_1 where PARAMCD = "RRINTNOS") b
    where a.USUBJID = b.USUBJID and
          a.AVISITN = b.AVISITN and
          a.ADT = b.ADT and 
          a.EGTPTNUM = b.EGTPTNUM;
quit;
data temp_adeg_qtcb;
    set temp_adeg_qt_rr_1;
    PARAM="QTcB (sec)";
    PARAMCD="QTCB";
    AVAL=QT_ORRES/(RR_ORRES**1/2);
run;
data temp_adeg_qtcf;
    set temp_adeg_qt_rr_1;
    PARAM="QTcF (sec)";
    PARAMCD="QTCF";
    AVAL=QT_ORRES/(RR_ORRES**1/3);
run;
data temp_adeg_qtcb_qtcf;
    set temp_adeg_qtcb
        temp_adeg_qtcf;
    AVALC="";
run;
%GET_MEANS(temp_adeg_qtcb_qtcf, temp_adeg_qtcb_qtcf_means);
* others;
data temp_adeg_2;
    set temp_adeg_1;
    numcheck=VERIFY(TRIM(EGORRES), '0123456789.');
    if numcheck=0 then do;
      AVAL=input(EGORRES, best12.);
    end;
    else do;
      AVALC=EGORRES;
    end;
    if not missing(EGORRESU) then do;
      PARAM=trim(EGTEST) || ' (' || trim(EGORRESU) || ') ';
    end;
    else do;
      PARAM=EGTEST;
    end;
run;
%GET_MEANS(temp_adeg_2, temp_adeg_means);
* merge;
data temp_adeg_3;
    set temp_adeg_means
        temp_adeg_qtcb_qtcf_means;
run;
* base;
%GET_BASE_ORRES(temp_adeg_1, temp_dummy, EGORRES);
proc sort data=temp_base_2 out=temp_adeg_base_1; 
    by USUBJID PARAMCD descending AVISITN ATPTN EGTPTNUM; 
run;
data temp_adeg_base_2;
    set temp_adeg_base_1;
    by USUBJID PARAMCD descending AVISITN ATPTN EGTPTNUM;
    if first.ATPTN then output;
run;
proc sort data=temp_adeg_base_2 out=temp_adeg_base_3; 
    by USUBJID PARAMCD ATPTN descending AVISITN; 
run;
data temp_adeg_base_4;
    set temp_adeg_base_3;
    by USUBJID PARAMCD ATPTN descending AVISITN;
    if first.ATPTN then output;
run;
proc sql noprint;
    create table temp_adeg_4 as
    select a.*, b.BASE
    from temp_adeg_3 a left join temp_adeg_base_4 b 
      on a.USUBJID = b.USUBJID and
         a.PARAMCD = b.PARAMCD and
         a.ATPTN = b.ATPTN; 
quit;
data temp_adeg_5;
    set temp_adeg_4;
    if not missing(BASE) then do;
      CHG=AVAL-BASE;
    end;
    if ATPTN=1 then do;
      ATPT="PRIOR";
    end;
    else if ATPTN=2 then do;
      ATPT="AFTER";
    end;
run;
proc sql noprint;
    create table temp_adeg_6 as
    select a.*, b.STUDYID, b.SUBJID, b.TRTSDT, b.TRTEDT, b.RFICDT, b.DTHDT, b.SITEID, b.SITENM, 
           b.AGE, b.AGEGR1, b.AGEGR1N, b.AGEU, b.SEX, b.SEXN, b.RACE, b.ARM, b.TRT01P, b.TRT01PN,
           b.COMPLFL, b.FASFL, b.PPSFL, b.SAFFL, b.DLTFL
    from temp_adeg_5 a left join adsl b on a.USUBJID = b.USUBJID 
    order by USUBJID, PARAMCD, AVISITN, ATPTN;
quit;
%SET_ADY(temp_adeg_6, temp_adeg_7);
%SET_AVISIT(temp_adeg_7, temp_adeg_8);
data &output_file_name.;
    length STUDYID $200. USUBJID $200. SUBJID 8. TRTSDT 8. TRTEDT 8. RFICDT 8. DTHDT 8. SITEID 8. 
           SITENM $200. AGE 8. AGEGR1 $8. AGEGR1N 8. AGEU $200. SEX $200. SEXN 8. RACE $200. 
           ARM $200. TRT01P $200. TRT01PN 8. COMPLFL $200. FASFL $200. PPSFL $200. SAFFL $200. 
           DLTFL $200. PARAM $200. PARAMCD $200. AVALC $200. AVAL 8. ADT 8. ADY 8. AVISIT $200. 
           AVISITN 8. ATPT $200. ATPTN 8. BASE 8. CHG 8.;
    set temp_adeg_8;
    label STUDYID='Study Identifier' USUBJID='Unique Subject Identifier' 
          SUBJID='Subject Identifier for the Study' TRTSDT='Date of First Exposure to Treatment' 
          TRTEDT='Date of Last Exposure to Treatment' RFICDT='Date of Informed Consent' 
          DTHDT='Date of Death' SITEID='Study Site Identifier' SITENM='Study Site Name' AGE='Age' 
          AGEGR1='Pooled Age Group 1' AGEGR1N='Pooled Age Group 1 (N)' AGEU='Age Units' SEX='Sex' 
          SEXN='Sex (N)' RACE='Race' ARM='Description of Planned Arm' 
          TRT01P='Planned Treatment for Period 01' TRT01PN='Planned Treatment for Period 01 (N)' 
          COMPLFL='Completers Population Flag' FASFL='Full Analysis Set Population Flag' 
          PPSFL='Per Protocol Set Population Flag' SAFFL='Safety Population Flag' 
          DLTFL='DLT Population Flag' PARAM='Parameter' PARAMCD='Parameter Code' 
          AVALC='Analysis Value (C)' AVAL='Analysis Value' ADT='Analysis Date' 
          ADY='Analysis Relative Day' AVISIT='Analysis Visit' AVISITN='Analysis Visit (N)' 
          ATPT='Analysis Timepoint ' ATPTN='Analysis Timepoint (N)' BASE='Baseline Value'
          CHG='Change from Baseline';
    format _ALL_;
    informat _ALL_;
    format TRTSDT YYMMDD10. TRTEDT YYMMDD10. RFICDT YYMMDD10. DTHDT YYMMDD10. ADT YYMMDD10.;
    keep STUDYID USUBJID SUBJID TRTSDT TRTEDT RFICDT DTHDT SITEID SITENM AGE AGEGR1 AGEGR1N 
         AGEU SEX SEXN RACE ARM TRT01P TRT01PN COMPLFL FASFL PPSFL SAFFL DLTFL PARAM PARAMCD 
         AVALC AVAL ADT ADY AVISIT AVISITN ATPT ATPTN BASE CHG; 
run;
data libout.&output_file_name.;
    set &output_file_name.;
run;
%WRITE_CSV(&output_file_name., &output_file_name.);
%SDTM_FIN(&output_file_name.);
