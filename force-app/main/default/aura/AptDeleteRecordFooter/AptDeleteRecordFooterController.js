({

    handleCancel : function(cmp, event, helper) {
        cmp.find("overlayLib").notifyClose();
    },
    
    handleDelete : function(cmp, event, helper) {
        helper.showSpinner(cmp);
        var action = cmp.get('c.deleteRecord')
        var record = cmp.get("v.recordId")
        var sobjectLabel = cmp.get("v.sobjectLabel")
		action.setParams({recordId : record})
 		action.setCallback(this, function(response) {
			var toastEvent = $A.get("e.force:showToast")
            var state = response.getState();
            var result = response.getReturnValue();
            helper.hideSpinner(cmp);
            console.log('result');
            console.log(result);
            if (state === "SUCCESS" && result) {
               toastEvent.setParams({
                    message: sobjectLabel + ' was deleted.',
                    type: 'SUCCESS'
                });
				var urlEvent = $A.get("e.force:navigateToURL");
    			urlEvent.setParams({
      				"url": "/" + record.substring(0, 3)
    			});
    			urlEvent.fire();                
            }else {
                toastEvent.setParams({
                    message: sobjectLabel + ' was not deleted.',
                    type: 'ERROR'
                });                
            }
            cmp.find("overlayLib").notifyClose();
            toastEvent.fire();

        })
        $A.enqueueAction(action);
    },    
})