public class UserTriggerHandler {
    
    public static Set<Id> setUserIds;
    
    public static void processOneLoginUsers(List<user> lstUsers){
        
        System.debug('****lstUsers*****' + lstUsers);
        setUserIds = new Set<Id>();
        for(User objUser : lstUsers){
            if(QuestUtility.isCommunityUser(objUser.ProfileId)){
                System.debug('****objUser*****' + objUser);
                setUserIds.add(objUser.id);
            }
        }
        System.debug('****setUserIds*****' + setUserIds +' Size= '+setUserIds.size());
        
        if(setUserIds != null && setUserIds.size() > 0){
            createOneLoginUser(setUserIds);
        }
        System.debug('****20*****');
    }

    @future(callout=true)
    public static void createOneLoginUser(Set<Id> setUsers){
        System.debug('****setUserIds*****' + setUserIds);
        List<User> lstUserToUpdate = new List<User>();
        if(setUsers != null && setUsers.size() > 0){
            for(Id objUserId : setUsers){
                System.debug('****objUserId*****' + objUserId);
                String strOneLoginId = QST_WebserviceCalloutsToOneLogin.createOneLoginUser(objUserId);
                System.debug('****strOneLoginId*****' + strOneLoginId);
                
                if(strOneLoginId != null){
                    System.debug('A user created with RecruitmentCommunityUser profile. - User Id : ' + objUserId);
                    user temp = new User(id=objUserId);
                    temp.OneLoginID__c = strOneLoginId;
                    update temp;
                    System.debug('****temp*****' + temp);
                }
            }
        }
    }

}