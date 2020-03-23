ods _all_ close;
/*data work.stuff;*/
/*	set sasdl.mis_summed;*/
/*	where _type_ = 255;	*/  /*---all ways aggregated --*/
/*	run;*/

title1 "Product:	CLP US Retail";

/*----- Rounding ----*/
proc format ;
	picture k_fmt (round) 
     low-high = '0,000,009'(mult=.001 prefix='$ ') ;
	run;

/*libname odstmpl 'g:\kwyland\styles';*/
ods path odstmpl.styles(read)
sashelp.tmplmst(read);

libname odstmpl 'g:\kwyland\styles';
%include 'g:\kwyland\styles\odstmpl_scale_it2.sas';

/*options orientation=portrait; */
/*options papersize=letter;*/
/*%let factor=.8; *1.0; *.935; */

/*--- good size for states ---*/
options orientation=landscape; 

options papersize=legal; *1.0;
%let factor=1.0; 

options papersize=letter; *.935;
%let factor=.935; 

%styles; 

title1 height=12pt j=left "Axcess Financial - Underwriting & Analytics - Portfolio Performance";
title2 height=10pt j=left "Product: Choice Loan Product";
title3 height=10pt j=left "Channel: Retail";


/*ods powerpoint file="g:\kwyland\sas_output\mis.pptx";*/  /*--- available with 9.4---*/

/*--------------------
table statement = categories in left column
next statement = values * row headings
nested categories use *

REPPCTN and REPPCTSUM statistics--print the percentage of the value in a single table cell in relation to the total of the values in the report.
COLPCTN and COLPCTSUM statistics--print the percentage of the value in a single table cell in relation to the total of the values in the column.
ROWPCTN and ROWPCTSUM statistics--print the percentage of the value in a single table cell in relation to the total of the values in the row.
PAGEPCTN and PAGEPCTSUM statistics--print the percentage of the value in a single table cell in relation to the total of the values in the page.
------------------------------*/



ods pdf file = "g:\kwyland\sas_output\tab_test.pdf" /*startpage=off*/ uniform /*notoc*/ style=ScaledPrinter;
proc tabulate data=sasdl.mis_clp format=comma15.;
	class fiscalyear quarter month profile state ics_score_band apr_band;
	var loan_amt ics_score apr loan_term inst_amt;

/*--- Originations ($,Avg,#) for Customer Type by Years/Months ---*/
	table fiscalyear* * (quarter) all='Total' ,
/*		loan_amt="Originations(000's)" * (profile all='Total') * sum='' *f= k_fmt. */
		loan_amt="Originations($)" * (profile all='Total') * sum='' *f=dollar15.    
		loan_amt='Average Originations($)' * (profile all='Total') * mean='' *f=dollar15.
		loan_amt='Originations(#)' *(profile all='Total') * n=''	
		/ box='Originated Loans'
		;
run;

/*------ This works for Footnote ----*/
%macro repnow ;
 %local d t ;
 %let d = %sysfunc( date( ), weekdate29 );
 %let t = %sysfunc( time( ), timeampm8 );
 &t &d
%mend repnow;
%let ff = HEIGHT=8PT J=RIGHT F=Verdana;
FOOTNOTE1 &ff "Page ^{thispage} of ^{lastpage}";
FOOTNOTE2 &ff "%repnow";

/*--- test to get %of total for each group of year ---*/
ods pdf file = "g:\kwyland\sas_output\tab_test2.pdf" /*startpage=off*/ uniform /*notoc*/ style=ScaledPrinter;
ods escapechar='^'; ods noproctitle;
title1 height=12pt j=left "Axcess Financial - Underwriting & Analytics";
title2 height=12pt j=left "Portfolio Performance for Choice Loan Product";

/*---- Not working ---*/
/*title1 '^{style[preimage="g:\kwyland\sas_configs\axcess_logo.gif"] }';*/

proc tabulate data=sasdl.mis_clp out=work.tab format=comma15. ;*S=[cellwidth=150];
	class fiscalyear quarter month profile state ics_score_band apr_band;
	var loan_amt ics_score apr loan_term inst_amt;
/*	table fiscalyear * (quarter * (month='Month')) all='total' ,*/  /*--- 3 nests ---*/
/*		(loan_amt) * (profile all='Total' colpctsum='%' * f=7.3 )*/
/*	loan_amt="Originations($)" 	* (profile * (sum='Sum'*f=dollar15. pctsum<month all>='%' *f=6.1 *{s={cellwidth=20}}))*/

	/*--- Yes, this works - do not disturb ---*/
	table fiscalyear * (month all='Total') /*all='Grand Total' */  ,
		loan_amt="Originations($)" 			* (profile * (sum='Sum'*f=dollar15. 	pctsum<month all>='%' *f=6.1))
		loan_amt="Average Originations($)" 	* (profile * (mean='Avg'*f=dollar15. 	pctsum<month all>='%' *f=6.1))
		loan_amt="Originations(#of Loans)" 	* (profile * (n='#'*f=comma9. 		pctsum<month all>='%' *f=6.1))
	/ box=[label='Originations by Vintage'] indent=3 rts=30 
