public without sharing class TimesheetApprovalController {
    private final NG_Timesheet__c timesheet;
    private final List<NG_Timesheet_Entry__c> entryList;
    public  String message {get; set;}
    public Id timesheetIdtemp;
    @testVisible
    public static Id timesheetId {
        get {
            if(timesheetId == null) {
                timesheetId = ApexPages.currentPage().getParameters().get('id');
            }
            return timesheetId;
        } set;
    }
    
    public TimesheetApprovalController() {
        message = '';
        timesheet = [SELECT Id, Employee_Name__c, Status__c, 
                            Rejection_Reason__c, Source_Object_ID__c,
                            Work_Location_Name__c, NG_UUID__c ,
                            QG_TS_Portal_Approver__c, QG_Portal_TS_Number_Text__c,
                     	    QG_Portal_TS_Number__c
                     FROM NG_Timesheet__c
                     WHERE Source_Object_ID__c = :timesheetId];
        
                     /*
        entryList = [SELECT Id, Name, Total_Hours__c, Total_Callback_Hours__c,
                            Default_Slot__r.Custom_On_Call_Beeper__c,
                            Default_Slot__r.In_Time__c, Default_Slot__r.Out_Time__c,
                            Default_Slot__r.Is_Multi_Day__c, Default_Slot__r.In_Date__c,
                            Default_Slot__r.Out_Date__c, Default_Slot__r.Unpaid_Break_Time__c, 
                            Default_Slot__r.Note__c
                     FROM NG_Timesheet_Entry__c
                     WHERE Timesheet__c = :timesheet.Id
                     ORDER BY Date__c];
                     */
        timesheetIdtemp = timesheet.Id;
        timesheet.Id = null;
    }

    public NG_Timesheet__c getTimesheet() {
        return timesheet;
    }

    public List<TimesheetDetailsController.TimesheetDetail> getEntryList() {
        TimesheetDetailsController tdc = new TimesheetDetailsController();
        tdc.TR_Timesheet_ID = timesheet.Source_Object_ID__c;
        List<TimesheetDetailsController.TimesheetDetail> details = tdc.getDetails();
        return details;
    }

    public Pagereference save() {
        system.debug('bw: TimesheetApprovalController.save -> timesheet = ' + timesheet);
        message='';
		if(timesheet.QG_TS_Portal_Approver__c == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' E-Signature is required.'));
        }
        else if(timesheet.Status__c == 'Rejected' && timesheet.Rejection_Reason__c == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Rejection Reason is required.'));
        }
        else {
            timesheet.id = timesheetIdtemp;
            update timesheet;
            TR_Timesheet_Gateway.synchronize(timesheet);
            message = 'Thank you, your action has been recorded.';
        }

        return null;
    }
}