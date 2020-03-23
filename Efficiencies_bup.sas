/* ----------------------------------------------------------------------------------------
PROGRAM:  DEV(Efficiences)
AUTHOR:	Karen Wyland, NOV2015
PURPOSE:	Explanations/Examples of various Inefficiencies and How to Correct 

		1) Passing the SAS Datetime function thru SQL
		2) Invalid or Missing arguments to SAS functions
		3) WARNING: Variable already exists...
		    
BEGIN MODIFICATIONS
MOD
END MODIFICIATIONS
-----------------------------------------------------------------------------------------*/

/*--------------------- (1) ------------------------------
	Date Subsetting in SQL to 3rd Party Databases
	   with SAS datetime format instead of passing 
	   the SAS function datepart()

	The datepart function requires SQL to bring
	every observation to SAS to process that 
	SAS function

-----> Results: Easily 50%, Can be ~70% to 80% reduction in Real Time <------

	How-To use the datetime to obtain correct results
	(remember that time includes HH:MM:SS so you have to be specific)

	1) want all obs where date is greater than 01JAN2015
		then use >= '02JAN2015 00:00:00'dt
			 or > '01JAN2015 59:59:59'dt
	
	Note:  Both generate the same results, it is merely a preference.

	2) want all obs where date is less than 01JAN2015
	 	then use < '01JAN2015 00:00:00'dt
			or <= '31DEC2014 59:59:59'dt
---------------------------------------------------------*/

/*-----------------------------
	Sample code to Run
------------------------------*/
Libname susstore ODBC NOPROMPT="SERVER=CHQSQL14;
								DRIVER=SQL Server;
								Trusted Connection=yes;
								DATABASE=USStoreReporting;" 
								schema=dbo;


/*--- Using datepart with SAS date format ---*/
proc sql; create table work.date1
	as select * from susstore.st_il_trans
	where datepart(tran_date) >= '11JAN2014'd;
	quit;

/*--- Using datetime SAS format ---*/
proc sql; create table work.date2
	as select * from susstore.st_il_trans
	where tran_date >= '11JAN2014 00:00:00'dt;
	quit;

*=================== Sample Log Results =================================
791  /*--- Using datepart with SAS date format ---*/
NOTE: The data set WORK.DATE1 has 9849427 observations and 57 variables
NOTE: PROCEDURE SQL used (Total process time):
      real time           2:17.45
      user cpu time       2:02.39
      system cpu time     6.42 seconds
      memory              670.93k
      OS Memory           12996.00k
      Timestamp           01/15/2016 12:48:10 PM

797  /*--- Using datetime SAS format ---*/
NOTE: The data set WORK.DATE2 has 9849427 observations and 57 variables
NOTE: PROCEDURE SQL used (Total process time):
      real time           47.92 seconds
      user cpu time       35.64 seconds
      system cpu time     2.68 seconds
      memory              602.21k
      OS Memory           12996.00k
      Timestamp           01/15/2016 12:48:58 PM
=============================================================================;


/*----------------------- (2) ---------------------------------
	Invalid (or missing) arguments to SAS function
--------------------------------------------------------------
Pay careful attention as there can be issues later on 
that produce unwanted results.

1) Remember that arithmatic calculations on missings = missing.
+ - * / (add, substract, multiply, divide)

2) Various SAS procs do not use missing values by default:
	ex: proc means, proc freq
although there are options for missing that can be stated

3) Various SAS functions will calculate results incorrectly
	example avg(length) sum(length)

-----------------------------------------------------------*/

/*-----------------------------
	Sample Code to run
-----------------------------*/
/*--- Create dataset with missing values for test ---*/
proc sql;
	create table work.missings as
	select 
		iloan_code
		,inst_num
		,inst_amt
		,payment_date
		,inst_due_date
 	from susstore.st_il_schedule
  	/*--- subset for sample ---*/
	where payment_date = .
	;quit;

proc sql; 
	create table work.payments1 as
	select 
		iloan_code
		,inst_num
		,inst_amt
		,datepart(payment_date) as payment_date format date9.
		,datepart(inst_due_date) as inst_due_date format date9.
	from work.missings;
	quit;
	
proc sql; 
	create table work.payments2 as
	select 
		iloan_code
		,inst_num
		,inst_amt
		,case when payment_date ne . then datepart(payment_date) 
		 	else . end as payment_date format=date9.
		,case when inst_due_date ne . then datepart(inst_due_date) 
		 	else . end as inst_due_date format=date9.
	from work.missings;
	;quit;




/*----------------------- (3) --------------------------------
	WARNING: Variable already exists....

	In proc sql, variable on first table referenced wins;
	In data step using merge, last table wins
------------------------------------------------------------*/
