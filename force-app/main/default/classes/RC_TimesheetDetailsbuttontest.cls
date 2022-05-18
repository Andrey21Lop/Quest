@isTest(Seealldata = false)

public  class RC_TimesheetDetailsbuttontest {
Public static testMethod void RC_TimesheetDetailsbuttontest() {
Account accApp = new Account(Name = 'Approver Account Test12232', Phone = '9963777127');
        RC_AccessController.insertRecord(accApp);
        
        Contact conApp = new Contact(LastName = 'Approver Contact Test34234', Email = 'admin@satrangtech.com', AccountId = accApp.Id);
        RC_AccessController.insertRecord(conApp);
 
 
 Account acc = new Account(Name = 'Account Test');
        RC_AccessController.insertRecord(acc);
        Contact con = new Contact(LastName = 'Contact Recruiter', Email = 'admin+rec@satrangtech.com', AccountId = acc.Id);
        RC_AccessController.insertRecord(con);
     
      User u1 = createTestUser('Appr', conApp.id, accApp.id);

     Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        
        TR1__Job__c job1 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 2', TR1__Contact__c = con.Id);
        //insert job1;
        TR1__Job__c[] joblist = new TR1__Job__c[] {
            job1
        };
        insert joblist;
      Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(
            TR1__Account__c = acc.id,
            RecordTypeId = crconsultingId,
            //Company_Active_Placements__c = acc.id,
            TR1__Job__c = job1.Id,
            TR1__Person_Placed__c = con.Id,
            TR1__Start_Date__c = system.today(),
           // Full_Time_Part_Time__c = 'Full-Time',
            //Travel__c = 'No',
           // Approval_Stage__c ='Approved',
            TR1__Assignment_Ended__c ='No',
            TR1__Job_Credit__c = u1.Id,
            TR1__Candidate_Credit__c = u1.Id,
            TR1__Marketing_Credit__c = u1.Id,
            TR1__Other_Credit__c = u1.Id,
            TR1__Other2_Credit__c = u1.Id,
            TR1__Generate_Timesheet__c = true,
            TR1__Timesheet_Approver__c = conApp.Id,
            TR1__Bill_Rate__c = 123,
            //TR1__Pay_Rate__c = 123,
            //TR1__End_Date__c = system.today(),
            TR1__Payroll_Type__c = 'W2',
            TR1__Pay_Rate__c = 123,
           // Base_Bill_Rate__c = 123,
            //HR_Financial_Operations_Notes__c ='test operation notes',
            TR1__Internal_Billing_Notes__c = 'test bill notes',
			Candidate_Type__c = 'Physician'
        );
    
    System.runAs(u1)
    {
         test.startTest();
        RC_AccessController.insertRecord(cr1);
           
         TR1__Timesheet__c timsheet = new TR1__Timesheet__c(TR1__Job_Order__c = job1.Id, TR1__Consultant__c = conApp.Id);
   
   RC_AccessController.insertRecord(timsheet);
         

   TR1__Timesheet_Detail__c timesheetdetail = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = timsheet.Id,TR1__Date__c=system.today());
   RC_AccessController.insertRecord(timesheetdetail);
    
   
   
   
   TR1__TimeType__c timetype = new TR1__TimeType__c(Name ='test',TR1__EntryType__c ='Start & Finish');
   RC_AccessController.insertRecord(timetype);
                    List < TR1__Rate__c > rates = new List < TR1__Rate__c > ();

   Schema.FieldSet fs1 = Schema.SObjectType.TR1__Rate__c.fieldSets.getMap().get('Timesheetdetailinforamtion');
   TR1__Rate__c rate = new TR1__Rate__c(Name ='test',TR1__ClosingReport__c = cr1.Id,TR1__TimeType__c=timetype.id, TR1__ACA_Fee_Value__c = 4);
   RC_AccessController.insertRecord(rate);
    
    //RC_AccessController.updateRecord(rate);
   
   //TR1__ShiftWork__c shift = new TR1__ShiftWork__c(TR1__Rate__c = rate.Id, TR1__TimesheetDetail__c = timesheetdetail.Id,TR1__Start_Time__c ='05:30AM', TR1__End_Time__c ='06:30AM',TR1__Hours__c=1);
     //     RC_AccessController.insertRecord(shift); //upsert shift 
        
    pagereference pgRef=Page.RC_TimesheetDetailsbutton;
    pgRef.getParameters().put('tsId', timesheetdetail.id);
            Test.setCurrentPageReference(pgRef);
            //test.Starttest();
            RC_TimesheetDetailsbutton SchCal = new RC_TimesheetDetailsbutton();
            SchCal.redirectUnAuthenticatedUser();
            //SchCal.getinvoice();
            SchCal.fetchContactInfo(); 
            SchCal.saveTimesheetDetails();
           SchCal.inlineedit();
            SchCal.canceledit();
          // SchCal.calculateTimeDifference();
        Try{ 
           // Apexpages.currentPage().getParameters().put('rowId', shift.Id);
           // SchCal.Deleterec();
        }catch(Exception ex){}
        test.stopTest();
    }
}

  
   
   
 public static  User createTestUser(String a, Id conId, Id accId) {
    
        if (a == 'Appr') {
            Profile p = [Select Id, Name from Profile where Name = 'Recruitment Community User'];
            return createTestUser(p, 'Approver', conId, accId);
        } else {
            Profile p = [Select Id, Name from Profile where Name = 'Recruitment Community User'];
            return createTestUser(p, 'Consult', conId, accId);
        }
    
        //return new User();
    }
    public static String createRandomWord() {
    
        String ret = 'word' + math.rint(math.random() * 100000);
    
        return ret;
    }
    public static  User createTestUser(Profile p, String a, Id conId, Id accId) {
    
        String namePrefix = createRandomWord();
    
        User testUser = new User();
        testUser.Email = 'admin'+a+'@satrangtech.com';
        testUser.Username = a + '_' + '112s123talentrover' + '@testuser.com';
        testUser.LastName = 'test' + a;
        testUser.Alias = a;
        testUser.ProfileId = p.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ContactId = conId;
        //testUser.Gender__c = ''
        //testUser.CompanyName  = '';
        //testUser.AccountId  = accId;
        //testUser.IsPortalEnabled = true;
    
        RC_AccessController.insertRecord(testUser);
    
        return testUser;
         
        
    }
}