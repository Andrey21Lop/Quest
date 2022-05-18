@isTest
private class NG_TimeSheetCtrl_Test 
{

	@testSetup 
    static void setupData() 
    {
    	NGCS__C ngcs = new NGCS__C(Name='Main',NG_Debug_Flag__c=TRUE, TS_OverWriteShifts__c=TRUE); insert ngcs;
    	TR1__TimeType__c tt1 = new TR1__TimeType__c(Name = 'Regular', TR1__EntryType__c = 'Hours & Minutes', TR1__ShowAs__c = 'Hours');
    	TR1__TimeType__c tt2 = new TR1__TimeType__c(Name = 'Overtime', TR1__EntryType__c = 'Hours & Minutes', TR1__ShowAs__c = 'Hours');
    	insert tt1; insert tt2;
    	
    	Account acc = new Account(Name='Calif Account Test'); insert acc;
        Contact con = new Contact(LastName='Approv Calif Contact Test',Email='abac@abconsulting.com',AccountId=acc.Id);insert con;
    	
    	Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Job__c job1 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 1', TR1__Contact__c = con.Id); insert job1;
        
        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
 
    	List<TR1__Closing_Report__c> l_crs = new List<TR1__Closing_Report__c>();
    	TR1__Closing_Report__c cr;
    	for(Integer iCR = 0 ; iCR < 3 ; iCR++)
    	{
    		cr = new TR1__Closing_Report__c();
    		cr.RecordTypeId = crconsultingId;
    		cr.TR1__Person_Placed__c = con.Id;
    		cr.Candidate_Type__c = 'Non-Physician';
    		cr.TR1__Job__c = Job1.Id;
    		cr.TR1__Timesheet_Approver__c = null;
    		cr.TR1__Timesheet_Second_Approver__c = null;
    		cr.TR1__Account__c = acc.Id;
    		cr.TR1__Generate_Timesheet__c = true;
 			l_crs.add(cr);
    	}
        Test.startTest();
    	insert l_crs;
    	Test.stopTest();
        
    	List<TR1__Rate__c> l_rates = new List<TR1__Rate__c>();
    	TR1__Rate__c rate;
    	Id RType = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Closing Report Rate').getRecordTypeId();
    	for(TR1__Closing_Report__c cr1 : l_crs)
    	{
    		rate = new TR1__Rate__c();
    		rate.Name = tt1.Name;
    		rate.RecordTypeId = RType;
    		rate.TR1__Active__c = true;
    		rate.TR1__ClosingReport__c = cr1.Id;
    		rate.TR1__Job__c = Job1.Id;
    		rate.TR1__RateBill__c = 20;
    		rate.TR1__RatePay__c = 10;
    		rate.TR1__TimeType__c = tt1.Id;
    		
    		l_rates.add(rate);
    		
    		rate = new TR1__Rate__c();
    		rate.Name = tt2.Name;
    		rate.RecordTypeId = RType;
    		rate.TR1__Active__c = true;
    		rate.TR1__ClosingReport__c = cr1.Id;
    		rate.TR1__Job__c = Job1.Id;
    		rate.TR1__RateBill__c = 30;
    		rate.TR1__RatePay__c = 15;
    		rate.TR1__TimeType__c = tt2.Id;
    		
    		l_rates.add(rate);
    	}
    	insert l_rates;
    	    	
    	List<NG_TimeSheet_Load__c> l_tsl = new List<NG_TimeSheet_Load__c>();
    	Integer ctr = 0;
    	for(TR1__Closing_Report__c cr1 : l_crs)
    	{			
			if(ctr == 0)
			{
				l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Regular',DateWorked__c=Date.parse('12/2/2017'), ClosingReportID__c = cr1.Id,Hours__c = 1,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));
				l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Overtime',DateWorked__c=Date.parse('12/2/2017'), ClosingReportID__c = cr1.Id,Hours__c = 1,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));

				l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Regular',DateWorked__c=Date.parse('12/3/2017'), ClosingReportID__c = cr1.Id,Hours__c = 1,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));
				l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Overtime',DateWorked__c=Date.parse('12/3/2017'), ClosingReportID__c = cr1.Id,Hours__c = 1,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));
				
				l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Regular',DateWorked__c=Date.parse('12/4/2017'), ClosingReportID__c = cr1.Id,Hours__c = 7,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));
				l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Overtime',DateWorked__c=Date.parse('12/4/2017'), ClosingReportID__c = cr1.Id,Hours__c = 2,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));
				ctr++;
			}
			else
			{
				l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Regular',DateWorked__c=Date.parse('12/2/2017'), ClosingReportID__c = cr1.Id,Hours__c = 7,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));
				l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Overtime',DateWorked__c=Date.parse('12/2/2017'), ClosingReportID__c = cr1.Id,Hours__c = 2,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));

				l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Regular',DateWorked__c=Date.parse('12/3/2017'), ClosingReportID__c = cr1.Id,Hours__c = 7,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));
				l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Overtime',DateWorked__c=Date.parse('12/3/2017'), ClosingReportID__c = cr1.Id,Hours__c = 2,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));				
			}
/*			
			l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Regular',DateWorked__c=Date.parse('12/5/2017'), ClosingReportID__c = cr1.Id,Hours__c = 7,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));
			l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Overtime',DateWorked__c=Date.parse('12/5/2017'), ClosingReportID__c = cr1.Id,Hours__c = 2,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));

			l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Regular',DateWorked__c=Date.parse('12/6/2017'), ClosingReportID__c = cr1.Id,Hours__c = 7,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));
			l_tsl.add(new NG_TimeSheet_Load__c(TimeTypeName__c = 'Overtime',DateWorked__c=Date.parse('12/6/2017'), ClosingReportID__c = cr1.Id,Hours__c = 2,WeekEndingDate__c = Date.parse('12/7/2017'),WeekStartingDate__c=Date.parse('12/1/2017')));
*/
    	}
    	insert l_tsl;
    	
    	TR1__Timesheet__c ts = new TR1__Timesheet__c();
        ts.TR1__Closing_Report__c = l_crs.get(0).Id;
        ts.TR1__Consultant__c = con.Id;
        ts.TR1__Job_Order__c = Job1.Id;
        ts.TR1__Client__c = acc.Id;
        ts.TR1__Week_Ending__c = Date.parse('12/7/2017');
	    ts.TR1__Pay_Week_Ending__c = Date.parse('12/7/2017');
	    insert ts;

    	Id RType_CR = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Closing Report Rate').getRecordTypeId();
    	List<TR1__Rate__c> l_ERates = new List<TR1__Rate__c>();
    	TR1__Rate__c ERate;
    	Id RType_TS = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Timesheet Rate').getRecordTypeId();
    	List<TR1__Rate__c> CRRates = [SELECT Id, Name, TR1__ClosingReport__c, TR1__Job__c, TR1__Timesheet__c, TR1__TimeType__c, TR1__Rate_Type_Name__c, TR1__RatePay__c, TR1__RateBill__c FROM TR1__Rate__c WHERE TR1__ClosingReport__c =: l_crs.get(0).Id and RecordTypeId =: RType_CR];
    	for(TR1__Rate__c crt : CRRates)
    	{
    		ERate = new TR1__Rate__c();
    		ERate.Name = crt.Name;
    		ERate.RecordTypeId = RType_TS;
    		ERate.TR1__Active__c = true;
    		ERate.TR1__ClosingReport__c = crt.TR1__ClosingReport__c;
    		ERate.TR1__Timesheet__c = ts.Id;
    		ERate.TR1__Job__c = crt.TR1__Job__c;
    		ERate.TR1__RateBill__c = crt.TR1__RateBill__c;
    		ERate.TR1__RatePay__c = crt.TR1__RatePay__c;
    		ERate.TR1__TimeType__c = crt.TR1__TimeType__c;   		
    		l_ERates.add(ERate);
    	}
    	insert l_ERates;
		
//Create only 2 TSD not the Third
		List<NG_TimeSheet_Load__c> l_tslFortsd = [SELECT Id, TimeTypeName__c, DateWorked__c, ClosingReportID__c, Hours__c, WeekEndingDate__c, WeekStartingDate__c FROM NG_TimeSheet_Load__c WHERE ClosingReportID__c =: l_crs.get(0).Id ORDER By DateWorked__c];
		ctr = 0;
		TR1__Timesheet_Detail__c tsd;
		for(NG_TimeSheet_Load__c tsl : l_tslFortsd)
		{
			if(ctr < 2)
			{
	    		tsd = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = ts.id, TR1__Date__c = tsl.DateWorked__c, TR1__Day__c = TR1.Utility.dayOfDate(tsl.DateWorked__c));
				insert tsd;
			}
		}
    	
    }
    
    static testMethod void myUnitTest() 
    {
		Test.startTest();
		NG_TimeSheetCtrl tslBatch = new NG_TimeSheetCtrl();
		Id batchId = Database.executeBatch(tslBatch);
//		tslBatch.start();
		Test.stopTest();
		
        
    }
}