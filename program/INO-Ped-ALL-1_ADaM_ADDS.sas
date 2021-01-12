**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_ADaM_ADDS.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20201225
*
* Purpose           : Create ADDS DataSet
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
%LET FILE = ADDS;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_ADaM_LIBNAME.sas";

/*** Data Reading ***/
%macro read(filename);
  data  work.&filename.;
    set libraw.&filename.;
    informat _all_;
    format _all_;
  run ;
%mend;
%read(ds);
%read(dd);

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

/*** DS ***/
data  wk10;
  length USUBJID PARAM PARAMCD $200.;
  keep 
    USUBJID
    PARAM
    PARAMCD
    AVAL
    ADT
    ASTDT
    DSDECOD
  ;
  set  DS;
  if  EPOCH="TREATMENT" then do;
    PARAMCD="DISCON";
    PARAM="Discontinuation";
    ADT=input(DSDTC,yymmdd10.);
    ASTDT=input(DSSTDTC,yymmdd10.);
    AVAL=.;
  end ;
  if  EPOCH^="TREATMENT" then do;
    PARAMCD="WITHDRAW";
    PARAM="Withdrawal";
    ADT=input(DSDTC,yymmdd10.);
    ASTDT=input(DSSTDTC,yymmdd10.);
    AVAL=.;
  end ;
  format ADT ASTDT yymmdd10.;
run ;

data  wk21;
  keep USUBJID ADT DDORRES;
  set  dd;
  ADT=input(DDDTC,yymmdd10.);
run ;

proc sort data=wk10; by USUBJID ADT; run ;
proc sort data=wk21; by USUBJID ADT; run ;

data  wk20;
  length AVALC $200.;
  merge  wk10 wk21(in=a);
  by  USUBJID ADT;
  if a=1 then AVALC=strip(DSDECOD)||" ("||strip(DDORRES)||")";
  else AVALC=DSDECOD;
run ;

/* adsl */
proc sort data=wk20; by USUBJID; run ;

data  wk00;
  merge  wk20(in=a) adsl;
  by  USUBJID;
  if a;
  if ASTDT>=TRTSDT then ASTDY=ASTDT-TRTSDT+1;
  if ASTDT < TRTSDT then ASTDY=ASTDT-TRTSDT;
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
      ASTDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Analysis Start Date",
      ASTDY  LENGTH=8    LABEL="Analysis Relative Start Day"
   from wk00;
quit ;

proc sort data = &file out =libout.&file. nodupkey dupout=aaa;
  by USUBJID PARAMCD ADT;
run;

%ADS_FIN;

/*** END ***/

            
                       
       
                    
                
                
                 
                     
