**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.2.8.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-4-19
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
%let output_file_name=T14.2.8;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=PPSFL;
libname libinput "&inputpath." ACCESS=READONLY;
proc sql noprint;
    create table adtte as
    select *, 1 as Cell from libinput.adtte
    where (&target_flg. = 'Y') and (PARAMCD = 'NONR') and (AHSCT = 'Y');
quit;
proc sql noprint;
    create table adpr as
    select SUBJID, ASTDT
    from libinput.adpr
    where (&target_flg. = 'Y') and (PRTRT = 'BMT' or PRTRT = 'PBSCT' or PRTRT = 'CBSCT' or PRTRT = 'OTHER')
    order by SUBJID, ASTDT;
quit;
proc sql noprint;
    create table temp_adtte_1 as
    select a.Cell, a.CNSR, (a.ADT - b.ASTDT + 1) as AVAL
    from adtte a left join adpr b on a.SUBJID = b.SUBJID;
quit;
data dmy;
    AVAL=100;
    CNSR=0;
    Cell=2;
    output;
    AVAL=150;
    CNSR=1;
    Cell=2;
    output;
    AVAL=200;
    CNSR=2;
    Cell=2;
    output;
run;
data temp_adtte;
    set temp_adtte_1
        dmy;
run;
proc lifetest data=temp_adtte(where=(Cell=1)) atrisk plots=s(atrisk=0 to 270 by 30 cl); 
    time AVAL * CNSR(1, 2);
run;
%OUTPUT_FILE(&output_file_name._1);
proc lifetest data=temp_adtte atrisk plots=cif(test cl); 
    time AVAL * CNSR(1) / failcode=0; 
    strata Cell; 
run;
%OUTPUT_FILE(&output_file_name._2);
%SDTM_FIN(&output_file_name.);
