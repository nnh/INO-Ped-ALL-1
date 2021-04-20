**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.27.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-4-19
SAS version : 9.4
**************************************************************************;
proc datasets library=work kill nolist; quit;
options mprint mlogic symbolgen noquotelenmax;
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
%macro EDIT_T14_3_27(input_ds);
    %local i j k temp_cnt N worst_1 worst_total target_ds;
    %let worst_1=4;
    %let worst_total=9; 
    proc sql noprint;
        create table temp_avisit_list_1 as
        select distinct AVISIT, AVISITN, ATPT, ATPTN
        from &input_ds.
        where AVISITN > 100 and AVISITN < 200
        order by AVISITN, ATPTN;

        create table temp_avisit_list_2 as
        select distinct AVISIT, AVISITN, ATPT, ATPTN
        from &input_ds.
        where AVISITN > 200
        order by AVISITN, ATPTN;
    quit;
    data temp_avisit_list_1_worst;
        length AVISIT $200 ATPT $200;
        AVISIT='1(Worst Value)';
        AVISITN=199;
        ATPT='';
        ATPTN=0;
        output;
    run;
    data temp_avisit_list_worst;
        length AVISIT $200 ATPT $200;
        AVISIT='Worst Value';
        AVISITN=999;
        ATPT='';
        ATPTN=0; output;
    run;
    data avisit_list;
        set temp_avisit_list_1 temp_avisit_list_1_worst temp_avisit_list_2 temp_avisit_list_worst;
    run;
    proc sql noprint;
        select PARAM, count(PARAM) into: test_1-:test_99, :test_cnt from test_param_list;
        select AVISITN, count(AVISITN), ATPTN into: avisit_1-:avisit_99, :avisit_cnt, :atptn_1-:atptn_99 from avisit_list;
    quit; 
    %do i=1 %to &test_cnt.;
      %do j=1 %to &avisit_cnt.;
        %if &j.=&worst_1. %then %do;
          %let temp_target=&&test_&i.;
          %let target_ds=&temp_target._worst_1;
        %end;
        %else %if &j.=&worst_total. %then %do;
          %let temp_target=&&test_&i.;
          %let target_ds=&temp_target._worst_total;
        %end;
        %else %do;
          %let target_ds=&&test_&i.;
        %end;
        proc sql noprint;
            select count(*) into:N from &target_ds. where AVISITN=&&avisit_&j. and ATPTN=&&atptn_&j.;
        quit;
        data temp_&input_ds._&i._&j._1 temp_&input_ds._&i._&j._2 temp_&input_ds._&i._&j._3 temp_&input_ds._&i._&j._4
             temp_&input_ds._&i._&j._5 temp_&input_ds._&i._&j._6 temp_&input_ds._&i._&j._7; 
            set &target_ds.;
            output_f='Y';
            if AVAL<=0.450 and AVISITN=&&avisit_&j. and ATPTN=&&atptn_&j. then output temp_&input_ds._&i._&j._1;
            if AVAL>0.450 and AVAL<=0.480 and AVISITN=&&avisit_&j. and ATPTN=&&atptn_&j. then output temp_&input_ds._&i._&j._2;
            if AVAL>0.480 and AVAL<=0.500 and AVISITN=&&avisit_&j. and ATPTN=&&atptn_&j. then output temp_&input_ds._&i._&j._3;
            if AVAL>0.500 and AVISITN=&&avisit_&j. and ATPTN=&&atptn_&j. then output temp_&input_ds._&i._&j._4;
            if (AVAL-BASE)<=0.03 and AVISITN=&&avisit_&j. and ATPTN=&&atptn_&j. then output temp_&input_ds._&i._&j._5;
            if (AVAL-BASE)>0.03 and (AVAL-BASE)<=0.06 and AVISITN=&&avisit_&j. and ATPTN=&&atptn_&j. then output temp_&input_ds._&i._&j._6;
            if (AVAL-BASE)>=0.06 and AVISITN=&&avisit_&j. and ATPTN=&&atptn_&j. then output temp_&input_ds._&i._&j._7;
        run;
        %do k=1 %to 7;
          %EDIT_N_PER_2(temp_&input_ds._&i._&j._&k., n_per_&input_ds._&i._&j._&k., output_f, %str('Y, N'), ',', &N.);
          data output_&i._&j._&k.;
              set n_per_&input_ds._&i._&j._&k.;
              where val='Y';
              output=CAT(strip(N),' (',strip(put(round(PER, 0.1), 8.1)),')');
              keep output;
          run;
        %end;
        data output_&i._&j.;
            set output_&i._&j._1-output_&i._&j._4;
        run;
        data output_base_&i._&j.;
            set output_&i._&j._5-output_&i._&j._7;
        run;
      %end;
    %end;
