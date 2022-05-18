@isTest
public class NG_DocMergeTest {
    @testSetup 
    static void setupData() 
    {
      Integer ctr = 0;
      Integer totalCR = 3;
      
      //Step1: Create CustomSetting and TimeType
      NGCS__C ngcs = new NGCS__C(Name='Main',NG_Debug_Flag__c=TRUE, TS_OverWriteShifts__c=TRUE, TS_UseShiftUploadModel_KV__c=TRUE, TS_ShiftLoadTypes__c='New,New', TS_PopulateShifts__c=TRUE, TS_PopulateRates__c=TRUE); insert ngcs;
        NG_TR_Settings__c ngtrs = new NG_TR_Settings__c(Name='TestSettings',NG_Invoice_Prefix__c='Test',NG_Invoice_Number__c=1); insert ngtrs;
        TR1__TimeType__c tt1 = new TR1__TimeType__c(Name = 'Regular', TR1__EntryType__c = 'Hours & Minutes', TR1__ShowAs__c = 'Hours',QG_COA_Code__c ='4000');
      TR1__TimeType__c tt2 = new TR1__TimeType__c(Name = 'Overtime', TR1__EntryType__c = 'Hours & Minutes', TR1__ShowAs__c = 'Hours');
        TR1__TimeType__c tt3 = new TR1__TimeType__c(Name = 'Expense - Lodging', TR1__EntryType__c = 'Hours & Minutes', QG_COA_Code__c ='4325');
        TR1__TimeType__c tt4 = new TR1__TimeType__c(Name = 'Expense - Mileage', TR1__EntryType__c = 'Hours & Minutes', QG_COA_Code__c ='4330');
      insert tt1; insert tt2;insert tt3;insert tt4;
      
      //Step2: Create Accounts and Contacts (Currently only creating one but will need atleast 2)
      Account acc = new Account(Name='Calif Account Test',SA_Account_Company_Code__c='10'); insert acc;
        Contact con = new Contact(LastName='Approv Calif Contact Test',Email='abac@abconsulting.com',AccountId=acc.Id);insert con;
         //Insert User
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]; 
        User SalesPrimaryuser = new User(LastName = 'Administrator',
                     FirstName='Dev1',
                     Alias = 'TAdmi',
                     Email = 'aniket.vast+ngdev4estream1@thenuagegroup.com',
                     Username = 'TAdmi@Testme.com',  
                       ProfileId = profileId.id,
                     TimeZoneSidKey = 'GMT',
                     LanguageLocaleKey = 'en_US',
                     EmailEncodingKey = 'UTF-8',
                     LocaleSidKey = 'en_US',
                     Phone = '11232',
             NG_COA_Company__c=11,
              NG_COA_Cost_Center__c = 1020,
                       NG_COA_Division__c =22                                          
                     ); insert SalesPrimaryuser;
        
         User SalesSecondaryuser = new User(LastName = 'Administrator2',
                     FirstName='Dev2',
                     Alias = 'TAdmi2',
                     Email = 'aniket.vast+ngdev4estream1@thenuagegroup.com',
                     Username = 'TAdmi2@Testme.com',                     
                       ProfileId = profileId.id,
                     TimeZoneSidKey = 'GMT',
                     LanguageLocaleKey = 'en_US',
                     EmailEncodingKey = 'UTF-8',
                     LocaleSidKey = 'en_US',
                     Phone = '11232',
             NG_COA_Company__c=11,
              NG_COA_Cost_Center__c = 1020,
                       NG_COA_Division__c =22                                          
                     ); insert SalesSecondaryuser;
          User RecSecondaryuser = new User(LastName = 'Administrator3',
                     FirstName='Dev3',
                     Alias = 'TAdmi3',
                     Email = 'aniket.vast+ngdev4estream1@thenuagegroup.com',
                     Username = 'TAdmi3@Testme.com',                     
                       ProfileId = profileId.id,
                     TimeZoneSidKey = 'GMT',
                     LanguageLocaleKey = 'en_US',
                     EmailEncodingKey = 'UTF-8',
                     LocaleSidKey = 'en_US',
                     Phone = '11232',
             NG_COA_Company__c=12,
              NG_COA_Cost_Center__c = 1020,
                       NG_COA_Division__c =23                                          
                     ); insert RecSecondaryuser;
          User RecPrimaryuser = new User(LastName = 'Administrator4',
                     FirstName='Dev4',
                     Alias = 'TAdmi4',
                     Email = 'aniket.vast+ngdev4estream1@thenuagegroup.com',
                     Username = 'TAdmi4@Testme.com',                     
                       ProfileId = profileId.id,
                     TimeZoneSidKey = 'GMT',
                     LanguageLocaleKey = 'en_US',
                     EmailEncodingKey = 'UTF-8',
                     LocaleSidKey = 'en_US',
                     Phone = '11232',
             NG_COA_Company__c=12,
              NG_COA_Cost_Center__c = 1020,
                       NG_COA_Division__c =23                                          
                     ); insert RecPrimaryuser;
        
      
      //Step3: Create Jobs for Consulting. These should be a set of 2 for 2 Accounts and Candidates/Contacts.
      Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
      List<TR1__Job__c> l_jobs = new List<TR1__Job__c>();
        TR1__Job__c job1 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 1', TR1__Contact__c = con.Id); l_jobs.add(job1);
        TR1__Job__c job2 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 2', TR1__Contact__c = con.Id); l_jobs.add(job2);
        TR1__Job__c job3 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 3', TR1__Contact__c = con.Id); l_jobs.add(job3);
        insert(l_jobs);
        
