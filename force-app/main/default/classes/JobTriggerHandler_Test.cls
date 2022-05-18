/***
 * @Author : Vickal
 * Created Date : 7th July 2017
 * Purpose: Test Class of JobTriggerHandler
 * Last Modified: 
 * Last Modified By: 
***/
@isTest
public class JobTriggerHandler_Test {
    
   static testMethod void JobAssociatedQualTest(){
        List<Account> accList = TestDataUtility.getAccount(1);
        insert accList;
         
        List<Contact> conList = TestDataUtility.getContact(1);
        insert conList;
           
        TR1__Qualification_Package__c  qp = new TR1__Qualification_Package__c();
        qp.TR1__Contact__c = conList[0].id;
        qp.TR1__Name__c = 'Test QP';
        insert qp;
         
        TR1__Qualification__c qual =  new TR1__Qualification__c();
        qual.Name = 'Test Qual';
        qual.TR1__Collection_Methods__c = 'DocuSign';
        insert qual;
            
        TR1__Associated_Qualification__c assQual = new TR1__Associated_Qualification__c();
        assQual.TR1__Qualification__c = qual.Id;
        assQual.TR1__Qualification_Package__c = qp.Id;
        insert assQual;
        
        List<TR1__Job__c> jobList = TestDataUtility.getJob(1);
        jobList[0].Account_Qualification_Package__c = qp.Id;
        insert jobList;
        
        TR1__Job__c job = new TR1__Job__c();
        job.TR1__Account__c = accList[0].Id;
        job.TR1__Contact__c = conList[0].id;
        insert job;
         
        TR1__Qualification_Package__c  qp1 = new TR1__Qualification_Package__c();
        qp.TR1__Contact__c = conList[0].id;
        qp.TR1__Add_Associated_Qualifications__c = true;
        qp.TR1__Name__c = 'Test QP';
        qp.TR1__Job__c = job.Id;
        insert qp1;
        
    }
}