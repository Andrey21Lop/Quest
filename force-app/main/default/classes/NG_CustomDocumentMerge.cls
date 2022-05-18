/* This sample shows how to use the Loop.DocumentService class from the Document Queue. */

global class NG_CustomDocumentMerge {
     TR1_INV__Invoice__c inv;
	static String apiStatus;    
    static String apiError;
    public NG_CustomDocumentMerge(){}

    public NG_CustomDocumentMerge(ApexPages.StandardController stdController){        
        this.inv = (TR1_INV__Invoice__c)stdController.getRecord();
    }
    public  PageReference MergeFiles1() {
        //this.inv.NG_PDF_Merge_Status__c = '';
        //update this.inv;
        
        MergeFiles(this.inv.id);
        
        return new PageReference('/' + this.inv.id);
    }
    
    public  Id MergeFiles(Id parentRecordId) {
        System.debug('parentRecordId : ' + parentRecordId);
        TR1_INV__Invoice__c invoice = [select  NG_DocumentsTo_be_Merged__c,SA_InvoicePDF_Name__c from TR1_INV__Invoice__c where id =: parentRecordId limit  1];
        string mergedFilename = invoice.SA_InvoicePDF_Name__c + '.pdf';// set the name of the combined file
        boolean trackActivity = false; // set whether or not to create a task for tracking status (completion/error)
        string mergeType = 'pdf'; // specify the type of merge: pdf, zip, byType (Word+Word, Excel+Excel, PPT+PPT, PDF+PDF) - if not specified, the default is pdf
        Id parentId = parentRecordId; // optional - the Id of the Salesforce record to attach the merged file to
        Id workspaceId; // optional - the Content Library Id for where to store the merged document
        Id contentId; // optional - specifies a Content Document to upload a new version of (prefix 069)
        boolean deleteOriginal; // optional - will delete the original documents
        
        List<Id> docIds;
        if(String.isNotBlank(invoice.NG_DocumentsTo_be_Merged__c)) {
            docIds = (invoice.NG_DocumentsTo_be_Merged__c).split(',');
        }
       ContentVersion contentVersion = new ContentVersion(
            Title =  invoice.SA_InvoicePDF_Name__c,
            PathOnClient = mergedFilename,
            VersionData = Blob.valueOf('Initial doc'),
            IsMajorVersion = true          
        );
    	    insert contentVersion;
        ContentVersion document = [SELECT Id, ContentDocumentId FROM ContentVersion where id =: contentVersion.Id limit 1];
        NGCS__c cs = NGCS__c.getInstance('Main');
        Map<string, string> params = new Map<string, string> {            
            'mergeType' => mergeType,
            'trackActivity' => string.valueOf(trackActivity),
            'outputName' => mergedFilename,
            'workspaceId' => cs.Invoice_Content_Library__c,
            'contentId'=> document.ContentDocumentId //,'apexCallback' => 'NG_DocMergeCallback.docMergeCallback'            
        };
            createContentDocumentLink(parentRecordId, document.ContentDocumentId );
        Id taskId;
        if(docIds != null && !docIds.isEmpty()){
            taskId = Loop.DocumentService.convertAndMerge(docIds, parentId, mergedFilename, params);
        }
        
        if (taskId != null)
            return taskId;
        return parentId;
    }
    
    static void createContentDocumentLink(String recordId,string documentID){
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = recordId;
        cdl.ContentDocumentId = documentID;
        cdl.shareType = 'I';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }    
    /*
    public  static void sendMergeResponse(ConvertAndMergeResponseData responseDataObj) {
        if(responseDataObj != null){
            apiStatus = responseDataObj.status;
            system.debug('sendMergeResponse apiStatus : ' + apiStatus);
            Error apiErrorObj = responseDataObj.Error;
            if(String.isNotBlank(apiStatus) && apiStatus.equalsIgnoreCase('Success')){
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Document Merged and uploade to File/Attachment Related List'));
            }
            else {
                if(apiErrorObj != null){
                    apiError =apiErrorObj.message;
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed to merge docuements \n ' + apiError));
                    
                }
            }
        }
        
    }
   webservice static void docMergeCallback(string responseData)
    {
        // Deserialize the response data as an ConvertAndMergeResponseData instance.
        System.debug('## ResponseData : ' + responseData);
        ConvertAndMergeResponseData responseDataObj = (ConvertAndMergeResponseData)JSON.deserialize(responseData,ConvertAndMergeResponseData.class);
        sendMergeResponse(responseDataObj);
    }
 
    public class ConvertAndMergeResponseData
    {
        // The Salesforce ID of the Attachment / ContentVersion created as a result of the process
        public Id recordId;
        // A value, either "success" or "error", indicating the status of the request
        public string status;
        // Information about an error that occurred as part of the process. Null if status is not "error"
        public Error error;
        // The version of the package installed
        public string requestVersion;
        // The original parameters passed to the process
        public Map<string, string> requestParameters;
    }
    public class Error
    {
        // A UUID used to identify the error
        public string referenceId;
        // A description of the error
        public string message;
    }*/
}