/**
 * @author Jozef 
 * @date 12.9.2019.
 * @description //TODO
 */

trigger AccountTeamAndAuthorizationsTrigger on Account_Team_And_Authorizations__c
        (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    {
        TriggerDispatcher.run(new AccountTeamAndAuthTriggerHandler());
    }
}