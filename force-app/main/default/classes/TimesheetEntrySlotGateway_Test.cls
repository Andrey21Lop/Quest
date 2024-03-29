@isTest
public class TimesheetEntrySlotGateway_Test {
    @isTest
    public static void testCreate() {
        /*
        NG_Timesheet__c t = new NG_Timesheet__c();
        insert t;

        NG_Timesheet_Entry__c e = new NG_Timesheet_Entry__c();
        e.Timesheet__c = t.Id;
        insert e;
		*/
        
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);

        NG_Timesheet_Entry_Slot__c s = TimesheetEntrySlotGateway.create(entries[0]);
        System.assertEquals(entries[0].Id, s.Timesheet_Entry__c);
    }

    

    @isTest
    public static void testSave() {
        /*
        NG_Timesheet__c t = new NG_Timesheet__c();
        insert t;

        NG_Timesheet_Entry__c e = new NG_Timesheet_Entry__c();
        e.Timesheet__c = t.Id;
        insert e;
		*/
        
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);
        NG_Timesheet_Entry__c e = entries[0];

        NG_Timesheet_Entry_Slot__c s = TimesheetEntrySlotGateway.create(e);
        s.Date__c = date.today();
        s.Day__c = 'Sunday';
        
        TimesheetEntrySlotGateway.save(s);

        e = TimesheetEntryGateway.fetch(e.Id);
        System.assertEquals(date.today(), e.Date__c);
        System.assertEquals('Sunday', e.Day__c);
    }


    @isTest
    public static void testDeleteBySourceObjectId() {
        /*
        NG_Timesheet__c t = new NG_Timesheet__c();
        insert t;

        NG_Timesheet_Entry__c e = new NG_Timesheet_Entry__c();
        e.Timesheet__c = t.Id;
        insert e;

        NG_Timesheet_Entry_Slot__c s = TimesheetEntrySlotGateway.create(e);
        s.Source_Object_ID__C = '123';
        
        TimesheetEntrySlotGateway.save(s);

        TimesheetEntrySlotGateway.deleteBySourceObjectId('123');

        List<NG_Timesheet_Entry_Slot__c> slots = [SELECT Id FROM NG_Timesheet_Entry_Slot__c];
        System.assertEquals(0, slots.size());
        */
    }
}