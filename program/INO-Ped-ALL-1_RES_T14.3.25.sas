**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_T14.3.25.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create T14.3.25
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
%LET FILE = T14.3.25;

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
%read(adlb,SAFFLN);

data  base;
  set  adlb;
  if  AVISITN=100 then trtpn=1;
  else if  AVISITN=101 then trtpn=2;
  else if  AVISITN=108 then trtpn=3;
  else if  AVISITN=115 then trtpn=4;
  else if  AVISITN=201 then trtpn=5;
  else if  AVISITN=208 then trtpn=6;
  else if  AVISITN=215 then trtpn=7;
  else if  AVISITN=301 then trtpn=8;
  else if  AVISITN=308 then trtpn=9;
  else if  AVISITN=315 then trtpn=10;
  else if  AVISITN=401 then trtpn=11;
  else if  AVISITN=408 then trtpn=12;
  else if  AVISITN=415 then trtpn=13;
  else if  AVISITN=800 then trtpn=14;
run ;

%macro mean(no,val,med_len,med_put,sd_len,sd_put,min_len,min_put,wh);
  /*max*/
  proc sort data=base(where=(&wh.)) out=max; by USUBJID decending AVAL; run ;
  proc sort data=max nodupkey ; by USUBJID ; run ;

  data  max;
    set  max;
    trtpn=15;
  run ;

  /*min*/
  proc sort data=base(where=(&wh.)) out=min; by USUBJID AVAL; run ;
  proc sort data=min nodupkey ; by USUBJID ; run ;

  data  min;
    set  min;
    trtpn=16;
  run ;

  data  main;
    set  base(where=(&wh.)) max min;
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

%MEAN(1  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="WBC")) ;
%MEAN(2  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="NEUTLE")) ;
%MEAN(3  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="EOSLE")) ;
%MEAN(4  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BASOLE")) ;
%MEAN(5  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="MONOLE")) ;
%MEAN(6  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="LYMLE")) ;
%MEAN(7  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BLASTLE")) ;
%MEAN(8  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="HGB")) ;
%MEAN(9  ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="PLAT")) ;
%MEAN(10 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="SODIUM")) ;
%MEAN(11 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="K")) ;
%MEAN(12 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="MG")) ;
%MEAN(13 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CA")) ;
%MEAN(14 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CREAT")) ;
%MEAN(15 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="ALB")) ;
%MEAN(16 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="ALT")) ;
%MEAN(17 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="AST")) ;
%MEAN(18 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="GLUC")) ;
%MEAN(19 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="PHOS")) ;
%MEAN(20 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BILI")) ;
%MEAN(21 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BILDIR")) ;
%MEAN(22 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="UREAN")) ;
%MEAN(23 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CYURIAC")) ;
%MEAN(24 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="ALP")) ;
%MEAN(25 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="LDH")) ;
%MEAN(26 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="GGT")) ;
%MEAN(27 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="PROT")) ;
%MEAN(28 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="AMYLASE")) ;
%MEAN(29 ,AVAL ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="LIPASET")) ;

%MEAN(101,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="WBC")) ;
%MEAN(102,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="NEUTLE")) ;
%MEAN(103,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="EOSLE")) ;
%MEAN(104,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BASOLE")) ;
%MEAN(105,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="MONOLE")) ;
%MEAN(106,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="LYMLE")) ;
%MEAN(107,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BLASTLE")) ;
%MEAN(108,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="HGB")) ;
%MEAN(109,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="PLAT")) ;
%MEAN(110,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="SODIUM")) ;
%MEAN(111,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="K")) ;
%MEAN(112,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="MG")) ;
%MEAN(113,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CA")) ;
%MEAN(114,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CREAT")) ;
%MEAN(115,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="ALB")) ;
%MEAN(116,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="ALT")) ;
%MEAN(117,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="AST")) ;
%MEAN(118,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="GLUC")) ;
%MEAN(119,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="PHOS")) ;
%MEAN(120,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BILI")) ;
%MEAN(121,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BILDIR")) ;
%MEAN(122,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="UREAN")) ;
%MEAN(123,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CYURIAC")) ;
%MEAN(124,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="ALP")) ;
%MEAN(125,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="LDH")) ;
%MEAN(126,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="GGT")) ;
%MEAN(127,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="PROT")) ;
%MEAN(128,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="AMYLASE")) ;
%MEAN(129,CHG ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="LIPASET")) ;

