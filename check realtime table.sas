

/*=============== Check for Realtime Table - Offline at 10, 12, 2, 4, and 7 ===================*/
libname realtime oracle user=wmcdonald pwd=Um3sT45s path=Online schema=ST3_REP_TAB;
%macro check_table;
%global rt_app;
	proc sql noprint;
		select count(distinct app_no) into :rt_app TRIMMED
		from realtime.bo_in_app_queue
		;
		quit;
%put Inside check-table Macro: Realtime Table, BO_IN_APP_QUEUE NObs --->  &rt_app  <--- as of %sysfunc(time(),tod8.);  
%mend;

%macro Loopy;
%let i=1;
%check_table
 	%do %while(&rt_app <= 0);
		%check_table
		%put /"---> Inside Loopy ( " &i ") --> Table OBS = " &rt_app ;
		%put "Sleeping every 2 minutes " %sysfunc(sleep(60,2)); 
		%let i=%eval(&i+1); 
	%end;
	%put /"---> Outside Loop --> DONE Now Available - Realtime Table has &rt_app. OBS"/;
 %mend Loopy;                                                                                                                                 
%Loopy;
