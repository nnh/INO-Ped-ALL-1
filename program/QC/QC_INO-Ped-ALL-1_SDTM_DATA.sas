**************************************************************************
Program Name : QC_INO-Ped-ALL-1_SDTM_DATA.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-1-5
SAS version : 9.4
**************************************************************************;
proc datasets library=work kill nolist; quit;
options mprint mlogic symbolgen;
* Define macros start;
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
%macro READ_CSV(dir);
    %local filrf rc did memcnt i filename;
    %let filrf=mydir;
    %let rc=%sysfunc(filename(filrf, &dir.));
    %let did=%sysfunc(dopen(&filrf));
    %let memcnt=%sysfunc(dnum(&did));

    %do i=1 %to &memcnt;
    *Get the file extension;
      %let filename=%qsysfunc(dread(&did, &i));
      data _NULL_;
        length title $60;
        title=compress(tranwrd("&filename.", '.csv', '*'), '*'); output;
        call symputx("dfname", title, "G");
      run;
      *Import a csv file;
      proc import datafile="&dir.\&filename."
        out=&dfname.
        dbms=csv replace;
        guessingrows=MAX;
      run;
    %end;
%mend READ_CSV;
%macro WRITE_CSV(input_ds, output_filename);
    proc export
        data=&input_ds.
        outfile="&outputpath.\&output_filename..csv"
        dbms=csv
        replace;
    run;
%mend WRITE_CSV;
%macro EDIT_DATE_TIME(input_ds, output_ds, target_val, output_val);
    data &output_ds.;
        set &input_ds.;
        dt=input(substrn(&target_val., 1, 10), yymmdd10.);
        if length(&target_val.)>10 then do;
          tm=input(substrn(&target_val., 12, 5), time5.);
        end;
        else do;
          tm=input('00:00', time5.);
        end;
        &output_val.=dhms(dt, 0, 0, tm);
        drop dt tm;
    run;
%mend EDIT_DATE_TIME;
%macro SELECT_MAX_MIN_RECORD(input_ds, output_ds, target_val);
    data temp;
        set &input_ds.;
        by &target_val.;
        output_f=first.&target_val.;
    run;
    data &output_ds.;
        set temp;
        where output_f=1;
        drop output_f;
    run;
%mend SELECT_MAX_MIN_RECORD;
%MACRO SDTM_FIN ;

  DATA _NULL_ ;
       CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
       CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
  RUN ;

  DM LOG "FILE '&LOG.\&FILE._SDTM_LOG_&_YYMM_._&_TIME_..txt' REPLACE" ;
  DM "OUTPUT ; CLEAR ; LOG ; CLEAR ; " ;
%MEND ;
* Define macros end;
* Main processing start;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%let inputpath=&projectpath.\input\rawdata;
%let outputpath=&projectpath.\input\sdtm\QC;
%let log=&projectpath.\log\QC\sdtm;
%let file=DATA;
%READ_CSV(&inputpath.);
*AE;
proc sql noprint;
    create table temp_ae as
    select STUDYID, DOMAIN, USUBJID, AESEQ, AESPID, AETERM, AELLT, AELLTCD, AEDECOD, AEPTCD, AEHLT, AEHLTCD, AEHLGT, AEHLGTCD, AEBODSYS, AEBDSYCD, AESOC, AESOCCD, AESER, AEACN, AEREL, AEOUT, AESCONG, AESDISAB, AESDTH, AESHOSP, AESLIFE, AESMIE, AETOXGR, AESTDTC, AEENDTC
    from AE
    order by STUDYID, USUBJID, AEDECOD, AESTDTC;
