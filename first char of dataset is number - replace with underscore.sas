data _null_;
	set work.stuff (obs=1);
	if _n_ = 1;
	if substr(memname,1,1) in ('0','1','2','3','4','5','6','7','8','9') 
	then memname = cat('_',substr(memname,2));
	put memname=;
	run;
