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
%LET FILE = DATA;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_SDTM_LIBNAME.sas";

/*** Data Reading ***/
%macro csv(filename);
  proc import out= work.&filename.
    datafile="&raw.\&filename..csv"
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

%csv(AE);
%csv(CM);
%csv(CO);
%csv(DD);
%csv(DM);
%csv(DS);
%csv(EC);
%csv(EG);
%csv(FA);
%csv(IE);
%csv(LB);
%csv(MH);
%csv(PC);
%csv(PE);
%csv(PR);
%csv(QS);
%csv(RS);
%csv(SC);
%csv(VS);

/*** AE domain ***/
data  wk_ae;
  set  ae;
run ;

/*** CM domain ***/
data  wk_cm;
  set  cm;
  if CMPRESP="N" then CMPRESP="";
run ;

/*** CO domain ***/
data  wk_co;
  set  co;
  drop COSPID;
run ;

/*** DD domain ***/
data  wk_dd01;
  set  dd;
run ;

data  wk_ds01;
  set  ds;
  rename DSDTC = DDDTC;
  if  DSTERM="DEATH" then output;
  keep USUBJID DSDTC;
run ;

data  wk_dd;
  merge  wk_dd01 wk_ds01;
  by USUBJID;
run ;

/*** DM domain ***/
data  wk_dm01;
  set  dm;
run ;

/* éÄñSì˙ */
data  wk_ds02;
  set  ds;
  rename DSSTDTC = DTHDTC;
  DTHFL="Y";
  if  DSTERM="DEATH" then output;
  keep USUBJID DSSTDTC DTHFL;
run ;

/* èââÒìäó^ì˙ */
data  wk_ec01;
  length ECSTDTC $16.;
  keep USUBJID RFXSTDTC RFSTDTC;
  set  ec;
  RFXSTDTC = ECSTDTC;
  RFSTDTC = ECSTDTC;
  if  ECSTDTC^="";
run ;

proc sort data=wk_ec01; by USUBJID RFSTDTC ; run ;
proc sort data=wk_ec01 nodupkey; by USUBJID ; run ;

/* ç≈èIìäó^ì˙ */
data  wk_ec02;
  length ECSTDTC ECENDTC $16.;
  keep USUBJID ECENDTC ;
  set  ec;
  if  ECENDTC="" then ECENDTC=ECSTDTC;
  rename ECENDTC = RFXENDTC;
run ;

proc sort data=wk_ec02; by USUBJID desending RFXENDTC ; run ;
proc sort data=wk_ec02 nodupkey; by USUBJID ; run ;

/* ç≈èIíÜé~ì˙ */
data  wk_ds03;
  set  ds;
  if  DSTERM^="SCREEN FAILURE";
  rename DSSTDTC = RFENDTC;
  keep USUBJID DSSTDTC ;
run ;

proc sort data=wk_ds03; by USUBJID desending RFENDTC ; run ;
proc sort data=wk_ds03 nodupkey; by USUBJID ; run ;

/* ç≈èIäœé@ì˙ */
data  wk_ds04;
  set  ds;
  rename DSDTC = RFPENDTC;
  keep USUBJID DSDTC ;
run ;

proc sort data=wk_ds04; by USUBJID desending RFPENDTC ; run ;
proc sort data=wk_ds04 nodupkey; by USUBJID ; run ;

data  wk_dm02;
  merge  wk_dm01 wk_ds02 wk_ec01 wk_ec02 wk_ds03 wk_ds04;
  by  USUBJID;
run ;

data  wk_dm;
  length AGEU $10. ARM ARMCD ACTARM ACTARMCD $20.;
  set  wk_dm02;
  if  missing(RFXSTDTC) then do;
    ARM="Screen Failure";
    ARMCD="SCRNFAIL";
    ACTARM="Screen Failure";
    ACTARMCD="SCRNFAIL";
  end ;
  else do;
    ARM="COHORT1";
    ARMCD="COHORT1";
    ACTARM="COHORT1";
    ACTARMCD="COHORT1";
  end;
  AGE=int(YRDIF(input(BRTHDTC,yymmdd10.),input(RFICDTC,yymmdd10.)));
  AGEU="YEARS";
run ;

/*** DS domain ***/
data  wk_ds;
  length DSDECOD $100.;
  set  ds;
  DSDECOD=DSTERM;
  if  DSTERM="SCREEN FAILURE" then EPOCH="SCREENING";
  else if EPOCH="" then EPOCH="FOLLOW-UP";
