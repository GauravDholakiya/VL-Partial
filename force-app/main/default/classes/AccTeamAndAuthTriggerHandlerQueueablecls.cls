global class AccTeamAndAuthTriggerHandlerQueueablecls implements Queueable , Database.AllowsCallouts  {
    
    List<Account_Team_And_Authorizations__c> accTeamAuthLst = new List<Account_Team_And_Authorizations__c>();
    String operationType;
    
    
    global AccTeamAndAuthTriggerHandlerQueueablecls(List<Account_Team_And_Authorizations__c> accTeamAuthLst, String operationType){
        
        this.accTeamAuthLst = accTeamAuthLst;
        this.operationType = operationType;
              
    }
    
    global void execute(QueueableContext context) {
        try {
            List<string> MSOwnerRolesList;
            MSTeamsOwnersRoles__c MSOwnerRoles =[select ListOwners__c from MSTeamsOwnersRoles__c];
            
            if(MSOwnerRoles.ListOwners__c!=null){
                MSOwnerRolesList = MSOwnerRoles.ListOwners__c.split(',');
            }
            Map<string,List<Account_Team_And_Authorizations__c>> accAtMap = new Map<string,List<Account_Team_And_Authorizations__c>>();
            for(Account_Team_And_Authorizations__c actma : accTeamAuthLst){
                
                String groupid = actma.Account_SPGroupId__c;
                System.debug('Group ID:' +groupid);
                if(string.isNotEmpty(groupid) && actma.Responsible__c != null){
                if(accAtMap.containsKey(groupid)){
                    List<Account_Team_And_Authorizations__c> tempActmaLst = accAtMap.get(groupid);
                    tempActmaLst.add(actma);
                    accAtMap.put(groupid,tempActmaLst);
                    
                }
                else{
                    accAtMap.put(groupid,new List<Account_Team_And_Authorizations__c> {actma});
                }
                }
            }
            
            if(!accAtMap.isEmpty()){
            map<string, object> mapToSerialize = new map<string, object>();
            for (String groupId : accAtMap.keySet()) {
                mapToSerialize.put('groupId', groupId);
                
                
                
                List<map<String, String>> getOwnerList = new List<map<String, String>>();
                List<map<String, String>> memberList = new List<map<String, String>>();
                for (Account_Team_And_Authorizations__c act : accAtMap.get(groupId)) {
                    
                    // Check if the account team and authorization record type is in the MSOwnerRolesList
                    if (MSOwnerRolesList.contains(act.Type__c) || act.Type__c == 'Account_Owner' || act.Type__c == 'Oppdragsansvarlig') {
                        // Create a map for the owner and add it to the owner list
                        map<string, string> ownerMap = new map<string, string>();
                        ownerMap.put('email', act.Responsible_Email__c);
                        ownerMap.put('operationType', operationType);
                        getOwnerList.add(ownerMap);
                        system.debug('getOwnerList'+ getOwnerList);
                        
                    } else {
                        // If the account team and authorization record type is not in the MSOwnerRolesList, 
                        // get the member types using the ATATMembers class and loop through each member type
                        List<String> strList = ATATMembers.GetTypes(act.Type__c);
                        for (String str : strList) {
                            // Create a map for the member and add it to the member list
                            map<string, string> memberMap = new map<string, string>();
                            memberMap.put('email', act.Responsible_Email__c);
                            memberMap.put('channelName', str);
                            memberMap.put('operationType',operationType);
                            memberList.add(memberMap);
                            system.debug('memberList'+memberList);
                            
                        }
                        
                    }
                }
                mapToSerialize.put('owners', getOwnerList);
                mapToSerialize.put('members', memberList);
                
                System.debug('Map before serialization: ' + mapToSerialize);
                string body = JSON.serialize(mapToSerialize);
                System.debug('Body after serialization: ' + body);
                AccountTeamAndAuthCallOutHandller.addMembersAndOwners(body,groupId);
                System.debug(body);
            }  
            }
        }
        
        catch(Exception ex) {
            system.debug('Error on AccTeamAndAuthTriggerHandlerQueueablecls-->'+ex.getMessage());
        }
    }
}