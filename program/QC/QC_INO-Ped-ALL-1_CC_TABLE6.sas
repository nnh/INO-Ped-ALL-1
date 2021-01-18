**************************************************************************
Program Name : QC_INO-Ped-ALL-1_CC_TABLE6.sas
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
%let output_file_name=Table6;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
libname libinput "&inputpath." ACCESS=READONLY;
proc sql noprint;
    create table temp_table6_1 as
    select a.SUBJID, a.AVALC as DLT, b.AVALC as BESTRESP
    from (select * from libinput.adrs where PARAMCD = 'DLT') a, 
         (select * from libinput.adrs where PARAMCD = 'BESTRESP') b
    where a.SUBJID = b.SUBJID
    order by SUBJID;
quit;
proc sql noprint;
    create table adrs_mrd as
    select * from libinput.adrs where PARAMCD = 'MRD'
    order by SUBJID, ADT;
quit;
proc sql noprint;
    create table adrs_ovrlresp as
    select * from libinput.adrs where PARAMCD = 'OVRLRESP'
    order by SUBJID, ADT;
quit;
%EDIT_SUBJID_LIST(libinput.adrs, subjid_list);
%GET_MAX_OBS_CNT(subjid_list, adrs_mrd, adrs_ovrlresp, temp_subjid_list_1);
%UNION_OUTPUT_SUBJID(temp_subjid_list_1, temp_subjid_list_2);

%SET_SEQ_VALUES(temp_table6_1, temp_table6_2);
%SET_SEQ_VALUES(adrs_mrd, adrs_mrd_2);
%SET_SEQ_VALUES(adrs_ovrlresp, adrs_ovrlresp_2);
proc sql noprint;
    create table temp_table6_3 as
    select a.SUBJID, a.SEQ, b.DLT, b.BESTRESP
    from temp_subjid_list_2 a left join temp_table6_2 b on a.SUBJID = b.SUBJID;

    create table temp_table6_4 as
    select a.*,  b.ADT as MRD_ADT, b.ADY as MRD_ADY, b.AVALC as MRD_RES
    from temp_table6_3 a left join adrs_mrd_2 b 
      on (a.SUBJID = b.SUBJID) and (a.SEQ = b.SEQ);

    create table temp_table6_5 as
    select a.*,  b.ADT as OVRLRESP_ADT, b.ADY as OVRLRESP_ADY, b.AVALC as OVRLRESP_RES
    from temp_table6_4 a left join adrs_ovrlresp_2 b 
      on (a.SUBJID = b.SUBJID) and (a.SEQ = b.SEQ)
    order by a.SUBJID, a.SEQ;
quit;
data &output_file_name.;
    set temp_table6_5 (rename=(SUBJID=temp_SUBJID DLT=temp_DLT BESTRESP=temp_BESTRESP));
    by temp_SUBJID;
    if first.temp_SUBJID then do;
      DOSELEVEL=&dose_level.;
      SUBJID=temp_SUBJID;
      DLT=temp_DLT;
      BESTRESP=temp_BESTRESP;
    end;
    else do;
      call MISSING(DOSELEVEL);
      call MISSING(SUBJID);
      call MISSING(DLT);
      call MISSING(BESTRESP);
    end;
    keep DOSELEVEL SUBJID DLT MRD_ADT MRD_ADY MRD_RES OVRLRESP_ADT OVRLRESP_ADY OVRLRESP_RES BESTRESP;
run;
%OPEN_EXCEL(&template.);
%SET_EXCEL(&output_file_name., 7, 2, %str(DOSELEVEL SUBJID DLT MRD_ADT MRD_ADY MRD_RES OVRLRESP_ADT OVRLRESP_ADY OVRLRESP_RES BESTRESP));
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);
