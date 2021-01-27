**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADSL.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-1-27
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
%let output_file_name=ADSL;
%READ_CSV(&inputpath., dm);
%READ_CSV(&inputpath., ds);
%READ_CSV(&inputpath., ie);
%READ_CSV(&inputpath., vs);
%READ_CSV(&inputpath., mh);
%READ_CSV(&inputpath., eg);
%READ_CSV(&inputpath., sc);
%READ_CSV(&inputpath., pr);
%READ_CSV(&inputpath., qs);
%READ_CSV(&inputpath., lb);
%READ_CSV(&inputpath., pe);
%READ_CSV(&extpath., facilities);
data temp_adsl_1;
    length AGEGR1 $200. SUBJID $200.;
    set dm(rename=(RFXSTDTC=TRTSDT RFXENDTC=TRTEDT RFICDTC=RFICDT DTHDTC=DTHDT SUBJID=temp_SUBJID));   
    temp=put(temp_SUBJID, z4.);
    SUBJID=temp; 
    if AGE < 2 then do;
      AGEGR1="<2";
      AGEGR1N=1;
    end;
    else if (2 <= AGE) and (AGE < 12) then do;
      AGEGR1='>=2-<12';
      AGEGR1N=2;
    end;
    else if 12 <= AGE then do;
      AGEGR1='>=12';
      AGEGR1N=3;
    end;
    else do;
      AGEGR1="";
      AGEGR1N=.;
    end;

    if SEX="M" then do;
      SEXN=1;
    end;
    else if SEX="F" then do;
      SEXN=2;
    end;
    else do;
      SEXN=.;
    end;
    TRT01P=ARM;
    if TRT01P="COHORT1" then do;
      TRT01PN=1;
    end;
    else if TRT01P="Screen Failure" then do;
      TRT01PN=2;
    end;
    else do;
      TRT01PN=.;
    end;
run;
proc sql noprint;
    create table temp_adsl_2 as
    select a.*, b.DSTERM, b.EPOCH,
    case
      when EPOCH="FOLLOW-UP" then 'Y'
      else 'N'
    end as COMPLFL 
    from temp_adsl_1 a left join (select * from ds where (DSTERM="COMPLETED") and (EPOCH="FOLLOW-UP")) b on a.USUBJID = b.USUBJID;
quit;
proc sql noprint;
    create table temp_adsl_3 as
    select a.*, b.IETESTCD, b.IETEST
    from temp_adsl_2 a left join ie b on a.USUBJID = b.USUBJID;
quit;
%GET_TEST_RESULT(vs, HEIGHT, temp_adsl_3, temp_adsl_4, HEIGHT);
%GET_TEST_RESULT(vs, WEIGHT, temp_adsl_4, temp_adsl_5, WEIGHT);
data temp_adsl_6;
    set temp_adsl_5;
    BSA=round((HEIGHT*WEIGHT/3600)**(1/2), 0.01);
    BMI=round(WEIGHT/(HEIGHT/100)**2, 0.01);
run;
proc sql noprint;
    create table temp_adsl_7 as 
    select a.*, b.MHTERM as PRIMDIAG, INT((MHENDTC-MHSTDTC)/30.4375) as DISDUR, MHENDTC
    from temp_adsl_6 a left join (select * from mh where MHCAT = "PRIMARY DIAGNOSIS") b on a.USUBJID = b.USUBJID;
quit;
proc sql noprint;
    create table temp_adsl_8 as
    select a.*, MHOCCUR as ALLER
    from temp_adsl_7 a left join (select * from mh where MHCAT = "ALLERGIC") b on a.USUBJID = b.USUBJID;
quit;
%GET_TEST_RESULT(eg, INTP, temp_adsl_8, temp_adsl_9, INTP);
proc sql noprint;
    create table temp_adsl_10 as
    select a.*, 
    case 
      when b.SCTESTCD="SALVSTAT" then b.SCORRES
      else ""
    end as RELREF
    from temp_adsl_9 a left join (select * from sc where SCTESTCD="SALVSTAT") b on a.USUBJID = b.USUBJID;
quit;
data temp_adsl_11;
    set temp_adsl_10;
    select;
      when (RELREF="INDUCTION FAILURE") do;
        RELREFN=1;
      end;
      when (RELREF="FIRST RELAPSE") do;
        RELREFN=2;
      end;
      when (RELREF="SECOND RELAPSE") do;
        RELREFN=3;
      end;
      when (RELREF="OTHER") do;
        RELREFN=4;
      end;
      otherwise RELREFN=.;
    end;
