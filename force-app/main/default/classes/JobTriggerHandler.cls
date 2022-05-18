/***
 * @Author : Vickal
 * Created Date : 7th July 2017
 * Purpose: Handler Class of JobTrigger on Job 
 * Last Modified: 
 * Last Modified By:
***/

public class JobTriggerHandler {  
    /***
     * @Author: Vickal
     * purpose: Methods to Create Associated Qualifications on Job When Add Associated Qualifications checkbox is checked
     * Dated: 7th July 2017
     * Dated: Acc: 9/8/2017: Updated condition on when the code to be executed on change of flag or on change of Qualification Package
  **/
    public void JobAssociatedQualifications(List<TR1__Job__c> newJobs,Map<Id,TR1__Job__c> newMap, Map<Id,TR1__Job__c> oldMap){
        Map<String, TR1__Associated_Qualification__c> assQlfToUpsert = new Map<String, TR1__Associated_Qualification__c>();        
        Map<String, TR1__Job__c> jobsVsQPkg = new Map<String, TR1__Job__c>();
        Map<String, List<TR1__Associated_Qualification__c>> QPkgVsAqual = new Map<String, List<TR1__Associated_Qualification__c>>();
        Map<String, TR1__Job__c> jobsToUpdate = new Map<String, TR1__Job__c>();

        //Check Jobs if checkbox is checked and Account Qualification Package is not null
        System.debug('newJobs> '+newJobs);
        for(TR1__Job__c job : newJobs){
            if(job.TR1__Add_Associated_Qualifications__c == true && job.Account_Qualification_Package__c != null){
                if (oldMap == null || oldMap.get(job.Id).TR1__Add_Associated_Qualifications__c != newMap.get(job.Id).TR1__Add_Associated_Qualifications__c ||
                    oldMap.get(job.Id).Account_Qualification_Package__c != newMap.get(job.Id).Account_Qualification_Package__c){
                    if(!jobsVsQPkg.containsKey(job.Account_Qualification_Package__c)){
                        jobsVsQPkg.put(job.Account_Qualification_Package__c, job);
                    }
                }    
            }
        }
        if (jobsVsQPkg.size()>0){
        for(TR1__Qualification_Package__c qp : [Select Id, (Select Id, TR1__Qualification__c From TR1__Associated_Qualifications__r) From TR1__Qualification_Package__c Where Id IN : jobsVsQPkg.keySet()]){
            for(TR1__Associated_Qualification__c aQual : qp.TR1__Associated_Qualifications__r ){ 
                if(!QPkgVsAqual.containsKey(qp.Id)){
                    QPkgVsAqual.put(qp.Id, new List<TR1__Associated_Qualification__c>{aQual});    
                }else{
                    QPkgVsAqual.get(qp.Id).add(aQual);
                } 
            }
        }
        
        for(TR1__Job__c job : newJobs){
            if(QPkgVsAqual.size()>0)
            for(TR1__Associated_Qualification__c aQual : QPkgVsAqual.get(job.Account_Qualification_Package__c)){
                TR1__Associated_Qualification__c assQlf = new TR1__Associated_Qualification__c(RecordTypeId = Schema.SObjectType.TR1__Associated_Qualification__c.getRecordTypeInfosByName().get('Job Qualification').getRecordTypeId());
                assQlf.TR1__Qualification__c = aQual.TR1__Qualification__c;
                assQlf.TR1__Job__c = job.Id;
                assQlf.TR1__External_ID__c = job.Id+'_'+aQual.TR1__Qualification__c;
                assQlfToUpsert.put(assQlf.TR1__External_ID__c, assQlf);
            }
            jobsToUpdate.put(job.Id, new TR1__Job__c(Id = job.Id, TR1__Add_Associated_Qualifications__c = false));
        }
        try{
            if(assQlfToUpsert.size()>0){
                upsert assQlfToUpsert.values() TR1__External_ID__c;
            }
            if(jobsToUpdate.size()>0){
                update jobsToUpdate.values();
            }
        }catch(DMLException de){
            System.debug('LineNumber: '+de.getLineNumber()+ 'ErrorMessage: '+de.getMessage());
        }    
        }
    }    
   
    /***
     * @Author: Vickal
     * purpose: Methods to Create Associated Qualifications on Job When Add Associated Qualifications checkbox is checked
     * Dated: 7th July 2017
  
    public void JobAssociatedQualifications(List<TR1__Job__c> newJobs) {
        Map<String, TR1__Associated_Qualification__c> assQlfToUpsert = new Map<String, TR1__Associated_Qualification__c>();        
        Map<String, TR1__Job__c> jobsVsQPkg = new Map<String, TR1__Job__c>();
        Map<String, List<TR1__Associated_Qualification__c>> QPkgVsAqual = new Map<String, List<TR1__Associated_Qualification__c>>();
        Map<String, TR1__Job__c> jobsToUpdate = new Map<String, TR1__Job__c>();

        //Check Jobs if checkbox is checked and Account Qualification Package is not null
        System.debug('newJobs> '+newJobs);
        for(TR1__Job__c job : newJobs){
            if(job.TR1__Add_Associated_Qualifications__c == true && job.Account_Qualification_Package__c != null){
                if(!jobsVsQPkg.containsKey(job.Account_Qualification_Package__c)){
                    jobsVsQPkg.put(job.Account_Qualification_Package__c, job);
                }else{
                    jobsVsQPkg.get(job.Account_Qualification_Package__c);
                }
            }
        }
        for(TR1__Qualification_Package__c qp : [Select Id, (Select Id, TR1__Qualification__c From TR1__Associated_Qualifications__r) From TR1__Qualification_Package__c Where Id IN : jobsVsQPkg.keySet()]){
            for(TR1__Associated_Qualification__c aQual : qp.TR1__Associated_Qualifications__r ){ 
                if(!QPkgVsAqual.containsKey(qp.Id)){
                    QPkgVsAqual.put(qp.Id, new List<TR1__Associated_Qualification__c>{aQual});    
                }else{
                    QPkgVsAqual.get(qp.Id).add(aQual);
                } 
            }
        }
        
        for(TR1__Job__c job : newJobs){
            if(QPkgVsAqual.size()>0)
            for(TR1__Associated_Qualification__c aQual : QPkgVsAqual.get(job.Account_Qualification_Package__c)){
                TR1__Associated_Qualification__c assQlf = new TR1__Associated_Qualification__c(RecordTypeId = Schema.SObjectType.TR1__Associated_Qualification__c.getRecordTypeInfosByName().get('Job Qualification').getRecordTypeId());
                assQlf.TR1__Qualification__c = aQual.TR1__Qualification__c;
                assQlf.TR1__Job__c = job.Id;
                assQlf.TR1__External_ID__c = job.Id+'_'+aQual.TR1__Qualification__c;
                assQlfToUpsert.put(assQlf.TR1__External_ID__c, assQlf);
            }
            jobsToUpdate.put(job.Id, new TR1__Job__c(Id = job.Id, TR1__Add_Associated_Qualifications__c = false));
        }
        try{
            if(assQlfToUpsert.size()>0){
                upsert assQlfToUpsert.values() TR1__External_ID__c;
            }
            if(jobsToUpdate.size()>0){
                update jobsToUpdate.values();
            }
        }catch(DMLException de){
            System.debug('LineNumber: '+de.getLineNumber()+ 'ErrorMessage: '+de.getMessage());
        }
    }  **/
}