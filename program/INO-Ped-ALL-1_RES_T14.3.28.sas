**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_T14.3.28.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create T14.3.28
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
%LET FILE = T14.3.28;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_RES_LIBNAME.sas";

%XLSREAD(INO-Ped-ALL-1_LB_Normal Range_20201228.xlsx,ADLB_Normal Range_age,LB1,10,RNUM=2,READLIB=&EXT.,CNUMST=1);

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
%read(adlb,SAFFLN);
%read(adsl,SAFFLN);

data  wk01;
  set  adlb;
  if  PARAMCD in("ALT","AST","BILI");
run ;

data  lb2;
  set  lb1;
  if  COL3 in("ALT","AST","BILI");
  AAGE=input(COL7,best32.);
  ULN=input(COL10,best32.);
  rename COL3=PARAMCD;
  rename COL6=SEX;
  keep COL3 COL6 AAGE ULN;
run ;

data  lb3;
  set  lb2;
  if  PARAMCD="BILI" then do;
    SEX="M";
    output;
  end ;
  if  PARAMCD="BILI" then do;
    SEX="F";
    output;
  end ;
  if  PARAMCD^="BILI" then do;
    output;
  end ;
run ;

proc sort data=wk01;by PARAMCD AAGE SEX; run ;
proc sort data=lb3;by PARAMCD AAGE SEX; run ;

data  wk01;
  merge  wk01(in=a) lb3;
  by   PARAMCD AAGE SEX;
  if  a;
  if  PARAMCD in("ALT","AST") then do;
    if  AVAL>=3*ULN then FLG1="Y";
  end;
  if  PARAMCD in("BILI") then do;
    if  AVAL>=2*ULN then FLG2="Y";
  end ;
  if  FLG1="Y" and FLG2="Y" then FLG3="Y";
run ;

/***Macro***/
%macro val(var, where, db=wk01, key=USUBJID);
  %global &var.;
  proc sql noprint;
    select count(distinct &key) into: &var.
    from &db.
    where &where.;
  quit;
  %put ************** &var. = &&&var..;
%mend;

%VAL(CNT1 ,%STR(1)); 
%VAL(CNT2 ,%STR(PARAMCD="AST" and FLG1="Y")); 
%VAL(CNT3 ,%STR(PARAMCD="ALT" and FLG1="Y")); 
%VAL(CNT4 ,%STR(FLG2="Y")); 
%VAL(CNT5 ,%STR(FLG3="Y")); 

data  wk00;
  length out1 $50.;
  out1=strip(put(&CNT1,best.));
  output;
  out1=strip(put(&CNT2,best.))|| " ("||strip(put(&CNT2/&CNT1*100,8.1))||")";
  output;
  out1=strip(put(&CNT3,best.))|| " ("||strip(put(&CNT3/&CNT1*100,8.1))||")";
  output;
  out1=strip(put(&CNT4,best.))|| " ("||strip(put(&CNT4/&CNT1*100,8.1))||")";
  output;
  out1=strip(put(&CNT5,best.))|| " ("||strip(put(&CNT5/&CNT1*100,8.1))||")";
  output;
run ;

/*** excel output ***/
%let strow = 7;                         *データ部分開始行;
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
%xlsout01(&file.,r&strow.c3:r%eval(&prerow.+&obs.)c3,wk00,OUT1);

/*footer*/
/*data footer;*/
/*   length out1 $200.;*/
/*   out1 = "Analysis Set : PPS"; output;*/
/*   out1 = "Analysis Set : Safety Analysis Set"; output;*/
/*   out1 = "Analysis Set : DLT Analysis Set"; output;*/
/*run;*/

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
   put '[font.properties("ＭＳ 明朝",,9)]';
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

