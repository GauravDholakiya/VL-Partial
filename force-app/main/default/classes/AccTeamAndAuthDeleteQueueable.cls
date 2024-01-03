global class AccTeamAndAuthDeleteQueueable implements Queueable , Database.AllowsCallouts {
    
    List<Account_Team_And_Authorizations__c> accTeamAuthLst = new List<Account_Team_And_Authorizations__c>();
    public String operationType;
    
    global AccTeamAndAuthDeleteQueueable(List<Account_Team_And_Authorizations__c> accTeamAuthLst, String operationType){
        
        this.accTeamAuthLst = accTeamAuthLst;
        this.operationType = operationType; 
    }
    
    global void execute(QueueableContext context) {
        try{
            List<string> MSOwnerRolesList;
            MSTeamsOwnersRoles__c MSOwnerRoles =[select ListOwners__c from MSTeamsOwnersRoles__c];
            
            if(MSOwnerRoles.ListOwners__c!=null){
                MSOwnerRolesList = MSOwnerRoles.ListOwners__c.split(',');
            }
            
            list<string> typeAccLst = new list<string> {'Sales Consultant','Accounting Responsible','Accounting Consultant','Accounting Consultant 2','Executive Sponsor','Integration_Resource','Project_Manager','Remittance Responsible','Accounting Controller','Quality Consultant','Year end Responcible','Year end Consultant','Customer Success Manager'};
            list<string> typePayrollLst = new list<string> {'Payroll Consultant','Payroll Consultant 2','Payroll_Responsible','Project Manager Payroll','Quality Consultant Payroll'};        
            Map<string,List<Account_Team_And_Authorizations__c>> accAtMap = new Map<string,List<Account_Team_And_Authorizations__c>>();
            for(Account_Team_And_Authorizations__c actma : accTeamAuthLst){
                if(actma.Responsible__c != null){
                    String groupid = actma.Account_SPGroupId__c;
                    System.debug('Group ID:' +groupid);
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
            
            Map<string,List<Account_Team_And_Authorizations__c>> accAllAtMap = new Map<string,List<Account_Team_And_Authorizations__c>>();
            list<Account_Team_And_Authorizations__c> accAllAtLst = [Select Id,Responsible__c,Type__c,Account_Id__c,Account_SPGroupId__c from Account_Team_And_Authorizations__c where Account_SPGroupId__c in :accAtMap.keySet() and Responsible__c != null];
            if(accAllAtLst.size() > 0){
                for(Account_Team_And_Authorizations__c actma : accAllAtLst){
                    
                    String spgroupid = actma.Account_SPGroupId__c;
                    if(accAllAtMap.containsKey(spgroupid)){
                        List<Account_Team_And_Authorizations__c> tempActmallLst = accAllAtMap.get(spgroupid);
                        tempActmallLst.add(actma);
                        accAllAtMap.put(spgroupid,tempActmallLst);
                        
                    }
                    else{
                        accAllAtMap.put(spgroupid,new List<Account_Team_And_Authorizations__c> {actma});
                    }
                }
            }
            
            for (String groupId : accAtMap.keySet()) {
                map<string, object> mapToSerialize = new map<string, object>();
                List<map<String, String>> getOwnerList = new List<map<String, String>>();
                List<map<String, String>> memberList = new List<map<String, String>>();
                for (Account_Team_And_Authorizations__c act : accAtMap.get(groupId)) {
                    integer countUnmatch = 0;
                    if(accAllAtMap.containsKey(groupId)){              
                        for(Account_Team_And_Authorizations__c allact: accAllAtMap.get(groupId)){
                            
                            if(act.Responsible__c == allact.Responsible__c){
                                
                                if(MSOwnerRolesList.contains(allact.Type__c)){
                                    break;
                                }
                                else if(act.Type__c == allact.Type__c){
                                    break;
                                }
                                else if(typeAccLst.contains(act.Type__c) && typeAccLst.contains(allact.Type__c)){
                                    break;
                                }
                                else if(typeAccLst.contains(act.Type__c) && typePayrollLst.contains(allact.Type__c)){
                                    break;
                                }
                                else if(typePayrollLst.contains(act.Type__c) && typeAccLst.contains(allact.Type__c)){
                                    
                                    map<string, string> memberMap = new map<string, string>();
                                    memberMap.put('email', act.Responsible_Email__c);
                                    memberMap.put('channelName', 'Payroll – Shared Channel');
                                    memberMap.put('operationType',operationType);
                                    memberList.add(memberMap);
                                }
                                else if(typePayrollLst.contains(act.Type__c) && typePayrollLst.contains(allact.Type__c)){
                                    break;
                                }
                                
                            }
                            else{
                                
                                countUnmatch = countUnmatch + 1;
                                
                            }
                        }
                        system.debug('accAllAtMap.get(groupId).size())'+ accAllAtMap.get(groupId).size());
                        system.debug('countUnmatch '+countUnmatch );
                        if(countUnmatch == accAllAtMap.get(groupId).size()){
                            if (MSOwnerRolesList.contains(act.Type__c) || act.Type__c == 'Account_Owner' || act.Type__c == 'Accounting_Consultant') {
                                
                                map<string, string> ownerMap = new map<string, string>();
                                ownerMap.put('email', act.Responsible_Email__c);
                                ownerMap.put('operationType', operationType);
                                getOwnerList.add(ownerMap);
                                system.debug('getOwnerList'+ getOwnerList);
                                
                            } else {
                                
                                List<String> strList = ATATMembers.GetTypes(act.Type__c);
                                for (String str : strList) {
                                    
                                    map<string, string> memberMap = new map<string, string>();
                                    memberMap.put('email', act.Responsible_Email__c);
                                    memberMap.put('channelName', str);
                                    memberMap.put('operationType',operationType);
                                    memberList.add(memberMap);
                                    
                                    
                                }
                                
                            }
                        }
                    }
                    else{
                        if (MSOwnerRolesList.contains(act.Type__c) || act.Type__c == 'Account_Owner' || act.Type__c == 'Accounting_Consultant') {
                            // Create a map for the owner and add it to the owner list
                            map<string, string> ownerMap = new map<string, string>();
                            ownerMap.put('email', act.Responsible_Email__c);
                            ownerMap.put('operationType', operationType);
                            getOwnerList.add(ownerMap);
                            system.debug('getOwnerList'+ getOwnerList);
                            
                        } else {
                            
                            List<String> strList = ATATMembers.GetTypes(act.Type__c);
                            for (String str : strList) {
                                
                                map<string, string> memberMap = new map<string, string>();
                                memberMap.put('email', act.Responsible_Email__c);
                                memberMap.put('channelName', str);
                                memberMap.put('operationType',operationType);
                                memberList.add(memberMap);
                                
                                
                            }
                            
                        }
                    }
                    
                    
                }
                if(getOwnerList.size()>0 || memberList.size()>0){
                    mapToSerialize.put('groupId', groupId);
                    mapToSerialize.put('owners', getOwnerList);
                    mapToSerialize.put('members', memberList);
                }
                
                if(!mapToSerialize.isEmpty()){
                    string body = JSON.serialize(mapToSerialize);
                    System.debug('Body after serialization: ' + body);
                    AccountTeamAndAuthCallOutHandller.addMembersAndOwners(body,groupId);
                    System.debug(body);
                }
            }
            
        }
        catch(Exception ex) {
            system.debug('Error on AccTeamAndAuthDeleteQueueable-->'+ex.getMessage());
        }  
    }
    
}