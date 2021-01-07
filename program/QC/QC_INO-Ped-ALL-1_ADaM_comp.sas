**************************************************************************
Program Name : QC_INO-Ped-ALL-1_ADaM_comp.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2020-1-7
SAS version : 9.4
**************************************************************************;
proc datasets library=work kill nolist; quit;
options mprint mlogic symbolgen;
%let out_comp_path=\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\compare\ads;
libname libtgt "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\input\ads" ACCESS=READONLY;
libname libtgtqc "\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\input\ads\QC" ACCESS=READONLY;
DATA _NULL_ ;
    CALL SYMPUT( "_YYMM_" , COMPRESS( PUT( DATE() , YYMMDDN8. ) ) ) ;
    CALL SYMPUT( "_TIME_" , COMPRESS( PUT( TIME() , TIME5. ) , " :" ) ) ;
RUN ;
%macro compare_ds(targetfile);
    data &targetfile.;
        set libtgt.&targetfile.;
    run;
    data QC_&targetfile.;
        set libtgtqc.&targetfile.;
    run;
    proc printto print="&out_comp_path.\comp_ads_&targetfile._&_YYMM_._&_TIME_..txt" new; run;
      proc compare base=&targetfile. compare=QC_&targetfile. out=Result_&targetfile. listall; run;
    proc printto; run;
%mend compare_ds;