%mend EDIT_T14_3_27;
%macro SET_EXCEL_T14_3_27();
    %local i j output_row output_col;
    %do i=1 %to &test_cnt.;
      %let output_row=%eval(7+(&i.-1)*9);
      %do j=1 %to &avisit_cnt.;
        %let output_col=%eval(3+&j.);
        %SET_EXCEL(output_&i._&j., &output_row., &output_col., %str(output), &output_file_name.);
        %if &j.^=1 %then %do;
          %SET_EXCEL(output_base_&i._&j., %eval(&output_row.+6), &output_col., %str(output), &output_file_name.);
        %end;
      %end;
    %end;
%mend SET_EXCEL_T14_3_27;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%global test_cnt avisit_cnt;
%let output_file_name=T14.3.27;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
%let input_ds=adeg;
data &input_ds.;
    set libinput.&input_ds.;
    where &target_flg.='Y';
run;
data qt qtcb qtcf;
    set &input_ds.;
    if PARAMCD='QTINTNOS' then output qt;
    if PARAMCD='QTCB' then output qtcb;
    if PARAMCD='QTCF' then output qtcf;
run;
proc sql noprint;
    create table temp_worst_1 as
    select SUBJID, PARAMCD, max(AVAL) as AVAL
    from &input_ds. 
    where AVISITN = 101
    group by SUBJID, PARAMCD;

    create table worst_1 as
    select distinct a.SUBJID, a.PARAMCD, a.AVAL, a.BASE, 199 as AVISITN, '' as ATPT, 0 as ATPTN
    from &input_ds. a, temp_worst_1 b
    where (a.SUBJID = b.SUBJID) and
          (a.PARAMCD = b.PARAMCD) and
          (a.AVAL = b.AVAL);
quit;
data qt_worst_1 qtcb_worst_1 qtcf_worst_1;
    set worst_1;
    if PARAMCD='QTINTNOS' then output qt_worst_1;
    if PARAMCD='QTCB' then output qtcb_worst_1;
    if PARAMCD='QTCF' then output qtcf_worst_1;
run;
proc sql noprint;
    create table temp_worst_total as
    select SUBJID, PARAMCD, max(AVAL) as AVAL
    from &input_ds. 
    group by SUBJID, PARAMCD;

    create table worst_total as
    select distinct a.SUBJID, a.PARAMCD, a.AVAL, a.BASE, 999 as AVISITN, '' as ATPT, 0 as ATPTN
    from &input_ds. a, temp_worst_total b
    where (a.SUBJID = b.SUBJID) and
          (a.PARAMCD = b.PARAMCD) and
          (a.AVAL = b.AVAL);
quit;
data qt_worst_total qtcb_worst_total qtcf_worst_total;
    set worst_total;
    if PARAMCD='QTINTNOS' then output qt_worst_total;
    if PARAMCD='QTCB' then output qtcb_worst_total;
    if PARAMCD='QTCF' then output qtcf_worst_total;
run;
data test_param_list;
    length PARAM $200;
    PARAM='qt'; output;
    PARAM='qtcb'; output;
    PARAM='qtcf'; output;
run;
%EDIT_T14_3_27(&input_ds.);
%OPEN_EXCEL(&template.);
%SET_EXCEL_T14_3_27();
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
