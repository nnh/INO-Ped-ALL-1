**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_LIBNAME.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-3-24
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
    data _NULL_;
        fname="tempfile";
        rc=filename(fname, "&target.");
        if rc = 0 and fexist(fname) then do;
           rc=fdelete(fname);
        end;
        rc=filename(fname);
    run;
    data _NULL_;
        file cmdexcel;
        put '[error(false)]';
        put "%str([save.as(%"&target.%")])";
        put '[file.close(0)]';
    run;
    filename cmdexcel clear;
%mend OUTPUT_EXCEL;
%macro CLEAR_EXCEL(sheetname, start_row);
    filename cmdexcel dde 'excel|system';
    data _NULL_;
        file cmdexcel;
        put "[workbook.activate(""[INO-Ped-ALL-1_STAT_RES_&sheetname..xlsx]&sheetname."")]";
        put "[select(%bquote("r&start_row.:r99999"))]";
        put '[edit.delete(3)]';
        put '[select("R1C1")]';
    run;
    filename cmdexcel clear;
%mend CLEAR_EXCEL;
%macro CLOSE_EXSEL_NOSAVE();
    filename cmdexcel dde 'excel|system';
    data _NULL_;
        file cmdexcel;
        put '[error(false)]';
        put '[file.close(0)]';
    run;
    filename cmdexcel clear;
%mend CLOSE_EXSEL_NOSAVE;
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
%macro EDIT_N_PER_2_1(input_ds, output_ds, target_var, sort_order, delimiter, mh_n, digit);
    /* N, PER */
    proc freq data=&input_ds. noprint;
       tables &target_var. / out=temp_ds;
    run;
    data &output_ds.;
        length STR_PER $200;
        set temp_ds;
        N=COUNT;
        if &mh_n.=0 then do;
          PER=round(PERCENT, 0.1);
          STR_PER=put(round(PERCENT, &digit.), 8.2);
        end;
        else do;
          PER=round((N/&mh_n.)*100, 0.1);
          STR_PER=put(round((N/&mh_n.)*100, &digit.), 8.2);
        end;
        keep &target_var. N PER STR_PER;
    run;
%mend EDIT_N_PER_2_1;
%macro EDIT_N_PER_3(input_ds, output_ds, target_var, weight_f=.);
    /* N, PER, 95%CI */
    %local format1 digit1;
    %let format1=8.2;
    %let digit1=0.01;
    %if &weight_f.=. %then %do;
      proc freq data=&input_ds. noprint;
          tables &target_var. / binomial(level='1');
          output out=temp_ds binomial;
      run;
    %end;
    %else %do;
      proc freq data=&input_ds. noprint;
          tables &target_var. /out=temp_freq_1;
      run;
      data ds_dummy;
          &target_var.='0';
          COUNT=0;
          output;
          &target_var.='1';
          COUNT=0;
          output;
      run;
      data temp_freq_2;
          merge ds_dummy temp_freq_1;
          by &target_var;
          drop PERCENT;
      run;
      proc freq data=temp_freq_2 noprint;
          tables &target_var. / binomial(level='1');
          exact binomial;
          weight COUNT / zeroes;
          output out=temp_ds binomial;
      run;
    %end;
    proc sql noprint;
        select count(*) into: target_n
        from &input_ds.
        where &target_var = '1';
    quit;
    data &output_ds.;
        set temp_ds;
        TARGET_N=&target_n.;
        if _BIN_^=. then do;
          temp_PER=_BIN_;
          temp_CI_L=XL_BIN;
          temp_CI_U=XU_BIN;
        end;
        else do;
          temp_PER=0;
          temp_CI_L=0;
          temp_CI_U=0;
        end;
        PER=put(round(temp_PER*100, &digit1.), &format1.);
        CI_L=put(round(temp_CI_L*100, &digit1.), &format1.);
        CI_U=put(round(temp_CI_U*100, &digit1.), &format1.);
        keep N TARGET_N PER CI_L CI_U;
    run;
