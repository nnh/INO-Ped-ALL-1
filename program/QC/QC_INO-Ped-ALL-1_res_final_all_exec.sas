**************************************************************************
Program Name : QC_INO-Ped-ALL-1_res_final_all_exec.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-4-19
SAS version : 9.4
**************************************************************************;
%macro WAIT_TO_EXEC();
    data _NULL_;
        rc=sleep(10);
    run;
%mend WAIT_TO_EXEC;
* *** INO-Ped-ALL-1 programs for result summary start ***; 
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T10.1.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_F10.1.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T10.2.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T11.3.2.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T11.3.3.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T11.3.4.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.1.2.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.2.2.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.2.3.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.3.2.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.5.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.6.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.2.8.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.2.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.3.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.4.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.5.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.7.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.8.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.9.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.10.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.12.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.13.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.14.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.15.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.17.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.18.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.19.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.20.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.25.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.26.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.27.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_T14.3.30.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.2.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.3.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.4.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.5.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.7.1.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.7.2.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.7.3.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.7.4.sas" / SOURCE2;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_RES_L16.2.7.5.sas" / SOURCE2;
* *** INO-Ped-ALL-1 programs for result summary end ***; 
