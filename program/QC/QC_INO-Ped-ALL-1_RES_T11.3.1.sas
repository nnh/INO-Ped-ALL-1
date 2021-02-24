**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T11.3.1.sas
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
%macro EDIT_T11_3_1_1(ds_names);
    %local val cnt i;
    %let cnt=%sysfunc(countc(&ds_names., ','));
    %put &cnt.;
    %do i=1 %to %eval(&cnt+1);
      %let val=%sysfunc(strip(%scan(&ds_names., &i., ',')));
      %let seq=%eval(&seq.+1);
      %EDIT_MEANS(&val., output_&seq., AVAL);
    %end;
%mend EDIT_T11_3_1_1;
%macro EDIT_T11_3_1_2(ds_names);
    %local val cnt i;
    %let cnt=%sysfunc(countc(&ds_names., ','));
    %put &cnt.;
    %do i=1 %to %eval(&cnt+1);
      %let val=%sysfunc(strip(%scan(&ds_names., &i., ',')));
      %let seq=%eval(&seq.+1);
      %EDIT_MEANS(&val., temp_output_&seq., AVAL, class_f=1, class_var=AVISITN);
    %end;
%mend EDIT_T11_3_1_2;
%macro EDIT_CYCDOS_CYCRDI(seq);
    %local i;
    data temp_ds;
        set temp_output_&seq.;
        where _TYPE_=1;
    run;
    %do i=1 %to 4;
      data temp_ds_&i.;
          set temp_ds;
          COL1=COL&i.;
          keep _NAME_ COL1;
      run;
    %end;
    data output_&seq.;
        set temp_ds_1-temp_ds_4;
    run;
%mend EDIT_CYCDOS_CYCRDI;
%global seq output_row N;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%let output_file_name=T11.3.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
data adec;
    set libinput.adec;
    where &target_flg.='Y';
run;
data adec_dos adec_durtrt adec_durflu adec_cycn adec_totdos adec_cycdos adec_rdi adec_cycrdi adec_int adec_res; 
    set adec;
    if PARAMCD='DOS' then output adec_dos;
    else if PARAMCD='DURTRT' then output adec_durtrt;
    else if PARAMCD='DURFLU' then output adec_durflu;
    else if PARAMCD='CYCN' then output adec_cycn;
    else if PARAMCD='TOTDOS' then output adec_totdos;
    else if PARAMCD='CYCDOS' then output adec_cycdos;
    else if PARAMCD='RDI' then output adec_rdi;
    else if PARAMCD='CYCRDI' then output adec_cycrdi;
    else if PARAMCD='INT' then output adec_int;
    else if PARAMCD='RES' then output adec_res;
run;
%let seq=0;
%EDIT_T11_3_1_1(%str(adec_durtrt, adec_durflu, adec_cycn, adec_totdos, adec_rdi));
%EDIT_T11_3_1_2(%str(adec_cycdos, adec_cycrdi));
%EDIT_CYCDOS_CYCRDI(6);
%EDIT_CYCDOS_CYCRDI(7);
data output_ds;
    set output_1-output_4 output_6 output_5 output_7;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_ds, 6, 4, %str(COL1), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);


