declare module "@salesforce/apex/SharepointWidgetController.getAllDocuments" {
  export default function getAllDocuments(param: {sobjectid: any, SortDir: any, SortField: any, ViewId: any}): Promise<any>;
}
declare module "@salesforce/apex/SharepointWidgetController.searchdocuments" {
  export default function searchdocuments(param: {accountid: any, searchtext: any}): Promise<any>;
}
declare module "@salesforce/apex/SharepointWidgetController.saveTheFiles" {
  export default function saveTheFiles(param: {sObjectId: any, fileNameList: any, contentType: any, isupload: any, jsonStringrequiredfields: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SharepointWidgetController.fetchGettermStore" {
  export default function fetchGettermStore(param: {termStoreName: any}): Promise<any>;
}
declare module "@salesforce/apex/SharepointWidgetController.DeleteFilesFromSalesforce" {
  export default function DeleteFilesFromSalesforce(param: {ContentDocumentIdList: any}): Promise<any>;
}
declare module "@salesforce/apex/SharepointWidgetController.CheckIfFilesExistsInSharepoint" {
  export default function CheckIfFilesExistsInSharepoint(param: {accountId: any, listofFileNames: any}): Promise<any>;
}
declare module "@salesforce/apex/SharepointWidgetController.UpdateIsDeletedTrue" {
  export default function UpdateIsDeletedTrue(param: {contentVersionIds: any}): Promise<any>;
}
declare module "@salesforce/apex/SharepointWidgetController.CreateRecord" {
  export default function CreateRecord(param: {accountId: any}): Promise<any>;
}
