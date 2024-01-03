({
	init : function(component, event, helper){
    	helper.initAPTTasks(component, event, helper);
	},

    handleChangeTempOption :function(component, event, helper){
        helper.initAPTTasks(component, event, helper);
    },

    addTasks : function(component, event, helper){
        //helper.clearSelectedTasks(component);
   		var apTasks = component.find("actionPlanTasks");
    	var selectedTasks = [];
        for (var i=0;i<apTasks.length;i++){
           var tasks = apTasks[i].get("v.selectedTasks");
            //console.log("tasks:" + tasks);
            for(var key in tasks){
            	selectedTasks.push(key);
	   		}
        }
        component.set("v.selectedTasks", selectedTasks);
        //console.log('????selectedTasks: ' + selectedTasks);
        helper.closeModal(component, false);
        helper.sendEvent(component, event);
        //
    },

    closeModal: function(component, event, helper) {
          // Set isModalOpen attribute to false
          helper.closeModal(component, true);
    },
})