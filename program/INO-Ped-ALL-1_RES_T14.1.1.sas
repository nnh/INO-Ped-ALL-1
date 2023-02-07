**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_T14.1.1.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create T14.1.1
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
%LET FILE = T14.1.1;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_RES_LIBNAME.sas";

/*** Template Open ***/
%XLSOPEN(INO-Ped-ALL-1_STAT_RES_&FILE..xlsx);

/*** Format ***/
proc format;
run;

%macro read(file,flg);
  data  &file;
    set  libraw.&file;
    if  SAFFL="Y" then SAFFLN=1;
    else SAFFLN=2;
    if  FASFL="Y" then FASFLN=1;
    else FASFLN=2;
    if  PPSFL="Y" then PPSFLN=1;
    else PPSFLN=2;
    if  DLTFL="Y" then DLTFLN=1;
    else DLTFLN=2;
    if  &flg.=1 then output;
  run ;
%mend;
%read(adsl,SAFFLN);
%read(admh,SAFFLN);
%read(adlb,SAFFLN);

data  adsl;
  set  adsl;
  select(PRIMDIAG);
    when("B-ALL/LBL(ETV6-RUNX1)") PRIMDIAGN=1;
    when("B-ALL/LBL(KMT2A)") PRIMDIAGN=2;
    when("B-ALL/LBL(NOS)") PRIMDIAGN=3;
    when("Hyperdiploid B-ALL/LBL") PRIMDIAGN=4;
    otherwise;
  end ;
  select(ALLER);
    when("Y") ALLERN=1;
    when("N") ALLERN=2;
    otherwise;
  end ;
  select(INTP);
    when("NORMAL") INTPN=1;
    when("ABNORMAL") INTPN=2;
    when("UNEVALUABLE") INTPN=3;
    when("UNKNOWN") INTPN=4;
    otherwise;
  end ;
  select(HSCT);
    when("Y") HSCTN=1;
    when("N") HSCTN=2;
    otherwise;
  end ;
  select(RAD);
    when("Y") RADN=1;
    when("N") RADN=2;
    otherwise;
  end ;
  /*add*/
  PBLSTN=PBLST*0.01*WBC;

  select;
    when (PBLSTN>10000) PBLSGR1=">10,000";
    when (PBLSTN>5000) PBLSGR1=">5,000- 10,000";
    when (PBLSTN>1000) PBLSGR1=">1,000- 5,000";
    when (PBLSTN>0) PBLSGR1=">0- 1,000";
    when (PBLSTN=0) PBLSGR1="0";
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

run ;

data  admh1;
  set  admh;
  if  MHENRTPT="BEFORE";
  select(MHDECOD);
    when("Benign neoplasm") MHDECODN=1;
    when("Drug-induced liver injury") MHDECODN=2;
    when("Infection") MHDECODN=3;
    when("Pneumocystis jirovecii pneumonia") MHDECODN=4;
    when("Sepsis") MHDECODN=5;
    when("Systemic mycosis") MHDECODN=6;
    otherwise;
  end ;
run ;

