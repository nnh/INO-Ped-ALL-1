**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_L16.2.6.1.sas
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
%let output_file_name=L16.2.6.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
data aaa; set libinput.adae;run;
proc sql noprint;
    create table adae as
    select 1 as temp_DOSELEVEL, SUBJID as temp_SUBJID, AETERM, AETOXGR, AESER, ASTDT, AENDT, ADURN, ASTDY, AEACN, AEREL, COVAL, AEOUT
    from libinput.adae
    where &target_flg. = 'Y'
    order by SUBJID, ASTDT, AENDT, AETERM;
quit;
data output_1;
    format DOSELEVEL SUBJID AETERM AETOXGR AESER ASTDT AENDT ADURN ASTDY AEACN AEREL COVAL AEOUT;
    set adae;
    by temp_SUBJID;
    if first.temp_SUBJID then do;
      DOSELEVEL=temp_DOSELEVEL;
      SUBJID=temp_SUBJID;
    end;
    else do;
      DOSELEVEL='';
      SUBJID='';
    end;
    drop temp_DOSELEVEL temp_SUBJID;
run;
%OPEN_EXCEL(&template.);
%CLEAR_EXCEL(&output_file_name., 6);
%SET_EXCEL(output_1, 6, 2, %str( DOSELEVEL SUBJID AETERM AETOXGR AESER ASTDT AENDT ADURN ASTDY AEACN AEREL COVAL AEOUT), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
