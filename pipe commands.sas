data _null_;
     infile 'echxxhello' pipe ;
     input ;
    put _infile_;
   run;


filename oscmd pipe "dir *.* 2>&1";
data _null_;
infile oscmd;
input;
put _infile_;
run;
*local_dw;
*filename copycmd pipe "ROBOCOPY g:\tempoe\temp_local_dw G:\tempoe\local_dw /MIR /COPY:DT /DCOPY:T";

libname test "G:\Tempoe\SAS_Configs";

*test file;
* NFL is NO FILE LIST, just header and summary;
filename copycmd pipe 
"robocopy g:\tempoe\sas_configs Z:\CreditPolicy\WNLI\WylandK\test_copydir /MIR /NFL /COPY:DT /DCOPY:T /LOG:g:\tempoe\sas_logs\robocopy.log";


data _null_;
	infile copycmd;
	input;
	put _infile_;
	run;

proc fslist file="g:\tempoe\sas_logs\robocopy.log";run;

