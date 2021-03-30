**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.20.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-30
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
%macro EDIT_T14_3_20(target_ds);
    %local target_cnt;
    proc sql noprint;
        select count(*) into: target_cnt from &target_ds.; 
    quit;
    %if &target_cnt. > 0 %then %do;
      %EDIT_T14_3_x_MAIN_2(&target_ds.);
    %end;
    %else %do;
      %SUBJID_N(output_n, N, N);
      data output_soc_pt;
          AETERM='No Events';
          N_PER='-';
          output;
      run;
    %end;
%mend EDIT_T14_3_20;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%let output_file_name=T14.3.20;
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
    where (&target_flg.='Y') and (AESER='Y') and (AEACN='DRUG INTERRUPTED') and (AEREL='RELATED')
    group by SUBJID, AESOC, AEDECOD, &target_flg.;
quit;
proc sql noprint;
    create table temp_ae_list as
    select distinct AESOC, AEDECOD
    from adae_llt
    outer union corr
    select distinct AESOC, '' as AEDECOD
    from adae_llt
    order by AESOC, AEDECOD;
quit;
%EDIT_T14_3_20(temp_ae_list);
%OPEN_EXCEL(&template.);
%CLEAR_EXCEL(&output_file_name., 8);
%SET_EXCEL(output_n, 7, 3, %str(N), &output_file_name.);
%SET_EXCEL(output_soc_pt, 8, 2, %str(AETERM N_PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
