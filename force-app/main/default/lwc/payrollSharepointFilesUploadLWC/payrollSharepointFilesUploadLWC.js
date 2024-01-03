import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue, getRecordNotifyChange, updateRecord } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import { subscribe as empSub, unsubscribe as empUnSub } from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex';
//Account Fields import
import Accountobj from '@salesforce/schema/Account';
import MailNickName from '@salesforce/schema/Account.MailNickName__c';
import SiteURL from '@salesforce/schema/Account.SiteURL__c';
import AccountName from '@salesforce/schema/Account.Name';
import PayrollSharedChannelURL from '@salesforce/schema/Account.Payroll_Channel_URL__c';
const fields = [MailNickName, SiteURL, AccountName];

// Task fields
import TASK_OBJECT from '@salesforce/schema/Task';
//Controller import
import getTermStore from '@salesforce/apex/sharepointFileUploadController.getTermStore';
import checkforExistingMultipleFiles from '@salesforce/apex/sharepointFileUploadController.checkforExistingMultipleFiles';
import getAllFileDocuments from '@salesforce/apex/sharepointFileUploadController.getAllFileDocuments';
import getCustomSettings from '@salesforce/apex/sharepointFileUploadController.getCustomSettings';
import isWidgetAccessible from '@salesforce/apex/sharepointFileUploadController.isWidgetAccessible';
import CreateLWCRecord from '@salesforce/apex/sharepointFileUploadController.CreateLWCRecord';

// LMS import 
import SharePointToken from '@salesforce/messageChannel/payrollsharepointToken__c';
import requestSharePointToken from '@salesforce/messageChannel/payrollrequestSharepointToken__c';
// User fields
import Author_Field from '@salesforce/schema/User.Email';
import USER_ID from '@salesforce/user/Id';

export default class sharepointFileUploadController extends LightningElement {

    userId = USER_ID;
    @track isWidgetAccessibleResponse = {
        showWidget: '',
        message: ''
    };
    @api recordId;
    @track isWidgetActive = -1;
    selectedFiles = [];
    @track isConfirmDialogVisible = false;
    @track displayError = false;
    @track displayDocError = false;
    @track errorMessage = '';
    @track showErrorMessage = false;
    @track errorWhileGettingFiles = false;
    @api objectApiName = Accountobj;
    @api showFilePropertiesModalpayroll = false;
    @api isCheckingFileExists = false;
    @api showOverWriteModalpayroll = false;
    @track selectedDocTypeFieldAPIName = '';
    @track selectedDocTypeLabel = '';
    @track options;
    @track showSpinner = false;
    showNoDocuments = false;
    showIsUploading = false;
    @api documentDetail = false;
    token = '';
    @track url1;
    @track newUploadedFileUrl = '';
    @track progressBarModalError = '';
    @track authenticationEM = 'Authentication Failed or User Cancelled Authentication Request or a pop-up window was blocked.';
    @track fileUploadInProgressEM = 'File upload is in progress. Please wait.';
    uploadedFiles = 0; // Used to display upload count on progress bar

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

    @api isFileExists = false;
    @api isFileUploaded = false;
    @api ItemsToUpdate = [];
    @track wiredDocuments = [];
    @track showResponseMessage = false;
    @track isUpload = false;
    @track selectedDocClass = [];
    @api showProgressBarModal = false;
    progressBarModalError = '';

    // html disply control values
    showLoadingMessage = false;
    @track selectedValue = '';
    @track fileTarget;
    email;
    @track searchTerm = '';
    @track enterKeyPressed = false;
    @track showErrorMsg = false;

    @track accountName;
    @track accName;
    @track inputField;

    @track nickName;
    @track createdSiteUrl;
    actiontask;
    @track PayrolllSharedChannelURL;
    systemOrigin = "salesforce";
    @track new;
    clientId;
    clientSecret;
    devEndpoint;
    existingFileTimestamp;

