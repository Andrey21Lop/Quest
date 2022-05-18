public with sharing class TR_ShiftWork_Helper 
    extends BaseTriggerHelper
{
    public TR_ShiftWork_Helper() {

    }

    public override void execute(SObject so) {
        system.debug('bw: TimesheetHelper::' + (Trigger.isBefore ? 'Before Trigger: ' : 'After Trigger: ') + 'so = ' + so);
        
        TR1__ShiftWork__c sw = (TR1__ShiftWork__c) so;

        if(Trigger.isAfter && Trigger.isDelete) {
            if(sw.NG_Generate_Timesheets__c && !TimesheetEntrySlotHelper.isExecuting) {
                DeleteNGTimesheetEntrySlot(sw);
            }
        }

    }

    public override void execute(SObject so, SObject oldSo){
        system.debug('bw: TimesheetHelper::execute -> so = ' + so + ', oldSo = ' + oldSo);
    }

    private void DeleteNGTimesheetEntrySlot(TR1__ShiftWork__c tr1ShiftWork) {
        system.debug('bw: DeleteNGTimesheetEntrySlot -> fired');
        TimesheetEntrySlotGateway.deleteBySourceObjectId(tr1ShiftWork.Id);
    }
}