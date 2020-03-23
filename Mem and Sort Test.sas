proc options option=memsize lognumberformat define value; run;
proc options option=sortsize lognumberformat define value; run;


Title "Using Default Config for Memsize and Sortsize";
data work.random_15meg;
	array x (200);
	do i=1 to 200;
	x(i)=ranuni(i);
	end;
	do i=1 to 15500000;
	output;
	 end;
 run; 

proc sort data=work.random_15meg out=work.sorted; 
	by x1;
	run;
