/**
* @author Jozef 
* @date 12.9.2019.
* @description //TODO
*/

public with sharing class AccountTeamAndAuthTriggerHandler implements ITriggerHandler {
    public static AzureAD_Credential__c azureCredentials = [Select MicrosoftGraphURL__c,MSTeamsprefix__c From AzureAD_Credential__c];
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems) {
        setCheckUniqueType(newItems, null);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        setCheckUniqueType(newItems.values(), oldItems);
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {
    }
    
    public void AfterInsert(Map<Id, SObject> newItems) {
        scheduleAccTeamAuthjob(newItems.values(),'Insert');
        AptActionPlanSync.synchronizeAccountTeamAfterInsert(newItems);
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        AccTeamAndAuthUpdateQueue Queue = new AccTeamAndAuthUpdateQueue((Map<id,Account_Team_And_Authorizations__c>)newItems,(Map<id,Account_Team_And_Authorizations__c>)oldItems,'Delete');
        System.enqueueJob(Queue);
        AptActionPlanSync.synchronizeAccountTeamAfterUpdate(newItems, oldItems);
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems) {
        scheduleAccTeamAuthjob(oldItems.values(), 'Delete');
        AptActionPlanSync.synchronizeAccountTeamAfterDelete(oldItems);
    }
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {
    }
    
    //pick list Value of "Account Team And Authorizations" type
    private Boolean isUniqueType(Account_Team_And_Authorizations__c at){
        return at.Type__c ==  'Account_Owner' || at.Type__c ==  'Oppdragsansvarlig'
            || at.Type__c == 'Payroll_Responsible' || at.Type__c == 'Remittance Responsible' ||
            at.Type__c == 'Accounting Responsible';
    }
    
    
    // newItems and oldItems, which are lists of SObject records and maps of Id to SObject records, respectively.
    @TestVisible
    private void setCheckUniqueType(List<SObject> newItems, Map<Id, SObject> oldItems){
        Boolean newRecordsError = false;
        
        // checks for duplicates in the "newItems" list by creating a map "uniqueAts" 
        
        Map<String, Account_Team_And_Authorizations__c> uniqueAts = new  Map<String, Account_Team_And_Authorizations__c>();
        for (SObject o : newItems) {
            Account_Team_And_Authorizations__c at = (Account_Team_And_Authorizations__c)o;
            String unique = at.Kontrakt__c + at.Type__c;
            at.CheckUniqueType__c = unique;
            // Unique Type just for Account Owner, Authorized Accountant, Payroll Responsible, Accounting Responsible and Remittance Responsible.
            // checks if the "Type__c" is unique using the "isUniqueType" method.
            // If the type is unique, the method checks if there is already an entry in "uniqueAts" 
            if (isUniqueType(at)){
                if(uniqueAts.containsKey(unique)){
                    at.addError(System.Label.AptDuplicateTypeFound);
                    newRecordsError = true;
                }else {
                    if (oldItems == null){
                        uniqueAts.put(unique, at);
                    }else {
                        Account_Team_And_Authorizations__c oldRecord = (Account_Team_And_Authorizations__c) oldItems.get(o.id);
                        
                        //  compares the CheckUniqueType__c fields of the old and new records, 
                        //  and adds the new record to the uniqueAts map with the unique type as the key if they are not the same.
                        
                        if (at.CheckUniqueType__c != oldRecord.CheckUniqueType__c) {
                            at.CheckUniqueType__c = unique;
                            uniqueAts.put(unique, at);
                        }
                    }
                }
            }
        }
        if (newRecordsError == false && !uniqueAts.isEmpty()){
            List<Account_Team_And_Authorizations__c> aTeamExists = [SELECT id,CheckUniqueType__c FROM Account_Team_And_Authorizations__c
                                                                    WHERE CheckUniqueType__c IN : uniqueAts.keySet()];
            for (Account_Team_And_Authorizations__c aExist : aTeamExists) {
                Account_Team_And_Authorizations__c newAt = uniqueAts.get(aExist.CheckUniqueType__c);
                newAt.addError(System.Label.AptDuplicateTypeFound);
            }
        }
    }
    /*------------------------------
Devloper Name :- Gaurav
Method Name :- scheduleAccTeamAuthjob
Date :- 03/02/2023
---------------------------------*/ 
  public static void scheduleAccTeamAuthjob(list<Account_Team_And_Authorizations__c> accTeamAuthLst, string operationType){
        try{
            if(accTeamAuthLst.size()>0){
                if(Limits.getQueueableJobs() > 1)
                {
                    DateTime dt = System.now(); // DateTime.now();
                    DateTime adjustedDt = dt.addSeconds(10);
                    
                    String nextFireTime = adjustedDt.second() + ' ' + adjustedDt.minute() + ' ' + adjustedDt.hour() + ' * * ?';
                    System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, new AccTeamAndAuthTriggerHandlerScheduleJob(accTeamAuthLst, operationType));
                    
                }
                else
                {   
                    if(operationType == 'Insert'){
                    AccTeamAndAuthTriggerHandlerQueueablecls Queue = new AccTeamAndAuthTriggerHandlerQueueablecls(accTeamAuthLst, operationType);
                    System.enqueueJob(Queue);
                    }
                    else if(operationType == 'Delete'){
                     AccTeamAndAuthDeleteQueueable Queue = new AccTeamAndAuthDeleteQueueable(accTeamAuthLst,operationType);   
                     System.enqueueJob(Queue);
                    }
                     
                    
                }
                
            }
        }
        catch (Exception ex){
            system.debug('Excpetion in AddOwnerOrMember : '+ex.getMessage()+' Line Number : '+ex.getLineNumber());
        }
        
        
    }
    
    
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    DeleteOwners
Description:    Delete Owners from O365group. 
Inputs:         List<emails>, GroupID , token 
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
15 Sep 2019       Deepak                    -   
21 Oct 2019       Deepak            Added MS team in error email
----------------------------------------------------------------------------------------------------------------------------------*/
    public static void DeleteOwners(Set<String> emails,String GroupID,string token)
    {
        try{
            Account account = [select MailNickName__c from Account where SPGroupID__c=: GroupID limit 1];
            string jsonbodyEmail =  JsonBodyofUsersEmail(emails);
            Set<String> UserIds =  MakebatchCallout(jsonbodyEmail,token,'getUserIds',account.MailNickName__c);
            string jsonbodyUserIds =  JsonBodyofUsersIds(UserIds,GroupID,'owners');
            MakebatchCallout(jsonbodyUserIds,token,'owners',account.MailNickName__c);
        }
        catch (Exception ex){
            system.debug('Excpetion in DeleteOwners : '+ex.getMessage()+' Line Number : '+ex.getLineNumber());
        }
    }
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    AddnewMembersTogroup
Description:    Add new Members To O365group. 
Inputs:         List<emails>, GroupID , token 
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
15 Sep 2019       Deepak                    -   
21 Oct 2019       Deepak            Added MS team in error email
----------------------------------------------------------------------------------------------------------------------------------*/
    public static void AddnewMembersTogroup(Set<string> emails,string groupid,String token)
    {
        string jsonbody='';
        
        jsonbody +='{ "requests": [ ';
        Integer count = 0;
        for(string useremail : emails ){
            jsonbody += '{'+
                '"id": "'+count+'",'+
                '"method": "POST",'+
                '"url": "/groups/'+groupid+'/members/$ref", '+
                '"body": {"@odata.id": "' + azureCredentials.MicrosoftGraphURL__c + 'users/'+useremail+'"},'+
                '"headers": {"Content-Type": "application/json"}},';
            count++;
        }
        jsonbody = jsonbody.removeEnd(',');
        jsonbody += ']}';
        try{
            Account account = [select MailNickName__c from Account where SPGroupID__c=: groupid limit 1];
            //send json body to O365 group for adding members.
            MakebatchCallout(jsonbody,token,'',account.MailNickName__c);       
        }
        catch (Exception ex){
            system.debug('Excpetion in AddnewMembersTogroup : '+ex.getMessage()+' Line Number : '+ex.getLineNumber());
        }
    }
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    DeleteMembers
Description:    Delete Members from O365group. 
Inputs:         List<emails>, GroupID , token 
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
15 Sep 2019       Deepak                    -   
21 Oct 2019       Deepak            Added MS team in error email
----------------------------------------------------------------------------------------------------------------------------------*/
    public static void DeleteMembers(Set<String> emails,String GroupID,string token)
    {
        try{
            Account account = [select MailNickName__c from Account where SPGroupID__c=: GroupID limit 1];
            string jsonbodyEmail =  JsonBodyofUsersEmail(emails);
            Set<String> UserIds =  MakebatchCallout(jsonbodyEmail,token,'getUserIds',account.MailNickName__c);
            string jsonbodyUserIds =  JsonBodyofUsersIds(UserIds,GroupID,'members');
            MakebatchCallout(jsonbodyUserIds,token,'members',account.MailNickName__c);
        }
        catch (Exception ex){
            system.debug('Excpetion in DeleteMembers : '+ex.getMessage()+' Line Number : '+ex.getLineNumber());
        }
    }
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    JsonBodyofUsersEmail
Description:    Create a Json string with user Email to get userIds and make a batch callout.
Inputs:         List<emails> 
Outputs:        Json string 
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
15 Sep 2019       Deepak                    -   

