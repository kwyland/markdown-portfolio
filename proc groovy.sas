proc groovy; 
	submit;
	def name='World';
	println "hello $name!"
	endsubmit;
quit;

proc groovy ;
 submit;
 class Speaker {
 def Speaker() {
 println "----> ctor"
 }
 def main( args ) {
 println "----> main"
 }
 }
 endsubmit;
quit;












proc groovy;

    submit;

        import groovy.json.*

        def input=new File(‘g:\kwyland\sas_external\test.json’).text

        def output = new JsonSlurper().parseText(input)

        println output    
        println ""

        output.each {println it}  

        println ""

        println output.address.streetAddress

        println "Street Address: $output.address.streetAddress"

        println output.address["streetAddress"]       


        exports = [fName1:output[‘firstName’]]    
        exports.put(‘fName2’, output[‘firstName’])  
         
        endsubmit;

quit;

%put fName1: &fName1;

%put fName2: &fName2;
