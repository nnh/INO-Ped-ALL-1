**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_LIBNAME.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-2-5
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
%macro OUTPUT_ANALYSIS_SET_N(input_ds, output_ds, output_var, var_type);
    data &output_ds.;
        if &var_type.='CHAR' then do;
          length &output_var. $200.;
        end;
        set &input_ds nobs=NOBS;
        &output_var.=NOBS;
        keep &output_var.;
    run;
    proc sort data=&output_ds. out=&output_ds. nodupkey;
        by &output_var.;
    run;
%mend OUTPUT_ANALYSIS_SET_N;
%macro EDIT_N_PER(input_ds, output_ds, target_var);
    /* N (PER) , order by 'Y', 'N' */
    data temp_ds;
        set &input_ds.;
        N_PER=CAT(strip(COUNT),' (',strip(round(PERCENT, 0.1)),')');
    run;
    proc sql noprint;
        create table &output_ds. as
        select N_PER from temp_ds order by &target_var. desc;
    quit;
%mend EDIT_N_PER;
%macro EDIT_N_PER_2(input_ds, output_ds, target_var, sort_order, delimiter, mh_n);
    /* N, PER */
    proc freq data=&input_ds. noprint;
       tables &target_var. / out=temp_ds;
    run;
    data temp_ds_2;
        set temp_ds;
        N=COUNT;
        if &mh_n.=0 then do;
          PER=round(PERCENT, 0.1);
        end;
        else do;
          PER=round((N/&mh_n.)*100, 0.1);
        end;
        keep &target_var. N PER;
    run;
    %SET_SORT_ORDER(temp_ds_2, &output_ds., &target_var., &sort_order., &delimiter.);
%mend EDIT_N_PER_2;
%macro SET_SORT_ORDER(input_ds, output_ds, target_var, sort_order, delimiter);
    %let cnt=%sysfunc(countw(&sort_order., &delimiter.));
    %put &cnt.;
    data ds_sortorder;
        do i=1 to &cnt.;
          val=strip(scan(&sort_order., i, &delimiter.));
          output;
        end;
    run;
    proc sql noprint;
        create table &output_ds. as
        select b.val,
               case
                 when a.N = . then
                   0
                 else
                   a.N 
               end as N, 
               case
                 when a.PER = . then
                   put(0, 8.1)
                 else
                   put(a.PER, 8.1) 
               end as PER
        from &input_ds. a right join ds_sortorder b on a.&target_var. = b.val
        order by i;
    quit;
%mend SET_SORT_ORDER;
%macro EDIT_MEANS(input_ds, output_ds, target_var);
    %local max_digit_count;
    proc means data=&input_ds.  noprint;
        var &target_var.;
        output out=temp_means n=n mean=temp_mean stddev=temp_sd median=temp_median min=min max=max;
    run;
    data temp_digit;
        set &input_ds.;
        if int(&target_var.)^=&target_var. then do;
          digit_count=length(scan(put(&target_var., best12.), 2, "."));
        end;
        else do;
          digit_count=0;
        end;
        keep &target_var. digit_count; 
    run;
    proc sql noprint;
        select max(digit_count) into :max_digit_count from temp_digit;
    quit;
    %let digitcount1=%eval(&max_digit_count.+1);
    %let digitcount2=%eval(&max_digit_count.+2);
    %let digit1=%sysevalf(1/(10**(&digitcount1.)));
    %let digit2=%sysevalf(1/(10**(&digitcount2.)));
    %let format1=%sysfunc(catx(., 8, %sysfunc(strip(&digitcount1.))));
    %let format2=%sysfunc(catx(., 8, %sysfunc(strip(&digitcount2.))));
    %let format3=%sysfunc(catx(., 8, %sysfunc(strip(&max_digit_count.))));
    data temp_means_2;
        length min_max $200.;
        set temp_means;
        mean=put(round(temp_mean, &digit1.), &format1.);
        sd=put(round(temp_sd, &digit2.), &format2.);
        median=put(round(temp_median, &digit1.), &format1.);
        mean_sd=cat(strip(mean), 'Å}', strip(sd));
        min_digit_count=length(scan(put(min, best12.), 2, "."));
        max_digit_count=length(scan(put(max, best12.), 2, "."));
        int_min=int(min);
        int_max=int(max);
        min=min;
        max=max;
        if &max_digit_count.>0 then do;
          min_max=cat(strip(put(min, &format3.)), 'Å`', strip(put(max, &format3.)));
        end;
        else do;
          min_max=cat(strip(min), 'Å`', strip(max));
        end;
    run; 
    proc transpose data=temp_means_2 out=temp_means_3;
        var n mean_sd median min_max;
        by _TYPE_;
    run;
    data &output_ds.;
        set temp_means_3;
        keep _NAME_ col1;
    run;
%mend EDIT_MEANS;
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
