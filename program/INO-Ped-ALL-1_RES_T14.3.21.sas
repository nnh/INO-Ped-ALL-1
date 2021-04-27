**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_T14.3.21.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create T14.3.21
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
%LET FILE = T14.3.21;

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
%read(adae,SAFFLN);
%read(adsl,SAFFLN);

proc sort data=adsl out=head nodupkey; by  TRT01PN USUBJID ; run ;

proc means data = head nway n noprint ;
  class TRT01PN ;
  var   TRT01PN ;
  output out = all n = n ;
run ;

data _null_ ;
  set all ;
  call symputx( "n" || compress( put( TRT01PN , 8. ) ) , n ) ;
run ;
%put &n1 ;

proc sort data=adae(where=(AERELN=1 and AESER="Y")); by USUBJID AEBDSYCD AEBODSYS AEPTCD AEDECOD decending AETOXGR; run ;
proc sort data=adae nodupkey ; by USUBJID AEBDSYCD AEBODSYS AEPTCD AEDECOD; run ;

data main ;
  set adae(drop=TRT01PN) ;
  cnt = 1 ;
  if  AETOXGR=1 then do; TRT01PN=1 ; output; end;
  if  AETOXGR=2 then do; TRT01PN=2 ; output; end;
  if  AETOXGR=3 then do; TRT01PN=3 ; output; end;
  if  AETOXGR=4 then do; TRT01PN=4 ; output; end;
  if  AETOXGR=5 then do; TRT01PN=5 ; output; end;
  if  AETOXGR in(3,4) then do; TRT01PN=6 ; output; end;
  if  AETOXGR in(3,4,5) then do; TRT01PN=7 ; output; end;
  if  AETOXGR in(1,2,3,4,5) then do; TRT01PN=8 ; output; end;
run ;

%macro ae ( whe , ds ) ;

  %do i = 1 %to 2 ;
    proc sort data = main out = srt %if &i = 1 %then nodupkey ; ;
      by &whe USUBJID TRT01PN;
    run ;

    proc means data = srt nway noprint ;
      class &whe trt01pn ;
      var CNT ;
      output out = n&i n = n&i ;
    run ;
  %end ;

  data work.mrg ;
    merge work.n1
          work.n2 ;
    by &whe TRT01PN ;
    if      TRT01PN = 1 then PER = "(" || trim( put( N1 / &N1 * 100 , 5.1 ) ) || ")" ;
    else if TRT01PN = 2 then PER = "(" || trim( put( N1 / &N1 * 100 , 5.1 ) ) || ")" ;
    else if TRT01PN = 3 then PER = "(" || trim( put( N1 / &N1 * 100 , 5.1 ) ) || ")" ;
    else if TRT01PN = 4 then PER = "(" || trim( put( N1 / &N1 * 100 , 5.1 ) ) || ")" ;
    else if TRT01PN = 5 then PER = "(" || trim( put( N1 / &N1 * 100 , 5.1 ) ) || ")" ;
    else if TRT01PN = 6 then PER = "(" || trim( put( N1 / &N1 * 100 , 5.1 ) ) || ")" ;
    else if TRT01PN = 7 then PER = "(" || trim( put( N1 / &N1 * 100 , 5.1 ) ) || ")" ;
    else if TRT01PN = 8 then PER = "(" || trim( put( N1 / &N1 * 100 , 5.1 ) ) || ")" ;
  run ;

  data work.out&ds ;
    format &whe VAR1 - VAR24 ;
    merge mrg ( where = ( TRT01PN = 1 ) rename = ( N1 = VAR1  PER = VAR2  N2 = VAR3  ) )
          mrg ( where = ( TRT01PN = 2 ) rename = ( N1 = VAR4  PER = VAR5  N2 = VAR6  ) ) 
          mrg ( where = ( TRT01PN = 3 ) rename = ( N1 = VAR7  PER = VAR8  N2 = VAR9  ) ) 
          mrg ( where = ( TRT01PN = 4 ) rename = ( N1 = VAR10 PER = VAR11 N2 = VAR12 ) ) 
          mrg ( where = ( TRT01PN = 5 ) rename = ( N1 = VAR13 PER = VAR14 N2 = VAR15 ) ) 
          mrg ( where = ( TRT01PN = 6 ) rename = ( N1 = VAR16 PER = VAR17 N2 = VAR18 ) ) 
          mrg ( where = ( TRT01PN = 7 ) rename = ( N1 = VAR19 PER = VAR20 N2 = VAR21 ) ) 
          mrg ( where = ( TRT01PN = 8 ) rename = ( N1 = VAR22 PER = VAR23 N2 = VAR24 ) ) ;
    %if &ds ^= 0 %then by &whe ; ;
    array bef(*) VAR1 VAR3 VAR4 VAR6 VAR7 VAR9 VAR10 VAR13 VAR16 VAR19 VAR22 VAR12 VAR15 VAR18 VAR21 VAR24;
    do i = 1 to dim( bef ) ;
      if bef(i) = . then bef(i) = 0 ;
    end ;
    array bef2(*) VAR2 VAR5 VAR8 VAR11 VAR14 VAR17 VAR20 VAR23;
    do i = 1 to dim( bef2 ) ;
      if bef2(i) = "" then bef2(i) = "(  0.0)" ;
    end ;
  run ;
%mend ;

%ae( %str( AEBDSYCD AEBODSYS               ) , 1 )
%ae( %str( AEBDSYCD AEBODSYS AEPTCD AEDECOD) , 2 )

data  header;
  length OUT1 OUT2 $200.;
  OUT1="Safety Analysis Set";
  OUT2=strip(put(&n1,best.));
run ;

data wk00 ;
  length  out1-out9 $200. ;
  set header 
      out1 (in=a)
      out2 (in=b);
  if  a=1 then out1=strip(AEBODSYS);
  if  b=1 then out1="　"||strip(AEDECOD);
  if  a=1 or b=1 then do;
    OUT2 =strip(put(VAR1 ,best.))||" "||compress(VAR2 );
    OUT3 =strip(put(VAR4 ,best.))||" "||compress(VAR5 );
    OUT4 =strip(put(VAR7 ,best.))||" "||compress(VAR8 );
    OUT5 =strip(put(VAR10,best.))||" "||compress(VAR11);
    OUT6 =strip(put(VAR13,best.))||" "||compress(VAR14);
    OUT7 =strip(put(VAR16,best.))||" "||compress(VAR17);
    OUT8 =strip(put(VAR19,best.))||" "||compress(VAR20);
    OUT9 =strip(put(VAR22,best.))||" "||compress(VAR23);
  end ;
  proc sort ; by AEBODSYS AEDECOD;
run ;

/*** excel output ***/
%let strow = 8;                         *データ部分開始行;
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
%xlsout01(&file.,r&strow.c2:r%eval(&prerow.+&obs.)c10,wk00,OUT1-OUT9);

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
filename sys dde 'excel|system';
%macro line(linest=);
  data _null_;
    file sys;
    put "[workbook.activate(""[INO-Ped-ALL-1_STAT_RES_&file..xlsx]&file."")]";
    put "[select(""r&linest.c2:r&linest.c10"")]";
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

