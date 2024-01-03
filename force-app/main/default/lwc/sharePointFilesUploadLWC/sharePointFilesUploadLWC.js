import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import { refreshApex } from '@salesforce/apex';
//Account Fields import
import Accountobj from '@salesforce/schema/Account';
import MailNickName from '@salesforce/schema/Account.MailNickName__c';
import SiteURL from '@salesforce/schema/Account.SiteURL__c';
import AccountName from '@salesforce/schema/Account.Name';
import AccountingSharedChannelURL from '@salesforce/schema/Account.Accounting_Channel_URL__c';
//Controller import
import getTermStore from '@salesforce/apex/sharepointFileUploadController.getTermStore';
import checkforExistingMultipleFiles from '@salesforce/apex/sharepointFileUploadController.checkforExistingMultipleFiles';
import getAllFileDocuments from '@salesforce/apex/sharepointFileUploadController.getAllFileDocuments';
import getCustomSettings from '@salesforce/apex/sharepointFileUploadController.getCustomSettings';
import isWidgetAccessible from '@salesforce/apex/sharepointFileUploadController.isWidgetAccessible';
import CreateLWCRecord from '@salesforce/apex/sharepointFileUploadController.CreateLWCRecord';

// LMS import 
import SharePointToken from '@salesforce/messageChannel/sharepointToken__c';
import requestSharePointToken from '@salesforce/messageChannel/requestSharepointToken__c';
// User fields
import Author_Field from '@salesforce/schema/User.Email';
import USER_ID from '@salesforce/user/Id';

const fields = [MailNickName, SiteURL, AccountName];

