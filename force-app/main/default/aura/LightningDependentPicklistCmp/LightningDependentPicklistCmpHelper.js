({
    isSelectedProjectInternal : function(component) {
        var projectTasks = component.get("v.projectTasks");
		var selectedProjectTasks = component.get("v.selectedProjectTasks");

        if (selectedProjectTasks.length != 0) {
            for (var j = 0; j < projectTasks.length; j++) {
                if (selectedProjectTasks[selectedProjectTasks.length - 1].Id == projectTasks[j].Id) {
                    if (projectTasks[j].Project__r.RecordType.DeveloperName == "Internal_Project") {
                        return true;
                    }
                }
            }
        }

        return false;
    }
})