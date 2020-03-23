/* ----------------------------------------------------------------------------------------
PROGRAM:  ADMIN(Log_Stats)
AUTHOR:	Karen Wyland, NOV2015
PURPOSE:	Analyze Process logs for Errors, Warnings, Real Time and Send Email Report
NOTES:	Section 1: Real Time by Procedure/Step
		Section 2: Errors, Warnings, Invalids, Missings, etc.
		Section 3: Update Process Stats
		Section 4: Email Notification

USAGE:	This program requires 3 Macros be set and then include this program. Ex:
			%let pgm = Local Data Warehouse PartB;
			%let logfile = &log_dir.\Local Data Warehouse PartB.log;
			%let outfile = &out_dir.\Local Data Warehouse PartB Log Stats.html;
			%include admin(log_stats);
NEEDS:	KLW Log Stats also written to log dir cummulatively for each process
		Do not want to keep too many.  Need way to archive each month.
			    
BEGIN MODIFICATIONS
MOD DEC2015 Added pid to stats - check for last process run (can be multiple runs per pgm)
END MODIFICIATIONS
-----------------------------------------------------------------------------------------*/
ods html close;
%macro testing;
%let pgm = Local Data Warehouse PartA;
%let logfile = &log_dir.\Local Data Warehouse PartA.log;
%let outfile = &out_dir.\Local Data Warehouse PartA Log Stats.html;
%let pgm = Local Data Warehouse PartB;
%let logfile = &log_dir.\Local Data Warehouse PartB.log;
%let outfile = &out_dir.\Local Data Warehouse PartB Log Stats.html;
%let pgm = Approval Reporting;
%let logfile = &log_dir.\Approval Reporting.log;
%let outfile = &out_dir.\Approval Reporting Log Stats.html;
%let pgm = Base Performance;
%let logfile = &log_dir.\Base Performance.log;
%let outfile = &out_dir.\Base Performance Log Stats.html;
%mend;

/*=============== Section One: Real Time by Procedure/Step  =================*/

data work.stuff (keep=process min sec totsec ctotsec);
	format process $35. min sec 9.2 totsec ctotsec time8.;
	label process='Process' sec='Seconds Found' min='Minutes Found' totsec ='Total HH:MM:SS' ctotsec='Cummulative Time';

	infile "&logfile" PAD MISSOVER end=thatisit ls=136 lrecl=136;     
	input aline $char136.;

	/*--- What process was running; retain it to calculate stats ---*/
	if index(aline,'(Total process time)') 
		then process = upcase(scan(aline,2,' ') || ' ' || scan(aline,3,' '));
	retain process ;

	/*--- Realtime took Minutes - there is no word after ---*/
	if substr(aline,31,1) ne ':';  *last line of log with total time;
	if index(aline,'real time   ') ne 0 and index(aline,'seconds') = 0 then 
		do;
			colon=index(aline,':');
			realtime = substr(aline,colon-3); 
			min=input(substr(aline,colon-2,2),3.);
			cmin+min;
			sec=input(substr(aline,colon+1),8.); 
			csec+sec;
		     totsec  = sum((min*60),sec,0);
			ctotsec = sum((cmin*60),csec,0);
		   output;
		end;

	/*--- Realtime did NOT go to Minutes, so search for word Seconds ---*/
	if process ne '';
	if index(aline,'real time   ') ne 0 and index(aline,'seconds') ne 0 then 
		do;
			dec=index(aline,'.');
			realtime = substr(aline,dec-2); 
			cmin+min;
			sec=input(substr(aline,dec-2,5),8.); 
			csec+sec;
		    totsec  = sum((min*60),sec,0);
			ctotsec = sum((cmin*60),csec,0);
		call symput('Tot_time',put(ctotsec,time8.));
		output;
		end;
	run;
%put &tot_time;

title "&logfile";
/*---No nway gives total for all --*/
proc summary data=work.stuff;
	class process;
	var totsec;
	output out=summed  sum=;
	run;
/*---Freq with _type_ = 0 or ALL will be at top --*/
proc sort data=work.summed; by descending _freq_; run;

/*--- Use blank process for _type_=0 for Steps summary --*/
data work.fluff (drop=_type_);
	set work.summed;
	if _type_ = 0 then process='TOTAL STEPS';
	run;

ods html body="&outfile" style=HTMLBlue; 
options ls=150;
ods listing;

title2 "Summary Stats";
proc print data=work.fluff label split=' '; run;
title2 "Detailed Procs and Steps";
proc print data=work.stuff label split=' '; run;

/*=============== Section Two: Errors, Warnings, Invalids, Missings, etc. ===========*/

title1 "LOG Analyzer: &pgm ";
title2 "(Line#) and Actual Line of Text";
title3 "Checking for: Errors, Warning, Uninitialized, Invalid (or missing) Arguments, Processing on Disk and Includes (of other programs).";   

