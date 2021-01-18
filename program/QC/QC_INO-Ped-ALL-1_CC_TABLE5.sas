**************************************************************************
Program Name : QC_INO-Ped-ALL-1_CC_TABLE5.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-1-18
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
%let output_file_name=Table5;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
libname libinput "&inputpath." ACCESS=READONLY;
data adec_dos adec_int adec_res adec_cycn;
    set libinput.adec;
    DOSELEVEL=&dose_level.;
    CYCLE=input(substrn(AVISITN, 1, 1), best12.);
    if PARAMCD='DOS' then do;
      UNIT='mg/m2';
      output adec_dos;
    end;
    else if PARAMCD='INT' then do;
      output adec_int;
    end;
    else if PARAMCD='RES' then do;
      output adec_res;
    end;
    else if PARAMCD='CYCRDI' then do;
      output adec_cycn;
    end;
    keep DOSELEVEL SUBJID SITENM AGE SEX AVISIT ASTDT UNIT CYCLE AVALC AVISITN AVAL;
run;
proc sql noprint;
    create table adec_cycn_int as
    select a.*, b.AVALC as INT
    from adec_cycn a left join adec_int b 
      on (a.SUBJID = b.SUBJID) and
         (a.CYCLE = b.CYCLE);

    create table adec_cycn_int_res as
    select a.DOSELEVEL, a.SUBJID, a.SITENM, a.AGE, a.SEX, a.AVISIT, . as ASTDT, '' as UNIT, 
           a.INT, b.AVALC as RES, a.AVISITN as AVISITN, . as AVAL
    from adec_cycn_int a left join adec_res b 
      on (a.SUBJID = b.SUBJID) and
         (a.CYCLE = b.CYCLE);

    create table temp_table5_1 as
    select * from adec_dos
    outer union corr
    select * from adec_cycn_int_res
    order by SUBJID, AVISITN;
quit;
data &output_file_name.;
    set temp_table5_1 (rename=(DOSELEVEL=temp_DOSE SUBJID=temp_SUBJID SITENM=temp_SITENM AGE=temp_AGE SEX=temp_SEX));
    by temp_SUBJID;
    if first.temp_SUBJID then do;
      DOSELEVEL=temp_DOSE;
      SUBJID=temp_SUBJID;
      SITENM=temp_SITENM;
      AGE=temp_AGE;
      SEX=temp_SEX;
    end;
    else do;
      call MISSING(DOSELEVEL);
      call MISSING(SUBJID);
      call MISSING(SITENM);
      call MISSING(AGE);
      call MISSING(SEX);
    end;
    keep DOSELEVEL SUBJID SITENM AGE SEX AVISIT ASTDT AVAL UNIT INT RES;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(&output_file_name., 7, 2, %str(DOSELEVEL SUBJID SITENM AGE SEX AVISIT ASTDT AVAL UNIT INT RES));
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
