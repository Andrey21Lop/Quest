global class NG_TimesheetApprovalEmailBatch 
	implements Database.Batchable<sObject> 
{
    global final String query;
    
    global NG_TimesheetApprovalEmailBatch(String q) {
        this.query = q;
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<TR1__Timesheet__c, String> emails = new Map<TR1__Timesheet__c, String>();

        NGCSH__c config = NGCSH__c.getOrgDefaults();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: config.TS_Sender_Email__c];
        String bccs = config.TS_BCC_Addresses__c;
        
        TR1__Timesheet__c timesheet;
        List<TR1__Timesheet__c> timesheets = new List<TR1__Timesheet__c>();
        
        for(sobject o : scope) {
            timesheet = (TR1__Timesheet__c) o;
            if(timesheet.TR1__Timesheet_Approver_Email__c != null ) {
            	emails.put(timesheet, buildApprovalEmail(timesheet, config));  
                timesheets.add(timesheet);
            }
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(TR1__Timesheet__c key : emails.keySet()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if(bccs != null) {
            	List<String> bccList = bccs.split(',');
            	mail.setBccAddresses(bccList);
        	}
            
        	mail.setToAddresses(new List<String> { key.TR1__Timesheet_Approver_Email__c });
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            
            mail.setSubject('Timesheet Approval Request: ' + key.NG_Consultant_Name__c);
            
            string body = emails.get(key);
            body = body.replace('null' , '') ;
            mail.setHtmlBody(body);
            
            mails.add(mail);
        }
        
        Messaging.sendEmail(mails);
        
        for(TR1__Timesheet__c t : timesheets) {
            t.NG_Approval_Reminder_Sent__c = true;
        }
        
        update timesheets;
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];    
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Timesheet Approval Email Batch program ' + a.Status);
            mail.setPlainTextBody
            ('The batch Apex job'+'('+ BC.getJobId()+')processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception ex){}        
    }
    
    public String buildApprovalEmail(TR1__Timesheet__c trTimesheet, NGCSH__c config) {
        TimesheetDetailsController tdc = new TimesheetDetailsController();
        tdc.TR_Timesheet_ID = trTimesheet.Id;
        List<TimesheetDetailsController.TimesheetDetail> details = tdc.getDetails();

        string body = '<p>' + trTimesheet.TR1__Approver_First_Name__c + ',</p>' +
                    '<p>' + trTimesheet.NG_Consultant_Name__c + ' has submitted a timesheet for week ending ' + trTimesheet.TR1__Week_Ending__c.format() + ' at ' + (trTimesheet.Work_Shift_Location__c != null ? trTimesheet.Work_Shift_Location__r.Name : trTimesheet.TR1__Client__r.Name) + '. ' +
                    'Please follow the steps below to approve or reject the timesheet.</p>' +
                    '<p><b>Step 1</b>: Copy this unique token code:<b>' + trTimesheet.NG_UUID__c + '</b><br/>' +
                    '<b>Step 2</b>: <a href="' + config.TS_Approval_Domain_Url__c + '/ts/NG_Token?id=' + trTimesheet.Id +'">Click Here to Access the Timesheet</a><br/>' +   
                    '<b>Step 3</b>: Enter the unique token code<br/>' +
                    '<b>Step 4</b>: If all hours are approved as displayed, click save.  *<i>If any time is not approved, change the status to Rejected, enter rejection notes and click save.</i></p>' +
                    
                    '<p>Please note that we can only process payroll for hours approved ' +
                    'before Monday at 6 pm EST.  If you encounter any system issues please ' +
                    'contact us immediately by emailing timesheets@qgsearch.com</p>' +

                    '<p><b>Contractor:</b>  ' + trTimesheet.NG_Consultant_Name__c + '<br/>' +
                    '<b>Worksite Location:</b> ' + (trTimesheet.Work_Shift_Location__c != null ? trTimesheet.Work_Shift_Location__r.Name : trTimesheet.TR1__Client__r.Name) + '</p>';
        
        if(trTimesheet.NG_OT_Threshold_Type__c == 'Weekly') {
            body += '<table style="border:solid #CCCCCC; border-width:2" border="2">' +
                        '<tr>' +
                            '<th>Start Date Time</th>' +
                            '<th>End Date Time</th>' +
                            '<th>Unpaid Break Hours</th>' +
                            '<th>Regular Hours</th>' +
                            '<th>Overtime Hours</th>' +
                            /*
                            '<th>On Call</th>' +
                            '<th>Total Callback Hours</th>' +
                            */
                            '<th>Provider Comments/Mileage</th>' +
                        '</tr>';

            for(TimesheetDetailsController.TimesheetDetail detail : details) {
                body += '<tr>' +
                        '<td>' + (detail.inDate + ' ' + detail.inTime) + '</td>' +
                        '<td>' + (detail.outDate + ' ' + detail.outTime) + '</td>' +
                        '<td align="right">' + detail.unpaidBreakHours + '</td>' +
                        '<td align="right">' + detail.totalRegHours + '</td>' +
                        '<td align="right">' + detail.totalOTHours + '</td>' +
                        /*
                        '<td align="center">' + detail.onCall + '</td>' +
                        '<td align="right">' + detail.totalCBHours + '</td>' +
                        */
                        '<td align="left">' + detail.note + '</td>' +
                        '</tr>';
            }

            body += '</table><br/>';

            body += '<table style="border:solid #CCCCCC; border-width:2" border="2">' +
                        '<tr>' +
                            '<th>Total Weekly Regular Hours</th>' +
                            '<th>Total Weekly Overtime Hours</th>' +  
                            '<th>Total Weekly Hours</th>' +
                        '</tr>';       

            body += '<tr>' +
                    '<td align="right">' + trTimesheet.NG_Total_Regular_Shift_Hours__c + '</td>' +
                    '<td align="right">' + trTimesheet.NG_Total_Overtime_Shift_Hours__c + '</td>' +
                    '<td align="right">' + trTimesheet.NG_Total_Weekly_Hours__c + '</td>' +
                    '</tr>' +
                    '</table>';
        }
        else {
            body += '<table style="border:solid #CCCCCC; border-width:2" border="2">' +
                        '<tr>' +
                            '<th>Start Date Time</th>' +
                            '<th>End Date Time</th>' +
                            '<th>Unpaid Break Hours</th>' +
                            '<th>Total Regular Hours</th>' +
                            '<th>Total Overtime Hours</th>' +
                            /*
                            '<th>On Call</th>' +
                            '<th>Total Callback Hours</th>' +
                            */
                            '<th>Provider Comments/Mileage</th>' +
                        '</tr>';

            for(TimesheetDetailsController.TimesheetDetail detail : details) {
                body += '<tr>' +
                        '<td>' + (detail.inDate + ' ' + detail.inTime) + '</td>' +
                        '<td>' + (detail.outDate + ' ' + detail.outTime) + '</td>' +
                        '<td align="right">' + detail.unpaidBreakHours + '</td>' +
                        '<td align="right">' + detail.totalRegHours + '</td>' +
                        '<td align="right">' + detail.totalOTHours + '</td>' +
                        /*
                        '<td align="center">' + detail.onCall + '</td>' +
                        '<td align="right">' + detail.totalCBHours + '</td>' +
                        */
                        '<td align="left">' + detail.note + '</td>' +
                        '</tr>';
            }

            body += '</table>';
        }

        body += '<br/><p>Thank you,' +
                '<br/>Quest Group Accounting Department<br/>' +
                'timesheets@qgsearch.com</p>';


     
        return body;
    }

}