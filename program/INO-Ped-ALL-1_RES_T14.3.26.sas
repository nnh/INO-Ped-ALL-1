**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_T14.3.26.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create T14.3.26
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
%LET FILE = T14.3.26;

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
%read(advs,SAFFLN);

data  base;
  set  advs;
  if  AVISITN=100 then trtpn=1;
  else if  AVISITN=101 and ATPTN in(1,.) then trtpn=2;
  else if  AVISITN=101 and ATPTN=2       then trtpn=3;
  else if  AVISITN=101 and ATPTN=3       then trtpn=4;
  else if  AVISITN=108 and ATPTN in(1,.) then trtpn=5;
  else if  AVISITN=108 and ATPTN=2       then trtpn=6;
  else if  AVISITN=115 and ATPTN in(1,.) then trtpn=7;
  else if  AVISITN=115 and ATPTN=2       then trtpn=8;
  else if  AVISITN=201 and ATPTN in(1,.) then trtpn=9;
  else if  AVISITN=201 and ATPTN=2       then trtpn=10;
  else if  AVISITN=208 and ATPTN in(1,.) then trtpn=11;
  else if  AVISITN=208 and ATPTN=2       then trtpn=12;
  else if  AVISITN=215 and ATPTN in(1,.) then trtpn=13;
  else if  AVISITN=215 and ATPTN=2       then trtpn=14;
  else if  AVISITN=301 and ATPTN in(1,.) then trtpn=15;
  else if  AVISITN=301 and ATPTN=2       then trtpn=16;
  else if  AVISITN=308 and ATPTN in(1,.) then trtpn=17;
  else if  AVISITN=308 and ATPTN=2       then trtpn=18;
  else if  AVISITN=315 and ATPTN in(1,.) then trtpn=19;
  else if  AVISITN=315 and ATPTN=2       then trtpn=20;
  else if  AVISITN=401 and ATPTN in(1,.) then trtpn=21;
  else if  AVISITN=401 and ATPTN=2       then trtpn=22;
  else if  AVISITN=408 and ATPTN in(1,.) then trtpn=23;
  else if  AVISITN=408 and ATPTN=2       then trtpn=24;
  else if  AVISITN=415 and ATPTN in(1,.) then trtpn=25;
  else if  AVISITN=415 and ATPTN=2       then trtpn=26;
  else if  AVISITN=800 then trtpn=27;
run ;

%macro mean(no,val,med_len,med_put,sd_len,sd_put,min_len,min_put,wh);
  data  main;
    set  base(where=(&wh.)) ;
  run ;

  proc means data = main nway noprint ;
    class trtpn ;
    var   &val ;
    output out = _out&no. n=n mean=mean std=std median=median min=min max=max;
  run ;

  data _out&no.;
    length wk1-wk6 $50.;
    set _out&no.;
    if ^missing(n)        then wk1 =strip(put(n,best.));                                else wk1="-";
    if ^missing(mean)     then wk2 =trim(left(put(round(mean,&med_len.),&med_put.)));   else wk2="-";
    if ^missing(std)      then wk3 =trim(left(put(round(std,&sd_len.),&sd_put.)));      else wk3="-"; 
    if ^missing(min)      then wk4 =trim(left(put(round(min,&min_len.),&min_put.)));    else wk4="-";
    if ^missing(median)   then wk5 =trim(left(put(round(median,&med_len.),&med_put.))); else wk5="-";
    if ^missing(max)      then wk6 =trim(left(put(round(max,&min_len.),&min_put.)));    else wk6="-";
  run;

  proc transpose data=_out&no. out=out&no. prefix=out;
    id  trtpn;
    var wk1 wk2 wk3 wk4 wk5 wk6;
  run;

  data  out&no.;
    length no line 8 out1 $50;
    set  out&no.;
    no = &no.;
    line = input(compress(_name_,"wk"),best.);
  run ;
%mend ;

%MEAN(1  ,AVAL ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="HEIGHT")) ;
%MEAN(2  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="WEIGHT")) ;
%MEAN(3  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="TEMP")) ;
%MEAN(4  ,AVAL ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="DIABP")) ;
%MEAN(5  ,AVAL ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="SYSBP")) ;
%MEAN(6  ,AVAL ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="PULSE")) ;

%MEAN(101,CHG ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="HEIGHT")) ;
%MEAN(102,CHG ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="WEIGHT")) ;
%MEAN(103,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="TEMP")) ;
%MEAN(104,CHG ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="DIABP")) ;
%MEAN(105,CHG ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="SYSBP")) ;
%MEAN(106,CHG ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="PULSE")) ;

data dmy;
  no=.;
run ;
  
data master1;
  set out1(in=a)   dmy dmy out101(in=a)
      out2(in=a)   dmy dmy out102(in=a)
      out3(in=a)   dmy dmy out103(in=a)
      out4(in=a)   dmy dmy out104(in=a)
      out5(in=a)   dmy dmy out105(in=a)
      out6(in=a)   dmy dmy out106(in=a)