run ;

/*** EC domain ***/
data  wk_ec;
  length ECSTDTC ECENDTC $16.;
  set  ec;
run ;

/*** EG domain ***/
data  wk_eg;
  set  eg;
  if  EGORRES="" then EGORRESU="";
run ;

/*** FA domain ***/
data  wk_fa;
  set  fa;
run ;

/*** IE domain ***/
data  wk_ie;
  set  ie;
  IESTRESC=IEORRES;
run ;

/*** LB domain ***/
data  wk_lb;
  set  lb;
  if  LBTESTCD="CHROMOSOME" then LBTESTCD="CHROMOSO";
  if  LBTESTCD="BCR-ABL1" then LBTESTCD="BCR_ABL1";
  if  LBORRES="" then LBORRESU="";
run ;

/*** MH domain ***/
data  wk_mh;
  set  mh;
  if  MHDECOD="" then MHDECOD=strip(MHTERM);
run ;

/*** PC domain ***/
data  wk_pc;
  length PCDTC $16.;
  set  pc;
run ;

/*** PE domain ***/
data  wk_pe;
  set  pe;
  IF  PETEST="PHYSEXAM" then PETEST="Physical Examination";
run ;

/*** PR domain ***/
data  wk_pr;
  set  pr;
  if PRPRESP="N" then PRPRESP="";

  if substr(PRSPID,1,20)="therapy_within28days" then do;
    PRSTDTC_= PRSTDTC;
    PRENDTC_= PRENDTC;
    PRSTDTC = PRENDTC_;
    PRENDTC = PRSTDTC_;
  end ;
run ;

/*** QS domain ***/
data  wk_qs;
  set  qs;
run ;

/*** RS domain ***/
data  wk_rs;
  set  rs;
run ;

/*** SC domain ***/
data  wk_sc;
  set  sc;
run ;

/*** VS domain ***/
data  wk_vs;
  set  vs;
  if  VSORRES="" then VSORRESU="";
run ;

/*** output ***/
%macro output_csv(domain,val,sortval);
  data out;
    keep &val.;
    format &val.;
    set  wk_&domain.;
  run ;

  proc sort data=out ; by &sortval.; run ;

  data libout.&domain.;
    set  out;
  run ;

  proc export data= out
            outfile= "&output.\&domain..csv"
            dbms=csv replace;
  run;

  proc import out= work.out2
    datafile="&output.\&domain..csv"
    dbms=csv replace;
    getnames=yes;
    datarow=2;
    guessingrows=MAX;  
  run; 

  libname MYXPT xport "&output.\&domain..xpt";

  proc copy in=WORK out=MYXPT memtype=data;
     select out2;
  run;
%mend;

