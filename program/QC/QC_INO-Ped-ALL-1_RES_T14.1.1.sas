**************************************************************************
Program Name : QC_INO-Ped-ALL-1_RES_T14.1.1.sas
Study Name : INO-Ped-ALL-1
Author : Ohtsuka Mariko
Date : 2021-2-5
SAS version : 9.4
**************************************************************************;
proc datasets library=work kill nolist; quit;
options mprint mlogic symbolgen noquotelenmax;
%macro GET_THISFILE_FULLPATH;
    %local _fullpath _path;
    %let _fullpath=;
    %let _path=;

    %if %length(%sysfunc(getoption(sysin)))=0 %then
      %let _fullpath=%sysget(sas_execfilepath);
    %else
      %let _fullpath=%sysfunc(getoption(sysin));
    &_fullpath.
%mend GET_THISFILE_FULLPATH;
%macro GET_DIRECTORY_PATH(input_path, directory_level);
    %let input_path_len=%length(&input_path.);
    %let temp_path=&input_path.;

    %do i = 1 %to &directory_level.;
      %let temp_len=%scan(&temp_path., -1, '\');
      %let temp_path=%substr(&temp_path., 1, %length(&temp_path.)-%length(&temp_len.)-1);
      %put &temp_path.;
    %end;
    %let _path=&temp_path.;
    &_path.
%mend GET_DIRECTORY_PATH;
%macro SET_EXCEL_BY_SEQ(input_ds, target_var);
    %local row_count;
    %SET_EXCEL(&input_ds., &output_row., 4, &target_var., &output_file_name.);
    proc sql noprint;
        select count(*) into: row_count from &input_ds.;
    quit;
    %let seq=%eval(&seq.+1);
    %let output_row=%eval(&output_row.+&row_count.); 
%mend SET_EXCEL_BY_SEQ;
%global seq output_row N;
%let thisfile=%GET_THISFILE_FULLPATH;
%let projectpath=%GET_DIRECTORY_PATH(&thisfile., 3);
%inc "&projectpath.\program\QC\macro\QC_INO-Ped-ALL-1_RES_LIBNAME.sas";
* Main processing start;
%let output_file_name=T14.1.1;
%let templatename=&template_name_head.&output_file_name.&template_name_foot.;
%let outputname=&template_name_head.&output_file_name.&output_name_foot.;
%let template=&templatepath.\&templatename.;
%let output=&outputpath.\&outputname.;
%let target_flg=PPSFL;
libname libinput "&inputpath." ACCESS=READONLY;
data adsl;
    set libinput.adsl;
    where &target_flg.='Y';
run;
data admh;
    set libinput.admh;
    where &target_flg.='Y';
run;
data medical_history complication;
    set admh;
    if MHENRTPT='BEFORE' then do;
      output medical_history;
    end;
    else if MHENRTPT='ONGOING' then do;
      output complication;
    end;
run;
%let seq=1;
%OUTPUT_ANALYSIS_SET_N(adsl, output_&seq., N, 'NUM');
data temp_n;
    set output_&seq.;
    call symput('N', N);
run;
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., SEX, %str('M, F'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_MEANS(adsl, output_&seq., AGE);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., AGEGR1, %str('<2, >=2-<12, >=12'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_MEANS(adsl, output_&seq., BSA);
%let seq=%eval(&seq.+1);
%EDIT_MEANS(adsl, output_&seq., HEIGHT);
%let seq=%eval(&seq.+1);
%EDIT_MEANS(adsl, output_&seq., WEIGHT);
%let seq=%eval(&seq.+1);
%EDIT_MEANS(adsl, output_&seq., BMI);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., PRIMDIAG, %str('B-ALL/LBL(ETV6-RUNX1), B-ALL/LBL(KMT2A), B-ALL/LBL(NOS), Hyperdiploid B-ALL/LBL'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_MEANS(adsl, output_&seq., DISDUR);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(medical_history, output_&seq., MHDECOD, 
               %str('Benign neoplasm, Drug-induced liver injury, Infection, Pneumocystis jirovecii pneumonia, Sepsis, Systemic mycosis'), ',', &N.);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(complication, output_&seq., MHDECOD, %str('Alanine aminotransferase increased, 
                                                          Alopecia, 
                                                          Anaemia, 
                                                          Aspartate aminotransferase increased, 
                                                          Cataract, 
                                                          Constipation, 
                                                          Decreased appetite, 
                                                          Dermatitis diaper, 
                                                          Diabetes mellitus, 
                                                          Dry skin, 
                                                          Erythema multiforme, 
                                                          Febrile neutropenia, 
                                                          Gamma-glutamyltransferase increased, 
                                                          Gastrointestinal disorder, 
                                                          Generalised oedema, 
                                                          Gingivitis, 
                                                          Haematoma, 
                                                          Haemorrhoids, 
                                                          Hepatic function abnormal, 
                                                          Hypercholesterolaemia, 
                                                          Hyperferritinaemia, 
                                                          Hyperglycaemia, 
                                                          Hypogammaglobulinaemia, 
                                                          Hypokalaemia, 
                                                          Interstitial lung disease, 
                                                          Lymphocyte count decreased, 
                                                          Malaise, 
                                                          Nausea, 
                                                          Neutropenia, 
                                                          Neutrophil count decreased, 
                                                          Oedema peripheral, 
                                                          Oliguria, 
                                                          Pain in extremity, 
                                                          Periodontal disease, 
                                                          Petechiae, 
                                                          Platelet count decreased, 
                                                          Protein urine, 
                                                          Sinusitis, 
                                                          Tumour associated fever, 
                                                          Tumour pain, 
                                                          Ventricular arrhythmia'), ',', &N.);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., ALLER, %str('Y, N'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., INTP, %str('NORMAL, ABNORMAL, UNEVALUABLE, UNKNOWN'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., RELREF, %str('INDUCTION FAILURE, FIRST RELAPSE, SECOND RELAPSE, OTHER'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., HSCT, %str('Y, N'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., RAD, %str('Y, N'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., LKPSGR1, %str('>=80, 70-50, <=40'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., CD22GR1, %str('>=90%, >=70%-<90%, <70%'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_MEANS(adsl, output_&seq., LVEF);
%let seq=%eval(&seq.+1);
%EDIT_MEANS(adsl, output_&seq., WBC);
%let seq=%eval(&seq.+1);
%EDIT_MEANS(adsl, output_&seq., PBLST);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., PBLSGR1, %str('0Åb>0- 1,000Åb>1,000- 5,000Åb>5,000- 10,000Åb>10,000'), 'Åb', 0);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., BLSGR1, %str('<50%, >=50%'), ',', 0);
%let seq=%eval(&seq.+1);
%EDIT_MEANS(adsl, output_&seq., FRDUR);
%let seq=%eval(&seq.+1);
%EDIT_N_PER_2(adsl, output_&seq., FRDURGR1, %str('<12 months, >=12 months'), ',', 0);
%OPEN_EXCEL(&template.);
%let seq=1;
%let output_row=6;
%SET_EXCEL_BY_SEQ(output_&seq., %str(N));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(COL1));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(COL1));
%SET_EXCEL_BY_SEQ(output_&seq., %str(COL1));
%SET_EXCEL_BY_SEQ(output_&seq., %str(COL1));
%SET_EXCEL_BY_SEQ(output_&seq., %str(COL1));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(COL1));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(COL1));
%SET_EXCEL_BY_SEQ(output_&seq., %str(COL1));
%SET_EXCEL_BY_SEQ(output_&seq., %str(COL1));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%SET_EXCEL_BY_SEQ(output_&seq., %str(COL1));
%SET_EXCEL_BY_SEQ(output_&seq., %str(N PER));
%OUTPUT_EXCEL(&output.);
%SDTM_FIN(&output_file_name.);


