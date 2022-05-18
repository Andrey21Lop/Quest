@isTest
public class TimesheetDetailsController_Tests {
	@isTest
    public static void test() {
        TestHelper.setupTriggerHelpers();
            
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c trt = MockFactory.createTRTimesheet(c.Id);
        TimesheetDetailsController tdc = new TimesheetDetailsController();
        
        List<NG_Timesheet__c> timesheets = TimesheetGateway.fetchTimesheetsForContact(c.Id, 'All');
        List<NG_Timesheet_Entry__c> entries = TimesheetEntryGateway.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);
        NG_Timesheet_Entry_Slot__c slot = TimesheetEntrySlotGateway.fetch(entries[0].Default_Slot__r.Id);
        
        slot.In_Date__c = string.valueOf(date.today());
        slot.In_Time__c = '08:00';
        slot.Out_Date__c = string.valueOf(date.today());
        slot.Out_Time__c = '16:00';
        update slot;
        
        tdc.TR_Timesheet_ID = trt.Id;
        List<TimesheetDetailsController.TimesheetDetail> details = tdc.getDetails();
    }
}