quit;
%WRITE_CSV(temp_ae, AE);
*CM;
proc sql noprint;
    create table temp_cm as 
    select STUDYID, DOMAIN, USUBJID, CMSEQ, CMSPID, CMTRT, CMDECOD, CMCAT, 
    case
      when CMPRESP="N" then ""
      else CMPRESP 
    end
    as CMPRESP, 
    CMOCCUR, CMINDC, CMDOSE, CMDOSU, CMROUTE, CMDOSFRQ, CMSTDTC, CMENDTC, CMENRTPT, CMENTPT
    from CM
    order by STUDYID, USUBJID, CMTRT, CMSTDTC, CMSEQ;
quit;
%WRITE_CSV(temp_cm, CM);
*CO;
proc sql noprint;
    create table temp_co as 
    select STUDYID, DOMAIN, RDOMAIN, USUBJID, COSEQ, IDVAR, IDVARVAL, COVAL
    from CO
    order by STUDYID, RDOMAIN, USUBJID, COSEQ; 
quit;
%WRITE_CSV(temp_co, CO);
*DD;
data ds_death;
    set DS;
    where DSTERM="DEATH";
    keep USUBJID DSTERM DSDTC;
run;
proc sql noprint;
    create table temp_dd as 
    select dd.STUDYID, dd.DOMAIN, dd.USUBJID, dd.DDSEQ, dd.DDSPID, dd.DDTESTCD, dd.DDTEST, dd.DDORRES, ds_death.DSDTC as DDDTC
    from dd left join ds_death on dd.USUBJID = ds_death.USUBJID
    order by STUDYID, USUBJID, DDTESTCD;
quit;
%WRITE_CSV(temp_dd, DD);
*DS;
data temp_ds;
    set DS (rename=(EPOCH=temp_EPOCH));
    DSDECOD=DSTERM;
    if DSTERM="SCREEN FAILURE" then do;
      EPOCH="SCREENING";
    end;
    else if temp_EPOCH="" then do;
      EPOCH="FOLLOW-UP";
    end;
    else do;
      EPOCH=temp_EPOCH;
    end;
run;
proc sql noprint;
    create table temp_ds2 as
    select STUDYID, DOMAIN, USUBJID, DSSEQ, DSSPID, DSTERM, DSDECOD, DSCAT, EPOCH, DSDTC, DSSTDTC
    from temp_ds
    order by STUDYID, USUBJID, DSSTDTC, DSDECOD;
quit;
%WRITE_CSV(temp_ds2, DS);
*EC;
proc sql noprint;
    create table temp_ec as
    select STUDYID, DOMAIN, USUBJID, ECSEQ, ECSPID, ECTRT, ECMOOD, ECDOSE, ECDOSU, ECDOSFRM, ECROUTE, VISITNUM, substrn(ECSTDTC, 1, 16) as ECSTDTC, substrn(ECENDTC, 1, 16) as ECENDTC
    from EC
    order by STUDYID, USUBJID, ECTRT, ECMOOD, ECSTDTC, ECSEQ; 
quit;
%WRITE_CSV(temp_ec, EC);
*DM;
%EDIT_DATE_TIME(temp_ec, temp_min_max_ec_1, ECSTDTC, temp_ECSTDTC);
%EDIT_DATE_TIME(temp_min_max_ec_1, serial_ec, ECENDTC, temp_ECENDTC);
%EDIT_DATE_TIME(temp_ds, temp_min_max_ds_1, DSDTC, temp_DSDTC);
%EDIT_DATE_TIME(temp_min_max_ds_1, serial_ds, DSSTDTC, temp_DSSTDTC);
* create table
* min(ECSTDTC);
proc sql noprint;
    create table temp_min_ECSTDTC as
    select USUBJID, temp_ECSTDTC, ECSTDTC
    from serial_ec
    where temp_ECSTDTC ne .
    order by USUBJID, temp_ECSTDTC;
quit;
%SELECT_MAX_MIN_RECORD(temp_min_ECSTDTC, min_ECSTDTC, USUBJID);
* max(ECSTDTC);
proc sql noprint;
    create table temp_max_ECSTDTC as
    select USUBJID, temp_ECSTDTC, ECSTDTC
    from serial_ec
    order by USUBJID, temp_ECSTDTC desc;
