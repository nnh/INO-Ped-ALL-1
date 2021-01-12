**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_ADaM_ADTTE.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20201225
*
* Purpose           : Create ADTTE DataSet
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
%LET FILE = ADTTE;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_ADaM_LIBNAME.sas";

/*** Data Reading ***/
%macro read(filename);
  data  work.&filename.;
    set libraw.&filename.;
    informat _all_;
    format _all_;
  run ;
%mend;
%read(pr);

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
    HSCT
 ;
 run ;

 data  adds;
  set libout.adds ;
 run ;

/*** PR ***/
data  wk10;
  set  pr;
  if PRSPID="HSCT";
  keep USUBJID;
run ;

data  adsl;
  length AHSCT $200.;
  merge  adsl wk10(in=a);
  by  USUBJID;
  if a=1 then AHSCT="Y";
  else AHSCT="N";
run ;

/*** ADDS ***/
*** Overall Survival;
proc sort data=adds out=wk20; by USUBJID decending ASTDY; run ;
proc sort data=wk20 nodupkey ; by USUBJID ; run ;

data  wk20;
  length USUBJID PARAM PARAMCD  $200.;
  set  wk20(keep=USUBJID AVALC ASTDT);
  PARAM="Overall Survival";
  PARAMCD="OS";
  if  AVALC="COMPLETED" then do;
    CNSR=1;
    ADT=ASTDT;
  end;
  else if AVALC^="" then do;
    CNSR=0;
    ADT=ASTDT;
  end ;
  drop AVALC ASTDT;
run ;

*** Non-Relapse Mortality;
proc sort data=adds out=wk30; by USUBJID decending ASTDY; run ;
proc sort data=wk30 nodupkey ; by USUBJID ; run ;

data  wk30;
  length USUBJID PARAM PARAMCD  $200.;
  set  wk30(keep=USUBJID AVALC ASTDT);
  PARAM="Non-Relapse Mortality";
  PARAMCD="NONR";
  if  AVALC="COMPLETED" then do;
    CNSR=1;
    ADT=ASTDT;
  end;
  else do;
    CNSR=2;
    ADT=ASTDT;
  end ;
  drop AVALC ASTDT;
run ;

data  wk40;
  set  wk20 wk30;
run;

/* adsl */
proc sort data=wk40; by USUBJID; run ;

data  wk00;
  merge  wk40(in=a) adsl;
  by  USUBJID;
  if a;
  if ADT>=TRTSDT>. then AVAL=ADT-TRTSDT+1;
  if .<ADT < TRTSDT then AVAL=ADT-TRTSDT;
  STARTDT=TRTSDT;
  if AVAL=. then delete;
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
      HSCT  LENGTH=200    LABEL="Prior HSCT",
      AHSCT  LENGTH=200    LABEL="After HSCT",
      PARAM  LENGTH=200    LABEL="Parameter",
      PARAMCD  LENGTH=200    LABEL="Parameter Code",
      STARTDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Time to Event Origin Date for Subject",
      AVAL  LENGTH=8    LABEL="Analysis Value",
      ADT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Analysis Date",
      CNSR      LABEL="Censor"
   from wk00;
quit ;

proc sort data = &file out =libout.&file. nodupkey dupout=aaa;
  by USUBJID PARAMCD ;
run;

%ADS_FIN;

/*** END ***/

            
                       
       
                    
                
                
                 
                     
