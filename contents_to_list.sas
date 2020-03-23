
/*--- get a list of vars from contents to use in drop or keep or where clauses ---*/

%let dset = exp.karen_sample;

proc contents data=&dset noprint out=work.contents (keep=name npos length);
	run;

proc sort data=work.contents; by npos; run;

data _null_; file "pp_head.txt" lrecl=10000;
	set work.contents;
	put @npos name @;
	run;

data _null_; file "pp_sas_code.txt";
	set work.contents;
	put 'put @@' +(-1) npos name;
	run; 

	

proc fslist file="pp_sas_code.txt"; run;



proc export data=exp.karen_sample (obs=5000)
    outfile='g:\kwyland\karen_sample.txt'
    dbms=csv
    replace;
run;

