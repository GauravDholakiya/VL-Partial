public class AptTaskUploadSelectorController {
	@AuraEnabled
    public static Map<String, List<APTTaskTemplate__c>> fetchAPTaskTempates(String templateType, String conId) {
        System.debug('fetchAPTaskTempates = ' + templateType + ' ' + conId);
        List<APTTaskTemplate__c> selTaskTemplates = new List<APTTaskTemplate__c>();
        Map <String, List<APTTaskTemplate__c>> apNameToAptTask= new Map<String, List<APTTaskTemplate__c>>();
        Boolean isLibrary = true;
        if (templateType == 'template'){
            isLibrary = false;
            Contract__c contract = [SELECT id, Scope__c FROM Contract__c WHERE id =: conId];
            if (contract.Scope__c != null) {
                System.debug(contract.Scope__c);
                Set<String> scopeFilter = new Set<String>(contract.Scope__c.split(';'));
                selTaskTemplates = [
                        SELECT Id, Name, Task_Number__c,TaskId__c,IsMandatory__c, Frequency__c,
                                Assigned_Role__c, Subject__c, Action_Plan_Template__r.Name
                        FROM APTTaskTemplate__c
                        WHERE Action_Plan_Template__r.Name IN : scopeFilter];
            }
        }else{
            selTaskTemplates = [SELECT Id, Name, Task_Number__c,TaskId__c,IsMandatory__c, Frequency__c,
                    Assigned_Role__c, Subject__c, Action_Plan_Template__r.Name
            FROM APTTaskTemplate__c WHERE Action_Plan_Template__r.Library_Template__c =: isLibrary];
        }
        for (APTTaskTemplate__c aptt : selTaskTemplates) {
            if (apNameToAptTask.containsKey(aptt.Action_Plan_Template__r.Name)) {
                apNameToAptTask.get(aptt.Action_Plan_Template__r.Name).add(aptt);
            } else {
                apNameToAptTask.put(aptt.Action_Plan_Template__r.Name, new List<APTTaskTemplate__c>{aptt});
            }
        }
        return apNameToAptTask;
    }
}