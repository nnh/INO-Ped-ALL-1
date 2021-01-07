**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADEC.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-1-7
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
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_ADaM_LIBNAME.sas";
* Main processing start;
%let output_file_name=ADEC;
libname libinput "&outputpath." ACCESS=READONLY;
%READ_CSV(&inputpath., ec);
%READ_CSV(&inputpath., ds);
data adsl;
    set libinput.adsl;
run;
data ec_time;
    length STUDYID $200. DOMAIN $200. USUBJID $200. ECSEQ $200. ECSPID $200. ECTRT $200. 
           ECMOOD $200. ECDOSE $200. ECDOSU $200. ECDOSFRM $200. ECROUTE $200. VISITNUM 8. 
           ECSTDTC $200. ECENDTC $200.;
    infile "&inputpath.\ec.csv" dlm="," dsd missover firstobs=2;
    input STUDYID DOMAIN USUBJID ECSEQ ECSPID ECTRT ECMOOD ECDOSE ECDOSU ECDOSFRM ECROUTE 
          VISITNUM ECSTDTC ECENDTC;
    keep USUBJID VISITNUM ECSTDTC ECENDTC;
run;
*Dose (mg/m2);
proc sql noprint;
    create table temp_ec_dos_1 as
    select a.*,
           case 
             when length(b.ECSTDTC) = 16 then input(b.ECSTDTC, E8601DT19.)
             else .
           end as ASTDTM, 
           case
             when length(b.ECENDTC) = 16 then input(b.ECENDTC, E8601DT19.)
             else .
           end as AENDTM
    from ec a left join ec_time b on a.USUBJID = b.USUBJID and 
                                     a.VISITNUM = b.VISITNUM and 
                                     a.ECSTDTC ne . and a.ECENDTC ne . and 
                                    (a.ECSTDTC = input(b.ECSTDTC, YYMMDD10.)) and 
                                    (a.ECENDTC = input(b.ECENDTC, YYMMDD10.));
    create table temp_ec_dos_2 as 
    select USUBJID, ECDOSE as AVAL, 'Dose (mg/m2)' as PARAM, 'DOS' as PARAMCD, VISITNUM as AVISITN,
           ECSTDTC as ASTDT, ECENDTC as AENDT, ASTDTM, AENDTM, ECSPID, VISITNUM
    from temp_ec_dos_1
    where ECMOOD='PERFORMED';
quit;
* Duration of Treatment (Days);
proc sql noprint;
    create table temp_ec_DURTRT as
    select USUBJID, 'Duration of Treatment (Days)' as PARAM, 'DURTRT' as PARAMCD, 
           TRTEDT-TRTSDT+1 as AVAL
    from adsl
    where TRTEDT ne . and TRTSDT ne .;
quit;
* Duration of Follow-UP (Days);
proc sql noprint;
    create table temp_ec_DURFLU as
    select a.USUBJID, 'Duration of Follow-UP (Days)' as PARAM, 'DURFLU' as PARAMCD, 
           a.DSDTC-b.TRTSDT+1 as AVAL
    from (select USUBJID, max(DSDTC) as DSDTC from ds group by USUBJID) a left join adsl b on a.USUBJID = b.USUBJID
    where a.DSDTC ne . and b.TRTSDT ne .;
quit;
* Number of Cycles;
proc sql noprint;
    create table temp_ec_CYCN as
    select distinct a.USUBJID, 'Number of Cycles' as PARAM, 'CYCN' as PARAMCD, 
           input(substr(ECSPID, 3, 1), best12.) as AVAL
    from ec a, (select USUBJID, max(VISITNUM) as VISITNUM from ec group by USUBJID) b 
    where a.USUBJID = b.USUBJID and a.VISITNUM = b.VISITNUM;
quit;
* Total Dose (mg/m2);
data temp_ec_TOTDOS;
    set ec;
    where ECMOOD='PERFORMED';
    by USUBJID;
    retain AVAL;
    if first.USUBJID then do;
      AVAL=0;
    end;
    AVAL=AVAL+ECDOSE;
    PARAM='Total Dose (mg/m2)';
    PARAMCD='TOTDOS';
    if last.USUBJID then output;
    keep USUBJID PARAM PARAMCD AVAL;
