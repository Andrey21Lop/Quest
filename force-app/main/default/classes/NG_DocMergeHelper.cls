public class NG_DocMergeHelper {
    
    public static Map<String,String> getRelatedDocIds(String parentId) {        
        TR1_INV__Invoice__c invoice = [Select NG_Invoice_Number__c,TR1_INV__Closing_Report__c from TR1_INV__Invoice__c where Id =: parentId];
        Set<Id> invoiceIds = new Set<ID>{invoice.id};
            
        Map<Id, TR1_INV__Invoice_Line_Item__c> invLineItemMap = new Map<Id, TR1_INV__Invoice_Line_Item__c>([Select Id from TR1_INV__Invoice_Line_Item__c where TR1_INV__Invoice__c = :parentId ]);
        System.debug('invLineItemMap :  ' + invLineItemMap);
        
        Map<Id,TR1__Expense_Report__c> expenseReport =  new Map<Id,TR1__Expense_Report__c>([Select Id from TR1__Expense_Report__c where TR1_INV__InvoiceLineItem__c in : invLineItemMap.keySet()]);
        System.debug('expenseReport :  ' + expenseReport);
        
        Map<Id,TR1__Timesheet__c> timeSheet = new Map<Id,TR1__Timesheet__c>([Select Id,TR1__Week_Ending__c from TR1__Timesheet__c where TR1_INV__InvoiceLineItem__c in : invLineItemMap.keySet() order by TR1__Week_Ending__c asc]);
        System.debug('timeSheet :  ' + timeSheet);
                
        Id crId = invoice.TR1_INV__Closing_Report__c;
        Map<Id,Confirmation_Letters_ACLs__c> acls = new Map<Id,Confirmation_Letters_ACLs__c>([Select Id, CreatedDate, ACL_Start_Date__c, ACL_End_Date__c from Confirmation_Letters_ACLs__c where Closing_Report__c =: crId and ACL_Type__c = 'Client' order by createdDate desc]);
        Map<Id,Confirmation_Letters_ACLs__c> selectedACLs =  selectACLs(acls,timeSheet);
        System.debug('acls :  ' + acls);
        
        Map<String,String> docMap = new Map<String,String>();
        docMap.putAll(getAttachmentDetails(invoiceIds, 'Inv'));//Get All Invoice Attachment Details
        docMap.putAll(getFileDetails(invoiceIds, 'Inv'));//Get All Invoice file Details
        docMap.putAll(getFileDetails(selectedACLs.keySet(), 'ACL'));//Get All Selectec ACL file Details
        docMap.putAll(getFileDetails(expenseReport.keySet(), 'Exp'));//Get All Expense file Details
        docMap.putAll(getFileDetails(timeSheet.keySet(), 'TS'));//Get All TimeSheet file Details
        System.debug('docMap :  ' + docMap);
        return docMap;
    }
    
    // Implementation restriction: ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
    private static Map<String,String> getFileDetails(Set<Id> linkedEntityIds,String objPrefix){
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        ContentDocumentLink cdlink;
        List<ContentDocumentLink> docsForID;
        for(Id leId : linkedEntityIds){
            docsForID = [SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.Title, 
                                                ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =: leId];
            if(docsForID != null && !docsForID.isEmpty()){
                cdls.addAll(docsForID);
            }
        }
        
        Map<String,String> docDetails = new Map<String,String>();
        String docName = '';
        for(ContentDocumentLink cdl : cdls){
            docName = objPrefix + '_' + cdl.ContentDocument.Title;
            docDetails.put(cdl.ContentDocumentId, docName);
        }
        System.debug('FileDetails :  ' + docDetails);
    	return docDetails;
    }
    
    private static Map<String,String> getAttachmentDetails(Set<Id> parentIds,String objPrefix){
        List<Attachment> attchments = [SELECT Id, Name,ContentType, CreatedDate FROM Attachment where ParentId in : parentIds];
        Map<String,String> docDetails = new Map<String,String>();
        String docName = '';
        for(Attachment  attch : attchments){
            docName = objPrefix + '_' + attch.Name;
            docDetails.put(attch.Id, docName);
        }
        System.debug('AttachmentDetails :  ' + docDetails);
    	return docDetails;
    }
    
    private static Map<Id,Confirmation_Letters_ACLs__c> selectACLs(Map<Id,Confirmation_Letters_ACLs__c> aclsMap,Map<Id,TR1__Timesheet__c> timeSheetMap){
        Map<Id,Confirmation_Letters_ACLs__c> selectedACLs = new Map<Id,Confirmation_Letters_ACLs__c>();
        if(timeSheetMap != null && !timeSheetMap.isEmpty()){
            Integer noOfTimesheets = timeSheetMap.size();
            List<TR1__Timesheet__c> timesheets = timeSheetMap.values();
            Date minWeekEndingDate = timesheets.get(0).TR1__Week_Ending__c;
            Date maxWeekEndingDate = timesheets.get(noOfTimesheets -1).TR1__Week_Ending__c;
            Confirmation_Letters_ACLs__c acl;
            for(Id aclId : aclsMap.keyset() ){
                acl = aclsMap.get(aclId);
                Date startDate = acl.ACL_Start_Date__c;
                Date endDate = acl.ACL_End_Date__c;
                //Select ACL record's attachments  if the timesheet dates fall within the range entered i.e. start date and End Date on the ACL.      
                if(startDate != null && endDate != null) {
                    if(minWeekEndingDate >= startDate && maxWeekEndingDate <= endDate){
                        selectedACLs.put(aclId,acl);
                    }
                }
            }
        }        
        System.debug('selectedACLs : ' + selectedACLs);
        return selectedACLs;
    }
    
    

}