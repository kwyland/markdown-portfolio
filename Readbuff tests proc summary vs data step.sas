/*------------------------------------
	Proc Summary as originally coded
-------------------------------------*/
libname  wnliperf ODBC DSN='WNLIrto' user=kwyland pw=Bapu$1369 schema=dbo readbuff=500;
proc summary data=wnliperf.wnli_cart nway;
	class approvalid;
	var cost delivery installation warranty quantity;
	output out=work.wnli_cart2 sum=;
	run;

/*------------------------------------
	Proc Summary with readbuff=500
-------------------------------------*/
libname  wnliperf ODBC DSN='WNLIrto' user=kwyland pw=Bapu$1369 schema=dbo readbuff=500;
proc summary data=wnliperf.wnli_cart nway;
	class approvalid;
	var cost delivery installation warranty quantity;
	output out=work.wnli_cart2 sum=;
	run;

/*------------------------------------
	Proc Summary with readbuff=1000
-------------------------------------*/
libname  wnliperf ODBC DSN='WNLIrto' user=kwyland pw=Bapu$1369 schema=dbo readbuff=1000;
proc summary data=wnliperf.wnli_cart nway;
	class approvalid;
	var cost delivery installation warranty quantity;
	output out=work.wnli_cart2 sum=;
	run;

/*------------------------------------
	Proc Summary with readbuff=1500
-------------------------------------*/
libname  wnliperf ODBC DSN='WNLIrto' user=kwyland pw=Bapu$1369 schema=dbo readbuff=1500;
proc summary data=wnliperf.wnli_cart nway;
	class approvalid;
	var cost delivery installation warranty quantity;
	output out=work.wnli_cart2 sum=;
	run;

/*-----------------------------------
	Proc Summary with Where Clause
	for Dates and Readbuff=
	as evaluated in previous runs 
------------------------------------*/
libname  wnliperf ODBC DSN='WNLIrto' user=kwyland pw=Bapu$1369 schema=dbo readbuff=1500;
proc summary data=wnliperf.wnli_cart (where=(datepart(ts) > '31DEC2013'd)) nway;
	class approvalid;
	var cost delivery installation warranty quantity;
	output out=work.wnli_cart2 sum=;
	run;

/*-----------------------------------
	Data Step with Where
	for Dates and Readbuff=500
	and then proc summary
------------------------------------*/
OPTIONS THREADS CPUCOUNT=2; /*Set the THREADS option */ 
libname  wnliperf ODBC DSN='WNLIrto' user=kwyland pw=Bapu$1369 schema=dbo readbuff=2000;
data work.stuff;
	set wnliperf.wnli_cart (where=(datepart(ts) > '31DEC2013'd) 
		 keep=approvalid ts cost delivery installation warranty quantity);
	run;

proc summary data=work.stuff nway;
	class approvalid;
	var cost delivery installation warranty quantity;
	output out=work.wnli_cart2kw sum=;
	run;