run;
* CYCDOS:Total Dose during Cycle x (mg/m2);
proc sql noprint;
    create table temp_ec_CYCDOS as
    select USUBJID, 'Total Dose during Cycle x (mg/m2)' as PARAM, 'CYCDOS' as PARAMCD, 
           sum(ECDOSE) as AVAL, (INT((max(VISITNUM) + 100) / 100)) * 100 as AVISITN
    from ec
    where ECMOOD='PERFORMED'
    group by USUBJID, ECSPID;
quit;
* RDI;
proc sql noprint;
    create table temp_ec_RDI as
    select a.USUBJID, 'RDI' as PARAM, 'RDI' as PARAMCD,
           round(a.ECDOSE / b.ECDOSE * 100, 0.01) as AVAL, 'N'
    from (select USUBJID, sum(ECDOSE) as ECDOSE from ec where ECMOOD = 'PERFORMED' group by USUBJID) a, 
         (select USUBJID, sum(ECDOSE) as ECDOSE from ec where ECMOOD = 'SCHEDULED' group by USUBJID) b
    where a.USUBJID = b.USUBJID;
quit;
* CYCRDI:RDI Cycle x;
proc sql noprint;
    create table temp_ec_CYCRDI_1 as
    select USUBJID, sum(ECDOSE) as ECDOSE, max(VISITNUM) as VISITNUM, ECSPID from ec 
    where ECMOOD = 'PERFORMED' group by USUBJID, ECSPID;

    create table temp_ec_CYCRDI_2 as
    select USUBJID, sum(ECDOSE) as ECDOSE, max(VISITNUM) as VISITNUM, ECSPID from ec 
    where ECMOOD = 'SCHEDULED' group by USUBJID, ECSPID;

    create table temp_ec_CYCRDI_3 as
    select b.USUBJID, 'RDI Cycle x' as PARAM, 'CYCRDI' as PARAMCD,
           round(a.ECDOSE / b.ECDOSE * 100, 0.01) as AVAL,  
           case 
             when a.VISITNUM < b.VISITNUM then INT((b.VISITNUM + 100) / 100) * 100
             else INT((a.VISITNUM + 100) / 100) * 100
           end as AVISITN
    from temp_ec_CYCRDI_1 a right join temp_ec_CYCRDI_2 b on a.USUBJID = b.USUBJID and a.ECSPID = b.ECSPID;
quit;
* INT:Interruption;
proc sql noprint;
    create table temp_ec_INT_1 as
    select USUBJID, count(*) as dose_count, max(VISITNUM) as VISITNUM
    from temp_ec_dos_2
    where AVAL > 0
    group by USUBJID, ECSPID;

    create table temp_ec_INT_2 as
    select USUBJID, 'Interruption' as PARAM, 'INT' as PARAMCD,
           case
             when dose_count = 3 then 'N'
             else 'Y'
           end as AVALC, 
           INT((VISITNUM + 100) / 100) * 100 as AVISITN
    from temp_ec_INT_1;
quit;
* RES:Restart;
proc sql noprint;
    create table temp_ec_RES_1 as
    select a.USUBJID, a.AVISITN, b.AVALC
    from temp_ec_INT_2 a, (select USUBJID, AVISITN, AVALC from temp_ec_INT_2 where AVALC = 'Y') b
    where a.USUBJID = b.USUBJID and
          a.AVISITN > b.AVISITN; 

    create table temp_ec_RES_2 as
    select a.USUBJID, 'Restart' as PARAM, 'RES' as PARAMCD,
           case
             when b.AVALC = 'Y' then 'Y'
             else 'N' 
           end as AVALC,
           a.AVISITN
    from temp_ec_INT_2 a left join temp_ec_RES_1 b on a.USUBJID = b.USUBJID and a.AVISITN = b.AVISITN;
quit;

data temp_ec_aval;
    length PARAM $200. PARAMCD $200. USUBJID $200.;
    set temp_ec_dos_2 
        temp_ec_DURTRT
        temp_ec_DURFLU
        temp_ec_CYCN
        temp_ec_TOTDOS
        temp_ec_CYCDOS
        temp_ec_RDI
        temp_ec_CYCRDI_3
        temp_ec_INT_2
        temp_ec_RES_2;
