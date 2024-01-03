declare module "@salesforce/apex/SingleRelatedListController.initData" {
  export default function initData(param: {jsonData: any}): Promise<any>;
}
declare module "@salesforce/apex/SingleRelatedListController.getRecords" {
  export default function getRecords(param: {jsonData: any}): Promise<any>;
}
declare module "@salesforce/apex/SingleRelatedListController.deleteRecord" {
  export default function deleteRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SingleRelatedListController.getIconName" {
  export default function getIconName(param: {sobjectApiName: any}): Promise<any>;
}
