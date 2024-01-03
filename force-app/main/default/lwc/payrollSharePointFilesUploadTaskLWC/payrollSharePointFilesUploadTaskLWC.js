import { LightningElement, wire, track, api } from 'lwc';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import { unsubscribe as empUnSub } from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex';
//Controller import
import uploadFile from '@salesforce/apex/sharepointFileUploadController.uploadFile';
import checkforExistingMultipleFilesTask from '@salesforce/apex/sharepointFileUploadController.checkforExistingMultipleFilesTask';
import getCustomSettings from '@salesforce/apex/sharepointFileUploadController.getCustomSettings';
import getTasksWithCustomFields from '@salesforce/apex/sharepointFileUploadController.getTasksWithCustomFields';
import isTaskWidgetAccessible from '@salesforce/apex/sharepointFileUploadController.isTaskWidgetAccessible';
import CreateLWCRecord from '@salesforce/apex/sharepointFileUploadController.CreateLWCRecord';
import getAllFileDocuments from '@salesforce/apex/sharepointFileUploadController.getAllFileDocumentsTask';

// LMS import 

import SharePointToken from '@salesforce/messageChannel/payrollsharepointToken__c';
import requestSharePointToken from '@salesforce/messageChannel/payrollrequestSharepointToken__c';
//User Fields
import USER_ID from '@salesforce/user/Id';
export default class sharepointFileUploadController extends LightningElement {

    @track isWidgetAccessibleResponse = {
        showWidget: '',
        message: ''
    };
    userId = USER_ID;
    @track isLoading = true;
    @track tabsection = true;
    @api recordId;
    @api Type;
    @track taskNumberString;
    selectedFiles = [];
    @track displayError = false;
    @track errorMessage = '';
    @track showErrorMessage = false;
    @api showFilePropertiesModalpayroll = false;
    @api isCheckingFileExists = false;
    @api showOverWriteModalpayroll = false;
    @track selectedDocTypeFieldAPIName = '';
    @track selectedDocTypeLabel = '';
    @track options;
    @track showSpinner = false;
    token = '';
    @track url1;
    @track newUploadedFileUrl = '';
    @track uploadedFileNames = [];
    @track progressBarModalError = '';
    @track authenticationEM = 'Authentication Failed or User Cancelled Authentication Request or a pop-up window was blocked.';
    @track fileUploadInProgressEM = 'File upload is in progress. Please wait.';
    @track uploadedFiles = 0; // Used to display upload count on progress bar
    // file upload values
    fileData;
    @track file;
    @track fileContents;
    @track fileextension = '';
    @api payrollfiles = [];
    @api renamedfiles = [];
    @track documents = [];
    @track sortColumn = '';
    @track sortDirection = 'asc';
    @track searchTerm = '';
    @api isFileExists = false;
    @api isFileUploaded = false;
    @api ItemsToUpdate = [];
    @track wiredDocuments = [];
    @track showResponseMessage = false;
    @track isUpload = false;
    @api showProgressBarModal = false;
    progressBarModalError = '';
    // html disply control values
    showLoadingMessage = false;
    @track selectedValue = '';
    @track fileTarget;
    email;
    @track accountName;
    @track accName;
    @track inputField;
    @track nickName;
    @track createdSiteUrl;
    @track actionplantask;
    @track apyear;
    @track period;
    @track tasknumber;
    @track TaskPayrollURL;
    @track TaskAccountId;
    systemOrigin = "salesforce";
    @track new;
    clientId;
    clientSecret;
    devEndpoint;
    // SharePoint auth subscription
    subscription;
    refreshSubscription;
    @track selectedValue;

