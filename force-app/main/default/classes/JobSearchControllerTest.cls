@istest
public class JobSearchControllerTest {

    public static testmethod void TestJobSearchController() {
       test.startTest();
        Account acc = new Account (Name = 'test account');
        insert acc;
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.AccountId = acc.Id;
        con.tr1__State_Area__c = 'Alabama';
        con.tr1__regional_Area__c = 'Mobile Metro Area';
        con.tr1__Primary_background__c = 'Test Primary Background';
        con.tr1__Secondary_background__c = 'Test Sec Background';
        insert con;
        tr1__job__c testjob = new tr1__job__c(TR1__External_Job_Title__c = 'test job',tr1__Secondary_background__c = 'Test Sec Background',tr1__Primary_background__c = 'Test Primary Background',tr1__regional_Area__c = 'Mobile Metro Area',tr1__State_Area__c = 'Alabama',TR1__Job_Board__c = 'testjobboard', tR1__Post_Externally__c = true, TR1__Status__c = 'Open',TR1__Client_Description__c ='test',TR1__Education_Requirements__c='aaa',TR1__Experience_Requirements__c='bbb',TR1__Responsibilities__c='ccc');
        insert testjob;
        Test.setCurrentPage(page.Jobsearch);
        apexpages.currentpage().getParameters().put('sitename', 'testjobboard');
        apexpages.currentpage().getParameters().put('Jobboard', 'testjobboard');
        JobSearchController jbboard = new JobSearchController();
        jbboard.resumeflag = true;
        jbboard.cont();
        jbboard.jobTemp = new tr1__Job__c();
        jbboard.jobKeyword = 'Test Contact';
        jbboard.jobTemp.tr1__State_Area__c = 'Alabama';
        jbboard.jobTemp.tr1__regional_Area__c = 'Mobile Metro Area';
        jbboard.jobTemp.tr1__Primary_background__c = 'Test Primary Background';
        jbboard.jobTemp.tr1__Secondary_background__c = 'Test Sec Background';
        jbboard.jobsearch();
        System.debug(jbboard.hasNext);
        System.debug(jbboard.hasPrevious);
        jbboard.firstjobs();
        jbboard.lastjobs();
        jbboard.previousjobs();
        jbboard.nextjobs();
        JobSearchController.emailvalidator('test@test.com');
       test.stopTest();
    }
    public static testmethod void TestJobSearchController1() {
       test.startTest();
        tr1__job__c testjob = new tr1__job__c(TR1__External_Job_Title__c = 'test job',tr1__Secondary_background__c = 'Test Sec Background',tr1__Primary_background__c = 'Test Primary Background',tr1__regional_Area__c = 'Mobile Metro Area',tr1__State_Area__c = 'Alabama',TR1__Job_Board__c = 'testjobboard', tR1__Post_Externally__c = true, TR1__Status__c = 'Open',TR1__Client_Description__c ='test',TR1__Education_Requirements__c='aaa',TR1__Experience_Requirements__c='bbb',TR1__Responsibilities__c='ccc');
        insert testjob;
        Account acc = new Account (Name = 'test account');
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'Test Contact';
        con.LastName = 'Test Contact';
        con.AccountId = acc.Id;
        con.tr1__State_Area__c = 'Alabama';
        con.tr1__regional_Area__c = 'Mobile Metro Area';
        con.tr1__Primary_background__c = 'Test Primary Background';
        con.tr1__Secondary_background__c = 'Test Sec Background';
        insert con;
        Test.setCurrentPage(page.jobRegister);
        apexpages.currentpage().getParameters().put('Jobboard', 'testjobboard');
        apexpages.currentpage().getParameters().put('jobId', testjob.Id);
        JobSearchController jbboardnew = new JobSearchController();
        jbboardnew.con = con;
        jbboardnew.SubmitWOResume();
        jbboardnew.resumetype = 'Paste';
        jbboardnew.ResumeBodyText ='test resume body';
        jbboardnew.createUpdateResume();
        jbboardnew.resumebody = Blob.valueOf('test body');
        jbboardnew.resumecontentype = 'application/msword';
        jbboardnew.resumeName = 'test resume.doc';
        jbboardnew.resumetype = 'Upload';
        jbboardnew.createUpdateResume();
        jbboardnew.fromEmail = 'test@test.com';
        jbboardnew.fromNAme = 'test';
        jbboardnew.toEmail = 'testing@testing.com';
        jbboardnew.toName = 'testing';
        jbboardnew.mesg = 'test msg';
        jbboardnew.sndEmail();
       test.stopTest();
    }


}