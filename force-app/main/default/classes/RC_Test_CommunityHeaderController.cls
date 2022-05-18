@isTest
private class RC_Test_CommunityHeaderController 
{
    private static testMethod void test()
    {
        
        RC_Test_Utility.createUser();
        
        Id contactId = RC_Test_Utility.objUser.ContactId;
        Contact con = new Contact(Id = contactId, Paylocity_Company_ID__c = '37103');
        
        //Update
        Update con;
        
        System.runAs(RC_Test_Utility.objUser){
            PageReference pageRef = Page.MyAccount_v1;
            Test.setCurrentPage(pageRef);
            RC_CommunityHeaderController objController = new RC_CommunityHeaderController();
            system.assertEquals(con.Id, RC_Test_Utility.objContact.Id);
            
        }
        
    }

}