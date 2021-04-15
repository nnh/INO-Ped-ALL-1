DATA _NULL_ ;
     CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
     CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
RUN ;
proc printto log="\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\log\QC\result\DATA_L16.2.5.1_LOG_&_YYMM_._&_TIME_..txt" new;
run;
**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_L16.2.5.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-4-15
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
%macro ROW_COUNT(input_ds, output_ds);
    proc sql noprint;
        create table &output_ds. as
        select SUBJID, count(*) as row_cnt
        from &input_ds.
        group by SUBJID;
    quit;
%mend ROW_COUNT;
%macro EDIT_L16_2_5_1();
    %local subjid_cnt i;
    proc sql noprint;
        select SUBJID, count(*), max_row_cnt into:subjid_1-:subjid_99, :subjid_cnt, :row_cnt_1-:row_cnt_99 from row_cnt;
    quit;
    %do i=1 %to &subjid_cnt.;
      data temp_output_&i._1;
          do i=1 to &&row_cnt_&i.;
            DOSELEVEL=1;
            SUBJID="&&subjid_&i.";
            output;
          end;
          drop i;
      run;
      data temp_output_&i._2;
          set dlt;
          where SUBJID="&&subjid_&i.";
          drop SUBJID;
      run;
      data temp_output_&i._3;
          set mrd;
          where SUBJID="&&subjid_&i.";
          drop SUBJID;
      run;
      data temp_output_&i._4;
          set ovrlresp;
          where SUBJID="&&subjid_&i.";
          drop SUBJID;
      run;
      data temp_output_&i._5;
          set bestresp;
          where SUBJID="&&subjid_&i.";
          drop SUBJID;
      run;
      data output_&i.;
        merge temp_output_&i._1-temp_output_&i._5;
      run;      
    %end;
    data output;
        set output_1-output_%eval(&subjid_cnt.);
    run;
%mend EDIT_L16_2_5_1;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%let output_file_name=L16.2.5.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=.;
libname libinput "&inputpath." ACCESS=READONLY;
%let input_ds=adrs;
data &input_ds.;
    set libinput.&input_ds.;
run;
proc sql noprint;
    create table dlt as
    select SUBJID, AVALC as DLT
    from &input_ds.
    where PARAMCD = 'DLT'
    order by SUBJID, AVISITN;
    create table mrd as
    select SUBJID, ADT as MRD_DT, AVISITN, AVALC as MRD, catx(' ', AVISIT, cats('(', ADY, ')')) as MRD_DAY
    from &input_ds.
    where PARAMCD = 'MRD'
    order by SUBJID, AVISITN;
    create table ovrlresp as
    select SUBJID, ADT as OVRLRESP_DT, AVISITN, AVALC as OVRLRESP, catx(' ', AVISIT, cats('(', ADY, ')')) as OVRLRESP_DAY
    from &input_ds.
    where PARAMCD = 'OVRLRESP'
    order by SUBJID, AVISITN;
    create table bestresp as
    select SUBJID, ADT, AVISITN, AVISIT, ADY, AVALC as BESTRESP
    from &input_ds.
    where PARAMCD = 'BESTRESP'
    order by SUBJID, AVISITN;
quit;
%ROW_COUNT(bestresp, row_cnt_1);
%ROW_COUNT(dlt, row_cnt_2);
%ROW_COUNT(mrd, row_cnt_3);
%ROW_COUNT(ovrlresp, row_cnt_4);
proc sql noprint;
    create table temp_row_cnt_1 as
    select a.SUBJID,  a.row_cnt as row_cnt_1 , b.row_cnt as row_cnt_2
    from row_cnt_1 a left join row_cnt_2 b on a.SUBJID = b.SUBJID;
    create table temp_row_cnt_2 as
    select a.* , b.row_cnt as row_cnt_3
    from temp_row_cnt_1 a left join row_cnt_3 b on a.SUBJID = b.SUBJID;
    create table row_cnt as
    select a.* , b.row_cnt as row_cnt_4, max(row_cnt_1, row_cnt_1, row_cnt_1, row_cnt_4) as max_row_cnt
    from temp_row_cnt_2 a left join row_cnt_4 b on a.SUBJID = b.SUBJID;
quit;
%EDIT_L16_2_5_1;
%OPEN_EXCEL(&template.);
%CLEAR_EXCEL(&output_file_name., 7);
%SET_EXCEL(output, 7, 2, %str(DOSELEVEL SUBJID DLT MRD_DT MRD_DAY MRD OVRLRESP_DT OVRLRESP_DAY OVRLRESP BESTRESP), &output_file_name.); 
%OUTPUT_EXCEL(&output.);
proc printto;
run;
