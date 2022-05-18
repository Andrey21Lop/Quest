public without sharing class TimesheetGateway {
    public static NG_Timesheet__c fetch(Id timesheetId) {
        NG_Timesheet__c timesheet = [SELECT Id, Work_Location__c, Work_Location__r.Name,
                                            Status__c, Week_Start__c, Week_End__c,
                                            Source_Object_ID__c, Rejection_Reason__c,
                                            Employee__c, Employee__r.Name,NG_UUID__c, 
                                            Timesheet_Approver__r.FirstName,Timesheet_Approver__r.Email,
                                            OT_Threshold_Type__c, OT_Threshold_Hours__c, 
                                     		QG_TS_Portal_Approver__c, QG_Portal_TS_Number_Text__c,   
                                            (SELECT ID, Total_Hours__c, Did_Not_Work__c FROM Timesheet_Entries__r)
                                     FROM NG_Timesheet__c
                                     WHERE Id = :timesheetId];
        
        return timesheet;
    }

    public static List<NG_Timesheet__c> fetchTimesheetsForContact(Id contactId, String statusFilter) {
        List<NG_Timesheet__c> timesheets;
        
        if(statusFilter != null && statusFilter != '' && statusFilter != 'All') {
            timesheets = [SELECT Id, Work_Location__c, Work_Location__r.Name, Total_Weekly_Regular_Hours__c, Total_Weekly_Overtime_Hours__c,
                                                    Status__c, Week_Start__c, Week_End__c,
                                                    Source_Object_ID__c, Rejection_Reason__c, 
                          							QG_TS_Portal_Approver__c, QG_Portal_TS_Number_Text__c 
                                                FROM NG_Timesheet__c
                                                WHERE Employee__c = :contactId
                                                    AND Status__c = :statusFilter
                                                    AND id in (SELECT Timesheet__c
                                                               FROM NG_Timesheet_Entry__c 
                                                               WHERE Timesheet__r.Employee__c = :contactId)
                                                ORDER BY Week_End__c ASC];
        }
        else {
            timesheets = [SELECT Id, Work_Location__c, Work_Location__r.Name, Total_Weekly_Regular_Hours__c, Total_Weekly_Overtime_Hours__c,
                                                    Status__c, Week_Start__c, Week_End__c,
                                                    Source_Object_ID__c, Rejection_Reason__c, 
                          							QG_TS_Portal_Approver__c, QG_Portal_TS_Number_Text__c   
                                                FROM NG_Timesheet__c
                                                WHERE Employee__c = :contactId
                                                    AND id in (SELECT Timesheet__c
                                                               FROM NG_Timesheet_Entry__c 
                                                               WHERE Timesheet__r.Employee__c = :contactId)
                                                ORDER BY Week_End__c];
        }

        system.debug('bw: fetchTimehseetsForContact -> timesheets = ' + timesheets);
        return timesheets;
    }

    public static void save(NG_Timesheet__c timesheet) {
        system.debug('bw: TimesheetGateway.save -> timesheet = ' + timesheet);
        update timesheet;
        TR1__Timesheet__c tr1TimeSheet = TR_Timesheet_Gateway.synchronize(timesheet);
    }

    public static String getAccountNameFromTimesheet(NG_Timesheet__c timesheet) {
        return AccountGateway.getName(timesheet.Work_Location__c);
    }

    public static NG_Timesheet__c getTimesheetFromTR_Timesheet(TR1__Timesheet__c tr1Timesheet) {
        NG_Timesheet__c retVal = null;

        List<NG_Timesheet__c> timesheets = [SELECT Id, Employee__c,Status__c,Week_End__c,
                       Work_Location__c,Source_Object_ID__c, 
                       QG_TS_Portal_Approver__c, QG_Portal_TS_Number_Text__c
                FROM NG_Timesheet__c 
                WHERE Source_Object_ID__c = :tr1Timesheet.Id];
        
        if(timesheets.size()!=0) {
            retVal = timesheets[0];
        }

        return retVal;
    }

    public static NG_Timesheet__c getTimesheetFromSourceObjectId(Id sourceObjectId) {
         NG_Timesheet__c retVal = null;

        List<NG_Timesheet__c> timesheets = [SELECT Id, Employee__c,Status__c,Week_End__c,
                       Work_Location__c,Source_Object_ID__c, 
                       QG_TS_Portal_Approver__c, QG_Portal_TS_Number_Text__c
                FROM NG_Timesheet__c 
                WHERE Source_Object_ID__c = :sourceObjectId];
        
        if(timesheets.size()!=0) {
            retVal = timesheets[0];
        }

        return retVal;       
    }

    public static SObjectUnitOfWork deleteBySourceObjectId(Id sourceObjectId) {
        List<Schema.SObjectType> MY_SOBJECTS = 
            new Schema.SObjectType[] {
                NG_Timesheet__c.SObjectType
            };
        SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);

        try {
            NG_Timesheet__c timesheet = [SELECT Id FROM NG_Timesheet__c WHERE Source_Object_ID__c = :sourceObjectId];
            uow.registerDeleted(timesheet);

            return uow;
        }
        catch(Exception e) {
            system.debug('bw: deleteBySourceObjectId -> error = ' + e);
        }

        return null;
    }

    public static NG_Timesheet__c createDirect(TR1__Timesheet__c tr1Timesheet) {
        system.debug('bw: NGTimesheet.createDirect');
        NG_Timesheet__c timesheet = new NG_Timesheet__c();
        timesheet.Employee__c = tr1Timesheet.TR1__Consultant__c;
        timesheet.Timesheet_Approver__c = tr1Timesheet.TR1__Approver__c;
        timesheet.Status__c = (tr1Timesheet.TR1__Status__c == 'Processed' ? 'Approved' : tr1Timesheet.TR1__Status__c);
        timesheet.Week_End__c = tr1Timesheet.TR1__Week_Ending__c;
        timesheet.Work_Location__c = (tr1Timesheet.Work_Shift_Location__c != null ? tr1Timesheet.Work_Shift_Location__c : tr1Timesheet.TR1__Client__c);
        timesheet.Source_Object_ID__c = tr1Timesheet.Id;
        timesheet.QG_TS_Portal_Approver__c = tr1Timesheet.QG_Portal_Timesheet_Approver__c;	
        timesheet.QG_Portal_TS_Number_Text__c = tr1Timesheet.QG_Portal_TS_Number__c;	
        insert timesheet;

        return timesheet;
    }

    public static SObjectUnitOfWork create (TR1__Timesheet__c tr1Timesheet) {
        system.debug('bw: NGTimesheet.create');
        List<Schema.SObjectType> MY_SOBJECTS = 
            new Schema.SObjectType[] {
                NG_Timesheet__c.SObjectType
            };
        SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);

        NG_Timesheet__c timesheet = new NG_Timesheet__c();
        timesheet.Employee__c = tr1Timesheet.TR1__Consultant__c;
        timesheet.Timesheet_Approver__c = tr1Timesheet.TR1__Approver__c;
        timesheet.Status__c = (tr1Timesheet.TR1__Status__c == 'Processed' ? 'Approved' : tr1Timesheet.TR1__Status__c);
        timesheet.Week_End__c = tr1Timesheet.TR1__Week_Ending__c;
        timesheet.Work_Location__c = (tr1Timesheet.Work_Shift_Location__c != null ? tr1Timesheet.Work_Shift_Location__c : tr1Timesheet.TR1__Client__c);
        timesheet.Source_Object_ID__c = tr1Timesheet.Id;
        timesheet.QG_TS_Portal_Approver__c = tr1Timesheet.QG_Portal_Timesheet_Approver__c;
        timesheet.QG_Portal_TS_Number_Text__c = tr1Timesheet.QG_Portal_TS_Number__c;	
        uow.registerNew(timesheet);

        return uow;
    }

    public static List<SObjectUnitOfWork> synchronize(TR1__Timesheet__c tr1Timesheet) {
        return synchronize(tr1Timesheet, false);
    }

    public static List<SObjectUnitOfWork> synchronize(TR1__Timesheet__c tr1Timesheet,Boolean isMultiDay) {
        List<SObjectUnitOfWork> uows = new List<SObjectUnitOfWork>();
        
        List<Schema.SObjectType> MY_SOBJECTS = 
            new Schema.SObjectType[] {
                NG_Timesheet__c.SObjectType,
                NG_Timesheet_Entry__c.SObjectType,
                NG_Timesheet_Entry_Slot__c.SObjectType
            };
        SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
        SObjectUnitOfWork uow2 = new SObjectUnitOfWork(MY_SOBJECTS);

        NG_Timesheet__c timesheet = getTimesheetFromTR_Timesheet(tr1Timesheet);
        if(timesheet == null) {
            //timesheet = createDirect(tr1Timesheet);
            return uows;
        }

        if(timesheet.Employee__c ==  null)
            timesheet.Employee__c = tr1Timesheet.TR1__Consultant__c;
        timesheet.Status__c = (tr1Timesheet.TR1__Status__c == 'Processed' ? 'Approved' : tr1Timesheet.TR1__Status__c);
        timesheet.Week_End__c = tr1Timesheet.TR1__Week_Ending__c;

        if(timesheet.Work_Location__c == null)
            timesheet.Work_Location__c = (tr1Timesheet.Work_Shift_Location__c != null ? tr1Timesheet.Work_Shift_Location__c : tr1Timesheet.TR1__Client__c);
        timesheet.Total_Weekly_Regular_Hours__c = tr1Timesheet.NG_Total_Regular_Shift_Hours__c;
        timesheet.Total_Weekly_Overtime_Hours__c = tr1Timesheet.NG_Total_Overtime_Shift_Hours__c;

        uow.registerDirty(timesheet);

        List<NG_Timesheet_Entry__c> entries  = TimesheetEntryGateway.fetchTimesheetEntriesForTimesheet(timesheet.Id);
        if(entries.size() == 0) {
            System.debug('bw: TimesheetGateway.synchronize -> create entries');
            //entries are out of sync, sync them.
            List<TR1__Timesheet_Detail__c> details = TR_TimesheetDetail_Gateway.fetchTimesheetDetailsForTimesheetId(tr1Timesheet.Id);
            if(details != null && details.size() > 0) {
                System.debug('bw: TimesheetGateway.synchronzie -> details = ' + details);
                for(TR1__Timesheet_Detail__c detail : details) {

                    NG_Timesheet_Entry__c entry = new NG_Timesheet_Entry__c();
                    entry.Date__c = detail.TR1__Date__c;
                    entry.Day__c = detail.TR1__Day__c;
                    entry.Source_Object_ID__c = detail.Id;
                    uow.registerNew(entry, NG_Timesheet_Entry__c.Timesheet__c, timesheet);

                    NG_Timesheet_Entry_Slot__c slot = new NG_Timesheet_Entry_Slot__c();
                    slot.Is_Multi_Day__c = isMultiDay;
                    uow.registerNew(slot, NG_Timesheet_Entry_Slot__c.Timesheet_Entry__c, entry);

                    uow2.registerRelationship(entry, NG_Timesheet_Entry__c.Default_Slot__c, slot);
                }
            }
        }

        uows.add(uow);
        uows.add(uow2);
        
        return uows;
    }

    public static String generateRandomNumber(){
        Integer len = 4;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, len);
        return randomNumber;
    }
}