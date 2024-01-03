/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         ContractTriggerhandlerInsertQueueable.cls 
Description:  Controller class creates Queue for create MS Teams In Sharepoint.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
July 2019        0.1         Parthesh                None    Initial draft
March 2023		 0.2		 Gaurav					 None    
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

global class ContractTriggerhandlerInsertQueueable implements Queueable , Database.AllowsCallouts 
{ 
    
    private Map<Id, String> accountOwnerMap = new Map<Id, String>();
    
    global ContractTriggerhandlerInsertQueueable(Map<Id, String> accountOwnerMapHandler)
    {   
        this.accountOwnerMap = accountOwnerMapHandler;
        
    }
    
    global void execute(QueueableContext context) 
    {
        try{
            for(Account acc : [select id,Name,IsMSTeamCreated__c,SPGroupID__c from Account where id in :accountOwnerMap.keyset()]){ 
                //Make a Future Callout by Passing the required Parameter              
                ContractTriggerhandler.CreateMSTeam(acc.Name,accountOwnerMap.get(acc.id),acc.Id,acc.IsMSTeamCreated__c,acc.SPGroupID__c);
                system.debug('Commented Future callout');
            }     
            
        }
        
        catch (Exception ex){
            system.debug('Excpetion in ContractTriggerhandlerInsertQueueable : '+ex.getMessage()+' Line Number : '+ex.getLineNumber());
        }
    }
    
}