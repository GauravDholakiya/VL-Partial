({
	handleChange: function (component, event) {
       var cmp = event.getSource();
       var selectedTasks = component.get("v.selectedTasks");
       console.log('selected tasks before ' + selectedTasks);
       console.log(selectedTasks);
       var isSelected = event.getSource().get("v.checked");
       var isMandatory = event.getSource().get("v.label");
       var taskId = event.getSource().get("v.name");
       var tasks = new Map();
       var allTasks = component.get("v.apTaskList");
       
       console.log(selectedTasks);
       console.log('tutaj mandatory: ' + isMandatory);
       var mandatoryTasks = [];
        
        //get List of mandatory tasks under the Action Plan
       // if (isMandatory) {
        	for(var key in allTasks){
                if (allTasks[key].IsMandatory__c) {
                    mandatoryTasks.push(allTasks[key].Id); 
                }
            }  
       // }
        console.log('?????mandatoryTasks: ' + mandatoryTasks); 
       	// get already selected tasks from other plans
        for(var key in selectedTasks){
  		   tasks[key] = key;
	   	}
       // Add selected task Id to map
       if (isSelected) {
           tasks[taskId] = taskId;
           // Is selected task is mandatory add other mandatory tasks
           //if (isMandatory) {
           console.log('check mandatory task');
               for (var key1 in mandatoryTasks) {
                   console.log('check mandatory task in loop');
                   if (!tasks.has(mandatoryTasks[key1])) {
                   		tasks[mandatoryTasks[key1]] = mandatoryTasks[key1];
               		}
               }    
          // }
       } else {
           // remove from List deselected tasks
           delete tasks[taskId];
           // if  deselected task is mandatory remove all mandatory tasks
           if (isMandatory) {
               for (var key1 in mandatoryTasks) {
                   delete tasks[mandatoryTasks[key1]];
               }    
           }
       }
       component.set("v.selectedTasks", tasks);
       
       console.log('selected tasks after');
       console.log(tasks);
       console.log(component.get("v.selectedTasks"));
        
        // Select/deselect mandatory tasks
            const allOptions = component.find('taskCheckbox'); 
            console.log(allOptions);
                
            let chk = (allOptions.length == null) ? [allOptions] : allOptions;
            if (isSelected) {
               	chk.forEach(function(checkbox){
                	if (checkbox.get('v.label') === true)
                	checkbox.set('v.checked', true)
            	});  
            }
        
    },
    selectAll: function (component, event) {
    	const allOptions = component.find('taskCheckbox'); 
        console.log(allOptions);
    	let chk = (allOptions.length == null) ? [allOptions] : allOptions;
    	chk.forEach(checkbox => checkbox.set('v.checked', true));
        var selectedTasks = component.get("v.selectedTasks");
        var tasks = new Map();
        for(var key in selectedTasks){
  		   tasks[key] = key;
	   	}
        var allTasks = component.get("v.apTaskList");
        for (var key1 in allTasks) {
        	tasks[allTasks[key1].Id] = allTasks[key1].Id;
		}  
       component.set("v.selectedTasks", tasks);
       
       console.log('selected tasks after');
       console.log(tasks);
    },
    
    deselectAll: function (component, event) {
    	const allOptions = component.find('taskCheckbox'); 
        console.log(allOptions);
    	let chk = (allOptions.length == null) ? [allOptions] : allOptions;
    	chk.forEach(checkbox => checkbox.set('v.checked', false));
        var selectedTasks = component.get("v.selectedTasks");
        var tasks = new Map();
        for(var key in selectedTasks){
  		   tasks[key] = key;
	   	}
        var allTasks = component.get("v.apTaskList");
        console.log('all tasks: ' + allTasks);
        console.log(allTasks);
        for (var key1 in allTasks) {
        	delete tasks[allTasks[key1].Id];
		}
        
        component.set("v.selectedTasks", tasks);
       
        console.log('selected tasks after');
        console.log(tasks);
    }
})