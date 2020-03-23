/*---------------------------------------------------------
	Program: Z:\SAS_Tests\SAS_Dev\testing_scheduler.sas
	Purpose: Test Generic SAS program in Task Scheduler

	Run some general SAS settings
	Run some test code 
	Check Log in Z:\SAS_Tests\SAS_Logs\test_scheduler.log
	Check Output in Z:\SAS_Tests\SAS_Output\test_scheduler.htm
---------------------------------------------------------*/

/*--- Who is User Running SAS, used for Email Notifications ---*/
%let sys_user = %SYSGET(USERNAME); 

/*---------------------------
	Test using SASHELP
----------------------------*/
data work.stuff;
	set sashelp.shoes;
	run;

ods _all_ close;   
%let out_file = Z:\SAS_Tests\SAS_Output\testing_scheduler.htm;	
ods html body="&out_file" style=HTMLBlue;  

ods html;
proc print data=work.stuff;
	run;

/*--- Email for Audit Trail ---*/
OPTIONS EMAILSYS=SMTP EMAILHOST=apprelay.cngfinancial.com; 
FILENAME mail EMAIL 'nul'
	to		= ("&sys_user.@axcess-financial.com")
	from 	= ("&sys_user.@axcess-financial.com")
	subject 	= "Testing_Scheduler" ;;;;
data _null_;
	file mail;
	put "The Task Scheduler just ran Z:\SAS_Tests\SAS_Dev\testing_scheduler.sas.";
	put "Check Z:\SAS_Tests\SAS_Logs folder for the SAS Log and ..SAS_Output\SAS Output (htm)."//;
	put "Message sent from the SAS Process, launched by the Task Scheduler." ;
	put "The Process began on %sysfunc(date(),date9.), &sysday, &systime." //;
	run;