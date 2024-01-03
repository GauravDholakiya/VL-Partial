/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         ContractTrigger.apxt 
Description:  Trigger calss that handles after insert or update oprations on Custom Contract__c Object.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
July 2019        0.1         Parthesh                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */
trigger ContractTrigger on Contract__c (before insert, before update, before delete, after insert,
        after update, after delete, after undelete) 
{    
    TriggerDispatcher.run(new ContractTriggerhandler());
}