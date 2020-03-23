/*data work.play (keep=iloan_code prin_paid int_ax_paid int_bank_paid total_paid);*/
/*	set work.perf_final;*/
/*	where iloan_code = 10808817;*/
/*	total_paid = sum(prin_paid + int_ax_paid + int_bank_paid);*/
/*	run;*/

data work.play2;
	set work.play;
	total_paid = round(sum(0,prin_paid,int_ax_paid,int_bank_paid),.2);
	total_paid2 = sum(0,prin_paid,int_ax_paid,int_bank_paid);
	format total_paid total_paid2 comma15.;
	run;
ods listing;
proc print; run;
