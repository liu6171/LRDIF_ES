/* macro to test for DIF using logistic regression techniques for dichotomous and polytomous items 

%macro lrdif_es(data, items, group, criterion, exo_con=, exo_cat=, sig_level=0.05, RS_D_crit_B=0.035, RS_D_crit_C=0.070, RS_P_crit_B=0.035, RS_P_crit_C=0.070, foc_size=100, ref_size=100, 
		combined_size=400, outfile=LRDIF, plot=NO);

Arguments:
data:  the input data.
items: the variable names in data containing item scores (dichotomous or polytomous item scores coded as integer starting from 0, i.e., 0, 1, 2,...) 
		on which DIF is to be conducted; multiple item score variables can be included and each variable name is not longer than 20 
		characters(this can be changed in the code).
group: the variable names in data containing groups on which DIF is to be conducted; each variable is coded as 1 for reference group and 0 for 
		focus group; multiple grouping variables can be included, and the combined length of each grouping variable name and the criterion name 
		is not longer than 19 characters.
criterion: the matching variable for DIF; usually is total test score.
exo_con: additional continuous explanatory variables; included only if needed.
exo_cat: additional categorical explanatory variables; should be numeric variables; included only if needed. 
sig_level: the significant level for model comparisons: the default is 0.05.
RS_D_crit_B: the cut-off value of  difference between DIF A category and B category for dichotomous items: the default is 0.035 (see Table 1).  
RS_D_crit_C: the cut-off value of  difference between DIF B category and C category for dichotomous items: the default is 0.070 (see Table 1).
RS_P_crit_B: the cut-off value of  difference between DIF A category and B category for polytomous items: the default is 0.035.  
RS_P_crit_C: the cut-off value of  difference between DIF B category and C category for polytomous items: the default is 0.070.
foc_size, ref_size, combined_size: minimum sample size requirements for focus group, reference group, and two groups combined; 
		if the sample size of the focus group is smaller than foc_size, the sample size of the reference group is smaller than ref_size, 
		or the sample size of the group combined is smaller than combined_size, then the DIF analysis is not conducted; the default values for 
		foc_size, ref_size, and combined_size are 100, 100, and 400, respectively. 
size_ratio: maximum sample size ratio of the large group over the small group. If the ratio of the large group over the 
		samll group is larger than size_ratio, then the DIF analysis is not conducted. If size_ratio <1, then size_ratio 
		is not treated as a pre-requirement for conducting DIF. The default is 0 .
out_parameter: the name of the output SAS file containing parameter estimates for each logistic model.  See Table 2 for 
		the variables included in this file.  The name of a library reference (libref) can be added to the front of 
		the file name so that the output file is a permanent SAS data file.  If out_parameter= 0, then this file is 
		not outputted. The default is 0. 
outfile: the name of the SAS output file containing DIF results for each item in "items" and each grouping variable in 
		"group".  The variables in the output file are defined in Table 2below.  The name of a library reference (libref) can 
		be added to the front of the file name so that the output file is a permanent SAS data file.  Note that if the sample 
		size criteria are not met (see above), or all examinees test takers get the same score on the target item in the overall 
		valid sample in a DIF run, then all the variables are missing except for Item, Group, Score_Category, N_ref, and N_foc. 

		Item: the name of the item variable on which DIF is conducted;
		Group: the name of the grouping variable on which DIF is conducted;
		Score_Category: the number of item score categories in the data; 
		N_ref: the number of students in the reference group (with group=0) used in the DIF calculation;
		N_foc: the number of students in the focus group (with group=1) used in the DIF calculation;
		Model 1: the -2 log likelihood of the no DIF model;
		Model 2: the -2 log likelihood of the uniform DIF model;
		Model 3: the -2 log likelihood of the non-uniform DIF model;
		RSQ1: the Nagelkerke  of the no DIF model;
		RSQ2: the Nagelkerke  of the uniform DIF model;
		RSQ3: the Nagelkerke  of the non-uniform DIF model;
		M2Est: the parameter estimate of the grouping variable ("Group") in the uniform DIF model; if the item appears to have uniform DIF, a positive 
				value indicates the item favors the focus group with code 0, and a negative value indicates the item favors the reference group with code 1; 
		M3Est M3EstInt: the parameter estimates of the grouping variable ("Group") and the interaction of the grouping variable and the criterion variable, 
				respectively, in the non-uniform DIF model; if the item appears to have overall or non-uniform DIF, the positive values in both variables 
				indicates the item favors the focus group with code 0, and the negative values in both variables indicates the item favors the 
				reference group with code 1. If signs of the two parameter estimates are opposite, then the item favors one or each group in 
				a certain range of the criterion variable; 
		LRDIF: the -2 log likelihood difference between Model 1 and Model 3 (Model 1 - Model 3);
		LRUIDIF: the -2 log likelihood difference between Model 1 and Model 2 (Model 1 - Model 2); 
		LRNUIDIF: the -2 log likelihood difference between Model 2 and Model 3 (Model 2 - Model 3);
		PDIF: the probability of overall DIF; equal to 1 minus the cumulative probability of LRDIF; LRDIF follows a chi-square distribution with two DF;   
		PUIDIF: the probability of uniform DIF; equal to 1 minus the cumulative probability of LRUIDIF; LRUIDIF follows a chi-square distribution with 
				one DF; 
		PNUIDIF: the probability of non-uniform DIF; equal to 1 minus the cumulative probability of LRNUIDIF; LRNUIDIF follows a chi-square distribution
				with one DF; 
		RSDIF: the Nagelkerke difference between the non-uniform DIF model and the no DIF model: RSQ3-RSQ1;
		RSUIDIF: the Nagelkerke difference between the uniform DIF model and the no DIF model: RSQ2-RSQ1;
		RSNUIDIF: the Nagelkerke difference between the non-uniform DIF model and the uniform DIF model: RSQ3-RSQ2;
		DIF: overall DIF classification based on Table 1 or similar rules: blank = non-significant overall DIF Chi-square 
			test (i.e., PDIF > sig_level), “*” = significant overall DIF Chi-square test (i.e., PDIF <= sig_level) but not 
			classified as B or C DIF, “B” = B DIF, “C” = C DIF (note that blank and “*” indicate A DIF); "+" sign 
			after "*", "B", and "C" indicates the item favors focus group, "-" sign after "*", "B", and "C" indicates the 
			item favors reference group, and no sign after "*", "B", and "C" indicates the item favors one or each group in a 
			certain range of the criterion variable; 
		UIDIF: uniform DIF classification based on Table 1 or similar rules: blank = non-significant uniform DIF Chi-square 
			test (i.e., PUIDIF > sig_level), “*” = significant uniform DIF Chi-square test (i.e., PUIDIF <= sig_level) but not 
			classified as B or C DIF, “B” = B DIF, “C” = C DIF (note that blank and “*” indicate A DIF); "+" sign 
			after "*", "B", and "C" indicates the item favors focus group, and "-" sign after "*", "B", and "C" indicates 
			the item favors reference group. 
		NUIDIF: non-uniform DIF classification based on Table 1 or similar rules: blank = non-significant non-uniform DIF 
			Chi-square test (i.e., PNUIDIF > sig_level), “*” = significant non-uniform DIF Chi-square test (i.e., 
			PNUIDIF <= sig_level) but not classified as B or C DIF, “B” = B DIF, “C” = C DIF (note that blank and “*” indicate
			A DIF); "+" sign after "*", "B", and "C" indicates the item favors focus group, "-" sign after "*", "B", and "C" 
			indicates the item favors reference group, and no sign after "*", "B", and "C" indicates the item favors one or each 
			group in a certain range of the criterion variable.

plot: Yes or No; if Yes, produce a line plot for each item in "items" and each grouping variable in "group", where mean item score and the 
		upper bound and low bound of the 95% confidence interval of the mean score for each group in the grouping variable are plotted against 
		the criterion variable.  If the sample size for a group at a criterion value is smaller than 20, or all item scores for a group at a 
		criterion value are the same, then the upper bound and low bound of the mean score for this group at the criterion value are set to missing.  
		Some labels in the plot (which can be changed in the code if needed):
		Criterion Scores: the criterion variable;
		
		Foc--LCLM: low bound of the 95% confidence limit of mean for the focus group with code 0; 
		Foc--UCLM: upper bound of the 95% confidence limit of mean for the focus group with code 0;
		Ref--LCLM: low bound of the 95% confidence limit of mean for the reference group with code 1; 
		Ref--UCLM: upper bound of the 95% confidence limit of mean for the reference group with code 1. 

Example:
%lrdif_es(data=sample, items=item1-item8, group=gender black, exo_con=income age, exo_cat=parent_education state, criterion = score, outfile=results, plot=yes);
*/

