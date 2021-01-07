**************************************************************************
Program Name : QC_ADaMLIBNAME.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-1-4
SAS version : 9.4
**************************************************************************;
%macro READ_CSV(dir, ds_name);
    proc import datafile="&dir.\&ds_name..csv"
      out=&ds_name.
      dbms=csv replace;
      guessingrows=MAX;
    run;
%mend READ_CSV;
%macro WRITE_CSV(input_ds, output_filename);
    proc export
        data=&input_ds.
        outfile="&outputpath.\&output_filename..csv"
        dbms=csv
        replace;
    run;
%mend WRITE_CSV;
%macro GET_TEST_RESULT(input_ds, target, join_ds, output_ds, output_val);
    proc sql noprint;
        create table &target. as
        select * 
        from &input_ds.
        where &input_ds.TESTCD = "&target." and (VISITNUM = 100 or VISITNUM = 101)
        order by USUBJID;
    quit;
    data &target.1;
        set &target.;      
        where VISITNUM=101;
        seq=_N_+100;
    run;
    data &target.2;
        set &target.;      
        where &input_ds.ORRES is not missing;
        seq=_N_+200;
    run;
    data &target.3;
        set &target.;      
        where VISITNUM=100;
        seq=_N_+300;
    run;
    proc sql noprint;
        create table &target._union as
        select * from &target.1
        outer union corr 
        select * from &target.2
        outer union corr 
        select * from &target.3
        order by USUBJID, SEQ;
    quit;
    data &target._first;
        set &target._union;
        by USUBJID;
        if first.USUBJID then do;
            output;
        end;
    run;
    proc sql noprint;
        create table &output_ds. as
        select a.*, b.&input_ds.ORRES as &output_val.
        from &join_ds. a left join &target._first b on a.USUBJID = b.USUBJID;
    quit;
%mend GET_TEST_RESULT;
%macro SET_AVISIT(input_ds, output_ds);
    data &output_ds.;
    length AVISIT $200.;
    set &input_ds.;
    select (AVISITN);
      when (100) AVISIT="SCREEN";
      when (101) AVISIT="CYCLE1 DAY1";
      when (104) AVISIT="CYCLE1 DAY4";
      when (108) AVISIT="CYCLE1 DAY8";
      when (115) AVISIT="CYCLE1 DAY15";
      when (200) AVISIT="END OF CYCLE1";
      when (201) AVISIT="CYCLE2 DAY1";
      when (208) AVISIT="CYCLE2 DAY8";
      when (215) AVISIT="CYCLE2 DAY15";
      when (300) AVISIT="END OF CYCLE2";
      when (301) AVISIT="CYCLE3 DAY1";
      when (308) AVISIT="CYCLE3 DAY8";
      when (315) AVISIT="CYCLE3 DAY15";
      when (400) AVISIT="END OF CYCLE3";
      when (401) AVISIT="CYCLE4 DAY1";
      when (408) AVISIT="CYCLE4 DAY8";
      when (415) AVISIT="CYCLE4 DAY15";
      when (500) AVISIT="END OF CYCLE4";
      when (501) AVISIT="CYCLE5 DAY1";
      when (508) AVISIT="CYCLE5 DAY8";
      when (515) AVISIT="CYCLE5 DAY15";
      when (600) AVISIT="END OF CYCLE5";
      when (601) AVISIT="CYCLE6 DAY1";
      when (608) AVISIT="CYCLE6 DAY8";
      when (615) AVISIT="CYCLE6 DAY15";
      when (700) AVISIT="END OF CYCLE6";
      when (800) AVISIT="FOLLOW-UP";
      when (900) AVISIT="HSCT";
      when (904) AVISIT="HSCT 4WKS";
      when (908) AVISIT="HSCT 8WKS";
      when (912) AVISIT="HSCT 12WKS";
      when (916) AVISIT="HSCT 16WKS";
      otherwise AVISIT="";
    end; 
run;
%mend SET_AVISIT;
%macro SET_ADY(input_ds, output_ds);
    data &output_ds.;
        set &input_ds.;
        if ADT>=TRTSDT then do;
          ADY=ADT-TRTSDT+1;
        end; 
        else if ADT<TRTSDT then do;
          ADY=ADT-TRTSDT;
        end;
    run;
%mend SET_ADY;
%macro GET_BASE_ORRES(input_ds, output_ds, target_val);
    proc sql noprint;
        create table temp_base_1 as
        select *
        from &input_ds.
        where AVISITN = 100 or AVISITN = 101
        order by USUBJID, PARAMCD, AVISITN desc;
    quit;
    data temp_base_2;
        set temp_base_1;
        numcheck=VERIFY(TRIM(&target_val.), '0123456789.');
        if numcheck=0 then do;
          BASE=input(&target_val., best12.);
          output;
      end;
    run;
    data temp_base_3;
        set temp_base_2;
        by USUBJID PARAMCD;
        if first.PARAMCD then output;
    run;
    proc sql noprint;
        create table &output_ds. as
        select a.*, b.BASE
        from &input_ds. a left join temp_base_3 b 
          on a.USUBJID =b.USUBJID and a.PARAMCD = b.PARAMCD;
    quit;
%mend GET_BASE_ORRES;
%MACRO SDTM_FIN(output_file_name) ;

  DATA _NULL_ ;
       CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
       CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
  RUN ;

  DM LOG "FILE '&LOG.\&FILE._&output_file_name._LOG_&_YYMM_._&_TIME_..txt' REPLACE" ;
  DM "OUTPUT ; CLEAR ; LOG ; CLEAR ; " ;
%MEND ;
%let inputpath=&projectpath.\input\sdtm\QC;
%let extpath=&projectpath.\input\ext;
%let outputpath=&projectpath.\input\ads\QC;
%let log=&projectpath.\log\QC\ads;
%let file=DATA;
libname libout "&outputpath.";
