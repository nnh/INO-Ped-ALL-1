**********************************************************************;
* Project           : Macro
*
* Program name      : XLSOPEN.sas
*
* Author            : MATSUO YAMAMOTO
*
* Date created      : 20151108
*
* Purpose           :
*
* Revision History  :
*
* Date        Author           Ref    Revision (Date in YYYYMMDD format)
* YYYYMMDD    XXXXXX XXXXXXXX  1      XXXXXXXXXXXXXXXXXXXXXXXXXXXX
*
**********************************************************************;

%MACRO XLSOPEN(XLSBOOK);

   OPTIONS NOXSYNC NOXWAIT;
   X "'&Template\&XLSBOOK.'" ;

   data payroll;
     time_slept=sleep(10,1);
   run;

%MEND XLSOPEN;
