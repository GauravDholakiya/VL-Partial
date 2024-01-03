({
	init : function(cmp, event, helper) {
        cmp.set('v.customActions', [
            { label: 'Custom action', name: 'custom_action' }
        ])
        cmp.set('v.fileColumns', [
            { label: 'File Name', fieldName: 'Title', type: 'text' },
            { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date' },
            { label: 'Owner', fieldName: 'Owner_LinkName', type: 'url', typeAttributes: {label: { fieldName: 'Owner_Name' }, target: '_top'} }
           
        ])
	 },
    
    recordUpdated : function(cmp, event, helper) {
        var changeType = event.getParams().changeType;
    	console.log(">>>>>>>>>>HANDLER INIT!!")
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { /* handle record load */ }
        else if (changeType === "REMOVED") { /* handle record removal */ }
        else if (changeType === "CHANGED") {
        	console.log("HANDLE CHANGE!!")
            cmp.find("recordLoader").reloadRecord();
			
        }
    },
    
    validate :function(cmp, event, helper) {
    },
    customHandler : function(cmp, event, helper) {
        alert("It's custom action!")
    },
    
    refreshView : function (component, event, helper) {
         $A.get('e.force:refreshView').fire();
    },
    
})