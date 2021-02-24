**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T11.1.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-2-24
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
* Main processing start;
%let output_file_name=T11.1.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg='';
libname libinput "&inputpath." ACCESS=READONLY;
data adsl;
    set libinput.adsl;
run;
%macro EDIT_T11_1_1();
    %local seq i cnt ds_names ds_cnt;
    %let ds_names=%str(SAFFL, FASFL, PPSFL, DLTFL, PKFL, ADAFL);
    %let cnt=%sysfunc(countc(&ds_names., ','));
    %let ds_cnt=%eval(&cnt+1);
    %OUTPUT_ANALYSIS_SET_N(adsl, output_n, N, 'CHAR');
    %do i=1 %to &ds_cnt.;
      %let val=%sysfunc(strip(%scan(&ds_names., &i., ',')));
      %EDIT_N_PER_2(adsl, temp_output_&i._1, &val., %str('Y, N'), ',', 0);
      data output_&i.;
          set temp_output_&i._1;
          N_PER=cat(N, ' (', strip(PER), ')');
          keep N_PER;
      run;
    %end;
    data output_ds;
        set output_1-output_&ds_cnt.;
    run;
%mend EDIT_T11_1_1;
%EDIT_T11_1_1;
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_n, 7, 3, %str(N), &output_file_name.);
%SET_EXCEL(output_ds, 8, 3, %str(N_PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
