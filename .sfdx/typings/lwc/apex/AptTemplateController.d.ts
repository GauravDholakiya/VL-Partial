declare module "@salesforce/apex/AptTemplateController.getTasks" {
  export default function getTasks(param: {apId: any}): Promise<any>;
}
declare module "@salesforce/apex/AptTemplateController.getTemplatePlan" {
  export default function getTemplatePlan(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AptTemplateController.getNewTemplatePlanTask" {
  export default function getNewTemplatePlanTask(param: {index: any}): Promise<any>;
}
declare module "@salesforce/apex/AptTemplateController.savePlan" {
  export default function savePlan(param: {tId: any, tPlan: any, tTasksJSON: any, delTasksJSON: any}): Promise<any>;
}
declare module "@salesforce/apex/AptTemplateController.fetchIniStartDatePicklistValues" {
  export default function fetchIniStartDatePicklistValues(): Promise<any>;
}
declare module "@salesforce/apex/AptTemplateController.fetchRolePicklistValues" {
  export default function fetchRolePicklistValues(): Promise<any>;
}