%macro lrdif_es(data, items, group, criterion, exo_con=, exo_cat=, sig_level=0.05, RS_D_crit_B=0.035, RS_D_crit_C=0.070, RS_P_crit_B=0.035, RS_P_crit_C=0.070, foc_size=100, ref_size=100, 
		combined_size=400, outfile=LRDIF, plot=NO, size_ratio=0, out_parameter=0);
options nonotes nomprint;

/* save number of respondents as macro variable */
data _null_; 
	set &data end=final; 
	if final then call symput('N',trim(left(_N_))); 
run;

/* save the item names as macro variables */
data _null_; 
	set &data; 
	array _y (*) &items; 
	length name $20; 
	if _n_=1 then do;
 		do _i=1 to dim(_y);
  			call vname(_y{_i}, name); 
  			call symput('_item'||trim(left(put(_i,4.))),trim(left(name)));
 		end; 
		_p=dim(_y); 
		call symput('_nitems',trim(left(put(_p,4.)))); 
	end; 
run;

/* calculate number of grouping variables - save names as macro variables */
data _null_; 
	set &data; 
	array _y (*) &group; 
	length name $20; 
	if _n_=1 then do;
 		do _i=1 to dim(_y);
  			call vname(_y{_i},name); 
  			call symput('_group'||trim(left(put(_i,4.))),trim(left(name)));
 		end; 
		_p=dim(_y); 
		call symput('_ngroup',trim(left(put(_p,4.)))); 
	end; 
