@isTest
private class NG_TrgHandler_Invoice_Test 
{

	@testSetup 
    static void setupData() 
    {
    	Integer ctr = 0;
    	Integer totalCR = 3;
    	
    	NG_TR_Settings__c ngcs = new NG_TR_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Name='Main',NG_Invoice_Prefix__c='INV', NG_Invoice_Number__c=40); insert ngcs;
    	
    	TR1__TimeType__c tt1 = new TR1__TimeType__c(Name = 'Regular', TR1__EntryType__c = 'Hours & Minutes', TR1__ShowAs__c = 'Hours'); insert tt1;
    	TR1__TimeType__c tt2 = new TR1__TimeType__c(Name = 'Overtime', TR1__EntryType__c = 'Hours & Minutes', TR1__ShowAs__c = 'Hours'); insert tt2;
    	
    	Account acc = new Account(Name='Calif Account Test'); insert acc;
        Contact con = new Contact(LastName='Approv Calif Contact Test',Email='abac@abconsulting.com',AccountId=acc.Id);insert con;

    }
    
    testmethod static void unitTest1()
    {
    	Account acc = [SELECT Id FROM Account WHERE Name='Calif Account Test' LIMIT 1];
    	List<TR1_INV__Invoice__c> invoices = new List<TR1_INV__Invoice__c>();
    	TR1_INV__Invoice__c inv;
    	inv = new TR1_INV__Invoice__c(TR1_INV__Account__c=acc.Id);invoices.add(inv);
    	inv = new TR1_INV__Invoice__c(TR1_INV__Account__c=acc.Id);invoices.add(inv);
    	inv = new TR1_INV__Invoice__c(TR1_INV__Account__c=acc.Id);invoices.add(inv);
    	inv = new TR1_INV__Invoice__c(TR1_INV__Account__c=acc.Id);invoices.add(inv);
    	inv = new TR1_INV__Invoice__c(TR1_INV__Account__c=acc.Id);invoices.add(inv);
    	insert invoices;
    	
    	NG_TR_Settings__c ngcs = NG_TR_Settings__c.getOrgDefaults();
    	System.assertEquals(45, ngcs.NG_Invoice_Number__c);
    }
}