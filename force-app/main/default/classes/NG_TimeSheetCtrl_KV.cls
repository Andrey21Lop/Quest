global class NG_TimeSheetCtrl_KV implements Database.batchable<sObject>
{    
    public Date minWeekEndingDate {get;set;}
    public Map<Id,TR1__Closing_Report__c> mainCRMap {get;set;}
    public Map<Id, Map<Id, TR1__Timesheet__c>> tsPerClosingReport {get;set;}
    public Map<Id, Map<Id, TR1__Timesheet_Detail__c>> tsdPerTS {get;set;}
    public Map<Id, Map<Id, TR1__Rate__c>> ratesPerTS {get;set;}
    public Map<Id, Map<Id, TR1__ShiftWork__c>> shiftsPerTSD {get;set;}
    public Boolean ngDebugFlag {get;set;}
    public Boolean TS_OverWriteShifts {get;set;}
    public Boolean TS_PopulateRates {get;set;}
    public Boolean TS_PopulateShifts {get;set;}
    
    public Map<Id, NG_Shift_Staging__c> ngtsloads {get;set;}
    public Map<Id, Map<Id, NG_Shift_Staging__c>> ngtslPerClosingReport {get;set;}   
    public List<String> ShiftLoadTypes {get;set;}
        
    public NG_TimeSheetCtrl_KV()
    {
    	NGCS__c  ngcs = NGCS__c.getInstance('Main');
    	ngDebugFlag = (Boolean)ngcs.get('NG_Debug_Flag__c');
    	TS_PopulateRates = (Boolean)ngcs.get('TS_PopulateRates__c');
    	TS_PopulateShifts = (Boolean)ngcs.get('TS_PopulateShifts__c');
    	TS_OverWriteShifts = (Boolean)ngcs.get('TS_OverWriteShifts__c');
    	ShiftLoadTypes = ((String)ngcs.get('TS_ShiftLoadTypes__c')).split(',');
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
   		return Database.getQueryLocator([SELECT Id, Name, Closing_Report_ID__c, Employee_Id__c, Load_Date_Worked__c, Load_Hours__c, Load_Hours_Type__c, Person_Placed__c, Rate_TR1__c, Shift_Load_Status__c, Shift_Work__c, Timesheet__c, Timesheet_Detail__c, Time_Type__c, Week_Ending__c FROM NG_Shift_Staging__c WHERE Shift_Load_Status__c in: ShiftLoadTypes ]);
    }
    global void execute(Database.BatchableContext bc, List<NG_Shift_Staging__c> l_ngtsloads)
    {
    		ngtsloads = new Map<Id, NG_Shift_Staging__c>();
    		for(NG_Shift_Staging__c tsl : l_ngtsloads)
    			ngtsloads.put(tsl.Id, tsl);
    		createTS_KV();    		
    }
    global void finish(Database.BatchableContext BC) {}
    
    public void start_KV()
    {
    	ngtsloads = new Map<Id, NG_Shift_Staging__c> ([SELECT Id, Name, Closing_Report_ID__c, Employee_Id__c, Load_Date_Worked__c, Load_Hours__c, Load_Hours_Type__c, Person_Placed__c, Rate_TR1__c, Shift_Load_Status__c, Shift_Work__c, Timesheet__c, Timesheet_Detail__c, Time_Type__c, Week_Ending__c FROM NG_Shift_Staging__c WHERE Shift_Load_Status__c in: ShiftLoadTypes ]);
   		createTS_KV();
    }
    
    public void createTS_KV()
    {
    	populate_MinWeekEndingDate();
    	populate_NGTSLPerClosingReport(ngtsloads);
    	populate_MainCRMap();
    	populate_ExistingTSMap();
    	
    	Map<Id, NG_Shift_Staging__c> m_ngtsl;
    	for(Id CR : ngtslPerClosingReport.KeySet())
    	{
    		m_ngtsl = ngtslPerClosingReport.get(CR);
    		createTSAndDetail(CR, m_ngtsl);
    		ngtslPerClosingReport.put(CR, m_ngtsl);
    	}
    	if(TS_PopulateRates)
    		populate_Rates();
    	if(TS_PopulateShifts)
    	{
    		populate_Shifts();
    		createShifts();
    	}
		NG_MainUtility.println(ngDebugFlag,'Final TS='+ tsPerClosingReport);
		NG_MainUtility.println(ngDebugFlag,'Final TSD='+ tsdPerTS);
		updateTSloads();
    }

    public void createTSAndDetail(Id CR, Map<Id, NG_Shift_Staging__c> m_ngtsl)
    {
    	Date LastWeekEndingDate = null;
    	Boolean newTS = false;
    	TR1__Timesheet__c ts;
    	TR1__Timesheet_Detail__c tsd;
    	for(NG_Shift_Staging__c tsl : m_ngtsl.values())
    	{
    		if(LastWeekEndingDate == null || LastWeekEndingDate != tsl.Week_Ending__c)
        	{
        		LastWeekEndingDate = tsl.Week_Ending__c;
        		ts = getExistingTSForCR(CR, LastWeekEndingDate);
        		if(ts == null) {NG_MainUtility.println(ngDebugFlag,'TS returned is Null'+ts); newTS = true; }
        	}
        	if(newTS) {NG_MainUtility.println(ngDebugFlag,'Creating TS'); ts = createTS(CR, tsl); }
        	tsl.Timesheet__c = ts.Id; //tsl.TSCreated__c = true; tsl.TSCreationDate__c = System.TODAY();
        	NG_MainUtility.println(ngDebugFlag,'AVDebug TSID created & in TSL : ' + tsl.Timesheet__c);
        	tsd = addTSDetail(ts, tsl); //NOTE: This cannot be bulkified by simple means.
        	
        	
        	tsl.Timesheet_Detail__c = tsd.Id;
        	m_ngtsl.put(tsl.Id,tsl);
        	newTS = false;
    	}
    }
    
    public TR1__Timesheet__c createTS(Id CRID, NG_Shift_Staging__c tsl)
    {
        TR1__Timesheet__c ts = new TR1__Timesheet__c();
        TR1__Closing_Report__c cr = mainCRMap.get(CRID);
        ts.TR1__Status__c = 'Unsubmitted';
        ts.TR1__Closing_Report__c = CRID;
        ts.TR1__Consultant__c = cr.TR1__Person_Placed__c;
        ts.TR1__Job_Order__c = cr.TR1__Job__c;
        ts.TR1__Approver__c = cr.TR1__Timesheet_Approver__c;
        ts.TR1__Timesheet_Second_Approver__c = cr.TR1__Timesheet_Second_Approver__c;
        ts.TR1__Client__c = cr.TR1__Account__c;
        ts.TR1__Week_Ending__c = tsl.Week_Ending__c;
	    ts.TR1__Pay_Week_Ending__c = tsl.Week_Ending__c;   
	       
	    insert ts;
	    Map<Id, TR1__Timesheet__c> m_ts = tsPerClosingReport.get(CRID);
	    if(m_ts == null) m_ts = new Map<Id, TR1__Timesheet__c>();
	    m_ts.put(ts.Id,ts);
	    tsPerClosingReport.put(CRID, m_ts);
	    
	    if(Test.isRunningTest()) { addRates(ts,tsl); } 
	    
	    return ts;
    }
    
    public TR1__Timesheet_Detail__c addTSDetail(TR1__Timesheet__c ts, NG_Shift_Staging__c tsl)
    {
    	TR1__Timesheet_Detail__c tsd = getExistingTSDForCRTS(ts, tsl.Load_Date_Worked__c);
    	if(tsd == null)
    	{
    		tsd = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = ts.id, TR1__Date__c = tsl.Load_Date_Worked__c, TR1__Day__c = TR1.Utility.dayOfDate(tsl.Load_Date_Worked__c));
    		insert tsd;
    		Map<Id, TR1__Timesheet_Detail__c> m_tsd = tsdPerTS.get(ts.Id);
    		if(m_tsd == null) m_tsd = new Map<Id, TR1__Timesheet_Detail__c>();
    		m_tsd.put(tsd.Id,tsd);
    		tsdPerTS.put(ts.Id,m_tsd);
    	}
    	return tsd;
    }    
    public void populate_MinWeekEndingDate()
    {
    	for(NG_Shift_Staging__c tsl : ngtsloads.values())
    	{
    		if(minWeekEndingDate == null) minWeekEndingDate = tsl.Week_Ending__c;
    		else if(tsl.Week_Ending__c < minWeekEndingDate) minWeekEndingDate = tsl.Week_Ending__c;
    	}
    	NG_MainUtility.println(ngDebugFlag,'MinWeekEndingDate='+minWeekEndingDate);
    }
    
    public void populate_NGTSLPerClosingReport(Map<Id, NG_Shift_Staging__c> ngtsloads)
    {
    	ngtslPerClosingReport = new Map<Id,Map<Id, NG_Shift_Staging__c>>();
    	Map<Id, NG_Shift_Staging__c> PerCRNode;
    	for(NG_Shift_Staging__c ngtsl : ngtsloads.values())
    	{
    		if(ngtslPerClosingReport.containsKey(ngtsl.Closing_Report_ID__c))
    			PerCRNode = ngtslPerClosingReport.get(ngtsl.Closing_Report_ID__c);
    		else
    			PerCRNode = new Map<Id, NG_Shift_Staging__c>();
    		PerCRNode.put(ngtsl.Id, ngtsl);
    		ngtslPerClosingReport.put(ngtsl.Closing_Report_ID__c,PerCRNode);
    	}
    	NG_MainUtility.println(ngDebugFlag,'NGTSL PerClosingReport='+ngtslPerClosingReport);
    }
	
	public void populate_MainCRMap()
	{
		mainCRMap = new Map<Id,TR1__Closing_Report__c>([SELECT Id, Name,TR1__Start_Date__c,TR1__End_Date__c,
                    TR1__Job__c,TR1__Person_Placed__c,TR1__Account__c,
                    TR1__Week_Ending__c,TR1__Timesheet_Approver__c,
                    TR1__Timesheet_Second_Approver__c,TR1__Bill_Rate__c, TR1__Pay_Rate__c,
                    TR1__Payroll_Type__c FROM TR1__Closing_Report__c WHERE Id in: ngtslPerClosingReport.keySet()]);
		NG_MainUtility.println(ngDebugFlag,'Main ClosingReportMap='+mainCRMap);
	}
	
	public void populate_ExistingTSMap()
	{
		tsPerClosingReport = new Map<Id,Map <Id, TR1__Timesheet__c>>();
		Map<Id, TR1__Timesheet__c> tsMap = new Map<Id, TR1__Timesheet__c>();
		Id PrevClosingReportID = null;
		List<Id> l_tsIds = new List<Id>();
		for(TR1__Timesheet__c ts: [SELECT Id, TR1__Closing_Report__c, TR1__Week_Ending__c FROM  TR1__Timesheet__c WHERE TR1__Closing_Report__c in: ngtslPerClosingReport.keySet() AND TR1__Week_Ending__c >=: minWeekEndingDate ORDER By TR1__Closing_Report__c ])
        {
        	if(PrevClosingReportID != null && PrevClosingReportID != ts.TR1__Closing_Report__c)
        	{
        		tsPerClosingReport.put(PrevClosingReportID, tsMap);
        		PrevClosingReportID = ts.TR1__Closing_Report__c;
        		tsMap = new Map<Id, TR1__Timesheet__c>();
        	}
        	if(PrevClosingReportID == null) PrevClosingReportID = ts.TR1__Closing_Report__c;
        	tsMap.put(ts.Id, ts);
        	l_tsIds.add(ts.Id);
        }
        if(PrevClosingReportID != null) tsPerClosingReport.put(PrevClosingReportID, tsMap);
        NG_MainUtility.println(ngDebugFlag,'Existing TS='+tsPerClosingReport);
        
        tsdPerTS = new Map<Id, Map<Id, TR1__Timesheet_Detail__c>>();
        Id PrevTSId = null;
        Map<Id, TR1__Timesheet_Detail__c> tsdMap = new Map<Id, TR1__Timesheet_Detail__c>();
        for(TR1__Timesheet_Detail__c tsd : [SELECT Id, TR1__Date__c, TR1__Day__c, TR1__Timesheet__c FROM TR1__Timesheet_Detail__c WHERE TR1__Timesheet__c in: l_tsIds ORDER BY TR1__Timesheet__c, TR1__Date__c])
        {
        	if(PrevTSId != null && PrevTSId != tsd.TR1__Timesheet__c)
        	{
        		tsdPerTS.put(PrevTSId,tsdMap);
        		PrevTSId = tsd.TR1__Timesheet__c;
        		tsdMap = new Map<Id, TR1__Timesheet_Detail__c>();
        	}
        	if(PrevTSId == null) PrevTSId = tsd.TR1__Timesheet__c;
        	tsdMap.put(tsd.Id, tsd);
        }
        if(PrevTSId != null) tsdPerTS.put(PrevTSId,tsdMap);
        NG_MainUtility.println(ngDebugFlag,'Existing TSDs='+ tsdPerTS);
	}
	
	public TR1__Timesheet__c getExistingTSForCR(Id CR, Date weekEnding)
	{
		Map <Id, TR1__Timesheet__c> m_ts = tsPerClosingReport.get(CR);
		if(m_ts != null)
			for(TR1__Timesheet__c ts : m_ts.values())
			{
				NG_MainUtility.println(ngDebugFlag,'Finding Existing TimeSheet='+ts.TR1__Week_Ending__c+ '=='+weekEnding);
				if(ts.TR1__Week_Ending__c == weekEnding) return ts;
			}
		return null;
	}
	
	public TR1__Timesheet_Detail__c getExistingTSDForCRTS(TR1__Timesheet__c ts, Date DateWorked)
	{
		Map<Id, TR1__Timesheet_Detail__c> m_tsd = tsdPerTS.get(ts.Id);
		if(m_tsd != null)
			for(TR1__Timesheet_Detail__c tsd : m_tsd.values())
			{
				NG_MainUtility.println(ngDebugFlag,'Finding Existing TSD='+tsd.TR1__Date__c+'=='+DateWorked);
				if(tsd.TR1__Date__c == DateWorked) return tsd;
			}
		return null;
	}

	public void updateTSloads()
	{
		List<NG_Shift_Staging__c> tslForUpload = new List<NG_Shift_Staging__c>();
   		Map<Id, NG_Shift_Staging__c> m_ngtsl;
    	for(Id CR : ngtslPerClosingReport.KeySet())
    	{
    		m_ngtsl = ngtslPerClosingReport.get(CR);
			for(NG_Shift_Staging__c ts : m_ngtsl.values())
			{	ts.Shift_Load_Status__c = 'Loaded'; tslForUpload.add(ts); }
		}
		update tslForUpload;
		NG_MainUtility.println(ngDebugFlag,'Final NTSL='+tslForUpload);
	}
	
	public void populate_Rates()
	{
		ratesPerTS = new Map<Id, Map<Id, TR1__Rate__c>> ();
		List<TR1__Rate__c> allRates = [SELECT Id, TR1__ClosingReport__c, TR1__Timesheet__c, TR1__TimeType__c, TR1__Rate_Type_Name__c, TR1__RatePay__c, TR1__RateBill__c FROM TR1__Rate__c WHERE TR1__Timesheet__c in: tsdPerTS.KeySet() ORDER BY TR1__Timesheet__c];
		Id PrevTSId = null;
		NG_MainUtility.println(ngDebugFlag,'-----RATES---TSIDs='+tsdPerTS.KeySet());
		NG_MainUtility.println(ngDebugFlag,'----RATES----'+allRates);
        Map<Id, TR1__Rate__c> m_rates = new Map<Id, TR1__Rate__c>();
        for(TR1__Rate__c rate : allRates)
        {
        	if(PrevTSId != null && PrevTSId != rate.TR1__Timesheet__c)
        	{
        		ratesPerTS.put(PrevTSId,m_rates);
        		PrevTSId = rate.TR1__Timesheet__c;
        		m_rates = new Map<Id, TR1__Rate__c>();
        	}
        	if(PrevTSId == null) PrevTSId = rate.TR1__Timesheet__c;
        	m_rates.put(rate.Id, rate);
        }
        ratesPerTS.put(PrevTSId,m_rates);
        NG_MainUtility.println(ngDebugFlag,'Populated Rates='+ratesPerTS);
        backFillRatesInNGTSL();
	}
	
	public void backFillRatesInNGTSL()
	{
		Map<Id, NG_Shift_Staging__c> m_ngtslPerCR;
		for(Id CR : ngtslPerClosingReport.keySet())
		{
			m_ngtslPerCR = ngtslPerClosingReport.get(CR);
			for(NG_Shift_Staging__c tsl : m_ngtslPerCR.values())
			{
				Map<Id, TR1__Rate__c> m_rates = ratesPerTS.get(tsl.Timesheet__c);
				if(m_rates == null) return;
				for(TR1__Rate__c rate : m_rates.values())
				{
					if(tsl.Load_Hours_Type__c.equalsIgnoreCase(rate.TR1__Rate_Type_Name__c))
					{
						tsl.Rate_TR1__c = rate.Id;
						tsl.Time_Type__c = rate.TR1__TimeType__c;
					}
						
				}
			}
		}
	}

	
	public void populate_Shifts()
	{
		shiftsPerTSD = new Map<Id, Map<Id, TR1__ShiftWork__c>> ();
		List<Id> tsdIds = new List<Id>();
		for(Id tsId: tsdPerTS.KeySet())
		{
			Map<Id, TR1__Timesheet_Detail__c> m_tsd = tsdPerTS.get(tsId);
			for(TR1__Timesheet_Detail__c tsd : m_tsd.values())
				tsdIds.add(tsd.Id);
		}
		List<TR1__ShiftWork__c> allShifts = [SELECT Id, TR1__Rate__c, TR1__Rate__r.TR1__Rate_Type_Name__c, TR1__Timesheet__c, TR1__TimesheetDetail__c, TR1__AmountBill__c, TR1__AmountPay__c, TR1__Hours__c FROM TR1__ShiftWork__c WHERE TR1__TimesheetDetail__c in: tsdIds ORDER BY TR1__TimesheetDetail__c];
		Id PrevTSDId = null;
        Map<Id, TR1__ShiftWork__c> m_shifts = new Map<Id, TR1__ShiftWork__c>();
        for(TR1__ShiftWork__c shift : allShifts)
        {
        	if(PrevTSDId != null && PrevTSDId != shift.TR1__TimesheetDetail__c)
        	{
        		shiftsPerTSD.put(PrevTSDId,m_shifts);
        		PrevTSDId = shift.TR1__TimesheetDetail__c;
        		m_shifts = new Map<Id, TR1__ShiftWork__c>();
        	}
        	if(PrevTSDId == null) PrevTSDId = shift.TR1__TimesheetDetail__c;
        	m_shifts.put(shift.Id, shift);
        }
        if(PrevTSDId != null) shiftsPerTSD.put(PrevTSDId,m_shifts);
        NG_MainUtility.println(ngDebugFlag,'Populated Shifts='+shiftsPerTSD);
	}
	
	public TR1__ShiftWork__c getExistingShiftForTSD(Id tsdID, String RateName)
	{
		NG_MainUtility.println(ngDebugFlag,'Find Shift for TSDId='+tsdID+' Rate='+RateName);
		Map<Id, TR1__ShiftWork__c> m_shifts = shiftsPerTSD.get(tsdID);
		if(m_shifts != null)
			for(TR1__ShiftWork__c shift : m_shifts.values())
			{
				NG_MainUtility.println(ngDebugFlag,'Finding Existing Shift='+shift.TR1__Rate__r.TR1__Rate_Type_Name__c+'=='+RateName);
				if(shift.TR1__Rate__r.TR1__Rate_Type_Name__c == RateName) return shift;
			}
		return null;
	}

	public Decimal getRate(Id TSID, String RateName, String RateType)
	{
		Map<Id, TR1__Rate__c> m_rates = ratesPerTS.get(TSID);
		TR1__Rate__c rateToConsider;
		if(m_rates == null) return 0;
		for(TR1__Rate__c rate : m_rates.values())
		{
			if(RateName.equalsIgnoreCase(rate.TR1__Rate_Type_Name__c))
				rateToConsider = rate;
		}
		if(RateType.equalsIgnoreCase('Bill'))
			return (Decimal) rateToConsider.TR1__RateBill__c;
		else if(RateType.equalsIgnoreCase('Pay'))
			return (Decimal) rateToConsider.TR1__RatePay__c;
		return 0;
	}
	
	public void createShifts()
	{
		Map<Id, NG_Shift_Staging__c> m_ngtsl;
		Boolean newShift = false;
		TR1__ShiftWork__c shift;
    	for(Id CR : ngtslPerClosingReport.KeySet())
    	{
    		m_ngtsl = ngtslPerClosingReport.get(CR);
    		for(NG_Shift_Staging__c tsl : m_ngtsl.values())
    		{
    			shift = getExistingShiftForTSD(tsl.Timesheet_Detail__c, tsl.Load_Hours_Type__c);
    			newShift = false;
    			if(shift == null) {	shift = new TR1__ShiftWork__c(); newShift = true; shift.TR1__TimesheetDetail__c = tsl.Timesheet_Detail__c;}
    			if(newShift || TS_OverWriteShifts)
    			{
    				shift.TR1__Rate__c = tsl.Rate_TR1__c;
    				shift.TR1__Timesheet__c = tsl.Timesheet__c;
//     				shift.TR1__AmountBill__c = tsl.Hours__c * getRate(tsl.Timesheet__c, tsl.Load_Hours_Type__c, 'Bill');
//    				shift.TR1__AmountPay__c = tsl.Hours__c * getRate(tsl.Timesheet__c, tsl.Load_Hours_Type__c, 'Pay');
    				shift.TR1__Hours__c = tsl.Load_Hours__c;
    				if(newShift) insert shift;
    				else if(TS_OverWriteShifts) update Shift;
    			}
    			Map<Id, TR1__ShiftWork__c> m_shifts = shiftsPerTSD.get(tsl.Timesheet_Detail__c);
    			if(m_shifts == null) m_shifts = new Map<Id, TR1__ShiftWork__c>();
    			m_shifts.put(shift.Id,shift);
    			shiftsPerTSD.put(tsl.Timesheet_Detail__c,m_shifts);
    			
    			tsl.Shift_Work__c = shift.Id;
    		}
    		NG_MainUtility.println(ngDebugFlag,' Final Shifts='+shiftsPerTSD);
    	}
	}


