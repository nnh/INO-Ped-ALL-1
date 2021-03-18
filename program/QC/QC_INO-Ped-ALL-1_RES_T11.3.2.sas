**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T11.3.2.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-17
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
%let output_file_name=T11.3.2;
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


%EDIT_T10_1_1();
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_ds, 6, 2, %str(SITENM N), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
%macro EDIT_T10_1_1();
    data adsl;
        set libinput.adsl;
    run;
    proc sql noprint;
        create table temp_sitenm as
        select distinct SITEID, SITENM from adsl;
        select SITENM, count(SITENM) into: sitenm1-:sitenm99, :sitenm_cnt from temp_sitenm;
    quit;
    data temp_adsl_1;
        array _SITE{*} $SITE1-SITE%eval(&sitenm_cnt.); 
        set adsl;
        do i=1 to &sitenm_cnt.;
          _SITE{i} = '';      
        end;
    run;
    %OUTPUT_ANALYSIS_SET_N(adsl, output_n, temp_N, '');
    data output_0;
        format SITENM N;
        set output_n;
        N=input(strip(temp_N), best12.);
        SITENM='Registration Set';
        keep SITENM N;
    run;
    data temp_adsl_2;
        set temp_adsl_1;
        %do i=1 %to &sitenm_cnt.;
          if SITENM="&&sitenm&i." then do;
            SITE&i.='Y';
          end;
          else do;
            SITE&i.='N';
          end;
        %end;
    run;
    %do i=1 %to &sitenm_cnt.;
      %EDIT_N_PER_2(temp_adsl_2, temp_output_&i._1, SITE&i., %str('Y, N'), ',', 0);
      data output_&i;
        format SITENM N;
        set temp_output_&i._1;
        where val='Y';
        SITENM="&&sitenm&i.";
        keep SITENM N;
      run;
    %end;
    data output_ds;
        length SITENM $200;
        set output_0-output_%eval(&sitenm_cnt.);
    run;
%mend EDIT_T10_1_1;