run;
proc sql noprint;
    create table temp_adsl_12 as
    select a.*, 
    case 
      when PRTRT="SCT(BMT,CBT,PBSCT)" then PROCCUR
      else ""
    end as HSCT
    from temp_adsl_11 a left join (select * from pr where PRTRT="SCT(BMT,CBT,PBSCT)") b on a.USUBJID = b.USUBJID;
quit;
proc sql noprint;
    create table temp_adsl_13 as
    select a.*,
    case
      when PRTRT="RADIATION" then PROCCUR
      else ""
    end as RAD
    from temp_adsl_12 a left join (select * from pr where PRTRT="RADIATION") b on a.USUBJID = b.USUBJID;
quit;
proc sql noprint;
    create table temp_adsl_14 as
    select a.*,
    case
      when QSCAT="LANSKY" then QSORRES
      when QSCAT="KPS" then QSORRES
      else ""
    end as LKPS
    from temp_adsl_13 a left join (select * from qs where (QSCAT="LANSKY") or (QSCAT="KPS")) b on a.USUBJID = b.USUBJID;
quit;
data temp_adsl_15;
    length LKPSGR1 $200.;
    set temp_adsl_14;
    select;
      when (LKPS="Fully active, normal") do;
        LKPSN=100;
      end;
      when (LKPS="Minor restrictions in physically strenuous activity") do;
        LKPSN=90;
      end;
      when (LKPS="Active, but tires more quickly") do;
        LKPSN=80;
      end;
      when (LKPS="Both greater restriction of, and less time spent in, active play") do;
        LKPSN=70;
      end;
      when (LKPS="Up and around, but minimal active play; keeps busy with quieter activities") do;
        LKPSN=60;
      end;
      when (LKPS="Get dressed, but lies around much of the day; no active play;  able to participate in all quiet play and activities") do;
        LKPSN=50;
      end;
      when (LKPS="Mostly in bed; participates in quiet activities.") do;
        LKPSN=40;
      end;
      when (LKPS="In bed; needs assistance even for quiet play") do;
        LKPSN=30;
      end;
      when (LKPS="Often sleeping; play entirely limited to very passive activities") do;
        LKPSN=20;
      end;
      when (LKPS="No play; does not get out of bed") do;
        LKPSN=10;
      end;
      when (LKPS="Unresponsive") do;
        LKPSN=0;
      end;
      when (LKPS="Normal. No complaints. No evidence of disease.") do;
        LKPSN=100;
      end;
      when (LKPS="Able to carry on normal activity. Minor signs or symptoms of disease.") do;
        LKPSN=90;
      end;
      when (LKPS="Normal activity with effort. Some signs or symptoms of disease.") do;
        LKPSN=80;
      end;
      when (LKPS="Cares for self. Unable to carry on normal activity or do active work.") do;
        LKPSN=70;
      end;
      when (LKPS="Requires occasional assistance,but is able to care for most of his needs.") do;
        LKPSN=60;
      end;
      when (LKPS="Requires considerable assistance and frequent medical care") do;
        LKPSN=50;
      end;
      when (LKPS="Disabled. Requires special care and assistance.") do;
        LKPSN=40;
      end;
      when (LKPS="Severely disabled. Hospitalization is indicated although death not imminent.") do;
        LKPSN=30;
      end;
      when (LKPS="Hospitalization necessary, very sick active supportive treatment necessary.") do;
        LKPSN=20;
      end;
      when (LKPS="Moribund. Fatal processes progressing rapidly.") do;
        LKPSN=10;
      end;
      when (LKPS="Dead.") do;
        LKPSN=0;
      end;
      otherwise LKPSN=.;
    end;
    if LKPSN>=80 then do;
      LKPSGR1=">=80";
      LKPSGR1N=1;
    end;
    else if 50<=LKPSN and LKPSN<80 then do;
      LKPSGR1="70-50";
      LKPSGR1N=2;
    end;
    else if 0<LKPSN and LKPSN<50 then do;
      LKPSGR1="<=40";
      LKPSGR1N=3;
    end;
    else do;
      LKPSGR1="";
      LKPSGR1N=.;
    end;
run;
proc sql noprint;
    create table temp_adsl_15_1 as
    select a.*, b.LBORRES as CD22
    from temp_adsl_15 a left join (select * from lb where LBTESTCD = "CD22") b on a.USUBJID = b.USUBJID;