    // SharePoint auth subscription
    subscription;
    refreshSubscription;
    @track options = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
    ];
    @track Picklist_Value;
    @track Picklist_Key;
    //@track picklistValues;
    @track TypeOptions;
    task;
    tasknumber;
    period;
    actionPlanTask;

    @track fileName;
    @track fileExtension;

    @track isLoading = true;

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
    /*Wire method to get field values*/
    @wire(getRecord, { recordId: '$recordId', fields })
    account;

    get nickname() {
        return getFieldValue(this.account.data, MailNickName);

    }

    get createdsiteurl() {
        return getFieldValue(this.account.data, SiteURL);

    }

    get accname() {
        return getFieldValue(this.account.data, AccountName);
    }

    get acceptedFormats() { return ['.xlsx, .xls, .csv, .png, .doc, .docx, .pdf, .zip, .psd, .bin, .txt']; }
    //wire Method for Picklist
    /*wire Method for Document Classification values*/
    @wire(getTermStore, { termsID: 'b96aecbd-3eae-4435-97f7-86aa793686f8' })
    // @wire(getTermStore, { termsID: this.guidvalue })
    wiredPicklistValues({ error, data }) {
        if (data) {
            try {
                // this.picklistValues = data; 
                let options = [];

                for (var key in data) {
                    options.push({ label: data[key].name, value: data[key].value, selected: false });

                }
                this.TypeOptions = options;

            } catch (error) {
            }
        } else if (error) {
        }

    }
    /*Method to get all documents lists from sharepoint*/
    @wire(getAllFileDocuments, { recordId: '$recordId', channelname: '$PayrolllSharedChannelURL', QueryText: '$searchTerm',SortingField: '$sortColumn', SortingDirection: '$sortDirection'})
     wiredDocuments(result) {
        this.isLoading = true;
        this.wiredDocuments = result;
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
        }
    }

    /*Method to check user permissions*/
    @wire(isWidgetAccessible, { accountId: '$recordId', requestedForPayroll: true })
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
            this.clientId = data.Salesforce_ClientId__c;
            this.clientSecret = data.Salesforce_ClientSecret__c;
            this.devEndpoint = data.DevAPIEndPoint__c;
        } else if (error) {
        }
    }

    connectedCallback() {
        this.showLoadingMessage = true;

    }

    /*Method to get user fields value*/
    @wire(getRecord, { recordId: USER_ID, fields: [Author_Field] })
    wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.email = getFieldValue(data, Author_Field);
            
        }
    }

    @wire(getRecord, { recordId:'$recordId' , fields: [PayrollSharedChannelURL] })
    wireaccount({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.PayrolllSharedChannelURL=getFieldValue(data, PayrollSharedChannelURL);
            console.log('**PAYROLL SP -->'+this.PayrolllSharedChannelURL);
            if(typeof this.PayrolllSharedChannelURL == "undefined"||this.PayrolllSharedChannelURL == null||this.PayrolllSharedChannelURL == '')
            {
                this.PayrolllSharedChannelURL = '-PayrollSharedChannel';
                console.log('check payroll-> ',this.PayrolllSharedChannelURL);
            }
        }
    }

    //Switch sorting arrow to up/down
    updateSortingArrowIcons() {
        let isAscOrder = (this.sortDirection === 'asc');
        this.sortIcon[this.sortColumn].icon = isAscOrder ? this.iconName = 'utility:chevrondown' : this.iconName = 'utility:chevronup';
        this.sortIcon[this.sortColumn].text = isAscOrder ? 'chevrondown' : 'chevronup';
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


    //Token Received
    async payroll_handleSharePointTokenReceived(message) {
        console.log('Payroll message', message);
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
            // let _this = this;
            await Promise.all(promises).then(async (fileContents) => {
                for (let fileContent of fileContents) {
                    let renamedFile = this.renamedfiles.find(i => i.oldname == fileContent.name);
                    let fileNameToUse = renamedFile ? renamedFile.newname : fileContent.name;
                    await this.payroll_handleUploadWithRESTAPI(this.token, fileNameToUse, fileContent.content);
                    this.uploadedFiles = this.uploadedFiles + 1;
                    this.payroll_updateProgressBar();
                }

            });
            await this.payroll_updateFileMetaData();
            this.selectedValue = '';
        }

        if (message.token == "Error") {
            this.showErrorMessage = true;
            this.errorMessage = "Authentication Failed or User Cancelled Authentication Request or a pop-up window was blocked.";
            this.showProgressBarModal = false;
            this.showSpinner = false;
        }
    }

    handleFileTypeSelectionChange(event) {
        this.selectedDocTypeFieldAPIName = event.detail.value;
        this.selectedDocTypeLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
    }

    //open document properties model
    handleFilesPropertiesModal() {
        this.showFilePropertiesModalpayroll = true;
        this.showSpinner = false;
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
        this.selectedValue = '';
        this.selectedDocClass = [];
        this.TypeOptions = this.TypeOptions.map(option => {
            return {
              ...option,
              selected: false
            }
          });
    }
    //close success response model
    payroll_CloseResponseMessage() {
        this.showResponseMessage = false;
        this.newUploadedFileUrl = '';
        this.selectedValue = '';
        refreshApex(this.wiredDocuments);

    }
    //close error model
    payroll_CloseErrorMessage() {
        this.showErrorMessage = false;
        this.errorMessage = '';
        this.selectedValue = '';

    }
    //Close ProgressBar Model
    payroll_closeProgressBarModal() {

        this.showProgressBarModal = false;

    }
    //Update ProgressBar Model Function w.r.t files length
    payroll_updateProgressBar() {
        console.log("uploadedFiles: ", this.uploadedFiles);
        let width = ((this.uploadedFiles / this.payrollfiles.length) * 100);
        width = Math.round(width);
        let progressBar = this.template.querySelector('[data-id="payroll_ProgressBar"]');
        let progressBarText = this.template.querySelector('[data-id="payroll_ProgressBarText"]');
        progressBar.style.width = width + "%";
        progressBarText.innerHTML = this.uploadedFiles + "/" + this.payrollfiles.length + " File(s) Uploaded";
    }

    //Close overwrite model
    payroll_handleCloseOverwriteModal() {
        this.showOverWriteModalpayroll = false;
        console.log('Selected Doc Class', JSON.stringify(this.selectedDocClass));
        let tempOptions = this.TypeOptions.map((option) => {
            console.log('option', JSON.stringify(option));
            return { ...option, selected: this.selectedDocClass.indexOf(option.value.replaceAll(';', '')) > -1 }

        });
        console.log('tempOptions', tempOptions);
        this.TypeOptions = tempOptions;

        this.showFilePropertiesModalpayroll = true;
    }

    //open uploaded documents in new tab as sharepoint site onclick of viewAll
    handleViewAll() {
        window.open(this.createdsiteurl + this.PayrolllSharedChannelURL+'/Shared Documents', '_blank');
    }

    //select document properties model
    payroll_handleTypeChange(event) {

        const selectedOptions = event.target.selectedOptions;
        this.selectedDocClass = [];
        for (let i = 0; i < selectedOptions.length; i++) {
            const value = selectedOptions[i].value.replaceAll(';', '');
            if (!this.selectedDocClass.includes(value)) {
                this.selectedDocClass.push(value);
            }
            this.displayDocError = false;
            this.errorDocMessage = '';
        }
    }
    //select Personal data field value
    handlePersonalDataChange(event) {
        this.personalDataValue = event.target.value;
    }
    // This function handles file upload to SharePoint
    async payroll_handleFileUploadToSharePoint(event) {
        refreshApex(this.wiredDocuments);
        // Check if a required field is selected
        let isFormValid = true;
        if (this.selectedValue == '') {
            this.displayError = true;
            this.errorMessage = 'Please select a required field';
            isFormValid = false;
        }
        if (this.selectedDocClass.length == 0) {
            this.displayDocError = true;
            this.errorDocMessage = 'Please select a required field';
            isFormValid = false;
        }
        if (!isFormValid) {
            return;
        }

        // Hide the overwrite modal if it is currently displayed
        this.showOverWriteModalpayroll = false;
        // Check if the file already exists in SharePoint
        console.log('Check file exist payroll');
        let overwriteFiles = ((event.target.dataset.overwritefiles ?? '') == 'true');
        console.log('overwriteFiles  '+overwriteFiles);
        let isFileExist = false;
        if (overwriteFiles == false) {
            isFileExist = await this.payroll_CheckifFileExistsinSPO();
        }
        // Display the overwrite modal if the file exists and overwriting is not allowed
        if (overwriteFiles == false && isFileExist) {
            this.showFilePropertiesModalpayroll = false;
            this.showOverWriteModalpayroll = true;
            //  this.selectedValue = null;
            return;
        }
        // Reset any error messages and show the progress bar modal
        this.showSpinner = false;
        this.errorMessage = '';
        this.displayError = false;
        this.displayDocError = false;
        this.errorDocMessage = '';
        this.showFilePropertiesModalpayroll = false;
        this.showProgressBarModal = true;
        this.filePropertiesModalEM = '';
        this.progressBarModalError = this.fileUploadInProgressEM;

        // Subscribe to the SharePoint token channel and publish a token request
        this.payroll_subscribeToSharepointTokenChannel();
        this.payroll_publishSharePointTokenRequest();

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

    //Check file exists function
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
        await checkforExistingMultipleFiles({ recordId: this.recordId, fileNames: JSON.stringify(tempFileNames), channelname: this.PayrolllSharedChannelURL})
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

            }).catch(error =>{ this.errorMessage = error});
        // Reset flag and show the file properties modal
        this.isCheckingFileExists = false;
        this.showFilePropertiesModalpayroll = true;

        return isFileExists;
    }
    //This function is used to upload a file to SharePoint Online using REST API with a given token, file name, and file contents.
    async payroll_handleUploadWithRESTAPI(token, file, fileContents) {
        var updatedFileName = encodeURIComponent(file);
        updatedFileName = updatedFileName.replace(/'/g, "''");
        this.url1 = this.createdsiteurl +this.PayrolllSharedChannelURL+ "/_api/web/GetFolderByServerRelativePath(decodedurl='/sites/" + this.nickname + this.PayrolllSharedChannelURL+"/Shared Documents')/Files/AddUsingPath(overwrite=true,decodedurl='" + updatedFileName + "')";
        // Obtain a context info request to get the digest value
        const siteUrlnew = this.createdsiteurl + '/_api/contextinfo';
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
                        .then((attchResult) => {
                            if (!attchResult.ok) {
                                throw 'Error while uploading file. Please try again.';
                            }
                            // Obtain the document ID by making a separate request to SharePoint
                            return this.payroll_GetDocumentIDByServerUrl(token, file)
                                .then(itm => {
                                    if (itm["odata.error"]) {
                                        throw 'Error in GetDocumentIDByServerUrl. ' + itm["odata.error"].message.value + ' Please try again.';
                                    }
                                    // Add the document ID and file name to the ItemsToUpdate array
                                    this.ItemsToUpdate.push({
                                        fileId: itm.Id.toString(),
                                        fileName: file
                                    });

                                }).catch((error) => {
                                });
                        }).catch((error) => {
                            this.errorMessage = "Error in File Upload.";
                            this.showErrorMessage = true;
                            this.showProgressBarModal = false;
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
        var reqUrl = this.createdsiteurl + this.PayrolllSharedChannelURL+'/_api/web/GetFileByServerRelativePath(decodedurl=\'/sites/' + this.nickname + this.PayrolllSharedChannelURL+'/Shared Documents/' + updatedFileName + '\')/ListItemAllFields';
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
                console.log('ItemID', data);
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

    //This function updates the metadata of the selected files using the File/UpdateMetadata endpoint.
    async payroll_updateFileMetaData() {
        let updatedToken = this.clientId + this.clientSecret;
        console.log('authorization', updatedToken);
        // create array of metadata fields to update
        let metadatas = [
            {
                "fieldName": "System_Origin",
                "fieldValue": "salesforce"
            },
            {
                "fieldName": "Account_Name",
                "fieldValue": this.accname
            },
            {
                "fieldName": "Personal_Data",
                "fieldValue": this.selectedValue
            }
        ];
        // add selected document classification metadata fields to the array
        this.selectedDocClass.map(value => metadatas.push({
            "fieldName": "Document_Classification",
            "fieldValue": value
        }));
        // create JSON object with files, metadata, and other parameters
        let metaData = {
            "files": this.ItemsToUpdate,
            "metaDatas": metadatas,
            "spoWebUrl": this.createdsiteurl + this.PayrolllSharedChannelURL,
            "authorEmailId": this.email
        };
        console.log('metadata', metaData);
        let _this = this;
        // send POST request to File/UpdateMetadata endpoint
        await fetch(this.devEndpoint + 'api/File/UpdateMetadata', {
            method: "POST",
            headers: {
                "Authorization": updatedToken,
                'Content-Type': 'application/json;',
            },
            body: JSON.stringify(metaData)
        }).then(async (response) => {
            // parse response as JSON
            response = await response.json();
            console.log('metaupdate res:', response);
            if (response.data.fileUrl) {
                _this.newUploadedFileUrl = response.data.fileUrl;
                console.log('Open url', _this.newUploadedFileUrl);
            }
            if (response.message == 'The remote server returned an error: (429)') {
                _this.showErrorMessage = true;
                _this.errorMessage = 'The remote server returned an error: (429) ';
                _this.showResponseMessage = false;
                _this.showProgressBarModal = false;
            }
            // refresh wiredDocuments property
            await refreshApex(this.wiredDocuments);
            _this.showProgressBarModal = false;
            _this.uploadedFiles = 0;
            _this.showResponseMessage = true;
            _this.authenticationEM = false;

        }).catch((error) => {
            _this.errorMessage = "Something went wrong while updating metadata!";
            _this.showErrorMessage = true;
            _this.showResponseMessage = false;
            _this.showProgressBarModal = false;
            console.log('Error in metadata', error);
        });
    }



    handleSort(event) {
        const col = event.currentTarget.dataset.col;
        if (this.sortColumn === col) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortColumn = col;
            this.sortDirection = 'asc';
        }
        //refreshApex(this.wiredDocuments);
        this.updateSortingArrowIcons();
    }

    payroll_handleChange(event) {
        this.selectedValue = event.target.value;
        this.displayError = false;
        this.errorMessage = '';

    }

    handleUnsubscribe() {
        if (this.refreshSubscription) {
            empUnSub(this.refreshSubscription, response => {
            });
            this.refreshSubscription = null;
        }
    }
    handleQuickrefresh(){
        refreshApex(this.wiredDocuments);
    }  

    handleCreateLWCRecord()
    {
        
        CreateLWCRecord({LWCName:'Payroll Upload From Account' ,recordId: this.recordId,UserId:this.userId })
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

}