declare module "@salesforce/apex/LinkController.getLinkList" {
  export default function getLinkList(): Promise<any>;
}
declare module "@salesforce/apex/LinkController.getFilteredLinks" {
  export default function getFilteredLinks(param: {types: any, countries: any, searchTerm: any}): Promise<any>;
}
declare module "@salesforce/apex/LinkController.getUserPermissions" {
  export default function getUserPermissions(param: {userId: any}): Promise<any>;
}
declare module "@salesforce/apex/LinkController.getCountryPicklistValues" {
  export default function getCountryPicklistValues(): Promise<any>;
}
declare module "@salesforce/apex/LinkController.getTypePicklistValues" {
  export default function getTypePicklistValues(): Promise<any>;
}