/* style=[preimage="g:\kwyland\sas_configs\axcess_logo.gif"]]; */
	;

	/*--- State Distribution---*/
	table state='State' all='Total' /*all='Grand Total' */  ,
		loan_amt="Originations($)" 			* (profile * (sum='Sum'*f=dollar15. 	pctsum<state all>='%' *f=6.1))
		loan_amt="Average Originations($)" 	* (profile * (mean='Avg'*f=dollar15. 	pctsum<state all>='%' *f=6.1))
		loan_amt="Originations(#of Loans)" 	* (profile * (n='#'*f=comma9. 		pctsum<state all>='%' *f=6.1))
	/ rts=20 box=[label='Originations by State']
	;

	/*--- ICS Score Distribution by Bands---*/
	table ics_score_band all='Total' /*all='Grand Total' */  ,
		loan_amt="Originations($)" 			* (profile * (sum='Sum'*f=dollar15. 	pctsum<ics_score_band all>='%' *f=6.1))
		loan_amt="Average Originations($)" 	* (profile * (mean='Avg'*f=dollar15. 	pctsum<ics_score_band all>='%' *f=6.1))
		loan_amt="Originations(#of Loans)" 	* (profile * (n='#'*f=comma9. 		pctsum<ics_score_band all>='%' *f=6.1))
	/ box=[label='Originations by ICS_Score_Band']
	;

/*--- APR Distribution by Bands---*/
	table apr_band all='Total' /*all='Grand Total' */  ,
		loan_amt="Originations($)" 			* (profile * (sum='Sum'*f=dollar15. 	pctsum<apr_band all>='%' *f=6.1))
		loan_amt="Average Originations($)" 	* (profile * (mean='Avg'*f=dollar15. 	pctsum<apr_band all>='%' *f=6.1))
		loan_amt="Originations(#of Loans)" 	* (profile * (n='#'*f=comma9. 		pctsum<apr_band all>='%' *f=6.1))
	/ box=[label='Originations by APR_Band']
	;


;;run;
ods _all_ close;



/*--- To Balance to Financial Report - Monthly Installment Report ---*/
ods pdf file = "g:\kwyland\sas_output\tab_finance.pdf" /*startpage=off*/ uniform /*notoc*/ style=ScaledPrinter;
ods escapechar='^'; ods noproctitle;
title1 height=12pt j=left "Axcess Financial - Underwriting & Analytics";
title2 height=12pt j=left "Portfolio Performance for Choice Loan Product";


proc tabulate data=sasdl.mis_clp out=work.tab format=comma15. ;*S=[cellwidth=150];
	class fiscalyear quarter month profile state ics_score_band apr_band;
	var loan_amt ics_score apr loan_term inst_amt rem_balance_principal;

	table fiscalyear * (month all='Total') /*all='Grand Total' */  ,
		loan_amt	="Originations($)" 			* (sum='Sum'*f=dollar15. 	pctsum<month all>='%' *f=6.1)
		loan_amt	="Originations($)" 			* (mean='Avg'*f=dollar15.) 	/*pctsum<month all>='%' *f=6.1)*/
		loan_amt	="Originations(#)" 			* (n='#'*f=comma9. 		)	/*pctsum<month all>='%' *f=6.1)*/
		inst_amt	="Scheduled Installment_Payment"			* (mean='Avg'*f=dollar15.	pctsum<month all>='%' *f=6.1)
		apr		="APR"					* (mean='Avg'*f=15.			pctsum<month all>='%' *f=6.1)
		apr		="APR"					* (min='Min'*f=15.		)	/*pctsum<month all>='%' *f=6.1)*/
		apr		="APR"					* (max='Max'*f=15.		)	/*pctsum<month all>='%' *f=6.1)*/
		loan_term ="Scheduled Loan_Terms"		* (mean='Avg'*f=15.			pctsum<month all>='%' *f=6.1)

	/ box=[label='Originations by Vintage'] indent=3 rts=30 
	;

;;run;
ods _all_ close;

/* / S=[cellwidth=550];*/
/*--- To Balance to Financial Report - Monthly Installment Report ---*/
ods pdf file = "g:\kwyland\sas_output\tab_finance3.pdf" /*startpage=off*/ uniform /*notoc*/ style=ScaledPrinter;
ods escapechar='^'; ods noproctitle;
title1 height=12pt j=left "Axcess Financial - Underwriting & Analytics - Portfolio Performance";
title2 height=10pt j=left "Product: Choice Loan Product";
title3 height=10pt j=left "Channel: Retail";


