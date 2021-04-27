**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_T14.2.5.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create T14.2.5
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
%LET FILE = T14.2.5;

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
%read(adtte,PPSFLN);

data  base;
  set  adtte;
  if  PARAMCD="OS" and AHSCT="Y";
run ;

ods graphics; 
ods listing gpath=".";
ods graphics/reset border=off;
ods output SurvivalPlot=Survivalplot Quartiles=Quartiles CensoredSummary=CensoredSummary ;

proc lifetest data=base atrisk plots=s(atrisk=0 to 270 by 30 cl); 
 Time AVAL*CNSR(1); 
/* strata Cell; */
run; 

*------------------------------------*; 
*-- データハンドリング              --*; 
*------------------------------------*; 

*==================================================*; 
* リスク集合出力時間間隔 ; 
%let TimeInterval=30; 
*==================================================*; 
* リスク集合の出力最大時間; 
%let TimeMax=270; 
*==================================================*; 
* 群の数; 
%let ArmNum=1; 
*==================================================*; 
* フォーマット ; 
proc format; 
 value Cellf 1='Level 1'; 
run; 
*==================================================*; 
* データセットSurvivalplotからSurvivalplot2の作成 ; 
data form; 
  do StratumNum=1 to &ArmNum.;
    do time=0 to &TimeMax by &TimeInterval;
      output;
    end;
  end;
run ;

data atrisk0;
  merge form Survivalplot; 
  by StratumNum time;
run ; 

data Survivalplot2; 
  set atrisk0; 
  if AtRisk=. then do;
    AtRisk=0; tAtRisk=time; 
  end; 
  Survival=Survival*100;
  Censored=Censored*100;
run;

ods graphics on / height = 10cm width = 15cm imagename = 'T14_2_5'
  outputfmt = png reset = index   antialiasmax=96100;
ods listing gpath = "&output.\KM" image_dpi = 300 ;

proc sgplot data=Survivalplot2 noautolegend; 
 step x=Time y=Survival / group=StratumNum name='Survaival Probability (%)'; 
 scatter x=Time y=Censored  
/ group=StratumNum markerattrs=(symbol=plus); 
 xaxistable AtRisk / x=tAtRisk class=StratumNum  title="Number at risk"; 
 keylegend 'Survaival Probability (%)' 
/ location=outside noborder position=bottom; 
 yaxis values=(0 to 100 by 10) label='Survaival Probability (%)'; 
 xaxis values=(0 to &TimeMax by &TimeInterval) label='Period from the first day of treatment (Day)';  format StratumNum Cellf.; 
 refline 180 / axis=x lineattrs=(color=gray pattern=2);
run; 

data  master1;
  length OUT1 OUT2 LL UL $200.;
  set Quartiles;
  OUT1=strip(put(Estimate,8.3));
  if  OUT1="" then OUT1="-";
  LL=strip(put(LowerLimit,8.3));
  if  LL="" or Estimate=. then LL="-";
  UL=strip(put(UpperLimit,8.3));
  if  UL=""  or Estimate=. then UL="-";
  OUT2=strip(LL)||"～"||strip(UL);
run ;

data  master2;
  length OUT1-OUT3 $200.;
  set  Censoredsummary;
  OUT1=strip(put(Total,8.));
  OUT2=strip(put(Failed,8.));
  OUT3=strip(put(Censored,8.));
run ;

data  master3;
  length OUT1 OUT2 LL UL $200.;
  set  Survivalplot2;
  if  Time<180 and ^missing(Survival);
  OUT1=strip(put(Survival,8.3));
  LL=strip(put(SDF_LCL,8.3));
  if  LL="" then LL="-";
  UL=strip(put(SDF_UCL,8.3));
  if  UL="" then UL="-";
  OUT2=strip(LL)||"～"||strip(UL);
run ;

proc sort data=master3 ; by decending Time; run ;
proc sort data=master3 nodupkey ; by STRATUM; run ;

/*** excel output ***/
filename sys dde 'excel|system';
data _null_;
  file sys;
  put '[select("r6c2")]';
  put "[insert.picture(""&output.\KM\T14_2_5.png"")]";
run ;


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
%xlsout01(&file.,r34c3:r36c4,master1,OUT1-OUT2);
%xlsout01(&file.,r35c6:r35c8,master2,OUT1-OUT3);
%xlsout01(&file.,r40c3:r40c4,master3,OUT1-OUT2);

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

