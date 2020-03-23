/*----------------------------
	Discovery
------------------------------*/

*how many dates are missing?;
*answer is there are no missing inst_due_dates, but payment_date has values for about 40%+;
proc sql; create table work.schedule_stats as
	select min(datepart(payment_date)) as min_pay_date format date9.,
		  count(datepart(payment_date)) as cnt_pay_date format comma15.,
		  min(datepart(inst_due_date)) as min_inst_date format date9.,
		  count(datepart(inst_due_date)) as cnt_inst_date format comma15.,	
		  count(*) as tot_obs format comma15.
	from susstore.st_il_schedule;
	quit;

proc sql; create table work.trans_stats as
	select min(datepart(tran_date)) as min_tran_date format date9.,
		  count(datepart(tran_date)) as cnt_tran_date format comma15.,
		  min(datepart(return_date)) as min_return_date format date9.,
		  count(datepart(return_date)) as cnt_return_date format comma15.,	
		  count(*) as tot_obs format comma15.
	from susstore.st_il_trans;
	quit;

ods listing;
proc contents data=susstore.st_il_trans; run;

data WORK.VCOLUMN;
	SET sashelp.vcolumn;
	where memname in('ST_IL_TRANS','ST_IL_SCHEDULE');
	RUN;

proc summary data=work.vcolumn nway;
	class memname;
	var length;
	output out=summed sum=; run;

/*------------------------------------------
	Sample Code to run
	Check for Missings before SAS function
------------------------------------------*/
proc sql;
	create table work.schedule_miss as
	select 
		iloan_code
		,inst_num
		,inst_amt
		,case when payment_date ne . then datepart(payment_date)
			else . end as payment_date format=date9.
		,case when inst_due_date ne . then datepart(inst_due_date)
			else . end as inst_due_date format=date9.

/*		,datepart(payment_date) as payment_date format date9.*/
/*		,datepart(inst_due_date) as inst_due_date format date9.*/
 	from susstore.st_il_schedule
  	/*--- subset for sample ---*/
	where '01JAN2010'd < datepart(inst_due_date) < '01JAN2016'd;
/*	where '01JAN2010 00:00:00'dt < inst_due_date < '01JAN2016 00:00:00'dt*/
	;quit;

