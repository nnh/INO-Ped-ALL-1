**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.3.26.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-4-7
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
%macro EDIT_T14_3_26(input_ds);
    proc sql noprint;
        create table avisit_list as
        select distinct AVISIT, AVISITN
        from &input_ds.
        where (AVISITN ^= .) and ((mod(AVISITN, 100) ^= 0) or (AVISITN = 800))
        order by AVISITN;
    quit;
    %local i j k temp_cnt; 
    proc sql noprint;
        select PARAM, count(PARAM) into: test_1-:test_99, :test_cnt from test_param_list;
        select AVISITN, count(AVISITN) into: avisit_1-:avisit_99, :avisit_cnt from avisit_list;
    quit; 
    %do i=1 %to &test_cnt.;
        proc sql noprint;
            create table temp_&input_ds._&i. as
            select *, 
                   case 
                     when (PARAMCD = 'HEIGHT') or (PARAMCD = 'WEIGHT') then 1
                     else ATPTN
                   end as temp_ATPTN 
            from &input_ds.
            where PARAM = "&&test_&i.";

            create table temp_&input_ds._&i._0_1 as
            select distinct SUBJID, BASE as AVAL
            from temp_&input_ds._&i.;
        quit;
        %EDIT_MEANS_2(temp_&input_ds._&i._0_1, means_&i._0_1, AVAL);
        data means_comp_&i._0_1;
          do i=1 to 6;
            output='-'; output;
          end;
        run;
        %do j=1 %to &avisit_cnt.;
          %do k=1 %to 3;
            proc sql noprint;
                create table temp_&input_ds._&i._&j._&k. as
                select distinct SUBJID, max(AVAL) as AVAL, BASE
                from temp_&input_ds._&i.
                where (AVISITN = &&avisit_&j.) and (temp_ATPTN = &k.)
                group by SUBJID;

                create table temp_&input_ds._comp_&i._&j._&k. as
                select SUBJID, (AVAL-BASE) as AVAL
                from temp_&input_ds._&i._&j._&k.;
              quit;
            %EDIT_MEANS_2(temp_&input_ds._&i._&j._&k., means_&i._&j._&k., AVAL);
            %EDIT_MEANS_2(temp_&input_ds._comp_&i._&j._&k., means_comp_&i._&j._&k., AVAL);
            proc sql noprint;
                select count(*) into: temp_cnt from means_&i._&j._&k.;
            quit;
            %if &temp_cnt. = 0 %then %do;
                data means_&i._&j._&k. temp_&input_ds._comp_&i._&j._&k.;
                    do i=1 to 6;
                      output='-'; output;
                    end;
                run;
            %end;
        %end;
      %end;
    %end;
%mend EDIT_T14_3_26;
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
        &output_var.=put(round(temp_mean, 0.01), 8.2); output;
        if temp_sd^=. then do;
          &output_var.=put(round(temp_sd, 0.001), 8.3); output;
        end;
        else do;
          &output_var.='-'; output;
        end;
        if min^='-0.0' then do; 
          &output_var.=put(round(min, 0.1), 8.1); output;
        end;
        else do;
          &output_var.='0.0'; output;
        end;      
        &output_var.=put(round(temp_median, 0.01), 8.2); output;
        if max^='-0.0' then do; 
          &output_var.=put(round(max, 0.1), 8.1); output;
        end;
        else do;
          &output_var.='0.0'; output;
        end;      
        keep &output_var.;
    run;
%mend EDIT_MEANS_2;
%macro SET_EXCEL_T14_3_26();
    %local i j k output_row output_col max_col;
    %do i=1 %to &test_cnt.;
      %let output_row=%eval(7+(&i.-1)*14);
      %do j=0 %to &avisit_cnt.;
      %let output_col=%eval(4+&j.);
      %if (&j. ^= 0) and (&j. ^= &avisit_cnt.) %then %do;
        %let max_col=3;
      %end;
      %else %do;
        %let max_col=1;
      %end;
          %do k=1 %to %eval(&max_col.);        
            %SET_EXCEL(means_&i._&j._&k., &output_row., &output_col., %str(output), &output_file_name.);
            %SET_EXCEL(means_comp_&i._&j._&k., %eval(&output_row.+8), &output_col., %str(output), &output_file_name.);
            %let output_col=%eval(&output_col.+1);
          %end;
      %end;
    %end;
%mend SET_EXCEL_T14_3_26;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%global test_cnt avisit_cnt max_col min_col;
%let output_file_name=T14.3.26;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=SAFFL;
libname libinput "&inputpath." ACCESS=READONLY;
%let input_ds=advs;
data &input_ds.;
    set libinput.&input_ds.;
    where &target_flg.='Y';
run;
data test_param_list;
    length PARAM $200;
    PARAM = 'Height (cm)'; output;
    PARAM = 'Weight (kg)'; output;
    PARAM = 'Temperature (C)'; output;
    PARAM = 'Diastolic Blood Pressure (mmHg)'; output;
    PARAM = 'Systolic Blood Pressure (mmHg)'; output;
    PARAM = 'Pulse Rate (beats/min)'; output;
run;
%EDIT_T14_3_26(advs);
%OPEN_EXCEL(&template.);
%SET_EXCEL_T14_3_26();
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);

