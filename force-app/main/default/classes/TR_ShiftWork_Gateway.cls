public without sharing class TR_ShiftWork_Gateway {
    public static TR1__ShiftWork__c fetch(Id shiftWorkId) {
        return [SELECT Id, TR1__End_Time__c, TR1__EndDateTime__c, TR1__Rate__c,
                       TR1__Start_Time__c, TR1__StartDateTime__c, TR1__TimeType__c,
                       TR1__Timesheet__c, TR1__TimesheetDetail__c
                FROM TR1__ShiftWork__c
                WHERE Id = :shiftWorkId];
    }
    
    public static TR1__ShiftWork__c fetchShiftWorkForTimesheetDetailId(Id timesheetDetailId) {
        return [SELECT Id FROM TR1__ShiftWork__c WHERE TR1__TimesheetDetail__c = :timesheetDetailId];
    }

    public static List<TR1__ShiftWork__c> fetchShiftWorksForTRTimesheetId(Id timesheetId) {
        return [SELECT Id, TR1__Rate__c, NG_Regular_Hours__c, NG_Total_Shift_Work_OT__c FROM TR1__ShiftWork__c WHERE TR1__Timesheet__c = :timesheetId];
    }

    public static void save(TR1__ShiftWork__c shiftWork) {
        update shiftWork;
    }

    public static Id save(string shiftType, Id sourceObjectId, Id timesheetId, Id timesheetDetailId, Id rateId, string oncallBeeper, string inTime, Date outDate, string outTime, Decimal hours) {
        system.debug('bw: TR_ShiftWork_Gateway.save(' + sourceObjectId + ', ' + timesheetId + ', ' + timesheetDetailId + ', ' + rateId + ', ' + inTime + ', ' + outTime + ', ' + hours + ')'); 
        TR1__ShiftWork__c shiftWork = new TR1__ShiftWork__c();

        if(sourceObjectId != null) {
            system.debug('bw: TR_ShiftWork_Gateway.save -> sourceObjectId is NOT null');
            try {
            shiftWork = [SELECT Id, 
                                NG_End_Date__c, TR1__End_Time__c, TR1__Start_Time__c,
                                TR1__TimesheetDetail__c, TR1__Timesheet__c,
                                NG_On_Call_Beeper__c,
                                TR1__TimeType__c, TR1__Rate__c, TR1__Hours__c, 
                                NG_Regular_Hours__c, NG_Total_Shift_Work_OT__c
                         FROM TR1__ShiftWork__c 
                         WHERE Id = :sourceObjectId
                         LIMIT 1];
            }
            catch(Exception e) {
                shiftWork = new TR1__ShiftWork__c();
                shiftWork.TR1__TimesheetDetail__c = timesheetDetailId;
                shiftWork.TR1__Timesheet__c = timesheetId;                
            }
        }
        else {
            system.debug('bw: TR_ShiftWork_Gateway.save -> sourceObjectId IS null');
            shiftWork.TR1__TimesheetDetail__c = timesheetDetailId;
            shiftWork.TR1__Timesheet__c = timesheetId;
        }

        shiftWork.TR1__Start_Time__c = inTime;
        shiftWork.NG_End_Date__c = outDate;
        shiftWork.TR1__End_Time__c = outTime;
        shiftWork.TR1__Hours__c = hours;
        if(shiftType == 'Overtime') {
            shiftWork.NG_Total_Shift_Work_OT__c = hours;
        }
        else if(shiftType == 'Regular') {
            shiftWork.NG_Regular_Hours__c = hours;
        }
        shiftWork.TR1__Rate__c = rateId;
        if(oncallBeeper != null) {
            shiftWork.NG_On_Call_Beeper__c = oncallBeeper;
        }

        system.debug('bw: TR_ShiftWork_Gateway.save -> upsert shiftWork = ' + shiftWork);
        try {
            upsert shiftWork;
        }
        catch(Exception e) {
            system.debug('bw: TR_ShiftWork_Gateway.save -> e = ' + e);
        }
        system.debug('bw: TR_ShiftWork_Gateway.save -> shiftWork.Id = ' + shiftWork.Id);
        return shiftWork.Id;
    }

    /*
    public static void remove(Id shiftWorkId) {
        TR1__ShiftWork__c sw = new TR1__ShiftWork__c();
        sw.Id = shiftWorkId;
        delete sw;
    }

    public static Decimal removeExistingOTShiftWorks(TR1__Timesheet__c timesheet, Id otRateId) {
        Decimal hours = 0.00;

        List<TR1__ShiftWork__c> sws = [SELECT Id, NG_Total_Shift_Work_OT__c FROM TR1__ShiftWork__c WHERE TR1__Timesheet__c = :timesheet.Id AND TR1__Rate__c = :otRateId];

        for(TR1__ShiftWork__c s : sws) {
            hours += s.NG_Total_Shift_Work_OT__c;
        }

        delete sws;

        return hours;
    }
    */
}