
data _null_; *file print;
	attrib hours format=z2.;
	string = '3:45:13.00';
	*string = '33:33.33';
	howmany = countc(string,':','i');
	if howmany > 1 then 
		do;
			x = substr(string,1,2);
			y = compress(x,":");
			hours = input(y,3.);
		end;
	if howmany =1 then hours = 0;
	mins = substr(string,index(string,':')+1,2);
	put _all_;
run;



