**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_ADaM_ADEG.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20201225
*
* Purpose           : Create ADEG DataSet
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
%LET FILE = ADEG;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_ADaM_LIBNAME.sas";

/*** Data Reading ***/
%macro read(filename);
  data  work.&filename.;
    set libraw.&filename.;
    informat _all_;
    format _all_;
  run ;
%mend;
%read(eg);

data  adsl;
  set libout.adsl ;
  keep 
    STUDYID
    USUBJID
    SUBJID
    TRTSDT
    TRTEDT
    RFICDT
    DTHDT
    SITEID
    SITENM
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
    COMPLFL
    FASFL
    PPSFL
    SAFFL
    DLTFL
 ;
 run ;

/*** EG ***/
data  wk10;
  length USUBJID PARAM PARAMCD AVALC $200.;
  keep 
    USUBJID
    PARAM
    PARAMCD
    AVAL
    AVALC
    ADT
    AVISITN
    EGTPTNUM
  ;
  set  eg;
  if  EGTESTCD^="INTP" and ^missing(EGORRES);
  PARAMCD=strip(EGTESTCD);
  if  missing(EGORRESU) then do;
    PARAM=strip(EGTEST);
    AVALC=strip(EGORRES);
  end ;
  else if  ^missing(EGORRESU) then do;
    PARAM=strip(EGTEST)||" ("||strip(EGORRESU)||")";
    AVAL=input(EGORRES,best32.);
  end ;
  ADT=input(EGDTC,yymmdd10.);
  AVISITN=input(VISITNUM,best32.);
  format ADT yymmdd10.;
run ;

***QTcB QTcF;
data  wk21;
  set  wk10;
  if  PARAMCD="QTINTNOS";
run;

data  wk22;
  set  wk10;
  keep USUBJID AVAL AVISITN EGTPTNUM;
  if  PARAMCD="RRINTNOS";
  rename AVAL = RR;
run;

data  wk20;
  merge  wk21 wk22;
  by USUBJID AVISITN EGTPTNUM;
  PARAM="QTcB (sec)";
  PARAMCD="QTCB";
  AVAL=AVAL/((RR)**(1/2));
run ;

data  wk30;
  merge  wk21 wk22;
  by USUBJID AVISITN EGTPTNUM;
  PARAM="QTcF (sec)";
  PARAMCD="QTCF";
  AVAL=AVAL/((RR)**(1/3));
run ;

data  wk40;
  set  wk10 wk20 wk30;
  drop RR;
  if EGTPTNUM in("10","20","30") then ATPTN=1;
  if EGTPTNUM in("40","50","60") then ATPTN=2;
  if ATPTN=1 then ATPT="PRIOR";
  if ATPTN=2 then ATPT="AFTER";
run ;

proc sort data=wk40; by USUBJID PARAM PARAMCD ADT AVISITN ATPTN ATPT; run ;

proc means data=wk40 MEAN;
    var AVAL;
    by USUBJID PARAM PARAMCD ADT AVISITN ATPTN ATPT;
    output out=wk50 mean=MEAN;
run;

data  wk60;
  length AVISIT $200.;
  set  wk50;
  select (AVISITN);
    when(100) AVISIT="SCREEN";
    when(101) AVISIT="CYCLE1 DAY1";
    when(104) AVISIT="CYCLE1 DAY4";
    when(108) AVISIT="CYCLE1 DAY8";
    when(115) AVISIT="CYCLE1 DAY15";
    when(200) AVISIT="END OF CYCLE1";
    when(201) AVISIT="CYCLE2 DAY1";
    when(208) AVISIT="CYCLE2 DAY8";
    when(215) AVISIT="CYCLE2 DAY15";
    when(300) AVISIT="END OF CYCLE2";
    when(301) AVISIT="CYCLE3 DAY1";
    when(308) AVISIT="CYCLE3 DAY8";
    when(315) AVISIT="CYCLE3 DAY15";
    when(400) AVISIT="END OF CYCLE3";
    when(401) AVISIT="CYCLE4 DAY1";
    when(408) AVISIT="CYCLE4 DAY8";
    when(415) AVISIT="CYCLE4 DAY15";
    when(500) AVISIT="END OF CYCLE4";
    when(501) AVISIT="CYCLE5 DAY1";
    when(508) AVISIT="CYCLE5 DAY8";
    when(515) AVISIT="CYCLE5 DAY15";
    when(600) AVISIT="END OF CYCLE5";
    when(601) AVISIT="CYCLE6 DAY1";
    when(608) AVISIT="CYCLE6 DAY8";
    when(615) AVISIT="CYCLE6 DAY15";
    when(700) AVISIT="END OF CYCLE6";
    when(800) AVISIT="FOLLOW-UP";
    when(900) AVISIT="HSCT";
    when(904) AVISIT="HSCT 4WKS";
    when(908) AVISIT="HSCT 8WKS";
    when(912) AVISIT="HSCT 12WKS";
    when(916) AVISIT="HSCT 16WKS";
    otherwise;
  end;
  rename MEAN=AVAL;
  AVALC="";
