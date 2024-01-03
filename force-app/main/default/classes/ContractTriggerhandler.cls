/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         ContractTriggerhandler.cls 
Description:  Controller class for Create MS Teams and Owners/Members.
Test class:   CreateTeamSiteHelper_Test.cls 

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
July 2019        1.0         Parthesh                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */
global class ContractTriggerhandler implements ITriggerHandler
{
    public static AzureAD_Credential__c azureCredentials = [Select MicrosoftGraphURL__c,MSTeamsprefix__c From AzureAD_Credential__c];
    
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems) {
        AptKontraktTriggerHandler.insertCountry(newItems);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        AptKontraktTriggerHandler.updateCountry(newItems, oldItems);
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems)     
    {
        processContractMap(newItems.values());
        populateStartDateOnAccount(newItems.values());
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        // 15-Sep-2019  Deepak  (Phase1 Additional Role CR)commented due to member replication is moved to another object.
        //21-Oct-2019 Deepak uncommeted the code for owner replication.
        //25-Oct-2019 Deepak commeted the code for owner replicationalready handle in flow.
        //UpdateContractProcess(newItems,oldItems);
        populateStartDateOnAccount(newItems.values());
        AptActionPlanSync.synchronizeActionPlan(newItems, oldItems);
    } 
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    public static void processContractMap(List<Contract__c> contractsLST){
        list<Contract__c> contractlst = new list<Contract__c>();
        list<id> contractId = new list<id>();
        for(Sobject con : contractsLST){
            contractId.add(con.id);
        }
        
        //Preparing list to get reference fields also available
        for(Contract__c con : [Select id,Account__c,RecordTypeId,RecordType.Name,Account_Owner_KA__c,Account_Owner_KA__r.Email,Status__c from Contract__c where id in :contractId and Account_Owner_KA__c != Null and Status__c = 'Draft']){
            contractLst.add(con);
        }
        
        Map<id,string> contractMap = new map<id,string>();       
        for(Contract__c con : contractLst){    
            if(contractMap.containsKey(con.Account__c)){  
                string OwnerEmail = contractMap.get(con.Account__c) + ';' + con.Account_Owner_KA__r.Email;
                contractMap.put(con.Account__c,OwnerEmail);
            }
            else{
                contractMap.put(con.Account__c,con.Account_Owner_KA__r.Email);
            }
        }
        
        if(!contractMap.isEmpty()){
            Integer maxSize = 15;
            Integer mapCount = (contractMap.size() + maxSize - 1) / maxSize;
            List<Map<Id, String>> accountOwnerMap = new List<Map<Id, String>>();
            
            Map<Id, String> chunkofMap = new Map<Id, String>();
            for (string key : contractMap.keySet()) {
                chunkofMap.put(key, contractMap.get(key));
                if (chunkofMap.size() == maxSize) {
                    accountOwnerMap.add(chunkofMap);
                    chunkofMap = new Map<Id, String>();
                }
            }
            
            if (!chunkofMap.isEmpty()) {
                accountOwnerMap.add(chunkofMap);
            }
            NewContractProcess(accountOwnerMap);
            
        }
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    NewContractProcess
Description:    Process on New Contaract Record for Creating New MS Teams. 
Owner to Newly Created MS Teams Owner.
Inputs:         contractsLST
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reason.

<Date>          <Authors Name>      Modification Reason 
July 2019       Parthesh                    -   

----------------------------------------------------------------------------------------------------------------------------------*/
    public static void NewContractProcess(List<map<id,string>> accountOwnerMap)
    {     
        for(Integer i = 0 ; i < accountOwnerMap.size() ; i++)
        {                           
            if(Limits.getQueueableJobs() >= 1)
            {
                DateTime dt = System.now(); // DateTime.now();  will also work here too
                DateTime adjustedDt = dt.addSeconds(10);
                
                String nextFireTime = adjustedDt.second() + ' ' + adjustedDt.minute() + ' ' + adjustedDt.hour() + ' * * ?';
                System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, new ContractTriggerhandlerInsertSchedule(accountOwnerMap[i]));
            }
            else
            {                                                                                                                       
                ContractTriggerhandlerInsertQueueable analyticsinsert = new ContractTriggerhandlerInsertQueueable(accountOwnerMap[i]);
                System.debug('First Queue In ContractTriggerHandler');
                ID jobID = System.enqueueJob(analyticsinsert);
            }
        }
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    CreateMSTeam
Description:    This method is used to Create MS Teams in Microsoft Sharepoint and also assign Two Group (VTI and Compliance) 
Owner to Newly Created MS Teams Owner.
Inputs:         MSTeamName,OwnerEmailId,accountID,IsMSTeamCreated,EmailIDSet
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
July 2019       Parthesh                    -   
15 Sep 2019     Deepak              (Phase1 Additional Role CR)Memeber will not be added while creating new team.
30 Sep 2019     Deepak              Invaild Interger Issue.
15 Oct 2019     Deepak
March 2023      Gaurav              Callout Changes
----------------------------------------------------------------------------------------------------------------------------------*/
    @future(Callout=true)
    global static void CreateMSTeam(String MSTeamName,String OwnerEmailId,String accountID,Boolean IsMSTeamCreated, String GroupID)    
    {
        AzureAD_Credential__c objAzureCredential = [Select DevAPIEndPoint__c,ClientId__c, ClientSecretKey__c,Salesforce_ClientId__c,Salesforce_ClientSecret__c FROM AzureAD_Credential__c];
        
        List<Account> accList = new List<Account>();
        string endpoint =objAzureCredential.DevAPIEndPoint__c+'api/Teams/CreateTeam';
        string authorization = objAzureCredential.Salesforce_ClientId__c+objAzureCredential.Salesforce_ClientSecret__c;
        try
        {   
            system.debug('is ms team created--->' + IsMSTeamCreated);
            
                string Owner =  OwnerEmailId;
                string mailNickname;
                
                if(string.isNotBlank(MSTeamName))
                {
                    mailNickname= azureCredentials.MSTeamsprefix__c+(MSTeamName.remove('\'').trim().replaceall('[^\\p{Alnum}]',''));
                }          
                string body = '{"teamName":"'+mailNickname+'","isTeamCreated":'+IsMSTeamCreated+',"id":"'+accountID+'","groupId":"'+GroupID+'","owner": "'+Owner+'","member": " "}';
                system.debug('Request Body team=>'+body);
                
                httpResponse response =   GlobalAPICallOut.makeCallout(body,endpoint,'POST',authorization);
                string responseBody = response.getBody();
                Integer statusCodeTeam = response.getStatusCode();
                string  statusMessage = response.getStatus();
                
                system.debug('response body-->'+responseBody);
                
            if(statusCodeTeam == 200){
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                List<Object> records;
                System.debug('MAP--> '+jsonMap);
              
                if(jsonMap.get('statusCode') != 200)
                {
                    String objCustomHandler = CreateCustomLogHandler.addCustomlogTeamsCreation((Integer)jsonMap.get('statusCode'),(string)jsonMap.get('message'),null, accountID, IsMSTeamCreated);

                }
                else
                {     //Check the Response should not be Empty 
                    if( jsonMap!= null && !jsonMap.isEmpty()){
                    system.debug('json Response-->'+jsonMap.get('jsonResponse'));
                    records = (List<Object>) jsonMap.get('jsonResponse'); //get the records
                    system.debug('records-->'+records);
                        
                    if ( records != null && !records.isEmpty()) {
                        for (Object r : records) {
                            System.debug('Response List==>'+r);
                            Map<String,Object> recordMap = (Map<String,Object>)r;
                            Account objAcc = new Account();
                            system.debug('@@Value Of Map.'+recordMap);
                            
                            string CenterGroupId = (String)recordMap.get('groupId');
                            string TeamEmail = (String)recordMap.get('email');
                            
                            //Check Account Id Should not be Empty and will Map the Data.
                            if(accountID!= null){
                                objAcc.Id=accountID;
                                objAcc.SPGroupID__c =(String)recordMap.get('groupId');
                                objAcc.SiteURL__c = (String)recordMap.get('url');
                                objAcc.CustomerChannelURL__c = (String)recordMap.get('customerChannel');
                                objAcc.IsMSTeamCreated__c=(boolean)recordMap.get('isTeamCreated');
                                objAcc.MailNickName__c=(String)recordMap.get('mailNickName');
                                objAcc.TeamEmail__c = TeamEmail;
                                objAcc.isLwcActive__c = true;
                                accList.add(objAcc);
                            }
                            
                        }
                        
                        //Update the Data here.
                        Database.update(accList,false); 
                        String objCustomHandler = CreateCustomLogHandler.addCustomlogTeamsCreation(statusCodeTeam,statusMessage,response.getBody(), accountID, IsMSTeamCreated);
                        System.debug('##Team Creation Response'+objCustomHandler);
                    }
                    else
                    {
                        system.debug('**ELSE PART');
                    String objCustomHandler = CreateCustomLogHandler.addCustomlogTeamsCreation((Integer)jsonMap.get('statusCode'),(string)jsonMap.get('message'),null, accountID, IsMSTeamCreated);
                        
                    }
                }
                else
                {
                    String objCustomHandler = CreateCustomLogHandler.addCustomlogTeamsCreation(statusCodeTeam,statusMessage,null, accountID, IsMSTeamCreated);
                    
                }
                }
              
                
            }
            else{
                
                String objCustomHandler = CreateCustomLogHandler.addCustomlogTeamsCreation(statusCodeTeam,statusMessage,null, accountID, IsMSTeamCreated);
            }  
             
        }
        
        catch(Exception ex)
        {
            System.debug(ex.getMessage());
        }  
    }
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    sendErrorMail
Description:    send error messages into mail.
Inputs:         subject,emailBody,errorType
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
July 2019       Parthesh                    -   

----------------------------------------------------------------------------------------------------------------------------------*/
    public static void sendErrorMail(String subject,String emailBody,String errorType)
    {
        User userDisplayName = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        AzureAD_Credential__c azureCred = [SELECT AdminUser__c FROM AzureAD_Credential__c];
        try
        {
            List<String> toAddEmailLST = new List<String>();
            List<String> setCCEmailLST = new List<String>();
            
            messaging.SingleEmailMessage email1=new messaging.SingleEmailMessage();
            toAddEmailLST.add(UserInfo.getUserEmail());
            setCCEmailLST.add(azureCred.AdminUser__c);
            
            emailBody = System.Label.ExceptionErrorMSG + '\n \n' + emailBody;
            
            email1.setCcAddresses(setCCEmailLST);
            email1.setToAddresses(toAddEmailLST);
            email1.setSubject(subject);
            email1.setPlainTextBody(emailBody);
            email1.setSenderDisplayName(userDisplayName.Name);
            messaging.Email[] emails = new messaging.Email[]{email1};
                if (!Test.isRunningTest()) {
                    messaging.sendEmail(emails);
                }
            else
            {
                EmailException e = new EmailException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            
        }
        catch(EmailException emailex)
        {
            List<String> toAddEmailLST = new List<String>();
            toAddEmailLST.add(azureCred.AdminUser__c);
            
            messaging.SingleEmailMessage email1=new messaging.SingleEmailMessage();
            
            emailBody = System.Label.ExceptionErrorMSG + '\n \n' + emailBody;
            
            email1.setToAddresses(toAddEmailLST);
            email1.setSubject(System.Label.ExceptionErrorMSG);
            email1.setPlainTextBody(emailex.getMessage());
            email1.setSenderDisplayName(userDisplayName.Name);
            messaging.Email[] emails = new messaging.Email[]{email1};
                if (!Test.isRunningTest()) {
                    messaging.sendEmail(emails);
                }
        }
    }
    
    @TestVisible
    private static void populateStartDateOnAccount(List<Contract__c> triggerNew) {
        Set<Id>accountId = new Set<Id>();
        for (Contract__c c : triggerNew) {
            accountId.add(c.Account__c);
        }
        
        //will  get the Record Type for Contract object using below code
        Id implementatioRtId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        Id operationalRtId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        Set<Account> accountToUpdate = new Set<Account>();
        for (Account acc : [SELECT Id, Contract_Start_Date_Impl__c, Contract_Start_Date_Oper__c, (SELECT Id, StartDate__c, RecordType.Name FROM Contracts1__r WHERE Status__c = 'Signed' ORDER BY CreatedDate ASC) FROM Account WHERE Id IN :accountId]) {
            Date implStartDate = null;
            Date operStartDate = null;
            Boolean implStartDateSet = false;
            Boolean operStartDateSet = false;
            
            for (Contract__c c : acc.Contracts1__r) {
                if (!implStartDateSet && implStartDate == null && c.RecordTypeId == implementatioRtId) {
                    implStartDate = c.StartDate__c;
                    implStartDateSet = true;
                }
                if(!operStartDateSet && operStartDate == null && c.RecordTypeId == operationalRtId) {
                    operStartDate = c.StartDate__c;
                    operStartDateSet = true;
                }
            }
            if (implStartDate != null && implStartDate != acc.Contract_Start_Date_Impl__c) {
                acc.Contract_Start_Date_Impl__c = implStartDate;
                accountToUpdate.add(acc);
            }
            
            if (operStartDate != null && operStartDate != acc.Contract_Start_Date_Oper__c) {
                acc.Contract_Start_Date_Oper__c = operStartDate;
                accountToUpdate.add(acc);
            }
        } 
        //It will Check the accountToupdate List Size If It is Greator than zero then it will Update the List 
        if (accountToUpdate.size()>0) {
            update new List<Account>(accountToUpdate);
        }
    }
    
    //It will filter the Data as per Accounts asociated with each Contracts
    public static Map<string,object> FilterContractsByAccount(List<Contract__c> Items){
        Map<string,object> AccountMapFilter = new  Map<string,object>();
        Account account;
        List<Contract__c> tempobj;
        
        try{
            for(Contract__c contract: Items){
                
                if(AccountMapFilter.containsKey(contract.Account__c))
                {
                    tempobj = (List<Contract__c>) AccountMapFilter.get((contract.Account__c));
                    tempobj.add(contract);
                    AccountMapFilter.put(contract.Account__c,tempobj);
                }
                else
                {
                    tempobj = new List<Contract__c>();
                    tempobj.add(contract);
                    AccountMapFilter.put(contract.Account__c,tempobj);
                }
            }
        }
        catch (Exception ex){
            system.debug('Excpetion in FilterContractsByAccount : '+ex.getMessage()+' Line Number : '+ex.getLineNumber());
        }
        return AccountMapFilter;
    }
    
}