run;

/* write something on the screen */
%put -----------------------------------------------------------;
%put logistic regression tests for differential item functioning;
%put -----------------------------------------------------------;
%put reading &N cases from data set &data, ;
%put &_nitems items, &_ngroup grouping variables ;
%put -----------------------------------------------------------;

%if &Out_parameter ^= 0 %then %do;
	data &Out_parameter;
	run;
%end;

/* loop over (item, group) combinations */
%do _i=1 %to &_nitems; 
	
	%do _e=1 %to &_ngroup;
	
		/* common sample is used in all models */
		
	data _new; 
	set &data (keep=&&_item&_i &&_group&_e &criterion &exo_con &exo_cat);
	array ar1 (*) &&_item&_i &&_group&_e &criterion &exo_con &exo_cat ;
	do i = 1 to dim(ar1);
		if ar1(i)=. then delete;
	end;
	run;
	/* retrieve number of item score categories, sample sizes for reference and focus group*/

	proc means data=_new;
	var &&_group&_e;
	output out=_sample sum=;
	run;	
	data _sample_foc (keep=Total rename=(Total=N_foc));
	set _sample ;
	Total = _freq_ - &&_group&_e;
	call symput('_foc',trim(left(put(Total,10.)))); 
	run;

	data _sample_ref (keep=Total rename=(Total=N_ref));
	set _sample (rename=(&&_group&_e=Total));
	call symput('_ref',trim(left(put(Total,10.)))); 
	run;

	proc freq data=_new;
	tables &&_item&_i /out=_Score_cat noprint;
	run;	
	data _Score_cat (keep=Score_Category);
	set _Score_cat end=final;
	Score_Category = _N_;
	if final then call symput('_SC',trim(left(_N_)));
	if final; 
	run;

	%let total = %eval(&_ref + &_foc);
	/*%put &_ref &_foc &total;*/
	%if &_ref >= &ref_size and &_foc >= &foc_size and &total >= &combined_size and &_SC > 1 and (&size_ratio <1 or 
(&_ref/&_foc>=1 and &_ref/&_foc <=&size_ratio) or (&_foc/&_ref>=1 and &_foc/&_ref <=&size_ratio))
%then %do;		
	
	/*run models*/
	proc logistic data=_new;
		class &exo_cat;	
		model &&_item&_i = &criterion &exo_con &exo_cat /rsq; 
		ods output logistic.FitStatistics=_tmp1;
		ods output logistic.parameterestimates=_est1;
		ods output  Logistic.RSquare=_RS1; 
	run;
	data _tmp1 (keep=InterceptAndCovariates rename=(InterceptAndCovariates=Model1));
		set _tmp1;
		if criterion="-2 Log L";
		run;
	data _RS1 (keep=nValue2 rename=(nValue2=RSQ1));
		set _RS1;
		run;

		proc logistic data=_new; 
			class &exo_cat;		
			model &&_item&_i =&criterion &&_group&_e &exo_con &exo_cat /rsq; 
			ods output logistic.FitStatistics=_tmp2; 
			ods output logistic.parameterestimates=_est2;
			ods output  Logistic.RSquare=_RS2; 
		run;
		proc logistic data=_new;
			class &exo_cat;		
			model &&_item&_i =&criterion &&_group&_e  &criterion.*&&_group&_e &exo_con &exo_cat /rsq; 
			ods output logistic.FitStatistics=_tmp3; 
			ods output logistic.parameterestimates=_est3;
			ods output  Logistic.RSquare=_RS3; 
		run;
		
		%if &Out_parameter ^= 0 %then %do;
		data _est1;
		set _est1;
		model="Model 1";
		run;

		data _est2;
		set _est2;
		model="Model 2";
		run;
		
		data _est3;
		set _est3;
		Model="Model 3";
		run;
		
		data est;
		length Variable $ 40;
		set _est1 _est2 _est3;
		Item="&&_item&_i";
		Group="&&_group&_e";
		run;

		data &Out_parameter;
		retain Item Group Model Variable ClassVal0;
		set &Out_parameter est;
		if item ^="";
		run;
		%end;
		data _tmp2 (keep=InterceptAndCovariates rename=(InterceptAndCovariates=Model2));
		set _tmp2;
		if criterion="-2 Log L";
		run;
		data _tmp3 (keep=InterceptAndCovariates rename=(InterceptAndCovariates=Model3));
		set _tmp3;
		if criterion="-2 Log L";
		run;
		data _est2 (keep=estimate rename=(estimate = M2Est));
		set _est2;
		if variable ="&&_group&_e";
		run;
		data _est4 (keep=estimate rename=(estimate = M3Est));
		set _est3;
		if variable ="&&_group&_e";
		run;
		data _est5 (keep=estimate rename=(estimate = M3EstInt));
		set _est3;
		if variable ="&criterion.*&&_group&_e";
		run;
		data _RS2 (keep=nValue2 rename=(nValue2=RSQ2));
		set _RS2;
		run;
		data _RS3 (keep=nValue2 rename=(nValue2=RSQ3));
		set _RS3;
		run;
		data _tmp;
		merge _Score_cat _sample_ref _sample_foc _tmp1 _tmp2 _tmp3 _RS1 _RS2 _RS3 _est2 _est4 _est5;
		run;

		/*ods listing;*/
