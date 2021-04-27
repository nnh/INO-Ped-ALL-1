**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_Table10.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210128
*
* Purpose           : Create Table10
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
%LET FILE = Table10;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_CC_LIBNAME.sas";

%XLSREAD(INO-Ped-ALL-1_LB_Normal Range_20201228.xlsx,ADLB_Normal Range_age,LB1,10,RNUM=2,READLIB=&EXT.,CNUMST=1);

/*** Template Open ***/
%XLSOPEN(INO-Ped-ALL-1_STAT_CC_&FILE..xlsx);

/*** Format ***/
proc format;
run;

/*** Input ***/
data  wk01;
  length OUT1-OUT3 OUT7-OUT8 OUT10 $200.;
  set  libraw.adlb;
  if  TRTSDT>=ADT>.;
  OUT1=strip(SUBJID);
  OUT2=strip(SITENM);
  OUT3=strip(SEX);
  OUT4=AGE;
  OUT5=RFICDT;
  OUT6=TRTSDT;
  OUT7="Laboratory Test Findings";
  OUT8=strip(PARAM);
  OUT9=ADT;
  OUT10=strip(put(AVAL,best.));
  if  ^missing(AVALC) then OUT10=strip(AVALC);
  keep OUT: PARAMCD;
  format OUT5 OUT6 OUT9 yymmdd10.;
run ;

data  lb2;
  set  lb1;
  if  COL3 in("ALT","AST","BILI","CREAT");
  OUT4=input(COL7,best32.);
  rename COL3=PARAMCD;
  rename COL6=OUT3;
  rename COL10=OUT11;
  keep COL3 COL6 OUT4 COL10;
run ;

data  lb3;
  set  lb2;
  if  PARAMCD="BILI" then do;
    OUT3="M";
    output;
  end ;
  if  PARAMCD="BILI" then do;
    OUT3="F";
    output;
  end ;
  if  PARAMCD^="BILI" then do;
    output;
  end ;
run ;

proc sort data=wk01;by PARAMCD OUT3 OUT4; run ;
proc sort data=lb3;by PARAMCD OUT3 OUT4; run ;

data  wk01;
  merge  wk01(in=a) lb3;
  by  PARAMCD OUT3 OUT4;
  if  a;
  if  PARAMCD in("ALT","AST") then OUT12=input(OUT11,best32.)*2.5;
  if  PARAMCD in("BILI","CREAT") then OUT12=input(OUT11,best32.)*1.5;
run ;

data  wk02;
  length OUT1-OUT3 OUT7-OUT8 OUT10 $200.;
  set  libraw.advs;
  if  TRTSDT>=ADT>.;
  OUT1=strip(SUBJID);
  OUT2=strip(SITENM);
  OUT3=strip(SEX);
  OUT4=AGE;
  OUT5=RFICDT;
  OUT6=TRTSDT;
  OUT7="Vital Signs";
  OUT8=strip(PARAM);
  OUT9=ADT;
  OUT10=strip(put(AVAL,best.));
  if  ^missing(AVALC) then OUT10=strip(AVALC);
  keep OUT:;
  format OUT5 OUT6 OUT9 yymmdd10.;
run ;

data  wk03;
  length OUT1-OUT3 OUT7-OUT8 OUT10 $200.;
  set  libraw.adeg;
  if  TRTSDT>=ADT>.;
  OUT1=strip(SUBJID);
  OUT2=strip(SITENM);
  OUT3=strip(SEX);
  OUT4=AGE;
  OUT5=RFICDT;
  OUT6=TRTSDT;
  OUT7="Electrocardiogram Results";
  OUT8=strip(PARAM);
  OUT9=ADT;
  OUT10=strip(put(AVAL,best.));
  if  ^missing(AVALC) then OUT10=strip(AVALC);
  keep OUT:;
  format OUT5 OUT6 OUT9 yymmdd10.;
run ;

