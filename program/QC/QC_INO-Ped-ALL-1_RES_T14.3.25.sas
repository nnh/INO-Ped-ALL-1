**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.25.sas
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
%macro EDIT_T14_3_25(input_ds);
    %local i j; 
  %EDIT_ROUND_TABLE();
    proc sql noprint;
        create table avisit_list as
        select distinct AVISIT, AVISITN
        from &input_ds.
        where (AVISITN ^= .) and ((mod(AVISITN, 100) ^= 0) or (AVISITN = 800))
        order by AVISITN;
    quit;
    proc sql noprint;
        select PARAM, count(PARAM) into: test_1-:test_99, :test_cnt from test_param_list;
        select AVISITN, count(AVISITN) into: avisit_1-:avisit_99, :avisit_cnt from avisit_list;
    quit; 
    %let max_col=%eval(&avisit_cnt.+1);
    %let min_col=%eval(&avisit_cnt.+2);
    %do i=1 %to &test_cnt.;
        proc sql noprint;
            create table temp_&input_ds._&i. as
            select *
            from &input_ds.
            where PARAM = "&&test_&i.";

            create table temp_&input_ds._&i._0 as
            select distinct SUBJID, BASE as AVAL
            from temp_&input_ds._&i.;

            create table output_test_&i. as
            select PARAM
            from output_test
            where temp_param = "&&test_&i.";
        quit;
        %EDIT_MEANS_2(temp_&input_ds._&i._0, means_&i._0, AVAL);
        data means_comp_&i._0;
          do i=1 to 6;
            output='-'; output;
          end;
        run;
        %do j=1 %to &min_col.;
          proc sql noprint;
            %if &j.=&max_col. %then %do;
              create table temp_&input_ds._&i._&j. as
              select distinct SUBJID, max(AVAL) as AVAL, BASE
              from temp_&input_ds._&i.
              group by SUBJID;
            %end;
            %else %if &j.=&min_col. %then %do;
              create table temp_&input_ds._&i._&j as
              select distinct SUBJID, min(AVAL) as AVAL, BASE
              from temp_&input_ds._&i.
              group by SUBJID;
            %end;
            %else %do;
              create table temp_&input_ds._&i._&j. as
              select distinct SUBJID, max(AVAL) as AVAL, BASE
              from temp_&input_ds._&i.
              where AVISITN = &&avisit_&j.
              group by SUBJID;
            %end;
              create table temp_&input_ds._comp_&i._&j. as
              select SUBJID, (AVAL-BASE) as AVAL
              from temp_&input_ds._&i._&j.;
          quit;
          %EDIT_MEANS_2(temp_&input_ds._&i._&j., means_&i._&j., AVAL);
          %EDIT_MEANS_2(temp_&input_ds._comp_&i._&j., means_comp_&i._&j., AVAL);
        %end;
    %end;
%mend EDIT_T14_3_25;
%macro SET_EXCEL_2(output_file_name, output_start_row, output_start_col, output_var, sheet_name);
    %local colcount rowcount output_end_col output_end_row;
    proc contents data=&output_file_name.
        out=_tmpxx_ noprint;
    run;
    %let colcount=0;
    data _NULL_;
        set &output_file_name. nobs=rowcnt;
        call symputx("rowcount", rowcnt);
    run;
    %let output_end_col=%eval(&output_start_col.+&colcount);
    %let output_end_row=%eval(&output_start_row.+&rowcount);
    filename cmdexcel dde "excel|&sheet_name.!R&output_start_row.C&output_start_col.:R&output_end_row.C&output_end_col.";
    data _NULL_;
        set &output_file_name.;
        file cmdexcel dlm='09'X notab dsd;
        put &output_var.;
    run;
    filename cmdexcel clear;    
%mend SET_EXCEL_2;
%macro SET_EXCEL_T14_3_25();
    %local i j output_row output_col;
    %do i=1 %to &test_cnt.;
      %let output_row=%eval(7+(&i.-1)*14);
      %SET_EXCEL_2(output_test_&i., &output_row., 2, %str(PARAM), &output_file_name.);
      %do j=0 %to &min_col.;
      %let output_col=%eval(4+&j.);
        %SET_EXCEL(means_&i._&j., &output_row., &output_col., %str(output), &output_file_name.);
        %SET_EXCEL(means_comp_&i._&j., %eval(&output_row.+8), &output_col., %str(output), &output_file_name.);
      %end;
    %end;
%mend SET_EXCEL_T14_3_25;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%global test_cnt avisit_cnt max_col min_col;
%let output_file_name=T14.3.25;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
%let input_ds=adlb;
data &input_ds.;
    set libinput.&input_ds.;
    where &target_flg.='Y';
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
data output_test;
    length PARAM $200.;
    set test_param_list(rename=(PARAM=temp_param));
    if (temp_param='Direct Bilirubin (mg/dL)') or 
       (temp_param='Uric Acid Crystals (mg/dL)') or 
       (temp_param='Lactate Dehydrogenase (IU/L)') or 
       (temp_param='Amylase (IU/L)') then do;
      PARAM=cats(temp_param, '09'X);
    end;
    else do;
      PARAM=temp_param;
    end;
run;
%EDIT_T14_3_25(&input_ds.);
%OPEN_EXCEL(&template.);
%SET_EXCEL_T14_3_25();
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
