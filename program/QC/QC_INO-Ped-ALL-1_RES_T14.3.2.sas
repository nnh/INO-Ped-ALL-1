**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.2.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-29
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
%macro EDIT_T14_3_2(target_ds);
    %local ae_cnt select_condition input_ds;
    proc sql noprint;
        select count(*),
               AESOC,
               AEDECOD,
               case
               when AEDECOD = '' then 1
               else 0
               end as soc_f
        into:ae_cnt,
            :aesoc_1-:aesoc_9999, 
            :aedecod_1-:aedecod_9999,
            :soc_f_1-:soc_f_9999
        from &target_ds.;
    quit;
    %do i=1 %to &ae_cnt.;
      %if &&soc_f_&i. = 0 %then %do;
        %let select_condition=%nrquote((AESOC = "&&aesoc_&i.") and (AEDECOD = "&&aedecod_&i."));
        %let input_ds=adae_llt;
      %end;
      %else %do;
        %let select_condition=%nrquote((AESOC = "&&aesoc_&i."));
        %let input_ds=adae_soc;
        proc sql noprint;
            create table &input_ds. as
            select distinct SUBJID, AESOC, '' as AEDECOD, &target_flg.
            from adae_llt;
        quit;
      %end;
      proc sql noprint;
          create table temp_ae_list_2_&i. as
          select *
          from &input_ds. 
          where &select_condition.;
      quit;
      %EDIT_N_PER_2(temp_ae_list_2_&i., temp_output_&i., &target_flg., %str('Y, N'), ',', &N.);
      data output_&i.;
          format AETERM N_PER;
          length AETERM $200;
          set temp_output_&i.;
          where val='Y';
          if &&soc_f_&i.=0 then do;
            AETERM=cat('Å@', "&&aedecod_&i.");
          end;
          else do;
            AETERM="&&aesoc_&i.";
          end;
          N_PER=cat(strip(N),' (',strip(PER),')');
          keep AETERM N_PER;
      run;
    %end;
    data output_soc_pt;
        set output_1-output_%eval(&ae_cnt.);
    run;
%mend EDIT_T14_3_2;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%global N;
%let output_file_name=T14.3.2;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
proc sql noprint;
    create table adae_llt as
    select SUBJID, AESOC, AEDECOD, &target_flg., max(AETOXGR) as AETOXGR
    from libinput.adae
    where &target_flg.='Y'
    group by SUBJID, AESOC, AEDECOD, &target_flg.;
quit;
proc sql noprint;
    create table temp_ae_list as
    select distinct AESOC, AEDECOD
    from adae_llt
    outer union corr
    select distinct AESOC, '' as AEDECOD
    from adae_llt
    order by AESOC, AEDECOD;
quit;
%SUBJID_N(output_n, N, N);
%EDIT_T14_3_2(temp_ae_list);
%OPEN_EXCEL(&template.);
%CLEAR_EXCEL(&output_file_name., 8);
%SET_EXCEL(output_n, 7, 3, %str(N), &output_file_name.);
%SET_EXCEL(output_soc_pt, 8, 2, %str(AETERM N_PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
