/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         AccAndAuthTriggerHandlerSchedule.cls 
Description:  Controller class creates Scheduler if any queue is running in back ground than next queue will schedule for next 5 second.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
15 Sep 2019        1.0         Deepak                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */
global class AccTeamAndAuthTriggerHandlerSchedule implements Schedulable {
    Private Map<string,object> MapOfMembers = new Map<string,object>();
    Private string GroupID;
    global AccTeamAndAuthTriggerHandlerSchedule(Map<string,object> MapOfMembers ,string GroupID)
    {
        this.MapOfMembers = MapOfMembers;
        this.GroupID = GroupID;
    }
    
    global void execute(SchedulableContext sc) 
    {
        AccTeamAndAuthTriggerHandlerQueueable Queue = new AccTeamAndAuthTriggerHandlerQueueable(MapOfMembers,GroupID);
        ID jobID = System.enqueueJob(Queue);
        // Abort the job once the job is queued
        System.abortJob(sc.getTriggerId());
    }
}