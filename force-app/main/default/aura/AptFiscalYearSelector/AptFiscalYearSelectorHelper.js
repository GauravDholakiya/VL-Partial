({
	initFicalYear : function(component, event, helper) {
		console.log('.......initFicalYear');
        
        var contractId = component.get("v.contractId");
        console.log('Populate years for: ' + contractId);
        var action = component.get('c.initYears');
        action.setParams({"contractId" : contractId});
 		action.setCallback(this, function(response) {
        	var opts=[];
            if (response.getState() === "SUCCESS" && response.getReturnValue().length>0)  {
                for(var i=0;i< response.getReturnValue().length;i++){
                    opts.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
                }
                component.set("v.fiscalYearsOptions", opts);
                console.log("v.fiscalYearsOptions: ");
                console.log(opts);
                var currentYear =new Date().getFullYear().toString();
                component.find("nextButtonId").set("v.disabled",false);
                console.log('>>>current year: ' + currentYear);
                component.find("selectYear").set("v.value", currentYear);
                component.set("v.fiscalYear", currentYear);                
                helper.searchForActionPlans(component, event, helper);
            } else {
               	var year = new Date().getFullYear();
       		   	opts.push({"class": "optionClass", label: (year-1).toString(), value: (year-1).toString()});
        	   	opts.push({"class": "optionClass", label: year.toString(), value: year.toString()});
        		opts.push({"class": "optionClass", label: (year+1).toString(), value: (year+1).toString()});
        		opts.push({"class": "optionClass", label: (year+2).toString(), value: (year+2).toString()});
        		opts.push({"class": "optionClass", label: (year+3).toString(), value: (year+3).toString()});
       			component.set("v.fiscalYearsOptions", opts);
            }
        });
        $A.enqueueAction(action);
	},
    searchForActionPlans : function(component, event, helper) {
        console.log('.......searchForActionPlans');
        var contractId = component.get("v.contractId");
        var fiscalYear = component.get("v.fiscalYear");
        console.log('ACTION PLAN! ' + fiscalYear);
        var action = component.get('c.fetchActionPlansForYears');
        action.setParams({"contractId" : contractId, "fiscalYear" : fiscalYear});
 		action.setCallback(this, function(response) {
        	var opts=[];
            if (response.getState() === "SUCCESS")  {
                if (response.getReturnValue().length>0)  {
                    component.set("v.validationMsg", true);
                	console.log('There is already AP');
                    component.find('nextButtonId').set('v.disabled',true);
                } else {
               		component.set("v.validationMsg", false);
                	component.find('nextButtonId').set('v.disabled',false);  
                }
            } else {
            }
        });
        $A.enqueueAction(action);
    }
})