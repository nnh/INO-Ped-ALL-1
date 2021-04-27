**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_T11.3.1.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create T11.3.1
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
%LET FILE = T11.3.1;

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
%read(adec,SAFFLN);

/***Macro***/
%macro mean(no,val,med_len,med_put,sd_len,sd_put,min_len,min_put,where);
  proc means data = adec(where=(&where.)) nway noprint ;
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

%MEAN(01 ,AVAL ,0.1,8.1,0.01,8.2,1.,8.,%str(PARAMCD="DURTRT")) ;
%MEAN(02 ,AVAL ,0.1,8.1,0.01,8.2,1.,8.,%str(PARAMCD="DURFLU")) ;
%MEAN(03 ,AVAL ,0.1,8.1,0.01,8.2,1.,8.,%str(PARAMCD="CYCN")) ;
%MEAN(04 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="TOTDOS")) ;
%MEAN(05 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CYCDOS" and AVISITN=200)) ;
%MEAN(06 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CYCDOS" and AVISITN=300)) ;
%MEAN(07 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CYCDOS" and AVISITN=400)) ;
%MEAN(08 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CYCDOS" and AVISITN=500)) ;
%MEAN(09 ,AVAL ,0.001,8.3,0.0001,8.4,0.01,8.2,%str(PARAMCD="RDI")) ;
%MEAN(10 ,AVAL ,0.001,8.3,0.0001,8.4,0.01,8.2,%str(PARAMCD="CYCRDI" and AVISITN=200)) ;
%MEAN(11 ,AVAL ,0.001,8.3,0.0001,8.4,0.01,8.2,%str(PARAMCD="CYCRDI" and AVISITN=300)) ;
%MEAN(12 ,AVAL ,0.001,8.3,0.0001,8.4,0.01,8.2,%str(PARAMCD="CYCRDI" and AVISITN=400)) ;
%MEAN(13 ,AVAL ,0.001,8.3,0.0001,8.4,0.01,8.2,%str(PARAMCD="CYCRDI" and AVISITN=500)) ;

data  wk00;
  set  out01-out13 ;
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
%xlsout01(&file.,r&strow.c4:r%eval(&prerow.+&obs.)c4,wk00,OUT1);

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

