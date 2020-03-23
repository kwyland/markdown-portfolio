proc format;
  picture abbrev
    0              = '0'
    0     -< 1000  = '000' 
    1000  - high   = '0,000,000.0k' (mult=.01)
    ;
run; 

%put %sysfunc(sum(123456.0),abbrev.) /*SHOULD BE SOMETHING LIKE 123K  */
     %sysfunc(sum(12345.60),abbrev.) /*SHOULD BE SOMETHING LIKE 12.3K */
     %sysfunc(sum(1234.560),abbrev.) /*SHOULD BE SOMETHING LIKE 1.3K  */
     %sysfunc(sum(123.4560),abbrev.) /*SHOULD BE SOMETHING LIKE 123   */
     %sysfunc(sum(12.34560),abbrev.) /*SHOULD BE SOMETHING LIKE 12    */
     %sysfunc(sum(1.234560),abbrev.) /*SHOULD BE SOMETHING LIKE 1     */
     ;
