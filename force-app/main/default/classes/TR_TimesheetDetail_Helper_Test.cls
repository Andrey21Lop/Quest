@isTest
public class TR_TimesheetDetail_Helper_Test {
    @isTest
    public static void testTR_TimesheetDetail_Helper() {
        TestHelper.setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        TR1__Timesheet_Detail__c d = MockFactory.TimesheetDetail;

        d.TR1__Date__c = date.today();
        update d;

        system.debug('bw-testing: delete Timesheet Detail trigger');
        delete d;
    }
}