;
  if a=1 then do;
    if  out1 ="" then out1 ="-";
    if  out2 ="" then out2 ="-";
    if  out3 ="" then out3 ="-";
    if  out4 ="" then out4 ="-";
    if  out5 ="" then out5 ="-";
    if  out6 ="" then out6 ="-";
    if  out7 ="" then out7 ="-";
    if  out8 ="" then out8 ="-";
    if  out9 ="" then out9 ="-";
    if  out10="" then out10="-";
    if  out11="" then out11="-";
    if  out12="" then out12="-";
    if  out13="" then out13="-";
    if  out14="" then out14="-";
    if  out15="" then out15="-";
    if  out16="" then out16="-";
    if  out17="" then out17="-";
    if  out18="" then out18="-";
    if  out19="" then out19="-";
    if  out20="" then out20="-";
    if  out21="" then out21="-";
    if  out22="" then out22="-";
    if  out23="" then out23="-";
    if  out24="" then out24="-";
    if  out25="" then out25="-";
    if  out26="" then out26="-";
    if  out27="" then out27="-";
  end ;
run ;

%macro mean2(no,val,med_len,med_put,sd_len,sd_put,min_len,min_put,wh);
  data  main;
    set  base(where=(&wh.)) ;
    proc sort nodupkey; by USUBJID;  
  run ;

  proc means data = main nway noprint ;
/*    class trtpn ;*/
    var   &val ;
    output out = _out&no. n=n mean=mean std=std median=median min=min max=max;
  run ;

  data _out&no.;
    length wk1-wk6 $50.;
    set _out&no.;
    if ^missing(n)        then wk1 =strip(put(n,best.));                                else wk1="-";
    if ^missing(mean)     then wk2 =trim(left(put(round(mean,&med_len.),&med_put.)));   else wk2="-";
    if ^missing(std)      then wk3 =trim(left(put(round(std,&sd_len.),&sd_put.)));      else wk3="-"; 
    if ^missing(min)      then wk4 =trim(left(put(round(min,&min_len.),&min_put.)));    else wk4="-";
    if ^missing(median)   then wk5 =trim(left(put(round(median,&med_len.),&med_put.))); else wk5="-";
    if ^missing(max)      then wk6 =trim(left(put(round(max,&min_len.),&min_put.)));    else wk6="-";
  run;

  proc transpose data=_out&no. out=out&no. prefix=out;
/*    id  trtpn;*/
    var wk1 wk2 wk3 wk4 wk5 wk6;
  run;

  data  out&no.;
    length no line 8 out1 $50;
    set  out&no.;
    no = &no.;
    line = input(compress(_name_,"wk"),best.);
  run ;
%mend ;

%MEAN2(201,BASE ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="HEIGHT")) ;
%MEAN2(202,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="WEIGHT")) ;
%MEAN2(203,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="TEMP")) ;
%MEAN2(204,BASE ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="DIABP")) ;
%MEAN2(205,BASE ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="SYSBP")) ;
%MEAN2(206,BASE ,0.1,8.1,0.01,8.2,1,8.,%str(PARAMCD="PULSE")) ;

data  dmy2;
  length out1 $50.;
  out1="-";output;output;output;output;output;output;
run ;

data  master2;
  set  out201 dmy dmy dmy2
       out202 dmy dmy dmy2
       out203 dmy dmy dmy2
       out204 dmy dmy dmy2
       out205 dmy dmy dmy2
       out206 dmy dmy dmy2
;
run ;

%macro tit(no,name);
  data tit_&no.;
    length out1 $200.;
      out1=strip(&name.);output;
      out1=""; output;output;output;output;output;output;output;output;output;output;output;output;output;
  run ;
%mend ;
%tit(1 ,%str('Height (cm)                    '));
%tit(2 ,%str('Weight (kg)                    '));
%tit(3 ,%str('Temperature (C)                '));
%tit(4 ,%str('Diastolic Blood Pressure (mmHg)'));
%tit(5 ,%str('Systolic Blood Pressure (mmHg)  '));
%tit(6 ,%str('Pulse Rate (beats/min)         '));

data  tit;
  set  tit_1-tit_6;
run ;

/*Height (cm) HEIGHT*/
/*Weight (kg) WEIGHT*/
/*Temperature (C) TEMP*/
/*Diastolic Blood Pressure (mmHg) DIABP*/
/*Systolic Blood Pressure (mmHg)  SYSBP*/
/*Pulse Rate (beats/min)  PULSE*/

/*** excel output ***/
%let strow = 7;                         *データ部分開始行;
%let prerow = %eval(&strow. -1);

/*obs*/
proc sql noprint;
   select count (*) into:obs from tit;
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
%xlsout01(&file.,r&strow.c2:r%eval(&prerow.+&obs.)c2,tit,OUT1);
%xlsout01(&file.,r&strow.c5:r%eval(&prerow.+&obs.)c30,master1,OUT2-OUT27);
%xlsout01(&file.,r&strow.c4:r%eval(&prerow.+&obs.)c4,master2,OUT1);

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

