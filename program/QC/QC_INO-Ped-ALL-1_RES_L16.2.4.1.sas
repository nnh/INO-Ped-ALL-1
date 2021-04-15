DATA _NULL_ ;
     CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
     CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
RUN ;
proc printto log="\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\log\QC\result\DATA_L16.2.4.1_LOG_&_YYMM_._&_TIME_..txt" new;
run;
**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_L16.2.4.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-4-15
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
%macro ROW_COUNT(input_ds, output_ds);
    proc sql noprint;
        create table &output_ds. as
        select SUBJID, count(*) as row_cnt
        from &input_ds.
        group by SUBJID;
    quit;
%mend ROW_COUNT;
%macro EDIT_L16_2_4_1();
    %local subjid_cnt i;
    proc sql noprint;
        select SUBJID, count(*), row_cnt into:subjid_1-:subjid_99, :subjid_cnt, :row_cnt_1-:row_cnt_99 from row_cnt;
    quit;
    %do i=1 %to &subjid_cnt.;
      data temp_output_&i._1;
          do i=1 to &&row_cnt_&i.;
            temp=''; output;
          end;
          drop i;
      run;
      data temp_output_&i._2;
          set output_&input_ds;
          where SUBJID="&&subjid_&i.";
          drop SUBJID;
      run;
      data temp_output_&i._3;
          set subjid_list;
          where SUBJID="&&subjid_&i.";
      run;
      data output_&i.;
        merge temp_output_&i._1 temp_output_&i._2 temp_output_&i._3;
      run;      
    %end;
    data output;
        set output_1-output_%eval(&subjid_cnt.);
    run;
%mend EDIT_L16_2_4_1;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%let output_file_name=L16.2.4.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=.;
libname libinput "&inputpath." ACCESS=READONLY;
%let input_ds=adec;
data &input_ds.;
    set libinput.&input_ds.;
run;
proc sql noprint;
    create table dose as
    select SUBJID, AVISIT, ASTDT, AVAL, 'mg/m2' as UNIT, '' as INT, '' as RES, 1 as SEQ, AVISITN 
    from &input_ds.
    where PARAMCD='DOS'
    order by SUBJID, AVISITN;

    create table int as
    select SUBJID, AVALC, AVISIT, PARAMCD, AVISITN
    from &input_ds.
    where PARAMCD='INT'
    order by SUBJID, AVISITN;
    create table res as
    select SUBJID, AVALC, AVISIT, PARAMCD, AVISITN
    from &input_ds.
    where PARAMCD='RES'
    order by SUBJID, AVISITN;
    create table int_res as
    select a.SUBJID, a.AVISIT, . as ASTDT, . as AVAL, '' as UNIT, a.AVALC as INT, b.AVALC as RES, 2 as SEQ, A.AVISITN 
    from int a, res b
    where a.SUBJID = b.SUBJID and
          a.AVISITN = b.AVISITN
    order by SUBJID, a.AVISITN;

    create table output_&input_ds as
    select * from DOSE
    outer union corr
    select * from INT_RES
    order by SUBJID, AVISITN, SEQ;

    create table subjid_list as
    select distinct 1 as DOSELEVEL, SUBJID, SITENM, AGE, SEX
    from &input_ds.
    order by SUBJID;
quit;
%ROW_COUNT(output_&input_ds., row_cnt);
%EDIT_L16_2_4_1;
%OPEN_EXCEL(&template.);
%CLEAR_EXCEL(&output_file_name., 7);
%SET_EXCEL(output, 7, 2, %str(DOSELEVEL SUBJID SITENM AGE SEX AVISIT ASTDT AVAL UNIT INT RES), &output_file_name.); 
%OUTPUT_EXCEL(&output.);
proc printto;
run;
