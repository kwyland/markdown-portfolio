LIBNAME i2_uw2 	ODBC DATASRC ='axfin_i2_v2' DBMAX_TEXT=30000; 
/*---------------------------------
	Obtain ics scores from i2 
	Underwriting ~15 min. to run
	Applyto = bo_code
---------------------------------*/
proc sql ;
  create table work.i2_data as 
  select id as evaluationid 
	, modelid
	, applicationSource
	, evaluationStatus
	, applyDate
	, applyto
	, createdDate 
	, input(compress(scan(substr(evaluationResponse,find(evaluationResponse,'"internalCreditScore"'),40),2,":,"),',"}'),12.) as i2_ics_score
	, compress(scan(substr(evaluationRequest,find(evaluationRequest,'"documentTypeNumber"'),40),2,":,"),',"}') as I2_ssn
	FROM i2_uw2.evaluation  
	WHERE applicationSource = 'STARS4' and evaluationStatus = 'APPROVED' and applyDate >= "&report_start_date"d;
	quit;

proc sql; create table work.stuff as
	select 
	 id as evaluationid
	, applyto
	, createdDate 
	,scan(substr(value,findw(value,"eaScore",'"')),2,'."[{:,','rs') as eaScore
	,scan(substr(value,findw(value,"ipReputation",'"')),2,'."[{:,','rs') as IPReputation
	,scan(substr(value,findw(value,"status",'"')),2,'."[{:,','rs') as ValueStatus

	FROM i2_uw2.evaluationdetail  
	WHERE applicationSource = 'STARS4' and evaluationStatus = 'APPROVED' and 
	/*applyDate >= "&report_start_date"d;*/
	applyDate >= "14JUL2016"d
	;;;quit;

