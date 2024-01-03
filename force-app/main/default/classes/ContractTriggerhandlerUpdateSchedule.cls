/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         ContractTriggerhandlerUpdateSchedule.cls 
Description:  Controller class creates Scheduler if any queue is running in back ground than next queue will schedule for next 5 second.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
Aug 2019        0.1         Parthesh                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

global class ContractTriggerhandlerUpdateSchedule implements Schedulable 
{
    Map<Id,Contract__c> contractNewMAP = new Map<Id,Contract__c>();
    Map<Id,Contract__c> contractOldMAP = new Map<Id,Contract__c>();
    
    global ContractTriggerhandlerUpdateSchedule(Map<Id,Contract__c> contractCLSNewMap,Map<Id,Contract__c> contractCLSOldMap)
    {
        this.contractNewMAP = contractCLSNewMap;
        this.contractOldMAP = contractCLSOldMap;
    }
    
	global void execute(SchedulableContext sc) 
    {
        ContractTriggerhandlerUpdateQueueable analyticsinsert = new ContractTriggerhandlerUpdateQueueable(contractNewMAP,contractOldMAP);                    
        ID jobID = System.enqueueJob(analyticsinsert);
        // Abort the job once the job is queued
        System.abortJob(sc.getTriggerId());
    }
}