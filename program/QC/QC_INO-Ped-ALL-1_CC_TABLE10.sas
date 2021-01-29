**************************************************************************
Program Name : QC_INO-Ped-ALL-1_CC_TABLE10.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-1-29
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
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_CC_LIBNAME.sas";
* Main processing start;
%let output_file_name=Table10;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let normal_range_file_name=INO-Ped-ALL-1_LB_Normal Range_20201228.xlsx;
%let normal_range_file=&projectpath.\input\ext\&normal_range_file_name.;
libname libinput "&inputpath." ACCESS=READONLY;
data adsl;
    length PARAM $200. TESTCAT $200.;
    set libinput.adsl;
    TESTCAT='Questionnaires';
    PARAM='Lansky/Karnofsky performance status';
    ADT=LKPSDT;
    AVAL=LKPSN;
run;
data adlb;
    length TESTCAT $200.;
    set libinput.adlb;
    TESTCAT='Laboratory Test Findings';
run;
data advs;
    length TESTCAT $200.;
    set libinput.advs;
    TESTCAT='Vital Signs';
run;
data adeg;
    length TESTCAT $200.;
    set libinput.adeg;
    TESTCAT='Electrocardiogram Results';
run;
data adfa;
    length TESTCAT $200.;
    set libinput.adfa;
    TESTCAT='Findings About';
run;
data adsl_lb_vs_eg_fa;
    length RESULT $200.;
    set adsl adlb advs adeg adfa;
    where (ADT <= TRTSDT) and (ADT is not missing);
    if not missing(AVAL) then do;
      RESULT=compress(put(AVAL, best12.));
    end;
    else do;
      RESULT=AVALC;
    end;
run;
%OPEN_EXCEL(&normal_range_file.);
filename cmdexcel dde "Excel|[&normal_range_file_name.]ADLB_Normal Range_age!R1C1:R1000C13";
data raw_normal_range;
    length var1-var13 $200.;
    infile cmdexcel notab dlm="09"x dsd missover lrecl=50000 firstobs=2;
    input var1-var13;
run;
filename cmdexcel clear;
filename cmdexcel dde 'excel|system';
data _null_;
    file cmdexcel;
    put '[error(false)]';
    put '[quit()]';
run;
filename cmdexcel clear;
data normal_range_1;
    set raw_normal_range;
    PARAM=VAR1;
    PARAMCD=VAR3;
    SEX=VAR6;
    AGE=input(VAR7, best12.);
    HIGHVALUE=VAR10;
    keep PARAM PARAMCD SEX AGE HIGHVALUE;
run;
data normal_range_2;
    set normal_range_1;
    if SEX='' then output;
run;
data normal_range_m;
    set normal_range_2 (rename=(SEX=tempSEX));
    SEX='M';
    drop tempSEX;
run;
data normal_range_f;
    set normal_range_2 (rename=(SEX=tempSEX));
    SEX='F';
    drop tempSEX;
run;
data normal_range_3;
    set normal_range_1;
    if SEX^='' then output;
run;
data normal_range;
    set normal_range_3 normal_range_m normal_range_f;
    if (PARAMCD='ALT') or (PARAMCD='AST') or (PARAMCD='BILI') or (PARAMCD='CREAT') then output;
run;
proc sql noprint;
    create table temp_&output_file_name._1 as
    select a.*, b.HIGHVALUE
    from adsl_lb_vs_eg_fa a left join normal_range  b
    on (a.PARAMCD = b.PARAMCD) and
       (a.SEX = b.SEX) and
       (a.AGE = b.AGE);
quit;
data temp_&output_file_name._2;
    set temp_&output_file_name._1;
    if (PARAMCD='ALT') or (PARAMCD='AST') then do;
        REF_VALUE=HIGHVALUE*2.5;
    end;
    else if (PARAMCD='BILI') or (PARAMCD='CREAT') then do;
        REF_VALUE=HIGHVALUE*1.5;
    end;
run;
proc sql noprint;
    create table &output_file_name. as
    select SUBJID, SITENM, SEX, AGE, RFICDT, TRTSDT, TESTCAT, PARAM, ADT, RESULT, HIGHVALUE, REF_VALUE
    from temp_&output_file_name._2
    order by SUBJID, TESTCAT, PARAM, ADT, AVISITN, ATPTN;
quit;
%OPEN_EXCEL(&template.);
%SET_EXCEL(&output_file_name., 6, 2, %str(SUBJID SITENM SEX AGE RFICDT TRTSDT TESTCAT PARAM ADT RESULT HIGHVALUE REF_VALUE));
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
