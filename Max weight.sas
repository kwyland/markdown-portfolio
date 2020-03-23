

data work.test;
retain max_weight;
	set sashelp.class;
	*---change which obs comes in first to see different values for max_weight being retained --;
	if _n_ > 0;  
	by name;
	if weight > max_weight then max_weight = weight;
	run;

ods html;
proc print data=work.test; 
	var name sex age height weight max_weight ;
	run;
