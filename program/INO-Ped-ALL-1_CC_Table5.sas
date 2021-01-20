**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_Table5.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210114
*
* Purpose           : Create Table5
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
%LET FILE = Table5;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_CC_LIBNAME.sas";

/*** Template Open ***/
%XLSOPEN(INO-Ped-ALL-1_STAT_CC_&FILE..xlsx);

/*** Format ***/
proc format;
run;

/*** Input ***/
data  wk01;
  set  libraw.adec;
  DOSLV=1;
  DOSU="mg/m2";
  if PARAMCD="DOS";
run ;

data  wk02;
  set  libraw.adec;
  DOSLV=1;
  if PARAMCD="INT";
  rename AVALC=INT;
  keep USUBJID AVISIT AVISITN AVALC DOSLV SUBJID SITENM AGE SEX ; 
run ;

data  wk03;
  set  libraw.adec;
  DOSLV=1;
  if PARAMCD="RES";
  rename AVALC=RES;
  keep USUBJID AVISIT AVISITN AVALC DOSLV SUBJID SITENM AGE SEX ; 
run ;

data  wk04;
  merge  wk01 wk02 wk03;
  by USUBJID AVISITN;
run ;

data  wk00;
  set  wk04;
  by  USUBJID;
  if  first.USUBJID=0 then do;
    SUBJID="";
    SITENM="";
    AGE=.;
    SEX="";
    DOSLV=.;
  end ;
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
%xlsout01(&file.,r&strow.c2:r%eval(&prerow.+&obs.)c25,wk00,DOSLV SUBJID SITENM AGE SEX AVISIT ASTDT AVAL DOSU INT RES);

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
    put "[select(""r&linest.c2:r&linest.c12"")]";
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

