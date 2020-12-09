**********************************************************************;
* Project           : INO-Ped-ALL-1_SDTM_LIBNAME
*
* Program name      : INO-Ped-ALL-1_SDTM_LIBNAME.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20201201
*
* Purpose           :
*
* Revision History  :
*
* Date        Author           Ref    Revision (Date in YYYYMMDD format)
* YYYYMMDD    XXXXXX XXXXXXXX  1      XXXXXXXXXXXXXXXXXXXXXXXXXXXX
*
**********************************************************************;

/*** initial setting ***/
proc datasets library = work kill nolist; quit;

%macro working_dir;

    %local _fullpath _path;
    %let   _fullpath = ;
    %let   _path     = ;

    %if %length(%sysfunc(getoption(sysin))) = 0 %then
        %let _fullpath = %sysget(sas_execfilepath);
    %else
        %let _fullpath = %sysfunc(getoption(sysin));

    %let _path = %substr(   &_fullpath., 1, %length(&_fullpath.)
                          - %length(%scan(&_fullpath.,-1,'\'))
                          - %length(%scan(&_fullpath.,-2,'\'))
                          - 2 );

    &_path.

%mend working_dir;

%let _wk_path = %working_dir;

libname libraw  "&_wk_path.\input\rawdata"  access = readonly;
libname libext  "&_wk_path.\input\ext"      access = readonly;
libname libout  "&_wk_path.\input\sdtm";

%let output = &_wk_path.\input\sdtm ;
%let log = &_wk_path.\log\sdtm;
%let ext = &_wk_path.\input\ext;
%let raw = &_wk_path.\input\rawdata;

options  validvarname=v7
         fmtsearch = (libout work)
         sasautos = ("&_wk_path.\program\macro") cmdmac
         nofmterr
         nomlogic nosymbolgen nomprint
         ls = 100 missing = "" pageno = 1;

/*** end ***/
