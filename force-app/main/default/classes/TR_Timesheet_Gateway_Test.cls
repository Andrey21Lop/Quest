@isTest
public class TR_Timesheet_Gateway_Test {
    @isTest
    public static void testFetchWorkLocationId() {
        Contact c = MockFactory.createContact();
        Account a = MockFactory.createAccount();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        t.Work_Shift_Location__c = a.Id;
        update t;

        Id wkId = TR_Timesheet_Gateway.fetchWorkLocationId(t.Id);
        System.assertEquals(a.Id, wkId);
    }

    @isTest
    public static void testFetch() {
        Contact c = MockFactory.createContact();
        Account a = MockFactory.createAccount();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id); 

        TR1__Timesheet__c t2 = TR_Timesheet_Gateway.fetch(t.Id);
        System.assert(t2 != null);
              
    }
    
    @isTest
    public static void testSynchronize() {

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        NG_Timesheet__c ngUpd = new NG_Timesheet__c();
        ngUpd.Id = timesheets[0].Id;
        ngUpd.Source_Object_ID__c = t.id;
        ngUpd.Status__c = 'Unsubmitted';
        ngUpd.Rejection_Reason__c = 'Test Reason';
        ngUpd.NG_UUID__c = 'Test UUID';
        ngUpd.QG_TS_Portal_Approver__c = 'Approved';
        ngUpd.QG_Portal_TS_Number_Text__c = 'Approved Test';
        update ngUpd;

        Test.startTest();
        NG_Timesheet__c ttst = [select Id,Source_Object_ID__c,Status__c,Rejection_Reason__c,NG_UUID__c,QG_TS_Portal_Approver__c,QG_Portal_TS_Number_Text__c from NG_Timesheet__c where id=:ngUpd.Id ];
        TR1__Timesheet__c t2 = TR_Timesheet_Gateway.synchronize(ttst);
        Test.stopTest();
              
    }
}