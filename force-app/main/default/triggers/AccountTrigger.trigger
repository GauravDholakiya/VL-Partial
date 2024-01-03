/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         AccountTrigger.apxt 
Description:  Trigger calss that handles rename oprations after update on Account Object that is replicated on MS Teams Sharepoint.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
July 2019        0.1         Parthesh                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */
trigger AccountTrigger on Account (before insert, before update, before delete, after insert,
        after update, after delete, after undelete) 
{
    TriggerDispatcher.run(new AccountTriggerhandler());
}