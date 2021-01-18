**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_SDTM_DATA.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20201201
*
* Purpose           : Create SDTM DataSet
*
* Revision History  : 
*
* Date        Author           Ref    Revision (Date in YYYYMMDD format)
* 
*
**********************************************************************;

/*** Initial setting ***/
%MACRO CURRENT_DIR;

    %local _fullpath _path;
    %let   _fullpath = ;
    %let   _path     = ;

    %if %length(%sysfunc(getoption(sysin))) = 0 %then
        %let _fullpath = %sysget(sas_execfilepath);
    %else
        %let _fullpath = %sysfunc(getoption(sysin));

    %let _path = %substr(   &_fullpath., 1, %length(&_fullpath.)
                          - %length(%scan(&_fullpath.,-1,'\')) -1 );

    &_path.

%MEND CURRENT_DIR;

%LET _PATH2 = %CURRENT_DIR;
%LET FILE = ADSL;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_ADaM_LIBNAME.sas";

/*** Data Reading ***/
%macro read(filename);
  data  work.&filename.;
    set libraw.&filename.;
    informat _all_;
    format _all_;
  run ;
%mend;
%read(dm);
%read(ds);
%read(ie);
%read(vs);
%read(mh);
%read(eg);
%read(sc);
%read(pr);
%read(qs);
%read(lb);
%read(pe);

%macro csv(filename);
  proc import out= work.&filename.
    datafile="&ext.\&filename..csv"
    dbms=csv replace;
    getnames=yes;
    datarow=2;
    guessingrows=max;  
  run; 

  data  work.&filename.;
    set work.&filename.;
    informat _all_;
    format _all_;
  run ;
%mend ;
%csv(facilities)

/*** 顔データ ***/
data  wk11;
  keep 
    STUDYID
    USUBJID
    SUBJID
    TRTSDT
    TRTEDT
    RFICDT
    DTHDT
    SITEID
    AGE
    AGEGR1
    AGEGR1N
    AGEU
    SEX
    SEXN
    RACE
    ARM
    TRT01P
    TRT01PN
  ;
  length AGEGR1 TRT01P $200.;
  set  dm(rename=(SITEID=_SITEID));
  TRTSDT=input(RFXSTDTC,yymmdd10.);
  TRTEDT=input(RFXENDTC,yymmdd10.);
  RFICDT=input(RFICDTC,yymmdd10.);
  DTHDT=input(DTHDTC,yymmdd10.);
  SITEID=input(_SITEID,best32.);
  if AGE < 2 then AGEGR1 = "<2";
  else if 2<= AGE <12 then AGEGR1 = ">=2-<12";
  else if 12<= AGE  then AGEGR1 = ">=12";
  if AGE < 2 then AGEGR1N = 1;
  else if 2<= AGE <12 then AGEGR1N = 2;
  else if 12<= AGE  then AGEGR1N = 3;
  if SEX = "M" then SEXN = 1;
  else if SEX = "F" then SEXN = 2;
  TRT01P=strip(ARM);
  if  TRT01P="COHORT1" then TRT01PN=1;
  else if  TRT01P="Screen Failure" then TRT01PN=2;
  format TRTSDT TRTEDT RFICDT DTHDT yymmdd10.;
run ;

/* 施設名 */
data  wk12;
  length SITENM $200.;
  set  facilities;
  SITEID=input(VAR1,best32.);
  SITENM=strip(VAR3);
  keep SITEID SITENM;
run ;

proc sort data=wk11; by SITEID; run ;
proc sort data=wk12; by SITEID; run ;

data  wk10;
  merge  wk11 wk12;
  by  SITEID;
run ;

/* COMPLFL */
data wk21;
  set  ds;
  if  DSTERM="COMPLETED" and EPOCH="FOLLOW-UP" ;
  COMPLFL="Y";
  keep USUBJID COMPLFL;
run ;

proc sort data=wk10; by USUBJID; run ;
proc sort data=wk21; by USUBJID; run ;

data  wk20;
  merge  wk10 wk21(in=a);
  by  USUBJID;
  if a=0 then COMPLFL="N";
run ;

/* IETESTCD IETEST */
data  wk31;
  set  ie;
  keep USUBJID IETESTCD IETEST;
run ;

data  wk30;
  merge  wk20 wk31;
  by  USUBJID ;
run ;

/* BSA HEIGHT WEIGHT BMI */
data  wk41;
  set vs;
  if  VSTESTCD="HEIGHT" and VSORRES^="" and VISITNUM in(100,101);
  HEIGHT=input(VSORRES,best32.);
  keep USUBJID HEIGHT VISITNUM;
run ;

proc sort data=wk41; by USUBJID decending VISITNUM; run ;
proc sort data=wk41(drop=VISITNUM) nodupkey ; by USUBJID ; run ;

data  wk42;
  set vs;
  if  VSTESTCD="WEIGHT" and VSORRES^="" and VISITNUM in(100,101);
  WEIGHT=input(VSORRES,best32.);
  keep USUBJID WEIGHT VISITNUM;
run ;

proc sort data=wk42; by USUBJID decending VISITNUM; run ;
proc sort data=wk42(drop=VISITNUM) nodupkey ; by USUBJID ; run ;

data  wk40;
  merge  wk30 wk41 wk42;
  by  USUBJID;
  if  ^missing(HEIGHT) and  ^missing(WEIGHT) then BSA=round((HEIGHT*WEIGHT/3600)**(1/2),0.01);
  if  ^missing(HEIGHT) and  ^missing(WEIGHT) then BMI=round(WEIGHT/((HEIGHT/100)**2),0.01);
run ;

/* PRIMDIAG DISDUR */
data  wk51;
  set  mh;
  if MHCAT="PRIMARY DIAGNOSIS" ;
  PRIMDIAG=strip(MHTERM);
  DISDUR=int((input(MHENDTC,yymmdd10.)-input(MHSTDTC,yymmdd10.))/365.25);
  keep USUBJID PRIMDIAG DISDUR;
run ;

/* ALLER */
data  wk52;
  set  mh;
  if  MHCAT="ALLERGIC";
  ALLER=MHOCCUR;
  keep USUBJID ALLER;
run ;

data  wk50;
  merge  wk40 wk51 wk52;
  by  USUBJID;
run ;

/* INTP */
data  wk61;
  length INTP $200.;
  set eg;
  if  EGTESTCD="INTP" and EGORRES^="" and VISITNUM in(100,101);
  INTP=strip(EGORRES);
  keep USUBJID INTP VISITNUM;
run ;

proc sort data=wk61; by USUBJID decending VISITNUM; run ;
proc sort data=wk61(drop=VISITNUM) nodupkey ; by USUBJID ; run ;

/* RELREF */
data  wk62;
  set  sc;
  if  SCTESTCD="SALVSTAT";
  RELREF=SCORRES;
  select(RELREF);
    when("INDUCTION FAILURE")  RELREFN=1;
    when("FIRST RELAPSE")  RELREFN=2;
    when("SECOND RELAPSE")  RELREFN=3;
    when("OTHER")  RELREFN=4;
    otherwise ;
  end ;
  keep USUBJID RELREF RELREFN;
run ;

/* HSCT */
data  wk63;
  set  pr;
  if  PRTRT="SCT(BMT,CBT,PBSCT)";
  HSCT=PROCCUR;
  keep USUBJID HSCT;
run ;

/* RAD */
data  wk64;
  set  pr;
  if  PRTRT="RADIATION";
  RAD=PROCCUR;
  keep USUBJID RAD;
run ;

data  wk60;
  merge  wk50 wk61 wk62 wk63 wk64;
  by  USUBJID;
run ;

/* LKPS LKPSN LKPSGR1 LKPSGR1N */
data  wk71;
  length LKPS LKPSGR1 $200.;
  set  qs;
  if  QSCAT="LANSKY";
  LKPS=QSORRES;
  select(LKPS);
    when("Fully active, normal")  LKPSN=100;
    when("Minor restrictions in physically strenuous activity")  LKPSN=90 ;
    when("Active, but tires more quickly")  LKPSN=80 ;
    when("Both greater restriction of, and less time spent in, active play")  LKPSN=70 ;
    when("Up and around, but minimal active play; keeps busy with quieter activities")  LKPSN=60 ;
    when("Get dressed, but lies around much of the day; no active play;  able to participate in all quiet play and activities")  LKPSN=50 ;
    when("Mostly in bed; participates in quiet activities.")  LKPSN=40 ;
    when("In bed; needs assistance even for quiet play")  LKPSN=30 ;
    when("Often sleeping; play entirely limited to very passive activities")  LKPSN=20 ;
    when("No play; does not get out of bed")  LKPSN=10 ;
    when("Unresponsive")  LKPSN=0  ;
    otherwise ;
  end ;
  select;
    when (LKPSN>=80) LKPSGR1=">=80";
    when (LKPSN>=50) LKPSGR1="70-50";
    when (LKPSN>=0) LKPSGR1="<=40";
    otherwise ;
  end ;
  select(LKPSGR1);
    when(">=80") LKPSGR1N=1;
    when("70-50") LKPSGR1N=2;
    when("<=40") LKPSGR1N=3;
    otherwise ;
  end;
  keep USUBJID LKPS LKPSN LKPSGR1 LKPSGR1N ;
run ;

data  wk70;
  merge  wk60 wk71 ;
  by  USUBJID;
run ;

/* CD22 CD22GR1 CD22GR1N WBC PBLST PBLSGR1 PBLSGR1N BLAST BLSGR1 BLSGR1N */
data  wk81;
  length CD22GR1 $200.;
  set  lb;
  if  LBTESTCD="CD22";
  CD22=input(LBORRES,best32.);
  select;
    when (CD22>=90) CD22GR1=">=90%";
    when (CD22>=70) CD22GR1=">=70%-<90%";
    when (CD22>=0) CD22GR1="<70%";
    otherwise ;
  end ;
  select(CD22GR1);
    when(">=90%") CD22GR1N=1;
    when(">=70%-<90%") CD22GR1N=2;
    when("<70%") CD22GR1N=3;
    otherwise ;
  end;
  keep USUBJID CD22  CD22GR1 CD22GR1N ;
run ;

data  wk82;
  set LB;
  if  LBTESTCD="WBC" and LBORRES^="" and VISITNUM in(100,101);
  WBC=input(LBORRES,best32.);
  keep USUBJID WBC VISITNUM;
run ;

proc sort data=wk82; by USUBJID decending VISITNUM; run ;
proc sort data=wk82(drop=VISITNUM) nodupkey ; by USUBJID ; run ;

data  wk83;
  length PBLSGR1 $200.;
  set LB;
  if  LBTESTCD="BLASTLE" and LBORRES^="" and VISITNUM in(100,101);
  PBLST=input(LBORRES,best32.);
  select;
    when (PBLST>10000) PBLSGR1=">10,000";
    when (PBLST>5000) PBLSGR1=">5,000- 10,000";
    when (PBLST>1000) PBLSGR1=">1,000- 5,000";
    when (PBLST>0) PBLSGR1=">0- 1,000";
    when (PBLST=0) PBLSGR1="0";
    otherwise ;
  end ;
  select(PBLSGR1);
    when("0") PBLSGR1N=1;
    when(">0- 1,000") PBLSGR1N=2;
    when(">1,000- 5,000") PBLSGR1N=3;
    when(">5,000- 10,000") PBLSGR1N=4;
    when(">10,000") PBLSGR1N=5;
    otherwise ;
  end;
  keep USUBJID PBLST VISITNUM PBLSGR1 PBLSGR1N;
run ;

proc sort data=wk83; by USUBJID decending VISITNUM; run ;
proc sort data=wk83(drop=VISITNUM) nodupkey ; by USUBJID ; run ;

data  wk84;
  set LB;
  if  LBTESTCD="MYBLALE" and LBORRES^="" and VISITNUM in(100,101);
  BLAST=input(LBORRES,best32.);
  select;
    when (BLAST>=50) BLSGR1=">=50%";
    when (BLAST>=0) BLSGR1="<50%";
    otherwise ;
  end ;
  select(BLSGR1);
    when("<50%") BLSGR1N=1;
    when(">=50%") BLSGR1N=2;
    otherwise ;
  end;
  keep USUBJID BLAST VISITNUM BLAST BLSGR1 BLSGR1N;
run ;

proc sort data=wk84; by USUBJID decending VISITNUM; run ;
proc sort data=wk84(drop=VISITNUM) nodupkey ; by USUBJID ; run ;

data  wk80;
  merge  wk70 wk81 wk82 wk83 wk84;
  by  USUBJID;
run ;

/* LVEF */
data  wk91;
  set  pe;
  if  PETESTCD="LVEF";
  LVEF=input(PEORRES,best32.);
  keep USUBJID LVEF;
run ;

data  wk90;
  merge  wk80 wk91;
  by  USUBJID;
run ;

/* FRDUR FRDURGR1 FRDURGR1N */
data  wk101;
  set  sc;
  if SCTESTCD="FIRSTREL";
  keep USUBJID SCDTC;
run ;

data  wk102;
  set  mh;
  if MHCAT="PRIMARY DIAGNOSIS";
  keep USUBJID MHENDTC;
run ;

data  wk103;
  merge  wk101 wk102;
  by  USUBJID;
  FRDUR=int((input(SCDTC,yymmdd10.)-input(MHENDTC,yymmdd10.))/30.4375);
  select;
    when (FRDUR>=12) FRDURGR1=">=12 months";
    when (FRDUR>=0) FRDURGR1="<12 months";
    otherwise ;
  end ;
  select(FRDURGR1);
    when("<12 months") FRDURGR1N=1;
    when(">=12 months") FRDURGR1N=2;
    otherwise ;
  end;
  keep USUBJID FRDUR FRDURGR1 FRDURGR1N;
run ;

data  wk00;
  merge  wk90 wk103;
  by USUBJID;
  FASFL="";
  PPSFL="";
  SAFFL="";
  DLTFL="";
run ;

/* output */
proc sql ;
   create table &file as
   select
      STUDYID  LENGTH=200    LABEL='Study Identifier',
      USUBJID  LENGTH=200    LABEL='Unique Subject Identifier',
      SUBJID  LENGTH=200    LABEL='Subject Identifier for the Study',
      TRTSDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL='Date of First Exposure to Treatment',
      TRTEDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL='Date of Last Exposure to Treatment',
      RFICDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL='Date of Informed Consent',
      DTHDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL='Date of Death',
      SITEID  LENGTH=8    LABEL='Study Site Identifier',
      SITENM  LENGTH=200    LABEL='Study Site Name',
      AGE  LENGTH=8    LABEL='Age',
      AGEGR1  LENGTH=200    LABEL='Pooled Age Group 1',
      AGEGR1N  LENGTH=8    LABEL='Pooled Age Group 1 (N)',
      AGEU  LENGTH=200    LABEL='Age Units',
      SEX  LENGTH=200    LABEL='Sex',
      SEXN  LENGTH=8    LABEL='Sex (N)',
      RACE  LENGTH=200    LABEL='Race',
      ARM  LENGTH=200    LABEL='Description of Planned Arm',
      TRT01P  LENGTH=200    LABEL='Planned Treatment for Period 01',
      TRT01PN  LENGTH=8    LABEL='Planned Treatment for Period 01 (N)',
      COMPLFL  LENGTH=200    LABEL='Completers Population Flag',
      FASFL  LENGTH=200    LABEL='Full Analysis Set Population Flag',
      PPSFL  LENGTH=200    LABEL='Per Protocol Set Population Flag',
      SAFFL  LENGTH=200    LABEL='Safety Population Flag',
      DLTFL  LENGTH=200    LABEL='DLT Population Flag',
      IETESTCD  LENGTH=200    LABEL='Inclusion/Exclusion Criterion Short Name',
      IETEST  LENGTH=200    LABEL='Inclusion/Exclusion Criterion',
      BSA  LENGTH=8    LABEL='BSA (m2)',
      HEIGHT  LENGTH=8    LABEL='Height (cm)',
      WEIGHT  LENGTH=8    LABEL='Weigth (kg)',
      BMI  LENGTH=8    LABEL='BMI (kg/m2)',
      PRIMDIAG  LENGTH=200    LABEL='Primary Diagnosis',
      DISDUR  LENGTH=8    LABEL='Disease Duration (Years)',
      ALLER  LENGTH=200    LABEL='Allergic disease',
      INTP  LENGTH=200    LABEL='Cardiac Function Evaluation',
      RELREF  LENGTH=200    LABEL='Type of Relapse / Refractory',
      RELREFN  LENGTH=8    LABEL='Type of Relapse / Refractory (N)',
      HSCT  LENGTH=200    LABEL='Prior HSCT',
      RAD  LENGTH=200    LABEL='Prior radiation for primary diagnosis',
      LKPS  LENGTH=200    LABEL='Lansky/Karnofsky performance status',
      LKPSN  LENGTH=8    LABEL='Lansky/Karnofsky performance status (N)',
      LKPSGR1  LENGTH=200    LABEL='Lansky/Karnofsky performance status Group 1',
      LKPSGR1N  LENGTH=8    LABEL='Lansky/Karnofsky performance status Group 1 (N)',
      CD22  LENGTH=8    LABEL='CD22',
      CD22GR1  LENGTH=200    LABEL='CD22 Group 1',
      CD22GR1N  LENGTH=8    LABEL='CD22 Group 1 (N)',
      LVEF  LENGTH=8    LABEL='LVEF（%）',
      WBC  LENGTH=8    LABEL='WBC(/μL)',
      PBLST  LENGTH=8    LABEL='Peripheral Blast Count (/μL)',
      PBLSGR1  LENGTH=200    LABEL='Peripheral Blast Count (/μL) Group 1',
      PBLSGR1N  LENGTH=8    LABEL='Peripheral Blast Count (/μL) Group 1 (N)',
      BLAST  LENGTH=8    LABEL='Bone Marrow Blasts (%)',
      BLSGR1  LENGTH=200    LABEL='Bone Marrow Blasts (%) Group 1',
      BLSGR1N  LENGTH=8    LABEL='Bone Marrow Blasts (%) Group 1 (N)',
      FRDUR  LENGTH=8    LABEL='Duration of first remission (Months)',
      FRDURGR1  LENGTH=200    LABEL='Duration of first remission (Months) Group 1',
      FRDURGR1N  LENGTH=8    LABEL='Duration of first remission (Months) Group 1 (N)'
   from wk00;
quit ;

proc sort data = &file out =libout.&file. nodupkey;
  by USUBJID ;
run;


%ADS_FIN;

/*** END ***/

            
                       
       
                    
                
                
                 
                     
