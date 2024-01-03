public class sharepointFileUploadController {
  
    public class DocumentWrapper {
        @AuraEnabled public String fileName { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String docIcon { get; set; }
        @AuraEnabled public String modifiedBy { get; set; }
        @AuraEnabled public String modifiedTime { get; set; }
        @AuraEnabled public String fileLink { get; set; }
    }
    public class isWidgetAccessibleResponse {
        @AuraEnabled public Boolean showWidget { get; set; }
        @AuraEnabled public String message { get; set; }
    }
    @AuraEnabled(cacheable=true)
    public static List<object> fetchGettermStore(string termStoreName){
        try{
            List<Termset__c> tsList = [select Name, Guid__c from Termset__c];
            string termstoreId ='';
            for(Termset__c ts : tsList){
                if(ts.Name==termStoreName){
                    termstoreId = ts.Guid__c;
                    break;
                }
            }
            if(termstoreId!=''){
                return getTermStore(termstoreId);
            }
        }catch(Exception ex ){
            system.debug('##Unable to fetch the term store  '+ex.getMessage());
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Object> getTermStore(String termsID){
          AzureAD_Credential__c objAzureCredential = [Select DevAPIEndPoint__c,ClientId__c, ClientSecretKey__c,Salesforce_ClientId__c,Salesforce_ClientSecret__c FROM AzureAD_Credential__c WITH SYSTEM_MODE];

        try{
            system.debug('calling get term store method');
            String EndpointUrl = objAzureCredential.DevAPIEndPoint__c+'api/file/getterm/'+termsID;
            string authorization = objAzureCredential.Salesforce_ClientId__c+objAzureCredential.Salesforce_ClientSecret__c;
            string body='';
            httpResponse httpResponse = GlobalAPICallOut.makefileCallout(EndpointUrl,'GET',authorization);
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(httpResponse.getBody());
            Integer statusCodeTeam = (Integer)jsonMap.get('statusCode');
            List<Object> records;
            if(statusCodeTeam == 200){
                if(!jsonMap.isEmpty()){
                    records = (List<Object>) jsonMap.get('data'); //get the records
                }
            }
            else{
                system.debug('If Fails' + statusCodeTeam);
            }
            system.debug('Data List'+records);
            return records;
        }
        
        catch(Exception ex){
            
            system.debug('Error occurred while processing the request'+ ex.getMessage());
           // throw new AuraHandledException(ex.getMessage());
           return null;
        }
    }
    
    @AuraEnabled(cacheable = false)
    public static String checkforExistingMultipleFiles(String recordId,String fileNames, string channelname){
        try {
            System.debug('@@channelname'+channelname);
            system.debug('Call checkforExistingMultipleFiles ');
            AzureAD_Credential__c objAzureCredential = [Select DevAPIEndPoint__c,ClientId__c, ClientSecretKey__c,Salesforce_ClientId__c,Salesforce_ClientSecret__c FROM AzureAD_Credential__c];
            
            String Endpoint = objAzureCredential.DevAPIEndPoint__c+'api/File/FileExists';
            string authorization = objAzureCredential.Salesforce_ClientId__c+objAzureCredential.Salesforce_ClientSecret__c;
            
            List<Account> newSiteURL = [Select ID, SiteURL__c from Account where ID=:recordId];
            system.debug('newSiteURL' +newSiteURL);
            string siteurl = newSiteURL[0].SiteURL__c;
            
            HttpRequest httpRequest = new HttpRequest();
            String requestBody = '{ "sharpointUrl": "'+siteurl + channelname+'","libraryName": "Documents","isSharedChannel": true, "fileNames": '+ fileNames +'}';
            system.debug('Requestbody' + requestBody);
            HttpResponse httpResponse = GlobalAPICallOut.makeCallout(requestBody, Endpoint, 'POST', authorization);
            system.debug('Http Response-->'+httpResponse.getBody());
            return httpResponse.getBody();
        } 
        catch (Exception e) {
            system.debug('Get Error message'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }    
    
    @AuraEnabled(cacheable = false)
    public static String checkforExistingMultipleFilesTask(String recordId,String fileNames, string channelname){
        try {
            system.debug('Call checkforExistingMultipleFilesTask ');
            
            AzureAD_Credential__c objAzureCredential = [Select DevAPIEndPoint__c,ClientId__c, ClientSecretKey__c,Salesforce_ClientId__c,Salesforce_ClientSecret__c FROM AzureAD_Credential__c];
            
            String Endpoint = objAzureCredential.DevAPIEndPoint__c+'api/File/FileExists';
            string authorization = objAzureCredential.Salesforce_ClientId__c+objAzureCredential.Salesforce_ClientSecret__c;
            
            List<Task> newSiteURL = [Select ID, Account__r.SiteURL__c from Task where ID=:recordId];
            system.debug('newSiteURL' +newSiteURL);
            string siteurl = newSiteURL[0].Account__r.SiteURL__c;
            
            HttpRequest httpRequest = new HttpRequest();
            String requestBody = '{ "sharpointUrl": "'+siteurl + channelname+'","libraryName": "Documents","isSharedChannel": true, "fileNames": '+ fileNames +'}';
            system.debug('Requestbody' + requestBody);
            HttpResponse httpResponse = GlobalAPICallOut.makeCallout(requestBody, Endpoint, 'POST', authorization);
            system.debug('Http Response-->'+httpResponse.getBody());
            return httpResponse.getBody();
        } 
        catch (Exception e) {
            system.debug('Get Error message'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

	
    
    @AuraEnabled(cacheable=true)
    public static List<DocumentWrapper> getAllFileDocuments(String recordId,String channelname, String QueryText, String SortingField, String SortingDirection) {
        system.debug(' id -->  '+recordId);
        system.debug(' QueryText->'+QueryText);
        
        List<DocumentWrapper> documents = new List<DocumentWrapper>();
        
        try {
            AzureAD_Credential__c objAzureCredential = [Select DevAPIEndPoint__c,ClientId__c, ClientSecretKey__c,Salesforce_ClientId__c,Salesforce_ClientSecret__c FROM AzureAD_Credential__c];
            
            List<Account> newSiteURL = [SELECT ID, SiteURL__c, MailNickName__c,IsMSTeamCreated__c,isWidgetActive__c FROM Account WHERE ID=:recordId and IsMSTeamCreated__c= true and isWidgetActive__c = true];
            system.debug('newSiteURL' + newSiteURL);
            
            if(newSiteURL.size() > 0 ){
                String sharePointUrl = newSiteURL[0].MailNickName__c; 
                system.debug('SharepointUrl   '+ sharePointUrl);
                
                String Endpoint = objAzureCredential.DevAPIEndPoint__c+'api/File/GetAllDocuments/' + sharePointUrl + channelname ;
                system.debug('##ENDPOINT-->'+Endpoint);
                if(QueryText != null && QueryText != '')
                {
                    Endpoint += '/'+QueryText.replaceAll(' ','%20');
                    system.debug('##QUERYTXT-->'+QueryText);
                }
                else if(SortingField != null && SortingField != '' && SortingDirection != null && SortingDirection != '')
                {
                    //?SortingField=FileLeafRef&SortingDirection=asc
                    Endpoint += '?SortingField=' + SortingField + '&SortingDirection=' + SortingDirection;
                }
               
                string authorization = objAzureCredential.Salesforce_ClientId__c+objAzureCredential.Salesforce_ClientSecret__c;
                system.debug('Endpoint->'+Endpoint);
                HttpResponse httpResponse = GlobalAPICallOut.makefileCallout(Endpoint,'GET',authorization);
                if (httpResponse.getStatusCode() == 200) {
                    // Parse the JSON response
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    system.debug('jsonResponse' + jsonResponse);
                    
                    List<Object> documentsJson = (List<Object>) jsonResponse.get('data');
                    system.debug('documentsJson' + documentsJson);
                    
                    // Map JSON response to DocumentWrapper objects
                    for (Object documentJson : documentsJson) {
                        Map<String, Object> documentFields = (Map<String, Object>) documentJson;
                        DocumentWrapper document = new DocumentWrapper();
                        
                        document.title = (String) documentFields.get('title');
                        document.docIcon = (String) documentFields.get('docIcon');
                        document.fileName = (String) documentFields.get('name');
                        document.modifiedBy = (String) documentFields.get('author');
                        
                        string ModifiedDate = (String) documentFields.get('modified');
                        List<string> splitedDate= ModifiedDate.split(':');
                        splitedDate[2] = splitedDate[2].indexOf('AM') > -1 ? ' AM' : ' PM';
                        string updatedDateString = splitedDate[0] + ':' + splitedDate[1] + splitedDate[2];
                        document.modifiedTime = updatedDateString;
                        document.fileLink = (String) documentFields.get('fileUrl');
                        document.fileLink =document.fileLink+ '?web=1&action=edit';

                        documents.add(document);
                        
                    }
                    system.debug('documents: ' + documents);
                    system.debug('document size-->'+documents.size());
                }
                else{
                    system.debug('If Fails' + httpResponse.getStatusCode());
                }
            }
        }
        catch (Exception ex) {
            // Handle the exception here
            system.debug('Error occurred while getting the documents: ' + ex.getMessage());
        }
        
        return documents;
    }
    
   @AuraEnabled(cacheable=true)
    public static List<DocumentWrapper> getAllFileDocumentsTask(String recordId,String channelname,string TaskNumber, String QueryText, String SortingField, String SortingDirection) {
        system.debug(' id -->  '+recordId);
        system.debug(' QueryText->'+QueryText);
        system.debug('Task No -->'+ taskNumber);
        
        List<DocumentWrapper> documents = new List<DocumentWrapper>();
        
        try {
            AzureAD_Credential__c objAzureCredential = [Select DevAPIEndPoint__c,ClientId__c, ClientSecretKey__c,Salesforce_ClientId__c,Salesforce_ClientSecret__c FROM AzureAD_Credential__c];
            
            List<Account> newSiteURL = [SELECT ID, SiteURL__c, MailNickName__c,IsMSTeamCreated__c,isWidgetActive__c FROM Account WHERE ID=:recordId and IsMSTeamCreated__c= true and isWidgetActive__c = true];
            system.debug('newSiteURL' + newSiteURL);
            
            if(newSiteURL.size() > 0 ){
                String sharePointUrl = newSiteURL[0].MailNickName__c; 
                system.debug('SharepointUrl   '+ sharePointUrl);
                
                String Endpoint = objAzureCredential.DevAPIEndPoint__c+'api/File/GetAllDocumentByTask/'+ sharePointUrl + channelname;
                system.debug('##ENDPOINT-->'+Endpoint);
                
                if(TaskNumber != null && TaskNumber != ''){
                    Endpoint += '/'+TaskNumber;
                    system.debug('## Task No--->'+TaskNumber);
                }
               
                if(QueryText != null && QueryText != '')
                {
                    Endpoint += '?QueryText='+QueryText.replaceAll(' ','%20');
                    system.debug('##QUERYTXT-->'+QueryText);
                }
                else if(SortingField != null && SortingField != '' && SortingDirection != null && SortingDirection != '')
                {
                    //?SortingField=FileLeafRef&SortingDirection=asc
                    Endpoint += '?SortingField=' + SortingField + '&SortingDirection=' + SortingDirection;
                }
               
                string authorization = objAzureCredential.Salesforce_ClientId__c+objAzureCredential.Salesforce_ClientSecret__c;
                system.debug('Endpoint->'+Endpoint);
               // Endpoint='https://devviewledgerapi.azurewebsites.net/api/File/GetAllDocumentByTask/SBOXP_VCD-BRTest040720230123423-AccountingSharedChannel/350/%20';
                HttpResponse httpResponse = GlobalAPICallOut.makefileCallout(Endpoint,'GET',authorization);
                if (httpResponse.getStatusCode() == 200) {
                    // Parse the JSON response
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    system.debug('jsonResponse' + jsonResponse);
                    
                    List<Object> documentsJson = (List<Object>) jsonResponse.get('data');
                    system.debug('documentsJson' + documentsJson);
                    
                    // Map JSON response to DocumentWrapper objects
                    for (Object documentJson : documentsJson) {
                        Map<String, Object> documentFields = (Map<String, Object>) documentJson;
                        DocumentWrapper document = new DocumentWrapper();
                        
                        document.title = (String) documentFields.get('title');
                        document.docIcon = (String) documentFields.get('docIcon');
                        document.fileName = (String) documentFields.get('name');
                        document.modifiedBy = (String) documentFields.get('author');
                        
                        string ModifiedDate = (String) documentFields.get('modified');
                        List<string> splitedDate= ModifiedDate.split(':');
                        splitedDate[2] = splitedDate[2].indexOf('AM') > -1 ? ' AM' : ' PM';
                        string updatedDateString = splitedDate[0] + ':' + splitedDate[1] + splitedDate[2];
                        document.modifiedTime = updatedDateString;
                        document.fileLink = (String) documentFields.get('fileUrl');
                        document.fileLink =document.fileLink+ '?web=1&action=edit';

                        documents.add(document);
                        
                    }
                    system.debug('documents: ' + documents);
                    system.debug('document size-->'+documents.size());
                }
                else{
                    system.debug('If Fails' + httpResponse.getStatusCode());
                }
            }
        }
        catch (Exception ex) {
            // Handle the exception here
            system.debug('Error occurred while getting the documents: ' + ex.getMessage());
        }
        
        return documents;
    }
    
    @AuraEnabled(cacheable=true)
    public static AzureAD_Credential__c getCustomSettings() {
        AzureAD_Credential__c customSettings = AzureAD_Credential__c.getOrgDefaults();
        System.debug('Custom settings retrieved: ' + customSettings);
        return customSettings;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static isWidgetAccessibleResponse isWidgetAccessible(String accountId, Boolean requestedForPayroll) {
        isWidgetAccessibleResponse response = new isWidgetAccessibleResponse();
        Account acct = [SELECT isWidgetActive__c, IsMSTeamCreated__c FROM Account WHERE Id = :accountId];
        if (acct.IsMSTeamCreated__c == false || acct.isWidgetActive__c == false) {
            response.showWidget = false;
            response.message = 'MS Teams Not Created or Widget Not Ready to use.';
        }
        else
        {
            response.showWidget = acct.isWidgetActive__c; 
            Boolean hasAccess = hasAccessToWidget(accountId,requestedForPayroll);
            if(!hasAccess)
            {
                response.showWidget = false;
                response.message = 'Access is denied.';
            }
        }
        
        return response;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static isWidgetAccessibleResponse isTaskWidgetAccessible(String taskId, Boolean requestedForPayroll) {
        isWidgetAccessibleResponse response = new isWidgetAccessibleResponse();
        
        Task tsk = [SELECT Account__c FROM Task WHERE Id = :taskId];
        if (tsk.Account__c != null && String.valueOf(tsk.Account__c).startsWith('001')) {
            Account acct = [SELECT Id,isWidgetActive__c,IsMSTeamCreated__c,createdDate FROM Account WHERE Id = :tsk.Account__c ];
            if (acct.IsMSTeamCreated__c == false || acct.isWidgetActive__c == false) {
                response.showWidget = false;
                response.message = 'MS Teams Not Created or Widget Not Ready to use.';
            }
            else
            {
                response.showWidget = acct.isWidgetActive__c; 
                Boolean hasAccess = hasAccessToWidget(acct.Id, requestedForPayroll);
                if(!hasAccess)
                {
                    response.showWidget = false;
                    response.message = 'Access is denied.';
                }
            }
            
        }
        
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean hasAccessToWidget(String recordId, Boolean requestedForPayroll) {
        Boolean showAccountingWidget;
        Set<ID> contractIds = new Set<ID>();
        set<ID> accountOwnerIds = new Set<ID>();
        String accountId = recordId; 
        system.debug('recordID' +recordId);
        
        // Check if the record is a Task and get its related Account Id
        if (recordId.startsWith('00T')) {
            Task task = [SELECT AccountId FROM Task WHERE Id = :recordId];
            accountId = task.AccountId;
            
        }
        
        // Retrieve the contracts(agrement) for the account
        for(Contract__c con : [SELECT Id,Account_Owner_KA__c FROM Contract__c WHERE Account__c = :accountId]) {
            contractIds.add(con.Id);
            accountOwnerIds.add(con.Account_Owner_KA__c);
        }
        
        if(accountOwnerIds.contains(UserInfo.getUserId())){
            showAccountingWidget = true;
            
        }
        else{
            // Retrieve the account teams for the contracts
            List<Account_Team_And_Authorizations__c> teams = [SELECT Id, Kontrakt__c, Responsible__c, Type__c FROM Account_Team_And_Authorizations__c WHERE Kontrakt__c IN :contractIds];
            
            // Check if the user has the responsible role in any of the account teams
            List<String> accountingAllowedRoles = new List<String>{'Sales Consultant','Year end Responsible','Quality Consultant','Customer Success Manager','Accounting Controller','Remittance Responsible','Executive Sponsor','Project_Manager','Integration_Resource','Accounting Responsible','Oppdragsansvarlig','Payroll Consultant','Payroll_Responsible','Project Manager Payroll','Quality Consultant Payroll','Account_Owner','Accounting Consultant','Accounting Consultant 2','Year end Consultant'};
            List<String> payrollAllowedRoles = new List<String>{'Payroll Consultant','Payroll Consultant 2','Payroll_Responsible','Project Manager Payroll','Quality Consultant Payroll','Account_Owner','Oppdragsansvarlig'};
                    
                    if(teams.size()> 0){
                        for (Account_Team_And_Authorizations__c team : teams) {
                            
                            if(requestedForPayroll)
                            {
                                if (team.Responsible__c == UserInfo.getUserId() && (payrollAllowedRoles.contains(team.Type__c)) )
                                {
                                    showAccountingWidget = true;
                                    break;
                                }
                                else {
                                    showAccountingWidget = false;
                                } 
                            }
                            else
                            {
                                if (team.Responsible__c == UserInfo.getUserId() && (accountingAllowedRoles.contains(team.Type__c)))
                                {
                                    showAccountingWidget = true;
                                    break;
                                }
                                else {
                                    showAccountingWidget = false;
                                }    
                            }
                            
                        }
                        
                    }
            else{
                showAccountingWidget = false; 
            }
        }
        
        
        return showAccountingWidget;
    }
   
    
    
   @AuraEnabled(cacheable=true)
    public static List<Task> getTasksWithCustomFields(String taskId) {
        
        try{
            system.debug('Task Id' + taskId);
           
            List<Task> taskFields =  [SELECT Id, Owner.Email, Period__c, Task_Number__c,Account__r.SiteURL__c,
                                      Account__r.MailNickName__c,Account__r.Name,Account__r.Accounting_Channel_URL__c,
                                      Account__r.Payroll_Channel_URL__c,Owner.Id,Account__r.Id,
                                      AP_Task__r.Subject__c,
                                      Action_Plan_Task__c, AP_Task__c,Action_Plan__c
                                      FROM Task where Id =: taskId WITH SYSTEM_MODE];
         
            return taskFields;
        }
        catch (Exception e) {
            system.debug('Get Field Error message'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    } 
   	/*@AuraEnabled
		public static void tag(){
   			 APTaskTemplate__c cc = [SELECT Id, Name,Subject__c,Action_Plan__c FROM APTaskTemplate__c LIMIT 1];
    			System.debug('Fields: ' + cc);
    
    		List<Task> tasks = [SELECT Id, WhatId FROM Task WHERE WhatId = :cc.Id];
   			 System.debug('Related Tasks: ' + tasks);
		}*/

    @AuraEnabled(cacheable=false)
    public static Boolean uploadFile(String recordId, String widgetName) {
        system.debug('Task Id' + recordId);
        Task taskRecord = [SELECT Id, Accounting_Upload__c, Payroll_Upload__c FROM Task WHERE Id = :recordId Limit 1];
        system.debug('Task taskRecord' + taskRecord);
        
        List<Task> taskUpdateList = new List<Task>();
        if (widgetName == 'Accounting') {
            if(!taskRecord.Accounting_Upload__c){
                Task tsk = new Task();
                tsk.Id = taskRecord.Id;
                tsk.Accounting_Upload__c = true;
                taskUpdateList.add(tsk);
            }
        } 
        else if (widgetName == 'Payroll') {
            if(!taskRecord.Payroll_Upload__c){   
                Task tsk = new Task();
                tsk.Id = taskRecord.Id;
                tsk.Payroll_Upload__c = true;
                taskUpdateList.add(tsk);
            }
        }
        if(taskUpdateList.size()>0){
            system.debug('taskUpdateList' + taskUpdateList);
            update taskUpdateList;
            return true;
        }
        return false;
              
    }
    
     @AuraEnabled(cacheable=false)
    public static void CreateLWCRecord(String LWCName,Id recordId,Id UserId)
    {
        try{
			system.debug('^^recordId'+recordId);
        system.debug('^^UserId'+UserId); 
        List<LWC_File_Tracker__c> existingrecord = [select id from LWC_File_Tracker__c where Record_ID__c=:recordId AND User_ID__c=:UserId AND LWC_Name__c=:LWCName];
        if(existingrecord.size()>0)
        {
            
        }
        else
        {
            LWC_File_Tracker__c NewLwcRecord = new LWC_File_Tracker__c();
            NewLwcRecord.LWC_Name__c = LWCName;
            NewLwcRecord.Record_ID__c = recordId;
            NewLwcRecord.User_ID__c = UserId;
            insert NewLwcRecord;
            system.debug('NewLwcRecord->'+NewLwcRecord);
                        
        }            
        }
        catch(Exception e){
            system.debug('Error occurred: ' + e.getMessage());
        }
      
        
     
    }

   
    
}