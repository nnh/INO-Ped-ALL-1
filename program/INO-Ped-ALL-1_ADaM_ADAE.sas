**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_ADaM_ADAE.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20201225
*
* Purpose           : Create ADAE DataSet
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
%LET FILE = ADAE;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_ADaM_LIBNAME.sas";

/*** Data Reading ***/
%macro read(filename);
  data  work.&filename.;
    set libraw.&filename.;
    informat _all_;
    format _all_;
  run ;
%mend;
%read(ae);
%read(co);

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

 data  meddra;
   set  libext.meddra;
   AEBODSYS=strip(soc_name);
   AEBDSYCD=soc_code;
   AELLT=strip(llt_name);
   AELLTCD=llt_code;
   AEDECOD=strip(pt_name);
   AEPTCD=pt_code;
   AESOC=strip(soc_name);
   AESOCCD=soc_code;
   keep 
    AEBODSYS
    AEBDSYCD
    AELLT
    AELLTCD
    AEDECOD
    AEPTCD
    AESOC
    AESOCCD
  ;
run ;

/*** AE ***/
data  wk11;
  length USUBJID $200.;
  keep 
    USUBJID
    AESEQ
    AETERM
    AELLTCD
    AESTDTC
    AEENDTC
    AESER
    AESDTH
    AESLIFE
    AESHOSP
    AESDISAB
    AESCONG
    AESMIE
    AEREL
    AEACN
    AEOUT
    AETOXGR
    ASTDT
    AENDT
    ADURN
    ADURU
    AERELN
    AEDICT
  ;
  set  ae(rename=(AELLTCD=_AELLTCD AETOXGR=_AETOXGR));
  ASTDT=input(AESTDTC,yymmdd10.);
  AENDT=input(AEENDTC,yymmdd10.);
  ADURN=AENDT - ASTDT + 1;
  ADURU="DAYS";
  AELLTCD=input(_AELLTCD,best32.);
  AETOXGR=input(_AETOXGR,best32.);
  if AEREL="RELATED" then AERELN=1;
  else if AEREL="NOT RELATED" then AERELN=2;
  AEDICT='MedDRA V23.1';
run ;

/* MedDRA */
proc sort data=wk11; by AELLTCD; run ;
proc sort data=Meddra; by AELLTCD; run ;

data  wk12;
  merge  wk11(in=a) meddra;
  by  AELLTCD;
  if a;
run ;

/* co */
proc sort data=wk12; by AESEQ; run ;
proc sort data=co(rename=(IDVARVAL=AESEQ)) out=wk13; by AESEQ; run ;

data  wk14;
  merge  wk12 wk13(keep=AESEQ COVAL);
  by  AESEQ;
run ;

/* adsl */
proc sort data=wk14; by USUBJID; run ;

data  wk00;
  merge  wk14(in=a rename=(AESEQ=_AESEQ)) adsl;
  by  USUBJID;
  if a;
  if ASTDT>=TRTSDT>. then ASTDY=ASTDT-TRTSDT+1 ;
  else if .<ASTDT<TRTSDT then  ASTDY=ASTDT-TRTSDT;
  if AENDT>=TRTSDT>. then AENDY=AENDT-TRTSDT+1 ;
  else if .<AENDT<TRTSDT then AENDY=AENDT-TRTSDT;
  AESEQ=input(_AESEQ,best32.);
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
    AESEQ  LENGTH=8    LABEL="Sequence Number",
    AETERM  LENGTH=200    LABEL="Reported Term for the Adverse Event",
    AEBODSYS  LENGTH=200    LABEL="Body System or Organ Class",
    AEBDSYCD  LENGTH=8    LABEL="Body System or Organ Class Code",
    AELLT  LENGTH=200    LABEL="Lowest Level Term",
    AELLTCD  LENGTH=8    LABEL="Lowest Level Term Code",
    AEDECOD  LENGTH=200    LABEL="Dictionary-Derived Term",
    AEPTCD  LENGTH=8    LABEL="Preferred Term Code",
    AESOC  LENGTH=200    LABEL="Primary System Organ Class",
    AESOCCD  LENGTH=8    LABEL="Primary System Organ Class Code",
    AESTDTC  LENGTH=200    LABEL="Start Date/Time of Adverse Event",
    ASTDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Analysis Start Date",
    AEENDTC  LENGTH=200    LABEL="End Date/Time of Adverse Event",
    AENDT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Analysis End Date",
    ASTDY  LENGTH=8    LABEL="Analysis Start Relative Day",
    AENDY  LENGTH=8    LABEL="Analysis End Relative Day",
    ADURN  LENGTH=8    LABEL="AE Duration (N)",
    ADURU  LENGTH=200    LABEL="AE Duration Units",
    AESER  LENGTH=200    LABEL="Serious Event",
    AESDTH  LENGTH=200    LABEL="Results in Death",
    AESLIFE  LENGTH=200    LABEL="Is Life Threatening",
    AESHOSP  LENGTH=200    LABEL="Requires or Prolongs Hospitalization",
    AESDISAB  LENGTH=200    LABEL="Persist or Signif Disability/Incapacity",
    AESCONG  LENGTH=200    LABEL="Congenital Anomaly or Birth Defect",
    AESMIE  LENGTH=200    LABEL="Other Medically Important Serious Event",
    AEREL  LENGTH=200    LABEL="Causality",
    AERELN  LENGTH=8    LABEL="Causality (N)",
    AEACN  LENGTH=200    LABEL="Action Taken with Study Treatment",
    AEOUT  LENGTH=200    LABEL="Outcome of Adverse Event",
    AETOXGR  LENGTH=8    LABEL="Standard Toxicity Grade",
    AEDICT  LENGTH=200    LABEL="Coding Dictionary Information",
    COVAL  LENGTH=200    LABEL="Relationship to Non-Study Treatment"
   from wk00;
quit ;

proc sort data = &file out =libout.&file. nodupkey;
  by USUBJID AESEQ;
run;

%ADS_FIN;

/*** END ***/

            
                       
       
                    
                
                
                 
                     