%output_csv( AE ,%str( STUDYID DOMAIN USUBJID AESEQ AESPID AETERM AELLT AELLTCD AEDECOD AEPTCD AEHLT AEHLTCD AEHLGT AEHLGTCD AEBODSYS AEBDSYCD AESOC AESOCCD AESER AEACN AEREL AEOUT AESCONG AESDISAB AESDTH AESHOSP AESLIFE AESMIE AETOXGR AESTDTC AEENDTC),%str( STUDYID USUBJID AEDECOD AESTDTC));
%output_csv( CM ,%str( STUDYID DOMAIN USUBJID CMSEQ CMSPID CMTRT CMDECOD CMCAT CMPRESP CMOCCUR CMINDC CMDOSE CMDOSU CMROUTE CMDOSFRQ CMSTDTC CMENDTC CMENRTPT CMENTPT),%str( STUDYID USUBJID CMTRT CMSTDTC CMSEQ));
%output_csv( CO ,%str( STUDYID DOMAIN RDOMAIN USUBJID COSEQ IDVAR IDVARVAL COVAL ),%str( STUDYID RDOMAIN USUBJID COSEQ));
%output_csv( DD ,%str( STUDYID DOMAIN USUBJID DDSEQ DDSPID DDTESTCD DDTEST DDORRES DDDTC),%str( STUDYID USUBJID DDTESTCD));
%output_csv( DM ,%str( STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFICDTC RFPENDTC DTHDTC DTHFL SITEID BRTHDTC AGE AGEU SEX RACE ETHNIC ARMCD ARM ACTARMCD ACTARM COUNTRY),%str( STUDYID USUBJID));
%output_csv( DS ,%str( STUDYID DOMAIN USUBJID DSSEQ DSSPID DSTERM DSDECOD DSCAT EPOCH DSDTC DSSTDTC),%str( STUDYID USUBJID DSSTDTC DSDECOD DSSEQ));
%output_csv( EC ,%str( STUDYID DOMAIN USUBJID ECSEQ ECSPID ECTRT ECMOOD ECDOSE ECDOSU ECDOSFRM ECROUTE VISITNUM ECSTDTC ECENDTC ),%str( STUDYID USUBJID ECTRT ECMOOD ECSTDTC ECSEQ));
%output_csv( EG ,%str( STUDYID DOMAIN USUBJID EGSEQ EGSPID EGTESTCD EGTEST EGORRES EGORRESU VISITNUM EGDTC EGTPTNUM),%str( STUDYID USUBJID EGTESTCD VISITNUM EGTPTNUM EGSEQ));
%output_csv( FA ,%str( STUDYID DOMAIN USUBJID FASEQ FASPID FALNKGRP FATESTCD FATEST FAOBJ FACAT FAORRES FAMETHOD FALOC VISITNUM FADTC),%str( STUDYID USUBJID FATESTCD FAOBJ VISITNUM FASEQ));
%output_csv( IE ,%str( STUDYID DOMAIN USUBJID IESEQ IESPID IETESTCD IETEST IECAT IEORRES IESTRESC IEDTC),%str( STUDYID USUBJID IETESTCD));
%output_csv( LB ,%str( STUDYID DOMAIN USUBJID LBSEQ LBSPID LBLNKGRP LBTESTCD LBTEST LBCAT LBORRES LBORRESU LBSPEC LBMETHOD VISITNUM LBDTC),%str( STUDYID USUBJID LBTESTCD LBSPEC VISITNUM LBSEQ));
%output_csv( MH ,%str( STUDYID DOMAIN USUBJID MHSEQ MHSPID MHTERM MHDECOD MHCAT MHPRESP MHOCCUR MHSTDTC MHENDTC MHENRTPT MHENTPT ),%str( STUDYID USUBJID MHDECOD));
%output_csv( PC ,%str( STUDYID DOMAIN USUBJID PCSEQ PCSPID PCTESTCD PCTEST VISITNUM PCDTC PCTPTNUM ),%str( STUDYID USUBJID PCTESTCD VISITNUM PCTPTNUM));
%output_csv( PE ,%str( STUDYID DOMAIN USUBJID PESEQ PESPID PELNKGRP PETESTCD PETEST PEBODSYS PEORRES PEORRESU PELOC PEMETHOD PEEVAL VISITNUM PEDTC ),%str( STUDYID USUBJID PETESTCD VISITNUM PESEQ));
%output_csv( PR ,%str( STUDYID DOMAIN USUBJID PRSEQ PRSPID PRTRT PRCAT PRSCAT PRPRESP PROCCUR PRINDC PRSTDTC PRENDTC PRENRTPT PRENTPT),%str( STUDYID USUBJID PRTRT PRSTDTC));
%output_csv( QS ,%str( STUDYID DOMAIN USUBJID QSSEQ QSSPID QSTESTCD QSTEST QSCAT QSORRES VISITNUM QSDTC),%str( STUDYID USUBJID QSCAT QSTESTCD VISITNUM));
%output_csv( RS ,%str( STUDYID DOMAIN USUBJID RSSEQ RSSPID RSLNKGRP RSTESTCD RSTEST RSCAT RSORRES RSEVAL VISITNUM RSDTC),%str( STUDYID USUBJID RSTESTCD RSCAT RSEVAL));
%output_csv( SC ,%str( STUDYID DOMAIN USUBJID SCSEQ SCSPID SCTESTCD SCTEST SCORRES SCDTC),%str( STUDYID USUBJID SCTESTCD));
%output_csv( VS ,%str( STUDYID DOMAIN USUBJID VSSEQ VSSPID VSTESTCD VSTEST VSORRES VSORRESU VISITNUM VSDTC VSTPTNUM),%str( STUDYID USUBJID VSTESTCD VISITNUM VSTPTNUM));

%SDTM_FIN;

/*** END ***/

            
                       
       
                    
                
                
                 
                     
