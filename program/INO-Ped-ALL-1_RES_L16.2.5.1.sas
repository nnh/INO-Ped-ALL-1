**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_L16.2.5.1.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210114
*
* Purpose           : Create L16.2.5.1
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
%LET FILE = L16.2.5.1;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_RES_LIBNAME.sas";

/*** Template Open ***/
%XLSOPEN(INO-Ped-ALL-1_STAT_RES_&FILE..xlsx);

/*** Format ***/
proc format;
run;

/*** Input ***/
data  adrs;
  set  libraw.adrs;
  if  PARAMCD in("MRD","OVRLRESP");
  AVISITN=AVISITN-99;
run ;

data  adec;
  set  libraw.adec;
  if  PARAMCD in("DOS");
  keep USUBJID AVISITN ASTDT;
run ;

proc sort data=adrs; by USUBJID AVISITN; run ;
proc sort data=adec; by USUBJID AVISITN; run ;

data  base;
  length TIMING $200.;
  merge  adrs(in=a) adec;
  by  USUBJID AVISITN ;
  if a;
  ASTDY = ADT - ASTDT+1;
  DYC=substr(AVISIT,8,14);
  TIMING=strip(DYC) ||" DAY"||strip(put(ASTDY,best.))  ||" ("|| strip(put(ADY,best.))  ||")";
run ;

data  wk01;
  set  libraw.adrs;
  if  PARAMCD="DLT" ;
run ;

data  wk01;
  retain LINE;
  set  wk01;
  by  USUBJID;
  if  first.USUBJID=1 then LINE=0;
  LINE=LINE+1;
  rename AVALC=OUT1;
  keep LINE USUBJID AVALC;
 run ;

data  wk02;
  set  base;
  if  PARAMCD="MRD" ;
run ;

data  wk02;
  retain LINE;
  set  wk02;
  by  USUBJID;
  if  first.USUBJID=1 then LINE=0;
  LINE=LINE+1;
  rename ADT=OUT2;
  rename TIMING=OUT3;
  rename AVALC=OUT4;
  keep LINE USUBJID ADT TIMING AVALC;
 run ;

 data  wk03;
  set  base;
  if  PARAMCD="OVRLRESP" ;
run ;

data  wk03;
  retain LINE;
  set  wk03;
  by  USUBJID;
  if  first.USUBJID=1 then LINE=0;
  LINE=LINE+1;
  rename ADT=OUT5;
  rename TIMING=OUT6;
  rename AVALC=OUT7;
  keep LINE USUBJID ADT TIMING AVALC;
 run ;

 data  wk04;
  set  libraw.adrs;
  if  PARAMCD="BESTRESP" ;
run ;

data  wk04;
  retain LINE;
  set  wk04;
  by  USUBJID;
  if  first.USUBJID=1 then LINE=0;
  LINE=LINE+1;
  rename AVALC=OUT8;
  keep LINE USUBJID AVALC;
 run ;

 data  wk00;
   merge  wk01- wk04;
   by  USUBJID LINE;
   DOSLV="1";
   SUBJID=substr(USUBJID,15,19);
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
   put "[workbook.activate(""[INO-Ped-ALL-1_STAT_RES_&file..xlsx]&file."")]";
   put "[select(%bquote("r&strow.:r99999"))]";
   put '[edit.delete(3)]';
   put '[select("r1c1")]';
run;

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
%xlsout01(&file.,r&strow.c2:r%eval(&prerow.+&obs.)c11,wk00, DOSLV SUBJID OUT1-OUT8);

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
    put "[workbook.activate(""[INO-Ped-ALL-1_STAT_RES_&file..xlsx]&file."")]";
    put "[select(""r&linest.c2:r&linest.c11"")]";
    put "[border(,,,,1)]";
  run;
%mend;
%line(linest=%eval(&prerow.+(&obs.)));

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

