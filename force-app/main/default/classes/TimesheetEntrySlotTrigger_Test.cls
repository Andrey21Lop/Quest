@isTest
public class TimesheetEntrySlotTrigger_Test {
    @isTest
    public static void testTimesheetEntrySlotTrigger() {
        Account a = MockFactory.createAccount();
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c trt = MockFactory.createTRTimesheet(c.Id);
        NG_Timesheet__c timesheet = new NG_Timesheet__c();
        timesheet.Employee__c = c.Id;
        timesheet.Work_Location__c = a.Id;
        timesheet.Source_Object_ID__c = 'for testing only';
        
        insert timesheet;

        NG_Timesheet_Entry__c entry = new NG_Timesheet_Entry__c();
        entry.Timesheet__c = timesheet.Id;
        entry.Source_Object_ID__c = 'for testing only';
        insert entry;

        NG_Timesheet_Entry_Slot__c slot = new NG_Timesheet_Entry_Slot__c();
        slot.Timesheet_Entry__c = entry.Id;
        insert slot;

        update slot;

        delete slot;
    }
}