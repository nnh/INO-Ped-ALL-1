**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T10.2.1.sas
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
%let output_file_name=T10.2.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg='';
libname libinput "&inputpath." ACCESS=READONLY;
%READ_DEVIATIONS(raw_deviations);
data adsl;
    set libinput.adsl;    
run;
%macro EDIT_T10_2_1();
    %local deviation_list cnt deviation_cnt i N;
    %let deviation_list=%str(PK—pŒŸ‘ÌÌæ•û–@‚Ìˆí’E, ‹K’èŒŸ¸E•]‰¿‚ÌŒ‡‘ª, ‹K’èŒŸ¸E•]‰¿“ú‚Ìˆí’E, ¡Œ±–ò“Š—^ƒXƒPƒWƒ…[ƒ‹‚Ìˆí’E, ’ÇÕ’²¸‚Ì–¢À{);
    %let cnt=%sysfunc(countc(&deviation_list., ','));
    %let deviation_cnt=%eval(&cnt+1);

    %OUTPUT_ANALYSIS_SET_N(adsl, output_n, temp_N, '');
    proc sql noprint;
        create table deviations_1 as
        select distinct var1, var3
        from raw_deviations;
    quit;
    data deviations_2;
        array _deviation{*} $deviation1-deviation%eval(&deviation_cnt.); 
        set deviations_1;
        do i=1 to &cnt.;
          _deviation{i} = '';      
        end;
    run;
    data output_0;
        format deviation N;
        set output_n;
        N=input(strip(temp_N), best12.);
        call symput('N', N);
        deviation='Registration Set';
        keep deviation N;
    run;
    data deviations_3;
        set deviations_2;
        %do i=1 %to &deviation_cnt.;
          %let val=%sysfunc(strip(%scan(&deviation_list., &i., ',')));
          if var3="&val." then do;
            deviation&i.='Y';
          end;
          else do;
            deviation&i.='N';
          end;
        %end;
    run;
    %do i=1 %to &deviation_cnt.;
      %EDIT_N_PER_2(deviations_3, temp_output_&i._1, deviation&i., %str('Y, N'), ',', &N.);
      data output_&i.;
          set temp_output_&i._1;
          where val='Y';
      run;
    %end;
    data output_ds;
        set output_1-output_%eval(&deviation_cnt.);
        keep N PER;
    run;
%mend EDIT_T10_2_1;
%EDIT_T10_2_1();
%OPEN_EXCEL(&template.);
%SET_EXCEL(output_0, 6, 3, %str(N), &output_file_name.);
%SET_EXCEL(output_ds, 7, 3, %str(N PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
