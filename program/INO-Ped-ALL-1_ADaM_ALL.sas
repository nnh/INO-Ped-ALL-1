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
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADAE.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADCM.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADDS.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADEC.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADEG.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADFA.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADLB.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADMH.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADPR.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADRS.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADSL.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADTTE.sas" / source2 ;
%CLE;%inc "&PROJ.\INO-Ped-ALL-1_ADaM_ADVS.sas" / source2 ;

*-- end of program --*;
