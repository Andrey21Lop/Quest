global class NG_GPExportCtrlSchedulable implements Schedulable{
    //Timing of this Schedule class is controlled by Salesforce UI in Apex Jobs Schedulable
	global void execute(SchedulableContext sc) {
        
	      NG_GPExportCtrlBatch ngGPExpoerControBatch = new NG_GPExportCtrlBatch();
	      Database.executeBatch(ngGPExpoerControBatch, 10);
        
	   }
}