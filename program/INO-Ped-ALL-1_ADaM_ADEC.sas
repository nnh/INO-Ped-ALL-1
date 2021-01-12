**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_ADaM_ADEC.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20201225
*
* Purpose           : Create ADEC DataSet
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
%LET FILE = ADEC;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_ADaM_LIBNAME.sas";

/*** Data Reading ***/
%macro read(filename);
  data  work.&filename.;
    set libraw.&filename.;
    informat _all_;
    format _all_;
  run ;
%mend;
%read(ec);
%read(ds);

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

/*** EC ***/
***Dose (mg/m2);
data  wk10;
  length USUBJID PARAM PARAMCD $200.;
  keep 
    USUBJID
    PARAM
    PARAMCD
    AVAL
    AVALC
    ASTDT
    AENDT
    ASTDTM
    AENDTM
    AVISITN
  ;
  set  ec;
  if ECMOOD="PERFORMED";
  PARAM="Dose (mg/m2)";
  PARAMCD="DOS";
  AVAL=input(ECDOSE,best32.);
  AVALC="";
  ASTDT=input(ECSTDTC,yymmdd10.);
  AENDT=input(ECENDTC,yymmdd10.);
  if  length(ECSTDTC)=16 then do;
    ASTDTM=input(ECSTDTC,E8601DT19.);
  end ;
  if  length(ECENDTC)=16 then do;
    AENDTM=input(ECENDTC,E8601DT19.);
  end ;
  AVISITN=input(VISITNUM,best32.);
  format ASTDT AENDT yymmdd10. ASTDTM AENDTM E8601DT19.;
run ;

***Duration of Treatment (Days);
data  wk20;
  length USUBJID PARAM PARAMCD $200.;
  keep 
    USUBJID
    PARAM
    PARAMCD
    AVAL
    AVALC
  ;
  set  adsl;
  if ARM="COHORT1";
  PARAM="Duration of Treatment (Days)";
  PARAMCD="DURTRT";
  AVAL=TRTEDT-TRTSDT+1;
  AVALC="";
run ;

***Duration of Follow-UP (Days);
proc sort data=ds out=wk31; by USUBJID decending DSDTC; run ;
proc sort data=wk31 nodupkey; by USUBJID; run ;

data  wk30;
  length USUBJID PARAM PARAMCD $200.;
  merge  adsl wk31;
  PARAM="Duration of Follow-UP (Days)";
  PARAMCD="DURFLU";
  if ^missing(DSDTC) and ^missing(TRTSDT) then AVAL=input(DSDTC,yymmdd10.)-TRTSDT+1;
  else delete;
  AVALC="";
  keep 
    USUBJID
    PARAM
    PARAMCD
    AVAL
    AVALC
  ;
run ;

***Number of Cycles;
proc sort data=ec out=wk41; by USUBJID decending ECSTDTC; run ;
proc sort data=wk41 nodupkey; by USUBJID; run ;

data  wk40;
  length USUBJID PARAM PARAMCD $200.;
  keep 
    USUBJID
    PARAM
    PARAMCD
    AVAL
    AVALC
  ;
  set  wk41;
  PARAM="Number of Cycles";
  PARAMCD="CYCN";
  AVAL=int(input(VISITNUM,best32.)/100);
  AVALC="";
run ;

***Total Dose (mg/m2);
data  wk51;
  retain AVAL;
  set  ec(where=(ECMOOD="PERFORMED")) ;
  by USUBJID;
  if  first.USUBJID=1 then AVAL=0;
  AVAL=AVAL+input(ECDOSE,best32.);
  if  last.USUBJID=1 then output;
run ;

data  wk50;
  length USUBJID PARAM PARAMCD $200.;
  keep 
    USUBJID
    PARAM
    PARAMCD
    AVAL
    AVALC
  ;
  set  wk51;
  PARAM="Total Dose (mg/m2)";
  PARAMCD="TOTDOS";
  AVALC="";
run ;

***Total Dose (mg/m2);
data  wk61;
  set  ec;
  AVISITN=(int(input(VISITNUM,best32.)/100)+1)*100;
run ;

proc sort data=wk61; by USUBJID AVISITN; run ;

data  wk61;
  retain AVAL;
  set  wk61(where=(ECMOOD="PERFORMED")) ;
  by USUBJID AVISITN;
  if  first.AVISITN=1 then AVAL=0;
  AVAL=AVAL+input(ECDOSE,best32.);
  if  last.AVISITN=1 then output;
run ;

data  wk60;
  length USUBJID PARAM PARAMCD $200.;
  keep 
    USUBJID
    PARAM
    PARAMCD
    AVAL
    AVALC
    AVISITN
  ;
  set  wk61;
  PARAM="Total Dose during Cycle x (mg/m2)";
  PARAMCD="CYCDOS";
  AVALC="";
