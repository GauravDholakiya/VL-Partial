/**
 * @author Jozef 
 * @date 6.2.2019.
 * @description //TODO
 */
({
    displayError: function(cmp, message) {
        console.log(message);
        var utilCmp = cmp.find("utilId");
        utilCmp.showError(message);
    },

    setObjectData : function(cmp, event){
        console.log('setObjectData');
        var action = cmp.get("c.getObjectData");
        action.setParams({ recordId :cmp.get('v.recordId'),
                           objectName: cmp.get('v.sfObject'),
                           fieldName: cmp.get('v.fieldName')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                cmp.set("v.record", record);
                this.setLabel(cmp, record);
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

    setLabel : function(cmp, record){
        var fieldName = cmp.get('v.fieldName');
        var record = cmp.get("v.record");
        var label = record[fieldName];
        cmp.set("v.label", label);
    },
})