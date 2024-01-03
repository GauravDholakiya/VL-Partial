({
   
    // on load of document fetched all details of site
    
    alldocuments : function(component, event, helper) {
        component.set('v.Spinner',true);
       
        
        
        var action = component.get("c.getAllDocuments");
        action.setParams({ sobjectid : component.get("v.recordId"),
                          SortDir : component.get('v.sortDirection'),
                          SortField : component.get('v.sortColumn'),
                          ViewId :  component.get('v.ViewId')});
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Results-->',result);
               
                
                if(!result.isWidgetActive){
                    component.set('v.isWidgetActive',result.isWidgetActive);
                    component.set('v.inActiveMessage',result.inActiveMessage);
                    component.set('v.Spinner',false);
                    return;
                    
                }
                component.set('v.isWidgetActive',result.isWidgetActive);
                component.set('v.Documents',result.Documents);
                if(result.isWidgetActive && !($A.util.isEmpty(result.ContentTypes))){
                    component.set('v.ContenttypesMap',result.ContentTypes);
                    component.set('v.NoContentTypes',false);
                   
                }
                else{
                    component.set('v.NoContentTypes',true);
                    component.set('v.uploadDisabled',true);
                }
                component.set('v.ViewsList',result.Views);
                component.set('v.SeeAlllink',result.SeeAll);
                component.set("v.sObjectId",result.sobjectid);
                component.set("v.sObjectName",result.sobjectName);
                if(result.TimeZone!=''){
                    component.set("v.TimeZone",result.TimeZone);
                }
                console.log(result.TimeZone);
                
                //Iterate through Views to get ViewDisplayFields
                for(var i=0; i< result.Views.length;i++){
                    if(result.Views[i].DefaultView){
                        component.set('v.ViewDisplayFields',result.Views[i].ViewDisplayFields);
                        break;
                    }
                }
                helper.setDocIcons(component, event, helper);
                setTimeout(function(){                    
                    $('.def-itemname').click(function(){
                        console.log(this.innerText);
                        var viewid =  component.get('v.ViewsList').filter(i=>i.viewName==this.innerText);
                        component.set('v.SetView',this.innerText);
                        component.set('v.ViewId',viewid[0].Id);
                        helper.alldocuments(component, event, helper);
                        $(".rib-innerbox").hide();
                    }); 
                    component.set('v.Spinner',false);  
                }, 1000);            }
            else if (state === "ERROR"){
                component.set('v.Spinner',false);
            }
        });
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
     
    // save single and upload multiple documents in sharepoint
     uploadFiles: function(component,helper) {
        var action = component.get("c.saveTheFiles");
        
        action.setParams({
            recordId: component.get("v.recordId"),
            sObjectId: component.get("v.sObjectId"),
            fileNameList: component.get('v.changedFileNameList') ,
            contentType: component.get("v.selectedContentType") + ','+ component.get("v.ContenttypeName"),
            jsonStringrequiredfields : JSON.stringify( component.get("v.jsonlistofrequiredfields")),
            isupload : component.get("v.isUpload") 
            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                if(response.getReturnValue()!='' && response.getReturnValue()!=null && response.getReturnValue()!=undefined){
                                        
                    if(component.get("v.isUpload")){
                        var url = response.getReturnValue();
                        var result = [];
                        for(var key in url){
                            result.push({'FileName' :key, 'URL':url[key]});
                        }
                        component.set("v.savedFiles",result);
                        if(result.length == 1){
                            component.set("v.doclink",result[0].URL);
                        }
                        
                    }
                    else
                    {
                        var returnurl = '';
                        var keys =  Object.keys(response.getReturnValue());
                        var responseurl = response.getReturnValue()[keys[0]];
                        
                        if( responseurl.endsWith('docx')||responseurl.endsWith('dotx')){
                            returnurl = 'ms-word:ofe|u|'+responseurl;
                        }
                        if(returnurl==''){
                            var arrxl = ['xlsx','xls','xlsm'];
                            for (var i=0 ;i < arrxl.length ;i++){
                                if( responseurl.endsWith(arrxl[i])){
                                    returnurl = 'ms-excel:ofe|u|'+responseurl;
                                    break;
                                }
                            }
                        }
                       component.set("v.doclink", returnurl); 
                    }
                    
                    component.set("v.ShowResponseMessage", true);
                    helper.alldocuments(component, event, helper);
                }
                else{
                    // Display pop up for error while uploading a file to sharepoint
                    
                    component.set("v.ErrorHeader", "Error"); 
                    component.set("v.ErrorHeader", "Something went wrong"); 
                    
                    if(component.get("v.isUpload")){
                        component.set("v.ErrorMessage", "Unable to upload file."); 
                    }
                    else{
                        component.set("v.ErrorMessage", "Unable to create file.");
                        
                    }
                    component.set("v.ShowerrorMessage", true);
                    
                }
            }
            else if(state==='ERROR'){
                component.set("v.ErrorHeader", "Error"); 
                
                if(component.get("v.isUpload")){
                    component.set("v.ErrorMessage", "Unable to upload file."); 
                }
                else{
                    component.set("v.ErrorMessage", "Unable to create file."); 
                } 
                component.set("v.ShowerrorMessage", true);
            }
            component.set("v.ShowContentType", false); 
            component.set("v.FileExitsInSharepoint", false);
            component.set('v.Spinner',false);
        });
        $A.enqueueAction(action); 
    },
    
    //fetch termstore from sharepoint based on selected content type
    fetchTermStore : function(component, helper, columnName,requiredfieldslist){
        component.set('v.Spinner',true);
        var action = component.get("c.fetchGettermStore");
        action.setParams({ termStoreName : columnName});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.TermStorelist", result);
                component.set('v.ContentTypeFieldsList',requiredfieldslist);
                if(component.get("v.isUpload")){
                    component.set("v.Disabled", true);   
                }
                
                component.set("v.ShowContentType", true);
                component.set("v.ShowerrorMessage", false);
                component.set("v.ModelPopUp", true);
                component.set('v.Spinner',false);
                setTimeout(function(){ $("#contenttype").select2(); $("#termstore").select2(); component.set('v.Spinner',false); }, 100);
                setTimeout(function(){
                    if($($("#termstore").next()).hasClass("select2 select2-container")){
                        $($("#termstore").next()).addClass("termstoreSpan");
                    }
                    
                }, 1000);
            }
            else if(state==='ERROR'){
                component.set('v.Spinner',false);
                component.set("v.ErrorHeader", "Error"); 
                component.set("v.ErrorMessage", "Unable to fetch require field values.");
            }
        });
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    // set content type values and iterate in Dropdown
    setContentTypeValues : function(component, event, helper){
        var ContenttypesMap  =  component.get('v.ContenttypesMap');
        var ContentTypes =[];
        ContentTypes.push({'value':'','text': 'Select Content Type','IsNewType' : true});
        for (var key in ContenttypesMap){
            var keysplit = key.split(',');
            ContentTypes.push({'value':keysplit[1],'text': keysplit[0],'IsNewType' : keysplit[2]});
        }
        component.set('v.ContenttypeNameList',ContentTypes);
    },
    
    // handle content types and required fields after document uploaded in Salesforce
    Uploadfilehandler : function(component, event, helper){
            helper.setContentTypeValues(component, event, helper);
            component.set("v.isUpload", true);
       		 component.set('v.uploadDisabled',false);
            helper.SetrequiredFields(component, event, helper);
        
    },
    
    // Set Content type according to IsNewType and if file is Uploaded
    // check if content type is selected in modal box
    SetrequiredFields : function(component, event, helper){
        
        var contenttypevalue ='';
        var contenttypeName='';
        var IsNewType ='';
        
        if(component.get("v.selectedContentType")!='' || component.get("v.isUpload")){
            component.set("v.SaveDisabled", false);  
            if($("#termstore")){
                $("#termstore").select2('destroy'); 
            }
            
            //if file is uploaded content type will be set accordingly
            if(component.get("v.isUpload")){
                var contenttypeList = component.get("v.ContenttypeNameList");
                for(var i=0 ;i< contenttypeList.length ;i++){
                    if(contenttypeList[i].IsNewType=='false'){ 
                        IsNewType = contenttypeList[i].IsNewType;
                        contenttypevalue= contenttypeList[i].value;
                        contenttypeName= contenttypeList[i].text;
                        contenttypeList[i].IsNewType = 'true';
                    }
                    else{
                        contenttypeList[i].IsNewType = 'false';
                    }
                }
                component.set("v.ContenttypeNameList", contenttypeList);
                component.set("v.ContenttypeName", contenttypeName);
                component.set("v.selectedContentType", contenttypevalue);
            }
            else
            {
                component.get("v.ContenttypeNameList").find(function(currentValue, index, arr){
                    if(currentValue.value == component.get("v.selectedContentType")){ 
                        IsNewType = currentValue.IsNewType;
                        contenttypeName = currentValue.text; 
                    }
                    
                });
                component.set("v.ContenttypeName", contenttypeName);
            }
            var ContenttypesMap=  component.get('v.ContenttypesMap');
            var requiredfieldslist = ContenttypesMap[contenttypeName +','+ component.get('v.selectedContentType')+','+IsNewType];
            
            
            var columnName='';
            // Iterate through requiredfieldslist to get Name of required fields(ColumnName)
            for(var i=0; i<requiredfieldslist.length;i++){
                if(requiredfieldslist[i].ColumnType=='TaxonomyFieldTypeMulti'){
                    columnName = requiredfieldslist[i].ColumnName;
                }
            }
            if(columnName!=''){
                helper.fetchTermStore(component, helper,columnName,requiredfieldslist);    
            }
            else{
                component.set('v.ContentTypeFieldsList',requiredfieldslist);
                if(component.get("v.isUpload")){
                    component.set("v.Disabled", true);   
                    setTimeout(function(){ $("#contenttype").select2();},100);
                }
                component.set("v.ShowContentType", true);
                component.set("v.ShowerrorMessage", false);
                component.set("v.ModelPopUp", true);
                component.set('v.Spinner',false);
            }
        }
        else{
            component.set("v.SaveDisabled", true);  
            $(".termstoreSpan").remove();
        }
    },
    
    // validate required fields values are not missing in inputs
    setrequiredfieldsvalues : function(component, event, helper){
        var ContentTypeFieldsList =  component.get("v.ContentTypeFieldsList");
        var fieldsList='';
        var filesWithChangedNames = component.get("v.changedFileNameList");
        var listofuploadedfiles = [];
        for(var key in filesWithChangedNames){
            if($('#fileName'+key).val() != '' && $('#fileName'+key).val() != null){
                listofuploadedfiles.push($('#fileName'+key).val());
            }
            else{
               fieldsList = 'FileName is missing';
               return fieldsList; 
            }
        }
        var listofrequiredfields = [];
        var flag = false;
        
        if(listofuploadedfiles!='' || component.get("v.fileName")!=''){
            for( var i =0 ; i < ContentTypeFieldsList.length ; i++){
                var field =  ContentTypeFieldsList[i].ColumnName ;
                if(ContentTypeFieldsList[i].ColumnType=='TaxonomyFieldTypeMulti'){
                    var selectedTags= $('#termstore').select2("val").toString().replace(',','');
                    if(selectedTags!='' && selectedTags !=undefined){
                        listofrequiredfields.push({[field] : selectedTags });
                    }
                    else{
                        flag = true;
                        fieldsList += field + ',';
                    }
                }
                else{
                    
                    $("#"+field).val();
                    if( $("#"+field).val()!='' &&  $("#"+field).val() !=undefined){
                        listofrequiredfields.push({[field] :  $("#"+field).val()});
                    }
                    else{
                        flag = true;
                        fieldsList += field + ',';
                    }
                    
                }
            }
            fieldsList=fieldsList.replace(/,*$/, "");  
            
            if(!flag){
                component.set("v.jsonlistofrequiredfields",listofrequiredfields);
            }
        }
        else{
            fieldsList+='fileName';
        }
        
        return fieldsList;
    },
    
    // call apex method to search from sharepoint and return documents
    OnSearchhelper : function(component, event, helper) {
        
        var action = component.get("c.searchdocuments");
        action.setParams({ accountid : component.get("v.sObjectId"), 
                          searchtext : component.get("v.SearchText")
                         });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                component.set('v.Documents',result);
                helper.setDocIcons(component, event, helper);
                component.set('v.issearching', false);
            }
            else if(state==='ERROR'){
                component.set('v.Spinner',false);
                component.set("v.ErrorHeader", "Error"); 
                component.set("v.ErrorMessage", "Unable to search files."); 
                
            }
        });
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    // jQuery works onload of component
    OnloadJquery :function(component, event, helper){
        $(document).ready(function(){
        
            $('.ribbon-lbl.new').click(function(){
                
                helper.setContentTypeValues(component, event, helper);
                
                if(component.get('v.ContenttypesMap') != '{}'){
                    component.set('v.ModelPopUp', true);
                    component.set('v.ShowContentType', true);
                    component.set("v.SaveDisabled", true);
                   
                }
                else{
                    component.set('v.uploadDisabled',true);
                    component.set('v.NoContentTypes',true);
                   
                }
                
                $("#contenttype").select2();
                $("#contenttype").on('change', function() {
                    var contenttypevalue = $('#contenttype').select2("val").toString();
                    component.set("v.selectedContentType", contenttypevalue); 
                    $("#contenttype").select2('destroy').select2();
                    
                    helper.SetrequiredFields(component, event, helper);
                });
                
                
            });
            $("#rib-droplink").click(function(){
                if($(".rib-innerbox").css('display')=='block')
                {
                    $(".rib-innerbox").hide();
                    
                }
                else{
                    $(".rib-innerbox").show();
                    
                }
                
            });
            $(".tib-menulist li").click(function(){
                if(this.id =='tiles'){
                    component.set('v.Tiles',true);
                    component.set('v.Details',false);
                    component.set("v.dragdropClass",".doc-list-part");
                    $(".rib-innerbox").hide();
                }
                else if(this.id =='details')
                {
                    component.set('v.Tiles',false);
                    component.set('v.Details',true);
                    component.set("v.dragdropClass",".doc-table-part");
                    $(".rib-innerbox").hide();
                }
                
            });
            
            $(".new-inbox li").click(function(){
                console.log(this.id);
                component.set('v.ContenttypeName',this.innerText);
                component.set('v.ContenttypeId',this.id);
                component.set('v.ModelPopUp', true);
                component.set('v.ShowContentType', true);
                
            });
            
        });
    },
    
    // set icons of documents in UI(Widget)
    setDocIcons :function(component, event, helper){
        var item = component.get("v.Documents");
        var docicon='';
        var arr = ['docx','pdf','xlsx','pptx','folder','txt'];
        var arrxl = ['xlsx','xls','xlsm'];
        var imgarr = ['jpg','png','jpeg','svg'];
        for(var i=0;i<item.length;i++){
            if(imgarr.indexOf( item[i].DocIcon) > -1){
                item[i].DocIcon = 'photo';
            }
            else if(arrxl.indexOf( item[i].DocIcon) > -1){
                item[i].DocIcon = 'xlsx';
            }
                else if(!(arr.indexOf( item[i].DocIcon) > -1)){
                    item[i].DocIcon = 'code';
                }
        }
        component.set("v.Documents",item);
    },
    
    // delete ContentDocumentId after files is uploaded successfullly
    DeleteFilesOnCancel :function(component, event, helper){
        var ContentDocumentId =  component.get('v.uploadedFilesProperty');
        
        var ContentDocumentIdList =[];
        for(var i=0; i< ContentDocumentId.length; i++){
            ContentDocumentIdList.push(ContentDocumentId[i].documentId);
        }
        //console.log('ContentDocumentIdList :'+ContentDocumentIdList);
        component.set("v.ContentDocumentIdList",ContentDocumentIdList);
        var action = component.get("c.DeleteFilesFromSalesforce");
        action.setParams({ ContentDocumentIdList : ContentDocumentIdList});
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Files Deleted Successfully from Salesforce');
            }
            else
            {
                console.log('Error deleting files from the salesforce');
            }
        });
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    //helper function to call apex method CheckIfFilesExistsInSharepoint
    //and return list of existing files
    CheckifFilesExits: function (component, event, helper,changedFileNameList){
        
        var action = component.get("c.CheckIfFilesExistsInSharepoint");
        action.setParams({ accountId : component.get("v.sObjectId") ,
                          listofFileNames :  changedFileNameList});
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length > 0){
                    component.set("v.FileExitsInSharepointName",result);
                    component.set('v.Spinner',false);
                    component.set("v.ShowContentType",false);
                    component.set("v.FileExitsInSharepoint",true);
                    
                }
                else
                {
                    component.set('v.Spinner',true);
                    helper.uploadFiles(component, helper);
                }
            }
            else
            {
                console.log('Error verifying file from the sharepoint');
            }
        });
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    insertAccountid: function (component, event, helper){	
        
    	 var action = component.get("c.CreateRecord");
     action.setParams({ accountId : component.get("v.sObjectId")});
        				
     
       
        
      $A.enqueueAction(action);
       console.log('**my action-->'+action);
    }
    
    
})