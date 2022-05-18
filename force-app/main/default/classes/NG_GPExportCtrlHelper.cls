public with sharing class NG_GPExportCtrlHelper {
    
    public Static Map<Id,TR1_INV__Invoice__c> getInvoiceMap(Set<Id> invoiceIds)
    {
        Map<Id,TR1_INV__Invoice__c> localInvoiceMap;
        localInvoiceMap = new Map<Id,TR1_INV__Invoice__c>([SELECT Id, 
                                                           	Name , 
                                                            TR1_INV__Account__c,
                                                           	TR1_INV__Account__r.Name,
                                                           	TR1_INV__Account__r.AccountNumber,
                                                           	TR1_INV__Invoice_Date__c,
                                                            NG_Invoice_Number__c,
                                                            TR1_INV__Invoicing_Contact__c,
                                                            TR1_INV__Additional_Invoice_Contact__c,
                                                            TR1_INV__Closing_Report__c,
                                                            TR1_INV__Total_Amount__c,
                                                            TR1_INV__Total_Amount_Absolute__c,
                                                           	TR1_INV__Total_Amount_Incl_Tax__c,
                                                           	TR1_INV__Total_Net_Amount__c,
                                                            TR1_INV__Total_Tax_Amount__c,
                                                           	TR1_INV__Total_VAT_Amount__c,
                                                            TR1_INV__Billing_Profile__c
                                                            FROM TR1_INV__Invoice__c Where Id In :invoiceIds ]);
        return localInvoiceMap;
    }
    
    public Static Set<Id> getCRrelatedToInvoiceLineItems(Map<Id, TR1_INV__Invoice_line_item__c> inoviceLineItemsMap)
    {
        
        Set<Id> localCRIdSet = new Set<Id>();
        
        for (TR1_INV__Invoice_line_item__c ili : inoviceLineItemsMap.values())
			{
               localCRIdSet.add(ili.TR1_INV__Closing_Report__c);
              // NG_MainUtility.println(myDebugFlag,'closing Report Id  ->'+ localCRIdSet);
            }
        return localCRIdSet;
    }
    
    public Static Map<Id,TR1__Closing_Report__c> getClosingReportMap(Set<Id> closingReportIdSet)
    {
        Map<Id,TR1__Closing_Report__c> localClosingReportMap;
        localClosingReportMap = new Map<Id,TR1__Closing_Report__c>([SELECT Id, 
                                                           	Name, 
                                                            Candidate_Type__c,
                                                            RecordTypeId,        
                                                            TR1__Person_Placed__c,
                                                            TR1__Account__r.AccountNumber,
                                                            TR1__Account__r.SA_Account_Company_Code__c,
                                                            TR1__Candidate_Credit__r.FirstName,
                                                            TR1__Candidate_Credit__r.LastName,
                                                            TR1__Candidate_Credit__r.Alias,//GP Commission Rep
                                                           	TR1__Candidate_Credit__r.NG_COA_Company__c,
                                                           	TR1__Candidate_Credit__r.NG_COA_Cost_Center__c,
                                                            TR1__Candidate_Credit__r.NG_COA_Division__c, 
                                                            TR1__Candidate_Credit__r.SA_Department_Sales_Account__c,
                                                           	TR1__Other_Credit__r.Alias,//GP Commission Rep 2nd 
                                                           	TR1__Other_Credit__r.FirstName,
                                                            TR1__Other_Credit__r.LastName,
                                                            TR1__Other_Credit__r.NG_COA_Company__c, 
                                                            TR1__Other_Credit__r.NG_COA_Cost_Center__c,
                                                            TR1__Other_Credit__r.NG_COA_Division__c,
                                                            TR1__Other_Credit__r.SA_Department_Sales_Account__c,
                                                                    
                                                            TR1__Job_Credit__r.Alias,//GP Commmision Sales 
                                                           	TR1__Job_Credit__r.FirstName,
                                                            TR1__Job_Credit__r.LastName,
                                                            TR1__Job_Credit__r.NG_COA_Company__c, 
                                                            TR1__Job_Credit__r.NG_COA_Cost_Center__c,
                                                            TR1__Job_Credit__r.NG_COA_Division__c,
                                                            TR1__Job_Credit__r.SA_Department_Sales_Account__c,
                                                                    
                                                            TR1__Marketing_Credit__r.Alias,//GP Commission Sales 2nd
                                                           	TR1__Marketing_Credit__r.FirstName,
                                                            TR1__Marketing_Credit__r.LastName,
                                                            TR1__Marketing_Credit__r.NG_COA_Company__c, 
                                                            TR1__Marketing_Credit__r.NG_COA_Cost_Center__c,
                                                            TR1__Marketing_Credit__r.NG_COA_Division__c,
                                                            TR1__Marketing_Credit__r.SA_Department_Sales_Account__c,
                                                                    
                                                            TR1__Candidate_Percentage__c,
                                                            TR1__Other_Percentage__c,
                                                            TR1__Job_Percentage__c,
                                                            TR1__Marketing_Percentage__c,
                                                            TR1_INV__InvoiceLineItem__c,
                                                            SA_Perm_GM_Deduction__c        
                                                            FROM TR1__Closing_Report__c Where Id In :closingReportIdSet ]);
        return localClosingReportMap;
    }
    
     
    public Static Set<Id> getCRrelatedToInvoiceIdSet(Map<Id, TR1_INV__Invoice__c> inoviceMap)
    {
        
        Set<Id> localCRIdSet = new Set<Id>();
        
        for (TR1_INV__Invoice__c invoice : inoviceMap.values())
			{
               localCRIdSet.add(invoice.TR1_INV__Closing_Report__c);
              // NG_MainUtility.println(myDebugFlag,'closing Report Id  ->'+ localCRIdSet);
            }
        return localCRIdSet;
    }
    
    public Static Map<Id,TR1_INV__Invoice_line_item__c> getInvoiceLineItemsMap(Set<Id> invoiceIds)
    {
        Map<Id,TR1_INV__Invoice_line_item__c> localILIMap;
        localILIMap = new Map<Id,TR1_INV__Invoice_line_item__c>([SELECT Id, 
                                                           	Name , 
                                                           	TR1_INV__Invoice__c,
                                                            TR1_INV__Timesheet__c,
                                                            TR1_INV__Purchase_Order__c,
                                                            TR1_INV__Expense_Report__c,
                                                            TR1_INV__Consultant__c,
                                                            TR1_INV__Closing_Report__c,
                                                            SA_Sales_Secondary_Rep__c,
                                                            SA_Sales_SecondaryPct__c,
                                                            SA_Sales_Rep__c,
                                                            SA_Sales_Perm_GM__c,
                                                            SA_Sales_2nd_Perm_GM__c,
                                                            SA_SalesPct__c,
                                                            SA_Recruiter_Secondary_Rep__c,
                                                            SA_Recruiter_SecondaryPct__c,
                                                            SA_Recruiter_Rep__c,
                                                            SA_Recruiter_Perm_GM__c,
                                                            SA_Recruiter_2nd_Perm_GM__c,
                                                            SA_RecruiterPct__c,
                                                            SA_Person_Placed__c,
                                                            SA_Invoice_Date__c,
                                                            SA_Invoice__c,
                                                            SA_Client_Name__c,
                                                            SA_AccountNumber__c,
                                                            SA_Perm_GM__c,     
                                                            TR1_INV__Total_Amount__c     
                                                            FROM TR1_INV__Invoice_line_item__c Where TR1_INV__Invoice__c in :invoiceIds Order By TR1_INV__Invoice__c]);
        return localILIMap;
    }
    
     public Static Set<Id> getInvoiceLineItemsIds(Map<Id,TR1_INV__Invoice_line_item__c> iliItems)
    {
       Set<Id> localILIIdSet = new Set<Id>();
       localILIIdSet=iliItems.keySet();
       return localILIIdSet;
    }
    
     public Static Set<Id> getExpenseReportIdsFromILI(Map<Id,TR1_INV__Invoice_line_item__c> iliItems)
    {
       Set<Id> localILIIdSet = new Set<Id>();
        for(TR1_INV__Invoice_line_item__c ili : iliItems.values())
    	{
    		    localILIIdSet.Add(ili.TR1_INV__Expense_Report__c);       
    	}
       
       return localILIIdSet;
    }
    
    public Static Map<Id, Map<Id, TR1_INV__Invoice_line_item__c>> getILIPerCRMap(Map<Id, TR1_INV__Invoice_line_item__c> invoiceLineItems)
    {
        Map<Id, Map<Id, TR1_INV__Invoice_line_item__c>> localILIPerCRMap = new  Map<Id, Map<Id, TR1_INV__Invoice_line_item__c>> ();
        Map<Id, TR1_INV__Invoice_line_item__c> matchingInvoiceLineItemwithClosingReport;
        
         for(TR1_INV__Invoice_line_item__c tr1InvInvoiceLineItem : invoiceLineItems.values())
    	{
    		if(localILIPerCRMap.containsKey(tr1InvInvoiceLineItem.TR1_INV__Closing_Report__c ))
    			matchingInvoiceLineItemwithClosingReport = localILIPerCRMap.get(tr1InvInvoiceLineItem.TR1_INV__Closing_Report__c);
    		else
    			matchingInvoiceLineItemwithClosingReport = new Map<Id, TR1_INV__Invoice_line_item__c>();
            matchingInvoiceLineItemwithClosingReport.put(tr1InvInvoiceLineItem.Id,tr1InvInvoiceLineItem);
            // Add to Map Inovice Id 
    		localILIPerCRMap.put(tr1InvInvoiceLineItem.TR1_INV__Closing_Report__c, matchingInvoiceLineItemwithClosingReport);
           
    	}
        return localILIPerCRMap;
    }
    
     public Static  Map<Id, Map<Id, TR1_INV__Invoice_line_item__c>> getILIPerInvoiceMap(Map<Id, TR1_INV__Invoice_line_item__c> invoiceLineItems)
    {
        Map<Id, Map<Id, TR1_INV__Invoice_line_item__c>> localILIPerInvoiceMap = new  Map<Id, Map<Id, TR1_INV__Invoice_line_item__c>> ();
        Map<Id, TR1_INV__Invoice_line_item__c> matchingInvoiceLineItem;
        
        for(TR1_INV__Invoice_line_item__c ili : invoiceLineItems.values())
    	{
    		if(localILIPerInvoiceMap.containsKey(ili.TR1_INV__Invoice__c ))
    			matchingInvoiceLineItem = localILIPerInvoiceMap.get(ili.TR1_INV__Invoice__c);
    		else
    			matchingInvoiceLineItem = new Map<Id, TR1_INV__Invoice_line_item__c>();
            matchingInvoiceLineItem.put(ili.Id,ili);
            // Add to Map Inovice Id 
    		localILIPerInvoiceMap.put(ili.TR1_INV__Invoice__c, matchingInvoiceLineItem);
           
    	}
       return localILIPerInvoiceMap;
    }
    
  	  public Static Map<Id,TR1__Expense_Report__c> getExpenseReportMap(Set<Id> relatedERFromILIIDset)
    {
        // Invoice Line Item Id's are passed to this method to get the related expense Reports
        // If Invoice Line Item is null then that Expense Report will not be added to Map
        Map<Id,TR1__Expense_Report__c> localExpenseReportMap = new Map<Id,TR1__Expense_Report__c>([SELECT Id, 
                                                           	Name , 
                                                           	TR1__Account__c,
                                                            TR1__Closing_Report__c,
                                                            TR1_INV__InvoiceLineItem__c,                                       
                                                            TR1__Status__c
                                                            FROM  TR1__Expense_Report__c Where Id in :relatedERFromILIIDset Order By TR1__Closing_Report__c]);
        //erIdSet = new Set<Id>();
        //erIdSet = ng_tr1_expenseReportMap.keySet();
        //NG_MainUtility.println(myDebugFlag,'populate_ng_tr1_closingReportMap  ->'+ ng_tr1_expenseReportMap);
        Return localExpenseReportMap;
    }
    
    public Static Map<Id,TR1__Expense_Report_Detail__c> getExpenseReportLineItemsMap(Set<Id> expenseReports)
    {
        Map<Id,TR1__Expense_Report_Detail__c> localExpenseReportLineItemsMap = new Map<Id,TR1__Expense_Report_Detail__c>([SELECT Id, 
                                                           	Name , 
                                                           	TR1__Account__c,
                                                            TR1__Amount__c,
                                                            TR1__Rate__c,
                                                            SA_Reimbursed_Amount__c,
                                                            TR1__Expense_Report__c,
															TR1__Mileage_Amount__c,
                                                            TR1_INV__RecordTypeName__c                                                             
                                                            FROM  TR1__Expense_Report_Detail__c 
                                                            Where TR1__Expense_Report__c in :expenseReports Order By TR1__Expense_Report__c]);
        //erIdSet = new Set<Id>();
        //erIdSet = ng_tr1_expenseReportMap.keySet();
        //NG_MainUtility.println(myDebugFlag,'populate_ng_tr1_closingReportMap  ->'+ ng_tr1_expenseReportMap);
        Return localExpenseReportLineItemsMap;
    }
    
     public static Map<Id, Map<Id, TR1__Expense_Report_Detail__c>> getErliPerERMap(Map <Id,TR1__Expense_Report_Detail__c> expenseReportLineItems, Id expenseReportId)
    {
       
       Map<Id, Map<Id, TR1__Expense_Report_Detail__c>> localErliPerERMap = new Map<Id, Map<Id, TR1__Expense_Report_Detail__c>>();
        Map<Id, TR1__Expense_Report_Detail__c> matchingErli;
        
		 for(TR1__Expense_Report_Detail__c erli : expenseReportLineItems.values())
    	{
            // If passed related expense Report Id Equals ELI Expense Report ID then only create Map
           If(erli.TR1__Expense_Report__c == expenseReportId)
           {
                       
    		if(localErliPerERMap.containsKey(expenseReportId ))
    			matchingErli = localErliPerERMap.get(expenseReportId);
    		else
    			matchingErli = new Map<Id, TR1__Expense_Report_Detail__c>();
            
          	If (erli != null && matchingErli != null) matchingErli.put(erli.Id,erli);
          
    		localErliPerERMap.put(expenseReportId, matchingErli);
            }
           
    	}
        //NG_MainUtility.println(True,'getErliPerERMap  expenseReportLineItems->'+ expenseReportLineItems);  
		//NG_MainUtility.println(True,'getErliPerERMap  localErliPerERMap->'+ localErliPerERMap);             
        return localErliPerERMap;
    }

    
    public Static Set<Id> getExpenseReportMapIdSet(Map<Id,TR1__Expense_Report__c> expenseReports)
    {
        Set<Id> localExpenseReportIDs = new Set<Id>();
        localExpenseReportIDs = expenseReports.keySet();
        return localExpenseReportIDs;
        
    }
    
    public static Map<Id,TR1__Timesheet__c> gettsMap(Set<Id> invoiceLineItems)
	{
		Map<Id,TR1__Timesheet__c> localtsMap = new Map<Id,TR1__Timesheet__c>([SELECT Id, 
                                                           	Name , 
                                                            TR1_INV__InvoiceLineItem__c,
                                               				TR1__Closing_Report__c,
                                               				TR1__Consultant__c,
                                                      		Candidate_Type__c,
                                               				TR1__Client__c,
                                                            Total_ACA_Fee__c,
                                                            TR1__Client__r.autonumber__c
                                                            FROM TR1__Timesheet__c 
                                                      Where TR1_INV__InvoiceLineItem__c in :invoiceLineItems Order By TR1_INV__InvoiceLineItem__c]);
        //tsIdSet = new Set<Id>();
        //tsIdSet = ng_tr1_tsMap.keySet();
        
        return localtsMap;
	
	}
    
     public static Set<Id> getTsIdSet(Map<Id,TR1__Timesheet__c> timeSheets)
	{
		Set<Id> localTsIDs = new Set<Id>();
        localTsIDs = timeSheets.keySet();
        return localTsIDs;
	
	}
    
       public static Map<Id,TR1__Timesheet_Detail__c> gettsdMap(set<Id> timesheets)
	{
		Map<Id,TR1__Timesheet_Detail__c> localtsdMap = new Map<Id,TR1__Timesheet_Detail__c>([SELECT Id, 
                                                           		Name , 
                                                       			TR1__Timesheet__c,
                                                           		TRSCHED__Closing_Report_Schedule__c              
                                                            	FROM TR1__Timesheet_Detail__c 
                                                              Where TR1__Timesheet__c in :timesheets Order By TR1__Timesheet__c]);
        return localtsdMap;		
	}
    
     public static Set<Id> getTsdIdSet(Map<Id,TR1__Timesheet_Detail__c> timeSheetDetailss)
	{
		Set<Id> localTsdIDs = new Set<Id>();
        localTsdIDs = timeSheetDetailss.keySet();
        return localTsdIDs;
	
	}
    
     public static Map<Id, Map<Id, TR1__Timesheet__c>> gettsPerILIMap(Map<Id, TR1__Timesheet__c> timeSheets)
	{
        Map<Id, Map<Id, TR1__Timesheet__c>> localtsPerILIMap = new Map<Id, Map<Id, TR1__Timesheet__c>>();
        Map<Id,TR1__Timesheet__c> matchingTSwithILI;
        for (TR1__Timesheet__c ts : timeSheets.values())
        {
            if (localtsPerILIMap.containsKey(ts.TR1_INV__InvoiceLineItem__c))
                matchingTSwithILI=localtsPerILIMap.get(ts.TR1_INV__InvoiceLineItem__c);
            else
                matchingTSwithILI = new Map<Id,TR1__Timesheet__c>();
             matchingTSwithILI.put(ts.Id,ts);
             localtsPerILIMap.put(ts.TR1_INV__InvoiceLineItem__c,matchingTSwithILI);
        }
        
        /*if(myDebugFlag)
        {
        for (Id id : ng_tr1_tsPerILIMap.keySet())
			{
    			NG_MainUtility.println(myDebugFlag,'ILI Id ->'+id);
                Map<Id,TR1__Timesheet__c> Values = new  Map<Id,TR1__Timesheet__c>();
                Values = ng_tr1_tsPerILIMap.get(id);
                for (Id sid : Values.keySet())
   					NG_MainUtility.println(myDebugFlag,'Time Sheets->'+Values.get(sid));
			}
        }*/
        
        return localtsPerILIMap;
        
	}
     public static Map<Id, Map<Id, TR1__Timesheet_Detail__c>> gettsdPerTSMap(Map <Id,TR1__Timesheet_Detail__c> timeSheetDetails)
    {
       
       Map<Id, Map<Id, TR1__Timesheet_Detail__c>> localtsdPerTSMap = new Map<Id, Map<Id, TR1__Timesheet_Detail__c>>();
        Map<Id, TR1__Timesheet_Detail__c> matchingtsd;
        
		 for(TR1__Timesheet_Detail__c tsd : timeSheetDetails.values())
    	{
    		if(localtsdPerTSMap.containsKey(tsd.TR1__Timesheet__c ))
    			matchingtsd = localtsdPerTSMap.get(tsd.TR1__Timesheet__c);
    		else
    			matchingtsd = new Map<Id, TR1__Timesheet_Detail__c>();
            
          	If (tsd != null && matchingtsd != null) matchingtsd.put(tsd.Id,tsd);
          
    		localtsdPerTSMap.put(tsd.TR1__Timesheet__c, matchingtsd);
           
    	}
        
        /*if(myDebugFlag)
        {
        for (Id id : ng_tr1_tsdPerTSMap.keySet())
			{
    			NG_MainUtility.println(myDebugFlag,'Time Sheet Id ->'+id);
                Map<Id, TR1__Timesheet_Detail__c> Values = new  Map<Id, TR1__Timesheet_Detail__c>();
                Values = ng_tr1_tsdPerTSMap.get(id);
                for (Id sid : Values.keySet())
   					NG_MainUtility.println(myDebugFlag,'Invoice Line Items->'+Values.get(sid));
			}
        }*/
      
        return localtsdPerTSMap;
    }
    
     public Static Map<Id,TR1__ShiftWork__c> getShiftWorkMap(set<Id> timeSheetDetails)
	{
        //List<AggregateResult> shiftWorkSumList;
		Map<Id,TR1__ShiftWork__c> localshiftWorkMap = new Map<Id,TR1__ShiftWork__c>([SELECT Id, 
                                                           	Name , 
                                                            TR1__TimesheetDetail__c,
                                               				TR1__Rate__c,
                                               				TR1__Timesheet__c,
                                                            TR1__TimeType__c,
															TR1__AmountBill__c,                                                                                     
                                                            SA_GM__c,
                                                            GP_Account_Number__c,
                                                            TR1__Hours__c,                                                            
                                                            GP_Commission_Rep__c,
                                                            GP_Commission_Rep_2nd__c,
															SA_Recruiter_GM__c,
															GP_Commission_Percent__c,
															GP_Commission_Percent_2nd__c,
															SA_Recruiter_Secondary_GM__c,
															GP_Commission_Sales__c,
															SA_Sales_GM__c,
															GP_Commission_Sales_Percent__c,
															GP_Commission_Sales_2nd__c,
															SA_Sales_Secondary_GM__c,
															GP_Commission_Sales_Percent_2nd__c,
                                                            SA_BBGM__c,
                                                            SA_ACA_v_GM__c,
                                                            SA_Burden_Amount__c,
                                                            SA_Malpractice_from_GM__c,
                                                            SA_Other_Deduction_from_GM__c,
                                                            SA_VMS_Fee__c                         
                                                            FROM TR1__ShiftWork__c 
                                                            Where TR1__TimesheetDetail__c in: timeSheetDetails 
                                                            ORDER By TR1__TimesheetDetail__c]);
        
         return localshiftWorkMap;
	}
    
    public Static Map<Id, Map<Id, TR1__ShiftWork__c>> getswPerTSDMap(Map <Id,TR1__ShiftWork__c> shiftWorks)
    {
       
       Map<Id, Map<Id, TR1__ShiftWork__c>> localSwPerTSDMap = new Map<Id, Map<Id, TR1__ShiftWork__c>>();
        Map<Id, TR1__ShiftWork__c> matchingsw;
        
		 for(TR1__ShiftWork__c sw : shiftWorks.values())
    	{
    		if(localSwPerTSDMap.containsKey(sw.TR1__TimesheetDetail__c))
    			matchingsw = localSwPerTSDMap.get(sw.TR1__TimesheetDetail__c);
    		else
    			matchingsw = new Map<Id, TR1__ShiftWork__c>();
            
          	If (sw != null && matchingsw != null) matchingsw.put(sw.Id,sw);
           
    		localSwPerTSDMap.put(sw.TR1__TimesheetDetail__c, matchingsw);
            
    	}
        return localSwPerTSDMap;
        /*
        if(myDebugFlag)
        {
         for (Id id : ng_tr1_swPerTSDMap.keySet())
			{
    			NG_MainUtility.println(myDebugFlag,'Time Sheet Id ->'+id);
                Map<Id, TR1__ShiftWork__c> Values = new  Map<Id, TR1__ShiftWork__c>();
                Values = ng_tr1_swPerTSDMap.get(id);
                for (Id sid : Values.keySet())
   					NG_MainUtility.println(myDebugFlag,'Invoice Line Items->'+Values.get(sid));
			}
        }*/
		
      
        
    }
    public static Map<Id,TR1__Rate__c> getRateMap(set<Id> timesheets)
	{
		Map<Id,TR1__Rate__c> localrateMap = new Map<Id,TR1__Rate__c>([SELECT Id, 
                                                           	Name , 
                                                            TR1__Timesheet__c,
                                               				TR1__TimeType__c,
                                               				TR1__Job__c,
                                            				TR1__Expense_Report__c,
                                            				TR1__ClosingReport__c,
                                            				TR1__Account__c
                                                            FROM TR1__Rate__c 
                                                   		   Where TR1__Timesheet__c in :timesheets Order By TR1__Timesheet__c]);// From ts
		return 	localrateMap;
	}  
    
    public static Set<Id> getTimeTypeIds(Map<Id,TR1__Rate__c>  rateMap)
	{
        Set<Id> localTimeTypeIds = new Set<Id>();
        for (TR1__Rate__c rate: rateMap.values())
        {
            localTimeTypeIds.add(rate.TR1__TimeType__c);
        }
		return 	localTimeTypeIds;
	}  
    
    public static Map<Id,TR1__TimeType__c> getTimeTypeMaps(Set<Id> timeTypeIds)
	{
        Map<Id,TR1__TimeType__c> localTimeTypeMaps = new Map<Id,TR1__TimeType__c>([SELECT Id, 
                                                           	Name ,	QG_COA_Code__c
                                               				FROM TR1__TimeType__c 
                                                   		   	Where Id in :timeTypeIds]);
       
         return localTimeTypeMaps;
	}  
    
    public static Map<Id,TR1__Rate__c> getExpenseLineItemsRateMap(Map<Id,TR1__Expense_Report_Detail__c> expenseLineItems)
	{
        Set<Id> localRateTypeIds = new Set<Id>();
        for (TR1__Expense_Report_Detail__c eli: expenseLineItems.values())
        {
            localRateTypeIds.add(eli.TR1__Rate__c);
        }
        
		Map<Id,TR1__Rate__c> localrateMap = new Map<Id,TR1__Rate__c>([SELECT Id, 
                                                           	Name , 
                                                            TR1__Timesheet__c,
                                               				TR1__TimeType__c,
                                               				TR1__Job__c,
                                            				TR1__Expense_Report__c,
                                            				TR1__ClosingReport__c,
                                            				TR1__Account__c
                                                            FROM TR1__Rate__c 
                                                   		   Where Id in :localRateTypeIds Order By TR1__Timesheet__c]);// From Expense Line Items
		return 	localrateMap;
	}  
    
    public static Set<Id> getExpenseRateTimeTypeIds(Map<Id,TR1__Rate__c>  rateMap)
	{
        Set<Id> localTimeTypeIds = new Set<Id>();
        for (TR1__Rate__c rate: rateMap.values())
        {
            localTimeTypeIds.add(rate.TR1__TimeType__c);
        }
		return 	localTimeTypeIds;
	}  
    
     public static Map<Id,TR1__TimeType__c> getExpenseTimeTypeMaps(Set<Id> timeTypeIds)
	{
        Map<Id,TR1__TimeType__c> localTimeTypeMaps = new Map<Id,TR1__TimeType__c>([SELECT Id, 
                                                           	Name ,	QG_COA_Code__c
                                               				FROM TR1__TimeType__c 
                                                   		   	Where Id in :timeTypeIds]);
       
         return localTimeTypeMaps;
	}  
    
    public static Map<Id,TR1__Rate__c> getMileageRateMap()
	{
		Map<Id,TR1__Rate__c> localrateMap = new Map<Id,TR1__Rate__c>([SELECT Id, 
                                                           	Name , 
                                                            TR1__Timesheet__c,
                                               				TR1__TimeType__c,
                                               				TR1__Job__c,
                                            				TR1__Expense_Report__c,
                                            				TR1__ClosingReport__c,
                                            				TR1__Account__c
                                                            FROM TR1__Rate__c 
                                                            Where Name Like '%Mileage%' Limit 1
                                                   		  ]);// From ts
		return 	localrateMap;
	}  
    
    public static Map<Id,TR1__TimeType__c> getMileageTimeTypeMaps()
	{
        Map<Id,TR1__TimeType__c> localTimeTypeMaps = new Map<Id,TR1__TimeType__c>([SELECT Id, 
                                                           	Name ,	QG_COA_Code__c
                                               				FROM TR1__TimeType__c 
                                                            Where Name Like '%Mileage%' Limit 1
                                                   		   	]);
       
         return localTimeTypeMaps;
	}  
    // This will return a Map which will hold Invoice Id, Map of CR Id with list of Invoice Line Items against it.
    // THis is because 1 CR 1 Invoice Line Items and 1 invoice can have Multipe CRs
   /* public static  Map<Id,Map <Id, List<TR1_INV__Invoice_line_item__c> > > createILIPerCRPerInvoiceMap(Map<Id, TR1_INV__Invoice__c> ng_tr1_nonpermInoviceMap, 
                                                                                                      Map<Id, TR1_INV__Invoice_line_item__c> ng_tr1_iliMap)
    {
       Map<Id,Map <Id, List<TR1_INV__Invoice_line_item__c> > >localILIPerCRPerInvoiceMap = new Map<Id,Map <Id, List<TR1_INV__Invoice_line_item__c> > >();
       Map <Id, List<TR1_INV__Invoice_line_item__c> > localILIPerCRMap = new Map <Id, List<TR1_INV__Invoice_line_item__c> >();
      
      
       //Get All ili related to invoice in a List
       List<TR1_INV__Invoice_line_item__c> localRelatedILIPerInvoiceList = new List<TR1_INV__Invoice_line_item__c>();
       List<TR1_INV__Invoice_line_item__c> localRelatedILIPerCRList = new List<TR1_INV__Invoice_line_item__c>();
        
       for( TR1_INV__Invoice__c invoice : ng_tr1_nonpermInoviceMap.Values())           
       {
           //localrelatedILIMap = iliPerClosingReportMap.Get(invoice.C);
           for (TR1_INV__Invoice_line_item__c ili : ng_tr1_iliMap.values())
           {	
               
               if (invoice.Id == ili.TR1_INV__Invoice__c)
               {
                   localRelatedILIPerInvoiceList.add(ili);
               }
           }
           // Create ili per CR 
           if ((localRelatedILIPerInvoiceList!= null) && (localRelatedILIPerInvoiceList.size() > 0))
           {
               for (TR1_INV__Invoice_line_item__c ili : localRelatedILIPerInvoiceList)
           		{
                    if (localILIPerCRMap.containsKey(ili.TR1_INV__Closing_Report__c))
                    {
                        localILIPerCRMap.get(ili.TR1_INV__Closing_Report__c).add(ili);
                    }
                    else
                    {
                        List <TR1_INV__Invoice_line_item__c> localiliList = new List<TR1_INV__Invoice_line_item__c>();
                        localiliList.add(ili);
                        localILIPerCRMap.put(ili.TR1_INV__Closing_Report__c,localiliList);
                    }
               
          		}
           }
           
           if ((localILIPerCRMap != null) && (localILIPerCRMap.size() >0))
           {
               localILIPerCRPerInvoiceMap.put(invoice.Id,localILIPerCRMap);
           }
           
          
       }
        
        return localILIPerCRPerInvoiceMap;
    }*/
    
}