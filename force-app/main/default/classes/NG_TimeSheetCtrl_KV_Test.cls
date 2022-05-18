@isTest
private class NG_TimeSheetCtrl_KV_Test 
{

	@testSetup 
    static void setupData() 
    {
    	Integer ctr = 0;
    	Integer totalCR = 3;
    	
    	NGCS__C ngcs = new NGCS__C(Name='Main',NG_Debug_Flag__c=TRUE, TS_OverWriteShifts__c=TRUE, TS_UseShiftUploadModel_KV__c=TRUE, TS_ShiftLoadTypes__c='New,New', TS_PopulateShifts__c=TRUE, TS_PopulateRates__c=TRUE); insert ngcs;
    	TR1__TimeType__c tt1 = new TR1__TimeType__c(Name = 'Regular', TR1__EntryType__c = 'Hours & Minutes', TR1__ShowAs__c = 'Hours');
    	TR1__TimeType__c tt2 = new TR1__TimeType__c(Name = 'Overtime', TR1__EntryType__c = 'Hours & Minutes', TR1__ShowAs__c = 'Hours');
    	insert tt1; insert tt2;
    	
    	Account acc = new Account(Name='Calif Account Test'); insert acc;
        Contact con = new Contact(LastName='Approv Calif Contact Test',Email='abac@abconsulting.com',AccountId=acc.Id);insert con;
    	
    	Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
    	List<TR1__Job__c> l_jobs = new List<TR1__Job__c>();
        TR1__Job__c job1 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 1', TR1__Contact__c = con.Id); l_jobs.add(job1);
        TR1__Job__c job2 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 2', TR1__Contact__c = con.Id); l_jobs.add(job2);
        TR1__Job__c job3 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 3', TR1__Contact__c = con.Id); l_jobs.add(job3);
        insert(l_jobs);
        
        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
    	List<TR1__Closing_Report__c> l_crs = new List<TR1__Closing_Report__c>();
    	TR1__Closing_Report__c cr;
    	for(Integer iCR = 0 ; iCR < totalCR ; iCR++)
    	{
    		cr = new TR1__Closing_Report__c();
    		cr.RecordTypeId = crconsultingId;
    		cr.TR1__Person_Placed__c = con.Id;
    		cr.Candidate_Type__c = 'Non-Physician'; //This will need to be commented on other SBs
    		cr.TR1__Job__c = l_jobs.get(iCR).Id;
    		cr.TR1__Timesheet_Approver__c = null;
    		cr.TR1__Timesheet_Second_Approver__c = null;
    		cr.TR1__Account__c = acc.Id;
    		cr.TR1__Generate_Timesheet__c = true;
 			l_crs.add(cr);
    	}
    	insert l_crs;

    	System.debug('AVDebug: CRs inserted');
    	List<TR1__Rate__c> l_rates = new List<TR1__Rate__c>();
    	TR1__Rate__c rate;
    	Id RType = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Closing Report Rate').getRecordTypeId();
        for(ctr = 0; ctr < totalCR ; ctr++)
    	{
    		rate = new TR1__Rate__c();
    		rate.Name = tt1.Name;
    		rate.RecordTypeId = RType;
    		rate.TR1__Active__c = true;
    		rate.TR1__ClosingReport__c = l_crs.get(ctr).Id;
    		rate.TR1__Job__c = l_jobs.get(ctr).Id;
    		rate.TR1__RateBill__c = 20;
    		rate.TR1__RatePay__c = 10;
    		rate.TR1__TimeType__c = tt1.Id;
    		
    		l_rates.add(rate);
    		
    		rate = new TR1__Rate__c();
    		rate.Name = tt2.Name;
    		rate.RecordTypeId = RType;
    		rate.TR1__Active__c = true;
    		rate.TR1__ClosingReport__c = l_crs.get(ctr).Id;
    		rate.TR1__Job__c = l_jobs.get(ctr).Id;
    		rate.TR1__RateBill__c = 30;
    		rate.TR1__RatePay__c = 15;
    		rate.TR1__TimeType__c = tt2.Id;
    		
    		l_rates.add(rate);
    	}
    	insert l_rates;
    	System.debug('AVDebug: Rates inserted for CRs');

    	List<NG_Shift_Staging__c> l_tsl = new List<NG_Shift_Staging__c>();
    	ctr = 0;
    	for(TR1__Closing_Report__c cr1 : l_crs)
    	{			
			if(ctr == 0)
			{
				l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Regular',Load_Date_Worked__c=Date.parse('12/2/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 1,Week_Ending__c = Date.parse('12/7/2017'), Shift_Load_Status__c='New'));
				l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Overtime',Load_Date_Worked__c=Date.parse('12/2/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 1,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));

				l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Regular',Load_Date_Worked__c=Date.parse('12/3/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 1,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));
				l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Overtime',Load_Date_Worked__c=Date.parse('12/3/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 1,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));
				
				l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Regular',Load_Date_Worked__c=Date.parse('12/4/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 7,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));
				l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Overtime',Load_Date_Worked__c=Date.parse('12/4/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 2,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));
				ctr++;
			}
			else
			{
				l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Regular',Load_Date_Worked__c=Date.parse('12/2/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 7,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));
				l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Overtime',Load_Date_Worked__c=Date.parse('12/2/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 2,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));

				l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Regular',Load_Date_Worked__c=Date.parse('12/3/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 7,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));
				l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Overtime',Load_Date_Worked__c=Date.parse('12/3/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 2,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));				
			}
			
			l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Regular',Load_Date_Worked__c=Date.parse('12/5/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 7,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));
			l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Overtime',Load_Date_Worked__c=Date.parse('12/5/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 2,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));

			l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Regular',Load_Date_Worked__c=Date.parse('12/6/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 7,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));
			l_tsl.add(new NG_Shift_Staging__c(Load_Hours_Type__c = 'Overtime',Load_Date_Worked__c=Date.parse('12/6/2017'), Closing_Report_ID__c = cr1.Id,Load_Hours__c = 2,Week_Ending__c = Date.parse('12/7/2017'),Shift_Load_Status__c='New'));

    	}
    	insert l_tsl;
    	
    	System.debug('AVDebug: StagingShiftLoads inserted');
    	
    	//Insert only ONE TS (others will be created by the batch code)
    	TR1__Timesheet__c ts = new TR1__Timesheet__c();
        ts.TR1__Closing_Report__c = l_crs.get(0).Id;
        ts.TR1__Consultant__c = con.Id;
        ts.TR1__Job_Order__c = l_jobs.get(0).Id;
        ts.TR1__Client__c = acc.Id;
        ts.TR1__Week_Ending__c = Date.parse('12/7/2017');
	    ts.TR1__Pay_Week_Ending__c = Date.parse('12/7/2017');
	    insert ts;

		//For the inserted TS above, the Rate Trigger doesn't fire in Testing, so ONLY for the one above create Rates at Timesheet level (others are created in Test.IsRunning code)
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
    	
    	System.debug('AVDebug : TS Rates inserted for sample');
		
		//Create only 2 TSD not the Third, This is just to make it weird for the first Timesheet.
		TR1__Timesheet_Detail__c tsd;
        List<TR1__Timesheet_Detail__c> tsds = new List<TR1__Timesheet_Detail__c>();
		for(ctr =0; ctr<2; ctr++)
		{
    		tsd = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = ts.id, TR1__Date__c = Date.parse('12/2/2017'), TR1__Day__c = TR1.Utility.dayOfDate(Date.parse('12/2/2017')));
			tsds.add(tsd);
    		tsd = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = ts.id, TR1__Date__c = Date.parse('12/3/2017'), TR1__Day__c = TR1.Utility.dayOfDate(Date.parse('12/3/2017')));
			tsds.add(tsd);
		}
        insert tsds;

		System.debug('AVDebug: Sample TSD Inserted');
/**/    	
    }
    
    static testMethod void myUnitTest() 
    {
		Test.startTest();
		NG_TimeSheetCtrl_KV tslBatch = new NG_TimeSheetCtrl_KV();
		Id batchId = Database.executeBatch(tslBatch);
		Test.stopTest();
    }
}