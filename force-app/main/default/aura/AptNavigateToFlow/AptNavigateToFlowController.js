({
    navigateToFlow : function(component, event, helper) {
        console.log('RECORD ID: ' + component.get("v.recordId"))
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AptTaskManager",
            componentAttributes: {
            	contractId : component.get("v.recordId")
       		}
        });
        evt.fire();
    } 
})