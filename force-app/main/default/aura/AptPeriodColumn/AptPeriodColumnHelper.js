/**
 * Created by jozef on 3. 4. 2023.
 */

({
    setTaskDetails : function(cmp){
        let apTask = cmp.get('v.apTask');
        let periodNumber = cmp.get('v.periodNumber');
        //console.log(JSON.stringify(apTask));
        let task = cmp.get('v.task');
        let periodDate = cmp.get('v.periodDate');
        let taskProperty = 'task_' + periodNumber;
        if (apTask && apTask.standardTasks){
            for (const [key, value] of Object.entries(apTask.standardTasks)) {
               if (key == taskProperty){
                   //console.log(value.ActivityDate);
                   //console.log(periodDate);
                   if (value.ActivityDate == periodDate){
                       task = value;
                   }
                   break;
               }
            }
        }
        //console.log(JSON.stringify(task));
        cmp.set('v.task', task);
        if (task != null){
            this.setDateColor(cmp, task);
            this.setTaskControl(cmp, task);
        }
    },

    setTaskControl: function(cmp, task) {
        let taskControl = '';
        let iconClass = '';
        if (task.Task_Control__c == 'OK'){
            taskControl = 'standard:task2';
        }else if (task.Task_Control__c == 'Deviated' ){
            taskControl = 'utility:warning';
            iconClass = 'iconWarning';
        }
        cmp.set('v.iconName', taskControl);
        cmp.set('v.iconClass', iconClass);
    },

    setDateColor: function(cmp, task){
        let periodDateClass = '';
        if (task.Days_to_Completed__c < 0){
            periodDateClass = 'taskOverDueDate';
        }else if (task.Days_to_Completed__c > 7 || task.Days_to_Completed__c == 0){
            periodDateClass = 'moreThenWeekBeforeDueDate';
        }else if (task.Days_to_Completed__c > 7  ){
            periodDateClass = 'oneWeekBeforeDueDate';
        }
        cmp.set('v.periodDateClass', periodDateClass);
    },
});