ods listing;

title "st_il_trans";
proc freq data=susstore.st_il_trans;
	table tran_id / missing norow nocol;
	quit;

title "ilp_distribution_details";
proc freq data=ncp.ilp_distribution_details;
	table tran_id / missing norow nocol;
	quit;