data dmy;
  no=.;
run ;
  
data master1;
  set out1   dmy dmy out101(in=a)
      out2   dmy dmy out102(in=a)
      out3   dmy dmy out103(in=a)
      out4   dmy dmy out104(in=a)
      out5   dmy dmy out105(in=a)
      out6   dmy dmy out106(in=a)
      out7   dmy dmy out107(in=a)
      out8   dmy dmy out108(in=a)
      out9   dmy dmy out109(in=a)
      out10  dmy dmy out110(in=a)
      out11  dmy dmy out111(in=a)
      out12  dmy dmy out112(in=a)
      out13  dmy dmy out113(in=a)
      out14  dmy dmy out114(in=a)
      out15  dmy dmy out115(in=a)
      out16  dmy dmy out116(in=a)
      out17  dmy dmy out117(in=a)
      out18  dmy dmy out118(in=a)
      out19  dmy dmy out119(in=a)
      out20  dmy dmy out120(in=a)
      out21  dmy dmy out121(in=a)
      out22  dmy dmy out122(in=a)
      out23  dmy dmy out123(in=a)
      out24  dmy dmy out124(in=a)
      out25  dmy dmy out125(in=a)
      out26  dmy dmy out126(in=a)
      out27  dmy dmy out127(in=a)
      out28  dmy dmy out128(in=a)
      out29  dmy dmy out129(in=a);
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

%MEAN2(201,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="WBC")) ;
%MEAN2(202,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="NEUTLE")) ;
%MEAN2(203,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="EOSLE")) ;
%MEAN2(204,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BASOLE")) ;
%MEAN2(205,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="MONOLE")) ;
%MEAN2(206,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="LYMLE")) ;
%MEAN2(207,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BLASTLE")) ;
%MEAN2(208,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="HGB")) ;
%MEAN2(209,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="PLAT")) ;
%MEAN2(210,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="SODIUM")) ;
%MEAN2(211,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="K")) ;
%MEAN2(212,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="MG")) ;
%MEAN2(213,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CA")) ;
%MEAN2(214,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CREAT")) ;
%MEAN2(215,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="ALB")) ;
%MEAN2(216,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="ALT")) ;
%MEAN2(217,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="AST")) ;
%MEAN2(218,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="GLUC")) ;
%MEAN2(219,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="PHOS")) ;
%MEAN2(220,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BILI")) ;
%MEAN2(221,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="BILDIR")) ;
%MEAN2(222,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="UREAN")) ;
%MEAN2(223,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="CYURIAC")) ;
%MEAN2(224,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="ALP")) ;
%MEAN2(225,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="LDH")) ;
%MEAN2(226,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="GGT")) ;
%MEAN2(227,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="PROT")) ;
%MEAN2(228,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="AMYLASE")) ;
%MEAN2(229,BASE ,0.01,8.2,0.001,8.3,0.1,8.1,%str(PARAMCD="LIPASET")) ;

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
       out207 dmy dmy dmy2
       out208 dmy dmy dmy2
       out209 dmy dmy dmy2
       out210 dmy dmy dmy2
       out211 dmy dmy dmy2
       out212 dmy dmy dmy2
       out213 dmy dmy dmy2
       out214 dmy dmy dmy2
       out215 dmy dmy dmy2
       out216 dmy dmy dmy2
       out217 dmy dmy dmy2
       out218 dmy dmy dmy2
       out219 dmy dmy dmy2
       out220 dmy dmy dmy2
       out221 dmy dmy dmy2
       out222 dmy dmy dmy2
       out223 dmy dmy dmy2
       out224 dmy dmy dmy2
       out225 dmy dmy dmy2
       out226 dmy dmy dmy2
       out227 dmy dmy dmy2
       out228 dmy dmy dmy2
       out229 dmy dmy dmy2
;
run ;

