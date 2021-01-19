**************************************************************************
Program Name : QC_INO-Ped-ALL-1_CC_TABLE9.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-1-19
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
%let output_file_name=Table9;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
libname libinput "&inputpath." ACCESS=READONLY;
proc sql noprint;
    create table adpr as
    select SUBJID, PRCAT, PRTRT, ASTDT, AENDT
    from libinput.adpr
    where (PRCAT = 'COMBINATION THERAPY') or (PRCAT = 'PRIOR THERAPY')
    order by SUBJID, PRCAT, ASTDT, AENDT, PRTRT;
quit;
data &output_file_name.;
    set adpr (rename=(SUBJID=temp_SUBJID));
    by temp_SUBJID;
    if first.temp_SUBJID then do;
      DOSELEVEL=&dose_level.;
      SUBJID=temp_SUBJID;
    end;
    else do;
      call MISSING(DOSELEVEL);
      call MISSING(SUBJID);
    end;
    keep DOSELEVEL SUBJID PRCAT PRTRT ASTDT AENDT;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(&output_file_name., 6, 2, %str(DOSELEVEL SUBJID PRCAT PRTRT ASTDT AENDT));
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
