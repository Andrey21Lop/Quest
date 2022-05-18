public with sharing class TR_TimesheetDetail_Helper 
    extends BaseTriggerHelper
{
    public TR_TimesheetDetail_Helper() {

    }

    public override void execute(SObject so) {
        system.debug('bw: TR_TimesheetDetail_Helper::' + (Trigger.isBefore ? 'Before Trigger: ' : 'After Trigger: ') + 'so = ' + so);

        SObjectUnitOfWork uow = null;

        TR1__Timesheet_Detail__c td = (TR1__Timesheet_Detail__c) so;

        if(Trigger.isAfter && Trigger.isInsert) {
            if(td.NG_Generate_Timesheets__c) {
            //if(detail.Shift_Status__c != 'Tentative' && detail.Shift_Status__c != 'Cancelled') {
                uow = CreateNGTimesheetEntry(td);
            //}
            }
        }
        else if(Trigger.isAfter && Trigger.isDelete) {
            if(td.NG_Generate_Timesheets__c) {
                uow = DeleteNGTimesheetEntry(td);
            }
        }

        if(uow != null) {
            m_uowList.add(uow);
        }
    }

    public override void execute(SObject so, SObject oldSo){
        system.debug('bw: TR_TimesheetDetail_Helper::execute -> so = ' + so + ', oldSo = ' + oldSo);
    }

    private SObjectUnitOfWork CreateNGTimesheetEntry(TR1__Timesheet_Detail__c timesheetDetail) {
        System.debug('bw: TR_TimesheetDetail_Helper.CreateNGTimesheetEntry fired');
        return TimesheetEntryGateway.create(timesheetDetail);
    }

    private SObjectUnitOfWork DeleteNGTimesheetEntry(TR1__Timesheet_Detail__c tr1TimesheetDetail) {
        system.debug('bw: DeleteNGTimesheet -> fired');
        return TimesheetEntryGateway.deleteBySourceObjectId(tr1TimesheetDetail.Id);
    }

}