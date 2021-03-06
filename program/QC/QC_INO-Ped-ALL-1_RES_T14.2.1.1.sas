**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.2.1.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-2-24
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
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%let output_file_name=T14.2.1.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=PPSFL;
libname libinput "&inputpath." ACCESS=READONLY;
data adrs;
    set libinput.adrs;
    where &target_flg.='Y';
run;
data temp_adrs_1;
    set adrs;
    where PARAMCD='BESTRESP';
    if AVALC='CR' then do;
      CR='1';
    end;
    else do;
      CR='0';
    end;
    if AVALC='CRi' then do;
      CRI='1';
    end;
    else do;
      CRI='0';
    end;
    if CR='1' or CRI='1' then do;
      CR_CRI='1';
    end;
    else do;
      CR_CRI='0';
    end;
run;
%EDIT_N_PER_3(temp_adrs_1, output_1, CR_CRI);
%EDIT_N_PER_3(temp_adrs_1, output_2, CR);
%EDIT_N_PER_3(temp_adrs_1, output_3, CRI);
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_1, 8, 3, %str(N TARGET_N PER CI_L CI_U), &output_file_name.);
%SET_EXCEL(output_2, 13, 3, %str(N TARGET_N PER CI_L CI_U), &output_file_name.);
%SET_EXCEL(output_3, 18, 3, %str(N TARGET_N PER CI_L CI_U), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
