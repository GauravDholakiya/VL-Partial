({
	createInvoice: function(component) {
        component.set("v.result", 'Invoicing...');
        console.log('startdate: ' + component.get('v.startDate'));
      	var action = component.get("c.createInvoiceAndInvoiceLinesRanges");
            action.setParams(
                {"projectId" : component.get('v.projectId'),
                 "startDate" : component.get('v.startDate'),
                 "endDate" : component.get('v.endDate')
            });
            
            action.setCallback(this, function(response) {
            var state = response.getState();
                if (state == "SUCCESS") {
                    var results = response.getReturnValue();
                    console.log('RESULT: ' + results.invoiceId);
                    var invoiceId = results.invoiceId; 
                    
                    var hasError = results.hasError;
                    var message = results.message;
                    console.log('hasError: ' + hasError);
                    if (hasError) {
                        component.set("v.result", message);
                        component.set("v.hasError", hasError);
                    } else {
                        console.log('CREATED' + results.invoiceId)
                    var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": invoiceId,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                	}   
               } else if (state === "ERROR") {
                    
               }
           });
           $A.enqueueAction(action); 
    },
    
    closeWindow: function(component, event) {
    	var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get('v.projectId'),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
    }
})