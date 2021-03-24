**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.2.2.2.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-24
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
%macro EDIT_T14_2_2_2();
    %local response_list cnt i j val;
    %global response_cnt;
    %let response_list=%str(CR,CRi,Partial response,RESISTANT DISEASE,PD,Death during aplasia,INDETERMINATE RESPONSE); 
    %let cnt=%sysfunc(countc(&response_list., ','));
    %let response_cnt=%eval(&cnt+1);
    %do i=1 %to &max_cycle.;
      %let visitn=%eval((&i.+1)*100);
      data temp_adrs_n_&i.;
        set adrs;
        where AVISITN=&visitn.;
      run;
      %OUTPUT_ANALYSIS_SET_N(temp_adrs_n_&i., output_n_&i., N, '');
      proc sql noprint;
          select count(*) into:N from temp_adrs_n_&i.;
      quit;
      %do j=1 %to &response_cnt.;
        %let val=%sysfunc(strip(%scan(&response_list., &j., ',')));
        data temp_adrs_&i._&j.;
            set adrs;
            OVRLRESP='Y';
            where ((AVISITN=&visitn.) and (AVALC = "&val."));
        run;
        %EDIT_N_PER_2(temp_adrs_&i._&j., output_&i._&j., OVRLRESP, %str('Y, N'), ',', &N.);
      %end;
    %end;
    data output_n;
        set output_n_1-output_n_%eval(&max_cycle.);
    run;
    %do j=1 %to &response_cnt.;
      data output_ds_&j.;
          set output_1_%eval(&j.) output_2_%eval(&j.) output_3_%eval(&j.) output_4_%eval(&j.);
          where val = 'Y';
          N_PER=CAT(strip(N),' (',strip(PER),')');
      run;
    %end;
%mend EDIT_T14_2_2_2;
%macro SET_EXCEL_T14_2_2_2();
    %local i;
    %do i=1 %to &response_cnt.;
      %SET_EXCEL(output_ds_&i., 7, %eval(&i.+4), %str(N_PER), &output_file_name.);
    %end;
%mend SET_EXCEL_T14_2_2_2;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
%global N;
* Main processing start;
%let output_file_name=T14.2.2.2;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=PPSFL;
libname libinput "&inputpath." ACCESS=READONLY;
data adrs;
    set libinput.adrs;
    where ((&target_flg.='Y') and (PARAMCD = 'OVRLRESP'));
run;
proc sql noprint;
    select ((max(AVISITN)/100) - 1) into:max_cycle from adrs;
quit;
%EDIT_T14_2_2_2();
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_n, 7, 4, %str(N), &output_file_name.);
%SET_EXCEL_T14_2_2_2();
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
