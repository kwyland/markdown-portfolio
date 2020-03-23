/* ----------------------------------------------------------------------------------------
PROGRAM:  Macros_Three_Ampersands.sas
AUTHOR:	Karen Wyland, FEB2016
PURPOSE:	Pass a Where Clause set as a Macro by a %let statement to a %Macro

NOTE:	Can be run AS-IS. Check your log for Results!

BEGIN MODIFICATIONS
MOD 
END MODIFICIATIONS
-----------------------------------------------------------------------------------------*/



option mprint mlogic;

%let female = where sex = 'F';
%let male = where sex = 'M';
%let all = where sex ne '';

%macro tryit (subset=subset);
data work.stuff;
	set sashelp.class;
	&&&subset.;
	run;
%mend;
%tryit(subset=female);
%tryit(subset=male);
%tryit(subset=all);

