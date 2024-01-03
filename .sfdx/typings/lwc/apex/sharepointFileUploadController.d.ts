declare module "@salesforce/apex/sharepointFileUploadController.fetchGettermStore" {
  export default function fetchGettermStore(param: {termStoreName: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.getTermStore" {
  export default function getTermStore(param: {termsID: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.checkforExistingMultipleFiles" {
  export default function checkforExistingMultipleFiles(param: {recordId: any, fileNames: any, channelname: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.checkforExistingMultipleFilesTask" {
  export default function checkforExistingMultipleFilesTask(param: {recordId: any, fileNames: any, channelname: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.getAllFileDocuments" {
  export default function getAllFileDocuments(param: {recordId: any, channelname: any, QueryText: any, SortingField: any, SortingDirection: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.getAllFileDocumentsTask" {
  export default function getAllFileDocumentsTask(param: {recordId: any, channelname: any, TaskNumber: any, QueryText: any, SortingField: any, SortingDirection: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.getCustomSettings" {
  export default function getCustomSettings(): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.isWidgetAccessible" {
  export default function isWidgetAccessible(param: {accountId: any, requestedForPayroll: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.isTaskWidgetAccessible" {
  export default function isTaskWidgetAccessible(param: {taskId: any, requestedForPayroll: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.hasAccessToWidget" {
  export default function hasAccessToWidget(param: {recordId: any, requestedForPayroll: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.getTasksWithCustomFields" {
  export default function getTasksWithCustomFields(param: {taskId: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.uploadFile" {
  export default function uploadFile(param: {recordId: any, widgetName: any}): Promise<any>;
}
declare module "@salesforce/apex/sharepointFileUploadController.CreateLWCRecord" {
  export default function CreateLWCRecord(param: {LWCName: any, recordId: any, UserId: any}): Promise<any>;
}
