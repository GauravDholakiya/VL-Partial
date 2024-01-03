/**
 * @author Jozef 
 * @date 21.6.2019.
 * @description //TODO
 */

trigger AptTaskTemplateTrigger on APTaskTemplate__c (before insert, before update, before delete, after insert,
        after update, after delete, after undelete) {
    TriggerDispatcher.run(new AptTaskTemplateTriggerHandler());
}