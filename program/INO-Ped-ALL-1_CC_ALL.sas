**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_ADS_All.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20210105
*
* Purpose           :
*
* Revision History  :
*
* Date        Author           Ref    Revision (Date in YYYYMMDD format)
* YYYYMMDD    XXXXXX XXXXXXXX  1      XXXXXXXXXXXXXXXXXXXXXXXXXXXX
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

%LET PROJ = %CURRENT_DIR;
%MACRO CLE;
  dm 'output; clear; log; clear;';
%MEND ;

/*** ÉvÉçÉOÉâÉÄì«Ç›çûÇ› ***/
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_CC_Figure1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_CC_Table1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_CC_Table2.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_CC_Table4.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_CC_Table5.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_CC_Table6.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_CC_Table7.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_CC_Table8.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_CC_Table9.sas" / source2 ;

*-- end of program --*;
