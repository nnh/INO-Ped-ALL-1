**************************************************************************
Program Name : QC_INO-Ped-ALL-1_EDIT_SITE_REF_VALUE.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-3
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
%let input_file_name=Site_Ref_Value;
%let inputname=&input_file_name..xlsx;
%let input_sheetname=Sheet;
%let input_site_ref=&extpath.\&inputname.;
%let output_file_name=output_&input_file_name.;
%let outputname=&output_file_name..xlsx;
%let output=&extpath.\&outputname.;
%let normal_range_filename=INO-Ped-ALL-1_LB_Normal Range_20201228.xlsx;
%let normal_range=&extpath.\&normal_range_filename.;
%let normal_range_sheetname=ADLB_Normal Range_age;
%OPEN_EXCEL(&normal_range.);
filename cmdexcel dde "excel|[&normal_range_filename.]&normal_range_sheetname.!R2C1:R9999C13";
data raw_normal_range;
    length var1-var13 $200;
    infile cmdexcel notab dlm='09'x dsd missover lrecl=30000 firstobs=1;
    input var1-var13;
run;
filename cmdexcel clear;
%CLOSE_EXSEL_NOSAVE;
%OPEN_EXCEL(&input_site_ref.);
filename cmdexcel dde "excel|[&inputname.]&input_sheetname.!R2C1:R9999C8";
data raw_site_ref_value;
    length var1-var8 $200;
    infile cmdexcel notab dlm='09'x dsd missover lrecl=30000 firstobs=1;
    input var1-var8;
run;
filename cmdexcel clear;
%CLOSE_EXSEL_NOSAVE;
proc sql noprint;
    create table normal_range_itemnames as
    select distinct var3 
    from raw_normal_range
    order by var3;
quit;
proc sql noprint;
    create table output_site_ref_value as
    select * 
    from raw_site_ref_value
    where var6 not in (select var3 from normal_range_itemnames)
    order by var1, var6, var3;
quit;
data output_ds;
    set output_site_ref_value;
    length note $200;
    if var6='BASOLE' then do;
      note='好塩基球';
    end;
    if var6='BLASTLE' then do;
      note='末梢血腫瘍芽球';
    end;
    if var6='EOSLE' then do;
      note='好酸球';
    end;
    if var6='LYMLE' then do;
      note='リンパ球';
    end;
    if var6='MONOLE' then do;
      note='単球';
    end;
    if var6='MYBLALE' then do;
      note='骨髄血腫瘍芽球';
    end;
    if var6='NEUTLE' then do;
      note='好中球';
    end;
    if var6='PROT' then do;
      note='総たんぱく';
    end;
    if var6='UREAN' then do;
      note='BUN';
    end;
run;
%ds2csv (data=output_ds, runmode=b, csvfile=\\aronas\Datacenter\Users\ohtsuka\2020\20210303\def.csv);
