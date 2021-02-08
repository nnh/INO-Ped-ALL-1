**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T11.3.5.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-2-8
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
%let output_file_name=T11.3.5;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
data adsl;
    set libinput.adsl;
    where &target_flg.='Y';
run;
data adcm;
    set libinput.adcm;
    where &target_flg.='Y';
run;
data adpr;
    set libinput.adpr;
    where &target_flg.='Y';
run;
data adtte;
    set libinput.adtte;
    where &target_flg.='Y';
run;
data adfa;
    set libinput.adfa;
    where &target_flg.='Y';
run;
proc sql noprint;
    create table temp_adtte_1 as
    select distinct SUBJID, AHSCT from adtte;

    create table target_subjid as
    select SUBJID from temp_adtte_1 where AHSCT ='Y';
quit;
%OUTPUT_ANALYSIS_SET_N(adsl, output_1, COUNT, 'CHAR');
%OUTPUT_ANALYSIS_SET_N(target_subjid, hsct_n, hsct_n, 'CHAR');
data _NULL_;
    set hsct_n;
    call symput('hsct_n', hsct_n);
run;
%EDIT_N_PER_2(temp_adtte_1, output_2, AHSCT, %str('Y, N'), ',', 0);
proc sql noprint;
    create table temp_adpr_1 as
    select * from adpr
    where (PRTRT = 'CBSCT') or (PRTRT = 'BMT');
quit;
%EDIT_N_PER_2(temp_adpr_1, output_3, PRTRT, %str('BMT, CBSCT'), ',', &hsct_n.);
%EDIT_N_PER_2(temp_adpr_1, output_4, PRTRT, %str('BMT, PBSCT, CBSCT, Other'), ',', &hsct_n.);
proc sql noprint;
    create table temp_adfa_1 as
    select * from adfa
    where PARAMCD = 'TYPE';
quit;
%EDIT_N_PER_2(temp_adfa_1, output_5, AVALC, %str('MYELOABLATIVE, REDUCED-INTENSITY'), ',', &hsct_n.);
proc sql noprint;
    create table temp_adcm_1 as
    select * from adcm
    where CMCAT = 'PRE-TRANSPLANT TREATMENT DRUG';
quit;
%EDIT_N_PER_2(temp_adcm_1, output_6, CMDECOD, %str('Busulfan, Cyclophosphamide monohydrate, Etoposide, Fludarabine phosphate, Melphalan'), ',', &hsct_n.);
data output_ds;
    length val $200.;
    set output_2-output_6;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_1, 6, 4, %str(COUNT), &output_file_name.);
%SET_EXCEL(output_ds, 7, 4, %str(N PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
