**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_L16.2.7.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-4-12
SAS version : 9.4
**************************************************************************;
proc datasets library=work kill nolist; quit;
options nomprint nomlogic nosymbolgen noquotelenmax;
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
%macro SET_EXCEL_L16_2_7_1();
    %local i j k output_row output_col;
    %let output_row=5;
    %do i=1 %to 1;
      %do j=1 %to &avisit_cnt.;
        %let output_row=%eval(&output_row.+1);
        %do k=1 %to 2;
          %let output_col=%eval(5+(&k.-1)*2);
            %SET_EXCEL(temp_adlb_normal_range_&i._&j._&k., &output_row., &output_col., %str(AVAL FLG), &output_file_name.);
        %end;
      %end;
    %end;
%mend SET_EXCEL_L16_2_7_1;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%global test_cnt avisit_cnt subjid_cnt;
%let output_file_name=L16.2.7.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
%let site_range_filename=Site_Ref_Value.xlsx;
%let site_range=&extpath.\&site_range_filename.;
%let site_range_sheetname=Sheet;
%let normal_range_filename=INO-Ped-ALL-1_LB_Normal Range_20201228.xlsx;
%let normal_range=&extpath.\&normal_range_filename.;
%let normal_range_sheetname=ADLB_Normal Range_age;
libname libinput "&inputpath." ACCESS=READONLY;
%let input_ds=adlb;
data &input_ds.;
    set libinput.&input_ds.;
    where &target_flg.='Y';
run;
%OPEN_EXCEL(&site_range.);
filename cmdexcel dde "excel|[&site_range_filename.]&site_range_sheetname.!R2C1:R9999C8";
data raw_site_range;
    length var1-var8 $200;
    infile cmdexcel notab dlm='09'x dsd missover lrecl=30000 firstobs=1;
    input var1-var8;
run;
filename cmdexcel clear;
%CLOSE_EXSEL_NOSAVE;
%OPEN_EXCEL(&normal_range.);
filename cmdexcel dde "excel|[&normal_range_filename.]&normal_range_sheetname.!R2C1:R9999C13";
data raw_normal_range;
    length var1-var13 $200;
    infile cmdexcel notab dlm='09'x dsd missover lrecl=30000 firstobs=1;
    input var1-var13;
run;
filename cmdexcel clear;
%CLOSE_EXSEL_NOSAVE;
proc sql noprint;
    create table site_list as
    select distinct SITEID, SITENM
    from &input_ds.;

    create table normal_range as
    select distinct a.var3 as PARAMCD, a.var2 as PARAM, a.var6 as SEX, input(a.var7, best12.) as AGE, a.var8 as UNIT, input(a.var9, best12.) as LOW, input(a.var10, best12.) as HIGH, b.SITEID, b.SITENM
    from raw_normal_range a, site_list b;

    create table site_range as
    select var6 as PARAMCD, var5 as PARAM, var3 as SEX, input(var4, best12.) as AGE, '' as UNIT, input(var7, best12.) as LOW, input(var8, best12.) as HIGH, input(var1, best12.) as SITEID, var2 as SITENM
    from raw_site_range;

    create table temp_test_range as
    select * from normal_range
    outer union corr
    select * from site_range
    order by PARAMCD, SITEID, SEX, AGE; 
quit;
data temp_test_range_1 temp_test_range_2;
    set temp_test_range;
    if SEX='' then do;
      output temp_test_range_1;
    end;
    else do;
      output temp_test_range_2;
    end;
run;
data temp_test_range_M;
    set temp_test_range_1(rename=(SEX=temp_sex));
    SEX='M';
    drop temp_sex;
    output;
run;
data temp_test_range_F;
    set temp_test_range_1(rename=(SEX=temp_sex));
    SEX='F';
    drop temp_sex;
    output;
run;
proc sql noprint;
    create table temp_test_range_3 as
    select * from temp_test_range_M
    outer union corr
    select * from temp_test_range_F
    outer union corr
    select * from temp_test_range_2
    order by PARAMCD, SITEID, SEX, AGE; 
quit;
data temp_test_range;
    set temp_test_range_3(rename=(LOW=temp_low HIGH=temp_high));
    if PARAMCD='WBC' then do;
      LOW=temp_low*1000;
      HIGH=temp_high*1000;
    end;
    else do;
      LOW=temp_low;
      HIGH=temp_high;
    end;