/*
		title "item &&_item&_i";
		proc print data=_pf&_i.&_e(where=(variable="&&_group&_e") 
			rename=(probchisq=p) keep=variable Estimate StdErr probchisq) noobs; 
		run;
*/
		%end;
	%else %do;
		data _tmp;
		merge _Score_cat _sample_ref _sample_foc ;
		run;
	%end;
		data outfile&_i.&_e; 
			length item group $ 20;
			set _tmp ; 
			Item="&&_item&_i"; 
			Group="&&_group&_e";
		run;
	%end; 
%end;

/* create output file */
data &outfile; 
	set %do _i=1 %to &_nitems; %do _e=1 %to &_ngroup; outfile&_i.&_e %end; %end;;
	label Score_Category ="Number_of_Score_Categories" model1="-2LLK_NoDIF" model2="-2LLK_UNIDIF" model3="-2LLK_NUNIDIF";
run;

data &outfile;

/*retain Item Group Score_Category N_ref	N_foc	Model1	Model2	Model3	RSQ1	RSQ2	RSQ3	M2Est	M3Est	M3EstInt	
LRDIF	LRUIDIF	LRNUIDIF	PDIF	PUIDIF	PNUIDIF	RSDIF	RSUIDIF	RSNUIDIF	DIF	UIDIF	NUIDIF;*/
set &outfile;
if model1 ^=. then do;
LRDIF = model1-model3;
LRUIDIF = model1-model2;
LRNUIDIF = model2-model3;
PDIF = 1-PROBCHI(LRDIF, 2);
PUIDIF = 1-PROBCHI(LRUIDIF, 1);
PNUIDIF = 1-PROBCHI(LRNUIDIF, 1);
RSDIF = RSQ3-RSQ1;
RSUIDIF = RSQ2-RSQ1;
RSNUIDIF = RSQ3-RSQ2; 
length DIF UIDIF NUIDIF $2;
DIF="";
UIDIF="";
NUIDIF="";
if Score_Category =2 then do;
if PDIF <= &sig_level and &RS_D_crit_C > RSDIF >= &RS_D_crit_B then DIF="B";
else if PDIF <= &sig_level and &RS_D_crit_C <= RSDIF then DIF="C";
else if PDIF <= &sig_level then DIF="*";

