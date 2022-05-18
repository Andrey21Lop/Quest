public class NG_MainUtility 
{
    public void NG_MainUtility() {}
    
    @InvocableMethod(label='Increment NGInvoiceNumber' description='Increments the value of this custom setting by 1')
    public static void incrementNGInvoiceNumber()
    {
    	NG_TR_Settings__c cs = NG_TR_Settings__c.getOrgDefaults();
    	cs.NG_Invoice_Number__c += 1;
    	update cs;
    }
    
    public static void println(Boolean ngDebugFlag, String lineToPrint)
    {
    	if(ngDebugFlag) System.debug('NGDebug: '+lineToPrint);
    }
}