run;
data test_param_list;
    length PARAM $200;
    PARAM = 'Leukocytes (10^6/L)'; output;
    PARAM = 'Neutrophils/Leukocytes (%)'; output;
    PARAM = 'Eosinophils/Leukocytes (%)'; output;
    PARAM = 'Basophils/Leukocytes (%)'; output;
    PARAM = 'Monocytes/Leukocytes (%)'; output;
    PARAM = 'Lymphocytes/Leukocytes (%)'; output;
    PARAM = 'Blasts/Leukocytes (%)'; output;
    PARAM = 'Hemoglobin (g/dL)'; output;
    PARAM = 'Platelets (10^10/L)'; output;
    PARAM = 'Sodium (mEq/L)'; output;
    PARAM = 'Potassium (mEq/L)'; output;
    PARAM = 'Magnesium (mg/dL)'; output;
    PARAM = 'Calcium (mg/dL)'; output;
    PARAM = 'Creatinine (mg/dL)'; output;
    PARAM = 'Albumin (g/dL)'; output;
    PARAM = 'Alanine Aminotransferase (IU/L)'; output;
    PARAM = 'Aspartate Aminotransferase (IU/L)'; output;
    PARAM = 'Glucose (mg/dL)'; output;
    PARAM = 'Phosphate (mg/dL)'; output;
    PARAM = 'Bilirubin (mg/dL)'; output;
    PARAM = 'Direct Bilirubin (mg/dL)'; output;
    PARAM = 'Urea Nitrogen (mg/dL)'; output;
    PARAM = 'Uric Acid Crystals (mg/dL)'; output;
    PARAM = 'Alkaline Phosphatase (IU/L)'; output;
    PARAM = 'Lactate Dehydrogenase (IU/L)'; output;
    PARAM = 'Gamma Glutamyl Transferase (IU/L)'; output;
    PARAM = 'Protein (g/dL)'; output;
    PARAM = 'Amylase (IU/L)'; output;
    PARAM = 'Lipase (IU/L)'; output;
run;
proc sql noprint;
    create table subjid_list as
    select distinct SUBJID
    from &input_ds.
    order by SUBJID;
quit;
proc sql noprint;
    create table adlb_normal_range as
    select a.*, b.LOW, b.HIGH, b.UNIT, 
           case
           when a.AVAL < b.LOW then 'L'
           when b.HIGH < a.AVAL then 'H'
           else ''
           end as FLG
    from adlb a left join test_range b on (a.PARAMCD = b.PARAMCD) and (a.AGE = b.AGE) and (a.SEX = b.SEX) and (a.SITEID = b.SITEID);
quit;
%macro EDIT_L16_2_7_1(input_ds);
    %local i j k;
    proc sql noprint;
        select PARAM, count(PARAM) into: test_1-:test_99, :test_cnt from test_param_list;
        select SUBJID, count(SUBJID) into:subjid_1-:subjid_99, :subjid_cnt from subjid_list;
    quit; 
    %do i=1 %to 1;
      proc sql noprint;
          create table temp_&input_ds._&i. as
          select SUBJID, SEX, AVISIT, AVISITN, PARAM, PARAMCD, AVAL, AVALC, LOW, HIGH, UNIT, FLG
          from &input_ds.
          where SUBJID = "&&subjid_&i."
          order by PARAMCD, AVISITN;

          create table temp_avisit_&i. as
          select distinct AVISIT, AVISITN
          from temp_&input_ds._&i.
          where AVISITN ^= .
          order by AVISITN;

          select AVISIT, count(*) into:avisit_1-:avisit_99, :avisit_cnt from temp_avisit_&i.;
      quit;
      %do j=1 %to &avisit_cnt.;
        data temp_&input_ds._&i._&j.;
            set temp_&input_ds._&i.;
            where AVISIT="&&avisit_&j.";
        run;
        %do k=1 %to 2;
          data temp_&input_ds._&i._&j._&k.;
              set temp_&input_ds._&i._&j.;
              where PARAM="&&test_&k.";
              keep AVAL FLG;
          run;
        %end;
      %end;
    %end;
%mend EDIT_L16_2_7_1;



%EDIT_L16_2_7_1(adlb_normal_range);
%OPEN_EXCEL(&template.);
%SET_EXCEL_L16_2_7_1();
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