    @track options = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
    ];
    task;
    tasknumber;
    period;
    actionPlanTask;

    @track fileName;
    @track fileExtension;
    @track searchTerm = '';
    @track sortIcon = {
        FileLeafRef: {
            icon: 'utility:chevrondown',
            text: 'chevrondown'
        },
        Modified: {
            icon: 'utility:chevrondown',
            text: 'chevrondown'
        },
        Author: {
            icon: 'utility:chevrondown',
            text: 'chevrondown'
        }
    }

    /*Method to check user permissions*/
    @wire(isTaskWidgetAccessible, { taskId: '$recordId', requestedForPayroll: true })
    isWidgetAccessible({ error, data }) {
        if (error) {
            console.error(error);
        }
        else {
            if (data != undefined) {
                this.isWidgetAccessibleResponse = data;
                console.log('isWidgetAccessibleResponse: ', this.isWidgetAccessibleResponse);
            }
        }
    }
    /*Method to get custom settings values*/
    @wire(getCustomSettings)
    wiredCustomSettings({ error, data }) {
        if (data) {
            this.clientId = data.ClientId__c;
            this.clientSecret = data.ClientSecretKey__c
            this.devEndpoint = data.DevAPIEndPoint__c;
        } else if (error) {
        }
    }

    @wire(getTasksWithCustomFields, { taskId: '$recordId' })
    wiredgetTasksWithCustomFields({ error, data }) {
        if (data) {
            console.log('Custom Fields', data);
            if (data.length > 0) {
                this.email = data[0].Owner.Email;
                this.createdsiteurl = data[0].Account__r.SiteURL__c;
                this.nickname = data[0].Account__r.MailNickName__c;
                this.accname = data[0].Account__r.Name;
                this.TaskPayrollURL = data[0].Account__r.Payroll_Channel_URL__c;
                this.TaskAccountId = data[0].Account__r.Id;
                console.log('Task acount ID for Payroll',this.TaskAccountId);
                console.log('^^^TaskPayrollURL',this.TaskPayrollURL);
                if(typeof this.TaskPayrollURL == "undefined"||this.TaskPayrollURL == null||this.TaskPayrollURL == '')
                 {
                this.TaskPayrollURL = '-PayrollSharedChannel';
                console.log('MAIN CHECK 2',this.TaskPayrollURL);
                 }
                if(data[0].hasOwnProperty("AP_Task__r")){
                this.actionplantask = data[0].AP_Task__r.Subject__c;
                }
                if(typeof data[0].Action_Plan__c !== "undefined"){
                    var tempapyear = data[0].Action_Plan__c;
                    if(tempapyear.indexOf('20') > 0){
                        tempapyear = tempapyear.substring(tempapyear.indexOf('20'),tempapyear.indexOf('</'));
                        this.apyear = tempapyear;
                        }
                    if(tempapyear.indexOf('20') < 0){
                            tempapyear = tempapyear.substring(tempapyear.indexOf('>')+1,tempapyear.indexOf('</'));
                            this.apyear = tempapyear;  
                        }
                }
                if(typeof data[0].Period__c !== "undefined"){
                this.period = data[0].Period__c;
                this.periodString = this.period.toString();
                }
                if(typeof data[0].Task_Number__c !== "undefined"){
                this.tasknumber = data[0].Task_Number__c;
                this.taskNumberString = this.tasknumber.toString();
                }

            }

        } else if (error) {
        }
    }

    /*Method to get all documents lists from sharepoint*/
    @wire(getAllFileDocuments, { recordId: '$TaskAccountId', channelname: '$TaskPayrollURL',TaskNumber:'$taskNumberString', QueryText: '$searchTerm', SortingField: '$sortColumn', SortingDirection: '$sortDirection' })
    wiredDocuments(result) {
       console.log('Result for Task -->',result);
        this.isLoading = true;
        this.wiredDocuments = result;
       
        console.log('im in wire doc  for TASK');
       
        console.log('Result Data for Task -->',result.data);
        if (result.data) {
            // icons logic will go here
            var arr = ['docx', 'pdf', 'xlsx', 'pptx', 'folder', 'txt'];
            var arrxl = ['xlsx', 'xls', 'xlsm'];
            var imgarr = ['jpg', 'png', 'jpeg', 'svg'];

            this.documents = result.data.map((doc) => {
                doc = { ...doc, docIcon: doc.docIcon ? doc.docIcon : "" };
                if (imgarr.indexOf(doc.docIcon.toLowerCase()) > -1) {
                    return { ...doc, docIcon: 'https://spoprod-a.akamaihd.net/files/fabric/assets/item-types-fluent/20/photo.svg' };
                }
                else if (arrxl.indexOf(doc.docIcon.toLowerCase()) > -1) {
                    return { ...doc, docIcon: 'https://spoprod-a.akamaihd.net/files/fabric/assets/item-types-fluent/20/xlsx.svg' };
                }
                else if (!(arr.indexOf(doc.docIcon.toLowerCase()) > -1)) {
                    return { ...doc, docIcon: 'https://spoprod-a.akamaihd.net/files/fabric/assets/item-types-fluent/20/code.svg' };
                } else {
                    return { ...doc, docIcon: 'https://spoprod-a.akamaihd.net/files/fabric/assets/item-types-fluent/20/' + doc.docIcon + '.svg' };
                }
            })
            this.isLoading = false;
        } else if (result.error) {
            console.error(result.error);
        }
    } 

    connectedCallback() {
        this.showLoadingMessage = true;
        if(this.Type === 'Details'){
            console.log('I AM IN DETAILS TAB SECTION');
            this.tabsection = true;
       } else if (this.Type === 'Related'){
        console.log('I AM IN RELATED TAB SECTION');
        this.tabsection = false;
    }

    }
     //Sorting of columns
     handleSort(event) {
        const col = event.currentTarget.dataset.col;
        if (this.sortColumn === col) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortColumn = col;
            this.sortDirection = 'asc';
        }
        refreshApex(this.wiredDocuments);
        this.updateSortingArrowIcons();
    }

    //Switch sorting arrow to up/down
    updateSortingArrowIcons() {
        let isAscOrder = (this.sortDirection === 'asc');
        this.sortIcon[this.sortColumn].icon = isAscOrder ? this.iconName = 'utility:chevrondown' : this.iconName = 'utility:chevronup';
        this.sortIcon[this.sortColumn].text = isAscOrder ? 'chevrondown' : 'chevronup';
    }

    //Search from the documents
    handleSearch(event) {
        console.log('I am In handle Search');
            const inputValue = event.target.value;
            console.log('Input Value-||-->',inputValue );
            console.log('keycode-->',event.keyCode  );

            if (event.keyCode === 13 ) {
                // Enter key pressed
                this.searchTerm = inputValue;
               console.log('Serch term |||-->',this.searchTerm );
                if (this.searchTerm.length > 0 && this.searchTerm.length < 3) {
                    this.showErrorMsg = true;
                    this.errorMsg = 'Please enter at least 3 characters';
                } else {
                    this.showErrorMsg = false;
                    this.errorMsg = '';
                }
            }
    }
    handleViewAll() {
        window.open(this.createdsiteurl + this.TaskPayrollURL+'/Shared Documents', '_blank');
    }
    

    payroll_handleCachedFile() {
        if (this.payrollfiles) {
            this.fileData = new FormData();
            this.fileData.append('file', this.payrollfiles);
            this.showFilePropertiesModalpayroll = true;
            this.showSpinner = false;
        }

    }

    //File handler after selecting docuemnt from local system
    payroll_selectFile(event) {
        // Regular expression to check for invalid characters in the file name
        var format = /["*:<>/|\\]/;
        // Clear existing files array and set uploaded files count to 0
        this.payrollfiles = [];
        this.uploadedFiles = 0;
        // Iterate through each file in the selected files array
        for (var file of event.target.files) {
            // Check if the file name contains any invalid characters
            if (format.test(file.name)) {
            }
            else {
                this.payrollfiles.push(file);
            }
        }
        // Clear selected files array and populate with file name, extension and ID for each selected file
        this.selectedFiles = [];
        for (let i = 0; i < this.payrollfiles.length; i++) {
            const fileName = this.payrollfiles[i].name.substring(0, this.payrollfiles[i].name.lastIndexOf("."));
            const fileExtension = this.payrollfiles[i].name.split('.').pop();
            this.selectedFiles.push({
                id: i,
                name: fileName,
                extension: fileExtension
            });
        }
        // Call function to handle cached file
        this.payroll_handleCachedFile();
        // Clear the file input field value
        var inputField = this.template.querySelectorAll('input');
        inputField.forEach(element => {
            element.value = "";
        });


    }

    payroll_dragOverHandler(event) {
        event.preventDefault();
    }

    payroll_dropHandler(event) { 
        event.preventDefault();
        console.log('Im in on dropHandler');
      /*  if (event.dataTransfer.files) {
            this.files = event.dataTransfer.files;
        }*/
        var format = /["*:<>/|\\]/;
        // Clear existing files array and set uploaded files count to 0
        this.payrollfiles = [];
        this.uploadedFiles = 0;
        // Iterate through each file in the selected files array
        for (var file of event.dataTransfer.files) {
            // Check if the file name contains any invalid characters
            if (format.test(file.name)) {
            }
            else {
                this.payrollfiles.push(file);
            }
        }

        // Clear selected files array and populate with file name, extension and ID for each selected file
        this.selectedFiles = [];
        for (let i = 0; i < this.payrollfiles.length; i++) {
            const fileName = this.payrollfiles[i].name.substring(0, this.payrollfiles[i].name.lastIndexOf("."));
            const fileExtension = this.payrollfiles[i].name.split('.').pop();
            this.selectedFiles.push({
                id: i,
                name: fileName,
                extension: fileExtension
            });
        }

        // Call function to handle cached file
        this.payroll_handleCachedFile();

        // Clear the file input field value
        var inputField = this.template.querySelectorAll('input');
        inputField.forEach(element => {
            element.value = "";
        });
    this.handleCreateLWCRecord();
}
    //select Personal data field value
    handlePersonalDataChange(event) {
        this.personalDataValue = event.target.value;
    }
    // This function handles file upload to SharePoint
    async payroll_handleFileUploadToSharePoint(event) {
        // Check if a required field is selected
        if (!this.selectedValue) {
            this.displayError = true;
            this.errorMessage = 'Please select a value for Personal Data.';
            return;
        }

        // Hide the overwrite modal if it is currently displayed
        this.showOverWriteModalpayroll = false;

        // Check if the file already exists in SharePoint
        let overwriteFiles = ((event.target.dataset.overwritefiles ?? '') == 'true');
        let isFileExist = false;
        if (overwriteFiles == false) {
            isFileExist = await this.payroll_CheckifFileExistsinSPO();
        }

        // Display the overwrite modal if the file exists and overwriting is not allowed
        if (overwriteFiles == false && isFileExist) {
            this.showFilePropertiesModalpayroll = false;
            this.showOverWriteModalpayroll = true;
            //this.selectedValue = null;
            return;
        }
        // Reset any error messages and show the progress bar modal
        this.showSpinner = false;
        this.errorMessage = '';
        this.displayError = false;
        this.showFilePropertiesModalpayroll = false;
        this.showProgressBarModal = true;
        this.filePropertiesModalEM = '';
        this.progressBarModalError = this.fileUploadInProgressEM;
        // Subscribe to the SharePoint token channel and publish a token request
        this.payroll_subscribeToSharepointTokenChannel();
        this.payroll_publishSharePointTokenRequest();

    }
    //Token generation
    @wire(MessageContext)
    messageContext;
    payroll_subscribeToSharepointTokenChannel() {
        if (!this.subscription) {

            this.subscription = subscribe(
                this.messageContext,
                SharePointToken,
                async (message) => await this.payroll_handleSharePointTokenReceived(message)

            );
        }

    }

    payroll_publishSharePointTokenRequest() {
        publish(this.messageContext, requestSharePointToken, { token: this.token });

    }
    // Checks if the selected file already exists in SharePoint
    async payroll_CheckifFileExistsinSPO() {
        this.isCheckingFileExists = true;
        this.showFilePropertiesModalpayroll = false;
        let tempFileNames = [];
        let isFileExists = false;
        for (let file of this.payrollfiles) {
            // Check if the file has been renamed
            let renamedFile = this.renamedfiles.find(i => i.oldname == file.name);
            let fileNameToUse = renamedFile ? renamedFile.newname : file.name;
            tempFileNames.push(fileNameToUse);
        }
        // Clear existing files array
        let _this = this;
        this.existingFiles = [];
        // Call the server to check for existing files
        await checkforExistingMultipleFilesTask({ recordId: this.recordId, fileNames: JSON.stringify(tempFileNames), channelname: this.TaskPayrollURL })
            .then(result => {
                var parsedResult = JSON.parse(result);
                if (parsedResult.response) {
                    parsedResult.response.forEach((file) => {
                        if (file.isExists) {
                            // Add the existing file to the existing files array
                            _this.existingFiles.push({ "name": file.fileName, "isExist": file.isExists });
                        }
                        isFileExists = isFileExists || file.isExists;
                    });
                    if (!isFileExists) {
                        this.showFilePropertiesModalpayroll = false;
                    }

                }

            }).catch(error => console.error(error));
        // Reset flag and show the file properties modal
        this.isCheckingFileExists = false;
        this.showFilePropertiesModalpayroll = true;

        return isFileExists;
    }
    //Token Received
    async payroll_handleSharePointTokenReceived(message) {
        if (message.token && message.token != "Error") {
            this.token = 'Bearer ' + message.token;
            let promises = [];
            this.payrollfiles.map((file) => {
                let filePromise = new Promise(resolve => {
                    let fileReader = new FileReader();
                    fileReader.readAsArrayBuffer(file);
                    fileReader.onloadend = () => {
                        let fileContent = fileReader.result;
                        resolve({ name: file.name, content: fileContent });
                    };
                });
                promises.push(filePromise);
            })
            this.ItemsToUpdate = [];
            this.newUploadedFileUrl = '';
            this.uploadedFileNames = [];
            await Promise.all(promises).then(async (fileContents) => {
                for (let fileContent of fileContents) {
                    let renamedFile = this.renamedfiles.find(i => i.oldname == fileContent.name);
                    let fileNameToUse = renamedFile ? renamedFile.newname : fileContent.name;
                    await this.payroll_handleUploadWithRESTAPI(this.token, fileNameToUse, fileContent.content);

                }

            });
            this.showProgressBarModal = false;
            if (this.showErrorMessage != true) {
                this.showResponseMessage = true;
            }
            this.selectedValue = '';
            await uploadFile({ recordId: this.recordId, widgetName: 'Payroll' })
                .then((r) => {
                    console.log('File Upload Response on checkbox', r);
                        this.updateRecordView();
                })
                .catch(error => {
                    console.error(error);
                });
        }

        if (message.token == "Error") {
            this.showErrorMessage = true;
            this.errorMessage = "Authentication Failed or User Cancelled Authentication Request or a pop-up window was blocked.";
            this.showProgressBarModal = false;
            this.showSpinner = false;
        }
    }
    //This function is used to upload a file to SharePoint Online using REST API with a given token, file name, and file contents.
    async payroll_handleUploadWithRESTAPI(token, file, fileContents) {

        var updatedFileName = encodeURIComponent(file);
        updatedFileName = updatedFileName.replace(/'/g, "''");
        this.url1 = this.createdsiteurl + this.TaskPayrollURL+"/_api/web/GetFolderByServerRelativePath(decodedurl='/sites/" + this.nickname + this.TaskPayrollURL+"/Shared Documents')/Files/AddUsingPath(overwrite=true,decodedurl='" + updatedFileName + "')";
        // Obtain a context info request to get the digest value
        const siteUrlnew = this.createdsiteurl + '/_api/contextinfo';
        let _this = this;
        try {

            await fetch(siteUrlnew, {
                method: "POST",
                processData: false,
                mode: 'cors',
                contentType: false,
                headers: {
                    'Content-Type': 'application/json;odata=verbose',
                    'Accept': 'application/json',
                    "Authorization": token,
                    'Access-Control-Allow-Origin': '*',
                    'Cache-Control': 'no-cache',
                    'pragma': 'no-cache',
                    'credentials': 'include',
                },
            }).then((r) => { console.log('digest res', r); return r.json() })
                .then((digestValue) => {
                    if (digestValue["odata.error"]) {
                        throw 'Error while getting Digest Value. ' + digestValue["odata.error"].message.value + ' Please try again.';
                    }
                    // Use the digest value in the header of the file upload request
                    return fetch(this.url1, {
                        method: "POST",
                        headers: {
                            "X-RequestDigest": digestValue.FormDigestValue,
                            'Accept': 'application/json; odata=verbose',
                            "content-length": fileContents.byteLength,
                            "content-type": "application/json;odata=verbose",
                            "Authorization": token
                        },
                        body: fileContents,
                    })
                        .then(async (attchResult) => {
                            if (!attchResult.ok) {
                                throw 'Error while uploading file. Please try again.';
                            }
                            let attchResultJson = await attchResult.json();
                            console.log('Attach Result', attchResultJson);
                            // set open link
                            if (_this.payrollfiles.length == 1) {
                                _this.newUploadedFileUrl = 'https://' + new URL(this.createdsiteurl).
                                    hostname + attchResultJson.d.ServerRelativeUrl;
                                console.log('Open url', _this.newUploadedFileUrl);
                            }
                            else if (_this.payrollfiles.length > 1) {
                                _this.uploadedFileNames.push(file);
                            }
                            // Obtain the document ID by making a separate request to SharePoint
                            return this.payroll_GetDocumentIDByServerUrl(token, file)
                                .then(itm => {
                                    if (itm["odata.error"]) {
                                        throw 'Error in GetDocumentIDByServerUrl. ' + itm["odata.error"].message.value + ' Please try again.';
                                    }

                                    let metadataBody = {
                                        Title: file,
                                        System_Origin: "salesforce",
                                        Personal_Data: this.selectedValue,
                                        Account_Name: this.accname,
                                    }
                                    if (this.actionplantask)
                                        metadataBody.Action_Plan_Task = this.actionplantask;
                                    if (this.taskNumberString)
                                        metadataBody.Task_Number = this.taskNumberString;
                                    if (this.periodString)
                                        metadataBody.Period = this.periodString;
                                    if (this.apyear)
                                        metadataBody.AP_x0020_Year = this.apyear;

                                    return this.payroll_updateFileMetaData(itm.Id,
                                        metadataBody
                                        , digestValue.FormDigestValue, token)
                                        .then(f => {
                                            console.log('updated then', f);
                                            if (!f.ok) {
                                                throw 'File did not complete successfully. Setting file properties failed. Please try again.';
                                            }
                                            _this.uploadedFiles = _this.uploadedFiles + 1;
                                            _this.payroll_updateProgressBar();

                                        }).catch((error) => {
                                            console.log('Error in metadata', error);
                                            _this.errorMessage = "Something went wrong while updating metadata!";
                                            _this.showErrorMessage = true;
                                            _this.showProgressBarModal = false;

                                        });
                                    ////UpdateMetadata call ends
                                }).catch((error) => {
                                    console.log('Error in GetDocumentIDByServerUrl', error);
                                    _this.errorMessage = "Something went wrong while getting uploaded document ID!";
                                    _this.showErrorMessage = true;
                                    _this.showProgressBarModal = false;

                                });
                        }).catch((error) => {
                            _this.errorMessage = "Error in File Upload.";
                            _this.showErrorMessage = true;
                            _this.showProgressBarModal = false;
                        });
                }).catch((error) => {
                    this.errorMessage = "Error while getting digest value.";
                    this.showErrorMessage = true;
                    this.showProgressBarModal = false;
                });
        } catch (error) {
            this.showSpinner = false;
            this.isFileUploaded = false;
        }
    }

    //Retrieves the ID of a document in SharePoint Online using its server-relative URL.
    payroll_GetDocumentIDByServerUrl(token, file) {

        var updatedFileName = encodeURIComponent(file);
        updatedFileName = updatedFileName.replace(/'/g, "''");
        //console.log('updatedFileName', updatedFileName);
        var reqUrl = this.createdsiteurl + this.TaskPayrollURL+'/_api/web/GetFileByServerRelativePath(decodedurl=\'/sites/' + this.nickname + this.TaskPayrollURL+'/Shared Documents/' + updatedFileName + '\')/ListItemAllFields';
        // Send a GET request to retrieve the document data.
        return fetch(reqUrl,
            {
                method: "GET",
                headers:
                {
                    "Authorization": token,
                    "accept": "application/json;odata=nometadata"
                }
            }).then(response => response.json())
            .then((data) => {
                return data;
            }).catch(error => {
                // Reject with an error message.
                this.showSpinner = false;
                this.isFileExists = false;
                this.isFileUploaded = false;
                this.displayError = true;
                this.showFilePropertiesModalpayroll = true;
                this.showDocumentPropertiesForm = true;
                this.errorMessage = 'Error in GetDocumentIDByServerUrl.';
                this.showErrorMessage = true;
                this.showProgressBarModal = false;
            });
    };

    payroll_updateFileMetaData(ItemId, metaData, digest, token) {
        console.log('Updated Metadata Lists-->', metaData);
        if (ItemId == undefined) {
            console.log('Item ID is undefined while updating metadata');
            return;
        }
        return fetch(this.createdsiteurl + this.TaskPayrollURL+'/_api/web/Lists/GetByTitle(\'Documents\')/items(' + ItemId + ')',
            {
                method: "POST", headers:
                {
                    accept: "application/json;odata=nometadata", "Authorization": token,
                    "Content-Type": "application/json;odata=nometadata", "X-RequestDigest": digest, "IF-MATCH": "*",
                    "X-HTTP-Method": "MERGE"

                }
                , body: JSON.stringify(metaData)
            });
    }


    //Update ProgressBar Model Function w.r.t files length
    payroll_updateProgressBar() {

        let width = ((this.uploadedFiles / this.payrollfiles.length) * 100);
        width = Math.round(width);
        let progressBar = this.template.querySelector('[data-id="payroll_ProgressBar"]');
        let progressBarText = this.template.querySelector('[data-id="payroll_ProgressBarText"]');
        progressBar.style.width = width + "%";
        progressBarText.innerHTML = this.uploadedFiles + "/" + this.payrollfiles.length + " File(s) Uploaded";
    }
    //close success response model
    payroll_CloseResponseMessage() {
        this.showResponseMessage = false;
        this.newUploadedFileUrl = '';
        this.uploadedFileNames = [];
        this.selectedValue='';


    }

    //Referesh field automatically from LWC when clicked on 'ok' from upolad modal.
    updateRecordView() {

        setTimeout(() => {

            eval("$A.get('e.force:refreshView').fire();");

        }, 1000);

    }
    //close error model
    payroll_CloseErrorMessage() {
        this.showErrorMessage = false;
        this.errorMessage = '';
        this.selectedValue='';

    }
    //Close ProgressBar Model
    payroll_closeProgressBarModal() {

        this.showProgressBarModal = false;

    }
    //Close overwrite model
    payroll_handleCloseOverwriteModal() {
        this.showOverWriteModalpayroll = false;
        this.showFilePropertiesModalpayroll = true;

    }

    //Check file exists function
    //open document properties model
    handleFilesPropertiesModal() {
        this.showFilePropertiesModalpayroll = true;
        this.showSpinner = false;
    }
    // This method is triggered when a file name is changed by the user in the UI
    payroll_handleFileNameChange(event) {
        let oldname = event.target.dataset.oldname;
        let ext = event.target.dataset.ext;
        // Check if the renamed file already exists in the renamedfiles array
        let isExists = this.renamedfiles.find(i => i.oldname == oldname + "." + ext);
        // If the renamed file already exists, update its new name in the renamedfiles array
        if (isExists) {
            this.renamedfiles = this.renamedfiles.map((item) => {
                if (item.oldname == oldname + "." + ext) {
                    return { ...item, newname: event.target.value + "." + ext };
                }
                return item;
            });
        }
        // If the renamed file does not exist, add it to the renamedfiles array
        else {
            this.renamedfiles.push({ oldname: oldname + "." + ext, newname: event.target.value + "." + ext });
        }


    }
    payroll_handleChange(event) {
        this.selectedValue = event.target.value;
        this.displayError = false;
        this.errorMessage = '';

        console.log('selected value', this.selectedValue);

    }
    handleFileTypeSelectionChange(event) {
        this.selectedDocTypeFieldAPIName = event.detail.value;
        this.selectedDocTypeLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
    }

    //close modal bclicking Close/Cancel
    handleCloseModal() {
        this.showFilePropertiesModalpayroll = false;
        this.token = '';
        this.payrollfiles = undefined;
        this.isFileUploaded = false;
        this.authenticationError = "";
        this.displayError = false;
        this.errorMessage = '';
        this.selectedValue ='';
    }

    handleUnsubscribe() {
        if (this.refreshSubscription) {
            empUnSub(this.refreshSubscription, response => {
            });
            this.refreshSubscription = null;
        }
    }

    handleCreateLWCRecord()
    {
       console.log('Task Acc Id payroll-> ',this.TaskAccountId);
       console.log('Current user id payroll->',this.userId);
        CreateLWCRecord({LWCName:'Payroll Upload From Task' ,recordId: this.TaskAccountId,UserId:this.userId })
        .then(result => {
            console.log('NEW Result: ' + result);
        })
        .catch(error => {
            console.log('NEW Error: ' + error);
        });
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    handleQuickrefresh(){
        refreshApex(this.wiredDocuments);
    }
}