quit;
%SELECT_MAX_MIN_RECORD(temp_max_ECSTDTC, max_ECSTDTC, USUBJID);
* max(ECENDTC);
proc sql noprint;
    create table temp_max_ECENDTC as
    select USUBJID, temp_ECENDTC, ECENDTC
    from serial_ec
    order by USUBJID, temp_ECENDTC desc;
quit;
%SELECT_MAX_MIN_RECORD(temp_max_ECENDTC, max_ECENDTC, USUBJID);
* max(DSDTC);
proc sql noprint;
    create table temp_max_DSDTC as
    select USUBJID, temp_DSDTC, DSDTC
    from serial_ds
    order by USUBJID, temp_DSDTC desc;
quit;
%SELECT_MAX_MIN_RECORD(temp_max_DSDTC, max_DSDTC, USUBJID);

* max(DSSTDTC);
proc sql noprint;
    create table temp_max_DSSTDTC as
    select USUBJID, temp_DSSTDTC, DSSTDTC
    from serial_ds
    order by USUBJID, temp_DSDTC desc;
quit;
%SELECT_MAX_MIN_RECORD(temp_max_DSSTDTC, max_DSSTDTC, USUBJID);

proc sql noprint;
    * death;
    create table temp_ds_death as 
    select USUBJID, DSTERM, DSDTC from DS where DSTERM = "DEATH";
quit;

proc sql noprint;
    * merge DM and min(ECSTDTC); 
    create table temp_dm_ec_1 as 
    select a.*, b.ECSTDTC as min_ECSTDTC
    from DM a left join min_ECSTDTC b on a.USUBJID = b.USUBJID;
    * merge DM and max(ECSTDTC); 
    create table temp_dm_ec_2 as 
    select a.*, b.ECSTDTC as max_ECSTDTC, b.temp_ECSTDTC
    from temp_dm_ec_1 a left join max_ECSTDTC b on a.USUBJID = b.USUBJID;
    * merge DM and max(ECENDTC); 
    create table temp_dm_ec_3 as 
    select a.*, b.ECENDTC as max_ECENDTC, b.temp_ECENDTC
    from temp_dm_ec_2 a left join max_ECENDTC b on a.USUBJID = b.USUBJID;
    * merge DM and max(DSDTC); 
    create table temp_dm_ds1 as 
    select a.*, b.DSDTC as RFPENDTC
    from temp_dm_ec_3 a left join max_DSDTC b on a.USUBJID = b.USUBJID;
    * merge DM and max(DSSTDTC); 
    create table temp_dm_ds2 as 
    select a.*, b.DSSTDTC
    from temp_dm_ds1 a left join max_DSSTDTC b on a.USUBJID = b.USUBJID;
    * merge DM and death info;
    create table temp_dm_ec_ds as 
    select a.*, b.DSDTC as DSDTC_DEATH, b.DSTERM 
    from temp_dm_ds2 a left join temp_ds_death b on a.USUBJID = b.USUBJID;
quit;
data temp_dm;
    set temp_dm_ec_ds (drop=ARM ARMCD);
    length ARM $14 ARMCD $8 ACTARM $14 ACTARMCD $8 RFSTDTC $16 RFENDTC $16 RFXENDTC $16;
    RFXSTDTC=min_ECSTDTC;
    if DSTERM="DEATH" then do;
      DTHDTC=DSDTC_DEATH;
      DTHFL="Y";
    end;
    else do;
      call missing(DTHDTC, DTHFL);
    end;
    if missing(RFXSTDTC) then do;
      ARM="Screen Failure";
      ARMCD="SCRNFAIL";
      ACTARM="Screen Failure";
      ACTARMCD="SCRNFAIL";
      call missing(RFSTDTC, RFSTDTC, RFXENDTC);
    end;
    else do;
      ARM="COHORT1";
      ARMCD="COHORT1";
      ACTARM="COHORT1";
      ACTARMCD="COHORT1";
      RFSTDTC=min_ECSTDTC;
      RFENDTC=DSSTDTC;
      if temp_ECENDTC ne "" and temp_ECSTDTC < temp_ECENDTC then do;
          RFXENDTC=max_ECENDTC;
      end;
      else do;
          RFXENDTC=max_ECSTDTC;
      end;
    end;
    AGE=int(YRDIF(input(BRTHDTC,yymmdd10.),input(RFICDTC,yymmdd10.)));
    AGEU="YEARS"; 
