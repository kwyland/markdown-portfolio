/* ----------------------------------------------------------------------------------------
PROGRAM:  PROD(Log_Stats)
AUTHOR:	Karen Wyland, NOV2015
PURPOSE:	Analyze Process logs for Errors, Warnings, Real Time and Send Email Report
NOTES:	Section 1: Real Time by Procedure/Step
		Section 2: Errors, Warnings, Invalids, Missings, etc.
		--Customized--Section 3: Update Process Stats
		Section 4: Email Notification

IMPORTANT:  Log files must be named .log

USAGE:	1) Environment Macros (automatic)
		Used for Email Parameters and Email Contents
		   sys_user_email: SAS login username plus domain - Change domain if other than axcess-financial.com
		   slash_date: Date format for Email stands out with '/'s.

		2) Filename for Path of log file to Read IN and Write TO for cummulative log stats.
		ex: Filename logs "G:\kwyland\sas_logs";  	(no filename, just path)

		3) Macros - requires these (3) MUST be set.
		%let pgm 		= Sample;					(used for Email Subject Line) 
		%let logfile 	= FullPath...\segments.log;   (full path and filename MUST end in .log)
		%let outfile 	= FullPath...\segments.html;  (full path and filename MUST end in .html)

BEGIN MODIFICATIONS
MOD
END MODIFICIATIONS
-----------------------------------------------------------------------------------------*/
ods html close;
%macro testing;
%let pgm = CDR_segments;
%let logfile = &log_dir.\CDR_segments.log;
%let outfile = &out_dir.\CDR_segments_LogStats.html;
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

	/*--- Realtime took Minutes - there is no word 'seconds' after ---*/
	if substr(aline,31,1) ne ':';  *exclude last line of log with total time;
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

/*--- Label Total - Use blank process for _type_=0 for Steps summary --*/
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
        do; oops+1; type = 'error';                                                            
           put / '(' _n_ 5.0 ') ' aline;
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
               /  "Processing on Disk vs Memory __________" disk
               /  "Warnings ______________________________" warn
			/  "Invalid or Missing Arugments __________" invalid                
               /  "Unintialized __________________________" unin                
               /  "Includes ______________________________" incl                
               /  "Unresolved ____________________________" unresolv            
               /  "Data/Proc steps _______________________" steps               
               ;
        end;
     format oops warn unin incl unresolv disk steps invalid z4.;
	if type ne '' then output;
	call symput('oops',compress(left(oops)));
     run;

data work.sum_stats (drop=type program aline);
	set work.log_stats end=eof;
	if eof then output;
	run;

/*=================== Section Four: Email Notification ============================*/
ods html close;
OPTIONS EMAILSYS=SMTP EMAILHOST=apprelay.cngfinancial.com;
FILENAME mail EMAIL 'nul'

	/*--- Message Headings ---*/
	to		= ("&sys_user.@axcess-financial.com" "mwgates@axcess-financial.com" "snaidu@axcess-financial.com")
	from 	= ("&sys_user.@axcess-financial.com")
	subject = "[&pgm] Log Stats &slash_date"
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
          /  disk "Processing on Disk vs Memory"
          /  warn "Warnings"
		/  invalid "Invalid or Missing Arugments"
          /  unin "Unintialized"
          /  incl "Includes"
          /  unresolv "Unresolved"
          /  steps "#Data/Proc steps"
          ;
        end;
	put //"Attached is the Log and a Log Statistics Reports showing:";
	put "(1) Processing times in Summary and by SAS Steps";
	put "(2) Audit Report results of important SAS messages, such as ERRORs, WARNINGs, INVALIDs, etc."; 
	put ///;
	run;

