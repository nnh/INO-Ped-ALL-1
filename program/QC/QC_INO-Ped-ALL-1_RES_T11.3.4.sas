**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T11.3.4.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-23
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
%macro EDIT_T11_3_4(target_var, target_ds);
    %local treatment_cnt;
    proc sql noprint;
        create table temp_treatment_list as
        select distinct &target_var.
        from temp_treatment
        order by &target_var.;

        select count(*),
               &target_var. 
        into:treatment_cnt,
            :treatment_1-:treatment_9999 
        from temp_treatment_list;
    quit;
    %do i=1 %to &treatment_cnt.;
      proc sql noprint;
          create table temp_treatment_list_2_&i. as
          select *
          from temp_treatment 
          where &target_var. = "&&treatment_&i.";
      quit;
      %EDIT_N_PER_2(temp_treatment_list_2_&i., temp_output_&i., AVALC, %str('Y, N'), ',', &N.);
      data output_&i.;
          format treatment N PER;
          length treatment $200;
          set temp_output_&i.;
          where val='Y';
          treatment="&&treatment_&i.";
          keep treatment N PER;
      run;
    %end;
    data output_&target_ds.;
        set output_1-output_%eval(&treatment_cnt.);
    run;
%mend EDIT_T11_3_4;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
%global N;
* Main processing start;
%let output_file_name=T11.3.4;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
data adcm;
    set libinput.adcm;
    where &target_flg.='Y';
run;
data adpr;
    set libinput.adpr;
    where &target_flg.='Y';
run;
%SUBJID_N(output_n, N, N);
proc sql noprint;
    create table temp_treatment as
    select distinct SUBJID, CMDECOD, 'Y' as AVALC
    from adcm
    where CMCAT = 'CONCOMITANT DRUG';    
quit;
%EDIT_T11_3_4(CMDECOD, cm);
proc sql noprint;
    create table temp_treatment as
    select distinct SUBJID, PRTRT, 'Y' as AVALC
    from adpr
    where PRCAT = 'COMBINATION THERAPY';    
quit;
%EDIT_T11_3_4(PRTRT, pr);
data output_ds;
    set output_cm output_pr;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_n, 6, 3, %str(N), &output_file_name.);
%SET_EXCEL(output_ds, 7, 2, %str(treatment N PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