data  wk04;
  length OUT1-OUT3 OUT7-OUT8 OUT10 $200.;
  set  libraw.adsl;
  if  TRTSDT>=LKPSDT>.;
  OUT1=strip(SUBJID);
  OUT2=strip(SITENM);
  OUT3=strip(SEX);
  OUT4=AGE;
  OUT5=RFICDT;
  OUT6=TRTSDT;
  OUT7="Questionnaires";
  OUT8="Lansky/Karnofsky performance status";
  OUT9=LKPSDT;
  OUT10=strip(put(LKPSN,best.));
  if  OUT10="" then delete;
  keep OUT:;
  format OUT5 OUT6 OUT9 yymmdd10.;
run ;

data  wk05;
  length OUT1-OUT3 OUT7-OUT8 OUT10 $200.;
  set  libraw.adfa;
  if  TRTSDT>=ADT>.;
  OUT1=strip(SUBJID);
  OUT2=strip(SITENM);
  OUT3=strip(SEX);
  OUT4=AGE;
  OUT5=RFICDT;
  OUT6=TRTSDT;
  OUT7="Findings About";
  OUT8=strip(PARAM);
  OUT9=ADT;
  OUT10=strip(put(AVAL,best.));
  if  ^missing(AVALC) then OUT10=strip(AVALC);
  if  OUT10="" then delete;
  keep OUT:;
  format OUT5 OUT6 OUT9 yymmdd10.;
run ;

data  wk00;
  set  wk01-wk05;
run ;

proc sort data=wk00; by OUT1 OUT7 OUT8 OUT9; run ;

/*** excel output ***/
%let strow = 6;                         *ÉfÅ[É^ïîï™äJénçs;
%let prerow = %eval(&strow. -1);

/*obs*/
proc sql noprint;
   select count (*) into:obs from wk00;
quit;

/*delete*/
filename sys dde 'excel|system';
data _null_;
   file sys;
   put "[workbook.activate(""[INO-Ped-ALL-1_STAT_CC_&file..xlsx]&file."")]";
   put "[select(%bquote("r&strow.:r99999"))]";
   put '[edit.delete(3)]';
   put '[select("r1c1")]';
run;

%macro xlsout01(sht,range,ds,var,jdg);

  filename xls dde "excel |\\[INO-Ped-ALL-1_STAT_CC_&file..xlsx]&file.!&range";

  data _null_;
    file xls notab lrecl=10000 dsd dlm='09'x;
    set &ds.;
    dmy = "";
    &jdg.;
    put &var.;
  run;

%mend;
%xlsout01(&file.,r&strow.c2:r%eval(&prerow.+&obs.)c13,wk00,OUT1-OUT12);

/*footer*/
/*data footer;*/
/*   length out1 $200.;*/
/*   out1 = "*íÜé~éûä˙ = íÜé~ì˙ - ìäó^äJénì˙ + 1"; output;*/
/*run;*/

/*%xlsout01(&file.,r%eval(&strow.+&obs.+1)c2:r%eval(&strow.+&obs.+1)c2,footer,out1);*/

/*line*/
filename sys dde 'excel|system';
%macro line(linest=);
  data _null_;
    file sys;
    put "[workbook.activate(""[INO-Ped-ALL-1_STAT_CC_&file..xlsx]&file."")]";
    put "[select(""r&linest.c2:r&linest.c13"")]";
    put "[border(,,,,1)]";
  run;
%mend;
%line(linest=%eval(&prerow.+(&obs.)));

/*Font*/;
filename sys dde 'excel|system';

data _null_;
   file sys;
   put "[workbook.activate(""[INO-Ped-ALL-1_STAT_CC_&file..xlsx]&file."")]";
   put '[select("r1:r1048576")]';
   put '[font.properties("ÇlÇr ñæí©",,9)]';
   put '[font.properties("times new roman",,9)]';
run;

*** close;
data _null_;
   file sys;
   put "[workbook.activate(""[INO-Ped-ALL-1_STAT_CC_&file..xlsx]&file."")]";
   put '[select("r1c1")]';
   put '[error(false)]';
   put "[save.as(""&output.\INO-Ped-ALL-1_STAT_CC_&file..xlsx"")]";
   put '[quit()]';
run;

%CC_FIN;

/*** END ***/

