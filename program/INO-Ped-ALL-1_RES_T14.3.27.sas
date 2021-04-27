**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_T14.3.27.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create T14.3.27
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
%LET FILE = T14.3.27;

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
%read(adeg,SAFFLN);

data  base;
  set  adeg;
  if  AVISITN=100 then trtpn=1;
  else if  AVISITN=101 and ATPTN=1 then trtpn=2;
  else if  AVISITN=101 and ATPTN=2 then trtpn=3;
  else if  AVISITN=108 then trtpn=4;
  else if  AVISITN=201 then trtpn=6;
  else if  AVISITN=301 then trtpn=7;
  else if  AVISITN=401 then trtpn=8;
  else if  AVISITN=800 then trtpn=9;
  select;
    when (.<(AVAL*1000)<=450)   ACAT=1;
    when (450<(AVAL*1000)<=480) ACAT=2;
    when (480<(AVAL*1000)<=500) ACAT=3;
    when (500<(AVAL*1000))      ACAT=4;
    otherwise ;
  end ;
run ;

data  worst_1;
  set  base;
  if  trtpn in(2,3);
  proc sort ; by USUBJID PARAMCD decending AVAL;
  proc sort nodupkey ; by USUBJID PARAMCD;
run ;

data  worst_1;
  set  worst_1;
  trtpn=5;
run ;

data  worst;
  set  base;
  proc sort ; by USUBJID PARAMCD decending AVAL;
  proc sort nodupkey ; by USUBJID PARAMCD;
run ;

data  worst;
  set  worst;
  trtpn=10;
run ;

data  base;
  set  base worst_1 worst;
run ;

/*chg*/
data  base2;
  set  adeg;
  if  AVISITN=100 then trtpn=1;
  else if  AVISITN=101 and ATPTN=1 then trtpn=2;
  else if  AVISITN=101 and ATPTN=2 then trtpn=3;
  else if  AVISITN=108 then trtpn=4;
  else if  AVISITN=201 then trtpn=6;
  else if  AVISITN=301 then trtpn=7;
  else if  AVISITN=401 then trtpn=8;
  else if  AVISITN=800 then trtpn=9;
  select;
    when (.<(CHG*1000)<30)   ACAT=1;
    when (30<=(CHG*1000)<60) ACAT=2;
    when (60<=(CHG*1000))    ACAT=3;
    otherwise ;
  end ;
run ;

data  worst_1;
  set  base2;
  if  trtpn in(2,3);
  proc sort ; by USUBJID PARAMCD decending CHG;
  proc sort nodupkey ; by USUBJID PARAMCD;
run ;

data  worst_1;
  set  worst_1;
  trtpn=5;
run ;

data  worst;
  set  base2;
  proc sort ; by USUBJID PARAMCD decending CHG;
  proc sort nodupkey ; by USUBJID PARAMCD;
run ;

data  worst;
  set  worst;
  trtpn=10;
run ;

data  base2;
  set  base2 worst_1 worst;
run ;

proc sort data=base; by trtpn; run ;
proc sort data=base2; by trtpn; run ;

%macro freq(no,var,num1,jyoken,flg,db=base);
  proc freq data=&db. noprint;
    tables &var./out=out&no. outcum;
    by  trtpn;
    %if &flg.=1 %then %do;
      where &jyoken.;
    %end;
  run;

  data dmy;
    do trtpn = 1 to 10;
      do &var. =  &num1.;
        output;
      end;
    end ;
  run;

  data out&no.;
    length no line close 8 out1 $50;
    merge dmy(in=x) out&no.;
    by trtpn &var.;
    if x; 
    no = &no.;
    line = &var.;

    if count = . then do;
      count = 0;
      PERCENT = 0;
    end;
/*    per = count/&cnt.*100;*/

    out1 = strip(put(round(count,1),8.0)) || " (" ||  strip(put(round(PERCENT,0.1),8.1)) || ")";

    if &var. = 901 and count = 0 then close = 1 ;
  run;

  proc sort data=out&no.; by no line ; run;

  proc transpose   data=out&no.   out=out_tr&no. ;
        var  out1  ;
        by   no line ;
        id   trtpn ;
  run;

%mend; 
%FREQ(01 ,ACAT     , %STR(1 TO 4) ,%str(PARAMCD="QTINTNOS") , FLG=1);
%FREQ(02 ,ACAT     , %STR(1 TO 4) ,%str(PARAMCD="QTCB")     , FLG=1);
%FREQ(03 ,ACAT     , %STR(1 TO 4) ,%str(PARAMCD="QTCF")     , FLG=1);
%FREQ(11 ,ACAT     , %STR(1 TO 3) ,%str(PARAMCD="QTINTNOS") , FLG=1,db=base2);
%FREQ(12 ,ACAT     , %STR(1 TO 3) ,%str(PARAMCD="QTCB")     , FLG=1,db=base2);
%FREQ(13 ,ACAT     , %STR(1 TO 3) ,%str(PARAMCD="QTCF")     , FLG=1,db=base2);

data  dmy;
  length out1 $50.;
  out1="";
  output; output; 
run ;

data  master;
  set  out_tr01 dmy out_tr11(in=a)
       out_tr02 dmy out_tr12(in=a)
       out_tr03 dmy out_tr13(in=a)
       ;
  if a=1 then _2="-";
run ;

/*** excel output ***/
%let strow = 7;                         *データ部分開始行;
%let prerow = %eval(&strow. -1);

/*obs*/
proc sql noprint;
   select count (*) into:obs from master;
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
%xlsout01(&file.,r&strow.c4:r%eval(&prerow.+&obs.)c12,master,_2-_10);

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
filename sys dde 'excel|system';
%macro line(linest=);
  data _null_;
    file sys;
    put "[workbook.activate(""[INO-Ped-ALL-1_STAT_RES_&file..xlsx]&file."")]";
    put "[select(""r&linest.c2:r&linest.c3"")]";
    put "[border(,,,,1)]";
  run;
%mend;
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

