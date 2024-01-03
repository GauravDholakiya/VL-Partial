/**
 * @author Jozef 
 * @date 19.6.2019.
 * @description //TODO
 */

trigger AptActionPlanTrigger on ActionPlan__c (before insert, before update, before delete, after insert,
        after update, after delete, after undelete) {
    TriggerDispatcher.run(new AptActionPlanTriggerHandler());
}