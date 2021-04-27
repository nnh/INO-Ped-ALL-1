**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_RES_F10.1.1.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210114
*
* Purpose           : Create F10.1.1
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
%LET FILE = F10.1.1;

%INCLUDE "&_PATH2.\INO-Ped-ALL-1_RES_LIBNAME.sas";

/*** Template Open ***/
%XLSOPEN(INO-Ped-ALL-1_STAT_RES_&FILE..xlsx);

/*** Format ***/
proc format;
run;

/*** Input ***/
%macro val(VAR, WHERE, DB=libraw.adsl, KEY=USUBJID);
  %global &VAR.;
  proc sql noprint;
    select count(distinct &KEY) into: &VAR.
    from &DB.
    where &WHERE.;
  quit;
  %put ************** &VAR. = &&&VAR..;
%mend;

%val(REG   , %str(USUBJID^=""));    
%val(NELI  , %str(IETESTCD^=""));    
%val(ELI   , %str(IETESTCD=""));  
%val(NTRE  , %str(IETESTCD="" and TRTSDT=.));  
%val(TRE   , %str(IETESTCD="" and TRTSDT^=.));  
%val(NCOM  , %str(IETESTCD="" and ^missing(TRTSDT) and COMPLFL='N'));  
%val(COM   , %str(IETESTCD="" and ^missing(TRTSDT) and COMPLFL='Y'));  

data  master; 
  REG  = strip(put(&REG  ,best.));
  NELI = strip(put(&NELI ,best.));
  ELI  = strip(put(&ELI  ,best.));
  NTRE = strip(put(&NTRE ,best.));
  TRE  = strip(put(&TRE  ,best.));
  NCOM = strip(put(&NCOM ,best.));
  COM  = strip(put(&COM  ,best.));
run ;


/*** excel output ***/
%macro xlsout01(sht,range,ds,var,jdg);

   filename xls dde "excel |\\[INO-Ped-ALL-1_STAT_RES_&file..xlsx]&sht.!&range";

   data _null_;
      file xls notab lrecl=10000 dsd dlm='09'x;
      set &ds.;
      dmy = "";
      &jdg.;
      put &var.;
   run;

%mend;

%xlsout01(&file.,r5c3:r5c3  ,master,REG  );
%xlsout01(&file.,r6c3:r6c3  ,master,REG  );
%xlsout01(&file.,r9c8:r9c8  ,master,NELI );
%xlsout01(&file.,r10c8:r10c8  ,master,NELI );
%xlsout01(&file.,r11c8:r11c8  ,master,NELI );
%xlsout01(&file.,r13c3:r13c3,master,ELI  );
%xlsout01(&file.,r14c3:r14c3,master,ELI  );
%xlsout01(&file.,r17c8:r17c8,master,NTRE );
%xlsout01(&file.,r18c8:r18c8,master,NTRE );
%xlsout01(&file.,r20c3:r20c3,master,TRE  );
%xlsout01(&file.,r21c3:r21c3,master,TRE  );
%xlsout01(&file.,r24c8:r24c8,master,NCOM );
%xlsout01(&file.,r25c8:r25c8,master,NCOM );
%xlsout01(&file.,r26c8:r26c8,master,NCOM );
%xlsout01(&file.,r28c3:r28c3,master,COM  );
%xlsout01(&file.,r29c3:r29c3,master,COM  );

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
    put "[select(""r&linest.c2:r&linest.c8"")]";
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

