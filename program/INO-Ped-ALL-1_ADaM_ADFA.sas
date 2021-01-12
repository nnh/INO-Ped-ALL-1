**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_ADaM_ADFA.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20201225
*
* Purpose           : Create ADFA DataSet
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
%LET FILE = ADFA;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_ADaM_LIBNAME.sas";

/*** Data Reading ***/
%macro read(filename);
  data  work.&filename.;
    set libraw.&filename.;
    informat _all_;
    format _all_;
  run ;
%mend;
%read(fa);

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

/*** FA ***/
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
    PARCAT1
    PARCAT2
    PARCAT3
    PARCAT4
    FACAT
    FAOBJ
    FAMETHOD
    FALOC
  ;
  set  fa;
  if  ^missing(FAORRES);
  PARAMCD=strip(FATESTCD);
  PARAM=strip(FATEST);
  AVALC=strip(FAORRES);
  AVAL=.;
  ADT=input(FADTC,yymmdd10.);
  AVISITN=input(VISITNUM,best32.);
  PARCAT1=strip(FACAT);
  PARCAT2=strip(FAOBJ);
  PARCAT3=strip(FAMETHOD);
  PARCAT4=strip(FALOC);
  format ADT yymmdd10.;
run ;

data  wk20;
  length AVISIT $200.;
  set  wk10;
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
proc sort data=wk20; by USUBJID; run ;

data  wk00;
  merge  wk20(in=a) adsl;
  by  USUBJID;
  if a;
  if ADT>=TRTSDT>. then ADY=ADT-TRTSDT+1;
  if .<ADT < TRTSDT then ADY=ADT-TRTSDT;
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
      PARCAT1  LENGTH=200    LABEL="Parameter Category 1",
      PARCAT2  LENGTH=200    LABEL="Parameter Category 2",
      PARCAT3  LENGTH=200    LABEL="Parameter Category 3",
      PARCAT4  LENGTH=200    LABEL="Parameter Category 4",
      PARAM  LENGTH=200    LABEL="Parameter",
      PARAMCD  LENGTH=200    LABEL="Parameter Code",
      AVALC  LENGTH=200    LABEL="Analysis Value (C)",
      AVAL  LENGTH=8    LABEL="Analysis Value",
      ADT  LENGTH=8  FORMAT=YYMMDD10.  LABEL="Analysis Date",
      ADY  LENGTH=8    LABEL="Analysis Relative Day",
      AVISIT  LENGTH=200    LABEL="Analysis Visit",
      AVISITN  LENGTH=8    LABEL="Analysis Visit (N)"
   from wk00;
quit ;

proc sort data = &file out =libout.&file. nodupkey dupout=aaa;
  by USUBJID PARCAT1 PARAMCD AVISITN ADT;
run;

%ADS_FIN;

/*** END ***/

            
                       
       
                    
                
                
                 
                     