        //Step4: For each Job, create a closing Report.
        Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
      List<TR1__Closing_Report__c> l_crs = new List<TR1__Closing_Report__c>();
      TR1__Closing_Report__c cr;
      for(Integer iCR = 0 ; iCR < totalCR ; iCR++)
      {
        cr = new TR1__Closing_Report__c();
        cr.RecordTypeId = crconsultingId;
        cr.TR1__Person_Placed__c = con.Id;
        cr.Candidate_Type__c = 'Non-Physician'; //This will need to be commented on other SBs
        cr.TR1__Job__c = l_jobs.get(iCR).Id;
        cr.TR1__Timesheet_Approver__c = null;
        cr.TR1__Timesheet_Second_Approver__c = null;
        cr.TR1__Account__c = acc.Id;
        cr.TR1__Generate_Timesheet__c = true;
            cr.TR1__Candidate_Percentage__c=5;
            cr.TR1__Job_Credit__c = SalesPrimaryuser.Id;
            cr.TR1__Marketing_Credit__c = SalesSecondaryuser.Id;
            cr.TR1__Other_Credit__c = RecSecondaryuser.Id;
            cr.TR1__Candidate_Credit__c = RecPrimaryuser.Id;
            cr.TR1__Marketing_Percentage__c = 5;
            cr.TR1__Job_Percentage__c =2;
            cr.TR1__Candidate_Percentage__c =2.5;
            cr.TR1__Other_Percentage__c =3.0;
       l_crs.add(cr);
      }
      insert l_crs;

    //Step5: For each Closing Report, insert 2 RateTypes (as defined by timetypes above)
      System.debug('AVDebug: CRs inserted');
      List<TR1__Rate__c> l_rates = new List<TR1__Rate__c>();
      TR1__Rate__c rate;
      Id RType = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Closing Report Rate').getRecordTypeId();
        for(ctr = 0; ctr < totalCR ; ctr++)
      {
        rate = new TR1__Rate__c();
        rate.Name = tt1.Name;
        rate.RecordTypeId = RType;
        rate.TR1__Active__c = true;
        rate.TR1__ClosingReport__c = l_crs.get(ctr).Id;
        rate.TR1__Job__c = l_jobs.get(ctr).Id;
        rate.TR1__RateBill__c = 20;
        rate.TR1__RatePay__c = 10;
        rate.TR1__TimeType__c = tt1.Id;
        
        l_rates.add(rate);
        
        rate = new TR1__Rate__c();
        rate.Name = tt2.Name;
        rate.RecordTypeId = RType;
        rate.TR1__Active__c = true;
        rate.TR1__ClosingReport__c = l_crs.get(ctr).Id;
        rate.TR1__Job__c = l_jobs.get(ctr).Id;
        rate.TR1__RateBill__c = 30;
        rate.TR1__RatePay__c = 15;
        rate.TR1__TimeType__c = tt2.Id;
        
        l_rates.add(rate);
            
             rate = new TR1__Rate__c();
        rate.Name = tt3.Name;
        rate.RecordTypeId = RType;
        rate.TR1__Active__c = true;
        rate.TR1__ClosingReport__c = l_crs.get(ctr).Id;
        rate.TR1__Job__c = l_jobs.get(ctr).Id;
        rate.TR1__RateBill__c = 30;
        rate.TR1__RatePay__c = 15;
        rate.TR1__TimeType__c = tt3.Id;
        
        l_rates.add(rate);
            
            rate = new TR1__Rate__c();
        rate.Name = tt4.Name;
        rate.RecordTypeId = RType;
        rate.TR1__Active__c = true;
        rate.TR1__ClosingReport__c = l_crs.get(ctr).Id;
        rate.TR1__Job__c = l_jobs.get(ctr).Id;
        rate.TR1__RateBill__c = 30;
        rate.TR1__RatePay__c = 15;
        rate.TR1__TimeType__c = tt4.Id;
        
        l_rates.add(rate);
            
      }
      insert l_rates;
      System.debug('AVDebug: Rates inserted for CRs');
      