quit;
data temp_adsl_16;
    length CD22GR1 $200.;
    set temp_adsl_15_1(rename=(CD22=temp_CD22));
    CD22=input(temp_CD22, best12.);
    if CD22>=90 then do;
      CD22GR1=">=90%";
      CD22GR1N=1;
    end;
    else if 70<=CD22 and CD22<90 then do;
      CD22GR1=">=70%-<90%";
      CD22GR1N=2;
    end;
    else if 0<CD22 and CD22<70 then do;
      CD22GR1="<70%";
      CD22GR1N=3;
    end;
    else do;
      CD22GR1="";
      CD22GR1N=.;
    end;
run;
proc sql noprint;
    create table temp_adsl_17 as
    select a.*, input(b.PEORRES, best12.) as LVEF
    from temp_adsl_16 a left join (select * from pe where PETESTCD = "LVEF") b on a.USUBJID = b.USUBJID;
quit;
%GET_TEST_RESULT(lb, WBC, temp_adsl_17, temp_adsl_18, WBC);
%GET_TEST_RESULT(lb, BLASTLE, temp_adsl_18, temp_adsl_18_1, PBLST);
data temp_adsl_19;
    length PBLSGR1 $200.;
    set temp_adsl_18_1(rename=(WBC=temp_WBC PBLST=temp_PBLST));
    WBC=input(temp_WBC, best12.);
    PBLST=input(temp_PBLST, best12.);
    if PBLST=0 then do;
      PBLSGR1="0";
      PBLSGR1N=1;
    end; 
    else if 0<PBLST and PBLST<=1000 then do;
      PBLSGR1=">0- 1,000";
      PBLSGR1N=2;
    end;
    else if 1000<PBLST and PBLST<=5000 then do;
      PBLSGR1=">1,000- 5,000";
      PBLSGR1N=3;
    end;
    else if 5000<PBLST and PBLST<=10000 then do;
      PBLSGR1=">5,000- 10,000";
      PBLSGR1N=4;
    end;
    else if 10000<PBLST then do;
      PBLSGR1=">10,000";
      PBLSGR1N=5;
    end;
    else do;
      PBLSGR1="";
      PBLSGR1N=.;
    end;
run;
%GET_TEST_RESULT(lb, MYBLALE, temp_adsl_19, temp_adsl_20, BLAST);
data temp_adsl_21;
    length BLSGR1 $200.; 
    set temp_adsl_20(rename=(BLAST=temp_BLAST));
    BLAST=input(temp_BLAST, best12.);
    if 0<BLAST and BLAST<50 then do;
      BLSGR1="<50%";
      BLSGR1N=1;
    end;
    else if 50<=BLAST then do;
      BLSGR1=">=50%";
      BLSGR1N=2;
    end;
    else do;
      BLSGR1="";
      BLSGR1N=.;
    end;
run;
proc sql noprint;
    create table temp_adsl_22 as
    select a.*, b.SCDTC
    from temp_adsl_21 a left join (select * from sc where SCTESTCD = "FIRSTREL") b on a.USUBJID = b.USUBJID;
quit;
data temp_adsl_23;
    length FRDURGR1 $200.;
    set temp_adsl_22;
    if cmiss(SCDTC, MHENDTC) = 0 then do;
      FRDUR=int((SCDTC-MHENDTC)/30.4375);
    end;
    else do;
      FRDUR=.;
    end;
    if 0<FRDUR and FRDUR<12 then do;
      FRDURGR1="<12 months";
      FRDURGR1N=1;
    end;
    else if 12<=FRDUR then do;
      FRDURGR1=">=12 months";
      FRDURGR1N=2;
    end;
    else do;
      FRDURGR1="";
      FRDURGR1N=.;
    end;
run;
proc sql noprint;
    create table temp_adsl_24_1 as
    select a.*, b.VAR3 as SITENM
    from temp_adsl_23 a left join facilities b on a.SITEID = b.VAR1
    order by USUBJID;
quit;
data temp_adsl_24_2;
    set temp_adsl_24_1;
    if USUBJID='INO-Ped-ALL-1-0005' then do;
      FASFL='N';
      PPSFL='N';
      SAFFL='N';
      DLTFL='N';
    end;
    else do;
      FASFL='Y';
      PPSFL='Y';
      SAFFL='Y';
      DLTFL='Y';
    end;
