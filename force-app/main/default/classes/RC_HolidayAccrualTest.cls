@isTest
private class RC_HolidayAccrualTest {

    private static testMethod void AccrualProcess() {
        
        TR1__Job__c objJob = RC_UtilityClass.insertJob();
       
        User communityPlacedUser  = RC_UtilityClass.returnCommunityContactTypeUser('candidate', 'mnb');
        User communityApproverUser1  = RC_UtilityClass.returnCommunityContactTypeUser('c&c', 'vop');
        
        Account testAcc = new Account(name='Test');  
        insert testAcc; 
        
        TR1__Closing_Report__c objCloseRep = new TR1__Closing_Report__c();
        objCloseRep.TR1__Account__c = testAcc.id;
        objCloseRep.TR1__Job_Percentage__c = 20;
        objCloseRep.TR1__Candidate_Percentage__c  = 20;
        objCloseRep.TR1__Marketing_Percentage__c  = 20;
        objCloseRep.TR1__Other_Percentage__c  = 20;
        objCloseRep.TR1__Other2_Percentage__c = 20;
        objCloseRep.TR1__Job__c = RC_UtilityClass.insertJob().id; 
        objCloseRep.TR1__Person_Placed__c = communityPlacedUser.contactId;
        objCloseRep.TR1__Timesheet_Approver__c = communityApproverUser1.contactId;
        objCloseRep.Candidate_Type__c = 'Physician';
        Test.startTest();
        insert objCloseRep;
        Test.stopTest();
        
        TR1__Timesheet__c  objTimesheet = RC_UtilityClass.insertTimeSheet(objJob.Id);
        Contact objContact = new Contact(Firstname = 'Test', Lastname = 'Conatct1');
        insert objContact;
        objTimesheet.TR1__Consultant__c = objContact.Id;
        objTimesheet.TR1__Closing_Report__c = objCloseRep.Id;
        update objTimesheet;
        
        TR1__Timesheet_Detail__c objTimesheetDetail = RC_UtilityClass.insertTimeSheetDetail(objTimesheet.Id);
        objTimesheetDetail.TR1__Vacation_Hours__c = 4;
        objTimesheetDetail.TR1__Regular_Hours__c = 4;
        update objTimesheetDetail;
        
        objTimesheet.TR1__Status__c = 'Approved';
        update objTimesheet;
        
        objTimesheet.TR1__Status__c = 'Unsubmitted';
        update objTimesheet;
        
        objTimesheet.TR1__Status__c = 'Approved';
        update objTimesheet;
        
        delete objTimesheetDetail;
        

    }

}