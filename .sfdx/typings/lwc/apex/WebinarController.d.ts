declare module "@salesforce/apex/WebinarController.getWebinarList" {
  export default function getWebinarList(): Promise<any>;
}
declare module "@salesforce/apex/WebinarController.getFilteredWebinars" {
  export default function getFilteredWebinars(param: {types: any, countries: any, searchTerm: any}): Promise<any>;
}
declare module "@salesforce/apex/WebinarController.getUserPermissions" {
  export default function getUserPermissions(param: {userId: any}): Promise<any>;
}
declare module "@salesforce/apex/WebinarController.getCountryPicklistValues" {
  export default function getCountryPicklistValues(): Promise<any>;
}
declare module "@salesforce/apex/WebinarController.getTypePicklistValues" {
  export default function getTypePicklistValues(): Promise<any>;
}
