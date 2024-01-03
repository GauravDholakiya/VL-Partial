({
	cancel : function(component, event, helper) {
		helper.closeWindow(component, event);
	},
    
    back : function(component, event, helper) {
		var navigate = component.get('v.navigateFlow');
		navigate("BACK");
	},
    
    submitInvoice : function(component, event, helper) {
		helper.createInvoice(component);
	},
    
   showSpinner: function(component, event, helper) {
       component.set("v.Spinner", true); 
   },
   hideSpinner : function(component,event,helper){
     component.set("v.Spinner", false);
   }

})