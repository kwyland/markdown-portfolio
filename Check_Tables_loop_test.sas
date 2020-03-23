/*-------------------------------------------------
PROGRAM:	PROD(Check Tables)
AUTHOR:	Karen Wyland, JAN2016
PURPOSE:	Check Availability of 3rd Party Tables
NOTES:    If not available, loop the check for 3 times - 15min intervals

BMOD
MOD
EMOD
---------------------------------------------------*/


/*----------------------------------
	Create Dset with Table Info
-----------------------------------*/
%macro check_table_temp;
proc delete data=sasdl.check_tables_all; 
	run;

	%macro doit(lib=lib,table=table);
	%let date = %sysfunc(date(),date9.);
	%let day  = &sysday;
	%let time = %sysfunc(time(),tod8.);

	proc sql; create table work.check_tables as
		select "&day" as day, "&date" as date, "&time" as time,
			  "&lib" as libname length=8 format=$8., "&table" as table length=32 format=$32., 
			  count(*) as num_obs length=8 format comma15.
		from &lib..&table.;
		quit;

	proc append base=sasdl.check_tables_all data=work.check_tables force;
		run;

	%mend;
	%doit(lib=i2_uw2	,table=evaluation);
	%doit(lib=susstore	,table=st_il_master);
	%doit(lib=susstore	,table=st_il_schedule);
	%doit(lib=susstore	,table=store_table_full);
	%doit(lib=susstore	,table=bo_master);
	%doit(lib=susstore	,table=business_dates_all);
	%doit(lib=susstore	,table=bo_address); 
	%doit(lib=susstore	,table=st_lo_master);
	%doit(lib=susstore	,table=st_il_trans);
	%doit(lib=susstore	,table=st_il_distribution);
	%doit(lib=NCP		,table=ILP_Loan_Summary);
	%doit(lib=NCP		,table=ilp_pmtsched_details); 
	%doit(lib=NCP		,table=ILP_customer_details);
	%doit(lib=NCP		,table=ILP_Distribution_Details);
	%doit(lib=LOC		,table=Loan);

proc sort data=sasdl.check_tables_all; by libname table; run;
%mend;

%macro check_table;
/*------------------------------------------
	Create output to include in Email
-------------------------------------------*/
%global subj;
data work.flags; file external(check_tables.txt);
	set sasdl.check_tables_all;
	by libname table;
	if _n_ = 1 then do;   /*---If first obs, then put header ---*/
	   put 'put "LIBNAME ' @25 'TABLE' @60 'NUM_OBS ";';
	   put 'put "' libname @25 table   @52 num_obs comma15. '";';
	end;
	else put 'put "' libname  @25 table   @52 num_obs comma15. '";';

	/*---Set Flag ---*/
/*	if num_obs = 0 then do; 	call symput('subj','ALERT'); end;*/
/*	else do; 				call symput('subj','READY'); end;*/
	flag = 0;
	if num_obs = 0 then flag=1;
	run;

proc summary data=work.flags nway;
	var flag;
	output out=work.summed sum=;
	run;

data _null_;
	set work.summed;
	if flag ne 0 then put 'Oops there is a flag';
	run;

%put &subj;
%mend Check_Table;


%macro Send_Email (loop);
/*-----------------------------
	ODS Template for Email
-------------------------------*/
proc template;  define style styles.test;
	parent=styles.printer;
	style data from data/font_face="courier new" font_size=10pt ;
	style batch from batch /
	font_face="courier new"
	font_size=10pt;end;
	run;

OPTIONS NODATE NONUMBER;
title;
/*-----------------------------
	Email Notifications
------------------------------*/
OPTIONS NOSYNTAXCHECK;   /*---Keeps batch process from failing to send email---*/
OPTIONS EMAILSYS=SMTP EMAILHOST=apprelay.cngfinancial.com; 
FILENAME mail EMAIL 
	to		= ("&sys_user_email")
	from 	= ("&sys_user_email")
	subject 	= "[&subj] Availability of 3rd Party Database Tables" 
	type		= "text/html";;;;

ods escapechar='^';
ods _all_ close;
ods html body=mail style=styles.test;
/*---{background=blue} ^n line feed
---------------*/

data _null_;
	file print linesize=200;
	if "&subj" = 'READY' then 
	   do;
		put "^S={color=green}All Tables are Available."; 
		put "^S={color=blue}The CDR Programs will now Begin Processing. ^n";
	   end;
	if "&subj" = 'ALERT' then 
	   do;
		put "^S={color=red}One or More Tables are NOT Available - Loop &loop..";
		put "^S={color=blue}The Program will check at 10 minute intervals for 1 Hour (6 Loops). ^n";
	   end;
	if "&loop" = '3' then 
		put "---------> Final Loop: The Program will now need to be Re-started Manually <--------- ^n";
	%include "&ext_dir.\check_tables.txt";
	put "^nMessage sent from the SAS Process, Check_Tables, which was launched by the Task Scheduler." ;
	put "The Process completed on %sysfunc(date(),date9.), &sysday at %sysfunc(time(),tod8.)";
	run;

ods html close;
%mend Send_Email;

option mlogic mprint;
%macro Loopy;
%let i=1;
%check_table;
/*	%if &subj = ALERT %then;*/
	%do %while (&subj = ALERT);
	   %do %until (%eval(&i) < 3);
		%send_email (&i);
		%check_table;
		%put /"---> Inside Loopy ( " &i ") --> One or more Tables has Zero Obs " &subj. ;
		%put "Sleeping every 5 minutes " %sysfunc(sleep(60,.1)); 
		%let i=%eval(&i+1); %end;
	%end;
	%put /"---> Outside Loop ( " &i ")  --> DONE All Tables Available - &subj."/;
%if &subj = READY %then; %do; %send_email (1); %end;
%mend Loopy;                                                                                                                                 
%Loopy;


