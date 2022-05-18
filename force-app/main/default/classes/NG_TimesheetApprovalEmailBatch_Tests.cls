@isTest
public class NG_TimesheetApprovalEmailBatch_Tests {
	@isTest
    public static void testBatcher() {
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        MockFactory.createTimesheet(t.Id);
        t.TR1__Status__c = 'Submitted';
        update t;
        
        NG_ScheduleTimesheetApprovalEmail schd = new NG_ScheduleTimesheetApprovalEmail();
        schd.execute(null);
        
        String query = 'SELECT TR1__Status__c, ' +
            				  'TR1__Approver__c, ' +
            				  'TR1__Approver_First_Name__c, ' +
            				  'TR1__Timesheet_Approver_Email__c, ' +
            			      'TR1__Approvers_Notes__c, ' +
           					  'TR1__Client__c, ' +
                              'TR1__Client__r.Name, ' +
            				  'TR1__Consultant_Email__c, ' +
            				  'TR1__Consultant_Name__c, ' +
            				  'NG_Consultant_Name__c, ' +
            				  'Work_Shift_Location__r.Name, ' +
            				  'TR1__Week_Ending__c, ' +
            				  'NG_Total_Weekly_Hours__c, ' +
            				  'NG_Total_Overtime_Shift_Hours__c, ' +
            				  'NG_Total_Regular_Shift_Hours__c, ' +
            				  'NG_UUID__c, ' +
            				  'NG_OT_Threshold_Type__c ' +
            			'FROM TR1__Timesheet__c ' +
            			'WHERE NG_Approval_Reminder_Sent__c = false ' +
							'AND NG_Portal_Submitted__c = true ' + 
            				'AND TR1__Status__c = \'Submitted\'';
        
        NG_TimesheetApprovalEmailBatch batcher = new NG_TimesheetApprovalEmailBatch(query);
        Test.startTest();
        batcher.start(null);
        List<sObject> scope = database.query(query);
		batcher.execute(null, scope);
        
        t.NG_OT_Threshold_Type__c = 'Weekly';
        update t;
        
        scope = database.query(query);
        batcher.execute(null, scope);
        Test.stopTest();
        
    }
}