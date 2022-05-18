@isTest
public class TimesheetTrigger_Test {
    @isTest
    public static void testTimesheetTrigger() {
        Account a = MockFactory.createAccount();
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c trt = MockFactory.createTRTimesheet(c.Id);
        NG_Timesheet__c timesheet = new NG_Timesheet__c();
        timesheet.Employee__c = c.Id;
        timesheet.Work_Location__c = a.Id;
        timesheet.Source_Object_ID__c = 'for testing only';
        
        insert timesheet;

        update timesheet;

        delete timesheet;
    }
}