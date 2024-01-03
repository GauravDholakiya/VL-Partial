/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         AccTeamAndAuthTriggerHandlerQueueable.cls 
Description:  Controller class creates Queue for create MS Teams In Sharepoint.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
15 Sep 2019        1.0         Deepak                None    Initial draft
04 Jun 2023                    Ole Erik @ Fluido             Remove references to SyncSalesforceAndSharepointUser
-------------------------------------------------------------------------------------------------------------------------------------------------------- */
global class AccTeamAndAuthTriggerHandlerQueueable implements Queueable , Database.AllowsCallouts  {

    Map<string,object> MapOfMembers = new Map<string,object>();
    Private string GroupID;
    global AccTeamAndAuthTriggerHandlerQueueable(Map<string,object> MapOfMembers,string GroupID)
    {
        this.MapOfMembers = MapOfMembers;
        this.GroupID = GroupID;
    }
    global void execute(QueueableContext context) {
        Set<String> AddOwnersList = new Set<string>();
        Set<String> AddMembersList = new Set<string>();
        Set<String> RemoveOwnersList = new Set<string>();
        Set<String> RemoveMembersList = new Set<string>();
        Set<String> users;
        string contractId='',token='';
        for(string key : MapOfMembers.keySet()){
            if(key=='AddOwnersList'){
                users = (Set<string>)MapOfMembers.get(key);
                for(User userEmailId : [Select Email From User  Where Id IN :users])   
                {
                    AddOwnersList.add(userEmailId.Email);
                }
            }
            if(key=='AddMembersList'){
                users = (Set<string>)MapOfMembers.get(key);
                system.debug('users : '+users);
                for(User userEmailId : [Select Email From User  Where Id IN :users])   
                {
                    AddMembersList.add(userEmailId.Email);
                }
            }
            if(key=='RemoveOwnersList'){
                users = (Set<string>)MapOfMembers.get(key);
                system.debug('users : '+users);
                for(User userEmailId : [Select Email From User  Where Id IN :users])   
                {
                    RemoveOwnersList.add(userEmailId.Email);
                }
            }
            if(key=='RemoveMembersList'){
                users = (Set<string>)MapOfMembers.get(key);
                system.debug('users : '+users);
                for(User userEmailId : [Select Email From User  Where Id IN :users])   
                {
                    RemoveMembersList.add(userEmailId.Email);
                }
            }
        }
        
        token = 'Bearer ' + TokenController.GetToken();        
          Map<string,Set<String>> result = new Map<string,Set<String>>();
        try{
            
            Account account = [select Id from Account where SPGroupID__c=: GroupID limit 1];
            
            if(AddOwnersList.size() > 0){
               // ContractTriggerhandler.SyncSalesforceAndSharepointUser(contractId, account.Id, AddOwnersList, true, false, token,GroupID,'Add');
            }
            if(AddMembersList.size() > 0){
              // ContractTriggerhandler.SyncSalesforceAndSharepointUser(contractId, account.Id, AddMembersList, false, true, token,GroupID,'Add');
               
            }
            if(RemoveOwnersList.size() > 0){
               // ContractTriggerhandler.SyncSalesforceAndSharepointUser(contractId, account.Id, RemoveOwnersList, true, false, token,GroupID,'Remove');
               
            }
            if(RemoveMembersList.size() > 0){
               // ContractTriggerhandler.SyncSalesforceAndSharepointUser(contractId, account.Id, RemoveMembersList, false, true, token,GroupID,'Remove');
            }
            
        } 
        catch (Exception ex){
            system.debug('Excpetion in AccTeamAndAuthTriggerHandlerQueueable : '+ex.getMessage()+' Line Number : '+ex.getLineNumber());
        }
    }
    
}