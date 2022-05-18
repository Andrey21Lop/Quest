/* 
    Developer Name: 
    Created Date: 
    Description:
    
*/

public without sharing class RC_HomeController {
    
    public User objUser                {get;set;}             //To get the last login date and time for the current logged in user
    public Contact objContact          {get; set;}            //To fetch the current user logged in user contact information
    Id idContact;                                             //To check the current logged in user have contact id / not 
    public Boolean isQHSBrand 		   {get; set;}			  //To check the current logged user’s associated contact belongs to QHS 
    public Boolean isQGCBrand          {get; set;}			  //To check the current logged user’s associated contact belongs to QGC 
    
    
    //Controller
    public RC_HomeController () 
    {    
        //Properties
        isQHSBrand = false;
        isQGCBrand = false;
        
        objUser = [SELECT LastLoginDate FROM User WHERE Id =:UserInfo.getUserId()]; //To fetch the last login date and time     
    }
    
    //If Unauthenticated user trying to access the page from Guest user then it will redirect to Signin page
    public Pagereference redirectUnAuthenticatedUser()
    {
        if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
        {
            return new Pagereference('/Signin'); 
        }  
        
         //To get the current logged in user contact Id
            idContact = [Select Id, ContactId                                           
                                   From User 
                                   where Id=: UserInfo.getUserId()].ContactId;
        
        //If the contact id not equal to null, the function will call to fetch the contact information to show on VF page.                                      
        if(idContact != null)
            fetchContactInfo();
        
        return null;
    }
    
     //To fetch the contact detail
    private void fetchContactInfo()
    {
        objContact = [SELECT Id,Community_Contact_Type__c, Consol_URL__c, Paylocity_Company_ID__c, 
                      QG_Contact_Account_Type__c FROM Contact WHERE Id = :idContact];
        
        //populate the flag
        if(objContact.Paylocity_Company_ID__c == System.Label.QHS_Paylocity_Company_Id 
           						|| objContact.QG_Contact_Account_Type__c == System.Label.QHS_QG_Contact_Account_Type) {
      		isQHSBrand = true;   
        } 
        
        if(objContact.Paylocity_Company_ID__c == System.Label.QGC_Paylocity_Company_Id 
           						|| objContact.QG_Contact_Account_Type__c == System.Label.QGC_QG_Contact_Account_Type) {
      		isQGCBrand = true;   
        } 
    } 

}