----------------------------------------------------------------------------------------------------------------------------------*/
    public static string JsonBodyofUsersEmail(Set<String> emails){
        string jsonbody='';
        
        jsonbody +='{ "requests": [ ';
        Integer count = 0;
        for(string useremail : emails ){
            jsonbody += '{'+
                '"id": "'+count+'",'+
                '"method": "GET",'+
                '"url": "/users/'+useremail+'", '+
                '"headers": {"Content-type":"application/json"}},';
            count++;
        }
        jsonbody = jsonbody.removeEnd(',');
        jsonbody += ']}';
        
        return jsonbody;
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    JsonBodyofUsersIds
Description:    Create a Json string with userIds to delete owner or members to make a batch callout.
Inputs:         List<emails>, GroupID ,OwnerOrMember(create json body dynamcially as per passed parmeter)
Outputs:        Json string 
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
15 Sep 2019       Deepak                    -   

----------------------------------------------------------------------------------------------------------------------------------*/
    public static string JsonBodyofUsersIds(Set<String> userIDS,string groupId,string OwnerOrMember){
        
        string jsonbody='';
        jsonbody +='{ "requests": [ ';
        Integer count = 0;
        
        for(string userid : userIDS ){
            jsonbody += '{'+
                '"id": "'+count+'",'+
                '"method": "DELETE",'+
                '"url": "/groups/'+groupId+'/'+OwnerOrMember+'/'+userid+'/$ref" '+
                '},';
            count++;
        }
        jsonbody = jsonbody.removeEnd(',');
        jsonbody += ']}';
        return jsonbody;
    }
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    MakeBatchCallout
Description:    Make batch callout used for multiple batch callout.
Inputs:         json body, token ,ExceptionMessageKey(used for which type Exception mail is to send)
Outputs:        Set<String> only when it return the userids.
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
15 Sep 2019       Deepak                    -   
21 Oct 2019       Deepak            Added MS team in error email
----------------------------------------------------------------------------------------------------------------------------------*/
    public static Set<String> MakeBatchCallout(String body,string token,string ExceptionMessageKey,string AccountName){
        Set<String> spUserIds = new Set<String>();
        HttpRequest httpRequest = new HttpRequest();
        string Endpoint = azureCredentials.MicrosoftGraphURL__c + '$batch';
        
        httpRequest.setEndpoint(Endpoint);
        httpRequest.setMethod('POST');
        httpRequest.setBody(body);
        httpRequest.setHeader('Content-type','application/json');
        httpRequest.setHeader('Accept','application/json');
        httpRequest.setHeader('Authorization', token);
        try{
            HttpResponse httpResponse = new HttpResponse();
            Http http = new Http();
            httpResponse = http.send(httpRequest);
            system.debug('httpResponse status Code' + httpResponse.getStatusCode());
            system.debug('httpResponse Body ' + httpResponse.getBody());
            if(httpResponse.getStatusCode() == 200)
            {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                List<Object> batchResponse = (List<Object>)results.get('responses');
                for(Object obj : batchResponse)
                {
                    
                    Map<String, Object> a2 = (Map<String, Object>)obj;
                    Map<String, Object> batchbody = (Map<String, Object>)a2.get('body');
                    if(ExceptionMessageKey=='getUserIds'){
                        spUserIds.add((String)batchbody.get('id'));
                    }
                    Integer batchStatusCode = Integer.valueOf(a2.get('status'));
                    if(batchStatusCode == 404)
                    {                        
                        Map<String, Object> a4 = (Map<String, Object>)batchbody.get('error');
                        ContractTriggerhandler.sendErrorMail('Error : Resource is Not Found for ms teams: '+AccountName,String.valueOf(a4.get('message')),'REST');
                    }
                    system.debug('batchStatusCode ' + batchStatusCode);
                    system.debug('batchResponsebody ' + batchbody );
                    
                }
            }
            
        }
        catch(Exception ex)
        {
            if(ExceptionMessageKey=='owners'){
                ContractTriggerhandler.sendErrorMail('Exception has occurred when Deleting Owner(s) from teams: '+AccountName,ex.getMessage(),'EXC');
            }
            else if(ExceptionMessageKey=='members')
            {
                ContractTriggerhandler.sendErrorMail('Exception has occurred When Deleting  Member(s) from MS Teams: '+AccountName,ex.getMessage(),'EXC');
            }
            else if(ExceptionMessageKey=='getUserIds'){
                
                ContractTriggerhandler.sendErrorMail('Exception has occurred when Fetching UserId(s) for ms teams: '+AccountName,ex.getMessage(),'EXC');
            }
            else
            {
                ContractTriggerhandler.sendErrorMail('Exception has occurred When Adding Member(s) to MS Teams: '+AccountName,ex.getMessage(),'EXC');
            }
        }
        return spUserIds;
    }
    
   
}