%macro tit(no,name);
  data tit_&no.;
    length out1 $200.;
      out1=strip(&name.);output;
      out1=""; output;output;output;output;output;output;output;output;output;output;output;output;output;
  run ;
%mend ;
%tit(1 ,%str('Leukocytes (10^6/L)'));
%tit(2 ,%str('Neutrophils/Leukocytes (%)'));
%tit(3 ,%str('Eosinophils/Leukocytes (%)'));
%tit(4 ,%str('Basophils/Leukocytes (%)'));
%tit(5 ,%str('Monocytes/Leukocytes (%)'));
%tit(6 ,%str('Lymphocytes/Leukocytes (%)'));
%tit(7 ,%str('Blasts/Leukocytes (%)'));
%tit(8 ,%str('Hemoglobin (g/dL)'));
%tit(9 ,%str('Platelets (10^10/L)'));
%tit(10,%str('Sodium (mEq/L)'));
%tit(11,%str('Potassium (mEq/L)'));
%tit(12,%str('Magnesium (mg/dL)'));
%tit(13,%str('Calcium (mg/dL)'));
%tit(14,%str('Creatinine (mg/dL)'));
%tit(15,%str('Albumin (g/dL)'));
%tit(16,%str('Alanine Aminotransferase (IU/L)'));
%tit(17,%str('Aspartate Aminotransferase (IU/L)'));
%tit(18,%str('Glucose (mg/dL)'));
%tit(19,%str('Phosphate (mg/dL)'));
%tit(20,%str('Bilirubin (mg/dL)'));
%tit(21,%str('Direct Bilirubin (mg/dL)	'));
%tit(22,%str('Urea Nitrogen (mg/dL)'));
%tit(23,%str('Uric Acid Crystals (mg/dL)	'));
%tit(24,%str('Alkaline Phosphatase (IU/L)'));
%tit(25,%str('Lactate Dehydrogenase (IU/L)	'));
%tit(26,%str('Gamma Glutamyl Transferase (IU/L)'));
%tit(27,%str('Protein (g/dL)'));
%tit(28,%str('Amylase (IU/L)	'));
%tit(29,%str('Lipase (IU/L)'));

data  tit;
  set  tit_1-tit_29;
run ;
/*Leukocytes (10^6/L)            	  WBC*/
/*Neutrophils/Leukocytes (%)	      NEUTLE*/
/*Eosinophils/Leukocytes (%)	      EOSLE*/
/*Basophils/Leukocytes (%)	        BASOLE*/
/*Monocytes/Leukocytes (%)      	  MONOLE*/
/*Lymphocytes/Leukocytes (%)	      LYMLE*/
/*Blasts/Leukocytes (%)	            BLASTLE*/
/*Hemoglobin (g/dL)	                HGB*/
/*Platelets (10^10/L)	              PLAT*/
/*Sodium (mEq/L)	                  SODIUM*/
/*Potassium (mEq/L)              	  K*/
/*Magnesium (mg/dL)	                MG*/
/*Calcium (mg/dL)	                  CA*/
/*Creatinine (mg/dL)	              CREAT*/
/*Albumin (g/dL)	                  ALB*/
/*Alanine Aminotransferase (IU/L)	  ALT*/
/*Aspartate Aminotransferase (IU/L)	AST*/
/*Glucose (mg/dL)	                  GLUC*/
/*Phosphate (mg/dL)               	PHOS*/
/*Bilirubin (mg/dL)	                BILI*/
/*Direct Bilirubin (mg/dL)	        BILDIR*/
/*Urea Nitrogen (mg/dL)	            UREAN*/
/*Uric Acid Crystals (mg/dL)	      CYURIAC*/
/*Alkaline Phosphatase (IU/L)	      ALP*/
/*Lactate Dehydrogenase (IU/L)	    LDH*/
/*Gamma Glutamyl Transferase (IU/L)	GGT*/
/*Protein (g/dL)	                  PROT*/
/*Amylase (IU/L)                  	AMYLASE*/
/*Lipase (IU/L)	                    LIPASET*/



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
%xlsout01(&file.,r&strow.c5:r%eval(&prerow.+&obs.)c19,master1,OUT2-OUT16);
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

