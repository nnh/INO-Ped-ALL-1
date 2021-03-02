**************************************************************************
Program Name : QC_INO-Ped-ALL-1_res_all_exec.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-3-2
SAS version : 9.4
**************************************************************************;
%macro WAIT_TO_EXEC();
    data _NULL_;
        rc=sleep(10);
    run;
%mend WAIT_TO_EXEC;
* *** INO-Ped-ALL-1 programs for result summary start ***; 
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T11.1.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.1.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T11.3.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T11.3.5.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.1.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.2.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.3.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.4.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.7.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.9.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.6.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.11.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.16.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.21.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.22.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.23.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.24.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.28.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.29.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.1.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.1.2.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.6.1.sas" / SOURCE2;
* *** INO-Ped-ALL-1 programs for result summary end ***; 
