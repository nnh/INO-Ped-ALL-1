**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_T11.1.1.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create T11.1.1
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
%LET FILE = T11.1.1;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_RES_LIBNAME.sas";

/*** Template Open ***/
%XLSOPEN(INO-Ped-ALL-1_STAT_RES_&FILE..xlsx);

/*** Format ***/
proc format;
run;

data  adsl;
  set  libraw.adsl;
  if  SAFFL="Y" then SAFFLN=1;
  else SAFFLN=2;
  if  FASFL="Y" then FASFLN=1;
  else FASFLN=2;
  if  PPSFL="Y" then PPSFLN=1;
  else PPSFLN=2;
  if  DLTFL="Y" then DLTFLN=1;
  else DLTFLN=2;
  if  PKFL="Y" then PKFLN=1;
  else PKFLN=2;
  if  ADAFL="Y" then ADAFLN=1;
  else ADAFLN=2;
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

%macro freq(no,var,num1,jyoken,flg);
  proc freq data=adsl noprint;
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
    length no line close 8 out1 /*out2*/ $50;
    merge dmy(in=x) out&no.;
    by &var.;
    if x; 
    no = &no.;
    line = &var.;

    if count = . then count = 0;
    per = count/&cnt.*100;

    _out1 = strip(put(round(count,1),8.0));
    _out2 = "(" || strip(put(round(per,0.1),8.1)) || ")" ;
    out1=strip(_out1)||" "||strip(_out2);

    if &var. = 901 and count = 0 then close = 1 ;
  run;

  proc sort data=out&no.; by no line; run;
%mend; 

%VAL(CNT ,%STR(1));  
%FREQ(01 ,SAFFLN       , %STR(1 TO 2) , , FLG=0);
%FREQ(02 ,FASFLN       , %STR(1 TO 2) , , FLG=0);
%FREQ(03 ,PPSFLN       , %STR(1 TO 2) , , FLG=0);
%FREQ(04 ,DLTFLN       , %STR(1 TO 2) , , FLG=0);
%FREQ(05 ,PKFLN       , %STR(1 TO 2) , , FLG=0);
%FREQ(06 ,ADAFLN       , %STR(1 TO 2) , , FLG=0);

data  header;
  length out1 $50.;
  out1=strip(put(&CNT,best.));
run ;

data  wk00;
  set  header 
       out01 - out06;
       keep OUT1;
run ;

/*** excel output ***/
%let strow = 7;                         *ÉfÅ[É^ïîï™äJénçs;
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
/*   out1 = "*íÜé~éûä˙ = íÜé~ì˙ - ìäó^äJénì˙ + 1"; output;*/
/*run;*/

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

