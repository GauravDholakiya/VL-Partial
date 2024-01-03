/**
 * @author Jozef 
 * @date 11.2.2019.
 * @description //TODO
 */
({
    showInfoToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info Message',
            message: 'Mode is dismissible ,duration is 5sec and this is normal Message',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 5000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Mode is pester ,duration is 5sec and this is normal Message',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },

    showErrorToast : function(component, event, helper) {
        var params = event.getParam('arguments');
        var mess = '';
        if (params) {
            mess = params.message;
        }
        helper.showError(mess);
        /*
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: mess,
            key: 'info_alt',
            type: 'error',
            mode: 'sticky'
        });
        toastEvent.fire();
        */
    },

    /*
    showError: function(aMessage){
         var toastEvent = $A.get("e.force:showToast");
         toastEvent.setParams({
            title : 'Error',
            message: aMessage,
            key: 'info_alt',
            type: 'error',
            mode: 'sticky'
         });
         toastEvent.fire();
    },
    */


    showWarningToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warning',
            message: 'Mode is pester ,duration is 5sec and normal message',
            messageTemplate: 'Mode is sticky ,duration is 5sec and Message is overrriden because messageTemplateData is {1}',
            messageTemplateData: ['Salesforce', {
                url: 'http://www.webkul.com/',
                label: 'Click Here',
            }],
            duration:' 5000',
            key: 'info_alt',
            type: 'warning',
            mode: 'sticky'
        });
        toastEvent.fire();
    },

    getLastIndexOfTasks: function(component, event, helper){
        var params = event.getParam('arguments');
        var tasks = [];
        if (params) {
           tasks = params.tasks;
        }

        var index = '0';
        if ($A.util.isEmpty(tasks)){
            return index;
        }
        //console.log('getLastIndexOfTasks');
        //console.log(JSON.stringify(tasks));
        var lastApTask = tasks[tasks.length -1];
        var tIndex = lastApTask.taskIndex__c;
        if (!$A.util.isEmpty(tIndex)){
            tIndex = tIndex +1
            index = tIndex.toString();
        }
        return index;
    },



    handleErrorMessage: function(component, event, helper){
        var response = helper.getArgument(event, 'response');
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                var em = errors[0].message;
                helper.showError(em);
            }
        } else {
            console.log("Unknown error");
        }
    },


    setPeriods:  function(component, event, helper){
         var params = event.getParam('arguments');
         var fiscalYear;
         var apt;
         var initDate;
         if (params) {
             fiscalYear = params.fiscalYear;
             apt = params.apt;
             initDate = params.initDate;
         }

        helper.setPeriods(fiscalYear, apt, initDate);
    },

    setNewPeriods:  function(component, event, helper){
          var params = event.getParam('arguments');
          var fiscalYear;
          var apt;
          var initDate;
          if (params) {
              fiscalYear = params.fiscalYear;
              apt = params.apt;
              initDate = params.initDate;
          }

         helper.setNewPeriods(fiscalYear, apt, initDate);
     },

    setStaticPeriods : function(component, event, helper){
        var params = event.getParam('arguments');
        var apt;
        if (params) {
            apt = params.apt;
        }
        helper.setStaticPeriods(apt);
    },

    findByNameAndNumber: function(component, event, helper){
       var params = event.getParam('arguments');
       var tasks;
       var searchKey;
       if (params) {
           tasks = params.tasks;
           searchKey = params.searchKey
       }
       helper.findByNameAndNumber(searchKey, tasks);
    },

    filterByKeyword: function(component, event, helper){
       var params = event.getParam('arguments');
       var tasks;
       var searchKey;
       if (params) {
           tasks = params.tasks;
           searchKey = params.searchKey
       }
       helper.filterByKeyword(searchKey, tasks);
    },

    skipWeekend:function(component, event, helper){
       var params = event.getParam('arguments');
       var tasks;
       if (params) {
           tasks = params.tasks;
           skip = params.skip;
       }
       helper.skipWeekend(tasks, skip);
    },

})