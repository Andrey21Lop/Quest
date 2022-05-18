public class NG_TrgHndlr_Invoice
{

  private boolean m_isExecuting = false;
  private integer BatchSize = 0;

  public NG_TrgHndlr_Invoice(boolean isExecuting, integer size)
  {
    m_isExecuting = isExecuting;
    BatchSize = size;
  }

  public void OnBeforeInsert(List<TR1_INV__Invoice__c> newRecords) 
  {
  	//$Setup.NG_TR_Settings__c.NG_Invoice_Prefix__c + TEXT($Setup.NG_TR_Settings__c.NG_Invoice_Number__c)
  	NG_TR_Settings__c ngcs = [SELECT Id, Name, NG_Invoice_Prefix__c, NG_Invoice_Number__c FROM NG_TR_Settings__c WHERE SetupOwnerId =: UserInfo.getOrganizationId() FOR UPDATE ];
  	for(TR1_INV__Invoice__c inv : newRecords)
  	{
  		inv.NG_Invoice_Number__c = ngcs.NG_Invoice_Prefix__c + ngcs.NG_Invoice_Number__c;
  		inv.TR1_INV__Email_Bcc__c = 'accounting@qgsearch.com';
  		ngcs.NG_Invoice_Number__c++;
  	}
  	update ngcs;
  }
    
  public void onAfterUpdate(List <TR1_INV__Invoice__c> newRecords)
  {
      // After the invoices are updated just delete the corresponding GP_Records related to the invoice. GP Records are then created for that invoice 
      // depending on conditions specified in Batch Apex
      // Select all GP records in List
    NG_TR_Settings__c ngcs = [SELECT Id, NG_DeleteGPEXPRecordOnInvoiceUpdate__c FROM NG_TR_Settings__c WHERE SetupOwnerId =: UserInfo.getOrganizationId() FOR UPDATE ];
    
    If  (!ngcs.NG_DeleteGPEXPRecordOnInvoiceUpdate__c) return;
      
    List<Id> updatedInvoiceIds = new List<Id>();
          
    for(TR1_INV__Invoice__c inv : newRecords)
  	{
  		updatedInvoiceIds.Add(inv.Id);
  	}
      
      
	List<QG_GP_Exp__c> qgGPExportListToDelete = [Select Id,Invoice__c from QG_GP_Exp__c Where Invoice__c IN : updatedInvoiceIds Order By Invoice__c];    
      

      if (qgGPExportListToDelete != null)
      {
          System.debug('NGDebug TriggerIsAfter, TriggerIsUpdate TR1_INV__Invoice__c Deleted ='+qgGPExportListToDelete.size() + 'Records'); 
          delete qgGPExportListToDelete;
      }
  }


/*  
  public Map<Id, TR1__TimeType__c> getTimeTypes(List<TR1__Rate__c> newRecords)
  {
  	Map<Id, TR1__TimeType__c> m_tt = new Map<Id, TR1__TimeType__c>();
  	for(TR1__Rate__c r : newRecords) m_tt.put(r.TR1__TimeType__c, null);
  	m_tt = new Map<Id, TR1__TimeType__c>([SELECT Id, Name FROM TR1__TimeType__c Where Id in: m_tt.keySet()]);
  	System.debug(m_tt);
	return m_tt;  	
  }

  public void OnBeforeInsert(List<TR1__Invoice__c> newRecords)
  {
  	Map<Id, TR1__TimeType__c> m_tt = getTimeTypes(newRecords);
  	for(TR1__Rate__c r : newRecords) 
  		if(r.TR1__TimeType__c != null) 
  		{	r.name = m_tt.get(r.TR1__TimeType__c).Name; System.debug('AVDebug: '+ r.Name + '-' + r.TR1__TimeType__c); }
  		else 
  			r.addError('TimeType is Required');
  }
  
  public void OnBeforeUpdate(List<TR1__Rate__c> oldRecords, List<TR1__Rate__c> updatedRecords, Map<ID, TR1__Rate__c> recordMap) 
  {
  	TR1__Rate__c newr;
  	Map<Id, TR1__TimeType__c> m_tt = getTimeTypes(updatedRecords);
	for(TR1__Rate__c oldr : oldRecords) 
	{
		newr = recordMap.get(oldr.Id);
		if(newr.TR1__TimeType__c != null)
		{
			if(newr.TR1__TimeType__c == oldr.TR1__TimeType__c) continue;
			newr.name = m_tt.get(newr.TR1__TimeType__c).Name;
		}
		else 
			newr.addError('TimeType is Required');
  	}
  }
*/  
}