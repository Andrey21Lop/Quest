public class QuestUtility {
    
    public static final String RECRUITMENT_COMMUNITY_PROFILE_NAME = 'Recruitment Community User';
    
    public static Boolean isCommunityUser(Id currentUserProfileId){
        System.debug('****currentUserProfileId*****' + currentUserProfileId);
        
        List<String> communityProfileNames = new List<String>();
        communityProfileNames.add(RECRUITMENT_COMMUNITY_PROFILE_NAME);
        System.debug('****communityProfileNames*****' + communityProfileNames);
        
        Map<Id,Profile> mapProfiles = new Map<Id,Profile>([Select id,name from Profile where name IN: communityProfileNames ]);
        System.debug('****mapProfiles*****' + mapProfiles);
        
        Set<Id> setCummnityProfielIds = new Set<Id>();
        if(mapProfiles != null && mapProfiles.size() > 0){
            setCummnityProfielIds = mapProfiles.keySet();
            System.debug('****setCummnityProfielIds*****' + setCummnityProfielIds);
            if(setCummnityProfielIds.contains(currentUserProfileId)){
                System.debug('****currentUserProfileId : ' + currentUserProfileId + ' is a CommunityUser Profile *****');
                return true; 
            }else{
                System.debug('****currentUserProfileId : ' + currentUserProfileId + ' is not a CommunityUser Profile *****');
                return false;
            }
        }else{
            System.debug('No Community Profile Present.');
            return false;
        }
    }
    
    public static User fetchUserdata(Id objUserId){
        System.debug('****objUserId*****' + objUserId);
        List<User> lstUsers = [Select id,name,firstname,lastname, username,Email from User where id=: objUserId];
        System.debug('****lstUsers*****' + lstUsers);
        if(lstUsers != null && lstUsers.size() > 0){
            System.debug('****lstUsers[0]*****' + lstUsers[0]);
            return lstUsers[0];
        }else{
            System.debug('**** no user present with the id: ' + objUserId);
            return null;
        }
    }
}