        // Create Invoices
         List<TR1_INV__Invoice__c> invoices = new List<TR1_INV__Invoice__c>();
      TR1_INV__Invoice__c inv;
      inv = new TR1_INV__Invoice__c(TR1_INV__Account__c=acc.Id,TR1_INV__Closing_Report__c= l_crs.get(0).Id);invoices.add(inv);
      insert invoices;
        System.debug('AVDebug: Sample Invoice Inserted');
        // Create Invovoice Line Items
        List<TR1_INV__Invoice_Line_Item__c> ilis = new List<TR1_INV__Invoice_Line_Item__c>();
        TR1_INV__Invoice_Line_Item__c ili;
        ili = new TR1_INV__Invoice_Line_Item__c(TR1_INV__Invoice__c = invoices.get(0).Id,
                                                TR1_INV__Closing_Report__c=l_crs.get(0).Id
                                                );
        ilis.add(ili);
        insert ilis;
          System.debug('AVDebug: Sample Invoice Line Item Inserted');

      //Create Time Sheets
      //Insert only ONE TS (others will be created by the batch code)
      TR1__Timesheet__c ts = new TR1__Timesheet__c();
        ts.TR1__Closing_Report__c = l_crs.get(0).Id;
        ts.TR1__Consultant__c = con.Id;
        ts.TR1__Job_Order__c = l_jobs.get(0).Id;
        ts.TR1__Client__c = acc.Id;
        ts.TR1__Week_Ending__c = Date.parse('12/7/2017');
      ts.TR1__Pay_Week_Ending__c = Date.parse('12/7/2017');
        ts.TR1_INV__InvoiceLineItem__c = ilis.get(0).id;
      insert ts;
        
        //Update Invoice Line Items
        List<TR1_INV__Invoice_Line_Item__c> iliToUpdate = [Select Id, Name From TR1_INV__Invoice_Line_Item__c];
        for (TR1_INV__Invoice_Line_Item__c iliupd : iliToUpdate)
        {
            iliupd.TR1_INV__Timesheet__c = ts.Id;
        }
        Upsert iliToUpdate;
    System.debug('AVDebug: Sample Invoice Line Item Updated');
    //For the inserted TS above, the Rate Trigger doesn't fire in Testing, so ONLY for the one above create Rates at Timesheet level (others are created in Test.IsRunning code)
      Id RType_CR = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Closing Report Rate').getRecordTypeId();
      List<TR1__Rate__c> l_ERates = new List<TR1__Rate__c>();
      TR1__Rate__c ERate;
      Id RType_TS = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Timesheet Rate').getRecordTypeId();
      List<TR1__Rate__c> CRRates = [SELECT Id, Name, TR1__ClosingReport__c, TR1__Job__c, TR1__Timesheet__c, TR1__TimeType__c, TR1__Rate_Type_Name__c, TR1__RatePay__c, TR1__RateBill__c FROM TR1__Rate__c WHERE TR1__ClosingReport__c =: l_crs.get(0).Id and RecordTypeId =: RType_CR];
        System.debug('CRRates->'+CRRates);
      for(TR1__Rate__c crt : CRRates)
      {
        ERate = new TR1__Rate__c();
        ERate.Name = crt.Name;
        ERate.RecordTypeId = RType_TS;
        ERate.TR1__Active__c = true;
        ERate.TR1__ClosingReport__c = crt.TR1__ClosingReport__c;
        ERate.TR1__Timesheet__c = ts.Id;
        ERate.TR1__Job__c = crt.TR1__Job__c;
        ERate.TR1__RateBill__c = crt.TR1__RateBill__c;
        ERate.TR1__RatePay__c = crt.TR1__RatePay__c;
        ERate.TR1__TimeType__c = crt.TR1__TimeType__c;   
            ERate.TR1__ACA_Fee_Value__c=10;
        l_ERates.add(ERate);
      }
      insert l_ERates;
      
