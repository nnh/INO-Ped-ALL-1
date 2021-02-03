**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T11.1.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-2-3
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
libname libinput "&inputpath." ACCESS=READONLY;
data adsl;
    set libinput.adsl;
run;
proc freq data=adsl noprint;
    tables SAFFL / out=ds_saffl;
run;
proc freq data=adsl noprint;
    tables FASFL / out=ds_fasfl;
run;
proc freq data=adsl noprint;
    tables PPSFL / out=ds_ppsfl;
run;
proc freq data=adsl noprint;
    tables DLTFL / out=ds_dltfl;
run;
proc freq data=adsl noprint;
    tables PKFL / out=ds_pkfl;
run;
proc freq data=adsl noprint;
    tables ADAFL / out=ds_adafl;
run;
%macro EDIT_N_PER(input_ds, output_ds, target_var);
    data temp_ds;
        set &input_ds.;
        N_PER=CAT(strip(COUNT),' (',strip(round(PERCENT, 0.1)),')');
    run;
    proc sql noprint;
        create table &output_ds. as
        select N_PER from temp_ds order by &target_var. desc;
    quit;
%mend EDIT_N_PER;
data output_1;
    length N_PER $200.;
    set adsl nobs=NOBS;
    N_PER=NOBS;
    keep N_PER;
run;
proc sort data=output_1 out=output_1 nodupkey; 
    by N_PER; 
run;
%EDIT_N_PER(ds_saffl, output_2, SAFFL);
%EDIT_N_PER(ds_fasfl, output_3, FASFL);
%EDIT_N_PER(ds_ppsfl, output_4, PPSFL);
%EDIT_N_PER(ds_dltfl, output_5, DLTFL);
%EDIT_N_PER(ds_pkfl, output_6, PKFL);
%EDIT_N_PER(ds_adafl, output_7, ADAFL);
data output_ds;
    set output_1
        output_2
        output_3
        output_4
        output_5
        output_6
        output_7;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_ds, 7, 3, %str(N_PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
