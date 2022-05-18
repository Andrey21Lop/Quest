@isTest 
public class NG_TokenController_Test 
{
    static testMethod void verifyTokenTest() 
    {
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        Contact cont = new Contact ();
        cont.FirstName = 'FirstName';
        cont.LastName = 'LastName';
        cont.Email='email@email.com';
        cont.phone='12345678';
        insert cont;
        
        Contact approver = new Contact ();
        approver.FirstName = 'AppFN';
        approver.LastName = 'LN';
        approver.Email='approver@email.com';
        approver.phone='12345678';
        insert approver;
        
        NG_Timesheet__c timesheet = new NG_Timesheet__c();
        TR1__Timesheet__c trTimesheet = MockFactory.createTRTimesheet(cont.Id);
        timesheet.Source_Object_ID__c = trTimesheet.Id;
        timesheet.Name = 'B&P Hospital - Week Ending 08/17/2019';
        timesheet.Employee__c = cont.id;
        timesheet.Timesheet_Approver__c = approver.id;
        timesheet.Work_Location__c = testAccount.id;
        timesheet.NG_UUID__c = '1234';
        timesheet.Week_End__c = Date.newInstance(2019, 8, 17);
        insert timesheet;
        Test.StartTest(); 
        
        PageReference pageRef = Page.NG_Token; // Add your VF page Name here
        pageRef.getParameters().put('Id',trTimesheet.id);
        ApexPages.currentPage().getParameters().put('Id',trTimesheet.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(timesheet);
        NG_TokenController controller = new NG_TokenController();           
        controller.timesheet.NG_UUID__c = '1234';
        controller.verifyToken();   
        Test.StopTest();
        NG_Timesheet__c timeSheetData = [select id,NG_UUID__c from NG_Timesheet__c];
        System.assert(controller.message == 'Success');
    }
    
    
}