/**
 * Created by jozef on 4. 4. 2023.
 */

({
     setButtonColor : function(cmp){
        let apTask = cmp.get('v.apTask');
        let isOverdue = false;
        if (apTask && apTask.standardTasks){
            for (const [key, value] of Object.entries(apTask.standardTasks)) {
               if (value.Days_to_Completed__c < 0){
                   isOverdue = true;
                   break;
               }
            }
        }
        this.setButtonClass(cmp, isOverdue);
        //console.log(isOverdue);
    },

    setButtonClass: function(cmp, isOverdue){
        let editClass = '';
        if (isOverdue == true){
            editClass = 'pencilRedCss';
        }
        cmp.set('v.editClass', editClass);
    },

    recalculateButtonColor: function(cmp){
        let apTask = cmp.get('v.apTask');
        let periodDateColumn;
        let newStandardTasks = {};
        if (apTask && apTask.standardTasks){
            for (const [key, value] of Object.entries(apTask.standardTasks)) {
               periodDateColumn = 'Period_' + value.Period__c + '__c';
               if (value.ActivityDate == apTask[periodDateColumn]){
                   newStandardTasks[key] = value;
               }
           }
        }
        apTask.standardTasks = newStandardTasks;
        cmp.set('v.apTask', apTask);
        this.setButtonColor(cmp);
    },
});