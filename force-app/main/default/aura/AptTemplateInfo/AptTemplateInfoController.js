/**
 * @author Jozef 
 * @date 22.2.2019.
 * @description //TODO
 */
({
     doInit : function(cmp, event, helper) {
            console.log('doInit');
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            console.log(userId);
            cmp.set('v.currentUser', userId);
     },
})