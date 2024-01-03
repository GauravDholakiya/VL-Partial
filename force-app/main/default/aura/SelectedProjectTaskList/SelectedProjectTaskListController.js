({
    handleProjectTaskSelected : function(component, event, helper) {
        var selectedList = component.get("v.selectedProjectTaskList");
        var pId = event.getParam("Id");
        var pName = event.getParam("Name");
        var pDeactivated = event.getParam("Deactivated");
        var pAccountStatus = event.getParam("AccountStatus");
        var pReasonForDeactivation = event.getParam("ReasonForDeactivation");
        var pDefaultTimeType = event.getParam("DefaultTimeType");
        var pLockTimeType = event.getParam("LockTimeType");
        console.log("## handleProjectTaskSelected");
        if (selectedList.filter(item => item.Id  == pId).length == 0) {
            console.log("## selected Item not found, adding.");
            selectedList.push({"Id":pId, "Name":pName, "Deactivated":(pDeactivated==undefined?false:pDeactivated), "ReasonForDeactivation":(pReasonForDeactivation==undefined?"":pReasonForDeactivation), "DefaultTimeType":(pDefaultTimeType==undefined?"":pDefaultTimeType), "LockTimeType":(pLockTimeType==undefined?false:pLockTimeType), "AccountStatus":(pAccountStatus==undefined?false:pAccountStatus)});
            component.set("v.selectedProjectTaskList", selectedList);
        }
        
    },
    handleProjectTaskDeselected : function(component, event, helper) {
        var selectedList = component.get("v.selectedProjectTaskList");
        var newSelectedList = [];
        var pId = event.getParam("Id");
        var pName = event.getParam("Name");
        console.log("## handleProjectTaskDeselected");
        console.log("## Removing id: " + pId);
        selectedList.forEach(function a(item, index) {            
            console.log("## id: "+ item.Id);            
            if(item.Id != pId) {
                newSelectedList.push(item);
                console.log("## Retaining Project Task: "+ item.Name);
            }
        });
        console.dir(newSelectedList)
        component.set("v.selectedProjectTaskList", newSelectedList);
        
    }
})