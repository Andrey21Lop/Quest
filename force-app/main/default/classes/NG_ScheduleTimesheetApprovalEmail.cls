global class NG_ScheduleTimesheetApprovalEmail 
	implements Schedulable 
{
	global void execute(SchedulableContext sc) {
        String query = 'SELECT TR1__Status__c, ' +
                              'TR1__Approver__c, ' +
                              'TR1__Approver_First_Name__c, ' +
                              'TR1__Timesheet_Approver_Email__c, ' +
                              'TR1__Approvers_Notes__c, ' +
                              'TR1__Consultant_Email__c, ' +
                              'TR1__Consultant_Name__c, ' +
                              'TR1__Client__c, ' +
                              'TR1__Client__r.Name, ' +
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
        
        ID batchprocessid = Database.executeBatch(new NG_TimesheetApprovalEmailBatch(query),3);
    }
}