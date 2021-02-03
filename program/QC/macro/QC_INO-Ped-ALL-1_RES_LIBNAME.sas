**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_LIBNAME.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-2-3
SAS version : 9.4
**************************************************************************;
%macro EDIT_SUBJID_LIST(input_ds, output_ds);
    %global subjid_list obs_cnt;
    data &output_ds.;
        set &input_ds.;
        keep SUBJID;
    run;

    proc sort data=&output_ds. out=&output_ds. nodupkey; 
    by SUBJID; 
    run;

    proc sql noprint;
    select SUBJID 
        into: subjid_list separated by ','
    from &output_ds.;

    select count(*)
    into: obs_cnt trimmed
    from &output_ds.;
    quit;
%mend EDIT_SUBJID_LIST;
%macro GET_MAX_OBS_CNT(subjid_list, input_ds_1, input_ds_2, output_ds);
    proc sql noprint;    
        create table row_count as
        select SUBJID, count(*) as row_count
        from &input_ds_1.
        group by SUBJID
        outer union corr
        select SUBJID, count(*) as row_count
        from &input_ds_2.
        group by SUBJID; 

        create table max_row_count as
        select SUBJID, max(row_count) as row_count
        from row_count
        group by SUBJID;

        create table &output_ds. as
        select a.SUBJID, b.row_count
        from &subjid_list. a left join max_row_count b on a.SUBJID = b.SUBJID;
    quit;
%mend GET_MAX_OBS_CNT;
%macro UNION_OUTPUT_SUBJID(input_ds, output_ds);
    %local i temp_subjid;
    data temp_&output_ds.; 
      set &input_ds.; 
      stop;   
      keep SUBJID;
    run;
    %do i=1 %to &obs_cnt.;
        %let temp_subjid=%scan(%quote(&subjid_list.), &i., ',');
        data _NULL_;
            set &input_ds.;
            where SUBJID="&temp_subjid.";
            if row_count=. then do;
              row_cnt=1;
            end;
            else do;
              row_cnt=row_count;
            end;
            call symputx('row_cnt', row_cnt);
        run;
        data temp_&i.;
            set &input_ds.;
            where SUBJID="&temp_subjid.";
            do j=1 to &row_cnt.;
              output;
            end;
            keep SUBJID; 
        run;
        data temp_&output_ds.;
            set temp_&output_ds. temp_&i.;
        run;
    %end;
    data &output_ds.;
        set temp_&output_ds.;
        by SUBJID;
        if first.SUBJID then do;
          target=&target_seq_1.;
          seq=0;
        end;
        else do;
          target=&target_seq_2.;
          seq+1;
        end;
    run;
%mend;
%macro SET_SEQ_VALUES(input_ds, output_ds);
    data &output_ds.;
        set &input_ds.;
        by SUBJID;
        if first.SUBJID then do;
          SEQ=-1;
        end;
        SEQ+1;
    run;
%mend SET_SEQ_VALUES;
%macro OPEN_EXCEL(target);
    options noxwait noxsync;
    %sysexec "&target.";
    data _NULL_;
        rc=sleep(5);
    run;
%mend OPEN_EXCEL;
%macro SET_EXCEL(output_file_name, output_start_row, output_start_col, output_var, sheet_name);
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
    filename cmdexcel dde "excel|&sheet_name.!R&output_start_row.C&output_start_col.:R&output_end_row.C&output_end_col.";
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
%let inputpath=&projectpath.\input\ads;
%let templatepath=&projectpath.\output\template;
%let outputpath=&projectpath.\output\QC;
%let log=&projectpath.\log\QC\result;
%let template_name_head=INO-Ped-ALL-1_STAT_RES_;
%let template_name_foot=.xlsx;
%let output_name_foot=_QC.xlsx;
%let file=DATA;
libname libin "&inputpath.";
libname libout "&outputpath.";
