/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         ContractTriggerhandlerUpdateQueueable.cls 
Description:  Controller class creates Queue for update MS Teams In Sharepoint.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
Aug 2019        1.0         Parthesh                None    Initial draft
21 Oct 2019     2.0         Deepak                          Contract Owner Repliaction.
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

global class ContractTriggerhandlerUpdateQueueable implements Queueable , Database.AllowsCallouts
{
    Map<Id,String> contractRecordTypes = new Map<Id,String>();
    Map<Id,Contract__c> contractNewMAP = new Map<Id,Contract__c>();
    Map<Id,Contract__c> contractOldMAP = new Map<Id,Contract__c>();
    
    global ContractTriggerhandlerUpdateQueueable(Map<Id,Contract__c> contractCLSNewMap,Map<Id,Contract__c> contractCLSOldMap)
    {
        this.contractNewMAP = contractCLSNewMap;
        this.contractOldMAP = contractCLSOldMap;
    }
    
    global void execute(QueueableContext context) 
    {
        Set<Id> SetOfaccountIDS = new Set<Id>();
        Set<String> DeleteOwnerSet = New Set<String>();
        Set<String> NewOwnerSet = new Set<String>();
        String OldUser ='',NewUser= '',GroupID= '',token= '',accountId='';
        Contract__c contract,newContract,oldContract;
        
        for( Id contractId : contractNewMAP.keySet() )
        {
            contract = (Contract__c)contractNewMAP.get( contractId );
            SetOfaccountIDS.add(contract.Account__c);
        }
        
        try{
            
            Map<Id,Account> mapOfAccountGroupIDS = new Map<Id,Account>([Select SPGroupID__c,IsMSTeamCreated__c From Account where Id IN :SetOfaccountIDS AND (SPGroupID__c != '' OR SPGroupID__c != NULL) AND IsMSTeamCreated__c = true]);
            Map<Id,User> MapOfUser = new Map<Id,User>([Select Email From User where IsActive = true]);

            token = 'Bearer ' + TokenController.GetToken();           
            
            for( Id contractId : contractNewMAP.keySet() )
            {
                newContract = (Contract__c)contractNewMAP.get( contractId );
                oldContract = (Contract__c)contractOldMAP.get( contractId );
                
                if(mapOfAccountGroupIDS.get(newContract.Account__c).IsMSTeamCreated__c)
                {
                    if(mapOfAccountGroupIDS.get(newContract.Account__c).SPGroupID__c != null || mapOfAccountGroupIDS.get(newContract.Account__c).SPGroupID__c != '')
                    { 
                        GroupID = mapOfAccountGroupIDS.get(newContract.Account__c).SPGroupID__c;   
                        if(newContract.OwnerId!=null){
                            NewUser = MapOfUser.get(newContract.OwnerId).Email;
                            NewOwnerSet.add(NewUser);
                        }
                        if(oldContract.OwnerId!=null){
                            OldUser = MapOfUser.get(oldContract.OwnerId).Email;
                            DeleteOwnerSet.add(OldUser);
                        }
                    }
                }
            }
            string contractid='';
            if(DeleteOwnerSet.size() > 0 && GroupID != '')
            {
                system.debug('DeleteOwnerSet : updateQueue : '+DeleteOwnerSet);
                ContractTriggerhandler.SyncSalesforceAndSharepointUser(contractId, accountId, DeleteOwnerSet, true, false, token,GroupID,'Remove');
                
            }
            
            if(NewOwnerSet.size() > 0  && GroupID != '')
            {
                system.debug('NewOwnerSet : updateQueue : '+NewOwnerSet);
                ContractTriggerhandler.SyncSalesforceAndSharepointUser(contractId, accountId, NewOwnerSet, true, false, token,GroupID,'Add');
                
            }
        }
        catch (Exception ex){
            system.debug('Excpetion in ContractTriggerhandlerUpdateQueueable : '+ex.getMessage()+' Line Number : '+ex.getLineNumber());
        }
        
    }
}