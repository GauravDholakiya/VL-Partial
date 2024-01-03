/**
 * @author Jozef 
 * @date 23.1.2019.
 * @description //TODO
 */
({

     displayError: function(cmp, message) {
        console.log(message);
        var utilCmp = cmp.find("utilId");
        utilCmp.showError(message);
     },

     showSpinner: function(cmp) {
        // make Spinner attribute true for display loading spinner
        //cmp.set("v.spinner", true);
        var numOfRuns = cmp.get('v.numOfRuns');
        //console.log(numOfRuns);
        numOfRuns = numOfRuns + 1;
        //console.log('showSpinner2');
        //console.log(numOfRuns);
        cmp.set('v.numOfRuns', numOfRuns);
     },

        // this function automatic call by aura:doneWaiting event
     hideSpinner : function(cmp){
         var numOfRuns = cmp.get('v.numOfRuns');
         //console.log('hideSpinner');
         //console.log(numOfRuns);
         if (numOfRuns > 0){
            numOfRuns = numOfRuns - 1;
            cmp.set('v.numOfRuns', numOfRuns);
         }
        // make Spinner attribute to false for hide loading spinner
        //cmp.set("v.spinner", false);
     },

     handleError: function(cmp, response) {
        this.hideSpinner(cmp);
        var utilCmp = cmp.find("utilId");
        utilCmp.handleError(response);
     },

     getTasksJs : function(cmp, event){
        this.showSpinner(cmp);
        var action = cmp.get("c.getTasks");
        action.setParams({ apId :cmp.get('v.recordId')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var apTasks = response.getReturnValue();
                if(!$A.util.isEmpty(apTasks)){
                    this.setApTasks(cmp, apTasks);
                    //console.log('SET TASK');
                }
                this.setTasksReference(cmp, apTasks);
                //this.setVisibility(cmp, apTasks);
                //console.log(JSON.stringify(cmp.get('v.apTasks')));
                //cmp.set('v.dataLoaded', true);
                this.setObjectData(cmp, event, true);
                this.hideSpinner(cmp);
            }

            else if (state === "ERROR") {
                this.handleError(cmp, response);
            }
         });
         $A.enqueueAction(action);
     },

    extendApTasks : function(apTasks, stTasks){
        apTasks.forEach((item) => {
            let aptId = item.Id;
            item.standardTasks = {};
            //console.log(aptId);
            let sTask = stTasks.find(element => element.id == aptId);
            if(sTask){
                this.extendApTask(item, sTask)
            }
            //console.log(sTask);
        });
    },

    extendApTask : function(apTask, stTask){
        //apTask.task_1 = {task}
        stTask.tasks.forEach((element) => {
            apTask.standardTasks["task_" + element.Period__c] = element;
            let periodField = 'P' + element.Period__c + 'static';
            apTask[periodField] = false;
            if (element.Status == 'Completed'){
                apTask[periodField] = true;
            }
        });
    },

    setTasksReference : function(cmp, apTasks){
        this.showSpinner(cmp);
        var action = cmp.get("c.getStandardTasks");
        action.setParams({ apId :cmp.get('v.recordId')});

        action.setCallback(this, function(response) {
            let stTasks;
            var state = response.getState();
            if (state === "SUCCESS") {
                stTasks = response.getReturnValue();
                if(!$A.util.isEmpty(stTasks)){
                    this.extendApTasks(apTasks, stTasks);
                }
                console.log(JSON.stringify(apTasks));
                cmp.set("v.apTasks", apTasks);
                this.hideSpinner(cmp);
            }
            else if (state === "ERROR") {
                this.handleError(cmp, response);
            }
         });
         $A.enqueueAction(action);
     },


     getNewTasksJs : function(cmp, event){
         this.showSpinner(cmp);
         var action = cmp.get("c.getNewTasks");
         action.setParams({ contractId :cmp.get('v.contractId')});

         action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {
                 var apTasks = response.getReturnValue();
                 if(!$A.util.isEmpty(apTasks)){
                     this.setNewApTasks(cmp, apTasks);
                 }
                 cmp.set("v.apTasks", apTasks);
                 this.setObjectData(cmp, event, false);

                 this.hideSpinner(cmp);
             }

             else if (state === "ERROR") {
                 this.handleError(cmp, response);
             }
          });
          $A.enqueueAction(action);
      },

      getClonedTasksJs : function(cmp, event){
        this.showSpinner(cmp);
        var action = cmp.get("c.copyTasks");
        action.setParams({ contractId :cmp.get('v.contractId'),
                            fiscalYear :cmp.get('v.fiscalYear')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var apTasks = response.getReturnValue();
                if(!$A.util.isEmpty(apTasks)){
                    this.setApTasks(cmp, apTasks);
                    this.clearAllStaticPeriods(apTasks);
                }
                cmp.set("v.apTasks", apTasks);
                this.setObjectData(cmp, event, false);
                this.hideSpinner(cmp);
            }

            else if (state === "ERROR") {
                this.handleError(cmp, response);
            }
         });
         $A.enqueueAction(action);
     },

    clearAllStaticPeriods: function(apTasks){
         for (var i = 0; i < apTasks.length; i++) {
               var apTask = apTasks[i];
               this.clearStaticPeriods(apTask);
         }
    },

    clearStaticPeriods:  function(apt){
        apt.P1static = false;
        apt.P2static = false;
        apt.P3static = false;
        apt.P4static = false;
        apt.P5static = false;
        apt.P6static = false;
        apt.P7static = false;
        apt.P8static = false;
        apt.P9static = false;
        apt.P10static = false;
        apt.P11static = false;
        apt.P12static = false;
    },

    setStartingDates : function(cmp, parContract, fiscalYear ){
         var startDay, startMonth, startYear;
         var startDayR, startMonthR;
         var startDayP, startMonthP;
         var endDay, endMonth;
         var initTaskDate, initPayrollDate, initReportingDate, initEndDate, initCloseDate, initYearEndReportingDate;
         var startDayCloseDate, startMonthCloseDate, startDayYearEndReportingDate, startMonthYearEndReportingDate;
         var initDate = {};

         startDay = 1;
         startDayP = 1;
         startDayR = 1;
         endDay = 1;
         startDayCloseDate = 1;
         startDayYearEndReportingDate = 1;

         startMonthR = 0;
         startMonthP = 0;
         endMonth = 0;
         startMonthCloseDate = 0;
         startMonthYearEndReportingDate = 0;

         if( parContract != null && parContract.PayrollDate__c != null){
            startDayP = new Date(parContract.PayrollDate__c).getDate();
            startMonthP = new Date(parContract.PayrollDate__c).getMonth();
         }

         if( parContract != null && parContract.ReportingDate__c != null){
            startDayR = new Date(parContract.ReportingDate__c).getDate();
            startMonthR = new Date(parContract.ReportingDate__c).getMonth();
         }

         if( parContract != null && parContract.FiscalYearStart__c != null){
             //startDay = moment(parContract.FiscalYearStart__c);
             startDay = new Date(parContract.FiscalYearStart__c).getDate();
         }
         if( parContract != null && parContract.StartDate__c != null ){
             //startDay = moment(parContract.StartDate__c, 'D');
             startDay = new Date(parContract.StartDate__c).getDate();
         }
         if( parContract != null && parContract.CloseDate__c != null){
             startDayCloseDate = new Date(parContract.CloseDate__c).getDate();
             startMonthCloseDate = new Date(parContract.CloseDate__c).getMonth();
         }
         if( parContract != null && parContract.Year_end_reporting_date__c != null){
             startDayYearEndReportingDate = new Date(parContract.Year_end_reporting_date__c).getDate();
             startMonthYearEndReportingDate = new Date(parContract.Year_end_reporting_date__c).getMonth();
         }

         // Custom fiscal year
         // if blank Period 1 = January, if not blank, Period 1 = date month.
         startMonth = 0;
         if(parContract != null && parContract.FiscalYearStart__c != null){
             //startMonth = moment(parContract.StartDate__c, 'M');
             startMonth = new Date(parContract.FiscalYearStart__c).getMonth();
         }

         if( fiscalYear != null ) {
             startYear = parseInt(fiscalYear);
         }
         if (parContract != null && parContract.Fiscal_Year_End__c != null) {
            endDay = new Date(parContract.Fiscal_Year_End__c).getDate();
            endMonth = new Date(parContract.Fiscal_Year_End__c).getMonth();
         } else if (parContract != null && parContract.Fiscal_Year_End__c == null) {
            endDay = 31;
            
            //Commented by Sushant - Incident Handling Friday 27 May 2022
            //endMonth = 12;
            endMonth = 11;

        }

         //console.log(startDay + ':'+ startMonth + ':' + startYear);
         //initTaskDate = moment(startDay + '.'+ startMonth + '.' + startYear);
         initTaskDate = new Date(startYear, startMonth, startDay, 0, 0, 0, 0);
         initPayrollDate = new Date(startYear, startMonthP, startDayP, 0, 0, 0, 0);
         initReportingDate = new Date(startYear, startMonthR, startDayR, 0, 0, 0, 0);
         initEndDate = new Date(startYear, endMonth, endDay, 0, 0, 0, 0);
         initCloseDate = new Date(startYear, startMonthCloseDate, startDayCloseDate, 0, 0, 0, 0);
         initYearEndReportingDate = new Date(startYear, startMonthYearEndReportingDate,
            startDayYearEndReportingDate, 0, 0, 0, 0);

         initDate.initTaskDate = initTaskDate;
         initDate.initPayrollDate = initPayrollDate;
         initDate.initReportingDate = initReportingDate;
         initDate.initEndFiscalYear = initEndDate;
         initDate.initCloseDate = initCloseDate;
         initDate.initYearEndReportingDate = initYearEndReportingDate;
         cmp.set('v.initDate', initDate);
         //console.log('COMP initDate ----> ' + initDate.initTaskDate);
     },

     setApTasks : function(cmp, apTasks){
        var utilCmp = cmp.find("utilId");
        for (var i = 0; i < apTasks.length; i++) {
            var apTask = apTasks[i];
            utilCmp.setStaticPeriods(apTask);
        }
     },

     setNewApTasks : function(cmp, apTasks){
        var fiscalYear = cmp.get('v.fiscalYear');
        var initDate = cmp.get('v.initDate');
        //console.log('initDate-->'+JSON.stringify(initDate));
        var utilCmp = cmp.find("utilId");
        for (var i = 0; i < apTasks.length; i++) {
            var apTask = apTasks[i];
            //utilCmp.setStaticPeriods(apTask);
            utilCmp.setNewPeriods(fiscalYear, apTask, initDate);
            if (apTask.Skip_Weekends__c == true){
                utilCmp.skipWeekend(apTask, true);
            }
            //console.log('i-->'+i);
        }
     },

     skipWeekend: function(cmp, skip){
         var utilCmp = cmp.find("utilId");
         var tasks = cmp.get("v.apTasks");
         //console.log('SKIP' + JSON.stringify(tasks));
         if(!$A.util.isEmpty(tasks)){
             for (var i = 0; i < tasks.length; i++) {
                 var task = tasks[i];
                 task.Skip_Weekends__c = skip;
                 utilCmp.skipWeekend(task, skip);
             }
             cmp.set("v.apTasks",tasks);
         }
     },

     setNewPlan : function(cmp, apTasks){
        this.setApTasks(cmp, apTasks);
        cmp.set("v.apTasks", apTasks);
        cmp.set("v.delTasks",[]);
        if (!$A.util.isEmpty(apTasks)){
            var task = apTasks[0];
            //console.log('task.Action_Plan__c' + task.Action_Plan__c);
            cmp.set('v.recordId',task.Action_Plan__c);
            //console.log('v.recordId set' + task.Action_Plan__c);
        }
     },

     savePlan : function(cmp, event){
        this.showSpinner(cmp);
        var action = cmp.get("c.savePlan");
        var tasks = cmp.get('v.apTasks');
        var dTasks = cmp.get('v.delTasks');
        var contract = cmp.get('v.contractId');
        var fYear = cmp.get('v.fiscalYear');
        var plan = cmp.get('v.actionPlan');
        //console.log('savePlan');
        this.prepareSave(tasks);
        this.prepareSave(dTasks);
        //console.log(tasks);
        action.setParams({ apId :cmp.get('v.recordId'),
                           apTasksJSON: JSON.stringify(tasks),
                           delTasksJSON: JSON.stringify(dTasks),
                           contractId: contract,
                           fiscalYear: fYear,
                           planName: cmp.get('v.actionPlanName'),
                           skipWeekend: plan.SkipWeekends__c});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var apTasks = response.getReturnValue();
                this.setTasksReference(cmp, apTasks);
                this.setNewPlan(cmp, apTasks);
                this.setObjectData(cmp, event, false);
                this.hideSpinner(cmp);
            }
            else if (state === "ERROR") {
               this.handleError(cmp, response);
            }
         });
         $A.enqueueAction(action);
    },

    prepareSave: function(tasks){
        if(!$A.util.isEmpty(tasks)){
            for (var i = 0; i < tasks.length; i++) {
                var task = tasks[i];
                delete task.ActionPlanTemplate__r;
                delete task.standardTasks;
            }
        }
    },

    getLastIndex: function(cmp, apTasks){
        var utilCmp = cmp.find('utilId');
        return utilCmp.getLastIndex(apTasks);
    },


    /*
    addRow: function(cmp, event){
        this.showSpinner(cmp);
        //Is it working??? TODO Check spinner TODO each function has to return TASKS!!!

        var apTasks = cmp.get('v.apTasks');
        var action = cmp.get("c.getNewTemplateTask");
        action.setParams({ index : this.getLastIndex(cmp, apTasks)} );
        action.setCallback(this, function(response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var apTask = response.getReturnValue();
                apTask.Id = null;
                console.log(JSON.stringify(apTask));
                if(!$A.util.isEmpty(apTask)){
                    var apTasks = cmp.get("v.apTasks");
                    apTasks.push(apTask);
                    cmp.set("v.apTasks", apTasks);
                    console.log(apTask);
                }
                this.hideSpinner(cmp);
            }
            else if (state === "ERROR") {
               this.handleError(cmp, response);
            }
         });
         $A.enqueueAction(action);
    },
    */

    setObjectData : function(cmp, event, setName){
        //console.log('getActionPlan');
        var action = cmp.get("c.getActionPlan");
        action.setParams({ apId :cmp.get('v.recordId')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                //console.log(record);
                cmp.set('v.actionPlan',record);
                if (setName == true){
                    cmp.set('v.actionPlanName', record.Name);
                    /*
                    if (record.SkipWeekends__c == true){
                        this.skipWeekend(cmp, record.SkipWeekends__c);
                    }
                    */
                }
                //cmp.set("v.record", record);
                //this.setLabel(cmp, record);
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var em = errors[0].message;
                            this.displayError(cmp, em);
                        }
                    } else {
                        console.log("Unknown error");
                    }

             }
         });
         $A.enqueueAction(action);
    },

    setStartingPeriod : function(cmp){
        var fiscalYear = cmp.get('v.fiscalYear');
        var parContract = cmp.get('v.contract');
        this.setStartingDates(cmp, parContract, fiscalYear );
    },

    setContractAndTasks : function(cmp, event){
        //console.log('setContractAndTasks -->' + cmp.get('v.contractId'));
        var action = cmp.get("c.getContract");
        action.setParams({ contractId :cmp.get('v.contractId')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                cmp.set('v.contract',record);
                this.setStartingPeriod(cmp);
                if (!$A.util.isEmpty(cmp.get('v.recordId'))){
                    //this.setObjectData(cmp, event, true);
                    this.getTasksJs(cmp, event);
                }else{
                    //this.setObjectData(cmp, event, false);
                    if (cmp.get("v.cloneExisting") == false) {
                        this.getNewTasksJs(cmp, event);
                        this.setActionPlanName(cmp, record);
                    } else {
                        this.getClonedTasksJs(cmp, event);
                        this.setActionPlanName(cmp, record);
                    }
                    
                }
                //cmp.set("v.record", record);
                //this.setLabel(cmp, record);
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var em = errors[0].message;
                            this.displayError(cmp, em);
                        }
                    } else {
                        console.log("Unknown error");
                    }

             }
         });
         $A.enqueueAction(action);
    },

    setActionPlanName: function(cmp, contract){
        //CustomerName + Year + [Implementation/Operational]
        var apName;
        var customerName = this.getShortNameOfAccount(contract.Account__r.Name);
        apName = customerName + ' ' + cmp.get('v.fiscalYear') + ' ' + contract.RecordType.Name;
        cmp.set('v.actionPlanName', apName);
    },

    getShortNameOfAccount: function(aName){
        var newName = aName;
        if(aName.length >= 59){
           newName = aName.substr(0,56) + '...';
        }
        return newName;
    },

     deleteRecord: function (cmp) {
        var modalBody;
        var modalFooter;
        var sobjectLabel = 'Action Plan '
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

    addAdditionalTasks: function(cmp, selTasks){
         this.showSpinner(cmp);
         var conId = cmp.get('v.contractId');
         //console.log('contractId = ' + conId);
         var apTasks = cmp.get('v.apTasks');
         //console.log(apTasks);
         if($A.util.isEmpty(apTasks)){
            var apTasks = [];
         }
         var action = cmp.get("c.getAdditionalTasks");
         action.setParams({ index : this.getLastIndex(cmp, apTasks),
                            selectedTasks: selTasks,
                            contractId: conId });
         action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
             var newTasks = response.getReturnValue();
             //console.log(JSON.stringify(newTasks));
             if(!$A.util.isEmpty(newTasks)){
                this.setNewApTasks(cmp, newTasks);
                for (var i = 0; i < newTasks.length; i++) {
                    var task = newTasks[i];
                    task.Id = null;
                    apTasks.push(task);
                }
                cmp.set("v.apTasks", apTasks);
             }
             this.hideSpinner(cmp);
         }else if (state === "ERROR") {
             this.handleError(cmp, response);
         }
         });
         $A.enqueueAction(action);
    },

	openModal: function(component, event) {
        // Set isModalOpen attribute to false
        component.set("v.isUploadTasksModalOpen", true);
    },

    /*
    setVisibility: function(cmp, apTasks) {
        if(!$A.util.isEmpty(apTasks)){
            for (var i = 0; i < apTasks.length; i++) {
                var task = apTasks[i];
                task.IsVisible__c = true;

            }
        }
    },
    */

})