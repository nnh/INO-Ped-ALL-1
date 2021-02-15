**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-2-15
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
%macro EDIT_T14_3_1(input_ds, temp_n);
    %let seq=%eval(&seq.+1); 
    %EDIT_N_PER_2(&input_ds., temp_output_&seq., &target_flg., %str('Y, N'), ',', &temp_n.);
    data output_&seq.;
        set temp_output_&seq.;
        where val='Y';
    run;
%mend EDIT_T14_3_1;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%global seq N;
%let output_file_name=T14.3.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
data adae;
    set libinput.adae;
    where &target_flg.='Y';
run;
%let seq=1; 
proc sql noprint;
    create table temp_adae_1 as
    select distinct SUBJID ,&target_flg.
    from adae;
quit;
%OUTPUT_ANALYSIS_SET_N(temp_adae_1, output_&seq., N, '');
data _NULL_;
    set output_&seq.;
    call symput('N', n);
run;
%let seq=%eval(&seq.+1); 
%OUTPUT_ANALYSIS_SET_N(adae, output_&seq., N, '');
%EDIT_T14_3_1(temp_adae_1, 0);
proc sql noprint;
    create table adae_reaction as
    select distinct SUBJID, &target_flg.
    from adae
    where AERELN = 1;
quit;
%EDIT_T14_3_1(adae_reaction, &N.);
proc sql noprint;
    create table adae_sae as
    select distinct SUBJID, &target_flg.
    from adae
    where AESER = 'Y';
quit;
%EDIT_T14_3_1(adae_sae, &N.);
proc sql noprint;
    create table adae_grade3_4 as
    select distinct SUBJID, &target_flg.
    from adae
    where (AETOXGR = 3) or (AETOXGR = 4);
quit;
%EDIT_T14_3_1(adae_grade3_4, &N.);
proc sql noprint;
    create table adae_grade3_5 as
    select distinct SUBJID, &target_flg.
    from adae
    where AETOXGR >= 3;
quit;
%EDIT_T14_3_1(adae_grade3_5, &N.);
proc sql noprint;
    create table adae_grade5 as
    select distinct SUBJID, &target_flg.
    from adae
    where AETOXGR = 5;
quit;
%EDIT_T14_3_1(adae_grade5, &N.);
proc sql noprint;
    create table adae_dose_discontinuation as
    select distinct SUBJID, &target_flg.
    from adae
    where AEACN = 'DRUG WITHDRAWN';
quit;
%EDIT_T14_3_1(adae_dose_discontinuation, &N.);
proc sql noprint;
    create table adae_dose_reduction as
    select distinct SUBJID, &target_flg.
    from adae
    where AEACN = 'DOSE REDUCED';
quit;
%EDIT_T14_3_1(adae_dose_reduction, &N.);
proc sql noprint;
    create table adae_dose_delay as
    select distinct SUBJID, &target_flg.
    from adae
    where AEACN = 'DRUG INTERRUPTED';
quit;
%EDIT_T14_3_1(adae_dose_delay, &N.);
proc sql noprint;
    create table adae_dose_delay_and_reduction as
    select distinct SUBJID, &target_flg.
    from adae
    where (AEACN = 'DRUG INTERRUPTED') or (AEACN = 'DOSE REDUCED');
quit;
%EDIT_T14_3_1(adae_dose_delay_and_reduction, &N.);
%OPEN_EXCEL(&template.);
data set_output_1;
    set output_1 output_2;
run;
%SET_EXCEL(set_output_1, 6, 3, %str(N), &output_file_name.);
data set_output_2;
    set output_3-output_12;
run;
%SET_EXCEL(set_output_2, 8, 3, %str(N PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
