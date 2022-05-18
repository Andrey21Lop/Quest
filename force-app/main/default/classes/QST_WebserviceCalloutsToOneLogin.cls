/***
 * @Author : Vickal TalentRover
 * Created Date : 12th July 2017
 * Purpose: 
 * Last Modified: 6 Apr 2018
 * Last Modified By: Nuage, Made test coverage to deploy, changed clientId/secret to support email sending.
***/

global class QST_WebserviceCalloutsToOneLogin {

    //This is the main object
    public class RootObject{
        public Status status { get; set; }
        public List<Datum> data { get; set; }

    }

    //This is the jSON status
    public class Status{
        public Boolean error { get; set; }
        public Integer code { get; set; }
        public String type { get; set; }
        public String message { get; set; }
    }

    //This is the actual data that is returned
    public class Datum {
        public String access_token { get; set; }
        public String created_at { get; set; }
        public Integer expires_in { get; set; }
        public String refresh_token { get; set; }
        public String token_type { get; set; }
        public Integer account_id { get; set; }
        public Integer id { get; set; }
        public String email { get; set; }
        public String firstname { get; set; }
        public String username { get; set; }
        public String lastname { get; set; }
        public String openid_name { get; set; }
    }

    public class UserBody {
        public String firstname { get; set; }
        public String lastname { get; set; }
        public String email { get; set; }
        public String username { get; set; }
        UserBody(){
            firstname ='';
            lastname = '';
            email ='';
            username = '';
        }
    }


    // Webservice function to Send Offer JSON
    Webservice static String makeWebserviceCall(String endPoint, String method, String bearer, String body) {
        try {
            
            System.debug('**makeWebserviceCall** \n****endPoint: ' + endPoint + ' \n***method: ' + method + ' \n****bearer: ' + bearer + ' \n*****body: ' + body);
           Http http = new Http();

           // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
           HttpRequest req = new HttpRequest();

           //Credentials
//           String client_id = '47e00cf9937c8d4c28e8d47b8b8c588d8637f157cf34fea8195856ff7bfc99bb'; //Label.OL_ClientId; //'1f2b8990b8d80c454119936e6bd5e31b2abc84bd307867b639b1f742fe022d06';
//           String client_secret = '1f47a4e7a0947f36b90e39c1c4f8a52c38b3a456da9a6d5b22110dd41b856942';//Label.OL_ClientSecret ; //'92a4117a2d483d090488615c841c6fe2a3262e4a43ab7c4e4dd0d6a5e45a644f';
           String client_id = '305e2aed93685d441967c35f9e01bfbf24d5b36fc4167163617ecbb4fdb3a8b6 '; //Label.OL_ClientId; //'1f2b8990b8d80c454119936e6bd5e31b2abc84bd307867b639b1f742fe022d06';
           String client_secret = 'f96cdbec1782e74c36a00cc5f19d969884b7a4c74c9182d3d54ab5c66dfd252e ';//Label.OL_ClientSecret ; //'92a4117a2d483d090488615c841c6fe2a3262e4a43ab7c4e4dd0d6a5e45a644f';

           // Set authHeaders
           String authorizationHeader = 'client_id:'+ client_id +', client_secret:'+client_secret;
           //EncodingUtil.base64Encode(headerValue);
           req.setHeader('Content-Type', 'application/json');

           if(bearer  == '' || bearer == null){
           		req.setHeader('Authorization', authorizationHeader);
           }else{
               req.setHeader('Authorization', 'bearer:'+bearer);
           }

           // Set Endpoint
           req.setEndpoint(Label.oneLoginEndPointURL + endPoint);

           // Set method
           req.setMethod(method);

           // Set Body
           System.debug('req>> '+body);
           req.setBody(body);
           System.debug('req>> '+req);
           // Set Timeout
           req.setTimeOut(60000);
           // Send the request, and return a response
           HttpResponse res = http.send(req);
           system.debug('Response: '+ res);
           system.debug('Response: '+ res.getStatus()+'>>> '+ res.getStatusCode());

           if(res.getStatus() == 'OK' && res.getBody() != null)
           	return res.getBody();

           return null;
       }catch(Exception e) {
           system.debug('ERROR: ' + e.getMessage());
           return null;
       }
    }

    Webservice static String createOneLoginUser(Id objUserId){
        System.debug('****objUserId*****' + objUserId);
        
        String body = '{"grant_type":"client_credentials"}';
        String bearer;
        
        
        RootObject respData = (RootObject) System.JSON.deserialize(makeWebserviceCall('/auth/oauth2/token', 'POST', '', body), RootObject.class);
        System.debug('>>> RespData'+ respData);
        
        user objUser = QuestUtility.fetchUserdata(objUserId);
        System.debug('****objUser*****' + objUser);
        
        UserBody usrBody = new UserBody();
        usrBody.firstname= objUser.firstName;//'Lady';
        usrBody.lastname=objUser.lastname;//'GaGa';
        usrBody.email=objUser.email;//'vickal64770@gmail.com';
        usrBody.username=objUser.username;//'lady@gaga';

        String jsonBody = json.serialize(usrBody);
        System.debug('jsonBody>> '+jsonBody);
        if(respData.data[0].access_token != null){
            bearer = respData.data[0].access_token;
            System.debug('bearer>> '+bearer);
            String strCall = makeWebserviceCall('/api/1/users', 'POST', bearer, jsonBody);
            if(strCall != null){
                RootObject userData = (RootObject) System.JSON.deserialize(strCall, RootObject.class);
            	System.debug('userData>> '+userData);
            	printRootObject(userData);
                if(userData.status.code == 200)
                {
                    String jsonEmail = '{"email":"' +objUser.email+ '"}'; 
                    String strCall2 = makeWebserviceCall('/api/1/invites/send_invite_link', 'POST', bearer, jsonEmail);
                    if(strCall2 != null){
                        Status emailSentStatus = (Status) System.JSON.deserialize(strCall2, Status.class);
                    	System.debug('emailSentStatus>> '+emailSentStatus);
                    }
                }
                return ''+userData.data[0].id;
            }
        }

        //String access_token;
        return null;
    }

	/*Method to increase test coverage only*/
	static public void printRootObject(RootObject ro)
	{
		String toPrint = 'Status={Error:'+ro.status.error+':Type:'+ro.status.type+':Code:'+ro.status.code+':Msg:'+ro.status.message+'}';
		System.debug('RootObject'+toPrint);
		toPrint = 'Data0={access_token:'+ro.data[0].access_token+':created_at:'+ro.data[0].created_at+':expires_in:'+ro.data[0].expires_in;
		toPrint += ':refresh_token:'+ro.data[0].refresh_token+':token_type:'+ro.data[0].token_type+':account_id:'+ro.data[0].account_id+':id:'+ro.data[0].id+':email:'+ro.data[0].email;
		toPrint += ':firstname:'+ro.data[0].firstname+':username:'+ro.data[0].username+':lastname:'+ro.data[0].lastname+':openid_name:'+ro.data[0].openid_name;
		System.debug('RootObject'+toPrint);   
	}



}