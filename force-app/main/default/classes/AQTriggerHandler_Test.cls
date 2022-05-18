/***
 * @Author : Vickal
 * Created Date : 12th July 2017
 * Purpose: Test Class of JobTriggerHandler
 * Last Modified: 07th Sept, 2017
 * Last Modified By: Accenture :- Changed the Class Name 
***/

@isTest
public class AQTriggerHandler_Test {
    
   static testMethod void AssociatedQualTest(){
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
         
         TR1__Qualification__c qual1 =  new TR1__Qualification__c();
         qual1.Name = 'Test Qual1';
         qual1.TR1__Collection_Methods__c = 'DocuSign1';
         insert qual1;
            
        TR1__Associated_Qualification__c assQual = new TR1__Associated_Qualification__c();
        assQual.TR1__Qualification__c = qual.Id;
        assQual.TR1__Qualification_Package__c = qp.Id;
        assQual.TR1__Contact__c = conList[0].Id;
        insert assQual;
         
        List<TR1__Job__c> jobList = TestDataUtility.getJob(1);
        jobList[0].Account_Qualification_Package__c = qp.Id;
        insert jobList;
         
        TR1__Qualification_Package__c  qp1 = new TR1__Qualification_Package__c();
        qp1.TR1__Contact__c = conList[0].id;
        qp1.TR1__Add_Associated_Qualifications__c = true;
        qp1.TR1__Name__c = 'Test QP';
        qp1.TR1__Job__c  = jobList[0].Id;
        insert qp1;
         
         TR1__Associated_Qualification__c assQual1 = new TR1__Associated_Qualification__c();
         assQual1.TR1__Qualification__c = qual1.Id;
         assQual1.TR1__Qualification_Package__c = qp.Id;
         assQual1.TR1__Contact_Qualification__c =assQual.id;
         assQual1.TR1__Status__c  = 'Active';
         insert assQual1;
        
    }
}