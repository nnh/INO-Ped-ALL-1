**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_Table6.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210114
*
* Purpose           : Create Table6
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
%LET FILE = Table6;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_CC_LIBNAME.sas";

/*** Template Open ***/
%XLSOPEN(INO-Ped-ALL-1_STAT_CC_&FILE..xlsx);

/*** Format ***/
proc format;
run;

/*** Input ***/
data  wk01;
  set  libraw.adrs;
  DOSLV=1;
  SEQ=1;
  if  PARAMCD="DLT";
  rename AVALC=DLT;
run ;

data  wk02;
  set  libraw.adrs;
  if  PARAMCD="MRD";
  if  AVALC="" then delete;
  rename AVALC=MRD;
  rename ADT=MRD_DT;
  rename ADY=MRD_DY;
  keep USUBJID AVALC ADT ADY ;
run ;

proc sort data=wk02 nodupkey; by USUBJID MRD_DT; run ;

data  wk02;
  retain SEQ;
  set  wk02;
  by USUBJID;
  if  first.USUBJID=1 then SEQ=0;
  SEQ=SEQ+1;
run ;

data  wk03;
  set  libraw.adrs;
  if  PARAMCD="OVRLRESP";
  rename AVALC=OVRLRESP;
  rename ADT=OVRLRESP_DT;
  rename ADY=OVRLRESP_DY;
  keep USUBJID AVALC ADT ADY ;
run ;

proc sort data=wk03 nodupkey; by USUBJID OVRLRESP_DT; run ;

data  wk03;
  retain SEQ;
  set  wk03;
  by USUBJID;
  if  first.USUBJID=1 then SEQ=0;
  SEQ=SEQ+1;
run ;

data  wk04;
  set  libraw.adrs;
  SEQ=1;
  if  PARAMCD="BESTRESP";
  rename AVALC=BESTRESP;
  keep USUBJID AVALC SEQ;
run ;

data  wk00;
  merge  wk01 wk02 wk03 wk04;
  by USUBJID SEQ;
run ;

/*** excel output ***/
%let strow = 7;                         *ÉfÅ[É^ïîï™äJénçs;
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
%xlsout01(&file.,r&strow.c2:r%eval(&prerow.+&obs.)c11,wk00,DOSLV SUBJID DLT MRD_DT MRD_DY MRD OVRLRESP_DT OVRLRESP_DY OVRLRESP BESTRESP);

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
    put "[select(""r&linest.c2:r&linest.c11"")]";
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