run;
%SET_AVISIT(temp_ec_aval, temp_ec_avisit);
proc sql noprint;
    create table temp_adec_1 as
    select distinct b.STUDYID, b.USUBJID, b.SUBJID, b.TRTSDT, b.TRTEDT, b.RFICDT, b.DTHDT, b.SITEID, 
           b.SITENM, b.AGE, b.AGEGR1, b.AGEGR1N, b.AGEU, b.SEX, b.SEXN, b.RACE, b.ARM, b.TRT01P, 
           b.TRT01PN, b.COMPLFL, b.FASFL, b.PPSFL, b.SAFFL, b.DLTFL, a.PARAM,
           a.PARAMCD, a.AVAL, a.AVALC, a.ASTDT, a.AENDT, a.ASTDTM, a.AENDTM, a.AVISIT, a.AVISITN
    from temp_ec_avisit a left join adsl b on a.USUBJID = b.USUBJID
    order by USUBJID, PARAMCD, AVISITN;
quit;
data &output_file_name.;
    length STUDYID $200. USUBJID $200. SUBJID $200. TRTSDT 8. TRTEDT 8. RFICDT 8. DTHDT 8. SITEID 8. 
           SITENM $200. AGE 8. AGEGR1 $200. AGEGR1N 8. AGEU $200. SEX $200. SEXN 8. RACE $200. 
           ARM $200. TRT01P $200. TRT01PN 8. COMPLFL $200. FASFL $200. PPSFL $200. SAFFL $200.
           DLTFL $200. PARAM $200. PARAMCD $200. AVAL 8. AVALC $200. ASTDT 8. AENDT 8. ASTDTM 8. 
           AENDTM 8. AVISIT $200. AVISITN 8.;
    set temp_adec_1;
    label STUDYID='Study Identifier' USUBJID='Unique Subject Identifier' 
          SUBJID='Subject Identifier for the Study' TRTSDT='Date of First Exposure to Treatment' 
          TRTEDT='Date of Last Exposure to Treatment' RFICDT='Date of Informed Consent' 
          DTHDT='Date of Death' SITEID='Study Site Identifier' SITENM='Study Site Name' AGE='Age' 
          AGEGR1='Pooled Age Group 1' AGEGR1N='Pooled Age Group 1 (N)' AGEU='Age Units' SEX='Sex' 
          SEXN='Sex (N)' RACE='Race' ARM='Description of Planned Arm' 
          TRT01P='Planned Treatment for Period 01' TRT01PN='Planned Treatment for Period 01 (N)' 
          COMPLFL='Completers Population Flag' FASFL='Full Analysis Set Population Flag'
          PPSFL='Per Protocol Set Population Flag' SAFFL='Safety Population Flag'
          DLTFL='DLT Population Flag' PARAM='Parameter' PARAMCD='Parameter Code' AVAL='Analysis Value' 
          AVALC='Analysis Value (C)' ASTDT='Analysis Start Date' AENDT='Analysis End Date' 
          ASTDTM='Analysis Start Datetime' AENDTM='Analysis End Datetime' AVISIT='Analysis Visit' 
          AVISITN='Analysis Visit (N)';
    format _ALL_;
    informat _ALL_;
    format TRTSDT YYMMDD10. TRTEDT YYMMDD10. RFICDT YYMMDD10. DTHDT YYMMDD10. ASTDT YYMMDD10. 
           AENDT YYMMDD10. ASTDTM E8601DT19. AENDTM E8601DT19.;
    keep STUDYID USUBJID SUBJID TRTSDT TRTEDT RFICDT DTHDT SITEID SITENM AGE AGEGR1 AGEGR1N AGEU 
         SEX SEXN RACE ARM TRT01P TRT01PN COMPLFL FASFL PPSFL SAFFL DLTFL PARAM PARAMCD AVAL AVALC 
         ASTDT AENDT ASTDTM AENDTM AVISIT AVISITN; 
run;
data libout.&output_file_name.;
    set &output_file_name.;
run;
%SDTM_FIN(&output_file_name.);
