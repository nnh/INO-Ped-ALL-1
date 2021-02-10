**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.2.1.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-2-9
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
%let output_file_name=T14.2.2.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=PPSFL;
libname libinput "&inputpath." ACCESS=READONLY;
data adrs;
    set libinput.adrs;
    where (&target_flg.='Y') and (PARAMCD='BESTRESP');
run;
%OUTPUT_ANALYSIS_SET_N(adrs, output1, N_PER, 'CHAR');
proc freq data=adrs noprint;
    tables AVALC / out=ds_bestresp;
run;
data temp_output_1;
    set ds_bestresp;
    N_PER=CAT(strip(COUNT),' (',strip(round(PERCENT, 0.1)),')');
run;
data output2 output3 output4 output5 output6 output7 output8;
  set temp_output_1;
  select;
    when (AVALC='CR') output output2;
    when (AVALC='CRi') output output3;
    when (AVALC='Partial response') output output4;
    when (AVALC='Resistant disease') output output5;
    when (AVALC='Progressive disease') output output6;
    when (AVALC='Death during aplasia') output output7;
    when (AVALC='Indeterminate') output output8;
    otherwise;
  end;
  keep AVALC N_PER;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(output1, 7, 3, %str(N_PER), &output_file_name.);
%macro EDIT_T_14_2_2_1();
    %do i=1 %to 7;
      %let seq=%eval(1+&i.);
      data _NULL_;
          set output&seq.;
          if 
      run;
      *%SET_EXCEL(output&seq., 7, %eval(3+&i.), %str(N_PER), &output_file_name.);
    %end;
%mend EDIT_T_14_2_2_1;
%EDIT_T_14_2_2_1();
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
