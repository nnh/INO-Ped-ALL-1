**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.6.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-2-15
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
%global row_cnt N;
%let output_file_name=T14.3.6;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
proc sql noprint;
    create table adae as
    select SUBJID, AESOC, AELLT, &target_flg., AETOXGR
    from libinput.adae;

    create table adae_soc_list as 
    select distinct AESOC, '' as AELLT
    from adae;

    create table adae_llt_list as
    select distinct AESOC, AELLT
    from adae;

    create table temp_adae_soc_llt as
    select *
    from adae_soc_list
    outer union corr
    select *
    from adae_llt_list
    order by AESOC, AELLT;

    create table adae_soc_llt as
    select *, monotonic() as N
    from temp_adae_soc_llt;

    select count(*) into: row_cnt
    from adae_soc_llt;
quit;
proc sql noprint;
    create table subjid_list as
    select distinct SUBJID from adae;
quit;
%OUTPUT_ANALYSIS_SET_N(subjid_list, output_0, N, '');
proc sql noprint;
    select N into: N from output_0;
quit;
%macro EDIT_T14_3_6();
    %local i j;
    %do i=1 %to 1;
      proc sql noprint;
          create table temp_join as
          select *
          from adae_soc_llt
          where N=&i.;

          create table temp_adae_&i._1 as
          select a.*, b.AESOC as temp_AESOC, b.AELLT as temp_AELLT
          from adae a left join temp_join b on a.AESOC = b.AESOC;

          create table temp_adae_&i._2 as
          select *
          from temp_adae_&i._1
          where AESOC = temp_AESOC;
      quit;
      data temp_adae_&i._3;
          set temp_adae_&i._2;
          if temp_AELLT='' then do;
            if temp_AESOC=AESOC then output;
          end;
          else do;
            if (temp_AESOC=AESOC) and (temp_AELLT=AELLT) then output;
          end;
      run;
      data temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8;
          set temp_adae_&i._3;
          if AETOXGR=1 then output temp1;
          if AETOXGR=2 then output temp2;
          if AETOXGR=3 then output temp3;
          if AETOXGR=4 then output temp4;
          if AETOXGR=5 then output temp5;
          if (AETOXGR=3) or (AETOXGR=4) then output temp6;
          if AETOXGR>=3 then output temp7;
          output temp8;
      run;
      %do j=1 %to 8;
        %EDIT_N_PER_2(temp&j., temp_output_&j., &target_flg., %str('Y, N'), ',', &N.);      
      %end;
    %end;

    
%mend EDIT_T14_3_6;
%EDIT_T14_3_6;




%OPEN_EXCEL(&template.);
%SET_EXCEL(set_output_2, 8, 3, %str(N PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
