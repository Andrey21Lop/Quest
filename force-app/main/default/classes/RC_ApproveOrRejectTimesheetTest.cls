/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class RC_ApproveOrRejectTimesheetTest {

    static testMethod void ApproveOrRejectTimesheetTest() 
    {
        User communityPlacedUser  = RC_UtilityClass.returnCommunityContactTypeUser('candidate', 'dsa');
        User communityApproverUser1  = RC_UtilityClass.returnCommunityContactTypeUser('c&c', 'asd');
        
        TR1__Job__c objJob = RC_UtilityClass.insertJob();
        
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
        insert objCloseRep;
        
        TR1__Timesheet__c  objTimesheet1 = RC_UtilityClass.insertTimeSheet(objJob.Id);
        
        User communityApproverUser = RC_UtilityClass.returnCommunityUser();
        Id approverId = [Select ContactId from User where Id =: communityApproverUser.Id limit 1].ContactId;
        Id consultantId = RC_UtilityClass.createAndGetContactId('Consultant');
        objTimesheet1.TR1__Closing_Report__c = objCloseRep.Id;
        objTimesheet1.TR1__Approver__c = communityApproverUser1.contactId;
        objTimesheet1.TR1__Consultant__c = communityPlacedUser.contactId;
        update objTimesheet1;
        
        System.runAs(communityApproverUser1)
        {
            
            Test.startTest();
            
            Apexpages.currentPage().getParameters().put('id', objTimesheet1.Id);
            Apexpages.currentPage().getParameters().put('action', 'Approved');
            
            RC_ApproveOrRejectTimesheet objApproveOrReject = new RC_ApproveOrRejectTimesheet();
            objTimesheet1.TR1__Status__c = 'Approved';
            RC_AccessController.updateRecord(objTimesheet1);
            objApproveOrReject.approveTimesheetFromAction();
            system.assertEquals('This Timesheet is already Approved', objApproveOrReject.strMessage);
            
            objTimesheet1.TR1__Status__c = 'Unsubmitted';
            RC_AccessController.updateRecord(objTimesheet1);
            objApproveOrReject.approveTimesheetFromAction();
            system.assertEquals('This Timesheet has not been submitted for Approval', objApproveOrReject.strMessage);
            
            objTimesheet1.TR1__Status__c = 'Submitted';
            RC_AccessController.updateRecord(objTimesheet1);
            objApproveOrReject.approveTimesheetFromAction();
            
            objTimesheet1.TR1__Status__c = 'Rejected';
            objTimesheet1.TR1__Approvers_Notes__c = 'Test';
            RC_AccessController.updateRecord(objTimesheet1);
            objApproveOrReject.approveTimesheetFromAction(); 

           
            objApproveOrReject.UpdateStatusToApproved();
            system.assertEquals('Approved', ((TR1__Timesheet__c)RC_AccessController.query('Select TR1__Status__c from TR1__Timesheet__c where Id = \'' + objTimesheet1.id + '\'')[0]).TR1__Status__c);
            String consultantName = ((TR1__Timesheet__c)RC_AccessController.query('Select TR1__Consultant__r.Name From TR1__Timesheet__c Limit 1')[0]).TR1__Consultant__r.Name;
            system.assertEquals('Timesheet for ' + consultantName + ' has been approved', objApproveOrReject.strMessage);
          
            objApproveOrReject.updateNotes();
            system.assertEquals('Notes successfully added', objApproveOrReject.strMessage);
            
                    
            Apexpages.currentPage().getParameters().put('id', '');
            Apexpages.currentPage().getParameters().put('action', '');
            
            RC_ApproveOrRejectTimesheet objApproveOrRejectTest = new RC_ApproveOrRejectTimesheet();
            objApproveOrRejectTest.approveTimesheetFromAction();
            
            Apexpages.currentPage().getParameters().put('id', objTimesheet1.Id);
            Apexpages.currentPage().getParameters().put('action', 'Rejected');
            
          //  RC_ApproveOrRejectTimesheet objApproveOrRejectTest1 = new RC_ApproveOrRejectTimesheet();
            objTimesheet1.TR1__Approvers_Notes__c = 'Test';
            RC_AccessController.updateRecord(objTimesheet1);
            objApproveOrRejectTest.approveTimesheetFromAction();
            objApproveOrRejectTest.updateNotes();
            system.assertEquals('Timesheet for ' + consultantName + ' has been rejected', objApproveOrRejectTest.strMessage);         
            Test.stopTest();            
        }
    }
}