run;
proc sql noprint;
    create table temp_dm2 as
    select STUDYID, DOMAIN, USUBJID, SUBJID, RFSTDTC, RFENDTC, RFXSTDTC, RFXENDTC, RFICDTC, RFPENDTC, DTHDTC, DTHFL, SITEID, BRTHDTC, AGE, AGEU, SEX, RACE, ETHNIC, ARMCD, ARM, ACTARMCD, ACTARM, COUNTRY
    from temp_dm
    order by STUDYID, USUBJID;
quit;
%WRITE_CSV(temp_dm2, DM);
*EG;
proc sql noprint;
    create table temp_eg as
    select STUDYID, DOMAIN, USUBJID, EGSEQ, EGSPID, EGTESTCD, EGTEST, EGORRES, 
           case
             when EGORRES="" then ""
             else EGORRESU
           end
           as EGORRESU, 
           VISITNUM, EGDTC, 
           case
             when VISITNUM="108" and EGTESTCD="QTINTNOS" and EGTPTNUM="10" then 40
             else input(EGTPTNUM, best12.)
           end
           as EGTPTNUM 
    from EG
    order by STUDYID, USUBJID, EGTESTCD, VISITNUM, EGTPTNUM, EGSEQ; 
quit;
%WRITE_CSV(temp_eg, EG);
*FA;
proc sql noprint;
    create table temp_fa as
    select STUDYID, DOMAIN, USUBJID, FASEQ, FASPID, FALNKGRP, FATESTCD, FATEST, FAOBJ, FACAT, FAORRES, FAMETHOD, FALOC, VISITNUM, FADTC 
    from FA
    order by STUDYID, USUBJID, FATESTCD, FAOBJ, VISITNUM, FASEQ; 
quit;
%WRITE_CSV(temp_fa, FA);
*IE;
proc sql noprint;
    create table temp_ie as
    select STUDYID, DOMAIN, USUBJID, IESEQ, IESPID, IETESTCD, IETEST, IECAT, IEORRES, IEORRES as IESTRESC, IEDTC 
    from IE
    order by STUDYID, USUBJID, IETESTCD ;
quit;
%WRITE_CSV(temp_ie, IE);
*LB;
proc sql noprint;
    create table temp_lb as
    select STUDYID, DOMAIN, USUBJID, LBSEQ, LBSPID, LBLNKGRP,
           case
             when LBTESTCD="CHROMOSOME" then "CHROMOSO"
             when LBTESTCD="BCR-ABL1" then "BCR_ABL1"
             else LBTESTCD
           end 
           as LBTESTCD, 
           LBTEST, LBCAT, LBORRES, 
           case
             when LBORRES="" then ""
             else LBORRESU
           end
           as LBORRESU, 
           LBSPEC, LBMETHOD, VISITNUM, LBDTC
    from LB
    order by STUDYID, USUBJID, LBTESTCD, LBSPEC, VISITNUM, LBSEQ; 
quit;
%WRITE_CSV(temp_lb, LB);
*MH;
proc sql noprint;
    create table temp_mh as
    select STUDYID, DOMAIN, USUBJID, MHSEQ, MHSPID, MHTERM, 
           case
             when MHDECOD="" then strip(MHTERM)
             else MHDECOD
           end
           as MHDECOD, 
           MHCAT, MHPRESP, MHOCCUR, MHSTDTC, MHENDTC, MHENRTPT, MHENTPT
    from MH
    order by STUDYID, USUBJID, MHDECOD; 
