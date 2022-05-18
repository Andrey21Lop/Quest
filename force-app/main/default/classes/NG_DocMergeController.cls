global class NG_DocMergeController {
    @AuraEnabled
    public static Map<String,String> getDocumentsToAttach(String parentId) {
        System.debug('getDocumentsToAttach - parentId :  ' + parentId);
        Map<String,String> docMap = NG_DocMergeHelper.getRelatedDocIds(parentId);
        return docMap;
    }
    
    @AuraEnabled
    public static List<String> getSelctedDocIds(String parentId) {
        TR1_INV__Invoice__c invoice = [select NG_DocumentsTo_be_Merged__c from TR1_INV__Invoice__c where id =: parentId limit  1];
        List<String> docIds = (invoice.NG_DocumentsTo_be_Merged__c).split(',');
        return docIds;
    }
    
    @AuraEnabled
    public static void saveDocIds(String parentId , List<Id> lstOfDocIds) {
		TR1_INV__Invoice__c inv = new TR1_INV__Invoice__c();
        inv.id = parentId;
        inv.NG_DocumentsTo_be_Merged__c = String.join(lstOfDocIds,',');
        update inv;
    }
}