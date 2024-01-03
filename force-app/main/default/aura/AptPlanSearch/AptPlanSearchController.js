/**
 * @author Jozef 
 * @date 18.2.2019.
 * @description //TODO
 */

({
    searchKeyChange: function(component, event, helper) {
        var myEvent = $A.get("e.c:AptPlanSearchKeyChangeEvt");
        myEvent.setParams({"searchKey": event.target.value});
        myEvent.fire();
    }
})