quit;
%WRITE_CSV(temp_mh, MH);
*PC;
proc sql noprint;
    create table temp_pc as
    select STUDYID, DOMAIN, USUBJID, PCSEQ, PCSPID, PCTESTCD, PCTEST, VISITNUM, substrn(PCDTC, 1, 16) as PCDTC, PCTPTNUM
    from PC
    order by STUDYID, USUBJID, PCTESTCD, VISITNUM, PCTPTNUM;
quit;
%WRITE_CSV(temp_pc, PC);
*PE;
proc sql noprint;
    create table temp_pe as
    select STUDYID, DOMAIN, USUBJID, PESEQ, PESPID, PELNKGRP, PETESTCD, 
           case 
             when PETEST="PHYSEXAM" then "Physical Examination"
             else PETEST
           end
           as PETEST, 
           PEBODSYS, PEORRES, PEORRESU, PELOC, PEMETHOD, PEEVAL, VISITNUM, PEDTC
    from PE
    order by STUDYID, USUBJID, PETESTCD, VISITNUM, PESEQ; 
quit;
%WRITE_CSV(temp_pe, PE);
*PR;
proc sql noprint;
    create table temp_pr as
    select STUDYID, DOMAIN, USUBJID, PRSEQ, PRSPID, PRTRT, PRCAT, PRSCAT, 
           case
             when PRPRESP="N" then ""
             else PRPRESP
           end
           as PRPRESP, 
           PROCCUR, PRINDC, 
           case
             when substr(PRSPID, 1, 20)="therapy_within28days" then PRENDTC
             else PRSTDTC
           end
           as PRSTDTC, 
           case
             when substr(PRSPID, 1, 20)="therapy_within28days" then PRSTDTC
             else PRENDTC
           end
           as PRENDTC, 
           PRENRTPT, PRENTPT
    from PR
    order by STUDYID, USUBJID, PRTRT, PRSTDTC ;
quit;
%WRITE_CSV(temp_pr, PR);
*QS;
proc sql noprint;
    create table temp_qs as
    select STUDYID, DOMAIN, USUBJID, QSSEQ, QSSPID, QSTESTCD, QSTEST, QSCAT, QSORRES, VISITNUM, QSDTC
    from QS
    order by STUDYID, USUBJID, QSCAT, QSTESTCD, VISITNUM;
quit;
%WRITE_CSV(temp_qs, QS);
*RS;
proc sql noprint;
    create table temp_rs as
    select STUDYID, DOMAIN, USUBJID, RSSEQ, RSSPID, RSLNKGRP, RSTESTCD, RSTEST, RSCAT, RSORRES, RSEVAL, VISITNUM, RSDTC
    from RS
    order by STUDYID, USUBJID, RSTESTCD, RSCAT, RSEVAL, VISITNUM; 
quit;
%WRITE_CSV(temp_rs, RS);
*SC;
proc sql noprint;
    create table temp_sc as
    select STUDYID, DOMAIN, USUBJID, SCSEQ, SCSPID, SCTESTCD, SCTEST, SCORRES, SCDTC
    from SC
    order by STUDYID, USUBJID, SCTESTCD; 
quit;
%WRITE_CSV(temp_sc, SC);
*VS;
proc sql noprint;
    create table temp_vs as
    select STUDYID, DOMAIN, USUBJID, VSSEQ, VSSPID, VSTESTCD, VSTEST, VSORRES, 
           case 
             when VSORRES="" then ""
             else VSORRESU
           end 
           as VSORRESU, 
           VISITNUM, VSDTC, VSTPTNUM
    from VS
    order by STUDYID, USUBJID, VSTESTCD, VISITNUM, VSTPTNUM; 
quit;
%WRITE_CSV(temp_vs, VS);
* Main processing end;
%SDTM_FIN;
