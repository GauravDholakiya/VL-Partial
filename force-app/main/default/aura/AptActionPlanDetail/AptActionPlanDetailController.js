/**
 * @author Jozef 
 * @date 23.1.2019.
 * @description //TODO
 */
({
   doInit : function(cmp, event, helper) {
        //cmp.set("v.mode", 'VIEW');
        //if (!$A.util.isEmpty(cmp.get('v.recordId'))){
        //    helper.setObjectData(cmp, event);
        //}
        helper.setContractAndTasks(cmp, event);

    },

    doEdit : function(cmp, event, helper) {
        cmp.set("v.mode", 'EDIT');

    },

    doSave : function(cmp, event, helper) {
        //var aptId =event.currentTarget.getAttribute("data-row-id");
        //var aptSavePressed = $A.get("e.c:AptActionPlanSavePressedEvt");
        //aptCommentsAttEvent.setParams({ "aptId": aptId ,"comments": aptComments });
        //aptSavePressed.fire();
        //console.log('aptSavePressed');
        var apTasks = cmp.get('v.apTasks');
        //console.log(JSON.stringify(apTasks));
        cmp.set("v.mode",'VIEW');
        helper.savePlan(cmp, event);
    },

    doRetry : function(cmp, event, helper) {


    },

    doCancel : function(cmp, event, helper) {
        cmp.set("v.mode", 'VIEW');
        helper.getTasksJs(cmp, event);
    },

    doDelete: function(cmp, event, helper) {
        helper.deleteRecord(cmp);
            //cmp.set("v.mode", 'VIEW');
    },

    /*
    handleAddRow: function(cmp, event, helper) {
        console.log('handleAddRow');
        //cmp.set("v.mode", 'VIEW');
        helper.addRow(cmp, event);
    },
    */

   skipWeekendChange : function(cmp, event, helper) {
        //console.log('skipWeekendChange');
        var skip = cmp.get('v.actionPlan.SkipWeekends__c');
        //var periodDate = '2019-06-23';
        helper.skipWeekend(cmp, skip);
   },

   handleUploadTasks: function(cmp, event, helper) {
        //console.log('handleUploadTasks');
        helper.openModal(cmp, event);
        //cmp.set("v.mode", 'VIEW');
        //helper.addRow(cmp, event);
   },

   handleUploadTasksEvent: function(cmp, event, helper) {
       //console.log('handleUploadTasksEvent');
       var selectedTasks = event.getParam("selectedTasks");
       //console.log('selected task-->' + selectedTasks);
       if(!$A.util.isEmpty(selectedTasks)){
           helper.addAdditionalTasks(cmp, selectedTasks);
       }
   },

    /*
    apTasksChange: function(cmp, evt, helper) {
        var apTasks = cmp.get('v.apTasks');
        helper.setVisibility(cmp, apTasks);
        //console.log("numItems has changed");
        //console.log("old value: " + evt.getParam("oldValue"));
        //console.log("current value: " + evt.getParam("value"));
    },
    */


})