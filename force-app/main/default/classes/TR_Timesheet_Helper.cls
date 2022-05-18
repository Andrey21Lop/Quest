public without sharing class TR_Timesheet_Helper 
    extends BaseTriggerHelper
{
    public TR_Timesheet_Helper() {

    }

    public override void execute(SObject so) {
        SObjectUnitOfWork uow = null;

        TR1__Timesheet__c t = (TR1__Timesheet__c) so;

        if(Trigger.isAfter && Trigger.isInsert) {
            system.debug('bw: TR_Timesheet_Helper::AfterInsert Trigger: so = ' + so);
            
            if(t.NG_Generate_Timesheets__c) {
                uow = TimesheetGateway.create(t);
            }
        }
        else if(Trigger.isAfter && Trigger.isDelete) {
            if(t.NG_Generate_Timesheets__c) {
                uow = TimesheetGateway.deleteBySourceObjectId(so.Id);
            }
        }

        if(uow != null) {
            m_uowList.add(uow);
        }
    }

    public override void execute(SObject so, SObject oldSo) {
        TR1__Timesheet__c t = (TR1__Timesheet__c) so;

        if(Trigger.isAfter && Trigger.isUpdate) {
            system.debug('bw: TR_Timesheet_Helper::AfterUpdate Trigger: so = ' + so + ', oldSo = ' + oldSo);
            if(t.NG_Generate_Timesheets__c) {
                List<SObjectUnitOfWork> uows = TimesheetGateway.synchronize((TR1__Timesheet__c) so);
                m_uowList.addAll(uows);
            }
        }
    }
}