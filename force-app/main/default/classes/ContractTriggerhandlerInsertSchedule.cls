/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         ContractTriggerhandlerInsertSchedule.cls 
Description:  Controller class creates Scheduler if any queue is running in back ground than next queue will schedule for next 5 second.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
Aug 2019        0.1         Parthesh                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

global class ContractTriggerhandlerInsertSchedule implements Schedulable {

    private Map<Id, String> accountOwnerMap = new Map<Id, String>();
    
    global ContractTriggerhandlerInsertSchedule(Map<Id, String> accountOwnerMapHandler)
    {
        this.accountOwnerMap = accountOwnerMapHandler;
    }
    
    global void execute(SchedulableContext sc) 
    {
        ContractTriggerhandlerInsertQueueable analyticsinsert = new ContractTriggerhandlerInsertQueueable(accountOwnerMap);                    
        ID jobID = System.enqueueJob(analyticsinsert);
        // Abort the job once the job is queued
        System.abortJob(sc.getTriggerId());
    }
    
}