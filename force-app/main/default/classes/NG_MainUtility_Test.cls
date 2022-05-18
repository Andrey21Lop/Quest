@isTest
public class NG_MainUtility_Test 
{
    @isTest static void test_incrementNGInvoiceNumber() 
	{
		NG_TR_Settings__c CS = new NG_TR_Settings__c();
		CS.NG_Invoice_Number__c = 2;
		insert CS;

		NG_MainUtility.incrementNGInvoiceNumber();
		NG_TR_Settings__c ncs = NG_TR_Settings__c.getOrgDefaults();
		System.assert(ncs.NG_Invoice_Number__c == 3);
	}
	
	@isTest static void test_CoverageForMainUtility()
	{
    	NGCS__C ngcs = new NGCS__C(Name='Main',NG_Debug_Flag__c=TRUE); insert ngcs;
		NG_MainUtility.println(true,'Simple Test');		
	}
}