**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_T14.2.3.1.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create T14.2.3.1
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
%LET FILE = T14.2.3.1;

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
%read(adrs,PPSFLN);

data  base;
  set  adrs;
  if  PARAMCD="MRD" ;
  if  AVALC="NEGATIVE" then AVAL=1;
  else  AVAL=2;
run ;

data  best;
  set  adrs;
  if  PARAMCD="BESTRESP" and AVALC in("CR","CRi");
  keep USUBJID;
run ;

data  base;
  merge  base best(in=a);
  by  USUBJID;
  if a;
run ;

proc sort data=base; by USUBJID AVAL; run ;
proc sort data=base nodupkey; by USUBJID ; run ;


%macro bin(val,outf);
  proc freq data=base noprint;
    tables &val. / binomial(level="NEGATIVE");
    output out=&outf. binomial;
  run;

  data  &outf.;
    set  &outf.;
    OUT1=strip(put(N,best.));
    OUT2=strip(put(_BIN_*N,best.));
    OUT3=strip(put(_BIN_*100,8.2));
    OUT4=strip(put(round(XL_BIN*100,0.01),8.2));
    OUT5=strip(put(round(XU_BIN*100,0.01),8.2));
    keep OUT1-OUT5;
  run ;
%mend;
%bin(AVALC,wk00);

/*** excel output ***/
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
%xlsout01(&file.,r8c3:r8c7,wk00,OUT1-OUT5);

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
   put '[font.properties("‚l‚r –¾’©",,9)]';
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

