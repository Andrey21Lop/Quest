/***
 * @Author : Vickal
 * Created Date : 7th July 2017
 * Purpose: Test data methods 
 * Last Modified: 07th Sept 2017
 * Last Modified By: Accenture :- Changed Class Name
***/
public class TestDataUtility {
  
    public static List<Account> getAccount(Integer NoOfRec){
        List<Account> accList = new List<Account>();
        for(Integer i=0; i<NoOfRec; i++){
            Account acc = new Account(Name='Account'+i);
            accList.add(acc);
        }
        return accList;
    }
    
    public static List<Contact> getContact(Integer NoOfRec){
        List<Contact> conList = new List<Contact>();
        for(Integer i=0; i<NoOfRec; i++){
            Contact con = new Contact(FirstName='First', LastName='Name'+i);
            conList.add(con);
        }
        return conList;
    }
    public static List<TR1__Job__c> getJob(Integer NoOfRec){
        List<TR1__Job__c> jobList = new List<TR1__Job__c>();
        for(Integer i=0; i<NoOfRec; i++){
            TR1__Job__c job = new TR1__Job__c();
            jobList.add(job);
        }
        return jobList;
    }
}