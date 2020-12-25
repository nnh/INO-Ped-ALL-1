**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADaM_comp.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-x-x
SAS version : 9.4
**************************************************************************;
proc datasets library=work kill nolist; quit;
options mprint mlogic symbolgen;
%let out_comp_path=C:\Users\Mariko\Desktop;
libname libtgt "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\input\ads" ACCESS=READONLY;
libname libtgtqc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\input\ads\QC" ACCESS=READONLY;
%macro compare_ds(targetfile);
    data &targetfile.;
        set libtgt.&targetfile.;
    run;
    data QC_&targetfile.;
        set libtgtqc.&targetfile.;
    run;
    proc printto print="&out_comp_path.\compare_&targetfile..txt" new; run;
      proc compare base=&targetfile. compare=QC_&targetfile. out=Result_&targetfile. listall; run;
    proc printto; run;
%mend compare_ds;
%compare_ds(adae);
