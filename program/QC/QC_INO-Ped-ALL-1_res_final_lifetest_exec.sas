**************************************************************************
Program Name : QC_INO-Ped-ALL-1_res_final_all_exec.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-4-21
SAS version : 9.4
**************************************************************************;
%macro WAIT_TO_EXEC();
    data _NULL_;
        rc=sleep(10);
    run;
%mend WAIT_TO_EXEC;
* *** INO-Ped-ALL-1 programs for result summary start ***; 
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.4.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.5.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.6.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.7.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.8.sas" / SOURCE2;
* *** INO-Ped-ALL-1 programs for result summary end ***; 