export default class sharepointFileUploadController extends LightningElement {
   userId = USER_ID;
    @api recordId;
    @track isWidgetAccessibleResponse = {
        showWidget: '',
        message: ''
    };
    selectedFiles = [];
    @track errorMessage = '';
    @track errorDocMessage = '';
    @track showErrorMessage = false;
    @api objectApiName = Accountobj;
    @api showFilePropertiesModal = false;
    @api isCheckingFileExists = false;
    @api showOverWriteModal = false;
    @track selectedDocTypeFieldAPIName = '';
    @track selectedDocTypeLabel = '';
    @track options;
    @track showSpinner = false;
    token = '';
    @track url1;
    @track newUploadedFileUrl = '';
    @track progressBarModalError = '';
    @track authenticationEM = 'Authentication Failed or User Cancelled Authentication Request or a pop-up window was blocked.';
    @track fileUploadInProgressEM = 'File upload is in progress. Please wait.';
    @track uploadedFiles = 0; // Used to display upload count on progress bar
    @track searchTerm= '';
    @track showErrorMsg = false;
    // file upload values
    fileData;
    @track file;
    @track fileContents;
    @track fileextension = '';
    @api files = [];
    @api renamedfiles = [];
    @track documents = [];
    @track sortColumn = '';
    @track sortDirection = 'asc';
    @track isLoading = true;
    @api isFileExists = false;
    @api isFileUploaded = false;
    @api ItemsToUpdate = [];
    @track wiredDocuments = [];
    @track showResponseMessage = false;
    @track isUpload = false;
    @track selectedDocClass = [];
    @api showProgressBarModal = false;
    @track displayError = false;
    @track displayDocError = false;
    progressBarModalError = '';
    showLoadingMessage = false;
    @track selectedValue = '';
    email;
    @track accountName;
    @track accName;
    @track inputField;
    @track nickName;
    @track createdSiteUrl;
    @track AccountSharedChannelURL;
    //@track PayrolllSharedChannelURL;
    systemOrigin = "salesforce";
    @track new;
    clientId;
    clientSecret;
    devEndpoint;
    subscription;
    refreshSubscription;
    @track options = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
    ];
    @track TypeOptions;
    @track fileName;
    @track fileExtension;
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

    /*wire Method for Document Classification values*/
    @wire(getTermStore, { termsID: 'b96aecbd-3eae-4435-97f7-86aa793686f8' })
    wiredPicklistValues({ error, data }) {
        console.log('data get trsm store ->',data);
        if (data) {
            try {
                let options = [];
                for (var key in data) {
                    options.push({ label: data[key].name, value: data[key].value, selected: false });
                }
                this.TypeOptions = options;
                console.log(' this.TypeOptions -->', this.TypeOptions);
            } catch (error) {
            }
        } else if (error) {
        }

    }

    /*Method to check user permissions*/
    @wire(isWidgetAccessible, { accountId: '$recordId', requestedForPayroll: false })
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

    /*Method to get all documents lists from sharepoint*/
    @wire(getAllFileDocuments, { recordId: '$recordId', channelname: '$AccountSharedChannelURL', QueryText:'$searchTerm', SortingField: '$sortColumn', SortingDirection: '$sortDirection' })
    wiredDocuments(result) {
        this.isLoading = true;
        this.wiredDocuments = result;
       
        console.log('im in wire doc');
        console.log('Result Data-->',result.data);
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
     
    /*Method to get user fields value*/
    @wire(getRecord, { recordId: USER_ID, fields: [Author_Field] })
    
    wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.email = getFieldValue(data, Author_Field);
          //  console.log('USER ID--> ',this.userId);
        }
    }
 
    @wire(getRecord, { recordId:'$recordId' , fields: [AccountingSharedChannelURL] })
    wireaccount({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.AccountSharedChannelURL = getFieldValue(data, AccountingSharedChannelURL);
            console.log('**Acc name -->'+this.AccountSharedChannelURL);
            if(typeof this.AccountSharedChannelURL == "undefined"||this.AccountSharedChannelURL == null||this.AccountSharedChannelURL == '')
            {
                this.AccountSharedChannelURL = '-AccountingSharedChannel';
                console.log('in wire if ',this.AccountSharedChannelURL);
                console.log('Account id--> ',this.recordId );
            }
 
        }
    }
    connectedCallback() {
        this.showLoadingMessage = true;
        console.log('Im in connection call back');   
        console.log('this.AccountSharedChannelURL in ccb',this.AccountSharedChannelURL);     
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
       // refreshApex(this.wiredDocuments);
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
                   // refreshApex(this.wiredDocuments);
                }
            }
    }


    //Token generation
    @wire(MessageContext)
    messageContext;

    subscribeToSharepointTokenChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                SharePointToken,
                async (message) => await this.handleSharePointTokenReceived(message)
            );
        }
    }

    publishSharePointTokenRequest() {
        publish(this.messageContext, requestSharePointToken, { token: this.token });
    }

    //Token Recieved
    async handleSharePointTokenReceived(message) {
        try {
            console.log("handleSharePointTokenReceived called with " + JSON.stringify(message));
            if (message.token) {
                this.token = 'Bearer ' + message.token;
                let promises = [];
                for (let i = 0; i < this.files.length; i++) {
                    let file = this.files[i];
                    let filePromise = new Promise(resolve => {
                        let fileReader = new FileReader();
                        fileReader.readAsArrayBuffer(file);
                        fileReader.onloadend = () => {
                            let fileContent = fileReader.result;
                            resolve({ name: file.name, content: fileContent });
                        };
                    });
                    promises.push(filePromise);
                }
                this.ItemsToUpdate = [];
                let _this = this;
                await Promise.all(promises).then(async fileContents => {
                    for (let i = 0; i < fileContents.length; i++) {
                        let fileContent = fileContents[i];
                        let renamedFile = this.renamedfiles.find(i => i.oldname == fileContent.name);
                        let fileNameToUse = renamedFile ? renamedFile.newname : fileContent.name;
                        await this.handleUploadWithRESTAPI(this.token, fileNameToUse, fileContent.content);
                        _this.uploadedFiles = _this.uploadedFiles + 1;
                        _this.updateProgressBar();
                    }
                });
                await this.updateFileMetaData();
                this.selectedValue = '';
            } else {
                throw new Error('Token not received');
            }
        } catch (error) {
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
        this.showFilePropertiesModal = true;
        this.showSpinner = false;
    }

    //close modal bclicking Close/Cancel
    handleCloseModal() {
        this.showFilePropertiesModal = false;
        this.token = '';
        this.files = undefined;
        this.isFileUploaded = false;
        this.authenticationError = "";
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

      

    //Close overwrite model
    handleCloseOverwriteModal() {
        this.showOverWriteModal = false;
        console.log('Selected Doc Class', JSON.stringify(this.selectedDocClass));
        let tempOptions = this.TypeOptions.map((option) => {
            console.log('option',JSON.stringify(option));
            return { ...option, selected: this.selectedDocClass.indexOf(option.value.replaceAll(';', '')) > -1 }

        });
        console.log('tempOptions', tempOptions);
        this.TypeOptions = tempOptions;

        this.showFilePropertiesModal = true;
    }

    //close success response model
    CloseResponseMessage() {
        this.showResponseMessage = false;
        this.newUploadedFileUrl = '';
       this.selectedValue = '';
        refreshApex(this.wiredDocuments);
      
        eval("$A.get('e.force:refreshView').fire();");
       
        
    }

   

    //close error model
    CloseErrorMessage() {
        this.showErrorMessage = false;
        this.errorMessage = '';
        this.selectedValue = '';
    }

    //Close ProgressBar Model
    closeProgressBarModal() {
        this.showProgressBarModal = false;
    }

    //Update ProgressBar Model Function w.r.t files length
    updateProgressBar() {
        let width = ((this.uploadedFiles / this.files.length) * 100);
        width = Math.round(width);
        let progressBar = this.template.querySelector('[data-id="ProgressBar"]');
        let progressBarText = this.template.querySelector('[data-id="ProgressBarText"]');
        progressBar.style.width = width + "%";
        progressBarText.innerHTML = this.uploadedFiles + "/" + this.files.length + " File(s) Uploaded";
    }

    //open uploaded documents in new tab as sharepoint site onclick of viewAll
    handleViewAll() {
        window.open(this.createdsiteurl + this.AccountSharedChannelURL+'/Shared Documents', '_blank');
    }

    //select document properties model
    handleTypeChange(event) {
        const selectedOptions = event.target.selectedOptions;
      
        this.selectedDocClass = [];
        for (let i = 0; i < selectedOptions.length; i++) {
            const value = selectedOptions[i].value.replaceAll(';', '');
            console.log('value->'+value);
            if (!this.selectedDocClass.includes(value)) {
                this.selectedDocClass.push(value);
            }
            this.displayDocError = false;
            this.errorDocMessage = '';
        }
        console.log('check-->'+event.target.selectedOptions.value)

    }

    // This function handles file upload to SharePoint
    async handleFileUploadToSharePoint(event) {
        
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
        this.showOverWriteModal = false;

        // Check if the file already exists in SharePoint
        console.log('Check if file exist from account');
        let overwriteFiles = ((event.target.dataset.overwritefiles ?? '') == 'true');
        console.log('overwrite files  '+overwriteFiles);
        let isFileExist = false;
        if (overwriteFiles == false) {
            isFileExist = await this.CheckifFileExistsinSPO();
        }

        // Display the overwrite modal if the file exists and overwriting is not allowed
        if (overwriteFiles == false && isFileExist) {
            this.showFilePropertiesModal = false;
            this.showOverWriteModal = true;
            return;
        }

        // Reset any error messages and show the progress bar modal
        this.showSpinner = false;
        this.errorMessage = '';
        this.displayError = false;
        this.displayDocError = false;
        this.errorDocMessage = '';
        this.showFilePropertiesModal = false;
        this.showProgressBarModal = true;
        this.filePropertiesModalEM = '';
        this.progressBarModalError = this.fileUploadInProgressEM;

        // Subscribe to the SharePoint token channel and publish a token request
        this.subscribeToSharepointTokenChannel();
        this.publishSharePointTokenRequest();

    }

    handleCachedFile() {
        if (this.files) {
            console.log('File-->',this.files);
            this.fileData = new FormData();
            this.fileData.append('file', this.files);
            console.log('fileData-->',this.fileData);
            this.showFilePropertiesModal = true;
            this.showSpinner = false;
        }
    }

    //File handler after selecting docuemnt from local system
    selectFile(event) {
       
        //sharepointFileUploadController.CreateRecord(this.recordId,this.userId);
        // Regular expression to check for invalid characters in the file name
        var format = /["*:<>/|\\]/;
        // Clear existing files array and set uploaded files count to 0
        this.files = [];
        this.uploadedFiles = 0;
        // Iterate through each file in the selected files array
        for (var file of event.target.files) {
            // Check if the file name contains any invalid characters
            if (format.test(file.name)) {
            }
            else {
                this.files.push(file);
            }
        }

        // Clear selected files array and populate with file name, extension and ID for each selected file
        this.selectedFiles = [];
        for (let i = 0; i < this.files.length; i++) {
            const fileName = this.files[i].name.substring(0, this.files[i].name.lastIndexOf("."));
            const fileExtension = this.files[i].name.split('.').pop();
            this.selectedFiles.push({
                id: i,
                name: fileName,
                extension: fileExtension
            });
        }

        // Call function to handle cached file
        this.handleCachedFile();

        // Clear the file input field value
        var inputField = this.template.querySelectorAll('input');
        inputField.forEach(element => {
            element.value = "";
        });
       
    }

    // This method is triggered when a file name is changed by the user in the UI
    handleFileNameChange(event) {
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

    dragOverHandler(event) {
        event.preventDefault();
        console.log('Im in on dragOverHandler');
    }

    dropHandler(event) {
        event.preventDefault();
        console.log('Im in on dropHandler');
      /*  if (event.dataTransfer.files) {
            this.files = event.dataTransfer.files;
        }*/
        var format = /["*:<>/|\\]/;
        // Clear existing files array and set uploaded files count to 0
        this.files = [];
        this.uploadedFiles = 0;
        // Iterate through each file in the selected files array
        for (var file of event.dataTransfer.files) {
            // Check if the file name contains any invalid characters
            if (format.test(file.name)) {
            }
            else {
                this.files.push(file);
            }
        }

        // Clear selected files array and populate with file name, extension and ID for each selected file
        this.selectedFiles = [];
        for (let i = 0; i < this.files.length; i++) {
            const fileName = this.files[i].name.substring(0, this.files[i].name.lastIndexOf("."));
            const fileExtension = this.files[i].name.split('.').pop();
            this.selectedFiles.push({
                id: i,
                name: fileName,
                extension: fileExtension
            });
        }

        // Call function to handle cached file
        this.handleCachedFile();

        // Clear the file input field value
        var inputField = this.template.querySelectorAll('input');
        inputField.forEach(element => {
            element.value = "";
        });
       
        this.handleCreateLWCRecord();
    }

    // Checks if the selected file already exists in SharePoint
    async CheckifFileExistsinSPO() {
        try {
            this.isCheckingFileExists = true;
            this.showFilePropertiesModal = false;
            let tempFileNames = [];
            let isFileExists = false;
            for (let file of this.files) {
                // Check if the file has been renamed
                let renamedFile = this.renamedfiles.find(i => i.oldname == file.name);
                let fileNameToUse = renamedFile ? renamedFile.newname : file.name;
                tempFileNames.push(fileNameToUse);
            }
            // Clear existing files array
            let _this = this;
            _this.existingFiles = [];
            // Call the server to check for existing files
            await checkforExistingMultipleFiles({ recordId: this.recordId, fileNames: JSON.stringify(tempFileNames), channelname: this.AccountSharedChannelURL })
                .then(result => {
                    console.log('Result-> '+result);
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
                            this.showFilePropertiesModal = false;
                        }
                    }
                })
                .catch(error =>{ this.errorMessage = error});

            // Reset flag and show the file properties modal
            this.isCheckingFileExists = false;
            this.showFilePropertiesModal = true;
            return isFileExists;
        } catch (error) {
            console.error(error);
        }
    }

    //This function is used to upload a file to SharePoint Online using REST API with a given token, file name, and file contents.
    async handleUploadWithRESTAPI(token, file, fileContents) {
        var updatedFileName = encodeURIComponent(file);
        updatedFileName = updatedFileName.replace(/'/g, "''");
        this.url1 = this.createdsiteurl + this.AccountSharedChannelURL+"/_api/web/GetFolderByServerRelativePath(decodedurl='/sites/" + this.nickname + this.AccountSharedChannelURL+"/Shared Documents')/Files/AddUsingPath(overwrite=true,decodedurl='" + updatedFileName + "')";
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
            }).then((r) => {
                console.log('digest res', r);

                return r.json()

            })

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
                            return this.GetDocumentIDByServerUrl(token, file)
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
                                    console.log('Error in GetDocumentIDByServerUrl', error);
                                    this.errorMessage = "Something went wrong while getting uploaded document ID!";
                                    this.showErrorMessage = true;
                                    this.showProgressBarModal = false;
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
    GetDocumentIDByServerUrl(token, file) {
        var updatedFileName = encodeURIComponent(file);
        updatedFileName = updatedFileName.replace(/'/g, "''");
        var reqUrl = this.createdsiteurl + this.AccountSharedChannelURL+'/_api/web/GetFileByServerRelativePath(decodedurl=\'/sites/' + this.nickname + this.AccountSharedChannelURL+'/Shared Documents/' + updatedFileName + '\')/ListItemAllFields';
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
                this.showFilePropertiesModal = true;
                this.showDocumentPropertiesForm = true;
                this.errorMessage = 'Error in GetDocumentIDByServerUrl.';
                this.showErrorMessage = true;
                this.showProgressBarModal = false;
            });
    };

    //This function updates the metadata of the selected files using the File/UpdateMetadata endpoint.
    async updateFileMetaData() {
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
            "spoWebUrl": this.createdsiteurl + this.AccountSharedChannelURL,
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
            }
            if (response.message == 'The remote server returned an error: (429)') {
                _this.showErrorMessage = true;
                _this.errorMessage = 'The remote server returned an error: (429) ';
                _this.showResponseMessage = false;
            }
            // refresh wiredDocuments property
            await refreshApex(this.wiredDocuments);
            _this.showProgressBarModal = false;
            _this.uploadedFiles = 0;
            _this.showResponseMessage = true;
        }).catch((error) => {
            _this.errorMessage = "Something went wrong while updating metadata!";
            _this.showErrorMessage = true;
            _this.showResponseMessage = false;
            _this.showProgressBarModal = false;
        });
    }

    handleChange(event) {
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
    
    handleCreateLWCRecord()
    {
       
        CreateLWCRecord({LWCName:'Accounting Upload From Account',recordId: this.recordId,UserId:this.userId })
        .then(result => {
            console.log('NEW Result: ' + result);
        })
        .catch(error => {
            console.log('NEW Error: ' + error);
        });
    }

}