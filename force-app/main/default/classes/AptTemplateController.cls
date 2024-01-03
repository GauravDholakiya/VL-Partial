/**
 * @author Jozef
 * @date 18.2.2019.
 * @description //TODO
 */

public with sharing class AptTemplateController {

    @AuraEnabled
    public static List<APTTaskTemplate__c> getTasks(Id apId) {
        System.debug('aptId = ' + apId);
        List<APTTaskTemplate__c> aptTaskTemplates = new List<APTTaskTemplate__c>();
        try{
            Map<String, String> assignedRoleTranslationApi = DependentPicklist.getPicklistApiMap(
                    Account_Team_And_Authorizations__c.Type__c);
            if (!String.isEmpty(apId)) {
                aptTaskTemplates = [
                        SELECT id, Task_Number__c, Subject__c, Frequency__c,
                                Assigned_Role__c,  Reminder__c, User__c, User__r.Name, Comments__c, TaskIndex__c,
                                IsMandatory__c, Action_Plan_Template__c, AttachmentHeader__c, Skip_Weekends__c,
                                Period_1__c,  Period_2__c, Period_3__c,  Period_4__c,
                                Period_5__c,  Period_6__c, Period_7__c,  Period_8__c, Period_9__c,  Period_10__c,
                                Period_11__c, Period_12__c, Description__c, Initial_Start_Date__c,
                                Plus_Days__c
                        FROM APTTaskTemplate__c
                        WHERE Action_Plan_Template__c = :apId
                        ORDER BY TaskIndex__c asc
                ];

            }

            for (APTTaskTemplate__c aptTaskTemplate : aptTaskTemplates) {
                aptTaskTemplate.IsVisible__c = true;
                if (aptTaskTemplate.Assigned_Role__c != null) {
                    aptTaskTemplate.Assigned_Role__c = assignedRoleTranslationApi.get(
                            aptTaskTemplate.Assigned_Role__c);
                }
            }
        }catch (Exception ex){
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException('AptTemplateController.getTasks : ' + ex.getMessage());
        }
        return aptTaskTemplates;
    }

    @AuraEnabled
    public static ActionPlanTemplate__c getTemplatePlan(Id recordId) {
        System.debug('recordId = ' + recordId);
        ActionPlanTemplate__c plan = new ActionPlanTemplate__c();
        if (!String.isEmpty(recordId)){
            List<ActionPlanTemplate__c> plans = [
                    SELECT Id, Name, Description__c, SkipWeekends__c, SkipDay__c, LastModifiedDate,
                            LastModifiedBy.Name, LastModifiedById, CreatedDate,
                            CreatedBy.Name, CreatedById, Owner.Name,
                            Library_Template__c, Start_Date__c
                    FROM ActionPlanTemplate__c
                    WHERE id =: recordId];
            if (!plans.isEmpty()){
                return plans.get(0);
            }else{
                throw new AuraHandledException('There is no record with id : ' + recordId);
            }
        }
        plan.Start_Date__c = null;
        return plan;
    }

    @AuraEnabled
    public static APTTaskTemplate__c getNewTemplatePlanTask(String index){
        //System.debug('getNewTemplateTask = ' + index);
        APTTaskTemplate__c at = new APTTaskTemplate__c();
        at.TaskIndex__c = Integer.valueOf(index);
        at.User__c = UserInfo.getUserId();
        at.IsVisible__c = true;

        AttachmentHeader__c attachmentHeader = new AttachmentHeader__c();
        attachmentHeader.AP_Task_Unique_Id__c = at.TaskId__c;
        insert attachmentHeader;

        at.AttachmentHeader__c = attachmentHeader.id;
        return at;
    }

    @AuraEnabled
    public static List<APTTaskTemplate__c> savePlan(Id tId, ActionPlanTemplate__c tPlan ,
            String tTasksJSON, String delTasksJSON) {

        System.debug('Save Plan id = ' + tId);
        System.debug('Save Plan data = ' + tPlan);
        System.debug('DELETE Tasks: ' + delTasksJSON);
        System.debug('UPDATE INSERT: ' + tTasksJSON);

        checkEditPermission();
        List<APTTaskTemplate__c> tTasks  = (List<APTTaskTemplate__c>) JSON.deserialize(tTasksJSON,
                List<APTTaskTemplate__c>.class);
        if(tTasks == null){
            throw new AuraHandledException('Impossible to retrieve the tasks list. Contact your system administrator');
        }

        List<APTTaskTemplate__c> delApTasks  = (List<APTTaskTemplate__c>) JSON.deserialize(delTasksJSON,
                List<APTTaskTemplate__c>.class);
        if(delApTasks == null){
            throw new AuraHandledException('Impossible to retrieve the tasks list for deletion. Contact your system administrator');
        }

        List<APTTaskTemplate__c> tTasksForDeletion = new List<APTTaskTemplate__c>();
        List<APTTaskTemplate__c> tTasksForInsert = new List<APTTaskTemplate__c>();
        List<APTTaskTemplate__c> tTasksForUpdate = new List<APTTaskTemplate__c>();
        List<AttachmentHeader__c> tAttHeadersForDeletion = new List<AttachmentHeader__c>();


        Set<ID> idTasksForDel = new Set<ID>();
        Set<ID> idAttForDel = new Set<ID>();
        for (APTTaskTemplate__c  t : delApTasks) {
            if (t.Id != null) {
                idTasksForDel.add(t.Id);
            }
            idAttForDel.add(t.AttachmentHeader__c);
        }

        if (!idTasksForDel.isEmpty()) {
            tTasksForDeletion = [SELECT Id FROM APTTaskTemplate__c WHERE Id IN:idTasksForDel];
            delete tTasksForDeletion;
        }

        if (!idAttForDel.isEmpty()) {
            tAttHeadersForDeletion = [SELECT Id FROM AttachmentHeader__c WHERE Id IN:idAttForDel];
            delete tAttHeadersForDeletion;
        }

        if (String.isEmpty(tId)){
            insert tPlan;
        }else {
            update tPlan;
        }

        Map<String, String> assignedRoleTranslationVal = DependentPicklist.getPicklistValueMap(
                Account_Team_And_Authorizations__c.Type__c);

        for (APTTaskTemplate__c tTaskTemplate : tTasks) {
            tTaskTemplate.IsVisible__c = true;
            tTaskTemplate.User__r = null;
            System.debug('ROLE:' + tTaskTemplate.Assigned_Role__c + ' : ' + assignedRoleTranslationVal);
            if (tTaskTemplate.Assigned_Role__c != null) {
                tTaskTemplate.Assigned_Role__c = assignedRoleTranslationVal.get(
                        tTaskTemplate.Assigned_Role__c);
            }
            if (tTaskTemplate.id == null){
                tTaskTemplate.Action_Plan_Template__c = tPlan.id;
                tTasksForInsert.add(tTaskTemplate);
            }else{
                tTasksForUpdate.add(tTaskTemplate);
            }
        }
        //TODO check which tasks has been changed
        if (!tTasksForUpdate.isEmpty()){
            update tTasksForUpdate;
        }

        if (!tTasksForInsert.isEmpty()) {
            System.debug(tTasksForInsert);
            insert tTasksForInsert;
        }

        List<APTTaskTemplate__c> newTasks = getTasks(tPlan.id);
        return newTasks;
    }

    private static void checkEditPermission(){
        String objectApiName = 'APTTaskTemplate__c';
        // Get the SObjectType for the object
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
        // Get the DescribeSObjectResult for the object
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        // Check if the user has edit access on the object
        if (!objectDescribe.isUpdateable()) {
            System.debug('User does not have edit permission on ' + objectApiName);
            throw new AuraHandledException('You do not have permission to edit Action Plan Template.');
        }
    }

    @AuraEnabled
    public static List<String> fetchIniStartDatePicklistValues(){
        Map<String, String> initialStartDatePicklistMap = DependentPicklist.getPicklistValueMap(
                APTTaskTemplate__c.Initial_Start_Date__c);
        System.debug(initialStartDatePicklistMap);
        return initialStartDatePicklistMap.values();
    }

    @AuraEnabled
    public static List<String> fetchRolePicklistValues() {
        List<String> roles = DependentPicklist.getDependentPicklistValues( Account_Team_And_Authorizations__c.Type__c,
                'Account Team');
        return roles;

        /*
       	Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Contract__c').getDescribe().fields.getMap();
		List<String> values = new List<String>();

        Set<String> apiNameFields = new Set<String>();
        for(APTask_Roles__mdt role : [SELECT Label, Contract_field__c, Default_for_custom_task__c, Nickname__c, Type__c
            FROM APTask_Roles__mdt]){
            apiNameFields.add(role.Contract_field__c);
        }

        for (String field : apiNameFields) {
            values.add(fieldMap.get(field).getDescribe().getLabel());
        }
        values.add(AptTemplateController.ACCOUNT_OWNER);

*/

        /*
        values.add(fieldMap.get('Employee_1__c').getDescribe().getLabel());
        values.add(fieldMap.get('Employee_2__c').getDescribe().getLabel());
        values.add(fieldMap.get('Employee_3__c').getDescribe().getLabel());
        values.add(fieldMap.get('Employee_4__c').getDescribe().getLabel());
        values.add(fieldMap.get('CertifiedAccountant__c').getDescribe().getLabel());
        values.add(fieldMap.get('CustomerResponsibleAndRemittanceResp__c').getDescribe().getLabel());
        values.add(fieldMap.get('IntegrationResource__c').getDescribe().getLabel());
        values.add(fieldMap.get('PayrollOfficer__c').getDescribe().getLabel());
        values.add(fieldMap.get('ProjectManager__c').getDescribe().getLabel());
         */

    }


}