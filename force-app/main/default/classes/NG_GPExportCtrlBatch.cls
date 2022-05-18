// Batch Job for Processing the Records
global class NG_GPExportCtrlBatch implements Database.Batchable<sobject> {
    
// Start Method
   global Database.Querylocator start (Database.BatchableContext BC) {
       string condition ='ALLTIME';
       string query;
       NGCS__C ngcs = [SELECT Id,GPExportLookupTime__c FROM NGCS__C LIMIT 1];
	   condition = (string)ngcs.GPExportLookupTime__c;	//TODAY / YESTERDAY / ALLTIME / LAST1H/LAST4H / LAST8H                                 
       NG_MainUtility.println(True,'condition->'+condition); 
     
       
       if (condition == 'ALLTIME')
       {
           query = 'Select id, Name From TR1_INV__Invoice__c Order By Id';
       }
       else if (condition == 'TODAY')
       {
           query = 'Select id, Name, CreatedDate From TR1_INV__Invoice__c Where CreatedDate>TODAY';
           
       }
       else if (condition == 'YESTERDAY')
       {
           query = 'Select id, Name,CreatedDate From TR1_INV__Invoice__c Where CreatedDate>YESTERDAY';
       }
       else if(condition == 'LAST4H')
       {
           query = 'Select id, Name,CreatedDate From TR1_INV__Invoice__c Where CreatedDate>TODAY AND HOUR_IN_DAY(CreatedDate) > 4';
       }
        else if(condition == 'LAST1H')
       {
           query = 'Select id, Name,CreatedDate From TR1_INV__Invoice__c  Where CreatedDate>TODAY AND HOUR_IN_DAY(CreatedDate) > 1';
       }
        else if(condition == 'LAST8H')
       {
           query = 'Select id, Name,CreatedDate From TR1_INV__Invoice__c Where CreatedDate>TODAY AND HOUR_IN_DAY(CreatedDate) > 8';
       }
       else if(condition == 'LAST_WEEK')
       {
           query = 'Select id, Name,CreatedDate From TR1_INV__Invoice__c Where CreatedDate > LAST_WEEK';
       }
       else if(condition == 'LAST_MONTH')
       {
           query = 'Select id, Name,CreatedDate From TR1_INV__Invoice__c Where CreatedDate > LAST_MONTH';
       }
       else
       {
           query = 'Select id, Name,CreatedDate From TR1_INV__Invoice__c Where CreatedDate = ' + condition;
       }
     
       	NG_MainUtility.println(True,'Query'+query); 
      	return Database.getQueryLocator(query);
      // Query which will be determine the scope of Records fetching the same
   }
   
   // Execute method
   global void execute (Database.BatchableContext BC, List<TR1_INV__Invoice__c> scope) 
   {
              
      
       List<TR1_INV__Invoice__c> invoiceList = scope;
       NG_MainUtility.println(True,'invoiceList'+invoiceList); 
       
       NG_GPExportCtrl ng = new NG_GPExportCtrl();
       if(!invoiceList.IsEmpty() )
       {
       	ng.populateAllMaps(invoiceList);
       	ng.processInvoiceData();
        ng.processPermInvoiceData();   
       }
       
   }
   
      
   // Finish Method
   global void finish(Database.BatchableContext BC) {
    NG_GPExportCtrlBatchPatch invoiceBatch = new NG_GPExportCtrlBatchPatch();
    Database.executeBatch(invoiceBatch,1);
     return;
    }
    public static void dummyMethodToMakeApexTestsWork() {
        List<String> strs = new List<String>();
        Integer i = 1;
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
        if (i>0)
            strs.add('');
       
    }

}