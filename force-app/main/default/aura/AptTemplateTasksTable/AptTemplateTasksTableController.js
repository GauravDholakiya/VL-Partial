/**
 * @author Jozef 
 * @date 24.1.2019.
 * @description //TODO
 */
({

    /*
    modeChange: function(cmp, evt, helper) {
        helper.changeSwitchButtonStyle(cmp, evt);
    },
    */

    doInit : function(cmp, event, helper) {
    	helper.initRolePicklistValues(cmp);
    	helper.initInitialStartDatePicklistValues(cmp);
    },

    onRowClick : function(cmp, event, helper) {
       var tId = event.currentTarget.getAttribute("data-row-id");
       var headerId = event.currentTarget.getAttribute("data-header-id");
       var tIndex =  event.currentTarget.getAttribute("data-index");
       cmp.set("v.tableIndex", tIndex);
       cmp.set("v.headerId", headerId);
       cmp.set("v.tId", tId);
       helper.fireRowClickEvent(headerId, tIndex);
   },

   handleUploadFinished: function(cmp, event, helper) {
       var uploadedFiles = event.getParam("files");
       //console.log("Files uploaded : " + uploadedFiles.length);
       //console.log(JSON.stringify(uploadedFiles));
       if (!$A.util.isEmpty(uploadedFiles)){
           var filesJSON = JSON.stringify(uploadedFiles);
           var attachmentheaderId = event.getSource().get("v.recordId");
           helper.saveAttachments(cmp, attachmentheaderId, filesJSON);
       }
   },

   deleteRow: function(cmp, event, helper) {
        var taskIndex = event.getSource().get("v.tabindex");
        //var tTasks = cmp.get('v.tTasks');
        //console.log(tTasks);
        helper.deleteRow(cmp, taskIndex);

   },


   searchKeyChange : function(component, event, helper){
       helper.findByName(component,event);
   },

   sortByNumber: function(cmp, event, helper) {
        var field = event.currentTarget.getAttribute("data-sort-field");
        helper.sortByNumber(cmp, field);
   },

   sortBy : function(cmp, event, helper) {
        var field = event.currentTarget.getAttribute("data-sort-field");
        //console.log('Sort by ' + field);
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

})