run ;

***RDI;
data  wk71;
  retain AVAL1;
  set  ec(where=(ECMOOD="PERFORMED")) ;
  by USUBJID;
  if  first.USUBJID=1 then AVAL1=0;
  AVAL1=AVAL1+input(ECDOSE,best32.);
  if  last.USUBJID=1 then output;
run ;

data  wk72;
  retain AVAL2;
  set  ec(where=(ECMOOD="SCHEDULED")) ;
  by USUBJID;
  if  first.USUBJID=1 then AVAL2=0;
  AVAL2=AVAL2+input(ECDOSE,best32.);
  if  last.USUBJID=1 then output;
run ;

data  wk70;
  length USUBJID PARAM PARAMCD $200.;
  keep 
    USUBJID
    PARAM
    PARAMCD
    AVAL
    AVALC
  ;
  merge  wk71 wk72;
  by USUBJID;
  PARAM="RDI";
  PARAMCD="RDI";
  AVAL=round(AVAL1/AVAL2*100,0.01);
  AVALC="";
run ;

***RDI Cycle x;
data  wk81;
  set  ec;
  AVISITN=(int(input(VISITNUM,best32.)/100)+1)*100;
run ;

proc sort data=wk81; by USUBJID AVISITN; run ;

data  wk82;
  retain AVAL1;
  set  wk81(where=(ECMOOD="PERFORMED")) ;
  by USUBJID AVISITN;
  if  first.AVISITN=1 then AVAL1=0;
  AVAL1=AVAL1+input(ECDOSE,best32.);
  if  last.AVISITN=1 then output;
run ;

data  wk83;
  retain AVAL2;
  set  wk81(where=(ECMOOD="SCHEDULED")) ;
  by USUBJID AVISITN;
  if  first.AVISITN=1 then AVAL2=0;
  AVAL2=AVAL2+input(ECDOSE,best32.);
  if  last.AVISITN=1 then output;
run ;

data  wk80;
  length USUBJID PARAM PARAMCD $200.;
  keep 
    USUBJID
    PARAM
    PARAMCD
    AVAL
    AVALC
    AVISITN
  ;
  merge  wk82 wk83;
  by USUBJID AVISITN;
  PARAM="RDI Cycle x";
  PARAMCD="CYCRDI";
  AVAL=round(AVAL1/AVAL2*100,0.01);
  AVALC="";
run ;

***Interruption;
data  wk90;
  length USUBJID PARAM PARAMCD $200.;
  set  wk80;
  PARAM="Interruption";
  PARAMCD="INT";
  if  AVAL^=100 then AVALC="Y";
  else AVALC="N";
  AVAL=.;
run ;

***Restart;
data  wk101;
  set  wk90;
  keep USUBJID SEQ AVALC1 AVISITN;
  AVALC1=AVALC;
  SEQ=_N_;
run ;

data  wk102;
  set  wk90;
  keep SEQ AVALC2;
  AVALC2=AVALC;
  SEQ=_N_+1;
run ;

data  wk100;
  length USUBJID PARAM PARAMCD $200.;
  merge  wk101(in=a) wk102;
  by SEQ;
  if a;
  if  AVALC1="N" and AVALC2="Y" then AVALC="Y";
  else AVALC="N";
  PARAM="Restart";
  PARAMCD="RES";
  drop SEQ AVALC1 AVALC2;
run ;

/* set */
data  wk110;
  length AVISIT $200.;
  set  wk10 wk20 wk30 wk40 wk50 wk60 wk70 wk80 wk90 wk100;
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
run ;

/* adsl */
proc sort data=wk110; by USUBJID; run ;

data  wk00;
  merge  wk110(in=a) adsl;
  by  USUBJID;
  if a;
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
    AVAL  LENGTH=8    LABEL="Analysis Value",
    AVALC  LENGTH=200    LABEL="Analysis Value (C)",
    ASTDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Analysis Start Date",
    AENDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Analysis End Date",
    ASTDTM  LENGTH=8  FORMAT=E8601DT19.  LABEL="Analysis Start Datetime",
    AENDTM  LENGTH=8  FORMAT=E8601DT19.  LABEL="Analysis End Datetime",
    AVISIT  LENGTH=200    LABEL="Analysis Visit",
    AVISITN  LENGTH=8    LABEL="Analysis Visit (N)"
   from wk00;
quit ;

proc sort data = &file out =libout.&file. nodupkey dupout=aaa;
  by USUBJID PARAMCD AVISITN ;
run;

%ADS_FIN;

/*** END ***/

            
                       
       
                    
                
                
                 
                     
