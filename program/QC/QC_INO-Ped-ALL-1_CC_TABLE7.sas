**************************************************************************
Program Name : QC_INO-Ped-ALL-1_CC_TABLE7.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-1-12
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
%let output_file_name=Table7;
%let templatename=&template_name_head.table1&template_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\QC_&templatename.;
libname libinput "&inputpath." ACCESS=READONLY;
data ae;
    set libinput.adae;
run;
data temp_ae;
    set ae;
    keep SUBJID AETERM AETOXGR AESER AESLIFE ASTDY AENDY ADURN AEACN AEREL COVAL AEOUT;
run;
data ds;
set 
run;

%OPEN_EXCEL(&template.);
        filename test dde  'excel|Table1!R6C2:R15C2' notab;
        data aaa;
          set adsl;
          keep STUDYID USUBJID; 
        run;
        data _NULL_;
            set aaa;
            file test;
            put STUDYID USUBJID;
        run;

*Subject ID Dose Level  Site name Sex Age Discontinuation Date  Reference from First Treatment  Reason
;

%OUTPUT_EXCEL(&output.);
*%SDTM_FIN(&output_file_name.);