if PUIDIF <= &sig_level and &RS_D_crit_C > RSUIDIF >= &RS_D_crit_B then UIDIF="B";
else if PUIDIF <= &sig_level and &RS_D_crit_C <= RSUIDIF then UIDIF="C";
else if PUIDIF <= &sig_level then UIDIF="*";

if PNUIDIF <= &sig_level and &RS_D_crit_C > RSNUIDIF >= &RS_D_crit_B then NUIDIF="B";
else if PNUIDIF <= &sig_level and &RS_D_crit_C <= RSNUIDIF then NUIDIF="C";
else if PNUIDIF <= &sig_level then NUIDIF="*";
end;
else if Score_Category >2 then do;
if PDIF <= &sig_level and &RS_P_crit_C > RSDIF >= &RS_P_crit_B then DIF="B";
else if PDIF <= &sig_level and &RS_P_crit_C <= RSDIF then DIF="C";
else if PDIF <= &sig_level then DIF="*";

if PUIDIF <= &sig_level and &RS_P_crit_C > RSUIDIF >= &RS_P_crit_B then UIDIF="B";
else if PUIDIF <= &sig_level and &RS_P_crit_C <= RSUIDIF then UIDIF="C";
else if PUIDIF <= &sig_level then UIDIF="*";

if PNUIDIF <= &sig_level and &RS_P_crit_C > RSNUIDIF >= &RS_P_crit_B then NUIDIF="B";
else if PNUIDIF <= &sig_level and &RS_P_crit_C <= RSNUIDIF then NUIDIF="C";
else if PNUIDIF <= &sig_level then NUIDIF="*";
end;
if PDIF =. then DIF="";
if PUIDIF =. then UIDIF="";
if PNUIDIF =. then NUIDIF="";
if UIDIF ^=""  then do;
if m2est <0 then UIDIF=cats( UIDIF, "-");
else UIDIF=cats(UIDIF, "+");
end;
if NUIDIF ^=""  then do;
if m3est <0 & m3EstInt <0 then NUIDIF=cats(NUIDIF, "-");
else if m3est >0 & m3EstInt >0 then NUIDIF=cats(NUIDIF, "+");
end;
if DIF ^=""  then do;
if m3est <0 & m3EstInt <0 then DIF=cats(DIF, "-");
else if m3est >0 & m3EstInt >0 then DIF=cats(DIF, "+");
end;
end;
run;