data  admh2;
  set  admh;
  if  MHENRTPT="ONGOING";
  select(MHDECOD);
    when("Alanine aminotransferase increased") MHDECODN=1;
    when("Alopecia") MHDECODN=2;
    when("Anaemia") MHDECODN=3;
    when("Aspartate aminotransferase increased") MHDECODN=4;
    when("Cataract") MHDECODN=5;
    when("Constipation") MHDECODN=6;
    when("Decreased appetite") MHDECODN=7;
    when("Dermatitis diaper") MHDECODN=8;
    when("Diabetes mellitus") MHDECODN=9;
    when("Dry skin") MHDECODN=10;
    when("Erythema multiforme") MHDECODN=11;
    when("Febrile neutropenia") MHDECODN=12;
    when("Gamma-glutamyltransferase increased") MHDECODN=13;
    when("Gastrointestinal disorder") MHDECODN=14;
    when("Generalised oedema") MHDECODN=15;
    when("Gingivitis") MHDECODN=16;
    when("Haematoma") MHDECODN=17;
    when("Haemorrhoids") MHDECODN=18;
    when("Hepatic function abnormal") MHDECODN=19;
    when("Hypercholesterolaemia") MHDECODN=20;
    when("Hyperferritinaemia") MHDECODN=21;
    when("Hyperglycaemia") MHDECODN=22;
    when("Hypogammaglobulinaemia") MHDECODN=23;
    when("Hypokalaemia") MHDECODN=24;
    when("Interstitial lung disease") MHDECODN=25;
    when("Lymphocyte count decreased") MHDECODN=26;
    when("Malaise") MHDECODN=27;
    when("Nausea") MHDECODN=28;
    when("Neutropenia") MHDECODN=29;
    when("Neutrophil count decreased") MHDECODN=30;
    when("Oedema peripheral") MHDECODN=31;
    when("Oliguria") MHDECODN=32;
    when("Pain in extremity") MHDECODN=33;
    when("Periodontal disease") MHDECODN=34;
    when("Petechiae") MHDECODN=35;
    when("Platelet count decreased") MHDECODN=36;
    when("Protein urine") MHDECODN=37;
    when("Sinusitis") MHDECODN=38;
    when("Tumour associated fever") MHDECODN=39;
    when("Tumour pain") MHDECODN=40;
    when("Ventricular arrhythmia") MHDECODN=41;
    otherwise;
  end ;
run ;

data  adlb1;
  set  adlb;
  if PARAMCD in("T_4_11_","T_9_22_","HPERDIP","HPODIP") and AVISITN=100;
  select(AVALC);
    when("Y") AVAL=1;
    when("N") AVAL=2;
    otherwise;
  end ;
run ;

/***Macro***/
%macro val(var, where, db=adsl, key=USUBJID);
  %global &var.;
  proc sql noprint;
    select count(distinct &key) into: &var.
    from &db.
    where &where.;
  quit;
  %put ************** &var. = &&&var..;
%mend;

%macro mean(no,val,med_len,med_put,sd_len,sd_put,min_len,min_put);
  proc means data = adsl nway noprint ;
/*    class trtpn ;*/
    var   &val ;
    output out = _out&no. n=n mean=mean std=std median=median min=min max=max;
  run ;

  data _out&no.;
    length wk1-wk4 $50.;
    set _out&no.;
    if ^missing(n)      then wk1 =strip(put(n,best.));
    if ^missing(mean)   then wk2 =trim(left(put(round(mean,&med_len.),&med_put.)));
    else                     wk2 ="-";
    if ^missing(std)    then wk2 =trim(left(wk2))||"Å}"||trim(left(put(round(std,&sd_len.),&sd_put.)));
    else                     wk2 =trim(left(wk2))||"Å}-";
    if n(mean,std)=0    then wk2 ="-";

    if ^missing(median) then wk3 = trim(left(put(round(median,&med_len.),&med_put.)));
    else                     wk3 = "-";

    if ^missing(min)    then wk4 =trim(left(put(round(min,&min_len.),&min_put.)));
    else                     wk4 ="-";
    wk4 = trim(left(wk4));
    if ^missing(max)    then wk4 =trim(left(wk4))||"Å`"||trim(left(put(round(max,&min_len.),&min_put.)));
    else                     wk4 =trim(left(wk4))||" -"; 
  run;

  proc transpose data=_out&no. out=out&no. prefix=out;
/*    id  trtpn;*/
    var wk1 wk2 wk3 wk4;
  run;

  data  out&no.;
    length no line 8 out1 $50;
    set  out&no.;
    no = &no.;
    line = input(compress(_name_,"wk"),best.);
  run ;
%mend ;

