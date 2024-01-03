/**
 * @author Jozef 
 * @date 24.1.2019.
 * @description //TODO
 */
({

    onRowClick : function(cmp, event, helper) {
       var aptId = event.currentTarget.getAttribute("data-row-id");
       var headerId =event.currentTarget.getAttribute("data-header-id");
       var aptIndex =  event.currentTarget.getAttribute("data-index");
       cmp.set("v.tableIndex", aptIndex);
       cmp.set("v.headerId", headerId);
       cmp.set("v.aptId", aptId);
       helper.fireRowClickEvent(headerId, aptIndex);
    },

   handleUploadFinished: function(cmp, event, helper) {
       var uploadedFiles = event.getParam("files");
       if (!$A.util.isEmpty(uploadedFiles)){
           var filesJSON = JSON.stringify(uploadedFiles);
           var attachmentheaderId = event.getSource().get("v.recordId");
           helper.saveAttachments(cmp, attachmentheaderId, filesJSON);
       }
   },


    handleChangeFrequency: function(cmp, event, helper) {
         var aptIndex = event.getSource().get("v.tabindex");
         var value = event.getSource().get("v.value");
         helper.onChangeFrequency(cmp, aptIndex, value);
         helper.recalculateStandardTasksAfterChange(cmp, aptIndex);
    },

   deleteRow: function(cmp, event, helper) {
        var taskIndex = event.getSource().get("v.tabindex");
        var apTasks = cmp.get('v.apTasks');
        helper.deleteRow(cmp, taskIndex);
   },

   editPeriods: function(cmp, event, helper) {
       //console.log('editPeriods');
       let tabIndex = event.getParam("tabIndex");
       //console.log('tabIndex-->' + tabIndex);
       if(!$A.util.isEmpty(tabIndex)){
           helper.editPeriods(cmp, tabIndex);
           //helper.recalculateStandardTasksAfterChange(cmp, tabIndex);
       }
   },

   /*
   editPeriods: function(cmp, event, helper) {
      let taskIndex = event.getSource().get("v.tabindex");
      helper.editPeriods(cmp, taskIndex);
   },
   */

   searchKeyChange : function(component, event, helper){
       helper.findByName(component,event);
   },

   sortByNumber: function(cmp, event, helper) {
        var field = event.currentTarget.getAttribute("data-sort-field");
        helper.sortByNumber(cmp, field);
   },

   sortBy : function(cmp, event, helper) {
        var field = event.currentTarget.getAttribute("data-sort-field");
        helper.sortBy(cmp, field);
   },

   sortByName: function(cmp, event, helper) {
        var field = event.currentTarget.getAttribute("data-sort-field");
        helper.sortByName(cmp, field);
   },

   sortByCheckBox: function(cmp, event, helper) {
        var field = event.currentTarget.getAttribute("data-sort-field");
        helper.sortByCheckBox(cmp, field);
   },

   skipWeekendsTask: function(cmp, event, helper) {
       var taskIndex = event.getSource().get("v.tabindex");
       var skip = event.getSource().get("v.checked");
       helper.skipWeekendsTask(cmp, taskIndex, skip);
   },

   firstPeriodChanged: function(cmp, event, helper) {
        let firstPeriodDate = event.getParam("firstPeriodDate");
        let periodColumn = event.getParam("periodColumn");
        let taskIndex = event.getParam("taskIndex");
        helper.changedFirstPeriodAndDay(cmp, firstPeriodDate, periodColumn, taskIndex);
        helper.recalculateStandardTasksAfterChange(cmp, taskIndex);
        //console.log(firstPeriodDate);
   },

   editPeriodsSavePressed: function(cmp, event, helper) {
        let taskIndex = event.getSource().get("v.taskIndex");
        helper.recalculateStandardTasksAfterChange(cmp, taskIndex);
   },
})