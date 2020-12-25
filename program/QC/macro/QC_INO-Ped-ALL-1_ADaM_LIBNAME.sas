**************************************************************************
Program Name : QC_ADaMLIBNAME.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-12-25
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
