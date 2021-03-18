**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_F10.1.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-17
SAS version : 9.4
**************************************************************************;
proc datasets library=work kill nolist; quit;
options mprint mlogic symbolgen;
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
%macro SET_FIGURE1(input_ds, output_file_name, output_start_row, output_start_col, output_var);
    %local output_end_row output_end_col;
    %let output_end_row=&output_start_row.;
    %let output_end_col=&output_start_col.;
    filename cmdexcel dde "excel|&output_file_name.!R&output_start_row.C&output_start_col.:R&output_end_row.C&output_end_col.";
    data _NULL_;
        set &input_ds.;
        file cmdexcel dlm='09'X notab dsd;
        put &output_var.;
    run;
    filename cmdexcel clear; 
%mend SET_FIGURE1;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%let output_file_name=F10.1.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
libname libinput "&inputpath." ACCESS=READONLY;
data adsl;
    set libinput.adsl;
run;
data adds;
    set libinput.adds;
run;
proc sql noprint;
    create table adsl_adds_discon as
    select a.*, b.PARAM, b.PARAMCD, b.AVALC
    from adsl a left join (select * from adds where PARAMCD = 'DISCON') b on a.SUBJID = b.SUBJID;
quit;
proc sql noprint;
    create table ds_registration as
    select * from adsl_adds_discon;

    create table registration as
    select count(*) as cnt 
    from ds_registration;
quit;
proc sql noprint;
    create table ds_not_met as
    select * from ds_registration
    where IETESTCD is not missing;

    create table not_met as
    select count(*) as cnt
    from ds_not_met;

    create table not_met_by_code as
    select count(*) as cnt
    from ds_not_met
    where IETESTCD ='IN06';
quit;
proc sql noprint;
    create table ds_eligible as
    select a.*
    from ds_registration a
    where not exists (select SUBJID from ds_not_met b where a.SUBJID = b.SUBJID);
    
    create table eligible as
    select count(*) as cnt
    from ds_eligible;
quit;
proc sql noprint;
    create table ds_not_treatment as
    select *
    from ds_eligible
    where TRTSDT is missing;

    create table not_treatment as
    select count(*) as cnt
    from ds_not_treatment;
quit;
proc sql noprint;
    create table ds_treatment as
    select a.*
    from ds_eligible a
    where not exists (select SUBJID from ds_not_treatment b where a.SUBJID = b.SUBJID);

    create table treatment as
    select count(*) as cnt
    from ds_treatment;
quit;
proc sql noprint;
    create table ds_discontinuation as
    select *
    from ds_treatment
    where AVALC ^= 'COMPLETED';

    create table discontinuation as
    select count(*) as cnt
    from ds_discontinuation;

    create table discontinuation_by_code as
    select count(*) as cnt
    from ds_discontinuation
    where AVALC = 'LACK OF EFFICACY';
quit;
proc sql noprint;
    create table ds_completion as
    select a.*
    from ds_treatment a
    where not exists (select SUBJID from ds_discontinuation b where a.SUBJID = b.SUBJID);

    create table completion as
    select count(*) as cnt
    from ds_completion;
quit;
%OPEN_EXCEL(&template.);
%SET_FIGURE1(registration, &output_file_name., 5, 3, %str(cnt));
%SET_FIGURE1(registration, &output_file_name., 6, 3, %str(cnt));
%SET_FIGURE1(not_met, &output_file_name., 9, 8, %str(cnt));
%SET_FIGURE1(not_met, &output_file_name., 10, 8, %str(cnt));
%SET_FIGURE1(not_met_by_code, &output_file_name., 11, 8, %str(cnt));
%SET_FIGURE1(eligible, &output_file_name., 13, 3, %str(cnt));
%SET_FIGURE1(eligible, &output_file_name., 14, 3, %str(cnt));
%SET_FIGURE1(not_treatment, &output_file_name., 17, 8, %str(cnt));
%SET_FIGURE1(not_treatment, &output_file_name., 18, 8, %str(cnt));
%SET_FIGURE1(treatment, &output_file_name., 20, 3, %str(cnt));
%SET_FIGURE1(treatment, &output_file_name., 21, 3, %str(cnt));
%SET_FIGURE1(discontinuation, &output_file_name., 24, 8, %str(cnt));
%SET_FIGURE1(discontinuation, &output_file_name., 25, 8, %str(cnt));
%SET_FIGURE1(discontinuation_by_code, &output_file_name., 26, 8, %str(cnt));
%SET_FIGURE1(completion, &output_file_name., 28, 3, %str(cnt));
%SET_FIGURE1(completion, &output_file_name., 29, 3, %str(cnt));
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
