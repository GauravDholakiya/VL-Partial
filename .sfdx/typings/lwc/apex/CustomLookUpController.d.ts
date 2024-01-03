declare module "@salesforce/apex/CustomLookUpController.fetchLookUpValues" {
  export default function fetchLookUpValues(param: {searchKeyWord: any, ObjectName: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomLookUpController.fetchLookUpValuesByQuery" {
  export default function fetchLookUpValuesByQuery(param: {searchKeyWord: any, sQuery: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomLookUpController.fetchLookUpValuesById" {
  export default function fetchLookUpValuesById(param: {recordId: any, ObjectName: any}): Promise<any>;
}
