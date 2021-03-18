**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T11.3.3.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-18
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
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
%global N;
* Main processing start;
%let output_file_name=T11.3.3;
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
proc sql noprint;
    create table temp_adcm_1 as
    select distinct SUBJID, CMDECOD, 'Y' as AVALC
    from adcm
    where CMCAT = 'PRIOR TREATMENT';

    create table treatment_list as
    select distinct CMDECOD
    from temp_adcm_1
    order by CMDECOD;

    select count(*),
           CMDECOD 
    into:treatment_cnt,
        :treatment_1-:treatment_9999 
    from treatment_list;
quit;
%SUBJID_N(output_n, N, N);
%macro EDIT_T11_3_3();
    %do i=1 %to &treatment_cnt.;
      proc sql noprint;
          create table temp_adcm_2_&i. as
          select *
          from temp_adcm_1 
          where CMDECOD = "&&treatment_&i.";
      quit;
      %EDIT_N_PER_2(temp_adcm_2_&i., temp_output_&i., AVALC, %str('Y, N'), ',', &N.);
      data output_&i.;
          format treatment N PER;
          length treatment $200;
          set temp_output_&i.;
          where val='Y';
          treatment="&&treatment_&i.";
          keep treatment N PER;
      run;
    %end;
    data output_ds;
        set output_1-output_%eval(&treatment_cnt.);
    run;
%mend EDIT_T11_3_3;
%EDIT_T11_3_3();
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_n, 6, 3, %str(N), &output_file_name.);
%SET_EXCEL(output_ds, 7, 2, %str(treatment N PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
