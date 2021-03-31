**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.25.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-3-31
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
%let output_file_name=T14.3.25;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
data adlb;
    set libinput.adlb;
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
proc sql noprint;
    create table avisit_list as
    select distinct AVISIT, AVISITN
    from adlb
    where (AVISITN ^= .) and ((mod(AVISITN, 100) ^= 0) or (AVISITN = 800))
    order by AVISITN;
quit;

%macro EDIT_T14_3_25();
    %local i j; 
    %global test_cnt avisit_cnt max_col min_col;
    %let max_col=%eval(&avisit_cnt.+1);
    %let min_col=%eval(&max_col.+1);
    proc sql noprint;
        select PARAM, count(PARAM) into: test_1-:test_99, :test_cnt from test_param_list;
        select AVISITN, count(AVISITN) into: avisit_1-:avisit_99, :avisit_cnt from avisit_list;
    quit; 
    %do i=1 %to &test_cnt.;
        proc sql noprint;
            create table temp_adlb_&i. as
            select *
            from adlb
            where PARAM = "&&test_&i.";

            create table temp_adlb_&i._0 as
            select distinct SUBJID, BASE as AVAL
            from temp_adlb_&i.;
        quit;
        %EDIT_MEANS_2(temp_adlb_&i._0, means_&i._0, AVAL);
        %do j=1 %to &min_col.;
          proc sql noprint;
            %if &j.=&max_col. %then %do;
              create table temp_adlb_&i._&max_col. as
              select SUBJID, max(AVAL) as AVAL
              from temp_adlb_&i.
              group by SUBJID;
            %end;
            %else %if &j.=&min_col. %then %do;
              create table temp_adlb_&i._&min_col. as
              select SUBJID, min(AVAL) as AVAL
              from temp_adlb_&i.
              group by SUBJID;
            %end;
            %else %do;
              create table temp_adlb_&i._&j. as
              select SUBJID, max(AVAL) as AVAL
              from temp_adlb_&i.
              where AVISITN = &&avisit_&j.
              group by SUBJID;
            %end;
          quit;
          %EDIT_MEANS_2(temp_adlb_&i._&j., means_&i._&j., AVAL);
        %end;
    %end;

%mend EDIT_T14_3_25;
%macro EDIT_MEANS_2(input_ds, output_ds, target_var);
    %let output_var=output;
    proc means data=&input_ds.  noprint;
        var &target_var.;
        output out=temp_means n=n mean=temp_mean stddev=temp_sd median=temp_median min=min max=max;
    run;
    data &output_ds.;
        length &output_var. $200;
        set temp_means;
        &output_var.=n; output;
        &output_var.=put(temp_mean, 8.2); output;
        &output_var.=put(temp_sd, 8.3); output;
        &output_var.=put(min, 8.1); output;
        &output_var.=put(temp_median, 8.2); output;
        &output_var.=put(max, 8.1); output;
        keep &output_var.;
    run;
%mend EDIT_MEANS_2;
%EDIT_T14_3_25();
%macro aaa();
    %local i j output_row output_col;
    %do i=1 %to 2;
      %let output_row=%eval(7+(&i.-1)*14);
      %do j=0 %to &min_col.;
      %let output_col=%eval(4+&j.);
        %SET_EXCEL(means_&i._&j., &output_row., &output_col., %str(output), &output_file_name.);
      %end;
    %end;
%mend aaa;
%aaa();


%OPEN_EXCEL(&template.);


%SET_EXCEL(output_n, 7, 3, %str(N), &output_file_name.);
%SET_EXCEL(output_soc_pt, 8, 2, %str(AETERM N_PER), &output_file_name.);
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);