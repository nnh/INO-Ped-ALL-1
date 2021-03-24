**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.2.1.2.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-24
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
%macro EDIT_T14_2_1_2();
    %do i=1 %to &max_cycle.;
      %let visitn=%eval((&i.+1)*100);
      data temp_adrs_n_&i. temp_adrs_&i.;
          set adrs;
          OVRLRESP='Y';
          if (AVISITN=&visitn.) then output temp_adrs_n_&i.;
          if ((AVISITN=&visitn.) and ((AVALC = 'CR') or (AVALC = 'CRi'))) then output temp_adrs_&i.;
      run;
      %OUTPUT_ANALYSIS_SET_N(temp_adrs_n_&i., output_n_&i., N, '');
      proc sql noprint;
          select count(*) into:N from temp_adrs_n_&i.;
      quit;
      %EDIT_N_PER_2_1(temp_adrs_&i., output_&i., OVRLRESP, %str('Y, N'), ',', &N., 0.01);
    %end;
    data output_n;
        set output_n_1-output_n_%eval(&max_cycle.);
    run;
    data output_ds;
        set output_1-output_%eval(&max_cycle.);
        where OVRLRESP = 'Y';
    run;
%mend EDIT_T14_2_1_2;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
%global N;
* Main processing start;
%let output_file_name=T14.2.1.2;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=PPSFL;
libname libinput "&inputpath." ACCESS=READONLY;
data adrs;
    set libinput.adrs;
    where ((&target_flg.='Y') and (PARAMCD = 'OVRLRESP'));
run;
proc sql noprint;
    select ((max(AVISITN)/100) - 1) into:max_cycle from adrs;
quit;
%EDIT_T14_2_1_2();
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_n, 8, 4, %str(N), &output_file_name.);
%SET_EXCEL(output_ds, 8, 5, %str(N STR_PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
