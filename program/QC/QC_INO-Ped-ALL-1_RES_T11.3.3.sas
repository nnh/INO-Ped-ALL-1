**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T11.3.3.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-18
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
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%let output_file_name=T11.3.3;
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
data temp_adec_1;
    set adec;
    where (PARAMCD='INT') or (PARAMCD='RES');
    keep SUBJID PARAM PARAMCD AVAL AVALC AVISIT AVISITN;
run;
proc sql noprint;
    select ((max(AVISITN)/100) - 1) into:max_cycle from temp_adec_1;
quit;
%EDIT_T11_3_2();
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_n_1, 7, 4, %str(N), &output_file_name.);
%SET_EXCEL(output_n_2, 7, 5, %str(N), &output_file_name.);
%SET_EXCEL(output_n_3, 7, 6, %str(N), &output_file_name.);
%SET_EXCEL(output_n_4, 7, 7, %str(N), &output_file_name.);
%SET_EXCEL(output_1, 8, 4, %str(N_PER), &output_file_name.);
%SET_EXCEL(output_2, 8, 5, %str(N_PER), &output_file_name.);
%SET_EXCEL(output_3, 8, 6, %str(N_PER), &output_file_name.);
%SET_EXCEL(output_4, 8, 7, %str(N_PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
%macro EDIT_T11_3_2();
    %do i=1 %to &max_cycle.;
      %let visitn=%eval((&i.+1)*100);
      data int_&i. res_&i.;
          set temp_adec_1;
          if (AVISITN=&visitn.) and (PARAMCD='INT') then output int_&i.;
          if (AVISITN=&visitn.) and (PARAMCD='RES') then output res_&i.;
      run;
      %OUTPUT_ANALYSIS_SET_N(int_&i., output_n_&i., N, '');
      %EDIT_N_PER_2(int_&i., output_int_&i._1, AVALC, %str('Y, N'), ',', 0);
      %EDIT_N_PER_2(res_&i., output_res_&i._1, AVALC, %str('Y, N'), ',', 0);
      data int_&i._Y int_&i._N;
          set output_int_&i._1;
          if val='Y' then output int_&i._Y;
          if val='N' then output int_&i._N;
      run;
      data res_&i._Y res_&i._N;
          set output_res_&i._1;
          if val='Y' then output res_&i._Y;
          if val='N' then output res_&i._N;
      run;
      data output_&i.;
          set int_&i._N int_&i._Y res_&i._N res_&i._Y;
          N_PER=CAT(N, ' (', strip(PER), ')');
          keep N_PER;
      run;
    %end;
%mend EDIT_T11_3_2;
