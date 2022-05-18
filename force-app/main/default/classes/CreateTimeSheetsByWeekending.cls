/************************************************************************************************************
Acc-Product Team 1:10/3/2017: W-008217 - TR core - Timesheet generation based on week end from Closing Report
*************************************************************************************************************/
global with sharing class CreateTimeSheetsByWeekending implements Database.Batchable<sObject>{
    global final String query;
    global Date runDate;
    global boolean weekStartflag=false;
    global CreateTimeSheetsByWeekending (String q){         
        this.query = q;
        this.runDate = Date.today().tostartofWeek();
        Datetime runDateTime = datetime.newInstance(runDate.year(), runDate.month(),runDate.day());
        if(runDateTime.format('EEEE').equalsIgnoreCase('Sunday')) {
            runDate = runDate.addDays(1);
        }
        //if(runDateTime.format('EEEE').equalsIgnoreCase('Monday')){
        //    runDate = runDate.addDays(-1);
        //}        
    }

    global CreateTimeSheetsByWeekending (List<sObject> scope) {
        this.runDate = Date.today().tostartofWeek().addDays(1);
        Datetime runDateTime = datetime.newInstance(runDate.year(), runDate.month(),runDate.day());
        if(runDateTime.format('EEEE').equalsIgnoreCase('Sunday')) {
            runDate = runDate.addDays(1);
        }
        //if(runDateTime.format('EEEE').equalsIgnoreCase('Monday')){
        //    runDate = runDate.addDays(-1);
        //}  

        execute(null, scope);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('Current scope size:'+scope);
        if (scope.size()>0){
            List<TR1__Timesheet__c> timesheets = new List<TR1__Timesheet__c>(); // to remove namespace
            Set<Id> cridset = new Set<Id>();        
            Set<Id> defcridset = new Set<Id>();        
            Date weekenddate;
            Date defaultweekenddate;
            integer AddDaysForMondayOffset = 0;
            //Date StartOfWeek;
            //Date EndOfWeek;

            weekenddate = runDate.addDays(6);

            defaultweekenddate = TR1.Utility.calculateEndDateBasedOnTimesheetType(runDate, 'Weekly');
            system.debug('weekend date:'+weekenddate);
            system.debug('def weekend date:'+defaultweekenddate); 
            
            TR1__Closing_Report__c cReport;
            Map<Id,Id> mapCRWID = new Map<Id, Id>();
            Map<Id,TR1__Closing_Report__c> mapCRIdVsCR = new Map<Id,TR1__Closing_Report__c>();
            set<Id> worksiteIds = new set<Id>();

            for(Sobject cR:scope){
                cReport = (TR1__Closing_Report__c)cR;       
                mapCRIdVsCR.put(cReport.Id,cReport);
                mapCRWID.put(cReport.Id, cReport.TR1__Account__c);
            }

            Map<Id,Account> worsiteLocations = new map<Id,Account>([select id, Name from Account
                                                                    where id in :mapCRWID.values()]);

            list<TR1__Timesheet__c> timesheetList = [SELECT TR1__Closing_Report__c,TR1__Week_Ending__c,Work_Shift_Location__c
                                                     FROM TR1__Timesheet__c
                                                     WHERE TR1__Closing_Report__c IN :mapCRIdVsCR.keyset() 
                                                     AND (TR1__Week_Ending__c = :weekenddate OR TR1__Week_Ending__c = :defaultweekenddate)];
            
            list<TR1__Timesheet_Detail__c> timesheetDetailList = [SELECT TR1__Timesheet__c, TR1__Date__c, TR1__Day__c
                                                                  FROM TR1__Timesheet_Detail__c
                                                                  WHERE TR1__Timesheet__c in :timesheetList];

            Map<Id,Map<Id,TR1__Timesheet__c>> mapCRVSWSIdVSTimesheet = new Map<Id,Map<Id,TR1__Timesheet__c>>();
            map<Id,list<TR1__Timesheet_Detail__c>> mapCRIdVsTimesheetDetails = new map<Id,list<TR1__Timesheet_Detail__c>>();

            // Creating a map which holds all the Timesheet of CR based on Work site location
            for(TR1__Timesheet__c timesheet:timesheetList){
                if(mapCRVSWSIdVSTimesheet.containskey(timesheet.TR1__Closing_Report__c)){
                    mapCRVSWSIdVSTimesheet.get(timesheet.TR1__Closing_Report__c).put(timesheet.Work_Shift_Location__c,timesheet);
                }else{
                   mapCRVSWSIdVSTimesheet.put(timesheet.TR1__Closing_Report__c, new map<Id,TR1__Timesheet__c>{timesheet.Work_Shift_Location__c =>timesheet}); 
                }

                for(TR1__Timesheet_Detail__c timesheetDetail:timesheetDetailList) {
                    if(mapCRIdVsTimesheetDetails.containskey(timesheet.TR1__Closing_Report__c)) {
                        mapCRIdVsTimesheetDetails.get(timesheet.TR1__Closing_Report__c).add(timesheetDetail);
                    }
                    else {
                        mapCRIdVsTimesheetDetails.put(timesheet.TR1__Closing_Report__c, new List<TR1__Timesheet_Detail__c>{timesheetDetail});
                    }
                }
            }
            
            system.debug('*************Timesheet******'+mapCRVSWSIdVSTimesheet);
            list<TR1__Timesheet__c> newtimesheetList = new list<TR1__Timesheet__c>();
            TR1__Timesheet__c timesheet;
            // Creating a timesheet if the corresponding worksite location not present
            for(Id cReportId:mapCRIdVsCR.keyset()){
                cReport  = mapCRIdVsCR.get(cReportId);
                Id worksiteId = mapCRWID.get(cReportId);

                if(mapCRVSWSIdVSTimesheet != null && mapCRVSWSIdVSTimesheet.containskey(cReportId)
                    && mapCRVSWSIdVSTimesheet.get(cReportId).containsKey(worksiteId)){
                }else{
                    timesheet = new TR1__Timesheet__c();
                    timesheet.TR1__Status__c='Unsubmitted';
                    timesheet.TR1__Closing_Report__c =cReport.Id;
                    timesheet.TR1__Consultant__c=cReport.TR1__Person_Placed__c;
                    timesheet.TR1__Job_Order__c = cReport.TR1__Job__c;
                    timesheet.TR1__Approver__c= cReport.TR1__Timesheet_Approver__c;                      
                    timesheet.TR1__Timesheet_Second_Approver__c = cReport.TR1__Timesheet_Second_Approver__c;
                    timesheet.TR1__Client__c= cReport.TR1__Account__c;
                    timesheet.TR1__Week_Ending__c = weekenddate; 
                    timesheet.TR1__Pay_Week_Ending__c = weekenddate; 
                    timesheet.Work_Shift_Location__c = worksiteId;
                    newtimesheetList.add(timesheet); 
                }

            }  
            
            Database.insert(newtimesheetList,false);
            for(TR1__Timesheet__c tsheet:newtimesheetList){
                if(mapCRVSWSIdVSTimesheet.containskey(tsheet.TR1__Closing_Report__c)){
                    mapCRVSWSIdVSTimesheet.get(tsheet.TR1__Closing_Report__c).put(tsheet.Work_Shift_Location__c,tsheet);
                }else{
                   mapCRVSWSIdVSTimesheet.put(tsheet.TR1__Closing_Report__c, new map<Id,TR1__Timesheet__c>{tsheet.Work_Shift_Location__c =>tsheet}); 
                }
            }
            
            TR1__Timesheet_Detail__c tDetail;
            list<TR1__Timesheet_Detail__c> tDetailList = new list<TR1__Timesheet_Detail__c>();
            set<Id> timesheetIds = new set<Id>();

            list<date> datesBetweenRunAndEnd = new list<date>();
            datesBetweenRunAndEnd.add(runDate);
            
            Date startDate = runDate;
            while(startDate < weekenddate) {
                datesBetweenRunAndEnd.add(startDate.addDays(1));
                startDate = startDate.addDays(1);
            }

            

            // Creating/updating timesheets based on work site location
            for(Id cReportId:mapCRIdVsCR.keyset()){
                cReport  = mapCRIdVsCR.get(cReportId);
                Id worksiteId = mapCRWID.get(cReportId);

                for(integer i = 0; i < datesBetweenRunAndEnd.size(); i++) {
                    if(!mapCRIdVsTimesheetDetails.containskey(cReportId)){
                        // system.debug('****cReportId**********'+cReportId);
                        // system.debug('*******worksiteId****'+worksiteId);
                        // system.debug('**********mapCRVSWSIdVSTimesheet.get(cReportId).get(worksiteId)**'+mapCRVSWSIdVSTimesheet.get(cReportId).get(worksiteId));
                        tDetail = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = mapCRVSWSIdVSTimesheet.get(cReportId).get(worksiteId).id, 
                                                                TR1__Date__c = datesBetweenRunAndEnd[i] ,
                                                                TR1__Day__c = TR1.Utility.dayOfDate(datesBetweenRunAndEnd[i]));
                        tDetailList.add(tDetail);
                    }else{
                        for(TR1__Timesheet_Detail__c tDet:mapCRIdVsTimesheetDetails.get(cReportId)){
                            if(tDet.TR1__Date__c != datesBetweenRunAndEnd[i]){
                                    if(tDet.TR1__Date__c != datesBetweenRunAndEnd[i] ){
                                        tDet.TR1__Date__c = datesBetweenRunAndEnd[i] ;
                                    }

                                    tDet.TR1__Timesheet__c = mapCRVSWSIdVSTimesheet.get(cReportId).get(worksiteId).id;
                                	boolean exists = false;
                                	for(TR1__Timesheet_Detail__c d:tDetailList){
                                        if(d.Id == tDet.Id) {
                                            exists = true;
                                            break;
                                        }
                                	}
                                	
                                	if(!exists)
                                    	tDetailList.add(tDet);
                            }
                        }
                    }
                }
                    
            }
            system.debug('***tDetailList*******'+tDetailList);
            Database.upsert(tDetailList, false);
            //Delete the Timesheets if there are no timesheet details present
            list<TR1__Timesheet__c> deleteTList = new list<TR1__Timesheet__c>();
            timesheetList = [SELECT Id, Name,(SELECT Id, Name FROM TR1__Timecards__r ) FROM TR1__Timesheet__c 
                                                        WHERE TR1__Closing_Report__c IN :mapCRIdVsCR.keyset() 
                                                        AND (TR1__Week_Ending__c = :weekenddate OR TR1__Week_Ending__c = :defaultweekenddate) ];
            for(TR1__Timesheet__c  tSh: timesheetList){
                if(tSh.TR1__Timecards__r == null || tSh.TR1__Timecards__r.size() == 0){
                    deleteTList.add(tSh);
                }
            }
            if(deleteTList != null && deleteTList.size() > 0){
                Database.delete(deleteTList,false);
            }            
        }
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];    
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Timesheet Creation Batch program ' + a.Status);
            mail.setPlainTextBody
            ('The batch Apex job'+'('+ BC.getJobId()+')processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception ex){}
    }
}