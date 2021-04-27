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
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.1.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.1.2.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.6.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T11.1.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T11.3.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T11.3.5.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.1.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.1.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.2.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.3.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.4.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.7.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.9.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.6.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.11.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.16.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.21.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.22.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.23.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.24.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.28.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.29.sas" / source2 ;

*-- end of program --*;
