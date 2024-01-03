({
	navigateNext: function(component, event, helper) {
		var navigate = component.get("v.navigateFlow");
        navigate("NEXT");
	},
    
    navigateCancel: function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
    	urlEvent.setParams({
      		"url": "/" + component.get("v.contractId")
    	});
    	urlEvent.fire();
	},
    
    init : function(component, event, helper){
    	helper.initFicalYear(component, event, helper);
	},
    
    handleChange : function(component, event, helper){
        var selectedOptionValue = event.getParam("value");
        component.set("v.fiscalYear", selectedOptionValue);
        console.log(selectedOptionValue);
        console.log('>>>COPY: ', component.get("v.cloneExisting"));
        let button = component.find('nextButtonId');
        if (selectedOptionValue!==null && selectedOptionValue!=='') {
            button.set('v.disabled',false);
        } else {
            button.set('v.disabled',true);
        }
        helper.searchForActionPlans(component, event, helper);
    }
})