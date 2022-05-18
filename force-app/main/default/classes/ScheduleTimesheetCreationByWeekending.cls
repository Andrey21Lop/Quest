/*
Acc-Product Team 1:10/3/2017: W-008217 - TR core - Timesheet generation based on week end from Closing Report: Scheduler class
*************************************************************************************************************/
global class ScheduleTimesheetCreationByWeekending implements Schedulable{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    public Boolean flag=false;
    public Date sow;
    public Date eow;
    public String recordId;
    global ScheduleTimesheetCreationByWeekending(){}
    global ScheduleTimesheetCreationByWeekending(String recordId){
        this.recordId = recordId;
    }
    global void execute(SchedulableContext sc) {  
        sow = Date.today().tostartofWeek().addDays(1);
        eow = sow.addDays(6);
        
        String sowstring = Datetime.newInstance(sow.year(), sow.month(), sow.day()).format('yyyy-MM-dd');
        String eowstring = Datetime.newInstance(eow.year(), eow.month(), eow.day()).format('yyyy-MM-dd');
      
        String query = 'SELECT Id,Name,TR1__Start_Date__c,TR1__End_Date__c,TR1__Job__c,TR1__Person_Placed__c,TR1__Account__c,'+
                    'TR1__Timesheet_Approver__c,TR1__Timesheet_Second_Approver__c,TR1__Bill_Rate__c,TR1__Pay_Rate__c,'+ 
                    'TR1__Payroll_Type__c,TR1__Week_Ending__c,TR1__Week_Start__c'
                      +' FROM TR1__Closing_Report__c WHERE ';
        
        query += ' NG_Generate_Timesheets__c = true AND TR1__Assignment_Ended__c = \'No\' AND ((TR1__Start_Date__c <= ' + sowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)) OR (TR1__Start_Date__c >= ' + sowstring + ' AND TR1__Start_Date__c <= ' + eowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)))';
        
        system.debug('*******query*************'+query);
        system.debug('bw: TR1__Generate_Timesheet__c = true AND TR1__Assignment_Ended__c = \'No\' AND ((TR1__Start_Date__c <= ' + sowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)) OR (TR1__Start_Date__c >= ' + sowstring + ' AND TR1__Start_Date__c <= ' + eowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)))');
        
        ID batchprocessid = Database.executeBatch(new CreateTimeSheetsByWeekending(query),1);
    }
   
}