run ;

/* adsl */
proc sort data=wk60; by USUBJID; run ;

data  wk70;
  merge  wk60(in=a) adsl;
  by  USUBJID;
  if a;
  if ADT>=TRTSDT then ADY=ADT-TRTSDT+1;
  if ADT < TRTSDT then ADY=ADT-TRTSDT;
run ;

***Base;
data  wk81;
  set  wk70;
  RENAME AVAL=BASE;
  keep USUBJID PARAMCD AVAL ADY ATPTN;
  if ADY<=1;
run ;

proc sort data=wk81; by USUBJID PARAMCD decending ADY ATPTN; run ;
proc sort data=wk81 out=wk80(drop=ADY ATPTN) nodupkey; by USUBJID PARAMCD; run ;

proc sort data=wk70; by USUBJID PARAMCD; run ;

data  wk00;
  merge  wk70 wk80;
  by  USUBJID PARAMCD;
  if ^missing(BASE) then CHG=AVAL-BASE;
run ;

data  wk00;
  set  wk00(rename=(AVAL=_AVAL BASE=_BASE CHG=_CHG));
  AVAL=round(_AVAL,0.001);
  BASE=round(_BASE,0.001);
  CHG=round(_CHG,0.001);
run ;

/* output */
proc sql ;
   create table &file as
   select
    STUDYID  LENGTH=200    LABEL="Study Identifier",
    USUBJID  LENGTH=200    LABEL="Unique Subject Identifier",
    SUBJID  LENGTH=200    LABEL="Subject Identifier for the Study",
    TRTSDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Date of First Exposure to Treatment",
    TRTEDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Date of Last Exposure to Treatment",
    RFICDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Date of Informed Consent",
    DTHDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Date of Death",
    SITEID  LENGTH=8    LABEL="Study Site Identifier",
    SITENM  LENGTH=200    LABEL="Study Site Name",
    AGE  LENGTH=8    LABEL="Age",
    AGEGR1  LENGTH=200    LABEL="Pooled Age Group 1",
    AGEGR1N  LENGTH=8    LABEL="Pooled Age Group 1 (N)",
    AGEU  LENGTH=200    LABEL="Age Units",
    SEX  LENGTH=200    LABEL="Sex",
    SEXN  LENGTH=8    LABEL="Sex (N)",
    RACE  LENGTH=200    LABEL="Race",
    ARM  LENGTH=200    LABEL="Description of Planned Arm",
    TRT01P  LENGTH=200    LABEL="Planned Treatment for Period 01",
    TRT01PN  LENGTH=8    LABEL="Planned Treatment for Period 01 (N)",
    COMPLFL  LENGTH=200    LABEL="Completers Population Flag",
    FASFL  LENGTH=200    LABEL="Full Analysis Set Population Flag",
    PPSFL  LENGTH=200    LABEL="Per Protocol Set Population Flag",
    SAFFL  LENGTH=200    LABEL="Safety Population Flag",
    DLTFL  LENGTH=200    LABEL="DLT Population Flag",
    PARAM  LENGTH=200    LABEL="Parameter",
    PARAMCD  LENGTH=200    LABEL="Parameter Code",
    AVALC  LENGTH=200    LABEL="Analysis Value (C)",
    AVAL  LENGTH=8    LABEL="Analysis Value",
    ADT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Analysis Date",
    ADY  LENGTH=8    LABEL="Analysis Relative Day",
    AVISIT  LENGTH=200    LABEL="Analysis Visit",
    AVISITN  LENGTH=8    LABEL="Analysis Visit (N)",
    ATPT  LENGTH=200    LABEL="Analysis Timepoint ",
    ATPTN  LENGTH=8    LABEL="Analysis Timepoint (N)",
    BASE  LENGTH=8    LABEL="Baseline Value",
    CHG  LENGTH=8    LABEL="Change from Baseline"
   from wk00;
quit ;

proc sort data = &file out =libout.&file. nodupkey dupout=aaa;
  by USUBJID PARAMCD AVISITN ATPTN;
run;

%ADS_FIN;

/*** END ***/

            
                       
       
                    
                
                
                 
                     