//This is required for TESTING via APEX
    public void addRates(TR1__Timesheet__c ts, NG_Shift_Staging__c tsl)
    {
    	Id RType_CR = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Closing Report Rate').getRecordTypeId();
    	List<TR1__Rate__c> l_rates = new List<TR1__Rate__c>();
    	TR1__Rate__c rate;
    	Id RType_TS = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Timesheet Rate').getRecordTypeId();
    	
    	List<TR1__Rate__c> CRRates = [SELECT Id, Name, TR1__ClosingReport__c, TR1__Job__c, TR1__Timesheet__c, TR1__TimeType__c, TR1__Rate_Type_Name__c, TR1__RatePay__c, TR1__RateBill__c FROM TR1__Rate__c WHERE TR1__ClosingReport__c =: tsl.Closing_Report_ID__c and RecordTypeId =: RType_CR];
    	NG_MainUtility.println(ngDebugFlag,'RATES=====in TESTMODE ONLY'+CRRates);
    	for(TR1__Rate__c crt : CRRates)
    	{
    		rate = new TR1__Rate__c();
    		rate.Name = crt.Name;
    		rate.RecordTypeId = RType_TS;
    		rate.TR1__Active__c = true;
    		rate.TR1__ClosingReport__c = crt.TR1__ClosingReport__c;
    		rate.TR1__Timesheet__c = ts.Id;
    		rate.TR1__Job__c = crt.TR1__Job__c;
    		rate.TR1__RateBill__c = crt.TR1__RateBill__c;
    		rate.TR1__RatePay__c = crt.TR1__RatePay__c;
    		rate.TR1__TimeType__c = crt.TR1__TimeType__c;   		
    		l_rates.add(rate);
    	}
    	insert l_rates;
    }		


}