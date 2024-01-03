/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         AccountTriggerhandler.cls 
Description:  Controller class for Renaming SP Team when Account Name changed in .

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
July 2019        0.1         Deepak                None      Initial draft
March 2023		 0.2		 Jay                   None      Renaming SiteURL & MailNickName fields of Account Object, when Account name is changed.
-------------------------------------------------------------------------------------------------------------------------------------------------------- */
public class AccountTriggerhandler implements ITriggerHandler
{    
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems) {}
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems) {}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        AccountTriggerhandler.renameMSTeamsTitle(newItems,oldItems);
        AptAccountTriggerHandler.updateContractCountry(newItems,oldItems);
        CreateAccountec.checkconditions(newItems,oldItems);
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    public static void renameMSTeamsTitle(Map<Id,SObject> newAccountMap, Map<Id,SObject> oldAccountMap)
    {	
        List<Account> newAccountLST = new List<Account>();
        List<Account> oldAccountLST = new List<Account>();
        System.debug('old acc map values->'+(List<Account>)oldAccountMap.values());
        for(Account acc : (List<Account>)oldAccountMap.values())
        {	System.debug('Inside for loop,old acc map values->'+(List<Account>)oldAccountMap.values());
            Account newAccMapVal = (Account)newAccountMap.get(acc.Id);
            if(acc.IsMSTeamCreated__c && acc.Name != newAccMapVal.Name)
            {	system.debug('Inside 2nd for loop');
                Account newACC= (Account)newAccountMap.get(acc.Id);
                oldAccountLST.add(acc);   
                newAccountLST.add(newACC);
            }
        }
      
        if(newAccountLST.size() > 0 && oldAccountLST.size() > 0)
        {
            List<List<Account>> chunkOfNewAccount = (List<List<Account>>) SplitList.doPartions(newAccountLST, 45, List<List<Account>>.class);
            List<List<Account>> chunkOfOldAccount = (List<List<Account>>) SplitList.doPartions(oldAccountLST, 45, List<List<Account>>.class);
            System.debug('chunkOfNewAccount -->'+ chunkOfNewAccount);
            System.debug('chunkOfOldAccount -->'+ chunkOfOldAccount);
            
            for(Integer i = 0 ; i < chunkOfNewAccount.size() ; i++)
            {                           
                Map<Id,Account> newMap = new Map<Id,Account>();
                Map<Id,Account> oldMap = new Map<Id,Account>();
                
                for(Account newCon : chunkOfNewAccount[i])
                {
                    newMap.put(newCon.Id, newCon);
                }
                
                for(Account oldCon : chunkOfOldAccount[i])
                {
                    oldMap.put(oldCon.Id, oldCon);
                }
               system.Debug('Limits.getQueueableJobs()'+Limits.getQueueableJobs());
                if(Limits.getQueueableJobs() >= 1)
                {	system.debug('*');
                    DateTime dt = System.now(); // DateTime.now();  will also work here too
                    DateTime adjustedDt = dt.addSeconds(5);
                    
                    String nextFireTime = adjustedDt.second() + ' ' + adjustedDt.minute() + ' ' + adjustedDt.hour() + ' * * ?';
                    System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, new AccountTriggerhandlerUpdateSchedule(newMap,oldMap));
                
                }
                else
                {          system.debug('**');                 																							
                    AccountTriggerhandlerUpdateQueueable analyticsinsert = new AccountTriggerhandlerUpdateQueueable(newMap,oldMap);
                    ID jobID = System.enqueueJob(analyticsinsert);
                }
            }
        }
        
        /*for( Id accId : newAccountMap.keySet() )
{
Account newAccount = (Account)newAccountMap.get(accId);
Account oldAccount = (Account)oldAccountMap.get(accId);

if( oldAccount.Name != newAccount.Name )
{
if(oldAccount.IsMSTeamCreated__c)
{
updateAccountNameToO365Group(newAccount.Name,newAccount.SPGroupID__c);
} 
}
}*/
    }
    
    @future(callout=true)
    public static void updateAccountNameToO365Group(string accountName,string groupid){
        AzureAD_Credential__c objAzureCredential = [Select DevAPIEndPoint__c, ClientId__c,MSTeamsprefix__c, ClientSecretKey__c,Salesforce_ClientId__c,Salesforce_ClientSecret__c FROM AzureAD_Credential__c];
        try
        {
            HttpRequest httpRequest = new HttpRequest();
            
            string MSSiteEndpoint =  objAzureCredential.DevAPIEndPoint__c+'api/Teams/UpdateTeam';
            String authorization = objAzureCredential.Salesforce_ClientId__c + objAzureCredential.Salesforce_ClientSecret__c;
            String newaccountname = accountName.remove('\'').trim().replaceall('[^\\p{Alnum}]','');
            string body = '{"groupId":"'+groupid+'","newDisplayname": "'+objAzureCredential.MSTeamsprefix__c+newaccountname+'"}';
            httpResponse response =   GlobalAPICallOut.makeCallout(body,MSSiteEndpoint,'POST',authorization);
                string responseBody = response.getBody();
            system.debug('!!!!!!Response Body-->'+responseBody);
           
            if(string.isNotEmpty(responseBody))
            {
                Map<String, Object> responseMap1 = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                Integer statusCode = (Integer) responseMap1.get('statusCode');
                String message1 = (String) responseMap1.get('message');
                String grpId =  (String) responseMap1.get('groupId');
                system.debug('Outside 200 grpid-->'+grpId);
                if(statusCode == 200)
           		{
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    system.debug('responseMap-->'+responseMap);
                    String newSiteUrl = (String) ((Map<String, Object>)responseMap.get('data')).get('newSiteUrl');
                    String newnickName = (String) ((Map<String, Object>)responseMap.get('data')).get('newnickName');
                    String newEmail = (String) ((Map<String, Object>)responseMap.get('data')).get('newEmail');
                    String customerchannelURL =  (String) ((Map<String, Object>)responseMap.get('data')).get('customerChannelUrl');
                    String GroupId1= (String) ((Map<String, Object>)responseMap.get('data')).get('groupId');
                    String AccountingchannelURL = (String) ((Map<String, Object>)responseMap.get('data')).get('accountingChannelUrl');
                    String PayrollChannelURL =(String) ((Map<String, Object>)responseMap.get('data')).get('payrollChannelUrl'); 
                  
                    Account acrecord =[select Id,name from account where SPGroupID__c =:groupid];
                    List<Account> aclist= new List<Account>();
                    Account a =new Account();
                    a.id = acrecord.id;
                    a.SiteURL__c = newSiteUrl;
                    a.MailNickName__c = newnickName;
                    a.TeamEmail__c = newEmail;
                    a.CustomerChannelURL__c = customerchannelURL;
                    a.Accounting_Channel_URL__c = AccountingchannelURL;
                    a.Payroll_Channel_URL__c = PayrollChannelURL;
                    aclist.add(a);
                    system.debug('$$aclist-->'+aclist);
                    Database.update(aclist,true); 
                    CreateCustomLogHandler.addCustomlogAccountNameChange(responseBody,statusCode,message1,groupid);
                }else
                {
               	    CreateCustomLogHandler.addCustomlogAccountNameChange(responseBody,statusCode,message1,groupid);
                }
           }
      }
            
        catch(Exception ex)
        {
            ContractTriggerhandler.sendErrorMail('Error : Exception has Occured',ex.getMessage(),'EX');
        } 
    }
}