%macro freq(no,var,num1,jyoken,flg,db=adsl);
  proc freq data=&db. noprint;
    tables &var./out=out&no. outcum;
    %if &flg.=1 %then %do;
      where &jyoken.;
    %end;
  run;

  data dmy;
    do &var. =  &num1.;
      output;
    end;
  run;

  data out&no.;
    length no line close 8 out1 out2 $50;
    merge dmy(in=x) out&no.;
    by &var.;
    if x; 
    no = &no.;
    line = &var.;

    if count = . then count = 0;
    per = count/&cnt.*100;

    out1 = strip(put(round(count,1),8.0)) ;
    out2 = strip(put(round(per,0.1),8.1)) ;

    if &var. = 901 and count = 0 then close = 1 ;
  run;

  proc sort data=out&no.; by no line; run;
%mend; 

%VAL(CNT ,%STR(1));  
%FREQ(01 ,SEXN     , %STR(1 TO 2) , , FLG=0);
%MEAN(02 ,AGE      ,0.1,8.1,0.01,8.2,1.,8.) ;
%FREQ(03 ,AGEGR1N  , %STR(1 TO 3) , , FLG=0);
%MEAN(04 ,BSA      ,0.001,8.3,0.0001,8.4,0.01,8.2) ;
%MEAN(05 ,HEIGHT   ,0.1,8.1,0.01,8.2,1.,8.) ;
%MEAN(06 ,WEIGHT   ,0.01,8.2,0.001,8.3,0.1,8.1) ;
%MEAN(07 ,BMI      ,0.001,8.3,0.0001,8.4,0.01,8.2) ;
%FREQ(08 ,PRIMDIAGN, %STR(1 TO 4) , , FLG=0);
%MEAN(09 ,DISDUR   ,0.1,8.1,0.01,8.2,1.,8.) ;
%FREQ(10 ,MHDECODN, %STR(1 TO 6) , , FLG=0,db=admh1);
%FREQ(11 ,MHDECODN, %STR(1 TO 41) , , FLG=0,db=admh2);
%FREQ(12 ,ALLERN   , %STR(1 TO 2) , , FLG=0);
%FREQ(13 ,INTPN    , %STR(1 TO 4) , , FLG=0);
%FREQ(14 ,RELREFN  , %STR(1 TO 4) , , FLG=0);
%FREQ(15 ,HSCTN    , %STR(1 TO 2) , , FLG=0);
%FREQ(16 ,RADN     , %STR(1 TO 2) , , FLG=0);
%FREQ(17 ,LKPSGR1N , %STR(1 TO 3) , , FLG=0);
%FREQ(18 ,CD22GR1N , %STR(1 TO 3) , , FLG=0);
%MEAN(19 ,LVEF     ,0.01,8.2,0.001,8.3,0.1,8.1) ;
%MEAN(20 ,WBC      ,0.1,8.1,0.01,8.2,1.,8.) ;
%MEAN(21 ,PBLSTN   ,0.01,8.2,0.001,8.3,0.1,8.1) ;
%FREQ(22 ,PBLSGR1N , %STR(1 TO 5) , , FLG=0);
%FREQ(23 ,BLSGR1N  , %STR(1 TO 2) , , FLG=0);
%MEAN(24 ,FRDUR    ,0.1,8.1,0.01,8.2,1.,8.) ;
%FREQ(25 ,FRDURGR1N, %STR(1 TO 2) , , FLG=0);

%FREQ(26 ,AVAL, %STR(1 TO 2) ,%str(PARAMCD="T_9_22_") , FLG=1,db=adlb1);
%FREQ(27 ,AVAL, %STR(1 TO 2) ,%str(PARAMCD="T_4_11_") , FLG=1,db=adlb1);
%FREQ(28 ,AVAL, %STR(1 TO 2) ,%str(PARAMCD="HPODIP") , FLG=1,db=adlb1);
%FREQ(29 ,AVAL, %STR(1 TO 2) ,%str(PARAMCD="HPERDIP") , FLG=1,db=adlb1);

data  header;
  length out1 $50.;
  out1=strip(put(&CNT,best.));
run ;

data  wk00;
  set  header 
       out01-out29 ;
  keep OUT1 OUT2;
run ;

