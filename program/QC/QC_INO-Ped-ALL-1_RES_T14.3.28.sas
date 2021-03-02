**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.28.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-2
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
%global seq N;
%let output_file_name=T14.3.28;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
%let normal_range_filename=INO-Ped-ALL-1_LB_Normal Range_20201228.xlsx;
%let normal_range=&extpath.\&normal_range_filename.;
%let normal_range_sheetname=ADLB_Normal Range_age;
libname libinput "&inputpath." ACCESS=READONLY;
data adlb;
    set libinput.adlb;
    where &target_flg.='Y';
run;
%OPEN_EXCEL(&normal_range.);
filename cmdexcel dde "excel|[&normal_range_filename.]&normal_range_sheetname.!R2C1:R9999C13";
data raw_normal_range;
    length var1-var13 $200;
    infile cmdexcel notab dlm='09'x dsd missover lrecl=30000 firstobs=1;
    input var1-var13;
run;
filename cmdexcel clear;
data temp_normal_range_1;
    set raw_normal_range;
    where (var3='AST') or (var3='ALT') or (var3='BILI'); 
    rename var3=PARAMCD var6=SEX var7=AGE var8=LBORRES var9=LOW var10=HIGH;
    keep var3 var6 var7 var8 var9 var10;
run;
%CLOSE_EXSEL_NOSAVE;
proc sql noprint;
    create table temp_normal_range_2 as
    select *, 'M' as temp_SEX
    from temp_normal_range_1
    where PARAMCD = 'BILI'
    outer union corr
    select *, 'F' as temp_SEX
    from temp_normal_range_1
    where PARAMCD = 'BILI';
quit;
data normal_range;
    set temp_normal_range_1
        temp_normal_range_2(drop=SEX rename=(temp_SEX=SEX));
run;
%SUBJID_N(set_output_1, N, N);
data raw_adlb;
    set libinput.adlb;
run;
proc sql noprint;
    create table adlb as
    select a.SUBJID, a.PARAMCD, a.AVAL, a.AAGE, a.SEX, b.LBORRES, 
           input(b.LOW, best12.) as LOW, input(b.HIGH, best12.) as HIGH
    from raw_adlb a, normal_range b
    where (a.PARAMCD = b.PARAMCD) and
          (a.AAGE = input(b.AGE, best12.)) and
          (a.SEX = b.SEX);
quit;
proc sql noprint;
    create table adlb_ast as
    select * 
    from adlb
    where (PARAMCD='AST') and (AVAL >= (HIGH * 3));
quit;
proc sql noprint;
    create table adlb_alt as
    select * 
    from adlb
    where (PARAMCD='ALT') and (AVAL >= (HIGH * 3));
quit;
proc sql noprint;
    create table adlb_bili as
    select * 
    from adlb
    where (PARAMCD='BILI') and (AVAL >= (HIGH * 2));
quit;
data adlb_ast_alt;
    set adlb_ast
        adlb_alt;
run;
proc sql noprint;
    create table adlb_hys_low as
    select *
    from adlb_ast_alt
    where SUBJID in (select distinct SUBJID from adlb_bili);
quit;
%macro EDIT_T14_3_28(input_ds);
    %let seq=%eval(&seq.+1);
    proc sql noprint;
        create table temp_adlb as
        select distinct SUBJID, 'Y' as target
        from &input_ds.;
    quit;
    %EDIT_N_PER_2(temp_adlb, temp_output, target, %str('Y, N'), ',', &N.);
    data output_&seq.;
        set temp_output;
        where val='Y';
        N_PER=CAT(strip(N),' (', strip(PER), ')');
    run;
%mend EDIT_T14_3_28;
%let seq=0;
%EDIT_T14_3_28(adlb_ast);
%EDIT_T14_3_28(adlb_alt);
%EDIT_T14_3_28(adlb_bili);
%EDIT_T14_3_28(adlb_hys_low);
data set_output_2;
    set output_1-output_4;
    keep N_PER;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(set_output_1, 7, 3, %str(N), &output_file_name.);
%SET_EXCEL(set_output_2, 8, 3, %str(N_PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
