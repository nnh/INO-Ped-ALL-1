**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.22.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-2-17
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
%let output_file_name=T14.3.22;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
proc sql noprint;
    create table adae_llt as
    select SUBJID, AESOC, AEDECOD, &target_flg., max(AETOXGR) as AETOXGR
    from libinput.adae
    where (&target_flg.='Y') and (AEDECOD = "Venoocclusive liver disease")
    group by SUBJID, AESOC, AEDECOD, &target_flg.;
quit;
%EDIT_T14_3_x_MAIN(adae_llt);
%OPEN_EXCEL(&template.);
%SET_EXCEL(set_output_1, 7, 3, %str(N), &output_file_name.);
%SET_EXCEL(set_output_2, 8, 3, %str(N_PER_8), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
