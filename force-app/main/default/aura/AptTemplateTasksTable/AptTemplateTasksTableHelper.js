/**
 * @author Jozef 
 * @date 30.1.2019.
 * @description //TODO
 */
({


    swithYear : function(svgCmp, tId){
        var category = svgCmp.get('v.category');
        //console.log(category);
        if (category == 'closed'){
             $A.util.removeClass(svgCmp, 'switchIconClosed');
             $A.util.addClass(svgCmp, 'switchIconOpened');
             category = 'opened';
             svgCmp.set('v.category',category);
        }else{
             $A.util.removeClass(svgCmp, 'switchIconOpened');
             $A.util.addClass(svgCmp, 'switchIconClosed');
             category = 'closed';
             svgCmp.set('v.category',category);

        }
        this.throwSwitchPressedEvent(tId, category);
    },

    throwSwitchPressedEvent : function(tId, category){
         var cmpPeriodSwitchPressedEvent = $A.get("e.c:AptPeriodSwitchPressedEvt");
         cmpPeriodSwitchPressedEvent.setParams({ "tId": tId , "status" : category });
         cmpPeriodSwitchPressedEvent.fire();
    },

    handleOnYearPress: function(cmp, event) {
        //console.log('onYearClick');
        var tId = event.currentTarget.getAttribute("data-row-id");
        var swId = 'switch';
        //dynamic aura:id not suported aura:id can't be expression https://success.salesforce.com/ideaView?id=0873A000000E8fBQAS
        var cmpsSwitchIcon = cmp.find(swId);
        if (!$A.util.isEmpty(cmpsSwitchIcon)){
             for (var i = 0; i < cmpsSwitchIcon.length; i++) {
                var svgCmp = cmpsSwitchIcon[i];
                var name = svgCmp.get('v.name');
                //var category = svgCmp.get('v.category');
                if (name == tId){
                    this.swithYear(svgCmp, tId);
                    return;
                }
             }
        }
        //console.log(tId);
        //console.log(cmpSwitchIcon[0].get('v.name'));

    },


    displayError: function(cmp, message) {
        console.log(message);
        var utilCmp = cmp.find("utilId");
        utilCmp.showError(message);
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
        var tTasks = cmp.get('v.tTasks');
        var delTasks = cmp.get('v.delTasks');
        //console.log(' TASK INDEX ' + taskIndex);
        if(!$A.util.isEmpty(tTasks)){
            for (var i = 0; i < tTasks.length; i++) {
                var task = tTasks[i];
                //console.log(task.taskIndex__c);
                if (task.taskIndex__c == taskIndex){
                    tTasks.splice(i, 1);
                    //console.log('IM HERE' + task.AttachmentHeader__c);
                    delTasks.push(task);
                    break;
                }
            }
            cmp.set('v.tTasks', tTasks);
        }
    },

    findByName: function(cmp, event) {
        var searchKey = event.getParam("searchKey");
        var utilCmp = cmp.find("utilId");
        var tTasks = cmp.get('v.tTasks');
        if(!$A.util.isEmpty(tTasks)){
            utilCmp.filterByNameAndNumber(searchKey, tTasks);
            cmp.set("v.tTasks", tTasks);
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
        var tTasks = cmp.get("v.tTasks");
        sortAsc = sortField != field || !sortAsc;
        tTasks.sort(function(a,b){
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
        cmp.set("v.tTasks", tTasks);
    },

    sortByNumber: function(cmp, field) {
        var sortAsc = cmp.get("v.sortAsc");
        var sortField = cmp.get("v.sortField");
        var tTasks = cmp.get("v.tTasks");
        sortAsc = sortField != field || !sortAsc;
        tTasks.sort(function(a,b){
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
        cmp.set("v.tTasks", tTasks);
    },


    sortByName: function(cmp, field) {
        var sortAsc = cmp.get("v.sortAsc");
        var sortField = cmp.get("v.sortField");
        var tTasks = cmp.get("v.tTasks");
        sortAsc = sortField != field || !sortAsc;
        tTasks.sort(function(a,b){
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
        cmp.set("v.tTasks", tTasks);
    },


    sortByCheckBox: function(cmp, field) {
        var sortAsc = cmp.get("v.sortAsc");
        var sortField = cmp.get("v.sortField");
        var tTasks = cmp.get("v.tTasks");
        sortAsc = sortField != field || !sortAsc;
        tTasks.sort(function(a,b){
             var first = a[field];
             var second = b[field];
             if (first == true && second == true) return 0;
             if (first == false && second == false) return 0;
             if (first == false && second == true) return sortAsc == true? -1 : 1;
             if (first == true && second == false) return sortAsc == true? 1 : -1;
        });

        cmp.set("v.sortAsc", sortAsc);
        cmp.set("v.sortField", field);
        cmp.set("v.tTasks", tTasks);
    },
    
    initRolePicklistValues: function(cmp){
    	var action = cmp.get('c.fetchRolePicklistValues');
        action.setCallback(this, function(response) {
            var opts=response.getReturnValue();    
            cmp.set("v.assignedToOptions", opts);
        });
        $A.enqueueAction(action);
    },

    initInitialStartDatePicklistValues: function(cmp){
        var action = cmp.get('c.fetchIniStartDatePicklistValues');
          action.setCallback(this, function(response) {
              var opts=response.getReturnValue();
              cmp.set("v.initialStartDateOptions", opts);
          });
          $A.enqueueAction(action);
    },

    skipWeekendsTask: function(cmp, taskIndex, skip){
        //console.log('skipWeekendsTask');
        //console.log(taskIndex);
        //console.log(skip);

        var utilCmp = cmp.find("utilId");
        var tasks = cmp.get("v.tTasks");
        if(!$A.util.isEmpty(tasks)){
            for (var i = 0; i < tasks.length; i++) {
                var task = tasks[i];
                if (task.taskIndex__c == taskIndex){
                    utilCmp.skipWeekend(task, skip);
                    break;
                }
            }
            cmp.set("v.tTasks",tasks);
        }
    },

})