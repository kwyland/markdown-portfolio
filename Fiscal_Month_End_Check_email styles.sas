/* ----------------------------------------------------------------------------------------
PROGRAM:  PROD(FISCAL_MONTH_END_CHECK)
AUTHOR:	Karen Wyland, FEB2016
PURPOSE:	Creates Fiscal Month End Calendar to Manage Automated Process Schedule and
		create macro date variable for Tran_end_Date used in Prod(CDR_Transactions) Program.

INPUT:	SUSSTORE.BUSINESS_DATES_ALL
OUTPUT:   SASDL.FISCAL_MONTH_END, SAS_OUTPUT\fiscal_month_end_calendar.html (current year)

BEGIN MODIFICATIONS
MOD FEB2016 Added Calc of Tran_end_date for use in CDR_Transactions and Timestamp for Email
MOD FEB2016 Added Email Notification if it is MONDAY but NOT fiscal month end
END MODIFICIATIONS
-----------------------------------------------------------------------------------------*/
%global process;
%global tran_end_date;
%global timestamp;

%let outfile = &out_dir.\fiscal_month_end_calendar.html;

proc sort data=susstore.business_dates_all out=work.sorted;
	by fiscalmonth date;
	run;

data sasdl.fiscal_month_end (keep=date fiscalmonth month day year weekday day_name run_date run_day tran_end_date);
	set work.sorted;
	format date datetime23. fiscalmonth $8. month day year weekday 4. 
		  day_name $10. tran_end_date date9. run_day $10. run_date date9.;
	label date		= "BusCal Date" 
		 fiscalmonth	= "BusCal Fiscal Month"
		 run_date 	= "SAS Task Run_Date"
		 day_name		= "Week Day"
		 tran_end_date	= "Tran End Date"
		 run_day		= "Run Day"
	;;;
	by fiscalmonth;
	if last.fiscalmonth;
		date1=datepart(date); 
		tran_end_date = date1;
		day = day(date1);
		month = month(date1);
		year = year(date1);
		weekday = weekday(date1);
		day_name = put (date1,downame.);
		run_date = date1+2;
		run_day = put(run_date,downame.);
	run;

option mprint mlogic;
/*------------------------
	Output to html
	Current Year
-------------------------*/
%let date = %sysfunc(date(),date9.);
%let day  = &sysday;
%let time = %sysfunc(time(),tod8.);

option nomprint nomlogic;
ods html close;
ods html body="&outfile" style=sasweb;*style=Barrettsblue; 
options ls=150;
title "Fiscal Calendar to Manage Scheduled SAS Processes for CDR";
proc print data=sasdl.fiscal_month_end noobs label split='';
	where year=year(today());
	run;
ods html close;

/*-----------------------
	Send Email to Admin
------------------------*/
title; footnote;
%macro email_stop;
%include prod(ODS_Styles);
/*------------------------
	Output to html
	Current Year
-------------------------*/



OPTIONS NOSYNTAXCHECK;   /*---Keeps batch process from failing to send email---*/

OPTIONS EMAILSYS=SMTP EMAILHOST=apprelay.cngfinancial.com; 
FILENAME mail EMAIL 
/*	to		= ("&sys_user.@axcess-financial.com" "mwgates@axcess-financial.com" "snaidu@axcess-financial.com")*/
	to 		= ("&sys_user.@axcess-financial.com")
	from 	= ("&sys_user.@axcess-financial.com")
	subject 	= "CDR Segmentation - Fiscal Month End Check" 
	type		= "text/html"
	;;;;
ods _all_ close;
ods msoffice2k file=mail style=email_fiscal;
option nodate nonumber;

data _null_;
	file print;
	put "This is a test of some text";
	
	call execute("
		title 'Fiscal Calendar to Manage Scheduled SAS Processes for CDR';
		proc print data=sasdl.fiscal_month_end noobs label split='';
			where year=year(today());
			run; 
	");
	run;
ods _all_ close;

	 
/*title "Fiscal Calendar to Manage Scheduled SAS Processes for CDR";*/
/*title2 "Today is &day, &date &time but it is NOT a Monday after Fiscal_Month_End.";*/
/*title3 "Therefore, the process will NOT run today.";*/
/*footnote "Prog Name: %sysget(SAS_EXECFILENAME) **By: &SYSUSERID ** Run on: %sysfunc(datetime(),datetime16.)";*/
/*proc print data=sasdl.fiscal_month_end noobs label split='';*/
/*	where year=year(today());*/
/*	run;*/

%mend;

/*--------------------------------------
	Creation of Macros for
	Tran_End_Date, Run_Date
----------------------------------------*/	   
%macro check_dates;
proc sql noprint;
	select run_date, tran_end_date 
		into :run_date, :tran_end_date
		from sasdl.fiscal_month_end
		where run_date = "&todays_date"d;
	quit;

/*--- Create timestamp for file as 20151013 (yymmddn8) ---*/
data _null_;
	timestamp = input("&tran_end_date",date9.);
	call symput('timestamp',put(timestamp,yymmddn8.));
	run;

%if &sqlobs ne 0 %then %let process = DOIT;
%else %do;
	%let process = STOP;
	%email_stop;
%end;
%mend check_dates;
%check_dates;

%put Process=&process; 
%put Tran_end_date=&tran_end_date;
%put Timestamp=&timestamp;
