/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         SharepointWidgetController.cls 
Description:  Controller class to fetch and search created/uploaded docuemnts, to save the documents and to display fetched termstore from and to sharepoint
to display in Widget placed on record page of Account/Task.

Test class:   SharepointWidgetController_Test.cls 

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
02 Oct 2019        1.0        Deepak                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */



public class SharepointWidgetController {
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    getAllDocuments
Description:    Fetches all documents with details,views and content types related to sobject with their required fields from sharepoint. 
Inputs:         Sharepoint siteurl, objName - Account/Task, country - related to Account/Task.
Output:         Map of fetched Contenttypes and key of map will be name,id,level of contenttypes
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   
21 Oct 2019    Deepak               If user Exists in group or not
----------------------------------------------------------------------------------------------------------------------------------*/ 
  
    @AuraEnabled
    public static Map<string,Object> getAllDocuments(id sobjectid,string SortDir, string SortField,string ViewId){
        Map<string,Object> DocViewContenttype = new Map<string,Object>();
        try{
            //fetch sobject name based on id.
            string objName = string.valueOf(sobjectid.getsobjecttype());
            string query  = '';
            Account account;
            Task task;
            //query based on the sobject.
            if(objName == 'Account'){
                query = 'select id,Name, SiteURL__c,isWidgetActive__c,MailNickName__c,Country2__c,SPGroupID__c,IsMSTeamCreated__c from '+ objName +' where Id=\''+sobjectid+'\'';
                System.debug('query:'+query);
                account =  Database.query(query);
            }
            else if(objName == 'Task')
            {
                query = 'select id, WhatId,Account__c,Task_Number__c,Period__c,Action_Plan_Task__c from '+ objName +' where Id=\''+sobjectid+'\'';
                task =  Database.query(query);
                if(task.Account__c!=null){
                    account = [select id,Name, MailNickName__c ,isWidgetActive__c,SiteURL__c,Country2__c,SPGroupID__c,IsMSTeamCreated__c from account where id=: task.Account__c];    
                }
                else
                {
                    DocViewContenttype.put('isWidgetActive',false);
                    DocViewContenttype.put('inActiveMessage',System.Label.NoRelatedAccountFound);
                    return DocViewContenttype;
                }
                
            }
            system.debug('actuve:'+account.isWidgetActive__c);
            if(account.isWidgetActive__c && account.IsMSTeamCreated__c){
                DocViewContenttype.put('isWidgetActive',account.isWidgetActive__c);
            }
            else
            {
                DocViewContenttype.put('isWidgetActive',false);
                DocViewContenttype.put('inActiveMessage',System.Label.Sharepoint_Widget_Active_Message);
                return DocViewContenttype;
            }
            system.debug('Ms team:'+account.IsMSTeamCreated__c);
            if(account.IsMSTeamCreated__c){
                if(!UserExistsInO365group(account)){
                    DocViewContenttype.put('isWidgetActive',false);
                    DocViewContenttype.put('inActiveMessage',System.Label.User_not_found_in_O365_group);
                    return DocViewContenttype;
                }
            }
            SharepointCredentialsInfo__c SPcredentials = [Select timezone__c from SharepointCredentialsInfo__c limit 1 ];
            system.debug(account.Country2__c);
            map<string,object> ContentTypes =  SPRequestController.fetchContentTypesWithRequiredColums(account.SiteURL__c,objName,account.Country2__c);
            List<String> FetchViewNameList = new List<String>();
            for(string content : ContentTypes.keyset()){
                FetchViewNameList.add(content.split(',')[0]);
            }
            string Seeallid='';
            Map<string,object> views = SPRequestController.FetchviewsFromSharepoint(account.SiteURL__c,objName,ViewId,FetchViewNameList);
            string token = string.valueOf( views.get('token'));
            List<Map<string,object>> ListOfViews  = (List<Map<string,object>>)views.get('ListOfViews');
            Seeallid = string.valueOf(views.get('Seeallid'));
            
            
            // create list of documents with required properties and retuen to client side.
            List<map<string,string>> listOfDocuments = new List<map<string,string>>();
            System.debug(account.SiteURL__c);
            System.debug(account.SiteURL__c.lastindexof('/'));
            System.debug(account.SiteURL__c.substring(account.SiteURL__c.lastindexof('/')+1));
            String mailNickName = account.SiteURL__c.substring(account.SiteURL__c.lastindexof('/')+1);
            string RootFolder = '/sites/'+mailNickName+'/Shared%20Documents/General';
            //string RootFolder = '/sites/'+account.MailNickName__c+'/Shared%20Documents/General';
            string Endpoint ;
            
            Endpoint =  account.SiteURL__c + '/_api/web/lists/getbytitle(\'Documents\')/RenderListDataAsStream?&RootFolder='+RootFolder+'&View='+viewId;
            if(SortField!=''){
                Endpoint =  account.SiteURL__c + '/_api/web/lists/getbytitle(\'Documents\')/RenderListDataAsStream?&RootFolder='+RootFolder+'&SortField='+SortField+'&SortDir='+SortDir+'&View='+viewId;   
            }
            
            string queryPayload = '{"parameters":{"__metadata":{"type":"SP.RenderListDataParameters"},"AllowMultipleValueFilterForTaxonomyFields":true,"AddRequiredFields":true}}';
            HttpResponse httpResponse = SPRequestController.handleHttpCallout(Endpoint,'POST',queryPayload,token,'getAllDocuments',null);
            
            if(httpResponse.getStatusCode() == 200)
            {
                // extract value from the json response.
                Map<string,object> rootobject = (map<string,object>)JSON.deserializeUntyped(httpResponse.getBody());
                // get list of the documents in value object.
                List<object> Rows =( List<object>) rootobject.get('Row');
                Integer loopLength = Rows.size()>10 ? 10 : Rows.size();
                // iterate through each document.
                for(Integer i=0 ; i< loopLength ;i++){
                    Map<string,string> documentprop = new  Map<string,string>();
                    Map<string,object> document =(Map<string,object>)Rows[i];
                    documentprop.put('Name',string.valueof(document.get('FileLeafRef')));
                    documentprop.put('DocIcon',string.valueof(document.get('FileLeafRef.Suffix')));
                    documentprop.put('Author',string.valueof(document.get('Author.title')));
                    system.debug('author'+string.valueof(document.get('Author.title')));
                    documentprop.put('Title',string.valueof(document.get('Title')));
                    // documentprop.put('Modified',string.valueof(document.get('Modified.')).split(' ')[0]);
                    string modified =  string.valueof(document.get('Modified'));
                    documentprop.put('Modified',EncodingUtil.urlDecode(modified, 'UTF-8'));
                    
                    // documentprop.put('Modified',string.valueof(document.get('Modified.')));
                    documentprop.put('Task_Number',string.valueof(document.get('Task_Number')));
                    documentprop.put('Period',string.valueof(document.get('Period')));
                    documentprop.put('Action_Plan_Task',string.valueof(document.get('Action_Plan_Task')));
                    string  documnetUrl = account.SiteURL__c +'/Shared%20Documents/General/'+EncodingUtil.URLENCODE(string.valueof(document.get('FileLeafRef')),'UTF-8').replace('+', '%20') +'?web=1&action=edit';
                    documentprop.put('documentUrl',documnetUrl);
                    system.debug('documentprop'+documentprop);
                    listOfDocuments.add(documentprop);
                }
            }
            // Add all Details to the master Map.
            DocViewContenttype.put('Documents',listOfDocuments);
            DocViewContenttype.put('Views',ListOfViews);
            DocViewContenttype.put('ContentTypes',ContentTypes);
            DocViewContenttype.put('sobjectid',account.Id);
            DocViewContenttype.put('sobjectName',objName);
            DocViewContenttype.put('TimeZone', SPcredentials.timezone__c);
            DocViewContenttype.put('SeeAll',account.SiteURL__c + '/Shared%20Documents/Forms/AllItems.aspx?&viewid='+Seeallid +'&id=/sites/'+mailNickName+'/Shared%20Documents/General');
          
        }
        catch(Exception ex){
            system.debug('Exception :'+ex.getMessage());
        }
        system.debug('DocViewContenttype-->'+DocViewContenttype);
        return DocViewContenttype;
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    searchdocuments
Description:    Searches the related documents with metadata column as per string entered by user in search box.
Inputs:         Id of related sobject, text entered by user in search box.
Output:         List of documents as result of search.
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   

----------------------------------------------------------------------------------------------------------------------------------*/ 
    
    @AuraEnabled
    public static List<Map<string,object>> searchdocuments(string accountid,string searchtext){
        List<Map<string,object>> listOfDocuments = new List<Map<string,object>>();
        try{
            Account  account = [select id,SiteURL__c,Country2__c from Account where id=: accountid];
            
            string querystring = '';
            string endpoint='';
            if(account.Country2__c=='NO - Norge'){
                endpoint = account.SiteURL__c+'/_api/web/lists/getbytitle(\'Documents\')/items?$select=*,TaxCatchAll/Term,DocIcon,ServerRedirectedEmbedUrl,Author/Title,Editor/Title,FileRef,EncodedAbsUrl,AP_x0020_Year,File/*&$expand=Author,File,Editor,TaxCatchAll&$filter=';
                querystring +=  '(substringof(\'' + searchText + '\',TaxCatchAll/Term))';
                querystring +=  'or(substringof(\'' + searchText + '\',Firm))';
            }
            else
            {
                endpoint = account.SiteURL__c+'/_api/web/lists/getbytitle(\'Documents\')/items?$select=*,DocIcon,ServerRedirectedEmbedUrl,Author/Title,Editor/Title,FileRef,EncodedAbsUrl,AP_x0020_Year,File/*&$expand=Author,File,Editor&$filter=';   
                querystring +=  '(substringof(\'' + searchText + '\',Firm))';
            }
            
            querystring +=  'or(substringof(\'' + searchText + '\',FileLeafRef))or(substringof(\'' + searchText + '\',Title))';
            querystring +=  'or(substringof(\'' + searchText + '\',Project_Number_Operational))';
            querystring +=  'or(substringof(\'' + searchText + '\',Company_Type))';
            querystring +=  'or(substringof(\'' + searchText + '\',ERP_System))';
            
            querystring +=  'or(substringof(\'' + searchText + '\',Account_Name))';
            querystring +=  'or(substringof(\'' + searchText + '\',Action_Plan_Task))';
            querystring +=  'or(substringof(\'' + searchText + '\',Author/Title))';
            querystring +=  'or(substringof(\'' + searchText + '\',Editor/Title))';
            querystring +=  'or(substringof(\'' + searchText + '\',AP_x0020_Year))';
            querystring +=  'or(substringof(\'' + searchText + '\',Org_Number))';
            // Add to querystring if the search text is Numeric.
            if(searchText.isNumeric()){
                querystring +=  'or(Task_Number eq ' + searchText + ')';
                querystring +=  'or(Period eq ' + searchText + ')';
                
            }
            
            querystring +=  'or(substringof(\'' + searchText + '\',System_Origin))';
            endpoint = endpoint + EncodingUtil.urlEncode(querystring, 'UTF-8');
            
            HttpResponse httpResponse = SPRequestController.handleHttpCallout(endpoint,'GET','','','searchdocuments',null);
            
            if(httpResponse.getStatusCode()==200){
                Map<string,object> rootobject = (map<string,object>)JSON.deserializeUntyped(httpResponse.getBody());
                List<object> searchDocumentList = (List<object>)rootobject.get('value');
                Integer loopLength = searchDocumentList.size()>10 ? 10 : searchDocumentList.size();
                // iterate through each document.
                for(Integer i=0 ; i< searchDocumentList.size() ;i++){
                    Map<string,string> documentprop = new  Map<string,string>();
                    Map<string,object> document =(Map<string,object>)searchDocumentList[i];
                    system.debug('document : '+document);
                    
                    Map<string,object> FileProp =(Map<string,object>)document.get('File');
                    Map<string,object> AuthorProp =(Map<string,object>)document.get('Author');
                    List<string> FileRef =  string.valueof(document.get('FileRef')).split('/');
                    if(FileRef!=null && FileRef[4]=='General' && FileProp!=null){
                        documentprop.put('Name',string.valueof(FileProp.get('Name')));
                        documentprop.put('Title',string.valueof(FileProp.get('Title')));
                        documentprop.put('Modified',string.valueof(FileProp.get('TimeLastModified')));
                        documentprop.put('DocIcon',string.valueof(document.get('DocIcon')));
                        
                        string  documnetUrl = account.SiteURL__c +'/Shared%20Documents/General/'+string.valueof(FileProp.get('Name'))+'?web=1&action=edit';
                        documentprop.put('documentUrl',documnetUrl);
                        documentprop.put('Action_Plan_Task',string.valueof(document.get('Action_Plan_Task')));
                        documentprop.put('Task_Number',string.valueof(document.get('Task_Number')));
                        documentprop.put('Period',string.valueof(document.get('Period')));
                        documentprop.put('Author',string.valueof(AuthorProp.get('Title')));
                        listOfDocuments.add(documentprop);
                    }
                }
                
                system.debug('listOfDocuments : '+listOfDocuments);
            }
        }catch(Exception ex ){
            system.debug('Fail to search '+ex.getMessage());
        }
        return listOfDocuments;
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    saveTheFiles
Description:    Save new document and uploaded multiple documents by user in sharepoint in general folder.
Inputs:         record Id and name of related sobject, list of all documents, body of document, related content types and its related 
required fields, boolean input to check if file's created/uploaded.
Output:         Url of created/uploaded document.
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   
09 JUL 2020       Deepak                Upload Multiple Files CR
----------------------------------------------------------------------------------------------------------------------------------*/ 
    
    @AuraEnabled
    public static Map<string,string> saveTheFiles(string sObjectId, List<Map<String,string>> fileNameList, String contentType,boolean isupload,string jsonStringrequiredfields,string recordId){
        
        Map<String,string> DocContIdFileNameMap = new map<String,string>();
        for(Map<String,String> fileN : fileNameList){
            DocContIdFileNameMap.put(fileN.get('DocContentId'),fileN.get('fileName'));
        }
        system.debug('Hello');
        Map<string,string> returnUrl=new Map<string,string>();
        try {
            returnUrl =  SPRequestController.sendFilesToSharepoint(DocContIdFileNameMap,sObjectId, contentType,jsonStringrequiredfields,isupload,recordId);
            system.debug('returnUrl'+returnUrl);     
        }
        catch(Exception ex ){
            system.debug('Fail to Save the file  '+ex.getMessage());
        } 
        system.debug('returnUrl : '+returnUrl);
        return returnUrl;
    }
    
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    fetchGettermStore
Description:    Fetches termstore to display in widget from Termset custom setting.
Inputs:         Name of term store.
Output:         List<Object> containing Name and Guid of termstore.
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   

----------------------------------------------------------------------------------------------------------------------------------*/ 
    
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
                return SPRequestController.getTermStore(termstoreId);
            }
        }catch(Exception ex ){
            system.debug('Unable to fetch the term store  '+ex.getMessage());
        }
        return null;
    }
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    UserExistsInO365group
Description:    check if the user is in O365 group then display widget.
Inputs:         group id.
Output:         return true if user exists.
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
15 Oct 2019       Deepak                    -   

