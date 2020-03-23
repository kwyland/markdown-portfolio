
libname exp 'G:\SashiNaidu\Online_Data_pull_Jun16';

/*--- Creates 100 obs of just one numeric (decimal) formatted value and a converted char format ---*/
data work.stuff (keep=nus_score nus_score_char);
	set exp.karen_sample (obs=100);
	where nus_score ne . ;
	nus_score_char = put(nus_score,10.2);
	run;

/*--- Export to tab delimeted ---*/
proc export data= work.stuff 
     outfile= "g:\kwyland\out to stuff.txt" 
     dbms=tab label replace;
     putnames=yes;
run;

data _null_; file 'g:\kwyland\fixed_width.txt';
	set work.stuff;
	if _n_ = 1 then 
	put @1 'nus_score' @11 'nus_score_char';
	else put @1 nus_score @11 nus_score_char;
	run;

proc fslist file='g:\kwyland\fixed_width.txt'; run;

/*--- Import Data back into SAS Dataset ---*/
data work.fluff;
	infile 'g:\kwyland\out to stuff.txt' delimiter='09'x missover dsd lrecl=32767 firstobs=2 ;
  	informat nus_score 10.;
  	informat nus_score_char $6.;
  	format nus_score 10.2;
  	format nus_score_char $6.;
	input
           nus_score
           nus_score_char
	;run;

