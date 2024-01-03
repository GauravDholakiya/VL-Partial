declare module "@salesforce/apex/AptActionPlanController.getContract" {
  export default function getContract(param: {contractId: any}): Promise<any>;
}
declare module "@salesforce/apex/AptActionPlanController.getActionPlan" {
  export default function getActionPlan(param: {apId: any}): Promise<any>;
}
declare module "@salesforce/apex/AptActionPlanController.getNewTasks" {
  export default function getNewTasks(param: {contractId: any}): Promise<any>;
}
declare module "@salesforce/apex/AptActionPlanController.getStandardTasks" {
  export default function getStandardTasks(param: {apId: any}): Promise<any>;
}
declare module "@salesforce/apex/AptActionPlanController.getTasks" {
  export default function getTasks(param: {apId: any}): Promise<any>;
}
declare module "@salesforce/apex/AptActionPlanController.copyTasks" {
  export default function copyTasks(param: {contractId: any, fiscalYear: any}): Promise<any>;
}
declare module "@salesforce/apex/AptActionPlanController.getAttachments" {
  export default function getAttachments(param: {attachmentHeaderId: any}): Promise<any>;
}
declare module "@salesforce/apex/AptActionPlanController.savePlan" {
  export default function savePlan(param: {apId: any, apTasksJSON: any, delTasksJSON: any, contractId: any, fiscalYear: any, planName: any, skipWeekend: any}): Promise<any>;
}
declare module "@salesforce/apex/AptActionPlanController.saveAttachments" {
  export default function saveAttachments(param: {attachmentHeaderId: any, files: any}): Promise<any>;
}
declare module "@salesforce/apex/AptActionPlanController.getAdditionalTasks" {
  export default function getAdditionalTasks(param: {index: any, selectedTasks: any, contractId: any}): Promise<any>;
}
declare module "@salesforce/apex/AptActionPlanController.fetchRolePicklistValues" {
  export default function fetchRolePicklistValues(): Promise<any>;
}
