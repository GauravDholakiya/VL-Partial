/**
 * Created by jozef on 4. 4. 2023.
 */

({
    init : function(cmp, event, helper){
        helper.setButtonColor(cmp);
    },

    editPeriods: function(cmp, event, helper) {
         let aptEditPeriodsPressedEvt = $A.get("e.c:AptEditPeriodsPressedEvt");
         let tabIndex = cmp.get('v.apTask.taskIndex__c');
         aptEditPeriodsPressedEvt.setParams({ "tabIndex" : tabIndex });
         aptEditPeriodsPressedEvt.fire();
    },

    recalculateButtonColor: function(cmp, event, helper){
        helper.recalculateButtonColor(cmp);
    },
});