@isTest 
public class TimesheetService_Test {
    @isTest
    public static void testFetchTimesheetsForEmployee() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);

        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        System.assertEquals(1, timesheets.size());
        System.assertEquals(t.Id, timesheets[0].Source_Object_ID__c);

    }

    @isTest
    public static void testFetchTimesheetEntriesForTimesheet() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);   
        System.assertEquals(1, entries.size());
        System.assertEquals(MockFactory.TimesheetDetail.Id, entries[0].Source_Object_ID__c);

    }

    @isTest
    public static void testFetchTimesheetEntry() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);         
    
        NG_Timesheet_Entry__c entry = TimesheetService.fetchTimesheetEntry(entries[0].Id);
        System.assertEquals(entries[0].Id, entry.Id);
    }

    @isTest
    public static void testFetchTimesheetEntrySlotsForEntry() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);         

        List<NG_Timesheet_Entry_Slot__c> slots = TimesheetService.fetchTimesheetEntrySlotsForEntry(entries[0].Id);
        System.assertEquals(1, slots.size());
        System.assertEquals(slots[0].Id, entries[0].Default_Slot__c);
        System.assertEquals(Date.today().addDays(-1), slots[0].Timesheet_Entry__r.Date__c);
        System.assertEquals(entries[0].Source_Object_ID__c, slots[0].Timesheet_Entry_Source_Object_ID__c);
        System.assertEquals(timesheets[0].Source_Object_ID__c, slots[0].Timesheet_Source_Object_ID__c);
    }

    @isTest
    public static void testFetchTimesheetEntrySlot() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);         
        List<NG_Timesheet_Entry_Slot__c> slots = TimesheetService.fetchTimesheetEntrySlotsForEntry(entries[0].Id);

        NG_Timesheet_Entry_Slot__c slot = TimesheetService.fetchTimesheetEntrySlot(slots[0].Id);
        System.assertEquals(slots[0].Id, slot.Id);

    }

    @isTest
    public static void testAddTimesheetEntry() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        NG_Timesheet_Entry__c entry = TimesheetService.addTimesheetEntry(timesheets[0].Id);
        System.assert(entry != null);
    }

    @isTest
    public static void testSubmitTimesheet() {
        TestHelper.setupTriggerHelpers();
        
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
		
        Test.startTest();
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);
        List<NG_Timesheet_Entry_Slot__c> slots = TimesheetService.fetchTimesheetEntrySlotsForEntry(entries[0].Id);
        slots[0].In_Date__c = '2019-10-07';
        slots[0].In_Time__c = '9:00';
        slots[0].Out_Date__c = '2019-10-07';
        slots[0].Out_Time__c = '18:00';
        slots[0].Custom_On_Call_Beeper__c = 'No';
        update slots[0];

        NGCSH__c settings = NGCSH__c.getOrgDefaults();
        settings.Allow_Zero_Hour_Timesheet_Entries__c = true;
        upsert settings settings__c.Id;
        
        TimesheetService.submitTimesheet(timesheets[0].Id);
        timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        System.assertEquals(0, timesheets.size());

        timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Submitted');
        System.assertEquals(1, timesheets.size());
        Test.stopTest();
    }
}