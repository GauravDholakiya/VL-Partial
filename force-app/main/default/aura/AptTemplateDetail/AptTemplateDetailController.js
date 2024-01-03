/**
 * @author Jozef 
 * @date 18.2.2019.
 * @description //TODO
 */
({
    doInit : function(cmp, event, helper) {
        //cmp.set("v.mode", 'VIEW');
        var recordId = cmp.get('v.recordId');
        if (!$A.util.isEmpty(recordId)){
            helper.getTemplatePlanJs(cmp, event);
            helper.getTemplateTasksJs(cmp, event);
        }else{
            helper.getTemplatePlanJs(cmp, event);
        }
    },

    doEdit : function(cmp, event, helper) {
        cmp.set("v.mode", 'EDIT');

    },

    doSave : function(cmp, event, helper) {
        //console.log('tempSavePressed');
        var tTasks = cmp.get('v.tTasks');
        //console.log(JSON.stringify(tTasks));
        //cmp.set("v.mode",'VIEW');
        helper.savePlan(cmp, event);
    },

    doRetry : function(cmp, event, helper) {


    },

    doCancel : function(cmp, event, helper) {
        cmp.set("v.mode", 'VIEW');
        helper.getTemplatePlanJs(cmp, event);
        helper.getTemplateTasksJs(cmp, event);
    },

    doDelete: function(cmp, event, helper) {
        //console.log('>>>>>>DELETE');
        helper.deleteRecord(cmp);
            //cmp.set("v.mode", 'VIEW');
    },

    handleAddRow: function(cmp, event, helper) {
        //cmp.set("v.mode", 'VIEW');
        helper.addRow(cmp, event);
    },

    skipWeekendChange : function(cmp, event, helper) {
        //console.log('skipWeekendChange');
        var skip = cmp.get('v.templatePlan.SkipWeekends__c');
        //var periodDate = '2019-06-23';
        helper.skipWeekend(cmp, skip);
   },


})