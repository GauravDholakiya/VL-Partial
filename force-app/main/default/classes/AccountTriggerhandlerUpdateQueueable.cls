/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         AccountTriggerhandlerUpdateQueueable.cls 
Description:  Controller class creates Queue for update MS Teams name In Sharepoint.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
Aug 2019         0.1         Parthesh                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

global class AccountTriggerhandlerUpdateQueueable implements Queueable , Database.AllowsCallouts
{
	Map<Id,Account> accountNewMAP = new Map<Id,Account>();
    Map<Id,Account> accountOldMAP = new Map<Id,Account>();
    
    global AccountTriggerhandlerUpdateQueueable(Map<Id,Account> accountCLSNewMap,Map<Id,Account> accountCLSOldMap)
    {
        this.accountNewMAP = accountCLSNewMap;
        this.accountOldMAP = accountCLSOldMap;
    }
    
    global void execute(QueueableContext context) 
    {
        for( Id accId : accountNewMAP.keySet() )
        {
            Account newAccount = (Account)accountNewMAP.get(accId);
            Account oldAccount = (Account)accountOldMAP.get(accId);
            
            if( oldAccount.Name != newAccount.Name )
            {
                AccountTriggerhandler.updateAccountNameToO365Group(newAccount.Name,newAccount.SPGroupID__c);
            } 
        }
    }
}