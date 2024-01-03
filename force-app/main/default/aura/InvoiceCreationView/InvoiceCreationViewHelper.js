({
	getTimes: function(component, event) {
		var projectId = component.get('v.recordId');
		//var projectId = 'a0I0Q000001xCQAUA2';
        console.log('on change: ' + projectId);
        
        //component.set("v.result", 'Invoicing...');
        var action = component.get("c.getInvoiceLines");
            action.setParams(
                {"projectId" : projectId,
    			"startDate" : component.get('v.startDate'),
    			"endDate" : component.get('v.endDate')
            });
            
            action.setCallback(this, function(response) {
            var state = response.getState();
                console.log('state: ' + state);
                if (state == "SUCCESS") {
                    console.log('success');
                    var results = response.getReturnValue();
                    component.set("v.invoiceLines", results.times);
                    component.set("v.noOfNotApproved", results.notApproved);
                    console.log('invoices');
                    console.log(results);
               } else if (state === "ERROR") {
                    
               }
           });
           $A.enqueueAction(action);
	},
    closeWindow: function(component, event) {
    	var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get('v.recordId'),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
    }
})