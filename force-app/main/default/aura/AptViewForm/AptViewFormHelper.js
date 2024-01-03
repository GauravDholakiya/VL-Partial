/**
 * @author Jozef 
 * @date 3.6.2019.
 * @description //TODO
 */

({
    displayError: function(cmp, message) {
        console.log(message);
        var utilCmp = cmp.find("utilId");
        utilCmp.showError(message);
    },

    setObjectData : function(cmp, event){
        console.log('getTemplatePlan');
        var action = cmp.get("c.getTemplatePlan");
        action.setParams({ recordId :cmp.get('v.tId')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                console.log(record);
                cmp.set('v.templatePlan',record);
                //cmp.set("v.record", record);
                //this.setLabel(cmp, record);
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var em = errors[0].message;
                            this.displayError(cmp, em);
                        }
                    } else {
                        console.log("Unknown error");
                    }

             }
         });
         $A.enqueueAction(action);
    },


});