**************************************************************************
Program Name : QC_INO-Ped-ALL-1_res_all_exec.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-2-22
SAS version : 9.4
**************************************************************************;
%macro WAIT_TO_EXEC();
    data _NULL_;
        rc=sleep(10);
    run;
%mend WAIT_TO_EXEC;
* *** INO-Ped-ALL-1 programs for result summary start ***; 
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T11.1.1.sas" / SOURCE2;
* *** INO-Ped-ALL-1 programs for result summary end ***; 
