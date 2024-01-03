({ 
    doInit: function(component, event, helper) {
		var date = new Date(), y = date.getFullYear(), m = date.getMonth();
		//var firstDay = new Date(y, m, 1);
		//var lastDay = new Date(y, m + 1, 0);
        var firstDay = $A.localizationService.formatDate(new Date(y, m, 1), "YYYY-MM-DD");
        var lastDay = $A.localizationService.formatDate(new Date(y, m+1, 0), "YYYY-MM-DD");
        component.set("v.startDate", firstDay);
        component.set("v.endDate", lastDay);
        console.log('Values set');
        helper.getTimes(component, event);

    },
    getTimes: function(component, event, helper) {
		helper.getTimes(component, event);
	},
    confirm: function(component, event, helper) {
		var navigate = component.get('v.navigateFlow');
		navigate("NEXT");
	},
    closeWindow: function(component, event, helper) {
       helper.closeWindow(component, event);
    },
    showSpinner: function(component, event, helper) {
       component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
     component.set("v.Spinner", false);
    }
})