----------------------------------------------------------------------------------------------------------------------------------*/ 
    public static boolean UserExistsInO365group(Account account){
        Boolean UserExists = false;
        try{
            String emailAddress =  UserInfo.getUserEmail();
            AzureAD_Credential__c SPSiteBaseURL = [Select MicrosoftGraphURL__c,SPServiceAccount__c,SiteMemberGroupId__c FROM AzureAD_Credential__c];
            string  graphtoken = 'Bearer ' + TokenController.GetToken();
            
            String Endpoint = SPSiteBaseURL.MicrosoftGraphURL__c + 'groups/'+account.SPGroupID__c+'/owners';
            HttpResponse httpResponseOwners =  SPRequestController.handleHttpCallout(Endpoint, 'GET', '', graphtoken, 'UserExsitsInO365group', null);
            
            Endpoint = SPSiteBaseURL.MicrosoftGraphURL__c + 'groups/'+account.SPGroupID__c+'/members';
            HttpResponse httpResponseMembers =  SPRequestController.handleHttpCallout(Endpoint, 'GET', '', graphtoken, 'UserExsitsInO365group', null);
            string sptoken ='';
            
            Endpoint = account.SiteURL__c+'/_api/web/sitegroups/getbyid('+SPSiteBaseURL.SiteMemberGroupId__c+')/users';
            HttpResponse httpResponseSiteMembers =  SPRequestController.handleHttpCallout(Endpoint, 'GET', '', sptoken, '', null);
            List<string> ListOfUsers = new List<string>();
            set<string> setOfUsers = new set<string>();
            Map<string,object> Mapofvalues;
            Map<string,object> Mapofuser ;
            //get owners from json body 
            if(httpResponseOwners.getStatusCode()==200){
                Mapofvalues =  (Map<string,object>)JSON.deserializeUntyped(httpResponseOwners.getBody());
                for(object user :(List<object>) Mapofvalues.get('value')){
                    Mapofuser =  (Map<string,object>)user;
                    string userEmail = string.valueOf(Mapofuser.get('userPrincipalName'));
                    if(userEmail!=null && userEmail!=''){
                        system.debug('userEmail : '+userEmail);
                        setOfUsers.add(userEmail.toLowerCase() );
                    }
                }
            }
            //get members from json body 
            if(httpResponseMembers.getStatusCode()==200){
                Mapofvalues =  (Map<string,object>)JSON.deserializeUntyped(httpResponseMembers.getBody());
                for(object user :(List<object>) Mapofvalues.get('value')){
                    Mapofuser =  (Map<string,object>)user;
                    string userEmail = string.valueOf(Mapofuser.get('userPrincipalName'));
                    if(userEmail!=null && userEmail!=''){
                        system.debug('userEmail : '+userEmail);
                        setOfUsers.add(userEmail.toLowerCase() );
                    }
                }
            }
            
            //site members
            if(httpResponseSiteMembers.getStatusCode()==200){
                Mapofvalues =  (Map<string,object>)JSON.deserializeUntyped(httpResponseSiteMembers.getBody());
                system.debug('Mapofvalues : '+Mapofvalues.get('value'));
                for(object user :(List<object>) Mapofvalues.get('value')){
                    Mapofuser =  (Map<string,object>)user;
                    string userEmail = string.valueOf(Mapofuser.get('userPrincipalName'));
                    if(userEmail!=null && userEmail!=''){
                        system.debug('userEmail : '+userEmail);
                        setOfUsers.add(userEmail.toLowerCase() );
                    }
                }
            }
            ListOfUsers.addAll(setOfUsers);
            integer index =  ListOfUsers.indexOf(SPSiteBaseURL.SPServiceAccount__c);
            if(index>-1){
                ListOfUsers.remove(index);
            }
            if(ListOfUsers.size()>0){
                UserExists = ListOfUsers.contains(emailAddress);
            }
        }
        catch (Exception ex){
            system.debug('Excpetion in UserExistsInO365group : '+ex.getMessage()+' Line Number : '+ex.getLineNumber());
        }
        return UserExists;
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    DeleteFilesFromSalesforce
Description:    Delete all the latest uploaded files when clicked on cancel in sharepoint Widget UI.
Inputs:         record id.
Output:         void.
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
30 JAN 2020       Deepak                Inital Draft  
09 JUL 2020       Deepak                Upload Multiple Files CR

----------------------------------------------------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    @future
    public static void DeleteFilesFromSalesforce(List<string> ContentDocumentIdList){
    string userid = UserInfo.getUserId();
        List <ContentDocument>  ContentDocumentList =  [Select Id ,Title from ContentDocument Where ID IN :ContentDocumentIdList and OwnerId=:userid];
        
        if(ContentDocumentList.size()>0){
            system.debug('ContentDocumentList :: '+ContentDocumentList);
            delete ContentDocumentList;
        }
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    CheckIfFilesExistsInSharepoint
Description:    Check for uploaded files if file name with same name exists in Sharepoint or not.
Inputs:         record id and list of uploaded filesnames.
Output:         list of existing filenames from sharepoint.
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reson.

<Date>          <Authors Name>      Modification Reason 
30 JAN 2020       Deepak                Inital Draft  
09 JUL 2020       Deepak                Upload Multiple Files CR
----------------------------------------------------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static List<object> CheckIfFilesExistsInSharepoint(string accountId,List<Map<String,String>> listofFileNames){
        System.debug('filenames in CheckIfFileExistsInSharepoint : '+listofFileNames);
        List<String> fileNameListFromCom = new List<String>();
        for(Map<String,String> fileN : listofFileNames){
            fileNameListFromCom.add(fileN.get('fileName').toLowerCase());
        }
        System.debug('List Onuploadfile : '+fileNameListFromCom);
        Account account = [SELECT id, Name,SiteURL__c,MailNickName__c from Account where id=:accountId];
        String mailNickName = account.SiteURL__c.substring(account.SiteURL__c.lastindexof('/')+1);
        string EndpointUrl =  account.SiteURL__c+'/_api/web/GetFolderByServerRelativeUrl(\'/sites/'+mailNickName+'/Shared%20Documents/General/\')/Files';
        //string EndpointUrl =  account.SiteURL__c+'/_api/web/GetFolderByServerRelativeUrl(\'/sites/'+account.MailNickName__c+'/Shared%20Documents/General/\')/Files';
        
        HttpResponse httpResponse = SPRequestController.handleHttpCallout(EndpointUrl,'GET','','','CheckIfFileExistsInSharepoint',null);
        map<string,object> SharePointFileName = new map<string,object>();
        if(httpResponse.getStatusCode()==200){
            Map<string,object> datamap = (Map<string,object>)system.JSON.deserializeUntyped(httpResponse.getBody());
            list<object> values = (list<object>)datamap.get('value');
            
            for(object value : values){
                Map<string,object> FileNameMap = (Map<string,object>)value;
                SharePointFileName.put(string.valueOf(FileNameMap.get('Name')).toLowerCase() ,FileNameMap.get('Name'));
            }
            
            
        }
        List<object> ExistingFileNameList = new List<object>();
        if(SharePointFileName.keyset().size()>0){
            for(string fileNameFromCom : fileNameListFromCom){
                if(SharePointFileName.containsKey(fileNameFromCom))
                    ExistingFileNameList.add(fileNameFromCom);
            }
        }
        return ExistingFileNameList;
    }
    
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    UpdateIsDeletedTrue
Description:    Update IsDeleted to true from ContentVersion
----------------------------------------------------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static void UpdateIsDeletedTrue(List<String> contentVersionIds){
        List<ContentVersion> contentVersionsToUpdate = [SELECT Id,ContentDocumentId,IsDeleted__c FROM ContentVersion Where Id IN :contentVersionIds];
       
        try{
            for(ContentVersion cv : contentVersionsToUpdate){
                cv.IsDeleted__c = true;
            }
            System.debug('contentVersionsToUpdate : '+contentVersionsToUpdate);
            update contentVersionsToUpdate;
        }
        catch(Exception ex){
            System.debug('Issue in updating field : '+ex.getMessage());
        }
    }
      @AuraEnabled
    public static void CreateRecord(string accountId)
    {
        //List of records which are created today
        List<AuraFileUploadTracker__c> listoftodaysrecord=[select AccountId__C from   AuraFileUploadTracker__c where isLwcActive__c=false];
         set<string> accountidset = new set<string>();
        if(listoftodaysrecord.size()>0){
            for(AuraFileUploadTracker__c acc : listoftodaysrecord){
                accountidset.add(acc.AccountId__C);
            }
        }
         if(!(accountidset.contains(accountId))){
                AuraFileUploadTracker__c newrecord = new AuraFileUploadTracker__c();
                newrecord.AccountId__c = accountId;
                newrecord.Related_AccountId__c = accountId;
                insert newrecord;
            }
        
    }
   
    
    
 
}