/**
 * @author Jozef 
 * @date 11.7.2019.
 * @description //TODO
 */

({
    doInit : function(cmp, event, helper) {
        console.log('>>CLONE: ', cmp.get('v.cloneExisting'));
        if(!$A.util.isEmpty(cmp.get('v.recordId'))){
            cmp.set('v.displayPlan', false);
            helper.setContractId(cmp, event);
        }
    },
});