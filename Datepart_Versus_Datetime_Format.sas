/* ----------------------------------------------------------------------------------------
PROGRAM:  DEV(Datepart_Versus_Datetime_Format)
AUTHOR:	Karen Wyland, FEB2016 
PURPOSE:	Universal code for Users to Run and Observe Efficiency Results
NOTES:    Assumes User has Access to CHQSQL14, USStoreReporting

		Part1: Creates stats about the Table
		Part2: Shows Datepart versus Datetime Run Times

REASON:	Datepart is a SAS function. Yes, it can be passed through ODBC 
		and then interpreted by the SQL engine, but every OBs is tested.
		With a Large 3rd Party Dataset, Savings can be higher than 70%

          			 
BEGIN MODIFICATIONS
MOD FEB2016 Added Data Analytics step for Discovery 
END MODIFICIATIONS
-----------------------------------------------------------------------------------------*/

LIBNAME Susstore ODBC NOPROMPT="SERVER=CHQSQL14;
							DRIVER=SQL Server;
							Trusted Connection=yes;
							DATABASE=USStoreReporting;" 
							schema=dbo;

/*----------------------------------------
	Data Analytics	
	Know something about the DBMS Table
----------------------------------------*/
%let date = %sysfunc(date(),date9.);
%let day  = &sysday;
%let time = %sysfunc(time(),tod8.);

proc sql; create table work.schedule_stats as
	select "ST_IL_SCHEDULE" as dset, "&day" as day, "&date" as date, "&time" as time,
		  min(payment_date) as payment_date_min format datetime23.,
		  max(payment_date) as payment_date_max format datetime23.,
		  count(iloan_code) as iloan_code_cnt length=8 format comma15., 
		  count(distinct iloan_code) as iloan_code_dist length=8 format comma15., 
		  max(iloan_code) as iloan_code_max length=8 format 15., 
		  min(iloan_code) as iloan_code_min length=8 format 15.
	from susstore.st_il_schedule
	quit;

/*--------------------------------------------
Discovery: ~25Mil Obs, 1.6Mil Distinct Loans
---------------------------------------------*/
ods html style=sasweb;
proc print data=work.schedule_stats;
	run;


/*---------------------------------
	Efficiency Tests with Dates
	For this sample, date subset
	produces ~350K obs from ~25M
	About 3.5 min versus 35 sec
----------------------------------*/
data work.test1;
	set susstore.st_il_schedule;
	where datepart(payment_date) >= '01JAN2015'd;
	run;

data work.test2;
	set susstore.st_il_schedule;
	where payment_date >= '01JAN2015 00:00:00'dt;
	run;