%mend EDIT_N_PER_3;
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
%macro EDIT_MEANS(input_ds, output_ds, target_var, class_f=., class_var='');
    %local max_digit_count;
    %if &class_f.=. %then %do;
      proc means data=&input_ds.  noprint;
          var &target_var.;
          output out=temp_means n=n mean=temp_mean stddev=temp_sd median=temp_median min=min max=max;
      run;
    %end;
    %else %do;
      proc means data=&input_ds.  noprint;
          var &target_var.;
          class &class_var.;
          output out=temp_means n=n mean=temp_mean stddev=temp_sd median=temp_median min=min max=max;
      run;
    %end;
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
        if temp_sd^=. then do;
          sd=put(round(temp_sd, &digit2.), &format2.);
        end;
        else do;
          sd='-';
        end;
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
    %if &class_f=. %then %do;
      data &output_ds.;
          set temp_means_3;
          keep _NAME_ col1;
      run;
    %end;
    %else %do;
      data &output_ds.;
          set temp_means_3;
      run;
    %end;
%mend EDIT_MEANS;
%macro EDIT_T14_3_x();
    %local i j save_j;
    %do i=1 %to &row_cnt.;
      proc sql noprint;
          create table temp_join as
          select *
          from adae_soc_llt
          where N=&i.;

          create table temp_adae_&i._1 as
          select a.*, b.AESOC as temp_AESOC, b.AEDECOD as temp_AEDECOD
          from adae a left join temp_join b on a.AESOC = b.AESOC;

          create table temp_adae_&i._3 as
          select *
          from temp_adae_&i._1
          where (AESOC = temp_AESOC) and (AEDECOD = temp_AEDECOD);
      quit;
      data temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8;
          set temp_adae_&i._3;
          if AETOXGR=1 then output temp1;
          if AETOXGR=2 then output temp2;
          if AETOXGR=3 then output temp3;
          if AETOXGR=4 then output temp4;
          if AETOXGR=5 then output temp5;
          if (AETOXGR=3) or (AETOXGR=4) then output temp6;
          if AETOXGR>=3 then output temp7;
          output temp8;
      run;
      proc sort data=temp8 out=temp8 nodupkey; 
        by SUBJID; 
      run;
      %do j=1 %to 8;
        %EDIT_N_PER_2(temp&j., temp_output_&j._1, &target_flg., %str('Y, N'), ',', &N.);
        data temp_output_&j._2;
            set temp_output_&j._1;
            where val='Y';
            N_PER=CAT(N, ' (', strip(PER), ')');
            keep val N_PER;
        run;
        %if &j.>1 %then %do;
          proc sql noprint;
              create table temp_output_&j. as
              select a.*, b.N_PER as N_PER_&j.
              from temp_output_&save_j. a, temp_output_&j._2 b
              where a.val = b.val;
          quit;
        %end;
        %else %do;
          data temp_output_&j.;
              set temp_output_&j._2;
          run;
        %end;
        %let save_j=&j.; 
      %end;
      data output_&i.;
          set temp_output_8;
          drop val;
      run;
    %end;
%mend EDIT_T14_3_x;
%macro EDIT_T14_3_x_OBS_EMPTY();    
    %SUBJID_N(set_output_1, N, N);
    data set_output_2;
        N_PER_8='-';
        output;
    run;
    data set_output_3;
        output='Safety Analysis Set';
        output;
        output='No Events';
        output;
    run;
