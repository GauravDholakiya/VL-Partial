/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         AccountTriggerhandlerUpdateSchedule.cls 
Description:  Controller class creates Scheduler if any queue is running in back ground than next queue will schedule for next 5 second.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
Aug 2019         0.1         Parthesh                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

global class AccountTriggerhandlerUpdateSchedule implements Schedulable
{
    Map<Id,Account> accountNewMAP = new Map<Id,Account>();
    Map<Id,Account> accountOldMAP = new Map<Id,Account>();
    
	global AccountTriggerhandlerUpdateSchedule(Map<Id,Account> accountCLSNewMap,Map<Id,Account> accountCLSOldMap)
    {
        this.accountNewMAP = accountCLSNewMap;
        this.accountOldMAP = accountCLSOldMap;
    }
    
    global void execute(SchedulableContext sc) 
    {
        AccountTriggerhandlerUpdateQueueable analyticsinsert = new AccountTriggerhandlerUpdateQueueable(accountNewMAP,accountOldMAP);
    }
}