@isTest
private class RC_ExpenseReportsTest 
{
	private static testMethod void test()  
	{
		User communityPlacedUser  = RC_UtilityClass.returnCommunityContactTypeUser('candidate', 'tew');
        User communityApproverUser  = RC_UtilityClass.returnCommunityContactTypeUser('c&c', 'zxc');        
        
        RC_ExpenseReports objExpenseReport = new RC_ExpenseReports();
        PageReference pg = objExpenseReport.redirectUnAuthenticatedUser();
        
        /* Create test data */
        Account testAcc = new Account(name='Test');  
        insert testAcc; 

        TR1__Job__c objJob = RC_UtilityClass.insertJob();
        
        TR1__Closing_Report__c objCloseRep = new TR1__Closing_Report__c();
        objCloseRep.TR1__Account__c = testAcc.id;
        objCloseRep.TR1__Job_Percentage__c = 20;
        objCloseRep.TR1__Candidate_Percentage__c  = 20;
        objCloseRep.TR1__Marketing_Percentage__c  = 20;
        objCloseRep.TR1__Other_Percentage__c  = 20;
        objCloseRep.TR1__Other2_Percentage__c = 20;
        objCloseRep.TR1__Job__c = RC_UtilityClass.insertJob().id; 
        objCloseRep.TR1__Person_Placed__c = communityPlacedUser.contactId;
        objCloseRep.TR1__Timesheet_Approver__c = communityApproverUser.contactId;
        objCloseRep.Candidate_Type__c = 'Physician';
        insert objCloseRep;
        
        TR1__Expense_Report__c objExp = RC_UtilityClass.returnExpenseReport();
        objExp.TR1__Closing_Report__c = objCloseRep.id; 
        update objExp;
        /* Create test data */
        
        
        System.assertEquals('/Signin',pg.getUrl());
        
        /*TR1__Expense_Report__c objExpRep = RC_UtilityClass.returnExpenseReport();*/
        objExp.TR1__Consultant__c = communityPlacedUser.contactId;
        update objExp;
        
        System.runAs(communityApproverUser)
        {
            objExpenseReport = new RC_ExpenseReports();
            pg = objExpenseReport.redirectUnAuthenticatedUser();
            System.assertEquals(null,pg);
            
            objExp = (TR1__Expense_Report__c)RC_AccessController.query('SELECT id, TR1__Status__c FROM TR1__Expense_Report__c LIMIT 1')[0];
            System.assertEquals('Submitted',objExp.TR1__Status__c);
            
            objExpenseReport.idExp = objExp.id;
            objExpenseReport.approveExp();
            objExp = (TR1__Expense_Report__c)RC_AccessController.query('SELECT id, TR1__Status__c FROM TR1__Expense_Report__c LIMIT 1')[0];  
            System.assertEquals('Approved',objExp.TR1__Status__c);
            
            objExp.TR1__Status__c = 'Submitted';
            RC_AccessController.updateRecord(objExp);
            objExpenseReport.strComment = 'Test'; 
            objExpenseReport.rejectExp(); 
            objExp = (TR1__Expense_Report__c)RC_AccessController.query('SELECT id, TR1__Status__c FROM TR1__Expense_Report__c LIMIT 1')[0]; 
        
            System.assertEquals('Rejected',objExp.TR1__Status__c);  
            
            
        } 
	}

}