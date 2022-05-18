public without sharing class Utilities {

    // Used to get the contact Id from the current User since Community Users have both.
    public static String GetContactIdFromUser() {
        User u = [Select ContactId from User where Id = :UserInfo.getUserId()];       
        return (u != null ? u.ContactId : null);
    }

    // Used to get the base Salesforce Url from the Page Url.
    public static String GetBaseUrl(){
        string baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        return baseUrl;
    }

    public static String GetNGCSHValue(String valueName) {
        NGCSH__c config = NGCSH__c.getOrgDefaults();
        return String.valueOf(config.get(valueName));
    }

}