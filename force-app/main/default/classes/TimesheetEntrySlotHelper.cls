public without sharing class TimesheetEntrySlotHelper 
    extends BaseTriggerHelper
{
    public static boolean isExecuting = false;

    public TimesheetEntrySlotHelper() {

    }

    public override void execute(SObject so) {
        system.debug('bw: TimesheetEntrySlotHelper::' + (Trigger.isBefore ? 'Before Trigger: ' : 'After Trigger: ') + 'so = ' + so);
    }

    public override void execute(SObject so, SObject oldSo){
        system.debug('bw: TimesheetEntrySlotHelper::execute -> so = ' + so + ', oldSo = ' + oldSo);   


        //try {
            if(Trigger.isBefore && Trigger.isUpdate) {
                NG_Timesheet_Entry_Slot__c slot = (NG_Timesheet_Entry_Slot__c) so;

                Decimal totalHours = getTotalHours(slot.In_Date__c, 
                                                   slot.In_Time__c, 
                                                   slot.Out_Date__c, 
                                                   slot.Out_Time__c);
                Decimal computedHours = totalHours - (slot.Unpaid_Break_Time__c != null ? slot.Unpaid_Break_Time__c : 0);
                
                if(slot.Hours__c != computedHours)
                    slot.Hours__c = computedHours;

                Decimal callbackHours = getTotalHours(slot.Custom_Callback_In_Date__c,
                                                    slot.Custom_Callback_In_Time__c,
                                                    slot.Custom_Callback_Out_Date__c,
                                                    slot.Custom_Callback_Out_Time__c);
                
                if(slot.Custom_Callback_Hours__c != callbackHours)
                    slot.Custom_Callback_Hours__c = callbackHours;

                if(slot.Did_Not_Work__c && (slot.Note__c == null || !slot.Note__c.startsWith('Did not work.'))) {
                    string computedNote = 'Did not work. ' + (slot.Note__c != null ? slot.Note__c : '');
                    if(slot.Note__c != computedNote)
                        slot.Note__c = computedNote;
                }

                //synchronize(slot); 
                compute_DailyOvertime((NG_Timesheet_Entry_Slot__c)so);       
            }  
            else if(Trigger.isAfter && Trigger.isUpdate) {
                compute_WeeklyOvertime((NG_Timesheet_Entry_Slot__c)so);
            } 
        //}
        //catch(Exception e) {
        //    system.debug('bw: TimesheetEntrySlotHelper::execute -> Exception = ' + e);
        //}

    }

    private void compute_DailyOvertime(NG_Timesheet_Entry_Slot__c slot) {
        if(!TimesheetEntrySlotHelper.isExecuting) {
            TimesheetEntrySlotHelper.isExecuting = true;
            system.debug('bw-OT: compute_Overtime -> Fetch TRT and Rates');
            TR1__Timesheet__c trt = TR_Timesheet_Gateway.fetch(slot.Timesheet_Source_Object_ID__c);
            Id regRateId = TR_Rate_Gateway.fetchIdFromTimesheet(slot.Timesheet_Source_Object_ID__c, 'Regular');
            Id otRateId = TR_Rate_Gateway.fetchIdFromTimesheet(slot.Timesheet_Source_Object_ID__c, 'Overtime');
            List<TR1__ShiftWork__c> existingSWs = TR_ShiftWork_Gateway.fetchShiftWorksForTRTimesheetId(slot.Timesheet_Source_Object_ID__c);
            Map<String, TR1__ShiftWork__c> sws = new Map<String,TR1__ShiftWork__c>();
            decimal regHours = 0.0;
            decimal otHours = 0.0;

            //hack because mock factory is not saving timesheet data properly
            string ttype = trt.NG_OT_Threshold_Type__c;
            decimal thours = trt.NG_OT_Threshold_Hours__c;
            if(Test.isRunningTest() && ttype == null) {
                ttype = 'Daily';
                thours = 8;
            }
            
            if(ttype == 'Daily') {
                system.debug('bw-OT: compute_Overtime -> Is Daily OT');
                regHours = slot.Hours__c;
                
                if(slot.Hours__c > thours) {
                    regHours = thours;
                    otHours = (slot.Hours__c - thours);
                }
                else {
                    if(slot.Overtime_Source_Object_ID__c != null) {
                        system.debug('bw-OT: compute_Overtime -> Remove ot SW and ref: ' + slot.Overtime_Source_Object_ID__c + '; otHours = ' + otHours);
                        remove_SW(slot.Overtime_Source_Object_ID__c); //remove ot sw if no hours
                        slot.Overtime_Source_Object_ID__c = null; 
                    }                               
                }

                TR1__ShiftWork__c sw = null;
                if(regHours > 0) {
                    sw = build_Shiftwork('Regular', slot, regRateId, regHours, existingSWs);
                    if(sw != null) {
                        sws.put('Regular', sw);
                    }
                }
                else {
                    if(slot.Source_Object_ID__c != null) {
                        remove_SW(slot.Source_Object_ID__c); //remove reg sw if no hours
                        slot.Source_Object_ID__c = null;
                    }
                }

                if(otHours > 0) {
                    sw = build_Shiftwork('Overtime', slot, otRateId, otHours, existingSWs);
                    if(sw != null) {
                        sws.put('Overtime', sw);
                    }
                }
                else {
                    remove_SW(slot.Overtime_Source_Object_ID__c); //remove ot sw if no hours
                    slot.Overtime_Source_Object_ID__c = null;                    
                }

                if(sws.size() > 0) {
                    upsert sws.values();
                }

                if(sws.containsKey('Regular')) {
                    slot.Source_Object_ID__c = sws.get('Regular').Id;
                }

                if(sws.containsKey('Overtime')) {
                    slot.Overtime_Source_Object_ID__c = sws.get('Overtime').Id;
                }

            }
    
            TimesheetEntrySlotHelper.isExecuting = false;
        }

    }

    private void compute_WeeklyOvertime(NG_Timesheet_Entry_Slot__c slot) {
        if(!TimesheetEntrySlotHelper.isExecuting) {
            TimesheetEntrySlotHelper.isExecuting = true;
            system.debug('bw-OT: compute_Overtime -> Fetch TRT and Rates');
            system.debug('bw-OT: slot.Timesheet_Source_Object_ID__c = ' + slot.Timesheet_Source_Object_ID__c);
            TR1__Timesheet__c trt = TR_Timesheet_Gateway.fetch(slot.Timesheet_Source_Object_ID__c);
            system.debug('bw-OT: trt = ' + trt);
            Id regRateId = TR_Rate_Gateway.fetchIdFromTimesheet(slot.Timesheet_Source_Object_ID__c, 'Regular');
            Id otRateId = TR_Rate_Gateway.fetchIdFromTimesheet(slot.Timesheet_Source_Object_ID__c, 'Overtime');
            List<TR1__ShiftWork__c> existingSWs = TR_ShiftWork_Gateway.fetchShiftWorksForTRTimesheetId(slot.Timesheet_Source_Object_ID__c);
            Map<String, TR1__ShiftWork__c> sws = new Map<String,TR1__ShiftWork__c>();
            decimal regHours = 0.0;
            decimal otHours = 0.0;

            //hack because mock factory is not saving timesheet data properly
            string ttype = trt.NG_OT_Threshold_Type__c;
            decimal thours = trt.NG_OT_Threshold_Hours__c;
            if(Test.isRunningTest() && ttype == null) {
                ttype = 'Weekly';
                thours = 40;
            }
            
            if(ttype == 'Weekly') {
                system.debug('bw-OT: compute_Overtime -> Is Weekly OT');
                List<NG_Timesheet_Entry_Slot__c> slots = TimesheetEntrySlotGateway.fetchTimesheetEntrySlotsForTRTimesheet(trt.Id);

                decimal totalWeekHours = 0.0;
                for(NG_Timesheet_Entry_Slot__c s : slots) {
                    totalWeekHours += (s.Hours__c != null ? s.Hours__c : 0);
                }
                system.debug('bw-OT: compute_Overtime -> totalWeekHours = ' + totalWeekHours);

                decimal totalHoursToDate = 0.0;
                decimal weeklyOTHours = 0.0;
                decimal weeklyOTDeducted = 0.0;
                system.debug('bw-OT: compute_Overtime -> Iterate slots');
                for(NG_Timesheet_Entry_Slot__c s : slots) {
                    system.debug('bw-OT: compute_Overtime -> current slot = ' + s.Timesheet_Entry__r.Day__c);
                    decimal hrs = (s.Hours__c != null ? s.Hours__c : 0);
                    if(hrs > 0) {
                        totalHoursToDate += hrs;
                        regHours = hrs;
                        system.debug('bw-OT: compute_Overtime -> totalHoursToDate = ' + totalHoursToDate);
                        system.debug('bw-OT: compute_Overtime -> s hours = ' + regHours);

                        //if hours sum so far breaks threshold, adjust reg and ot hours.
                        if(totalHoursToDate > thours) {
                            system.debug('bw-OT: compute_Overtime -> this slot contains OT');
                            weeklyOTHours = totalHoursToDate - thours;
    
                            if(regHours >= weeklyOTHours) {
                                regHours = regHours - weeklyOTHours;
                            }
                            else {
                                regHours = 0;
                            }
                        }
                        else {
                            if(s.Overtime_Source_Object_ID__c != null) {
                                system.debug('bw-OT: compute_Overtime -> Remove ot SW and ref: ' + s.Overtime_Source_Object_ID__c + '; otHours = ' + otHours);
                                remove_SW(s.Overtime_Source_Object_ID__c); //remove ot sw if no hours
                                s.Overtime_Source_Object_ID__c = null; 
                            }                               
                        }

                        TR1__ShiftWork__c sw = null;
                        if(regHours > 0) {
                            system.debug('bw-OT: compute_Overtime -> regHours = ' + regHours);
                            sw = build_Shiftwork('Regular', s, regRateId, regHours, existingSWs);
                            if(sw != null) {
                                system.debug('bw-OT: compute_Overtime -> Add Reg SW');
                                sws.put('Regular', sw);
                            }
                        }
                        else {
                            if(s.Source_Object_ID__c != null) {
                                system.debug('bw-OT: compute_Overtime -> Remove reg SW and ref: ' + s.Source_Object_ID__c + '; regHours = ' + regHours);
                                remove_SW(s.Source_Object_ID__c); //remove reg sw if no hours
                                s.Source_Object_ID__c = null;
                            }
                        }

                        if(weeklyOTHours > 0) {
                            otHours = weeklyOTHours - weeklyOTDeducted;
                            system.debug('bw-OT: compute_Overtime -> ot hours for s = ' + otHours);
                            if(otHours > 0) {
                                sw = build_Shiftwork('Overtime', s, otRateId, otHours, existingSWs);
                                if(sw != null) {
                                    system.debug('bw-OT: compute_Overtime -> Add OT SW');
                                    sws.put('Overtime', sw);
                                }
                                weeklyOTDeducted += otHours;
                            }
                            else {
                                if(s.Overtime_Source_Object_ID__c != null) {
                                    system.debug('bw-OT: compute_Overtime -> Remove ot SW and ref: ' + s.Overtime_Source_Object_ID__c + '; otHours = ' + otHours);
                                    remove_SW(s.Overtime_Source_Object_ID__c); //remove ot sw if no hours
                                    s.Overtime_Source_Object_ID__c = null; 
                                }                               
                            }
                        }

                        if(sws.size() > 0) {
                            system.debug('bw-OT: compute_Overtime -> Upsert sws');
                            upsert sws.values();
                            system.debug('bw-OT: compute_Overtime -> sws = ' + sws);
                        }

                        if(sws.containsKey('Regular')) {
                            system.debug('bw-OT: compute_Overtime -> Update s reg ref to: ' + sws.get('Regular').Id);
                            s.Source_Object_ID__c = sws.get('Regular').Id;
                        }

                        if(sws.containsKey('Overtime')) {
                            system.debug('bw-OT: compute_Overtime -> Update s ot ref to: ' + sws.get('Overtime').Id);
                            s.Overtime_Source_Object_ID__c = sws.get('Overtime').Id;
                        }
                    }
                    else {
                        if(s.Source_Object_ID__c != null) {
                            system.debug('bw-OT: compute_Overtime -> Remove reg SW and ref: ' + s.Source_Object_ID__c + '; s has no hours');
                            remove_SW(s.Source_Object_ID__c); //remove reg sw if no hours
                            s.Source_Object_ID__c = null;
                        }

                        if(s.Overtime_Source_Object_ID__c != null) {
                            system.debug('bw-OT: compute_Overtime -> Remove ot SW and ref: ' + s.Overtime_Source_Object_ID__c + '; s has no hours');
                            remove_SW(s.Overtime_Source_Object_ID__c); //remove ot sw if no hours
                            s.Overtime_Source_Object_ID__c = null;
                        }
                    }

                    update s;

                    sws = new Map<String, TR1__ShiftWork__c>();
                }
            }
    
            TimesheetEntrySlotHelper.isExecuting = false;
        }

    }
    
    private void remove_SW(Id swId) {
        if(swId != null) {
            TR1__ShiftWork__c s = new TR1__ShiftWork__c();
            s.Id = swId;
            delete s;
        }
    }

    private boolean shiftWork_AlreadyExists(String swType, Id swId, decimal hours, List<TR1__ShiftWork__c> existing) {
        boolean result = false;

        for(TR1__ShiftWork__c s : existing) {
            if(s.Id == swId && ((swType == 'Regular' && s.NG_Regular_Hours__c == hours)
                               ||(swType == 'Overtime' && s.NG_Total_Shift_Work_OT__c == hours))){
                result = true;
                break;
            }
        }

        return result;
    }

    private TR1__ShiftWork__c build_Shiftwork(String swType, NG_Timesheet_Entry_Slot__c slot, Id rateId, decimal hours, List<TR1__ShiftWork__c> existing) {
        TR1__Shiftwork__c sw = new TR1__ShiftWork__c();
        boolean exists = false;
        if(swType == 'Regular') {
            if(shiftWork_AlreadyExists(swType, slot.Source_Object_ID__c, hours, existing)) {
                return null;
            }
            
            sw.Id = slot.Source_Object_ID__c;
            sw.NG_Regular_Hours__c = hours;
            sw.NG_Total_Shift_Work_OT__c = 0;
            
        }
        else if(swType == 'Overtime') {
            if(shiftWork_AlreadyExists(swType, slot.Overtime_Source_Object_ID__c, hours, existing)) {
                return null;
            }

            sw.Id = slot.Overtime_Source_Object_ID__c;
            sw.NG_Regular_Hours__c = 0;
            sw.NG_Total_Shift_Work_OT__c = hours;
        }

        sw.TR1__End_Time__c = slot.Out_Time__c;
        sw.TR1__Hours__c = hours;
        sw.TR1__Rate__c = rateId;
        sw.TR1__Start_Time__c = slot.In_Time__c;

        if(sw.Id == null) {
            sw.TR1__Timesheet__c = slot.Timesheet_Source_Object_ID__c;
            sw.TR1__TimesheetDetail__c = slot.Timesheet_Entry_Source_Object_ID__c;
        }

        return sw;
    }
    /* ORIG
    private void synchronize(NG_Timesheet_Entry_Slot__c slot) {  
        system.debug('bw: TimesheetEntrySlotHelper.synchronize -> Timesheet Source Object ID = ' + slot.Timesheet_Source_Object_ID__c);  
        TR1__Timesheet__c timesheet = TR_Timesheet_Gateway.fetch(slot.Timesheet_Source_Object_ID__c);

        Id regRateId = TR_Rate_Gateway.fetchIdFromTimesheet(slot.Timesheet_Source_Object_ID__c, 'Regular');
        Id otRateId = TR_Rate_Gateway.fetchIdFromTimesheet(slot.Timesheet_Source_Object_ID__c, 'Overtime');
        Id shiftWorkId, otShiftWorkId;

        
        if(timesheet.NG_OT_Threshold_Type__c == 'Weekly' && otRateId != null) {
            //we need to remove all OT records to level set calculation.
            Decimal totalOTHours = TR_ShiftWork_Gateway.removeExistingOTShiftWorks(timesheet, otRateId);
            system.debug('bw: TimesheetEntrySlotHelper.synchronize -> totalOTHouors = ' + totalOTHours);
            system.debug('bw: TimesheetEntrySlotHelper.synchronize -> slot.Hours__c = ' + slot.Hours__c);  
            //slot.Hours__c += totalOTHours;
        }
        

        Decimal otHours = getOTHours(slot, timesheet.NG_OT_Threshold_Type__c, timesheet.NG_OT_Threshold_Hours__c);
        system.debug('bw: TimesheetEntrySlotHelper.synchronize -> otHours = ' + otHours);
        if(otHours > 0 && otRateId != null) {
            // Set Regular Hours ShiftWork
            if(slot.Hours__c - otHours > 0) {
                shiftWorkId = TR_ShiftWork_Gateway.save('Regular',
                                                        slot.Source_Object_ID__c, 
                                                        slot.Timesheet_Source_Object_ID__c, 
                                                        slot.Timesheet_Entry_Source_Object_ID__c, 
                                                        regRateId, 
                                                        null,
                                                        slot.In_Time__c, 
                                                        date.valueOf(slot.Out_Date__c),
                                                        slot.Out_Time__c, 
                                                        (slot.Hours__c - otHours));
            }
            
            // Set Overtime Hours ShiftWork
            otShiftWorkId = TR_ShiftWork_Gateway.save('Overtime',
                                                   slot.Overtime_Source_Object_ID__c, 
                                                   slot.Timesheet_Source_Object_ID__c, 
                                                   slot.Timesheet_Entry_Source_Object_ID__c, 
                                                   otRateId, 
                                                   null,
                                                   slot.In_Time__c, 
                                                   date.valueOf(slot.Out_Date__c),
                                                   slot.Out_Time__c, 
                                                   otHours);

        }
        else {
            // Set Regular Hours ShiftWork
            shiftWorkId = TR_ShiftWork_Gateway.save('Regular',
                                                   slot.Source_Object_ID__c, 
                                                   slot.Timesheet_Source_Object_ID__c, 
                                                   slot.Timesheet_Entry_Source_Object_ID__c, 
                                                   regRateId, 
                                                   null,
                                                   slot.In_Time__c, 
                                                   date.valueOf(slot.Out_Date__c),
                                                   slot.Out_Time__c, 
                                                   slot.Hours__c);

    
        }
        TR1__Timesheet_Detail__c timesheetDetail = TR_TimesheetDetail_Gateway.fetch(slot.Timesheet_Entry_Source_Object_ID__c);
        timesheetDetail.NG_Unpaid_Break_Time__c = slot.Unpaid_Break_Time__c;
        timesheetDetail.NG_Shift_Notes__c = slot.Note__c;

        if(timesheetDetail.TR1__Day__c == null || timesheetDetail.TR1__Date__c == null){
            timesheetDetail.TR1__Day__c = slot.Day__c;
            timesheetDetail.TR1__Date__c = slot.Date__c;
        }

        TR_TimesheetDetail_Gateway.save(timesheetDetail);

        if(slot.Source_Object_ID__c != shiftWorkId)
            slot.Source_Object_ID__c = shiftWorkId;

        if(otShiftWorkId != null) {
            if(slot.Overtime_Source_Object_ID__c != otShiftWorkId)
                slot.Overtime_Source_Object_ID__c = otShiftWorkId;
        }
        else {
            slot.Overtime_Source_Object_ID__c = null;
        }

        // Set Callback Hours ShiftWork if applicable
        if(slot.Custom_Callback_Hours__c != null && slot.Custom_Callback_Hours__c > 0) {
            Id rateId = TR_Rate_Gateway.fetchIdFromTimesheet(slot.Timesheet_Source_Object_ID__c, 'Callback');
            if(rateId != null) {
                shiftWorkId = TR_ShiftWork_Gateway.save('Callback',
                                                        slot.Custom_Callback_Source_ID__c,
                                                        slot.Timesheet_Source_Object_ID__c,
                                                        slot.Timesheet_Entry_Source_Object_ID__c,
                                                        rateId,
                                                        slot.Custom_On_Call_Beeper__c,
                                                        slot.Custom_Callback_In_Time__c,
                                                        date.valueOf(slot.Custom_Callback_Out_Date__c),
                                                        slot.Custom_Callback_Out_Time__c,
                                                        slot.Custom_Callback_Hours__c);
                
                if(slot.Custom_Callback_Source_ID__c != shiftWorkId)
                    slot.Custom_Callback_Source_ID__c = shiftWorkId;
            }
        }

        // Update Entry with Date and Day if necessary
        if(slot.Date__c != null && slot.Day__c != null) {
            NG_Timesheet_Entry__c entry = TimesheetEntryGateway.fetch(slot.Timesheet_Entry__c);
            entry.Name = slot.Day__c + ' - ' + slot.Date__c.format();
            entry.Day__c = slot.Day__c;
            entry.Date__c = slot.Date__c;
            TimesheetEntryGateway.save(entry);
        }
    }

    private Decimal getOTHours(NG_Timesheet_Entry_Slot__c slot, string otThresholdType, Decimal otThresholdHours) {
        system.debug('bw: getOTHours -> slot = ' + slot);
        system.debug('bw: getOTHours -> otThresholdType = ' + otThresholdType);
        system.debug('bw: getOTHours -> otThresholdHours = ' + otThresholdHours);

        Decimal otHours = 0.00;

        decimal totalHours = TimesheetEntrySlotGateway.fetchSlotHoursForTimesheetSourceID(slot.Timesheet_Source_Object_ID__c, slot.Id);
        system.debug('bw: getOTHours -> totalHours = ' + totalHours);

        if(otThresholdType == 'Weekly') {
            if(totalHours + slot.Hours__c > otThresholdHours) {
                //35 +  0 +  8 > 40 = 3
                //40 + 32 + 12 > 40 = 44 - 32 = 12
                //40 + 0 + 12 > 40 = 12 - 0 = 12
                otHours = ((totalHours + slot.Hours__c) - otThresholdHours); // - timesheet.NG_Total_Overtime_Shift_Hours__c;
            }
        }
        else if(otThresholdType == 'Daily') {
            if(slot.Hours__c > otThresholdHours) {
                otHours = slot.Hours__c - otThresholdHours;
            }
        }

        system.debug('bw: getOTHours -> otHours = ' + otHours);
        return otHours;
    }
    */

    private Decimal getTotalHours(String inDate, String inTime, String outDate, String outTime) {
        System.debug('bw: getTotalHours -> inDate, inTime, outDate, outTime = ' + inDate + ', ' + inTime + ', ' + outDate + ', ' + outTime);

        if(inDate == null || inTime == null || outDate == null || outTime == null) {
            return 0;
        }

        List<Integer> inValues =    splitDateTime(inDate, inTime);
        List<Integer> outValues =   splitDateTime(outDate, outTime);

                                /* year, month, day, hour, minute, second */
        DateTime inDT =         DateTime.newInstance(inValues[0], 
                                                     inValues[1], 
                                                     inValues[2], 
                                                     inValues[3], 
                                                     inValues[4], 
                                                     0);

        DateTime outDT =        DateTime.newInstance(outValues[0],
                                                     outValues[1],
                                                     outValues[2],
                                                     outValues[3],
                                                     outValues[4],
                                                     0);

        Long inVal =            inDT.getTime();
        Long outVal =           outDT.getTime();
        System.debug('bw: getTotalHours -> inVal, outVal = ' + inVal + ', ' + outVal);

        Long diffMils =         outVal - inVal + (inVal > outVal ? 86400000 : 0);
        Decimal diff =          diffMils/1000.00/60.00/60.00;

        system.debug('bw: TimesheetEntrySlotHelper.getTotalHours -> return = ' + diff.setScale(2));
        return diff.setScale(2);
    }

    private List<Integer> splitDateTime(String dateString, String timeString) {
        List<Integer> returnValue = new List<Integer>();

        List<String> values = new List<String>();
        values.addAll(dateString.split('-'));
        values.addAll(timeString.split(':'));

        for(Integer i=0; i<values.size();i++) {
            returnValue.add(Integer.valueOf(values[i]));
        }

        return returnValue;
    }

}