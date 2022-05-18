@isTest
private class RC_Test_HomeController 
{
    private static testMethod void test_RC_Home() 
    {
        RC_HomeController objController = new RC_HomeController();
       
        RC_Test_Utility.createUser();
		
        Id contactId = RC_Test_Utility.objUser.ContactId;
        Contact con = new Contact(Id = contactId, Paylocity_Company_ID__c = '37103');
        
        //Update
        Update con;
        
        System.runAs(RC_Test_Utility.objUser)
        {
            RC_HomeController objHome = new RC_HomeController();
            objHome.redirectUnAuthenticatedUser();
        }
    }
}