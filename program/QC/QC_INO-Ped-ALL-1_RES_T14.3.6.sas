**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.6.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-2-16
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
%macro EDIT_T14_3_6();
    %local i j save_j;
    %do i=1 %to &row_cnt.;
      proc sql noprint;
          create table temp_join as
          select *
          from adae_soc_llt
          where N=&i.;

          create table temp_adae_&i._1 as
          select a.*, b.AESOC as temp_AESOC, b.AEDECOD as temp_AEDECOD
          from adae a left join temp_join b on a.AESOC = b.AESOC;

          create table temp_adae_&i._3 as
          select *
          from temp_adae_&i._1
          where (AESOC = temp_AESOC) and (AEDECOD = temp_AEDECOD);
      quit;
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
      proc sort data=temp8 out=temp8 nodupkey; 
        by SUBJID; 
      run;
      %do j=1 %to 8;
        %EDIT_N_PER_2(temp&j., temp_output_&j._1, &target_flg., %str('Y, N'), ',', &N.);
        data temp_output_&j._2;
            set temp_output_&j._1;
            where val='Y';
            N_PER=CAT(N, ' (', strip(PER), ')');
            keep val N_PER;
        run;
        %if &j.>1 %then %do;
          proc sql noprint;
              create table temp_output_&j. as
              select a.*, b.N_PER as N_PER_&j.
              from temp_output_&save_j. a, temp_output_&j._2 b
              where a.val = b.val;
          quit;
        %end;
        %else %do;
          data temp_output_&j.;
              set temp_output_&j._2;
          run;
        %end;
        %let save_j=&j.; 
      %end;
      data output_&i.;
          set temp_output_8;
          drop val;
      run;
    %end;
%mend EDIT_T14_3_6;
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
    create table adae_llt as
    select SUBJID, AESOC, AEDECOD, &target_flg., max(AETOXGR) as AETOXGR
    from libinput.adae
    group by SUBJID, AESOC, AEDECOD, &target_flg.;

    create table adae_soc as
    select distinct SUBJID, AESOC, '' as AEDECOD, &target_flg., AETOXGR
    from adae_llt;

    create table adae as
    select *
    from adae_soc
    outer union corr
    select *
    from adae_llt
    order by AESOC, AEDECOD;

    create table temp_adae_soc_llt as
    select distinct AESOC, AEDECOD
    from adae
    order by AESOC, AEDECOD;

    create table adae_soc_llt as
    select *, monotonic() as N
    from temp_adae_soc_llt;

    select count(*) into: row_cnt trimmed
    from adae_soc_llt;
quit;
proc sql noprint;
    create table subjid_list as
    select distinct SUBJID from adae;
quit;
%OUTPUT_ANALYSIS_SET_N(subjid_list, set_output_1, N, '');
proc sql noprint;
    select N into: N from set_output_1;
quit;
%EDIT_T14_3_6;
data set_output_2;
    set output_1-output_&row_cnt.;
run;
data temp_term_of_ae_1;
    length output $200;
    output='Safety Analysis Set';
run;
data temp_term_of_ae_2;
    length output $200;
    set adae_soc_llt;
    if AEDECOD='' then do;
      output=AESOC;
    end;
    else do;
      output=cat('Å@', strip(AEDECOD));
    end;
    keep output;
run;
data set_output_3;
    set temp_term_of_ae_1
        temp_term_of_ae_2;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(set_output_3, 8, 2, %str(OUTPUT), &output_file_name.);
%SET_EXCEL(set_output_1, 8, 3, %str(N), &output_file_name.);
%SET_EXCEL(set_output_2, 9, 3, %str(N_PER N_PER_2 N_PER_3 N_PER_4 N_PER_5 N_PER_6 N_PER_7 N_PER_8), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
