global class AccTeamAndAuthUpdateQueue implements Queueable , Database.AllowsCallouts {
    map<id,Account_Team_And_Authorizations__c> newActmaMap = new map<id,Account_Team_And_Authorizations__c>();
    map<id,Account_Team_And_Authorizations__c> oldActmaMap = new map<id,Account_Team_And_Authorizations__c>();
    String operationType;
    global AccTeamAndAuthUpdateQueue(map<id,Account_Team_And_Authorizations__c> newMap,map<id,Account_Team_And_Authorizations__c> oldMap, string operationType){
        this.newActmaMap = newMap;
        this.oldActmaMap = oldMap;
        this.operationType = operationType;
    }
    global void execute(QueueableContext context) {
        try {
            List<string> MSOwnerRolesList;
            MSTeamsOwnersRoles__c MSOwnerRoles =[select ListOwners__c from MSTeamsOwnersRoles__c];
            
            if(MSOwnerRoles.ListOwners__c!=null){
                MSOwnerRolesList = MSOwnerRoles.ListOwners__c.split(',');
            }
            
            list<string> typeAccLst = new list<string> {'Sales Consultant','Accounting Responsible','Accounting Consultant','Accounting Consultant 2','Executive Sponsor','Integration_Resource','Project_Manager','Remittance Responsible','Accounting Controller','Quality Consultant','Year end Responcible','Year end Consultant','Customer Success Manager'};
            list<string> typePayrollLst = new list<string> {'Payroll Consultant','Payroll Consultant 2','Payroll_Responsible','Project Manager Payroll','Quality Consultant Payroll'};                
            Map<string,List<AccTeamAuthWrapp>> accAtMap = new Map<string,List<AccTeamAuthWrapp>>();
            
            for(Account_Team_And_Authorizations__c act : newActmaMap.values()){  
                String groupid = act.Account_SPGroupId__c;
                System.debug('Group ID:' +groupid);
                if(string.isNotEmpty(groupid) && act.Responsible__c != null){
                    if(accAtMap.containsKey(groupid)){
                        List<AccTeamAuthWrapp> tempactmWrapp = accAtMap.get(groupid);  
                        tempactmWrapp.add(new AccTeamAuthWrapp(act,oldActmaMap.get(act.Id)));
                        accAtMap.put(groupid,tempactmWrapp);   
                    }
                    else{
                        AccTeamAuthWrapp actmWrapp = (new AccTeamAuthWrapp(act,oldActmaMap.get(act.Id)));
                        accAtMap.put(groupid,new List<AccTeamAuthWrapp> {actmWrapp});
                    }
                }
            }
            
            system.debug('accAtMap -->'+accAtMap);
            
            Map<string,List<Account_Team_And_Authorizations__c>> accAllAtMap = new Map<string,List<Account_Team_And_Authorizations__c>>();
            list<Account_Team_And_Authorizations__c> accAllAtLst = [Select Id,Responsible__c,Type__c,Account_Id__c,Account_SPGroupId__c from Account_Team_And_Authorizations__c where Account_SPGroupId__c in :accAtMap.keySet() AND id not in :oldActmaMap.keySet()];
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
            
            system.debug('accAllAtMap-->'+accAllAtMap);
            for (String groupId : accAtMap.keySet()) {
                map<string, object> mapToSerialize = new map<string, object>();
                List<map<String, String>> getOwnerList = new List<map<String, String>>();
                List<map<String, String>> memberList = new List<map<String, String>>();  
                
                for(AccTeamAuthWrapp actmwrap:accAtMap.get(groupId)){
                    
                    Account_Team_And_Authorizations__c newRecord = actmwrap.newActmaRec;
                    Account_Team_And_Authorizations__c oldRecord = actmwrap.oldActmaRec;
                    
                    integer countUnmatch = 0;
                    
                    if(newRecord.Type__c != oldRecord.Type__c || newRecord.Responsible__c != oldRecord.Responsible__c){
                        
                        if(accAllAtMap.containsKey(groupId)){
                            for(Account_Team_And_Authorizations__c allact: accAllAtMap.get(groupId)){
                                if(oldRecord.Responsible__c == allact.Responsible__c){
                                    if(MSOwnerRolesList.contains(allact.Type__c)){
                                        break;
                                    }
                                    else if(oldRecord.Type__c == allact.Type__c){
                                        break;
                                    }
                                    else if(typeAccLst.contains(oldRecord.Type__c) && typeAccLst.contains(allact.Type__c)){
                                        break;
                                    }
                                    else if(typeAccLst.contains(oldRecord.Type__c) && typePayrollLst.contains(allact.Type__c)){
                                        break;
                                    }
                                    else if(typePayrollLst.contains(oldRecord.Type__c) && typeAccLst.contains(allact.Type__c)){
                                        map<string, string> memberMap = new map<string, string>();
                                        memberMap.put('email', oldRecord.Responsible_Email__c);
                                        memberMap.put('channelName', 'Payroll – Shared Channel');
                                        memberMap.put('operationType','Delete');
                                        memberList.add(memberMap);
                                    }
                                    else if(typePayrollLst.contains(oldRecord.Type__c) && typePayrollLst.contains(allact.Type__c)){
                                        break;
                                    }
                                    
                                }
                                else{
                                    countUnmatch = countUnmatch + 1;
                                    
                                }
                            }
                            
                            if(countUnmatch == accAllAtMap.get(groupId).size()){
                                if (MSOwnerRolesList.contains(oldRecord.Type__c)) {
                                    
                                    map<string, string> ownerMap = new map<string, string>();
                                    ownerMap.put('email', oldRecord.Responsible_Email__c);
                                    ownerMap.put('operationType', 'Delete');
                                    getOwnerList.add(ownerMap);
                                    
                                    
                                } else {
                                    
                                    List<String> strList = ATATMembers.GetTypes(oldRecord.Type__c);
                                    for (String str : strList) {
                                        
                                        map<string, string> memberMap = new map<string, string>();
                                        memberMap.put('email', oldRecord.Responsible_Email__c);
                                        memberMap.put('channelName', str);
                                        memberMap.put('operationType','Delete');
                                        memberList.add(memberMap);
                                        
                                        
                                    }
                                    
                                }
                            }
                            
                            
                        }
                        else{
                            if (MSOwnerRolesList.contains(oldRecord.Type__c)) {
                                
                                map<string, string> ownerMap = new map<string, string>();
                                ownerMap.put('email', oldRecord.Responsible_Email__c);
                                ownerMap.put('operationType', 'Delete');
                                getOwnerList.add(ownerMap);
                                
                                
                            } else {
                                
                                List<String> strList = ATATMembers.GetTypes(oldRecord.Type__c);
                                for (String str : strList) {
                                    
                                    map<string, string> memberMap = new map<string, string>();
                                    memberMap.put('email', oldRecord.Responsible_Email__c);
                                    memberMap.put('channelName', str);
                                    memberMap.put('operationType','Delete');
                                    memberList.add(memberMap);
                                    
                                    
                                }
                                
                            }
                        }
                        
                        if(MSOwnerRolesList.contains(newRecord.Type__c)){
                            map<string, string> ownerMap = new map<string, string>();
                            ownerMap.put('email', newRecord.Responsible_Email__c);
                            ownerMap.put('operationType', 'Insert');
                            getOwnerList.add(ownerMap);
                        }
                        else{
                            List<String> strList = ATATMembers.GetTypes(newRecord.Type__c);
                            
                            for (String str : strList) {
                                map<string, string> memberMap = new map<string, string>();
                                memberMap.put('email', newRecord.Responsible_Email__c);
                                memberMap.put('channelName', str);
                                memberMap.put('operationType','Insert');
                                memberList.add(memberMap);
                                
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
                        AccountTeamAndAuthCallOutHandller.addMembersAndOwners(body,groupid);
                        // System.debug(body);
                    }
                }
                
            }
        }
        catch(Exception ex) {
            system.debug('Error on AccTeamAndAuthUpdateQueue-->'+ex.getMessage());
        }
        
    }
    
    global class AccTeamAuthWrapp{
       Account_Team_And_Authorizations__c newActmaRec;
       Account_Team_And_Authorizations__c oldActmaRec;
        
        AccTeamAuthWrapp(Account_Team_And_Authorizations__c newRec, Account_Team_And_Authorizations__c oldRec){
            this.newActmaRec = newRec;
            this.oldActmaRec = oldRec;
        }


    }
    
    
    
}