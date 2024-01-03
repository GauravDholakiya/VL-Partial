declare module "@salesforce/apex/TimekeepingCalendar.setUiConf" {
  export default function setUiConf(param: {operationalFilter: any, internalFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getActivityPriceAgreementConfig" {
  export default function getActivityPriceAgreementConfig(): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getActivityPriceAgreementOptions" {
  export default function getActivityPriceAgreementOptions(param: {projTaskIds: any}): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getAllTimes" {
  export default function getAllTimes(): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.updateTime" {
  export default function updateTime(param: {timeid: any, timedate: any}): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.saveTime" {
  export default function saveTime(param: {newTimes: any}): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getCurrentUser" {
  export default function getCurrentUser(): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getMainActivityValues" {
  export default function getMainActivityValues(): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getActivityValues" {
  export default function getActivityValues(param: {mainActivityValue: any}): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getTimeTypeValues" {
  export default function getTimeTypeValues(): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getDefaultTimeTypeValue" {
  export default function getDefaultTimeTypeValue(): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getProjTasks" {
  export default function getProjTasks(param: {nameFilterString: any, internalFilter: any, operationalFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getProjectTaskCountry" {
  export default function getProjectTaskCountry(param: {projectTaskId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimekeepingCalendar.getMainPriceAgreement" {
  export default function getMainPriceAgreement(param: {projectTaskId: any}): Promise<any>;
}
