
data sample;
  string='Your'||'05'x||'data'||'0D'x||'goes'||'0C'x||'here.'||'0A'x;
run;

data _null_;
  set sample;
  put string=;

  /* Verify each byte in string until no more non-printables are found */
  do until(test=0);

    /* For SAS 9.0 and above, NOTPRINT */
    test=notprint(string);

    /* prior to SAS 9.0, use VERIFY */
    *test=verify(upcase(string),' ABCDEFGHIJKLMNOPQRSTUVWXYZ,.1234567890');

    /* If a non-printable is found...replace it with a space */
    if test>0 then do;
      substr(string,test,1)=' ';
      end;
    end;
  put string=;
run;

/*--- print all control characters that are 'nonprintable' ---*/
data test; 
do dec=0 to 255;
   byte=byte(dec);
   hex=put(dec,hex2.);
   notprint=notprint(byte);
   output;
 end;

 proc print data=test;
 run;