/*** excel output ***/
%let strow = 6;                         *ÉfÅ[É^ïîï™äJénçs;
%let prerow = %eval(&strow. -1);

/*obs*/
proc sql noprint;
   select count (*) into:obs from wk00;
quit;

/*delete*/
/*filename sys dde 'excel|system';*/
/*data _null_;*/
/*   file sys;*/
/*   put "[workbook.activate(""[INO-Ped-ALL-1_STAT_RES_&file..xlsx]&file."")]";*/
/*   put "[select(%bquote("r&strow.:r99999"))]";*/
/*   put '[edit.delete(3)]';*/
/*   put '[select("r1c1")]';*/
/*run;*/

%macro xlsout01(sht,range,ds,var,jdg);

  filename xls dde "excel |\\[INO-Ped-ALL-1_STAT_RES_&file..xlsx]&file.!&range";

  data _null_;
    file xls notab lrecl=10000 dsd dlm='09'x;
    set &ds.;
    dmy = "";
    &jdg.;
    put &var.;
  run;

%mend;
%xlsout01(&file.,r&strow.c4:r%eval(&prerow.+&obs.)c5,wk00,OUT1 OUT2);

/*footer*/
/*data footer;*/
/*   length out1 $200.;*/
/*   out1 = "Analysis Set : PPS"; output;*/
/*   out1 = "Analysis Set : Safety Analysis Set"; output;*/
/*   out1 = "Analysis Set : DLT Analysis Set"; output;*/
/*run;*/
/**/
/*%xlsout01(&file.,r2c2:r2c2,footer,out1);*/
/*%xlsout01(&file.,r%eval(&strow.+&obs.+1)c2:r%eval(&strow.+&obs.+1)c2,footer,out1);*/

/*line*/
/*filename sys dde 'excel|system';*/
/*%macro line(linest=);*/
/*  data _null_;*/
/*    file sys;*/
/*    put "[workbook.activate(""[INO-Ped-ALL-1_STAT_RES_&file..xlsx]&file."")]";*/
/*    put "[select(""r&linest.c2:r&linest.c9"")]";*/
/*    put "[border(,,,,1)]";*/
/*  run;*/
/*%mend;*/
/*%line(linest=%eval(&prerow.+(&obs.)));*/

/*Font*/;
filename sys dde 'excel|system';

data _null_;
   file sys;
   put "[workbook.activate(""[INO-Ped-ALL-1_STAT_RES_&file..xlsx]&file."")]";
   put '[select("r1:r1048576")]';
   put '[font.properties("ÇlÇr ñæí©",,9)]';
   put '[font.properties("times new roman",,9)]';
run;

*** close;
/*** PARAMETERS: iSAVEAS: THE DESTINATION FILENAME TO SAVE TO.*/
/***             iType  : (OPTIONAL. DEFAULT=BLANK). */
/***                      BLANK = XL DEFAULT SAVE TYPE*/
/***                          1 = XLS DOC - OLD SCHOOL! PRE OFFICE 2007?*/
/***                         44 = HTML - PRETTY COOL! CHECK IT OUT... */
/***                         51 = XLSX DOC - OFFICE 2007 ONWARDS COMPATIBLE?*/
/***                         57 = PDF*/

%macro dde_save_as(iSaveAs=,iType=);
  %local iDocTypeClause;

  %let iDocTypeClause=;
  %if "&iType" ne "" %then %do;
    %let iDocTypeClause=,&iType;
  %end;

  filename cmdexcel dde 'excel|system';
  data _null_;
    length str_line $200;
    file cmdexcel;
    put '[error(false)]';
    put "%str([save.as(%"&iSaveAs%"&iDocTypeClause)])";
    str_line = cats("[e","rror(true)]");
    put str_line;
  run;
  filename cmdexcel clear;

%mend;
%dde_save_as(iSaveAs=&output.\INO-Ped-ALL-1_STAT_RES_&file..xlsx, iType=51);

%macro dde_close_without_save();
  filename cmdexcel dde 'excel|system';
  data _null_;
    file cmdexcel;
    put '[select("r1c1")]';
    put '[close(0)]';
  run;
  filename cmdexcel clear;
%mend;
%dde_close_without_save;

%RES_FIN;

/*** END ***/

