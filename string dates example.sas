
/*---------- String Dates ---------------------------
	This works fast whereas same pull
	using datepart(ts) = sas date takes
	8 minutes
---------------------------------------------------*/

/*----------------
Is sql faster using timestamp out fully rather than datepart?
YES - for smaller queries 8 min ver few seconds
------------------*/

libname  wnliapp  ODBC DSN='WNLIdec' user=kwyland pw=Bapu$1369 schema=dbo;
data work.stuff;
	set wnliapp.tu_ln_analysis (keep=approvalid id ts fpscore fpmed fphigh tuscore 
		tumed tuhigh segment channel);
	where datepart(ts) > '31OCT2015'd;
	run;

libname  wnliapp  ODBC DSN='WNLIdec' user=kwyland pw=Bapu$1369 schema=dbo stringdates=yes;
data work.tu_ln_analysisz;
	set wnliapp.tu_ln_analysis (keep=approvalid id ts fpscore fpmed fphigh tuscore 
		tumed tuhigh segment channel);
	where ts > '2015-11-01 00:00:00.000';
	run;

/*--- reset libname in case used in other code ---*/
libname  wnliapp  ODBC DSN='WNLIdec' user=kwyland pw=Bapu$1369 schema=dbo;* stringdates=yes;* readbuff=500; 


/*---------- Sample literals depending on Database Scheme -----
For April1 2014 use >= '2014-04-01 00:00:00.000';

'2013-12-20 11:38:15.207'
'2014/05/12 09:49:12'
'2011-04-12T00:00:00.000'
{ts '2013-02-01 15:00:00.001'}
------------------------------------------------------*/

*---which is faster???---;
data work.tu_ln_analysis;
	set wnliapp.tu_ln_analysis (keep=approvalid id ts fpscore fpmed fphigh tuscore
		tumed tuhigh segment channel);
	/*--- trying different coding techniques ---*/
	*where ts >= '01AUG2014 00:00:00'dt;
	where ts >= &start_date;
	*where datepart(ts) >= &start_date;
	run;

