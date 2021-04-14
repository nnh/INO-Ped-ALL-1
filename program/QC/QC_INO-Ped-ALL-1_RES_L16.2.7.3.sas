DATA _NULL_ ;
     CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
     CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
RUN ;
proc printto log="\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\log\QC\result\DATA_L16.2.7.3_LOG_&_YYMM_._&_TIME_..txt" new;
run;
**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_L16.2.7.3.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-4-14
SAS version : 9.4
**************************************************************************;
proc datasets library=work kill nolist; quit;
options nomprint nomlogic nosymbolgen noquotelenmax;
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
%macro EDIT_L16_2_7_3(input_ds);
    %local i j k;
    proc sql noprint;
        select PARAM, count(PARAM) into: test_1-:test_99, :test_cnt from test_param_list;
        select SUBJID, count(SUBJID) into:subjid_1-:subjid_99, :subjid_cnt from subjid_list;
    quit; 
    %do i=1 %to &subjid_cnt.;
      proc sql noprint;
          create table id_sex_&i. as
          select distinct SUBJID, SEX
          from &input_ds.
          where SUBJID = "&&subjid_&i.";

          create table temp_&input_ds._&i. as
          select SUBJID, SEX, AVISIT, AVISITN, PARAM, PARAMCD, AVAL, AVALC, ATPT, ATPTN
          from &input_ds.
          where SUBJID = "&&subjid_&i."
          order by PARAMCD, AVISITN, ATPTN;

          create table temp_avisit_&i. as
          select distinct AVISIT, AVISITN, ATPT, ATPTN
          from temp_&input_ds._&i.
          where AVISITN ^= .
          order by AVISITN, ATPTN;

          select AVISIT, count(*), ATPT into:avisit_1-:avisit_99, :avisit_cnt, :atpt_1-:atpt_99 from temp_avisit_&i.;
      quit;
      %do j=1 %to &avisit_cnt.;
        data temp_&input_ds._&i._&j.;
            set temp_&input_ds._&i.;
            where AVISIT="&&avisit_&j." and ATPT="&&atpt_&j.";
        run;
        %do k=1 %to &test_cnt.;
          data temp_&input_ds._&i._&j._&k.;
              set temp_&input_ds._&i._&j.;
              where PARAM="&&test_&k.";
              keep AVAL;
          run;
          proc sql noprint;
              select count(*) into:temp_row_cnt from temp_&input_ds._&i._&j._&k.;
              %if &temp_row_cnt. = 0 %then %do;
                data temp_&input_ds._&i._&j._&k.;
                  AVAL=.;
                run;
              %end;
          quit;
        %end;
      %end;
    %end;
%mend EDIT_L16_2_7_3;
%macro SET_EXCEL_L16_2_7_3();
    %local i j k output_row output_col temp_avisit_cnt;
    %let output_row=5;
    %do i=1 %to &subjid_cnt.;
      %SET_EXCEL(id_sex_&i., %eval(&output_row.+1), 2, %str(SUBJID SEX), &output_file_name.); 
      %SET_EXCEL(temp_avisit_&i., %eval(&output_row.+1), 4, %str(AVISIT ATPT), &output_file_name.); 
      proc sql noprint;
          select count(*) into: temp_avisit_cnt from temp_avisit_&i.;
      quit;
      %do j=1 %to &temp_avisit_cnt.;
        %let output_row=%eval(&output_row.+1);
        %do k=1 %to &test_cnt.;
          %let output_col=%eval(6+(&k.-1));
            %SET_EXCEL(temp_target_&input_ds._&i._&j._&k., &output_row., &output_col., %str(AVAL), &output_file_name.);
        %end;
      %end;
    %end;
%mend SET_EXCEL_L16_2_7_3;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%global test_cnt avisit_cnt subjid_cnt;
%let output_file_name=L16.2.7.3;
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
data test_param_list;
    length PARAM $200;
    PARAM = 'QT Interval Not Otherwise Specified (sec)'; output;
    PARAM = 'QTcB (sec)'; output;
    PARAM = 'QTcF (sec)'; output;
    PARAM = 'QRS Interval Not Otherwise Specified (sec)'; output;
    PARAM = 'PR Interval Not Otherwise Specified (sec)'; output;
    PARAM = 'RR Interval Not Otherwise Specified (sec)'; output;
run;
proc sql noprint;
    create table subjid_list as
    select distinct SUBJID
    from &input_ds.
    order by SUBJID;
quit;
proc sql noprint;
    create table temp_&input_ds. as
    select * 
    from &input_ds.
    where PARAM in (select PARAM from test_param_list);
quit;
data target_&input_ds.;
    set temp_&input_ds.(rename=(AVAL=temp_aval));
    AVAL=temp_aval*1000;
    drop temp_aval;
run;
%EDIT_L16_2_7_3(target_&input_ds.);
%OPEN_EXCEL(&template.);
%CLEAR_EXCEL(&output_file_name., 6);
%SET_EXCEL_L16_2_7_3();
%OUTPUT_EXCEL(&output.);
proc printto;
run;

