({
    handleCancel : function(cmp, event, helper) {
        cmp.find("overlayLib").notifyClose()
    },
    
    handleDelete : function(cmp, event, helper) {
        var action = cmp.get('c.deleteRecord')
        var record = cmp.get("v.record")
        var sobjectLabel = cmp.get("v.sobjectLabel")
		action.setParams({recordId : record.Id})
 		action.setCallback(this, function(response) {
			var toastEvent = $A.get("e.force:showToast")
            var state = response.getState()
            var result = response.getReturnValue()
            console.log('result');
            console.log(result);
            if (state === "SUCCESS" && result) {
                var message = '';
                if (sobjectLabel == 'Content Version') {
                   message = 'File' + ' "' +record.Title + '"' 
                } else {
                   message = sobjectLabel + ' "' +record.Name + '"' 
                }
                var message = 
                toastEvent.setParams({
                    message: message + ' was deleted.',
                    type: 'SUCCESS'
                });                
            }else {
                toastEvent.setParams({
                    message: message + ' was not deleted.',
                    type: 'ERROR'
                });                
            }
            cmp.find("overlayLib").notifyClose()
            toastEvent.fire()         
        })
        $A.enqueueAction(action)
    },    
})