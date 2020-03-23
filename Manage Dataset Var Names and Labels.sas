/*--------------------------------
	Lowcase Var Names and
	remove Labels which come
	from 3rd Party Data
--------------------------------*/
ods _all_ close;
option pagesize=max;
ods html body="&out_dir.\MIS DW Contents after Fixing UpCase and Blanking out Labels.html" style=analysis options(pagebreak='no');
title; footnote;
title "MIS DW Datasets Contents";
footnote5 "Prog Name: %sysget(SAS_EXECFILENAME) **By: &SYSUSERID ** Run on: %sysfunc(datetime(),datetime16.)";

%macro dset_fix(dset=dset);

%let names=;
proc sql noprint;
	select catx('=',name,lowcase(name)) into : names separated by ' '
  	from dictionary.columns
    	where libname='SASDL' and memname="&dset";
	quit;

proc datasets lib=SASDL nolist;
	modify &dset;
	rename &names;
	quit;

/*---remove all labels because they are just the upper case of var name ---*/
proc datasets lib=SASDL nolist;
	modify &dset;
 	attrib _all_ label=' '; 
	quit;

proc contents data=sasdl.&dset.; run;

%mend;
%DSET_FIX(DSET=CLP_ILP_RETAIL_LOANS);
%DSET_FIX(DSET=CLP_ILP_RETAIL_PROFILE);
%DSET_FIX(DSET=CLP_ILP_RETAIL_SCORES);
%DSET_FIX(DSET=CLP_RETAIL_MIS);
%DSET_FIX(DSET=ILP_RETAIL_MIS);
%DSET_FIX(DSET=CLP_RETAIL_TRANS);
%DSET_FIX(DSET=ILP_RETAIL_TRANS);
%DSET_FIX(DSET=CLP_PERF_DETAIL);
%DSET_FIX(DSET=ILP_PERF_DETAIL);

ods _all_ close;