proc tabulate data=sasdl.mis_clp out=work.tab format=comma15. missing;*S=[cellwidth=150];
	class fiscalyear quarter month profile state ics_score_band apr_band ;
*	keylabel pctsum='%' sum='Total' mean='Avg' n='#' min='Min' max='Max';  /*--- can use instead of on each var ---*/

	var loan_amt ics_score apr loan_term inst_amt rem_balance_principal;

	table fiscalyear * (month all='Total') /*all='Grand Total' */  ,
		loan_amt="Originations"	  * (profile='By Customer'	all='All Customers' 
									* (	sum='Total'	*f=dollar15. 	pctsum<month all>='%' *f=6.1
										mean='Avg'	*f=dollar15.
										n='#'		*f=comma9. 	))

		inst_amt	="Scheduled Payments"	* (	mean='Avg'	*f=dollar15.	pctsum<month all>='%' *f=6.1)

		apr		="APR"				* (	mean='Avg'	*f=15.		pctsum<month all>='%' *f=6.1
										min='Min'		*f=15.		
										max='Max'		*f=15.		)

		loan_term ="Scheduled Loan_Terms"	* (	mean='Avg'	*f=15.1		pctsum<month all>='%' *f=6.1)
		

	/ box=[label='Loans by Vintage'] indent=3 rts=30 
	;

;;run;
ods _all_ close;





%macro test3;


ods pdf file = "g:\kwyland\sas_output\tab_test3.pdf" /*startpage=off*/ uniform /*notoc*/ style=ScaledPrinter;
proc tabulate data=sasdl.mis_clp out=work.tab format=comma15.;
	class fiscalyear quarter month profile state ics_score_band apr_band;
	var loan_amt ics_score apr loan_term inst_amt;

/*--- Originations ($,Avg,#) for Customer Type by Years, Loan Term, Score Band, Apr Band ---*/
	table fiscalyear all='Total' loan_term all='Total' ics_score_band='Score Band' all='Total' apr_band all='Total',
		loan_amt='Originations($)' * (profile all='Total') *sum='' 
		loan_amt='Average Originations($)' * (profile all='Total') *mean='' 
		loan_amt='Originations(#)' *(profile all='Total') *n=''	
		/ box='Originated Loans'
		;

/*--- Originations ($,Avg,#) for Customer Type by Years (loan_term), Score Band, Apr Band ---*/
	table fiscalyear * (loan_term all='Total') ics_score_band='Score Band' all='Total' apr_band all='Total',
		loan_amt='Originations($)' * (profile all='Total') *sum='' 
		loan_amt='Average Originations($)' * (profile all='Total') *mean='' 
		loan_amt='Originations(#)' *(profile all='Total') *n=''	
		/ box='Originated Loans'
		;

/*---Originations ($) for State by Years/Months ---*/
	table fiscalyear * (fiscalmonth all='SubTotal') all='Total' ,
		loan_amt='Originations($)' * (state all='Total') *sum='' 
		/ box='Originated Loans'
		;

/*---Originations (Avg) for State by Years/Months ---*/
	table fiscalyear * (fiscalmonth all='SubTotal') all='Total' ,
		loan_amt='Average Originations($)' * (state all='Total') *sum='' 
		/ box='Originated Loans'
		;

/*---Averages (Score,APR,Payment,Term) for Customer Type by Years/Months ---*/
	table fiscalyear * (fiscalmonth all='SubTotal') all='Total' ,
		ics_score * (profile all='Total') *mean=''
		apr * (profile all='Total') *mean=''
		inst_pmt * (profile all='Total') *mean=''
		loan_term * (profile all='Total') *mean=''
		/ box='Averages'
		;
	

;;;;;run;

ods _all_ close;
%mend;
*test3;  *Need to fix it first;





%macro nope;

	table fiscalyear all='Total' profile all='Total' loan_term all='Total',
		loan_amt_sum*state *sum='' loan_amt_avg*state *sum=''
	/ box='Table1A Loans Across States 3 in One'
	;

	table state all='Total' profile all='Total' loan_term all='Total', 
		loan_amt_sum*fiscalyear loan_amt_avg*fiscalyear
	/ box='Table1B Loans Across Years Table 1 Flipped'
	;

	table i2_ics_score_band all='Total' apr_band all='Total',
		loan_amt_sum*fiscalyear loan_amt_avg*fiscalyear 
	/ box='Table1C Bands Across Years '
	;

	table fiscalyear*fiscalmonth all i2_ics_score_band all,
		loan_amt_sum*state *sum='' loan_amt_avg*state *sum=''
	/ box='Table3'
	;



	;;run;
ods _all_ close;

%mend;







	/*--- Table breaks by year ---*/
/*	table fiscalyear * (fiscalmonth all='SubTotal') all='Total', i2_ics_score_band all='Total',  *---this makes it page break by fiscal ---;*/
/*		loan_amt_sum*state loan_amt_avg*state all='Total'*/




