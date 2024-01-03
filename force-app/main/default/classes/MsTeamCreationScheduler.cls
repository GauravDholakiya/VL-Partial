/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         MsTeamCreationScheduler.cls 
Description:  Delay MsteamSite Creation due to graph internal callout issue and used for retrieve of MsteamSite Creation.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
Sep 2020        0.1         Deepak                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

global class MsTeamCreationScheduler implements Schedulable 
{
    
    private  String sgroupid;
    private string stoken;
    private string smailNickname;
    private string saccountID;
    private integer processcount;
    global MsTeamCreationScheduler(String groupid,string token,string mailNickname,string accountID,integer count)
    {
        this.sgroupid = groupid;
        this.stoken = token;
        this.smailNickname = mailNickname;
        this.saccountID = accountID;
        this.processcount = count;
    }
    
    
    global void execute(SchedulableContext sc) 
    {
        
        ContractTriggerhandler.RetryCreateTeamSite(sgroupid,stoken,smailNickname,saccountID,processcount);
        
        // Abort the job once the job is queued
        System.abortJob(sc.getTriggerId());
    }
}