declare module "@salesforce/apex/SObjectController.getReturnResults" {
  export default function getReturnResults(param: {records: any, fieldNames: any}): Promise<any>;
}
declare module "@salesforce/apex/SObjectController.getColumnData" {
  export default function getColumnData(param: {curRR: any, fields: any, objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/SObjectController.getRowData" {
  export default function getRowData(param: {records: any, lookupFields: any, percentFields: any}): Promise<any>;
}
