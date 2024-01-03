/**
 * @author Jozef 
 * @date 11.7.2019.
 * @description //TODO
 */

({
    setContractId : function(cmp, event){
        console.log('setContractId');
        var action = cmp.get("c.getActionPlan");
        action.setParams({ apId :cmp.get('v.recordId')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                console.log(record);
                cmp.set('v.contractId',record.Contract__c);
                cmp.set('v.fiscalYear',record.FiscalYear__c);
                cmp.set('v.displayPlan', true);
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

    displayError: function(cmp, message) {
      console.log(message);
      var utilCmp = cmp.find("utilId");
      utilCmp.showError(message);
    },

});