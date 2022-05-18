public class QualificationPackageTriggerHandler {

    public void createQPAndAQ(List<TR1__Qualification_Package__c> newQPList){

        Map<String, List<TR1__Qualification_Package__c>> jobQPMap = new Map<String, List<TR1__Qualification_Package__c>>();
        List<TR1__Associated_Qualification__c> assQlfToUpsert = new List<TR1__Associated_Qualification__c>();
        List<TR1__Qualification_Package__c> qpObsToUpdate = new List<TR1__Qualification_Package__c>();
        System.debug('newQPList>>'+newQPList);
        for(TR1__Qualification_Package__c qpOb : newQPList){
            if(qpOb.TR1__Add_Associated_Qualifications__c && qpOb.TR1__Job__c != null && qpOb.TR1__Contact__c != null){
                if(!jobQPMap.containsKey(qpOb.TR1__Job__c)){
                    jobQPMap.put(qpOb.TR1__Job__c, new List<TR1__Qualification_Package__c>{qpOb});
                }else{
                    jobQPMap.get(qpOb.TR1__Job__c).add(qpOb);
                }
            }
        }
        System.debug('jobQPMap>>> '+jobQPMap);
        for(TR1__Job__c job : [Select Id, (Select Id, TR1__Qualification__c From TR1__Associated_Qualifications__r) From TR1__Job__c Where Id IN : jobQPMap.keySet()]){
            for(TR1__Qualification_Package__c qpOb : jobQPMap.get(job.Id)){
                Integer i= 0;
                for(TR1__Associated_Qualification__c caq : job.TR1__Associated_Qualifications__r){
                    // Associated Qualifications for "Qualification Package"
                    TR1__Associated_Qualification__c assQlf = new TR1__Associated_Qualification__c(RecordTypeId= Schema.SObjectType.TR1__Associated_Qualification__c.getRecordTypeInfosByName().get('Candidate Credentials').getRecordTypeId());
                    assQlf.TR1__Qualification__c = caq.TR1__Qualification__c;
                    assQlf.TR1__Qualification_Package__c = qpOb.Id;
                    assQlf.TR1__Job_Qualification__c = caq.id;
                    assQlf.TR1__External_ID__c = caq.TR1__Qualification__c+'_'+qpOb.Id+'_'+i+job.Id+'_'+qpOb.TR1__Contact__c;
                    assQlfToUpsert.add(assQlf);
                    i++;

                    // Associated Qualifications for Contact
                    assQlf = new TR1__Associated_Qualification__c(RecordTypeId= Schema.SObjectType.TR1__Associated_Qualification__c.getRecordTypeInfosByName().get('Candidate Credentials').getRecordTypeId());
                    assQlf.TR1__Qualification__c = caq.TR1__Qualification__c;
                    assQlf.TR1__Contact__c = qpOb.TR1__Contact__c;
                    assQlf.TR1__Job_Qualification__c = caq.id;
                    assQlf.TR1__External_ID__c = caq.TR1__Qualification__c+'_'+qpOb.TR1__Contact__c;
                    assQlfToUpsert.add(assQlf);
                }
                qpObsToUpdate.add(new TR1__Qualification_Package__c(Id = qpOb.Id, TR1__Add_Associated_Qualifications__c = false));
            }
        }
        System.debug('================== assQlfToUpsert : '+assQlfToUpsert);
        System.debug('================== jobsToUpdate : '+qpObsToUpdate);
        if(assQlfToUpsert.size() > 0){
            upsert assQlfToUpsert TR1__External_ID__c;
            // Code to link the Associated Candidate Qualification to each Associated "Qualification Package" Qualification
            Integer i = 0;
            for(TR1__Associated_Qualification__c aq : assQlfToUpsert){
                if(Math.mod(i, 2) == 0){
                    aq.TR1__Contact_Qualification__c = assQlfToUpsert.get(i+1).id;
                }
                i++;
            }
            update assQlfToUpsert;
        }
        if(qpObsToUpdate.size() > 0){
            update qpObsToUpdate;
        }
    }
}