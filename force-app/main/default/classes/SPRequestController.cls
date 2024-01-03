/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         SPRequestController.cls 
Description:  Controller class to fetch Content type, views and termstores from Sharepoint and to send created/uploaded 
documents to sharepoint with metadata and author details
Test class:   SharepointWidgetController_Test.cls 

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
02 Oct 2019        1.0        Deepak                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

public class SPRequestController {
    public static ExternalWebAPI__c Externalfileurl = [select Url__c,CreateNewFile__c,Upload_File__c,Fetch_TermStore__c,Update_Item_Author__c from ExternalWebAPI__c];    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    fetchContentTypesWithRequiredColums
Description:    Fetches contenttypes related to account,country with their required fields from sharepoint. 
Inputs:         Sharepoint siteurl, objName - Account/Task, country - related to Account/Task.
Output:         Map of fetched Contenttypes and key of map will be name,id,level of contenttypes
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reason.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   

----------------------------------------------------------------------------------------------------------------------------------*/
    
    public static map<string,object> fetchContentTypesWithRequiredColums(string siteurl,string objName, string country){
        map<string,object> ContentTypesMap = new  map<string,object>();
        List<string> RestrictedContentTypes = new string[]{'Document','Folder'};
            
            string EndpointUrl = siteurl +'/_api/lists/getbytitle(\'Documents\')/contenttypes';    
        string token ='';
        HttpResponse httpResponse = handleHttpCallout(EndpointUrl,'GET','',token,'fetchContentTypesWithRequiredColums',null);
        
        if(httpResponse.getStatusCode()==200){
            object rootobject = JSON.deserializeUntyped(httpResponse.getBody());
            system.debug(rootobject);
            Map<string,object> Mapofvalues =  (Map<string,object>)rootobject;
            List<object> listOfContentType = (List<object>)Mapofvalues.get('value');
            for(object ContentType: listOfContentType){
                Map<string,object> ContentTypeProp = (Map<string,object>)Contenttype;
                string Contenttypename = string.valueOf(ContentTypeProp.get('Name'));
                string ContenttypeDescription = string.valueOf(ContentTypeProp.get('Description'));
                Map<string,object>  ContentTypePropId =(Map<string,object>)ContentTypeProp.get('Id');
                string ContenttypeIdString = string.valueOf(ContentTypePropId.get('StringValue'));
                string ContentTypeNameID = Contenttypename +','+ ContenttypeIdString;
                if(RestrictedContentTypes.indexOf(Contenttypename) == -1){
                    String isNewType ='false';
                    
                    if((Contenttypename.toLowerCase().contains(objName.toLowerCase()) || ContenttypeDescription.toLowerCase().contains(objName.toLowerCase())) 
                       && ((Contenttypename.toLowerCase().contains(country.split('-')[1].trim().toLowerCase()) || ContenttypeDescription.toLowerCase().contains(country.split('-')[1].trim().toLowerCase()))
                            )){
                               
                               if(!Contenttypename.toLowerCase().contains('('+country.split('-')[0].trim().toLowerCase()+')')){
                                   isNewType ='true';
                                   ContentTypeNameID += ','+isNewType;
                               }
                               else
                               {
                                   ContentTypeNameID += ','+isNewType;
                               }
                               
                               List<Map<string,object>> RequiredColumDetails;
                               if((string)ContentTypeProp.get('SchemaXml')!=null){
                                   RequiredColumDetails =  XmlReader.ExtractRequiredColumDetails((string)ContentTypeProp.get('SchemaXml'));
                               }
                               ContentTypesMap.put(ContentTypeNameID,RequiredColumDetails);
                           }
                }
            }
        }
       
        return ContentTypesMap;
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    sendfilesToSharepoint
Description:    Sends created single document or uploaded multiple document to sharepoint with related metadata and author details
Inputs:         Map of Document names with ContentDocumentId, related recordId(Account/Task), contenttypeId, required fields related to content types,
body of document, sobjectname(Account/Task),boolean input to check if file's created/uploaded.
Output:         Map of Url of created/uploaded document(s).
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reason.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   
09 JUL 2020       Deepak                Upload Multiple Files CR
----------------------------------------------------------------------------------------------------------------------------------*/    
    
    public static Map<string,string> sendFilesToSharepoint(Map<String,string> DocContIdFileNameMap,string accountId,string contentTypeId,string jsonStringRequiredFields,Boolean isUpload,String recordId){
        map<string,string> accountvalues = new map<string,string>();
        map<string,string> taskvalues = new map<string,string>();
        string countryname,siteName,EndpointUrl,siteurl,contentType,contentVersionid='';
        Account acc;
        Task task ;
        Map<string,string> ContVerIdWithFileName = new Map<string,string>();
        Map<string,string> DocumentDetails = new Map<string,string>();
        List<ContentVersion> contentVersionList;
        List<ContentDocumentLink> contentDocumentLink;
        if(accountId==recordId){
            acc = [SELECT id, Name,SiteURL__c,MailNickName__c,Country2__c,Org_Number__c,ERP_System__c,Firm__c,Company_Type__c,Project_Number_Operational__c from Account where id=:accountId];
            
            accountvalues.put('Account_Name',acc.Name !=null ? acc.Name:'');
            accountvalues.put('Country',acc.Country2__c!=null ? acc.Country2__c:'');
            accountvalues.put('Org_Number',acc.Org_Number__c!=null ? acc.Org_Number__c:'');
            accountvalues.put('Company_Type',acc.Company_Type__c!=null ? acc.Company_Type__c:'');
            accountvalues.put('Firm',acc.Firm__c!=null ? acc.Firm__c:'');
            accountvalues.put('Project_Number_Operational',acc.Project_Number_Operational__c!=null ? (acc.Project_Number_Operational__c.isNumeric()?acc.Project_Number_Operational__c:''):'');
            accountvalues.put('ERP_System',acc.ERP_System__c!=null ? acc.ERP_System__c:'');
            
            countryname = '%'+acc.Country2__c.split('-')[1].trim() +'%';
            //siteName =acc.MailNickName__c;
            siteName = acc.SiteURL__c.substring(acc.SiteURL__c.lastindexof('/')+1);
            siteurl = acc.SiteURL__c;
            if(isUpload){
                if(DocContIdFileNameMap.size()>0){
                    contentVersionList = [SELECT id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : DocContIdFileNameMap.keySet() AND IsLatest = true];
                    for(ContentVersion contentVersion: contentVersionList){
                        ContVerIdWithFileName.put(contentVersion.id, DocContIdFileNameMap.get(contentVersion.ContentDocumentId));
                    }
                }
            }
        }
        else{
            task = [SELECT Subject,AP_Task__r.Subject__c,Action_Plan__c,Action_Plan_Task__c,Period__c,Task_Number__c,AP_Task__r.Action_Plan__c,Account__r.Country2__c,Account__r.Name,Account__r.SiteURL__c,Account__r.MailNickName__c FROM Task WHERE id =:recordId];
            taskvalues.put('Account_Name',task.Account__r.Name!=null ? task.Account__r.Name:'' );
            taskvalues.put('Action_Plan_Task',task.AP_Task__r.Subject__c!=null ? task.AP_Task__r.Subject__c:'');
            taskvalues.put('Task_Number',task.Task_Number__c!=null ? String.valueOf(task.Task_Number__c):'' );
            if(task.Action_Plan__c!=null){
                string actionplan = task.Action_Plan__c;
                actionplan = actionplan.substring(actionplan.indexOf('>')+1, actionplan.indexOf('<',1));
                system.debug(actionplan);
                string actionplanvalue = actionplan.substring(actionplan.indexOf('20'));
                system.debug(actionplanvalue);
                taskvalues.put('AP_Year',actionplanvalue);
            }
            
            taskvalues.put('Period',task.Period__c!=null ?String.valueOf(task.Period__c):'' );
            taskvalues.put('Country',task.Account__r.Country2__c!=null ? task.Account__r.Country2__c:'' );
            countryname =  task.Account__r.Country2__c!=null ?'%'+ task.Account__r.Country2__c.split('-')[1].trim() +'%': '';
            //siteName = string.valueOf(task.Account__r.MailNickName__c);
            siteName = string.valueOf(task.Account__r.SiteURL__c.substring(task.Account__r.SiteURL__c.lastindexof('/')+1));
            siteurl = string.valueOf(task.Account__r.SiteURL__c);
            if(isUpload){
                if(DocContIdFileNameMap.size()>0){
                    contentVersionList = [SELECT id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : DocContIdFileNameMap.keySet() AND IsLatest = true];
                    for(ContentVersion contentVersion: contentVersionList){
                        ContVerIdWithFileName.put(contentVersion.id, DocContIdFileNameMap.get(contentVersion.ContentDocumentId));
                    }
                }
            }
        }
        blob body;
        string ItemId,ContentDocumentId,token='';
        object result;
        String contentTypeName =  contentTypeId != '' ? contentTypeId.split(',')[1] : '';
        contentType = contentTypeId != '' ? contentTypeId.split(',')[0] : '';
        
        string requestBody='';
        
        if(accountvalues.size()>0){
            requestBody = '[{"FieldName":"ContentTypeId","FieldValue": "'+contentType+'"},'+
                '{"FieldName":"Account_Name","FieldValue":"'+accountvalues.get('Account_Name')+'"},'+
                '{"FieldName":"System_Origin","FieldValue": "salesforce"},'+
                '{"FieldName":"Title","FieldValue":"'+DocContIdFileNameMap.get('filename')+'"},'+
                '{"FieldName":"Country","FieldValue":"'+accountvalues.get('Country')+'"},'+
                '{"FieldName":"Org_Number","FieldValue":"'+accountvalues.get('Org_Number')+'"},'+
                '{"FieldName":"Firm","FieldValue":"'+accountvalues.get('Firm')+'"},'+
                '{"FieldName":"Company_Type","FieldValue":"'+accountvalues.get('Company_Type')+'"},'+
                '{"FieldName":"ERP_System","FieldValue":"'+accountvalues.get('ERP_System')+'"},'+
                '{"FieldName":"Project_Number_Operational","FieldValue":"'+accountvalues.get('Project_Number_Operational')+'"},';
        }
        
        if(taskvalues.size()>0){
            requestBody='[{"FieldName":"Action_Plan_Task","FieldValue": "'+taskvalues.get('Action_Plan_Task')+'"},' +
                '{"FieldName":"Account_Name","FieldValue":"'+taskvalues.get('Account_Name')+'"},'+
                '{"FieldName":"ContentTypeId","FieldValue": "'+contentType+'"},'+
                '{"FieldName":"System_Origin","FieldValue": "salesforce"},'+
                '{"FieldName":"Country","FieldValue":"'+taskvalues.get('Country')+'"},'+
                '{"FieldName":"Task_Number","FieldValue": "'+taskvalues.get('Task_Number')+'"},' +
                '{"FieldName":"Period","FieldValue": "'+taskvalues.get('Period')+'"},';
            if(taskvalues.containsKey('AP_Year')){
                requestBody+= '{"FieldName":"AP_x0020_Year","FieldValue":"'+taskvalues.get('AP_Year')+'"},';
            }
            
        }
        
        if(jsonStringRequiredFields!='' && jsonStringRequiredFields!=null){
            system.debug( JSON.deserializeUntyped(jsonStringRequiredFields));
            for(object requiredfield : (List<object> )JSON.deserializeUntyped(jsonStringRequiredFields)){
                map<string, object> field  =  (map<string,object>)requiredfield;
                for (String fieldName : field.keySet()){
                    if(fieldName !='Name'){
                        requestBody+= '{"FieldName":"'+fieldName + '","FieldValue":  "'+ string.valueOf(field.get(fieldName))+'"},';
                    }
                }
            }
        }
        
        if(!isUpload){
            requestBody+='{"FieldName":"Title","FieldValue":"'+DocContIdFileNameMap.get('filename')+'"},';
        }
        requestBody =  requestBody.removeEnd(',');
        requestBody+=']';
        
        if(isUpload){
            result =   UploadFilesUsingExternalApi(ContVerIdWithFileName,requestBody,siteurl,siteName,contentTypeName,isUpload);
            system.debug('result:: '+result);
            for (Map<String,String> itemDetails : (List<Map<String,String>>)result){
                siteurl = siteurl.split('/sites')[0];
                string documentUrl = siteurl + itemDetails.get('documentUrl').replace(' ','%20');
                DocumentDetails.put(itemDetails.get('FileName'), documentUrl);
            }
            SharepointWidgetController.DeleteFilesFromSalesforce(new List<string> (DocContIdFileNameMap.keySet()));
        }
        else
        {
            string filename;
            string newbody='';
            if(DocContIdFileNameMap.size()>0){
                ContVerIdWithFileName.put('filename', DocContIdFileNameMap.get('filename'));
            }
            result =  UploadFilesUsingExternalApi(ContVerIdWithFileName,newbody,siteurl,siteName,contentTypeName,isUpload);
            ItemId =  result !=null ? string.valueOf(result).split(',')[0]:'';
            if(ItemId!=''||ItemId!='0'){
                string documnetUrl = siteurl +'/Shared%20Documents/General/'+string.valueOf(result).split(',')[1];
                DocumentDetails.put(ContVerIdWithFileName.get('filename'),documnetUrl);
                SetMetaData(ItemId,siteurl,token,requestBody);
                UpdateitemAuthor(siteurl,ItemId);
            }
        }
        return DocumentDetails;
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    SetMetaData
Description:    Set metadata related to Account/Task to send with document to sharepoint
Inputs:         ItemId, Sharepoint siteurl, id of contenttype selected, values of fields from account and task object. 
Output:         Url of created/uploaded document.
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reason.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   
09 JUL 2020       Deepak                Upload Multiple Files CR
----------------------------------------------------------------------------------------------------------------------------------*/    
    
    public static void SetMetaData(string itemId,string siteurl,string token,string requestbody){
        string body ='';
        string EndpointUrl = siteurl+'/_api/web/lists/GetByTitle(\'Documents\')/items('+ItemId+')/ValidateUpdateListItem';
        body+='{"formValues":'+requestbody+'}';
        
        HttpResponse httpResponse = handleHttpCallout(EndpointUrl,'POST',body,token,'SetMetaData',null);
        
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    FetchviewsFromSharepoint
Description:    Fetches views related to account,country and contenttypes from sharepoint. 
Inputs:         Sharepoint siteurl, objName - Account/Task, country - related to Account/Task, viewId, and list containg name
of contenttypes.
Output:         Map of fetched views from sharepoint
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reason.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   

----------------------------------------------------------------------------------------------------------------------------------*/
    
    public static Map<string,object> FetchviewsFromSharepoint(string siteurl,string ObjName,string ViewId,List<String> FetchViewNameList){
        
        List<string> staticColumnFields = new  List<string>();
        //Alldocuments View fields.
        
        if(ObjName == 'Account'){
            staticColumnFields.add('Name');
            staticColumnFields.add('Title');
            staticColumnFields.add('Modified');
            staticColumnFields.add('Author');
            
        }
        else if(ObjName == 'Task'){
            staticColumnFields.add('Name');
            staticColumnFields.add('Title');
            staticColumnFields.add('Modified');
            staticColumnFields.add('Author');
            staticColumnFields.add('Task_Number');
            staticColumnFields.add('Period');
            staticColumnFields.add('Action_Plan_Task');
        }
        
        Map<string,object> Views = new Map<string,object>();
        
        HttpRequest httpRequest = new HttpRequest();
        String token = 'Bearer ' + SPTokenController.GetToken();
        string EndpointUrl = siteurl +'/_api/lists/getbytitle(\'Documents\')/views';
        
        HttpResponse httpResponse = handleHttpCallout(EndpointUrl,'GET','',token,'FetchviewsFromSharepoint',null);
        if(httpResponse.getStatusCode() == 200)
        {
            List<Map<string,object>> ListOfViews = new List<Map<string,object>>();
            
            //extract json object from response.
            object rootobject = JSON.deserializeUntyped(httpResponse.getBody());
            
            Map<string,object> Mapofvalues =  (Map<string,object>)JSON.deserializeUntyped(httpResponse.getBody());
            Map<string,object> d =  (Map<string,object>)Mapofvalues.get('d');
            //Extract list of views as results.
            List<object> results = (List<object>)d.get('results');
            string Seeallid;
            //iterate through each view and fetch the content and query fields of each view.
            for(object view : results){
                Map<string,object> Mapofviews = new map<string,object>();
                List<String> ViewFieldsList = new List<String>();
                Map<string,object> Mapofview =  (Map<string,object>)view;
                string viewName = string.valueOf(Mapofview.get('Title'));
                // fetch only view which are visible in sharepoint.
                if(!boolean.valueOf(Mapofview.get('Hidden'))){
                    if(viewName=='All Documents'){
                        Seeallid=string.valueOf(Mapofview.get('Id'));
                    }
                    String XMLviewData = (String)Mapofview.get('HtmlSchemaXml');
                    XMLviewData = XMLviewData.replace('\\\'', '\'');
                    
                    string viewQuery ='';
                    //Extract ViewQuery from the XMLviewData.
                    if(XMLviewData.indexOf('<Query>') > 1){
                        viewQuery = XMLviewData.substring(XMLviewData.indexOf('<Query>')+7,XMLviewData.indexOf('</Query>'));
                    }
                    Dom.Document domElement = new Dom.Document();
                    domElement.load(XMLviewData);
                    dom.XmlNode ViewFields = domElement.getRootElement().getChildElement('ViewFields',null);
                    List<dom.XmlNode> ListofViewFields = ViewFields.getChildren();
                    //iterate through each field get name of fields.
                    for(dom.XmlNode Field : ListofViewFields){
                        ViewFieldsList.add(Field.getAttributeValue('Name', ''));
                    }
                    // put all the values in map as prop.
                    
                    Mapofviews.put('viewName',domElement.getRootElement().getAttribute('DisplayName', null));
                    if(String.valueOf(Mapofview.get('Id'))==ViewId && ViewId!=''){
                        Mapofviews.put('DefaultView',true);   
                        MapOfViews.put('ViewDisplayFields',staticColumnFields);
                    }
                    else if(ViewId=='' && Boolean.valueOf(Mapofview.get('DefaultView'))){
                        Mapofviews.put('DefaultView',true);   
                        MapOfViews.put('ViewDisplayFields',staticColumnFields);
                    }
                    
                    Mapofviews.put('Id',Mapofview.get('Id'));
                    //add  map to list of views 
                    
                    if(FetchViewNameList.contains(viewName) ||viewName=='All Documents'){
                        ListOfViews.add(Mapofviews);
                    }
                    
                }
            }
            
            Views.put('ListOfViews',ListOfViews);
            Views.put('token',token);
            Views.put('Seeallid',Seeallid);
        }
        return Views;
    }    
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    getTermStore
Description:    Fetches term store(requires field) and its values related to contenttypes from sharepoint. 
Inputs:         Id of particular term store
Output:         List of termstore values of particular required field
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reason.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   

----------------------------------------------------------------------------------------------------------------------------------*/
    
    
    public static List<Object> getTermStore(String termsID){
        
        String EndpointUrl = Externalfileurl.Fetch_TermStore__c+'/'+termsID;
        HttpResponse httpResponse = handleHttpCallout(EndpointUrl,'GET','','','getTermStore',null);
        
        List<Object> tsDataList;
        if(httpResponse.getStatusCode()==200){
            tsDataList = (List<Object>)JSON.deserializeUntyped(httpResponse.getBody());
        }
        return tsDataList;
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    UpdateitemAuthor
Description:    Assigns/sets user's name as author/editor for newly created item in sharepoint document library using cutom web api
Inputs:         Sharepoint siteurl, item/document Id
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reason.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   

----------------------------------------------------------------------------------------------------------------------------------*/
    
    
    @future(callout=true)
    public static void UpdateitemAuthor(String Siteurl,String itemId){
        String emailAddress =  UserInfo.getUserEmail();
        String EndpointUrl =Externalfileurl.Update_Item_Author__c;
        String body='{"siteUrl": "'+Siteurl+'" ,"itemId":'+itemId+', "userEmailId":"'+emailAddress+'"}';  
        
        HttpResponse httpResponse = handleHttpCallout(EndpointUrl,'POST',body,'','UpdateitemAuthor',null);
        
        if(httpResponse.getStatusCode()==200){
            system.debug('UpdateitemAuthor Responsebody: ' + httpResponse.getBody());
        }
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    handleHttpCallout
Description:    Handle Http Callout for all above functions
Inputs:         Endpoint url, Get/Post method, response body, access token, function name, document/file
Output:         Resposne from sharepoint for the callouts
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reason.

<Date>          <Authors Name>      Modification Reason 
02 Oct 2019       Deepak                    -   

----------------------------------------------------------------------------------------------------------------------------------*/
    
    
    public static HttpResponse handleHttpCallout(string Endpoint,String Method, string body, string token ,string functionName,blob filebody){
        
        HttpResponse httpResponse = new HttpResponse();
        HttpRequest httpRequest = new HttpRequest();
        try{
            httpRequest.setEndpoint(Endpoint);
            httpRequest.setMethod(Method);
            
            if(Method=='POST'){
                httpRequest.setBody(body);
            }
            
            if((token==''||token==null) && functionName!='UpdateitemAuthor' && functionName!='getTermStore'){
                token = 'Bearer ' + SPTokenController.GetToken();
            }
            if(functionName!='UpdateitemAuthor'&& functionName!='getTermStore'){
                httpRequest.setHeader('Authorization', token);
            }
            if(functionName=='FetchviewsFromSharepoint')
            {
                httpRequest.setHeader('Accept', 'application/json;odata=verbose');
            }
            else if(functionName=='SetMetaData'|| functionName=='getAllDocuments'){
                httpRequest.setHeader('Accept', 'application/json;odata=nometadata');
                httpRequest.setHeader('Content-Type','application/json;odata=verbose');
            }
            else if(functionName=='fetchContentTypesWithRequiredColums'){
                httpRequest.setHeader('Content-Type','application/json;odata=nometadata');  
                httpRequest.setHeader('Accept','application/json;odata=nometadata'); 
            }
            else if(functionName=='UpdateitemAuthor'){
                httpRequest.setHeader('Content-Type', 'application/json');
            }
            else
            {
                httpRequest.setHeader('Accept', 'application/json');  
                httpRequest.setHeader('Content-Type', 'application/json');
            }
            
            system.debug('Endpoint : '+Endpoint);
            system.debug('body : '+body);
            Http http = new Http();
            httpResponse = http.send(httpRequest);
            
            System.debug('Status Code ' + httpResponse.getStatusCode());
            System.debug('Response Body ' + httpResponse.getBody());
            
        }catch(Exception ex){
            system.debug('Exception in Function : '+functionName+', Message : '+ex.getMessage());
        }
        return httpResponse;
    }
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    UploadFilesUsingExternalApi
Description:    Upload File Using External web Api for large file size greater then 6 MB.
Inputs:         contentVersionid =salesforce content version id , filename= name of the file to set in sharepoint, 
siteurl= sharepoint site url, sitename= sharepoint filename in which file is to be uploded.
Output:         Resposne from API for Itemid and filename of the uploaded document.
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reason.

<Date>          <Authors Name>      Modification Reason 
11 NOV 2019       Deepak                    -   
09 JUL 2020       Deepak                Upload Multiple Files CR
----------------------------------------------------------------------------------------------------------------------------------*/
    public static object UploadFilesUsingExternalApi(Map<string,string> ContVerIdWithFileName, string MetaDataRequestBody,string siteurl,string sitename,string contentTypeName,boolean isUpload){
        string itemAndFileName='',RequestBody,Endpoint;
        string contentDocumentURL;
        Organization org = [select IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
        if(isUpload){
            string baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            RequestBody='{"Files": [';
            string filesbody ='';
            for(String VersionId : ContVerIdWithFileName.keyset()){
                filesbody+= '{"FileName":"'+ContVerIdWithFileName.get(VersionId)+ '","FileTitle": "'+ContVerIdWithFileName.get(VersionId) +'", "SFDFileUrl":"'+baseUrl+'/services/data/v47.0/sobjects/ContentVersion/'+VersionId+'/VersionData'+'"},';                
            }
            
            filesbody = filesbody.removeEnd(',');
            RequestBody+=filesbody +'],';
            RequestBody+='"MetaDatas":'+MetaDataRequestBody+',';
            RequestBody+='"SPOWebUrl":"'+siteurl+'", "DocumentPath":"Shared%20Documents/General", "SiteName":"'+sitename+'", "AuthorEmailId" : "'+UserInfo.getUserEmail()+'" }';
            Endpoint = Externalfileurl.Upload_File__c;            
        }
        else
        {
            Endpoint=Externalfileurl.CreateNewFile__c;
            RequestBody='{ "FileName" :"'+ContVerIdWithFileName.get('filename')+'", "ContentTypeName":"'+contentTypeName+'","SPOWebUrl":"'+siteurl+'", "DocumentPath":"Shared%20Documents/General", "SiteName":"'+sitename+'" }';
            
        }
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(Endpoint);
        httpRequest.setMethod('POST');
        httpRequest.setHeader('content-type', 'application/json');
        HttpRequest.setBody(RequestBody);
        httpRequest.setTimeout(120000);
        Http http = new Http();
        HttpResponse httpResponse = new HttpResponse();
        httpResponse = http.send(httpRequest);
        
        If(httpResponse.getStatusCode() == 301 || httpResponse.getStatusCode() == 302)
        {    
            system.debug('Location : '+httpResponse.getHeader('Location'));
            httpRequest.setEndpoint(httpResponse.getHeader('Location'));
            httpResponse = new Http().send(httpRequest);
        }
        system.debug('Endpoint : '+Endpoint);
        system.debug('Request Body '+RequestBody);
        System.debug('Status Code ' + httpResponse.getStatusCode());
        System.debug('Response Body ' + httpResponse.getBody());
        if(httpResponse.getStatusCode()==200){
            if(isUpload){
                List<Map<String,String>> ListOfItemAndFileNameMap = new  List<Map<String,String>>();
                Map<string,object> uploadFilesResponse = (Map<string,object>)JSON.deserializeUntyped(httpResponse.getBody());
                Map<string,object> getdata = (Map<string,object>)uploadFilesResponse.get('data');
                List<Object> getItems = (List<Object>)getdata.get('Items');
                Map<String,String> itemAndFileNameMap ;
                for(Object fileobj : getItems){
                    itemAndFileNameMap = new  Map<String,String>();
                    Map<string,object> itemsfiles = (Map<string,object>)fileobj;
                    if(itemsfiles.get('ItemId') != null){
                        itemAndFileNameMap.put('ItemId', string.valueOf(itemsfiles.get('ItemId')));
                        itemAndFileNameMap.put('FileName', string.valueOf(itemsfiles.get('FileName')));
                        itemAndFileNameMap.put('documentUrl', String.valueOf(itemsfiles.get('FileURL')));
                        ListOfItemAndFileNameMap.add(itemAndFileNameMap);
                    }
                }
                System.debug('itemAndFileNameList : '+ListOfItemAndFileNameMap);
                return ListOfItemAndFileNameMap;
            }
            else
            {
                Map<string,object> uploadFileResponse = (Map<string,object>)JSON.deserializeUntyped(httpResponse.getBody());
                Map<string,object> getdata = (Map<string,object>)uploadFileResponse.get('data');
                itemAndFileName =  string.valueOf(getdata.get('ItemId')) + ','+ string.valueOf(getdata.get('FileName'));
                system.debug('uploadFileResponse : '+uploadFileResponse); 
                return itemAndFileName;
            }
        }
        return null;
    }
}