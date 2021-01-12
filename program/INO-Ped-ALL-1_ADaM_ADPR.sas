**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_ADaM_ADPR.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20201225
*
* Purpose           : Create ADPR DataSet
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
%LET FILE = ADPR;

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
 ;
 run ;

/*** PR ***/
data  wk11;
  length USUBJID $200.;
  keep 
    USUBJID
    PRSEQ
    PRTRT
    PRCAT
    PRSCAT
    ASTDT
    AENDT
  ;
  set  pr(rename=(PRSEQ=_PRSEQ));
  ASTDT=input(PRSTDTC,yymmdd10.);
  AENDT=input(PRENDTC,yymmdd10.);
  PRSEQ=input(_PRSEQ,best32.);
run ;

/* adsl */
proc sort data=wk11; by USUBJID; run ;

data  wk00;
  merge  wk11(in=a) adsl;
  by  USUBJID;
  if a;
/*  if ASTDT>=TRTSDT>. then ASTDY=ASTDT-TRTSDT+1 ;*/
/*  else if .<ASTDT<TRTSDT then  ASTDY=ASTDT-TRTSDT;*/
/*  if AENDT>=TRTSDT>. then AENDY=AENDT-TRTSDT+1 ;*/
/*  else if .<AENDT<TRTSDT then AENDY=AENDT-TRTSDT;*/
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
      PRSEQ  LENGTH=8    LABEL="Sequence Number",
      PRTRT  LENGTH=200    LABEL="Reported Name of Drug, Med, or Therapy",
      PRCAT  LENGTH=200    LABEL="Category for Medication",
      PRSCAT  LENGTH=200    LABEL="Subcategory for Medication",
      ASTDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Analysis Start Date",
      AENDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Analysis End Date"
   from wk00;
quit ;

proc sort data = &file out =libout.&file. nodupkey;
  by USUBJID PRSEQ;
run;

%ADS_FIN;

/*** END ***/

            
                       
       
                    
                
                
                 
                     
