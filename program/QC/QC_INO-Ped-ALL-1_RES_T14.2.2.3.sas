**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.2.2.3.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-4-16
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
%let output_file_name=T14.2.2.3;
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
proc sql noprint;
    create table ovrlresp as
    select *
    from adrs
    where PARAMCD = 'OVRLRESP' and (AVALC = 'CR' or AVALC = 'CRi')
    order by SUBJID, ADT;
quit;
data first_ovrlresp;
    set ovrlresp;
    by SUBJID;
    if first.SUBJID then output;
    keep SUBJID ADY;
run;
%OUTPUT_ANALYSIS_SET_N(first_ovrlresp, output_N, N, '');
%EDIT_ROUND_TABLE(mean=0.1, sd=0.01, min=0, median=0.1, max=0);
%EDIT_MEANS_2(first_ovrlresp, output_means, ADY);
data _NULL_;
    set output_means;
    if _N_=1 then call symput('N', output);
    if _N_=2 then call symput('mean', output);
    if _N_=3 then call symput('sd', output);
    if _N_=4 then call symput('min', output);
    if _N_=5 then call symput('median', output);
    if _N_=6 then call symput('max', output);
run;
data output;
    output=put(&N., best12.); output;
    output=cats(&mean., 'Å}', &sd.); output;
    output=put(&median., 8.1); output;
    output=cats(&min., 'Å`', &max.); output;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_N, 6, 4, %str(N), &output_file_name.);
%SET_EXCEL(output, 7, 4, %str(output), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
