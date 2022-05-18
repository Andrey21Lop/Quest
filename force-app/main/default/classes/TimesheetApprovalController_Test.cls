@isTest
public class TimesheetApprovalController_Test {
    @isTest
    public static void testController() {
        TestHelper.setupTriggerHelpers();

        NGCSH__c settings = NGCSH__c.getOrgDefaults();
        settings.TS_Sender_Email__c = 'test@test.com';
        settings.TS_BCC_Addresses__c = 'test2@test.com,test3@test.com';
        upsert settings settings__c.Id;

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        TimesheetApprovalController.timesheetId = timesheets[0].Source_Object_ID__c;

        TimesheetApprovalController ctl = new TimesheetApprovalController();
        ctl.save();
         NG_Timesheet__c t1= ctl.getTimesheet();
        List<TimesheetDetailsController.TimesheetDetail> t2 = ctl.getEntryList();
    }
    @isTest
    public static void testController2() {
        TestHelper.setupTriggerHelpers();

        NGCSH__c settings = NGCSH__c.getOrgDefaults();
        settings.TS_Sender_Email__c = 'test@test.com';
        settings.TS_BCC_Addresses__c = 'test2@test.com,test3@test.com';
        upsert settings settings__c.Id;

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        
        NG_Timesheet__c ngUpd = new NG_Timesheet__c();
        ngUpd.Id = timesheets[0].Id;
        ngUpd.QG_TS_Portal_Approver__c = 'test';
        update ngUpd;

        TimesheetApprovalController.timesheetId = timesheets[0].Source_Object_ID__c;

        TimesheetApprovalController ctl = new TimesheetApprovalController();
        ctl.save();
    }
    @isTest
    public static void testController1() {
        TestHelper.setupTriggerHelpers();

        NGCSH__c settings = NGCSH__c.getOrgDefaults();
        settings.TS_Sender_Email__c = 'test@test.com';
        settings.TS_BCC_Addresses__c = 'test2@test.com,test3@test.com';
        upsert settings settings__c.Id;

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        //system.debug('Mock1:'+timesheets[0].Source_Object_ID__c);
        NG_Timesheet__c ngUpd = new NG_Timesheet__c();
        ngUpd.Id = timesheets[0].Id;
        ngUpd.Status__c = 'Rejected';
        ngUpd.Rejection_Reason__c = null;
        update ngUpd;
        //system.debug('Mock2:'+ngUpd.Id);

        TimesheetApprovalController.timesheetId = timesheets[0].Source_Object_ID__c;
        
        TimesheetApprovalController ctl = new TimesheetApprovalController();
        ctl.save();
    }
}