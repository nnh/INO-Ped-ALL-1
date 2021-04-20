DATA _NULL_ ;
     CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
     CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
RUN ;
proc printto log="\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\log\QC\result\DATA_L16.2.2.1_LOG_&_YYMM_._&_TIME_..txt" new;
run;
**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_L16.2.2.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-4-19
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
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%let output_file_name=L16.2.2.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=.;
%let deviations_filename=INO-Ped-ALL-1_Table3_採否検討資料用_逸脱一覧最終版.xlsx;
%let deviations=&extpath.\&deviations_filename.;
%let deviations_sheetname=採否検討資料用_逸脱一覧最終版;
libname libinput "&inputpath." ACCESS=READONLY;
%let input_ds=adsl;
data &input_ds.;
    set libinput.&input_ds.;
run;
%OPEN_EXCEL(&deviations.);
filename cmdexcel dde "excel|[&deviations_filename.]&deviations_sheetname.!R2C1:R9999C4";
data raw_deviations;
    length var1-var4 $200;
    infile cmdexcel notab dlm='09'x dsd missover lrecl=30000 firstobs=1;
    input var1-var4;
run;
filename cmdexcel clear;
%CLOSE_EXSEL_NOSAVE;
proc sql noprint;
    create table deviations as
    select input(var1, best12.) as SUBJID, var2 as TIMEPOINT, var3 as CONTENTS, var4 as DETAILS
    from raw_deviations;
quit;
proc sql noprint;
    create table subjid_list as
    select distinct cats('INO-Ped-ALL-1-', SUBJID) as SUBJID, input(SUBJID, best12.) as SUBJID_N, SEX, AGE, SITENM
    from &input_ds.
    order by SUBJID_N;
quit;
proc sql noprint;
    create table output_deviations as
    select a.SUBJID, 1 as DOSELEVEL, a.SEX, a.AGE, a.SITENM, b.TIMEPOINT, b.CONTENTS, b.DETAILS
    from subjid_list a, deviations b
    where a.SUBJID_N = b.SUBJID;
quit;
%OPEN_EXCEL(&template.);
%CLEAR_EXCEL(&output_file_name., 6);
%SET_EXCEL(output_deviations, 6, 2, %str(SUBJID DOSELEVEL SEX AGE SITENM TIMEPOINT CONTENTS DETAILS), &output_file_name.); 
%OUTPUT_EXCEL(&output.);
proc printto;
run;

