**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_L16.2.7.1.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210114
*
* Purpose           : Create L16.2.7.1
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
%LET FILE = L16.2.7.1;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_RES_LIBNAME.sas";

%XLSREAD(INO-Ped-ALL-1_LB_Normal Range_20201228.xlsx,ADLB_Normal Range_age,LB1,13,RNUM=2,READLIB=&EXT.,CNUMST=1);
%XLSREAD(Site_Ref_Value.xlsx,Sheet,SLB1,8,RNUM=2,READLIB=&EXT.,CNUMST=1);

/*** Template Open ***/
%XLSOPEN(INO-Ped-ALL-1_STAT_RES_&FILE..xlsx);

/*** Format ***/
proc format;
run;

/*** Input ***/
data  wk11;
  set  libraw.adlb;
run ;

data  lb2;
  set  lb1;
  rename COL3=PARAMCD;
  rename COL6=SEX;
  AGE=input(COL7,best.);
  LLN=input(COL9,best.)*input(COL13,best.);
  ULN=input(COL10,best.)*input(COL13,best.);
  keep COL3 COL6 LLN ULN AGE;
run ;

data  lb_sex;
  set  lb2;
  if  ^missing(SEX) ;
  rename LLN=LLN1;
  rename ULN=ULN1;
run ;

data  lb_nsex;
  set  lb2;
  if  missing(SEX) ;
  rename LLN=LLN2;
  rename ULN=ULN2;
  drop SEX;
run ;

data  slb_sex;
  set  slb1;
  rename COL6=PARAMCD;
  rename COL3=SEX;
  SITEID=input(COL1,best.);
  LLN3=input(COL7,best.);
  ULN3=input(COL8,best.);
  keep SITEID COL3 COL6 LLN3 ULN3;
run ;

proc sort data=slb_sex ; by SITEID PARAMCD SEX; run ;
proc sort data=wk11 ; by SITEID PARAMCD SEX; run ;

data  wk12;
  merge  wk11(in=a) slb_sex;
  by  SITEID PARAMCD SEX;
  if a;
run ;

proc sort data=lb_sex ; by PARAMCD SEX AGE; run ;
proc sort data=wk12 ; by PARAMCD SEX AGE; run ;

data  wk13;
  merge  wk12(in=a) lb_sex;
  by  PARAMCD SEX AGE;
  if a;
run ;

proc sort data=lb_nsex ; by PARAMCD AGE; run ;
proc sort data=wk13 ; by PARAMCD AGE; run ;

data  wk14;
  merge  wk13(in=a) lb_nsex;
  by  PARAMCD AGE;
  if a;
run ;

data  wk10;
  set  wk14;
  if  AVAL>ULN1>. then FLG="H";
  if  .<AVAL<LLN1 then FLG="L";
  if  AVAL>ULN2>. then FLG="H";
  if  .<AVAL<LLN2 then FLG="L";
  if  AVAL>ULN3>. then FLG="H";
  if  .<AVAL<LLN3 then FLG="L";
run ;

%macro RP(outf,wh);
  data &outf.;
    set  wk10;
    if  PARAMCD="&wh.";
    rename AVAL=&outf.;
    rename FLG=&outf._F;
    keep AVISITN AVISIT USUBJID SUBJID SEX AVAL FLG;
  run ;
  proc sort data=&outf.; by USUBJID AVISITN; run;

%mend ;
%rp(out1 ,%str(WBC));
%rp(out2 ,%str(NEUTLE));
%rp(out3 ,%str(EOSLE));
%rp(out4 ,%str(BASOLE));
%rp(out5 ,%str(MONOLE));
%rp(out6 ,%str(LYMLE));
%rp(out7 ,%str(BLASTLE));
%rp(out8 ,%str(HGB));
%rp(out9 ,%str(PLAT));
%rp(out10,%str(SODIUM));
%rp(out11,%str(K));
%rp(out12,%str(MG));
%rp(out13,%str(CA));
%rp(out14,%str(CREAT));
%rp(out15,%str(ALB));
%rp(out16,%str(ALT));
%rp(out17,%str(AST));
%rp(out18,%str(GLUC));
%rp(out19,%str(PHOS));
%rp(out20,%str(BILI));
%rp(out21,%str(BILDIR));
%rp(out22,%str(UREAN));
%rp(out23,%str(CYURIAC));
%rp(out24,%str(ALP));
%rp(out25,%str(LDH));
%rp(out26,%str(GGT));
%rp(out27,%str(PROT));
%rp(out28,%str(AMYLASE));
%rp(out29,%str(LIPASET));

data  wk20;
  merge  out1-out29;
  by  USUBJID AVISITN;
run ;

data  wk00;
  set  wk20;
  by  USUBJID;
  if  first.USUBJID=0 then do;
    SUBJID="";
    SEX="";
  end ;
run ;

/*** excel output ***/
%let strow = 6;                         *ƒf[ƒ^•”•ªŠJŽns;
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
%xlsout01(&file.,r&strow.c2:r%eval(&prerow.+&obs.)c62,wk00,SUBJID SEX AVISIT
out1  out1_F out2  out2_F out3  out3_F out4  out4_F out5  out5_F out6  out6_F
out7  out7_F out8  out8_F out9  out9_F out10 out10_F out11 out11_F out12 out12_F
out13 out13_F out14 out14_F out15 out15_F out16 out16_F out17 out17_F out18 out18_F
out19 out19_F out20 out20_F out21 out21_F out22 out22_F out23 out23_F out24 out24_F
out25 out25_F out26 out26_F out27 out27_F out28 out28_F out29 out29_F );

/*footer*/
/*data footer;*/
/*   length out1 $200.;*/
/*   out1 = "*’†Ž~ŽžŠú = ’†Ž~“ú - “Š—^ŠJŽn“ú + 1"; output;*/
/*run;*/

/*%xlsout01(&file.,r%eval(&strow.+&obs.+1)c2:r%eval(&strow.+&obs.+1)c2,footer,out1);*/

/*line*/
filename sys dde 'excel|system';
%macro line(linest=);
  data _null_;
    file sys;
    put "[workbook.activate(""[INO-Ped-ALL-1_STAT_RES_&file..xlsx]&file."")]";
    put "[select(""r&linest.c2:r&linest.c62"")]";
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

