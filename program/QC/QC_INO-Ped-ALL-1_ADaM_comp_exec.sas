**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADaM_comp_exec.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-1-7
SAS version : 9.4
**************************************************************************;
libname libcomp "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC" ACCESS=READONLY;
%inc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\program\QC\QC_INO-Ped-ALL-1_ADaM_comp.sas";
*%compare_ds(adsl);
*%compare_ds(adae);
*%compare_ds(adcm);
*%compare_ds(adpr);
*%compare_ds(admh);
*%compare_ds(adec);
*%compare_ds(adrs);
*%compare_ds(adlb);
*%compare_ds(adeg);
*%compare_ds(advs);
*%compare_ds(adds);
*%compare_ds(adfa);
%compare_ds(adtte);
