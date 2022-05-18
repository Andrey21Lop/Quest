@isTest
private class RC_ResumeUploadTest 
{
    private static testMethod void test() 
    {
        User u = RC_UtilityClass.returnCommunityUser();

        System.runAs(u)
        {
            ApexPages.currentPage().getParameters().put('success', 'false');
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            RC_ResumeUpload objResumeUpload = new RC_ResumeUpload();
            objResumeUpload.objAttachment.Name = 'TestAttachment';
    	    objResumeUpload.objAttachment.body = bodyBlob;
            System.assertEquals(objResumeUpload.success,'false');
            //TR1__TalentRoverProperties__c objCSTR = TR1__TalentRoverProperties__c.getInstance();
            //String orgId = objCSTR.TR1__Organization_ID__c; 
        	TR1__TalentRoverProperties__c objCSTR = new TR1__TalentRoverProperties__c(Apex_Email_Service__c = 'test@gmaile.com', TR1__Salesforce_Host__c = ' naа34.test.com ');
            RC_AccessController.insertRecord(objCSTR);
            PageReference pg = objResumeUpload.insertContent();  
            System.assertEquals('/ResumeUpload?Success=false&UserExist=false',pg.getURL()); 
      }
       
  }

}