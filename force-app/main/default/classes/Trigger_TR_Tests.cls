@isTest
public class Trigger_TR_Tests {
    @isTest
    public static void exerciseTRTimesheetTriggers() {
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);

        update t;

        delete t;
    }

    @isTest
    public static void exerciseTRTimesheetDetailTriggers() {
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        TR1__Timesheet_Detail__c td = MockFactory.createTRTimesheetDetail(t.Id);
        
        update td;

        delete td;
    }
}