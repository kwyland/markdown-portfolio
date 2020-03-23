%let names=;
proc sql noprint;
select	case when upcase(name) then catx('=',name,lowcase(name)) else ' ' end into : names separated by ' '

  	from dictionary.columns
    	where libname='WORK' and memname='LOANS';
	quit;

%put &names;
