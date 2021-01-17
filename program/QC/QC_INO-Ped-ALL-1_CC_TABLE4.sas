**************************************************************************
Program Name : QC_INO-Ped-ALL-1_CC_TABLE4.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-1-15
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
%macro UNION_OUTPUT_SUBJID(input_ds, output_ds);
    %local i temp_subjid;
    data temp_&output_ds.; 
      set &input_ds.; 
      stop;   
      keep SUBJID;
    run;
    %do i=1 %to &obs_cnt.;
        %let temp_subjid=%scan(%quote(&subjid_list.), &i., ',');
        data _NULL_;
            set &input_ds.;
            where SUBJID="&temp_subjid.";
            if row_count=. then do;
              row_cnt=1;
            end;
            else do;
              row_cnt=row_count;
            end;
            call symputx('row_cnt', row_cnt);
        run;
        data temp_&i.;
            set &input_ds.;
            where SUBJID="&temp_subjid.";
            do j=1 to &row_cnt.;
              output;
            end;
            keep SUBJID; 
        run;
        data temp_&output_ds.;
            set temp_&output_ds. temp_&i.;
        run;
    %end;
    data &output_ds.;
        set temp_&output_ds.;
        by SUBJID;
        if first.SUBJID then do;
          target=&target_seq_1.;
          seq=0;
        end;
        else do;
          target=&target_seq_2.;
          seq+1;
        end;
    run;
%mend;
%global subjid_list obs_cnt target_seq_1 target_seq_2;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_CC_LIBNAME.sas";
* Main processing start;
%let output_file_name=Table4;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_seq_1=1;
%let target_seq_2=999;
libname libinput "&inputpath." ACCESS=READONLY;
data adsl;
    set libinput.adsl;
    keep SUBJID SEX BSA AGE HEIGHT WEIGHT BMI PRIMDIAG DISDUR ALLER INTP RELREF FRDUR HSCT 
         RAD LKPS CD22 LVEF WBC PBLST BLAST;
run;
data subjid_list;
    set libinput.adsl;
    keep SUBJID;
run;
proc sort data=subjid_list out=subjid_list nodupkey; 
    by SUBJID; 
run;
proc sql noprint;
    select SUBJID 
    into: subjid_list separated by ','
    from subjid_list;

    select count(*)
    into: obs_cnt trimmed
    from subjid_list;
quit;
proc sql noprint;
    create table medical_history as
    select SUBJID, MHTERM 
    from libinput.admh
    where MHENRTPT='BEFORE'
    order by SUBJID, MHTERM; 

    create table complications as
    select SUBJID, MHTERM 
    from libinput.admh
    where MHENRTPT='ONGOING'
    order by SUBJID, MHTERM; 

    create table mh_row_count as
    select SUBJID, count(*) as row_count
    from medical_history
    group by SUBJID
    outer union corr
    select SUBJID, count(*) as row_count
    from complications
    group by SUBJID; 

    create table mh_max_row_count as
    select SUBJID, max(row_count) as row_count
    from mh_row_count
    group by SUBJID;

    create table temp_subjid_list_1 as
    select a.SUBJID, b.row_count
    from subjid_list a left join mh_max_row_count b on a.SUBJID = b.SUBJID;

quit;
%UNION_OUTPUT_SUBJID(temp_subjid_list_1, temp_subjid_list_2);
data temp_subjid_list_3;
    length AGE 8. ALLER $200. BLAST 8. BMI 8. BSA 8. CD22 8. DISDUR 8. FRDUR 8. HEIGHT 8. 
           HSCT $200. INTP $200. LKPS $200. LVEF 8. PBLST 8. PRIMDIAG $200. RAD $200.
           RELREF $200. SEX $200. SUBJID $200. WBC 8. WEIGHT 8.;
    set temp_subjid_list_2;
    where target=&target_seq_2.;
    call missing(SEX);
    call missing(BSA);
    call missing(AGE);
    call missing(HEIGHT);
    call missing(WEIGHT);
    call missing(BMI);
    call missing(PRIMDIAG);
    call missing(DISDUR);
    call missing(ALLER);
    call missing(INTP);
    call missing(RELREF);
    call missing(FRDUR);
    call missing(HSCT);
    call missing(RAD);
    call missing(LKPS);
    call missing(CD22);
    call missing(LVEF);
    call missing(WBC);
    call missing(PBLST);
    call missing(BLAST);
run;
proc sql noprint;
    create table temp_table4_1 as
    select b.*, a.target, a.seq
    from (select * from temp_subjid_list_2 where target = &target_seq_1.) a left join adsl b on a.SUBJID = b.SUBJID
    outer union corr
    select * from temp_subjid_list_3
    order by SUBJID, target, seq;
quit;

proc sql noprint;
    create table medical_history_2 as 
    select a.SUBJID, a.SEQ, b.MHTERM
    from temp_subjid_list_2 a left join medical_history b on a.SUBJID = b.SUBJID order by SUBJID, SEQ;

    create table medical_history_3 as
    select * from medical_history_2 where MHTERM = '';

    create table medical_history_4 as
    select * 
    from left join medical_history_2;
quit;
/*
%OPEN_EXCEL(&template.);
%SET_EXCEL(&output_file_name., 6, 2, %str(SUBJID DOSELEVEL SITENM SEX AGE ASTDT ASTDY AVALC));
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
*/
