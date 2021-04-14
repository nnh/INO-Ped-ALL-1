DATA _NULL_ ;
     CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
     CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
RUN ;
proc printto log="\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\log\QC\result\DATA_L16.2.7.5_LOG_&_YYMM_._&_TIME_..txt" new;
run;
**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_L16.2.7.5.sas
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
%macro EDIT_L16_2_7_5(input_ds);
    %local i subjid_cnt;
    proc sql noprint;
        select subjid, count(*) into:subjid_1-:subjid_99, :subjid_cnt from subjid_list;
    quit;
    %do i = 1 %to &subjid_cnt.;
      proc sql noprint;
          select count(*)-1 into:row_cnt from &input_ds. where SUBJID = "&&subjid_&i.";
      quit;
      data subjid_&i.;
        DOSELEVEL=1;
        SUBJID="&&subjid_&i.";
        output;
        do i=1 to &row_cnt.;
          DOSELEVEL=.;
          SUBJID='';
          output;
        end;
        drop i;
      run;
    %end;
    data output_subjid;
        set subjid_1-subjid_%eval(&subjid_cnt.);
    run;
%mend EDIT_L16_2_7_5;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%global test_cnt avisit_cnt subjid_cnt;
%let output_file_name=L16.2.7.5;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
%let input_ds=adpr;
data &input_ds.;
    set libinput.&input_ds.;
    where &target_flg.='Y';
run;
proc sql noprint;
    create table subjid_list as
    select distinct SUBJID
    from &input_ds.
    order by SUBJID;
quit;
proc sql noprint;
    create table target_&input_ds. as
    select SUBJID, PRCAT, PRTRT, ASTDT, AENDT 
    from &input_ds.
    where PRCAT = 'PRIOR THERAPY' or PRCAT = 'COMBINATION THERAPY'
    order by SUBJID, PRCAT, ASTDT, AENDT;
quit;
%EDIT_L16_2_7_5(target_&input_ds.);
%OPEN_EXCEL(&template.);
%CLEAR_EXCEL(&output_file_name., 6);
%SET_EXCEL(output_subjid, 6, 2, %str(DOSELEVEL SUBJID), &output_file_name.); 
%SET_EXCEL(target_&input_ds., 6, 4, %str(PRCAT PRTRT ASTDT AENDT), &output_file_name.); 
%OUTPUT_EXCEL(&output.);
proc printto;
run;

