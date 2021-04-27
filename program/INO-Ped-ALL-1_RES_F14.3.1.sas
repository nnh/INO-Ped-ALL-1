**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_STAT_F14.3.1.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210127
*
* Purpose           : Create F14.3.1
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
%LET FILE = F14.3.1;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_RES_LIBNAME.sas";

/*** Template Open ***/
%XLSOPEN(INO-Ped-ALL-1_STAT_RES_&FILE..xlsx);

/*** Format ***/
proc format ;
  value trtpnf 
    1="Screening" 
    2="C1D1" 
    3="C1D8" 
    4="C1D15" 
    5="C2D1" 
    6="C2D8" 
    7="C2D15" 
    8="C3D1" 
    9="C3D8" 
    10="C3D15" 
    11="C4D1" 
    12="C4D8" 
    13="C4D15" 
    14="Follow-UP" 
;
run ;

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
  format trtpn trtpnf.;
run ;

%macro lb(name,par,parl);

  ods graphics on / height = 10cm width = 15cm imagename = "&name."
    outputfmt = png reset = index   antialiasmax=96100;
  ods listing gpath = "&output.\LB" image_dpi = 300 ;

  proc sgplot data=base(where=(PARAMCD="&par.")) ;
    styleattrs
    datacolors =(blue red green orange brown pink)
    ;
    vline trtpn / response =AVAL group =SUBJID
    groupdisplay=cluster 
    markers ;

    xaxis type=discrete /*offsetmin=0.2 offsetmax=0.2*/
    display=(nolabel) tickvalueformat=trtpnf. ;

    yaxis offsetmin=0.05 offsetmax=0.2
   
    label="&parl.";

    keylegend / down=2 location=inside position=topright title="Subject ID" ;
  run ;

%mend;

%lb(F1 ,%str(WBC) ,%str(Leukocytes (10^6/L))) ;
%lb(F2 ,%str(NEUTLE),%str(Neutrophils/Leukocytes (Åì))) ;
%lb(F3 ,%str(EOSLE) ,%str(Eosinophils/Leukocytes (Åì))) ;
%lb(F4 ,%str(BASOLE) ,%str(Basophils/Leukocytes (Åì))) ;
%lb(F5 ,%str(MONOLE) ,%str(Monocytes/Leukocytes (Åì))) ;
%lb(F6 ,%str(LYMLE) ,%str(Lymphocytes/Leukocytes (Åì))) ;
%lb(F7 ,%str(BLASTLE) ,%str(Blasts/Leukocytes (Åì))) ;
%lb(F8 ,%str(HGB) ,%str(Hemoglobin (g/dL))) ;
%lb(F9 ,%str(PLAT) ,%str(Platelets (10^10/L))) ;
%lb(F10,%str(SODIUM),%str(Sodium (mEq/L))) ;
%lb(F11,%str(K),%str(Potassium (mEq/L))) ;
%lb(F12,%str(MG),%str(Magnesium (mg/dL))) ;
%lb(F13,%str(CA),%str(Calcium (mg/dL))) ;
%lb(F14,%str(CREAT),%str(Creatinine (mg/dL))) ;
%lb(F15,%str(ALB),%str(Albumin (g/dL))) ;
%lb(F16,%str(ALT),%str(Alanine Aminotransferase (IU/L))) ;
%lb(F17,%str(AST),%str(Aspartate Aminotransferase (IU/L))) ;
%lb(F18,%str(GLUC),%str(Glucose (mg/dL))) ;
%lb(F19,%str(PHOS),%str(Phosphate (mg/dL))) ;
%lb(F20,%str(BILI),%str(Bilirubin (mg/dL))) ;
%lb(F21,%str(BILDIR),%str(Direct Bilirubin (mg/dL)));
%lb(F22,%str(UREAN),%str(Urea Nitrogen (mg/dL)));
%lb(F23,%str(CYURIAC),%str(Uric Acid Crystals (mg/dL)));
%lb(F24,%str(ALP),%str(Alkaline Phosphatase (IU/L)));
%lb(F25,%str(LDH),%str(Lactate Dehydrogenase (IU/L)));
%lb(F26,%str(GGT),%str(Gamma Glutamyl Transferase (IU/L)));
%lb(F27,%str(PROT),%str(Protein (g/dL)));
%lb(F28,%str(AMYLASE),%str(Amylase (IU/L)));
%lb(F29,%str(LIPASET),%str(Lipase (IU/L)));

/*** excel output ***/

filename sys dde 'excel|system';
data _null_;
  file sys;
  put '[select("r6c2")]';
  put "[insert.picture(""&output.\LB\F1.png"")]";

  put '[select("r6c12")]';
  put "[insert.picture(""&output.\LB\F2.png"")]";

  put '[select("r32c2")]';
  put "[insert.picture(""&output.\LB\F3.png"")]";

  put '[select("r32c12")]';
  put "[insert.picture(""&output.\LB\F4.png"")]";

  put '[select("r58c2")]';
  put "[insert.picture(""&output.\LB\F5.png"")]";

  put '[select("r58c12")]';
  put "[insert.picture(""&output.\LB\F6.png"")]";

  put '[select("r84c2")]';
  put "[insert.picture(""&output.\LB\F7.png"")]";

  put '[select("r84c12")]';
  put "[insert.picture(""&output.\LB\F8.png"")]";

  put '[select("r110c2")]';
  put "[insert.picture(""&output.\LB\F9.png"")]";

  put '[select("r110c12")]';
  put "[insert.picture(""&output.\LB\F10.png"")]";

  put '[select("r136c2")]';
  put "[insert.picture(""&output.\LB\F11.png"")]";

  put '[select("r136c12")]';
  put "[insert.picture(""&output.\LB\F12.png"")]";

  put '[select("r162c2")]';
  put "[insert.picture(""&output.\LB\F13.png"")]";

  put '[select("r162c12")]';
  put "[insert.picture(""&output.\LB\F14.png"")]";

  put '[select("r188c2")]';
  put "[insert.picture(""&output.\LB\F15.png"")]";

  put '[select("r188c12")]';
  put "[insert.picture(""&output.\LB\F16.png"")]";

  put '[select("r214c2")]';
  put "[insert.picture(""&output.\LB\F17.png"")]";

  put '[select("r214c12")]';
  put "[insert.picture(""&output.\LB\F18.png"")]";

  put '[select("r240c2")]';
  put "[insert.picture(""&output.\LB\F19.png"")]";

  put '[select("r240c12")]';
  put "[insert.picture(""&output.\LB\F20.png"")]";

  put '[select("r266c2")]';
  put "[insert.picture(""&output.\LB\F21.png"")]";

  put '[select("r266c12")]';
  put "[insert.picture(""&output.\LB\F22.png"")]";

  put '[select("r292c2")]';
  put "[insert.picture(""&output.\LB\F23.png"")]";

  put '[select("r292c12")]';
  put "[insert.picture(""&output.\LB\F24.png"")]";

  put '[select("r318c2")]';
  put "[insert.picture(""&output.\LB\F25.png"")]";

  put '[select("r318c12")]';
  put "[insert.picture(""&output.\LB\F26.png"")]";

  put '[select("r344c2")]';
  put "[insert.picture(""&output.\LB\F27.png"")]";

  put '[select("r344c12")]';
  put "[insert.picture(""&output.\LB\F28.png"")]";

  put '[select("r370c2")]';
  put "[insert.picture(""&output.\LB\F29.png"")]";

run ;

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

