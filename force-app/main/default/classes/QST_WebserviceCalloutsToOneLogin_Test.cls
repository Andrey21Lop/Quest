@isTest
private class QST_WebserviceCalloutsToOneLogin_Test 
{

	@testSetup
	static void setupTestData()
	{
		String orgId=UserInfo.getOrganizationId(); 
		String userId=UserInfo.getUserId();
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
		Account portalAccount = new Account(name = 'portalAccount', ownerId=userId); insert portalAccount;		
		Contact c = new Contact(firstname = 'ABC', lastName = 'XYZNG', email = uniqueName + '@test' + orgId + '.org',AccountId=portalAccount.Id); insert c;
		portalAccount = [SELECT Name, OwnerId FROM Account WHERE Name = 'portalAccount' limit 1];
		/*
		System.debug('--AV--ContextUser'+UserInfo.getUserName());
		User u = [SELECT Id, UserRoleId FROM User WHERE Id =: userId limit 1];
		List <UserRole> ur=[Select Id,Name,portalType from UserRole WHERE Name = 'Admin'];
		System.debug('--AV--UserRoles'+ur);
		if(u.UserRoleId == null) u.UserRoleId = ur[0].Id; update u;
		System.debug('--AV--CurrentUserRole'+u.UserRoleId);
		*/
	}

    static testMethod void unitTest1() 
    {
    	System.debug('--AV--Label'+System.Label.oneLoginEndPointURL);
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		multimock.setStaticResource(System.Label.oneLoginEndPointURL+'/auth/oauth2/token', 'OneloginTestEndpoint_Auth');
		multimock.setStaticResource(System.Label.oneLoginEndPointURL+'/api/1/users', 'OneloginTestEndpoint_Users');
		multimock.setStaticResource(System.Label.oneLoginEndPointURL+'/api/1/invites/send_invite_link', 'OneloginTestEndpoint_SendInviteLink');
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		

       	String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        List <UserRole> ur=[Select Id,Name,portalType from UserRole where portalType = 'CustomerPortal'];
        System.debug('--AV--'+ur);	
		Contact c = [Select Id from Contact where firstname='ABC' and lastname = 'XYZNG' limit 1];		
		Profile pf= [Select Id from profile where Name='Recruitment Community User']; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimock);
        String body = '{"grant_type":"client_credentials"}';
        System.debug('AVDebug '+QST_WebserviceCalloutsToOneLogin.makeWebserviceCall('/auth/oauth2/token', 'POST', '', body));
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id,
                         ContactId = c.Id
                         //UserRoleId = ur[0].Id
                         //PortalRole='User'
                        ); 
        
        
        insert uu;
        Test.stopTest();
    }
}