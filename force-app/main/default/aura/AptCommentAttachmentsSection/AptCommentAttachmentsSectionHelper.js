/**
 * @author Jozef 
 * @date 24.1.2019.
 * @description //TODO
 */
({

     displayError: function(cmp, message) {
        console.log(message);
        var utilCmp = cmp.find("utilId");
        utilCmp.showError(message);
     },

     readAttachments : function(cmp){
        var action = cmp.get("c.getAttachments");
        action.setParams({ attachmentHeaderId :cmp.get('v.headerId')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var attachments = response.getReturnValue();
                cmp.set("v.attachments", attachments);

            }
            else if (state === "INCOMPLETE") {
                           // do something

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

})