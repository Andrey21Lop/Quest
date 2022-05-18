@isTest
public class TR_ShiftWork_Gateway_Test {
    @isTest
    public static void testFetch() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        NG_Timesheet__c ngt;
        for(NG_Timesheet__c timesheet : timesheets) {
            if(timesheet.Source_Object_ID__c == t.Id){
                ngt = timesheet;
                break;
            }
        }
        
        
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(ngt.Id);
        NG_Timesheet_Entry__c e = entries[0];

        Test.startTest();
        NG_Timesheet_Entry_Slot__c s = TimesheetService.fetchTimesheetEntrySlot(e.Default_Slot__c);
        s.In_Time__c = '07:00';
        s.Out_Time__c = '18:00';
        s.Out_Date__c = '2019-10-28';
        s.In_Date__c = '2019-10-28';
        s.Last_Updated_Hours__c = 0;
        update s;
        
        s = TimesheetService.fetchTimesheetEntrySlot(e.Default_Slot__c);

        TR1__ShiftWork__c sh = TR_ShiftWork_Gateway.fetch(s.Source_Object_ID__c);
        System.assert(sh != null);
        Test.stopTest();
    }
	
    
    @isTest
    public static void testFetchShiftWorkForTimesheetDetailId() {
         TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);         

        Test.startTest();
        NG_Timesheet_Entry_Slot__c s = TimesheetService.fetchTimesheetEntrySlot(entries[0].Default_Slot__c);
        s.In_Time__c = '07:00';
        s.Out_Time__c = '18:00';
        s.Out_Date__c = '2019-10-28';
        s.In_Date__c = '2019-10-28';
        update s;
        s = TimesheetService.fetchTimesheetEntrySlot(entries[0].Default_Slot__c);

        TR1__ShiftWork__c sh = TR_ShiftWork_Gateway.fetchShiftWorkForTimesheetDetailId(s.Timesheet_Entry_Source_Object_ID__c);
        System.assert(sh != null);

        TR_ShiftWork_Gateway.save(sh);
        
        TR1__Rate__c rate = MockFactory.createTRRate();
        
        TR_ShiftWork_Gateway.save('Regular', 
                                  s.Source_Object_ID__c, 
                                  s.Timesheet_Source_Object_ID__c, 
                                  s.Timesheet_Entry_Source_Object_ID__c, 
                                  rate.Id, 
                                  'Yes', 
                                  s.In_Time__c, 
                                  Date.today(), 
                                  s.Out_Time__c, 
                                  11);
        
         TR_ShiftWork_Gateway.save('Overtime', 
                                  s.Source_Object_ID__c, 
                                  s.Timesheet_Source_Object_ID__c, 
                                  s.Timesheet_Entry_Source_Object_ID__c, 
                                  rate.Id, 
                                  'Yes', 
                                  s.In_Time__c, 
                                  Date.today(), 
                                  s.Out_Time__c, 
                                  11);
        Test.stopTest();
    }
}