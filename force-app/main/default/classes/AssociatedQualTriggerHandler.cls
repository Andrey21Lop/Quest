public with sharing class AssociatedQualTriggerHandler {
  public AssociatedQualTriggerHandler() {}

  @future
  public static void rollupAQ_On_QP(Set<Id> qpIds){
    if(qpIds != null && qpIds.size() > 0){
      List<TR1__Qualification_Package__c> qpsToUpdate = new List<TR1__Qualification_Package__c>();

      for(TR1__Qualification_Package__c qp : [Select Id, Name, (Select Id, TR1__Status__c, Contact_Qualification_Status__c
        From TR1__Associated_Qualifications__r)
        From TR1__Qualification_Package__c Where Id IN :qpIds]){

        TR1__Qualification_Package__c newQp = new TR1__Qualification_Package__c(Id = qp.Id);
        newQp.Total_Requested_AQs__c = 0;
        newQp.Total_Submitted_AQs__c = 0;
        newQp.Total_Active_AQs__c = 0;
        newQp.Total_Rejected_AQs__c = 0;
        newQp.Total_Expired_AQs__c = 0;

        for(TR1__Associated_Qualification__c aq : qp.TR1__Associated_Qualifications__r){
          if(aq.Contact_Qualification_Status__c != null){
            if(aq.Contact_Qualification_Status__c.trim().equalsIgnoreCase('Requested')){
              newQp.Total_Requested_AQs__c++;
            }else if(aq.Contact_Qualification_Status__c.trim().equalsIgnoreCase('Submitted')){
              newQp.Total_Submitted_AQs__c++;
            }else if(aq.Contact_Qualification_Status__c.trim().equalsIgnoreCase('Active')){
              newQp.Total_Active_AQs__c++;
            }else if(aq.Contact_Qualification_Status__c.trim().equalsIgnoreCase('Rejected')){
              newQp.Total_Rejected_AQs__c++;
            }else if(aq.Contact_Qualification_Status__c.trim().equalsIgnoreCase('Expired')){
              newQp.Total_Expired_AQs__c++;
            }
          }
        }

        qpsToUpdate.add(newQP);
      }

      if(qpsToUpdate.size() > 0){
        update qpsToUpdate;
      }
    }
  }
}