%mend EDIT_T14_3_x_OBS_EMPTY;
%macro EDIT_T14_3_x_MAIN(input_ds, n_input=.);
    %global row_cnt N;
    proc sql noprint;
        create table adae_soc as
        select distinct SUBJID, AESOC, '' as AEDECOD, &target_flg., AETOXGR
        from &input_ds.;

        create table adae as
        select *
        from adae_soc
        outer union corr
        select *
        from &input_ds.
        order by AESOC, AEDECOD;

        create table temp_adae_soc_llt as
        select distinct AESOC, AEDECOD
        from adae
        order by AESOC, AEDECOD;

        create table adae_soc_llt as
        select *, monotonic() as N
        from temp_adae_soc_llt;

        select count(*) into: row_cnt trimmed
        from adae_soc_llt;
    quit;
    
    %if &n_input.=. %then %do;
      %SUBJID_N(set_output_1, N, N);
    %end;
    %else %do;
      %OUTPUT_ANALYSIS_SET_N(&n_input., set_output_1, N, '');
      proc sql noprint;
          select count(*) into: N from &n_input.;
      quit;
    %end;
    %EDIT_T14_3_x;
    %if &row_cnt.>1 %then %do;
      data set_output_2;
          set output_1-output_&row_cnt.;
      run;
    %end;
    %else %do;
      data set_output_2;
          set output_1;
      run;
    %end;
    data temp_term_of_ae_1;
        length output $200;
        output='Safety Analysis Set';
    run;
    data temp_term_of_ae_2;
        length output $200;
        set adae_soc_llt;
        if AEDECOD='' then do;
          output=AESOC;
        end;
        else do;
          output=cat('Å@', strip(AEDECOD));
        end;
        keep output;
    run;
    data set_output_3;
        set temp_term_of_ae_1
            temp_term_of_ae_2;
    run;
%mend EDIT_T14_3_x_MAIN;
%macro SUBJID_N(output_ds, output_ds_var, output_var);
    proc sql noprint;
        create table subjid_list as
        select distinct SUBJID 
        from libinput.adsl
        where &target_flg. = 'Y';
    quit;
    %OUTPUT_ANALYSIS_SET_N(subjid_list, &output_ds., &output_ds_var., '');
    proc sql noprint;
        select &output_ds_var. into: &output_var. from &output_ds.;
    quit;
%mend SUBJID_N;
%macro READ_DEVIATIONS(output_ds);
    %local deviations_filename deviations deviations_sheetname;
    %let deviations_filename=INO-Ped-ALL-1_Table3_çÃî€åüì¢éëóøóp_àÌíEàÍóóç≈èIî≈.xlsx;
    %let deviations=&extpath.\&deviations_filename.;
    %let deviations_sheetname=çÃî€åüì¢éëóøóp_àÌíEàÍóóç≈èIî≈;
    %OPEN_EXCEL(&deviations.);
    filename cmdexcel dde "excel|[&deviations_filename.]&deviations_sheetname.!R2C1:R9999C4";
    data &output_ds.;
        length var1-var4 $200;
        infile cmdexcel notab dlm='09'x dsd missover lrecl=30000 firstobs=1;
        input var1-var4;
    run;
    filename cmdexcel clear;
    %CLOSE_EXSEL_NOSAVE;
%mend READ_DEVIATIONS;
%MACRO OUTPUT_FILE(output_file_name) ;

  DATA _NULL_ ;
       CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
       CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
  RUN ;

  DM OUTPUT "FILE '&outputpath.\&output_file_name..txt' REPLACE" ;
  DM "OUTPUT ; CLEAR ; LOG ; CLEAR ; " ;
%MEND ;
%MACRO SDTM_FIN(output_file_name) ;

  DATA _NULL_ ;
       CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
       CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
  RUN ;

  DM LOG "FILE '&LOG.\&FILE._&output_file_name._LOG_&_YYMM_._&_TIME_..txt' REPLACE" ;
  DM "OUTPUT ; CLEAR ; LOG ; CLEAR ; " ;
%MEND ;
%let inputpath=&projectpath.\input\ads;
%let extpath=&projectpath.\input\ext;
%let templatepath=&projectpath.\output\template;
%let outputpath=&projectpath.\output\QC;
%let log=&projectpath.\log\QC\result;
%let template_name_head=INO-Ped-ALL-1_STAT_RES_;
%let template_name_foot=.xlsx;
%let output_name_foot=_QC.xlsx;
%let file=DATA;
libname libin "&inputpath.";
libname libout "&outputpath.";
