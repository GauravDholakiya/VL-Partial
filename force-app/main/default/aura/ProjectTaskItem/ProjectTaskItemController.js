({
    handleClickAdd : function(component, event, helper) {        
        console.log("## Setting up event");       
        var evt = $A.get("e.c:projectTaskSelected");
        evt.setParams({"Id": component.get("v.projectTaskId"),
                       "Name": component.get("v.projectTaskName"),
                       "Deactivated": component.get("v.deactivated"),
                       "AccountStatus": component.get("v.accountStatus"),
                       "ReasonForDeactivation": component.get("v.reasonForDeactivation"),
                       "DefaultTimeType": component.get("v.defaultTimeType"),
                       "LockTimeType": component.get("v.lockTimeType")});
        console.dir(evt.toString());
        evt.fire();
        console.log("## Event fired");
    },
    handleClickDelete : function(component, event, helper) {        
        console.log("## Setting up event");       
        var evt = $A.get("e.c:projectTaskDeselected");
        evt.setParams({"Id": component.get("v.projectTaskId"),
                       "Name": component.get("v.projectTaskName")});
        console.dir(evt.toString());
        evt.fire();
        console.log("## Event fired");
    }
})