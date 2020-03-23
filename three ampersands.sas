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

