/**
 * @author Jozef 
 * @date 18.2.2019.
 * @description //TODO
 */
({
    displayError: function(cmp, message) {
        console.log(message);
        var utilCmp = cmp.find("utilId");
        utilCmp.showError(message);
     },

     showSpinner: function(cmp) {
        var numOfRuns = cmp.get('v.numOfRuns');
        //console.log(numOfRuns);
        numOfRuns = numOfRuns + 1;
        cmp.set('v.numOfRuns', numOfRuns);
     },

        // this function automatic call by aura:doneWaiting event
     hideSpinner : function(cmp){
         var numOfRuns = cmp.get('v.numOfRuns');
         //console.log(numOfRuns);
         if (numOfRuns > 0){
            numOfRuns = numOfRuns - 1;
            cmp.set('v.numOfRuns', numOfRuns);
         }
     },

     handleError: function(cmp, response) {
        var utilCmp = cmp.find("utilId");
        utilCmp.handleError(response);
        this.hideSpinner(cmp);
     },

     setStartDateOptions: function(cmp){
        var plan = cmp.get("v.templatePlan");
        var startDayOptions= [
                    {'label': $A.get("$Label.c.AptOptionFiscalYearDate"), 'value': 'Fiscal_Year_Date'},
                    {'label': $A.get("$Label.c.AptOptionReportingDate"), 'value': 'Reporting_Date'},
                    {'label': $A.get("$Label.c.AptOptionPayrollDate"), 'value': 'Payroll_Date'},
                    {'label': $A.get("$Label.c.AptOptionReportingDatePlus"), 'value': 'Reporting_Date_Plus'},
                    {'label': $A.get("$Label.c.AptOptionReportingDatePlus2"), 'value': 'Reporting_Date_Plus_2'},
                    {'label': $A.get("$Label.c.AptOptionFiscalYearDatePlus2"), 'value': 'Fiscal_Year_End_Date_Plus_2'}
                    ];
        cmp.set("v.startDayOptions", startDayOptions);
        var startDayValue = 'Fiscal_Year_Date';
        if ($A.util.isEmpty(plan.Start_Date__c)){
            plan.Start_Date__c = startDayValue;
            cmp.set("v.templatePlan", plan);
        }
     },

    getTemplatePlanJs: function(cmp, event){
        this.showSpinner(cmp);
        var action = cmp.get("c.getTemplatePlan");
        action.setParams({ recordId :cmp.get('v.recordId')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var plan = response.getReturnValue();
                cmp.set("v.templatePlan", plan);
                this.setStartDateOptions(cmp);
                this.hideSpinner(cmp);
            }
            else if (state === "ERROR") {
                this.handleError(cmp, response);
            }
         });
         $A.enqueueAction(action);
     },

     getTemplateTasksJs : function(cmp, event){
        this.showSpinner(cmp);
        var action = cmp.get("c.getTasks");
        action.setParams({ apId :cmp.get('v.recordId')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tTasks = response.getReturnValue();
                cmp.set("v.tTasks", tTasks);
                console.log(JSON.stringify(cmp.get('v.tTasks')));
                this.hideSpinner(cmp);
            }
            else if (state === "ERROR") {
                this.handleError(cmp, response);
            }
         });
         $A.enqueueAction(action);
    },


     setNewPlan : function(cmp, tTasks){
        cmp.set("v.tTasks", tTasks);
        cmp.set("v.delTasks",[]);
        if (!$A.util.isEmpty(tTasks)){
            var task = tTasks[0];
            //console.log(JSON.stringify(task));
            //console.log('>>>>>>Saved record Id: ' + task.Action_Plan_Template__c);
            cmp.set('v.recordId',task.Action_Plan_Template__c);
        } 
     },

     savePlan : function(cmp, event){
        this.showSpinner(cmp);
        var action = cmp.get("c.savePlan");
        var tasks = cmp.get('v.tTasks');
        var dTasks = cmp.get('v.delTasks');
        if ($A.util.isEmpty(tasks)) {
            //console.log('>>>>>EMPTY');
            this.hideSpinner(cmp);
            cmp.set("v.hasError", true);
            var toastEvent = $A.get("e.force:showToast")
            toastEvent.setParams({
                    message: 'Record not saved. Tasks are required!',
                    type: 'ERROR'
            });
            toastEvent.fire();
        } else {
            cmp.set("v.hasError", false);
            //console.log('savePlan');
            //console.log(tasks);
         
            action.setParams({ tId :cmp.get('v.recordId'),
                               tPlan: cmp.get('v.templatePlan'),
                               tTasksJSON: JSON.stringify(tasks),
                               delTasksJSON: JSON.stringify(dTasks)} );
    
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var tTasks = response.getReturnValue();
                    this.setNewPlan(cmp, tTasks);
                    this.hideSpinner(cmp);
                    var urlEvent = $A.get("e.force:navigateToURL");
                    //console.log('>>>>>Navigate: ' + cmp.get('v.recordId'))
                    urlEvent.setParams({
                        "url": "/" + cmp.get('v.recordId')
                    });
                    urlEvent.fire();
                    var toastEvent = $A.get("e.force:showToast")
            		toastEvent.setParams({
                    message: 'Record saved successfully!',
                    type: 'SUCCESS'
            });
            toastEvent.fire();
                }
                else if (state === "ERROR") {
                    this.handleError(cmp, response);
                }
             });
             $A.enqueueAction(action);
         }
    },

    getLastIndex: function(cmp, tTasks){
         var utilCmp = cmp.find("utilId");
         return utilCmp.getLastIndex(tTasks);
    },

    addRow: function(cmp, event){
        this.showSpinner(cmp);
        var tTasks = cmp.get('v.tTasks');
        var action = cmp.get("c.getNewTemplatePlanTask");
        action.setParams({ index : this.getLastIndex(cmp, tTasks)} );
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tTask = response.getReturnValue();
                tTask.Id = null;
                //console.log(JSON.stringify(tTask));
                if(!$A.util.isEmpty(tTask)){
                    var tTasks = cmp.get("v.tTasks");
                    tTasks.push(tTask);
                    cmp.set("v.tTasks", tTasks);
                }
                //console.log(cmp.get('v.tTasks'));
                this.hideSpinner(cmp);
            }
            else if (state === "ERROR") {
                this.handleError(cmp, response);
            }
         });
         $A.enqueueAction(action);
    },
    
    deleteRecord: function (cmp) {
        var modalBody;
        var modalFooter;
        var sobjectLabel = 'Action Plan Template'
        var recordId = cmp.get('v.recordId')
        //console.log('>>>>>>deleted record Id: ' + cmp.get('v.recordId'));
            
        $A.createComponents([
            ["c:AptDeleteRecordContent",{sobjectLabel:sobjectLabel}],
            ["c:AptDeleteRecordFooter",{recordId: recordId, sobjectLabel:sobjectLabel}]
        ],
        function(components, status){
            if (status === "SUCCESS") {
                modalBody = components[0];
                modalFooter = components[1];
                cmp.find('overlayLib').showCustomModal({
                   header: "Delete " + sobjectLabel,
                   body: modalBody, 
                   footer: modalFooter,
                   showCloseButton: true
               })
            }
        }
       );
    },

     skipWeekend: function(cmp, skip){
         var utilCmp = cmp.find("utilId");
         var tasks = cmp.get("v.tTasks");
         if(!$A.util.isEmpty(tasks)){
             for (var i = 0; i < tasks.length; i++) {
                 var task = tasks[i];
                 task.Skip_Weekends__c = skip;
                 utilCmp.skipWeekend(task, skip);
             }
             cmp.set("v.tTasks",tasks);
         }
     },

})