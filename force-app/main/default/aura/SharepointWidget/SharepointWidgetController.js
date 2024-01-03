({
    doInit : function(component, event, helper) {
        // Call alldocuments function from helper on load of component
        helper.alldocuments(component, event, helper);
       
        setTimeout(function(){    
            // Call OnloadJquery function on load of component
            helper.OnloadJquery(component, event, helper);
            component.set('v.Spinner',false);
        }, 5000);
    },
    
    // Set uploaded file properties on upload finished
    onFileSelectChange : function(component, event, helper){
        var uploadedfiles = event.getParam("files");
        var uploadedFilesProperty =[];
        var contentVersionIds = [];
        // Iterate through uploadedfiles to create new map of separated fileName and fileExtension
        for(var file = 0; file < uploadedfiles.length; file++){
            uploadedFilesProperty.push({'fileName':(uploadedfiles[file].name).substring(0,(uploadedfiles[file].name).lastIndexOf('.')),'fileExtension': (uploadedfiles[file].name).substring((uploadedfiles[file].name).lastIndexOf('.')), 'documentId' : (uploadedfiles[file].documentId)});
            contentVersionIds.push(uploadedfiles[file].ContentVersionId);
        }
        component.set("v.uploadedFilesProperty",uploadedFilesProperty);
        component.set("v.contentVersionIds",contentVersionIds);
        console.log(JSON.stringify(uploadedFilesProperty));
        component.set("v.isUpload", true);
        component.set('v.uploadDisabled',false);
        helper.Uploadfilehandler(component, event, helper);
    },
    closeModel : function(component, event, helper){
        // for Hide/Close Model,set the "isOpen" attribute to "False"  
        if(component.get("v.isUpload")){
            helper.DeleteFilesOnCancel(component, event, helper);
        }
        component.set("v.NoContentTypes", false);
        component.set("v.ModelPopUp", false);
        component.set("v.ShowContentType", false);
        component.set("v.ShowResponseMessage", false);
        component.set("v.ContentTypeFieldsList", []);
        component.set("v.selectedContentType", '');
        component.set("v.showFileDetailMessage", false);
        component.set("v.showResponseMessage", false);
        component.set("v.ShowerrorMessage", false);
        component.set("v.FileExitsInSharepoint", false);
        component.set("v.fileName",'');
        component.set("v.Disabled", false); 
        component.set("v.isUpload", false);
        component.set('v.Spinner',false);
        component.set("v.fileExtension",'');
        
        
    },
    // Save New document
    openNewfile : function(component, event, helper){
        var fieldsList=  helper.setrequiredfieldsvalues(component, event, helper);
        
        if(fieldsList==''){
            component.set('v.Spinner',true);
            var fileName= component.find("filename").get("v.value");
            var newFileName = [];
            // create new map to bind with apex method
            newFileName.push({"DocContentId":"filename","fileName":fileName});
            component.set('v.changedFileNameList',newFileName);
            helper.uploadFiles(component,helper); 
        }
        else{
            alert('Please enter require values for these fields:  '+fieldsList);
        }
    },
    //on select of Content type required fields being fetched from Sharepoint
    onSelectChange : function(component, event, helper){
        helper.SetrequiredFields(component, event, helper);
    },
    
    // set file properties on click of upload if user changes from input 
    // and call helper method CheckifFilesExits
    CheckFileWithSP: function(component, event, helper) {
       helper.insertAccountid(component, event, helper);
        var uploadedfiles = component.get("v.uploadedFilesProperty");
        var changedFileNameList = [];
        for(var file = 0; file < uploadedfiles.length; file++){
            changedFileNameList.push({"DocContentId":$('#fileName'+file).attr('data-contentdocumentId'),"fileName":$('#fileName'+file).val()+uploadedfiles[file].fileExtension});
        }
        component.set('v.changedFileNameList',changedFileNameList);
        console.log('changedFileNameList : '+JSON.stringify(changedFileNameList));
        var fieldsList=  helper.setrequiredfieldsvalues(component, event, helper);
        if(fieldsList==''){
            component.set('v.Spinner',true);
            var fileName = component.get("v.fileName") + component.get("v.fileExtension");
            helper.CheckifFilesExits(component, event, helper,changedFileNameList);
        }
        else{
            alert('Please enter require values for these fields:  '+fieldsList);
        }
         $A.enqueueAction(action);
    },
    
    //upload files on click of Yes
    uploadFileToSP: function(component, event, helper) {
        component.set('v.Spinner',true);
        helper.uploadFiles(component, helper);
    },
    
    // sort columns ASC/DESC according to columnname
    sortingOflist  :function(component, event, helper) {
        component.set('v.Spinner',true);
        event.preventDefault();
        var docList = component.get('v.Documents');
        
        var selectedfieldname ;
        if(event.srcElement.textContent == 'Name'){
            selectedfieldname = 'LinkFilename';
        }
        else{
            selectedfieldname = event.srcElement.textContent;
        }
        var sortDirection = component.get('v.sortDirection');
        var sortColumn = component.get('v.sortColumn');
        if(sortColumn == ''){
            sortColumn = component.set('v.sortColumn',selectedfieldname);
            sortDirection = component.set('v.sortDirection',"Asc");
        }
        else if(sortColumn == selectedfieldname){
            sortDirection = component.set('v.sortDirection',"Desc");
        }
            else {
                component.set('v.sortColumn',selectedfieldname);
                sortDirection = component.set('v.sortDirection',"Asc");
            }
        helper.alldocuments(component, event, helper);
        setTimeout(function(){component.set('v.Spinner',false);}, 3000);
        
    },
    
    // check if enter keywords contains more than 3 characters
    OnSearch:function(component, event, helper) {
        
        var isEnterKey = event.keyCode === 13;
        var queryTerm = component.find('enter-search').get('v.value');
        if (isEnterKey ) {
            if(queryTerm!='' && queryTerm.length>2){
                component.set('v.issearching', true);
                component.set("v.SearchText",queryTerm);
                component.set('v.SearchDate', true);
                helper.OnSearchhelper(component, event, helper);
            }
            else
            {
                alert('Please enter atleast 3 characters');
            }
        }
        
    },
    
    // clear search box
    OnSearchClear:function(component, event, helper) {
        var queryTerm = component.find('enter-search').get('v.value');
        if(queryTerm==''){
            component.set('v.SearchDate', false);
            helper.alldocuments(component, event, helper);
            component.set('v.Spinner',false);
        }
    },
    
    // redirect to Document properties modal box on click of No
    RedirectToDocumentProperties:function(component, event, helper) {
        
        component.set("v.FileExitsInSharepoint",false);
        component.set("v.ModelPopUp", true);
        component.set("v.ShowContentType",true);
        setTimeout(function(){ $("#contenttype").select2();$("#termstore").select2(); $("#contenttype").select2();  }, 100);
        
        
    }
})