data &outfile;
retain Item Group Score_Category N_ref	N_foc	Model1	Model2	Model3	RSQ1	RSQ2	RSQ3	M2Est	M3Est	M3EstInt	
LRDIF	LRUIDIF	LRNUIDIF	PDIF	PUIDIF	PNUIDIF	RSDIF	RSUIDIF	RSNUIDIF	DIF	UIDIF	NUIDIF;
set &outfile;
run;
title ' ';

/* create plots if required */
%if %upcase(%left(%trim(&plot)))=YES %then %do; 
	%put plotting mean item scores for the grouping variables;
 	%put ---------------------------------------------------------;
	data _new; 
	set &data; 
	run;
	  %do _e=1 %to &_ngroup; %do _it=1 %to &_nitems;
	
		proc sort data=_new;
			by &criterion;
		run;
		proc means data=_new(where=(&&_group&_e=0)) noprint mean;
			var &&_item&_it;
			by &criterion;
			output out=_plot0 mean=mean0 lclm=lclm0 uclm=uclm0;
		run;
		proc means data=_new(where=(&&_group&_e=1)) noprint mean;
			var &&_item&_it;
			by &criterion;
			output out=_plot1 mean=mean1 lclm=lclm1 uclm=uclm1;
		run;
		data _plot0; set _plot0; if _FREQ_<20 then do; lclm0=.; uclm0=.; end; run;
		data _plot1; set _plot1; if _FREQ_<20 then do; lclm1=.; uclm1=.; end; run;
		data _plot; 
			merge _plot0 _plot1;
			by &criterion;
			label lclm0='Foc--LCLM'; label uclm0='Foc--UCLM'; label mean0='Foc--Mean Score';
			label lclm1='Ref--LCLM'; label uclm1='Ref--UCLM'; label mean1='Ref--Mean Score';
			label &criterion= "Criterion Score";
		run;

		title2 justify=center "Responses to item &&_item&_it for the two &&_group&_e groups:";
   		title3 justify=center "Mean scores and 95% confidence interval";

		symbol1 v=trianglefilled c=blue i=none; 
		symbol2 v=triangle c=blue i=join l=1;
		symbol3 v=triangle c=blue i=join l=1;
		symbol4 v=dot c=red i=none;
		symbol5 v=circle c=red i=join l=20;
		symbol6 v=circle c=red i=join l=20;
		legend1 position=center;

		axis2 label=(angle=90 justify=c "Mean Item Score");
		proc gplot data=_plot;
			plot (mean0 lclm0 uclm0 mean1 lclm1 uclm1)*&criterion/overlay legend=legend1 vaxis=axis2;
		run; quit;
	%end; %end;
/* end of fit test part*/
%end;

/* clean up */

proc datasets nolist;
 delete %do _i=1 %to &_nitems; %do _e=1 %to &_ngroup; outfile&_i.&_e %end; %end;
 _est1 est _Score_cat _new _est2 _est3 _est4 _est5 _tmp _tmp1 _tmp2 _tmp3 _plot _plot0 _plot1 _RS1 _RS2 _RS3 _sample_ref _sample_foc _sample;
run; quit;

title ' '; ods listing; options notes stimer;
%mend;