data work.log_stats; file print;                                             
     attrib type format=$8.;
	attrib program format=$50.;

     infile "&logfile" PAD MISSOVER end=thatisit ls=136 lrecl=136;                 
     input aline $char136. ;                                                    

	if index (aline,'PROGRAM:') then 
	   do; type='program';
		program = trim(aline);
		put / '(' _n_ 5.0 ') ' program;*aline;
	   end;
	
	if index(aline,'uninitialized') then
        do; unin+1; type='uninit';
		put / '(' _n_ 5.0 ') ' aline;
        end;

	if index(aline,'Invalid (or missing) arguments') then
	   do; invalid+1; type='invalid';
	      put / '(' _n_ 5.0 ') ' aline;
	   end;

     if index(aline,'Processing on disk') then                                       
        do; disk+1; type='disk';                                                            
            put / '(' _n_ 5.0 ') ' aline;                                       
        end;                                                                    

     if index(upcase(aline),'%INC') then                                       
        do; incl+1; type = 'include';                                                            
            put / '(' _n_ 5.0 ') ' aline;                                       
        end;                                                                    

	if index(aline,'ERROR')   =1 then                                          
        do; put / '(' _n_ 5.0 ') ' aline;
		 if index(aline,'Libname') then do; lib_error+1; type='lib_error'; end;
		else					    do;  oops+1; type = 'error'; end;
	   end;                                                                    

     if index(aline,'WARNING') =1 then                                          
        do; put   '(' _n_ 5.0 ') ' aline;                                        
           if index(aline,'Apparent') then do; unresolv+1; type='unresolv'; end;                          
          else                         do;   warn+1    ;  type='warn'; end;
        end;                                                                    

     if substr(aline,1,4) = '<---' then do;
        if index(aline,'TS') then do; type='time';
           put  '(' _n_ 5.0 ') ' aline;
        end; end;

     if index(aline,'NOTE:')=1 and index(aline,'used') then                 
        do;  steps+1 ; type='steps'; end;

     if thatisit then                                                           
        do;	file logs("log_stats_&pgm..txt") mod;
             put _PAGE_
			//"Program: [&pgm]" 
			/"Date: &slash_date %sysfunc(time(),tod8.) Run Time: &tot_time"
		     // "Errors ________________________________" oops
			/  "  Libname Errors ______________________" lib_error
               /  "Warnings ______________________________" warn
               /  "  Unresolved __________________________" unresolv            
			/  "Invalid or Missing Arugments __________" invalid                
               /  "Unintialized __________________________" unin
               /  "Processing on Disk vs Memory __________" disk
               /  "Includes ______________________________" incl                
               /  "Data/Proc steps _______________________" steps               
               ;
        end;
     format oops lib_error warn unin incl unresolv disk steps invalid z4.;
	if type ne '' then output;
	call symput('oops',compress(left(oops)));
     run;

data work.sum_stats (drop=type program aline);
	set work.log_stats end=eof;
	if eof then output;
	run;

/*=================== Section Three: Update Process Stats ============================*/
/*--------------------------------------------------------------------------------------
	Update Master Process Stats Table 
	- Collect stats for current process (end_time, pgm, errors)
	- Create process id (pid) representing the number of times run.
	- Used for other processes for decision to run by checking for errors in dependent processes. 
	- Can be multiple runs for each pgm so need to number runs with a pid
	- End_time, errors from this pgm, Admin(log_stats)
--------------------------------------------------------------------------------------*/
option mprint mlogic;
%global lastpid;
%macro check_pid (pgm=pgm);
%if %sysfunc(exist(admin.process_stats_&year_mon.)) %then %do;
proc sql; create table work.pid as
	select max (pid) as lastpid, "&pgm" as pgm 
	from admin.process_stats_&year_mon.
	where pgm="&pgm";
	quit;
data _null_;
	set work.pid;
	if lastpid ne . then call symput('lastpid',trim(left(put(lastpid,8.))));
	else call symput('lastpid','0');
	run;
%end; 
%else %do;
%let lastpid=0; %end;
%mend;
%check_pid (pgm=&pgm);
%put lastpid=&lastpid;

data work.stats;
retain pid date end_time pgm tot_time errors syscc;
attrib pid length=8 format=4. label='process_id' pgm length=$50. errors length=$4. tot_time length=$10. syscc length=$10.;
	pid 		= input("&lastpid",8.) +1;
	date 	= "&slash_date";
	end_time 	= "%sysfunc(time(),tod8.)";
	pgm 		= "&pgm";
	tot_time 	= "&tot_time";
	errors 	= "&oops";
	syscc 	= "&syscc";
	run;

proc append base=admin.process_stats_&year_mon. data=work.stats force;
	run;

option nomprint nomlogic;


/*=================== Section Four: Email Notification ============================*/
ods html close;
OPTIONS EMAILSYS=SMTP EMAILHOST=apprelay.cngfinancial.com;
FILENAME mail EMAIL 'nul'

	/*--- Message Headings ---*/
/*	to		= ("&sys_user_email" "myauch@axcess-financial.com" "snarayanaswamy@tempoe.com" "kwyland@axcess-financial.com")*/
	to		= ("&sys_user_email") 
	subject 	= "[&pgm] Log Stats &slash_date"
	attach	= ("&logfile" "&outfile" content_type="text/html" lrecl=8196);
	;;;;

data _null_;
	file mail;
	set work.sum_stats;  			/*--this works for email because only one obs---*/
	/*--- Message Contents ---*/		/*--otherwise, message repeats for each obs---*/
	   do;  put _PAGE_
		   "Program: &pgm"
		/  "Date: &slash_date" " Time:%sysfunc(time(),tod8.)" " Run Time: &tot_time"
		// "Completed with ---->  &oops  <---- Errors. "
		///"- - - - - Recap - - - - - "
	     /  oops "Errors"
		/  lib_error "__Libname Errors"
          /  warn "Warnings"
		/  unresolv "__Unresolved"
		/  invalid "Invalid or Missing Arugments"
          /  unin "Unintialized"
		/  disk "Processing on Disk vs Memory"
          /  incl "Includes"
          /  steps "#Data/Proc steps"
          ;
        end;

	put //"Attached is the Log and a Log Statistics Reports showing:";
	put "(1) Processing times in Summary and by SAS Steps";
	put "(2) Audit Report results of important SAS messages, such as ERRORs, WARNINGs, INVALIDs, etc."; 
	put ///;
	run;

