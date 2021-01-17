**************************************************************************
Program Name : QC_INO-Ped-ALL-1_CC_LIBNAME.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-1-15
SAS version : 9.4
**************************************************************************;
%macro OPEN_EXCEL(target);
    options noxwait noxsync;
    %sysexec "&target.";
    data _NULL_;
        rc=sleep(5);
    run;
%mend OPEN_EXCEL;
%macro SET_EXCEL(output_file_name, output_start_row, output_start_col, output_var);
    %local colcount rowcount output_end_col output_end_row;
    proc contents data=&output_file_name.
        out=_tmpxx_ noprint;
    run;
    data _NULL_;
        set _tmpxx_ nobs=colcnt;
        call symputx("colcount", colcnt);
    run;
    data _NULL_;
        set &output_file_name. nobs=rowcnt;
        call symputx("rowcount", rowcnt);
    run;
    %let output_end_col=%eval(&output_start_col.+&colcount);
    %let output_end_row=%eval(&output_start_row.+&rowcount);
    filename cmdexcel dde "excel|&output_file_name.!R&output_start_row.C&output_start_col.:R&output_end_row.C&output_end_col.";
    data _NULL_;
        set &output_file_name.;
        file cmdexcel dlm='09'X notab dsd;
        put &output_var.;
    run;
    filename cmdexcel clear;    
%mend SET_EXCEL;
%macro OUTPUT_EXCEL(target);
    filename cmdexcel dde 'excel|system';
    data _null_;
        fname="tempfile";
        rc=filename(fname, "&target.");
        if rc = 0 and fexist(fname) then do;
           rc=fdelete(fname);
        end;
        rc=filename(fname);
    run;
    data _null_;
        file cmdexcel;
        put '[error(false)]';
        put "%str([save.as(%"&target.%")])";
        put '[file.close(0)]';
    run;
    filename cmdexcel clear;
%mend;
%MACRO SDTM_FIN(output_file_name) ;

  DATA _NULL_ ;
       CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
       CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
  RUN ;

  DM LOG "FILE '&LOG.\&FILE._&output_file_name._LOG_&_YYMM_._&_TIME_..txt' REPLACE" ;
  DM "OUTPUT ; CLEAR ; LOG ; CLEAR ; " ;
%MEND ;
%let inputpath=&projectpath.\input\ads\QC;
%let templatepath=&projectpath.\output\template;
%let outputpath=&projectpath.\output\QC;
%let log=&projectpath.\log\QC\CC;
%let template_name_head=INO-Ped-ALL-1_STAT_CC_;
%let template_name_foot=.xlsx;
%let output_name_foot=_QC.xlsx;
%let dose_level=1;
%let file=DATA;
libname libin "&inputpath.";
libname libout "&outputpath.";