run;
data &output_file_name.;
    length STUDYID $200. USUBJID $200. SUBJID $200. TRTSDT 8. TRTEDT 8. RFICDT 8. DTHDT 8. SITEID 8. 
           SITENM $200. AGE 8. AGEGR1 $200. AGEGR1N 8. AGEU $200. SEX $200. SEXN 8. RACE $200. ARM $200. 
           TRT01P $200. TRT01PN 8. COMPLFL $200. FASFL $200. PPSFL $200. SAFFL $200. DLTFL $200. 
           IETESTCD $200. IETEST $200. BSA 8. HEIGHT 8. WEIGHT 8. BMI 8. PRIMDIAG $200. DISDUR 8. 
           ALLER $200. INTP $200. RELREF $200. RELREFN 8. HSCT $200. RAD $200. LKPS $200. LKPSN 8. 
           LKPSGR1 $200. LKPSGR1N 8. CD22 8. CD22GR1 $200. CD22GR1N 8. LVEF 8. WBC 8. PBLST 8. 
           PBLSGR1 $200. PBLSGR1N 8. BLAST 8. BLSGR1 $200. BLSGR1N 8. FRDUR 8. FRDURGR1 $200. FRDURGR1N 8.;
    set temp_adsl_24_2;
    label STUDYID='Study Identifier' USUBJID='Unique Subject Identifier' 
          SUBJID='Subject Identifier for the Study' TRTSDT='Date of First Exposure to Treatment' 
          TRTEDT='Date of Last Exposure to Treatment' RFICDT='Date of Informed Consent' 
          DTHDT='Date of Death' SITEID='Study Site Identifier' SITENM='Study Site Name' 
          AGE='Age' AGEGR1='Pooled Age Group 1' AGEGR1N='Pooled Age Group 1 (N)' AGEU='Age Units' 
          SEX='Sex' SEXN='Sex (N)' RACE='Race' ARM='Description of Planned Arm' 
          TRT01P='Planned Treatment for Period 01' TRT01PN='Planned Treatment for Period 01 (N)' 
          COMPLFL='Completers Population Flag' FASFL='Full Analysis Set Population Flag' 
          PPSFL='Per Protocol Set Population Flag' SAFFL='Safety Population Flag' 
          DLTFL='DLT Population Flag' IETESTCD='Inclusion/Exclusion Criterion Short Name' 
          IETEST='Inclusion/Exclusion Criterion' BSA='BSA (m2)' HEIGHT='Height (cm)' 
          WEIGHT='Weigth (kg)' BMI='BMI (kg/m2)' PRIMDIAG='Primary Diagnosis' 
          DISDUR='Disease Duration (Months)' ALLER='Allergic disease' INTP='Cardiac Function Evaluation'
          RELREF='Type of Relapse / Refractory' RELREFN='Type of Relapse / Refractory (N)' 
          HSCT='Prior HSCT' RAD='Prior radiation for primary diagnosis' 
          LKPS='Lansky/Karnofsky performance status' LKPSN='Lansky/Karnofsky performance status (N)' 
          LKPSGR1='Lansky/Karnofsky performance status Group 1' 
          LKPSGR1N='Lansky/Karnofsky performance status Group 1 (N)' CD22='CD22' CD22GR1='CD22 Group 1' 
          CD22GR1N='CD22 Group 1 (N)' LVEF='LVEFÅi%Åj' WBC='WBC(/É L)' PBLST='Peripheral Blast Count (/É L)' 
          PBLSGR1='Peripheral Blast Count (/É L) Group 1' PBLSGR1N='Peripheral Blast Count (/É L) Group 1 (N)' 
          BLAST='Bone Marrow Blasts (%)' BLSGR1='Bone Marrow Blasts (%) Group 1' 
          BLSGR1N='Bone Marrow Blasts (%) Group 1 (N)' FRDUR='Duration of first remission (Months)'
          FRDURGR1='Duration of first remission (Months) Group 1' 
          FRDURGR1N='Duration of first remission (Months) Group 1 (N)';
    format _ALL_;
    informat _ALL_;
    format TRTSDT YYMMDD10. TRTEDT YYMMDD10. RFICDT YYMMDD10. DTHDT YYMMDD10.;
    keep STUDYID USUBJID SUBJID TRTSDT TRTEDT RFICDT DTHDT SITEID SITENM AGE
         AGEGR1 AGEGR1N AGEU SEX SEXN RACE ARM TRT01P TRT01PN COMPLFL 
         FASFL PPSFL SAFFL DLTFL IETESTCD IETEST BSA HEIGHT WEIGHT BMI
         PRIMDIAG DISDUR ALLER INTP RELREF RELREFN HSCT RAD LKPS LKPSN 
         LKPSGR1 LKPSGR1N CD22 CD22GR1 CD22GR1N LVEF WBC PBLST PBLSGR1 PBLSGR1N 
         BLAST BLSGR1 BLSGR1N FRDUR FRDURGR1 FRDURGR1N; 
run;
data libout.&output_file_name.;
    set &output_file_name.;
run;
%SDTM_FIN(&output_file_name.);
