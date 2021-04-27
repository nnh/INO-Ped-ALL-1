**********************************************************************;
* Project           : INO-Ped-ALL-1
*
* Program name      : INO-Ped-ALL-1_Final.sas
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
   data payroll;
     time_slept=sleep(3,1);
   run;

  dm 'output; clear; log; clear;';
%MEND ;

/*** ÉvÉçÉOÉâÉÄì«Ç›çûÇ› ***/
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_F10.1.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_F14.3.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.1.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.1.2.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.2.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.3.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.4.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.5.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.6.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.7.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.7.2.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.7.3.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.7.4.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_L16.2.7.5.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T10.1.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T10.2.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T11.1.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T11.3.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T11.3.2.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T11.3.3.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T11.3.4.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T11.3.5.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.1.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.1.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.1.2.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.2.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.2.2.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.2.3.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.3.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.3.2.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.4.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.5.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.6.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.7.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.8.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.2.9.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.1.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.10.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.11.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.12.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.13.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.14.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.15.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.16.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.17.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.18.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.19.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.2.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.20.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.21.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.22.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.23.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.24.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.25.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.26.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.27.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.28.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.29.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.30.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.3.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.4.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.5.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.6.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.7.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.8.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_RES_T14.3.9.sas" / source2 ;

*-- end of program --*;