      System.debug('AVDebug : TS Rates inserted for sample');
    
    //Create only 2 TSD not the Third, This is just to make it weird for the first Timesheet.
    TR1__Timesheet_Detail__c tsd;
        List<TR1__Timesheet_Detail__c> tsds = new List<TR1__Timesheet_Detail__c>();
    for(ctr =0; ctr<2; ctr++)
    {
        tsd = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = ts.id, TR1__Date__c = Date.parse('12/8/2017'), TR1__Day__c = TR1.Utility.dayOfDate(Date.parse('8/3/2018')));
      tsds.add(tsd);
        tsd = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = ts.id, TR1__Date__c = Date.parse('12/8/2017'), TR1__Day__c = TR1.Utility.dayOfDate(Date.parse('8/3/2018')));
      tsds.add(tsd);
    }
        insert tsds;

    System.debug('AVDebug: Sample TSD Inserted');
        // Insert Shift Works.
        
        TR1_INV__Billing_Profile__c billingProfile = new TR1_INV__Billing_Profile__c();
        billingProfile.TR1_INV__Name__c = 'BPO-387';
        billingProfile.TR1_INV__Account__c = acc.Id;
        billingProfile.TR1_INV__Invoice_Email__c = 'test@testmail.com';
        
        insert billingProfile;
        System.debug('AVDebug: Sample Sample Billing Profile Inserted');
        
        List<TR1__ShiftWork__c> shiftWorkList = new List<TR1__ShiftWork__c>();
    
        for(ctr = 0; ctr < 2 ; ctr++)
        {
            TR1__ShiftWork__c shiftWork = new TR1__ShiftWork__c();
            shiftWork.TR1__Timesheet__c = ts.id;
            shiftWork.TR1__TimesheetDetail__c = tsds.get(0).Id;
            shiftWork.TR1__Rate__c = l_ERates.get(0).Id;
            shiftWork.TR1__AmountBill__c = 140;
            shiftWork.TR1__Hours__c = 7;
            shiftWork.ACA_Fee_Amount__c=120;
            shiftWork.NG_Guaranteed_Hours__c=8;
             shiftWork.TR1__StartDateTime__c = DateTime.newInstance(2017, 6, 12);
            shiftWork.TR1__Start_Time__c='12:00AM';
            shiftWork.TR1__EndDateTime__c = DateTime.newInstance(2018, 12, 12);
            shiftWork.TR1__End_Time__c='12:00AM';
            shiftWorkList.add(shiftWork);
        }
        insert shiftWorkList;
        System.debug('AVDebug: Sample Shift Works Inserted');
        System.debug('rate->'+l_ERates.get(0));
        System.debug('shiftWorkList->'+shiftWorkList);
        // Create Expense Report
        TR1__Expense_Report__c expReport = new TR1__Expense_Report__c();
    expReport.TR1__Account__c=acc.Id;
        expReport.TR1__Closing_Report__c= l_crs.get(0).Id;
        expReport.TR1__Status__c = 'Approved';
        insert expReport;
        
        TR1__Expense_Report_Detail__c expLineItem = new TR1__Expense_Report_Detail__c();
      List<TR1__Expense_Report__c> insertedER = [Select Id, Name From TR1__Expense_Report__c];
        // Update invoice Line Item with Expense Report
        
        List<TR1_INV__Invoice_Line_Item__c> eriliToUpdate = [Select Id, Name From TR1_INV__Invoice_Line_Item__c];
        for (TR1_INV__Invoice_Line_Item__c iliupd : eriliToUpdate)
        {
            iliupd.TR1_INV__Expense_Report__c = insertedER.get(0).Id;
        }
        Upsert eriliToUpdate;
        
        List <TR1__Rate__c> insertedRates = [Select Id, Name From TR1__Rate__c Where Name = 'Expense - Lodging'];
        Id expLineItemRecordType = Schema.SObjectType.TR1__Expense_Report_Detail__c.getRecordTypeInfosByName().get('Lodging').getRecordTypeId();
        
        expLineItem.TR1__Expense_Report__c = insertedER.get(0).Id;
        expLineItem.TR1__Account__c = acc.Id;
        expLineItem.TR1__Rate__c = insertedRates.get(0).Id;
        expLineItem.TR1__Amount__c =50;
        expLineItem.SA_Reimbursed_Amount__c=5;
        expLineItem.SA_Business_Name__c = 'H1';
        expLineItem.RecordTypeId =expLineItemRecordType;
        expLineItem.ExpenseLI_End_Date__c = Date.parse('12/12/2018');
        insert expLineItem;
        TR1__Expense_Report_Detail__c expLineItem2 = new TR1__Expense_Report_Detail__c();
        expLineItem2.TR1__Expense_Report__c = insertedER.get(0).Id;
        expLineItem2.TR1__Account__c = acc.Id;
        expLineItem2.TR1__Rate__c = insertedRates.get(0).Id;
        expLineItem2.TR1__Amount__c =50;
        expLineItem2.SA_Reimbursed_Amount__c=15;
        expLineItem2.SA_Business_Name__c = 'H1';
        expLineItem2.RecordTypeId =expLineItemRecordType;
        expLineItem2.ExpenseLI_End_Date__c = Date.parse('12/12/2018');
        insert expLineItem2;
        System.debug('insertedRates->'+insertedRates);
        
        //For Each Closing report Create ACL
        List<Confirmation_Letters_ACLs__c> l_acls = new List<Confirmation_Letters_ACLs__c>();
        Confirmation_Letters_ACLs__c acl;
        for(ctr = 0; ctr < totalCR ; ctr++)
      {
          acl = new Confirmation_Letters_ACLs__c();
        acl.Name = 'TestACL_' + ctr;
        acl.Closing_Report__c = l_crs.get(ctr).Id;
          acl.ACL_Type__c = 'Client';
          acl.ACL_Start_Date__c = Date.parse('12/1/2017');
          acl.ACL_End_Date__c = Date.parse('12/20/2017');
          l_acls.add(acl);
      }
        insert l_acls;
        NGCS__c cs = new NGCS__c();
        cs.Name = 'Main';
        cs.Invoice_Content_Library__c = null;
        insert cs;
        //for each ACL create documents
        createContentDocumentVersion();
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        //Create File for ACL
        for(ctr = 0; ctr < totalCR ; ctr++) {
        	createContentDocumentLink(l_acls.get(ctr).Id,documents[0].Id);
        }
        
        createContentDocumentLink(ts.Id,documents[0].Id);//Create File for Timesheet
        createContentDocumentLink(expReport.id,documents[0].Id);//Create File for Expense Report
        createAttachment(inv.id);
        List<Attachment> attachmnts = [Select id from Attachment];
        inv.NG_DocumentsTo_be_Merged__c = attachmnts[0].id + ',' + documents[0].Id;
        update inv;
    }
    
    
    static void createContentDocumentVersion(){
        ContentVersion contentVersion = new ContentVersion(
            Title =  'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
    }
    
    static void createContentDocumentLink(String recordId,string documentID){
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = recordId;
        cdl.ContentDocumentId = documentID;
        cdl.shareType = 'V';
        insert cdl;
    }    
    
    static void createAttachment(String recordId){
        Attachment attach=new Attachment();   	
    	attach.Name='Invoice Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=recordId;
        insert attach;
    }
    
    @isTest 
    static void test_getDocIds() {
        List<TR1_INV__Invoice__c> invoiceList = [SELECT Id, Name FROM TR1_INV__Invoice__c];
        //NG_DocMergeHelper.getRelatedDocIds(invoiceList.get(0).id);
        String parentId = invoiceList.get(0).id;
        NG_DocMergeController.getDocumentsToAttach(parentId);
        NG_DocMergeController.getSelctedDocIds(parentId);
        
        List<Id> lstOfDocIds = new List<Id>{'06918000000bcZrAAI','06918000000bMn9AAE'};
        NG_DocMergeController.saveDocIds(parentId, lstOfDocIds);
    }
    
    @isTest 
    static void test_MergeDocuments() {
        List<TR1_INV__Invoice__c> invoiceList = [SELECT Id, Name FROM TR1_INV__Invoice__c];
        ApexPages.StandardController sc = new ApexPages.StandardController(invoiceList.get(0));
        NG_CustomDocumentMerge docMerge = new NG_CustomDocumentMerge(sc);
        
        PageReference pageRef = Page.NGDocMergeVF;
        //pageRef.getParameters().put('id', String.valueOf(invoiceList.get(0).Id));
        Test.setCurrentPage(pageRef);        
        docMerge.MergeFiles1();
    }

}