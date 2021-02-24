**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.2.2.1.sas
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
%macro EDIT_T14_2_2_1();
    %local i var nobs;
    %global cnt;
    %let cnt=%sysfunc(countc(&target., ','));
    %do i=1 %to %eval(&cnt+1);
      %let var=%sysfunc(strip(%scan(&target., &i., ',')));
      data temp_adrs_1;
          set adrs;
          if AVALC="&var." then do;
            target='1';
          end;
          else do;
            target='0';
          end;
      run;
      %let seq=%eval(&seq.+1);
      proc freq data=temp_adrs_1 noprint;
          tables target / out=temp_adrs_2;
      run;
      data temp_adrs_3;
          set temp_adrs_2;
          where target='1';
      run;
      proc sql noprint;
          select count(*) into: nobs from temp_adrs_3;
          %if &nobs.=0 %then %do;
            insert into temp_adrs_3
              set COUNT=0, PERCENT=0;
          %end; 
      quit;
      %put &nobs.;
      data output_&seq.;
          set temp_adrs_3;
          N_PER=CAT(COUNT, ' (', strip(put(round(PERCENT, 0.1), 8.1)), ')');
      run;  
    %end;
%mend EDIT_T14_2_2_1;
%macro SET_EXCEL_T_14_2_2_1();
    %local i;
    %do i=0 %to %eval(&cnt+1);
      %let seq=%eval(1+&i.);
      %SET_EXCEL(output_&seq., 7, %eval(3+&i.), %str(N_PER), &output_file_name.);
    %end;
%mend SET_EXCEL_T_14_2_2_1;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%global seq target;
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
%let target=%str(CR, CRi, PARTIAL RESPONSE, RESISTANT DISEASE, PROGRESSIVE DISEASE, DEATH DURING APLASIA, INDETERMINATE);
%let seq=1;
%OUTPUT_ANALYSIS_SET_N(adrs, output_&seq., N_PER, 'CHAR');
data doselevel;
    DOSELEVEL=1;
    output;
run;
%EDIT_T14_2_2_1();
%OPEN_EXCEL(&template.);
%SET_EXCEL(doselevel, 7, 2, %str(DOSELEVEL), &output_file_name.);
%SET_EXCEL_T_14_2_2_1();
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
