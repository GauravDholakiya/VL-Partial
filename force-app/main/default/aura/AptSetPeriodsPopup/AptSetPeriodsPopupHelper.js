/**
 * Created by jozef on 27. 3. 2023.
 */

({

    cancel: function(cmp) {
        let originTask = cmp.get('v.originApTask');
        let apTasks = cmp.get('v.apTasks');
        let taskIndex = cmp.get("v.taskIndex");
        let changedApTasks = [];
        if(!$A.util.isEmpty(apTasks)){
            for (var i = 0; i < apTasks.length; i++) {
                task = apTasks[i];
                //console.log(task.taskIndex__c);
                if (task.taskIndex__c == taskIndex){
                    task = originTask;
                }
                changedApTasks.push(task);
            }
            cmp.set('v.apTasks', changedApTasks);
        }
        //console.log('cancel #############' + JSON.stringify(cmp.get('v.apTask')));
        this.closeModal(cmp);
    },

    closeModal: function(cmp) {
        cmp.set("v.isPeriodModalOpen", false);
        cmp.set('v.mode', 'VIEW');
    },

    save: function(cmp) {
        this.sendSavePressed(cmp);
        this.closeModal(cmp);
    },

    edit: function(cmp) {
        cmp.set('v.mode', 'EDIT');
    },

    sendSavePressed: function(cmp) {
         let taskIndex = cmp.get("v.taskIndex");
         let aptEditPeriodsSavePressedEvt = $A.get("e.c:AptEditPeriodsSavePressedEvt");
         aptEditPeriodsSavePressedEvt.setParams({ "taskIndex" : taskIndex });
         aptEditPeriodsSavePressedEvt.fire();
    },

});