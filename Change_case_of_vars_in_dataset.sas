proc sql noprint;
	select catx('=',name,lowcase(name)) into : names separated by ' '
  	from dictionary.columns
    	where libname='' and memname='CLP_RETAIL_MIS';
	quit;

%put &names;

proc datasets lib=SASDL nolist;
	modify CLP_RETAIL_MIS;
	rename &names;
	quit;
