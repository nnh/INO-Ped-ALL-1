**************************************************************************
Program Name : QC_INO-Ped-ALL-1_CC_TABLE1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-1-15
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
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_CC_LIBNAME.sas";
* Main processing start;
%let output_file_name=Table1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
libname libinput "&inputpath." ACCESS=READONLY;
data &output_file_name.;
    format SUBJID DOSELEVEL SITENM SEX AGE ASTDT ASTDY AVALC;
    set libinput.adds;
    where PARAMCD='WITHDRAW' and AVALC^='COMPLETED';
    DOSELEVEL=&dose_level.;
    keep SUBJID DOSELEVEL SITENM SEX AGE ASTDT ASTDY AVALC;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(&output_file_name., 6, 2, %str(SUBJID DOSELEVEL SITENM SEX AGE ASTDT ASTDY AVALC));
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
