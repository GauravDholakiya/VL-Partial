/**
 * @author Jozef 
 * @date 30.1.2019.
 * @description //TODO
 */
({

    displayError: function(cmp, message) {
        console.log(message);
        var utilCmp = cmp.find("utilId");
        utilCmp.showError(message);
    },

    onChangeFrequency: function(cmp, aptIndex, value){
        var utilCmp = cmp.find("utilId");
        var initDate = cmp.get('v.initDate');
        var fiscalYear = cmp.get('v.fiscalYear');
        var apTasks = cmp.get('v.apTasks');
        var apTask = this.getTaskAccordingIndex(apTasks, aptIndex);
        utilCmp.setPeriods(fiscalYear, apTask, initDate);
        cmp.set('v.apTasks',apTasks);
        this.setFirstPeriodAfterChange(cmp, aptIndex);
    },

    setFirstPeriodAfterChange: function(cmp, aptIndex){
        let firstPeriodInputs = cmp.find('firstPeriodId');
        if(!$A.util.isEmpty(firstPeriodInputs)){
            for (var i = 0; i < firstPeriodInputs.length; i++) {
                let firstPeriod = firstPeriodInputs[i];
                if (firstPeriod.get("v.taskIndex") == aptIndex){
                    firstPeriod.recalculateFirstPeriod();
                    break;
                }
            }
        }
    },

    getTaskAccordingIndex: function(apTasks, aptIndex){
        if(!$A.util.isEmpty(apTasks)){
            for (var i = 0; i < apTasks.length; i++) {
                var task = apTasks[i];
                if (task.taskIndex__c == aptIndex){
                    return task;
                }
            }
        }
        return null;
    },

    saveAttachments : function(cmp, attheaderId, uploadedFiles){
        var action = cmp.get("c.saveAttachments");
        action.setParams({ attachmentHeaderId :attheaderId,
                           files: uploadedFiles});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.reloadAttachments(cmp);
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


    reloadAttachments: function(cmp){
       var aptIndex = cmp.get("v.tableIndex");
       var headerId = cmp.get("v.headerId");
       this.fireRowClickEvent(headerId, aptIndex);
    },

    fireRowClickEvent: function(headerId, aptIndex){
        var aptCommentsAttEvent = $A.get("e.c:AptTableReadRowSelectedEvt");
        aptCommentsAttEvent.setParams({ "headerId": headerId, "index": aptIndex  });
        aptCommentsAttEvent.fire();
    },


    deleteRow : function(cmp, taskIndex){
        var apTasks = cmp.get('v.apTasks');
        var delTasks = cmp.get('v.delTasks');
        if(!$A.util.isEmpty(apTasks)){
            for (var i = 0; i < apTasks.length; i++) {
                var task = apTasks[i];
                if (task.taskIndex__c == taskIndex){
                    apTasks.splice(i, 1);
                    delTasks.push(task);
                    break;
                }
            }
            cmp.set('v.apTasks', apTasks);
        }
    },

    editPeriods : function(cmp, taskIndex){
        let apTasks = cmp.get("v.apTasks");
        let task = null;
        let foundedTask = null;
        let originTask = null;
        if(!$A.util.isEmpty(apTasks)){
            for (var i = 0; i < apTasks.length; i++) {
                task = apTasks[i];
                if (task.taskIndex__c == taskIndex){
                    foundedTask = task;
                    originTask = JSON.parse(JSON.stringify(task));
                    break;
                }
            }
            if (foundedTask != null){
                cmp.set('v.apTaskEdit', foundedTask);
                cmp.set('v.apTaskEditOrigin', originTask);
            }
        }
        cmp.set('v.aptIndex', taskIndex);
        cmp.set('v.isPeriodModalOpen', true);
    },

    findByName: function(cmp, event) {
        var searchKey = event.getParam("searchKey");
        var utilCmp = cmp.find("utilId");
        var apTasks = cmp.get('v.apTasks');
        if(!$A.util.isEmpty(apTasks)){
            utilCmp.filterByKeyword(searchKey, apTasks);
            cmp.set("v.apTasks", apTasks);
        }
    },

    sortBy: function(cmp, field) {
        /*
        -1 if the reference string is sorted before the compareString
        0 if the two strings are equal
        1 if the reference string is sorted after the compareString
        */
        var sortAsc = cmp.get("v.sortAsc");
        var sortField = cmp.get("v.sortField");
        var apTasks = cmp.get("v.apTasks");
        sortAsc = sortField != field || !sortAsc;
        apTasks.sort(function(a,b){
            var first = a[field];
            var second = b[field];
            if(first == undefined) {
                first = '';
            }
            if (second == undefined){
                second = '';
            }
            var t1 = first.localeCompare(second);
            if (t1 == 0){
                return 0;
            }
            if ((t1 == -1) && sortAsc){
                return -1;
            }
            if ((t1 == 1) && sortAsc){
                return 1;
            }
            if ((t1 == -1) && !sortAsc) {
                return 1;
            }
            if ((t1 == 1) && !sortAsc){
                return -1;
            }
        });

        cmp.set("v.sortAsc", sortAsc);
        cmp.set("v.sortField", field);
        cmp.set("v.apTasks", apTasks);
    },

    sortByNumber: function(cmp, field) {
        var sortAsc = cmp.get("v.sortAsc");
        var sortField = cmp.get("v.sortField");
        var apTasks = cmp.get("v.apTasks");
        sortAsc = sortField != field || !sortAsc;
        apTasks.sort(function(a,b){
            var first = a[field];
            var second = b[field];
            if(first == undefined) {
                first = 0;
            }
            if (second == undefined){
                second = 0;
            }
            var t1 = first == second,
                t2 = (!first && second) || (first < second);
                return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        cmp.set("v.sortAsc", sortAsc);
        cmp.set("v.sortField", field);
        cmp.set("v.apTasks", apTasks);
    },


    sortByName: function(cmp, field) {
        var sortAsc = cmp.get("v.sortAsc");
        var sortField = cmp.get("v.sortField");
        var apTasks = cmp.get("v.apTasks");
        sortAsc = sortField != field || !sortAsc;
        apTasks.sort(function(a,b){
            var first = a[field];
            var second = b[field];
            if(first == undefined) {
                first = '';
            }else {
                first = first.Name;
            }
            if (second == undefined){
                second = '';
            }else{
               second = second.Name;
            }
            var t1 = first.localeCompare(second);
            if (t1 == 0){
                return 0;
            }
            if ((t1 == -1) && sortAsc){
                return -1;
            }
            if ((t1 == 1) && sortAsc){
                return 1;
            }
            if ((t1 == -1) && !sortAsc) {
                return 1;
            }
            if ((t1 == 1) && !sortAsc){
                return -1;
            }
        });

        cmp.set("v.sortAsc", sortAsc);
        cmp.set("v.sortField", field);
        cmp.set("v.apTasks", apTasks);
    },


    sortByCheckBox: function(cmp, field) {
        var sortAsc = cmp.get("v.sortAsc");
        var sortField = cmp.get("v.sortField");
        var apTasks = cmp.get("v.apTasks");
        sortAsc = sortField != field || !sortAsc;
        apTasks.sort(function(a,b){
             var first = a[field];
             var second = b[field];
             if (first == true && second == true) return 0;
             if (first == false && second == false) return 0;
             if (first == false && second == true) return sortAsc == true? -1 : 1;
             if (first == true && second == false) return sortAsc == true? 1 : -1;
        });

        cmp.set("v.sortAsc", sortAsc);
        cmp.set("v.sortField", field);
        cmp.set("v.apTasks", apTasks);
    },

    skipWeekendsTask: function(cmp, taskIndex, skip){
       var utilCmp = cmp.find("utilId");
       var tasks = cmp.get("v.apTasks");
       if(!$A.util.isEmpty(tasks)){
           for (var i = 0; i < tasks.length; i++) {
               var task = tasks[i];
               if (task.taskIndex__c == taskIndex){
                   utilCmp.skipWeekend(task, skip);
                   break;
               }
           }
           cmp.set("v.apTasks",tasks);
       }
   },

   changedFirstPeriodAndDay: function(cmp, firstPeriodDate, periodColumn, taskIndex){
       //console.log(firstPeriodDate + ' : ' + periodColumn + ' : ' + taskIndex);
       var tasks = cmp.get("v.apTasks");
       if(!$A.util.isEmpty(tasks)){
          for (var i = 0; i < tasks.length; i++) {
              var task = tasks[i];
              if (task.taskIndex__c == taskIndex){
                  this.changedFirstPeriodAndDayForTask(task, firstPeriodDate, periodColumn);
                  break;
              }
          }
          //console.log(JSON.stringify(tasks));
          cmp.set("v.apTasks",tasks);
       }
   },

    changedFirstPeriodAndDayForTask: function(task, firstPeriodDate, periodColumn){
        task[periodColumn] = firstPeriodDate;
        if(!$A.util.isEmpty(firstPeriodDate)){
            this.changeDayInPeriods(task, firstPeriodDate);
        }
    },

    changeDayInPeriods: function(task, firstPeriodDate){
        let day = new Date(firstPeriodDate).getDate();
        let periodColumn;
        let periodDateStr;
        let periodDate;
        let periodStaticCol;
        for (var i = 1; i <= 12; i++) {
             periodColumn = 'Period_'+ i +'__c';
             periodStaticCol = 'P' + i + 'static';
             periodDateStr = task[periodColumn];
             if(!$A.util.isEmpty(periodDateStr) && task[periodStaticCol] == false){
                 periodDate = new Date(periodDateStr);
                 periodDate.setDate(day);
                 task[periodColumn] = $A.localizationService.formatDate(periodDate, "YYYY-MM-DD");
             }
        }
    },

    recalculateStandardTasksAfterChange: function(cmp, aptIndex){
        //console.log('setEditButtonColor');
        let editButtons = cmp.find('editButtonId');
        if(!$A.util.isEmpty(editButtons)){
            for (var i = 0; i < editButtons.length; i++) {
                let editButton = editButtons[i];
                if (editButton.get("v.taskIndex") == aptIndex){
                    editButton.recalculateButtonColor();
                    break;
                }
            }
        }
    },

})