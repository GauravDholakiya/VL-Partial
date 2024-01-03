/**
 * Created by jozef on 4. 4. 2023.
 */

({
     setFirstPeriodDate : function(cmp){
         let firstPeriodDate = null;
         let periodColumn = null;
         let periodName = null;
         let apTask = cmp.get('v.apTask');
         if(!$A.util.isEmpty(apTask)){
             for (var i = 1; i <= 12; i++) {
                 periodColumn = 'Period_'+ i +'__c';
                 let periodVal = apTask[periodColumn];
                 if(!$A.util.isEmpty(periodVal)){
                     periodName = 'P'+i;
                     firstPeriodDate = periodVal;
                     break;
                 }
             }
         }
         /*
         if (apTask){

            firstPeriodDate = apTask.Period_1__c;
         }*/
         cmp.set('v.periodName', periodName);
         cmp.set('v.firstPeriodDate', firstPeriodDate);
         cmp.set('v.periodColumn', periodColumn);
     },

     sendFirstPeriodDateChangedEvt : function(cmp){
        //console.log('sendFirstPeriodDateChangedEvt');
        let periodColumn = cmp.get('v.periodColumn');
        let firstPeriodDate = cmp.get('v.firstPeriodDate');
        let taskIndex = cmp.get('v.taskIndex');
        let aptFirstPeriodChangedEvt = $A.get("e.c:AptFirstPeriodChangedEvt");
        aptFirstPeriodChangedEvt.setParams({
            "firstPeriodDate" : firstPeriodDate,
            "periodColumn" : periodColumn,
            "taskIndex" : taskIndex
        });
        aptFirstPeriodChangedEvt.fire();
     }
});