/**
 * @author Jozef 
 * @date 11.9.2019.
 * @description //TODO
 */

public with sharing class AptAssignedRoleFieldController {
    private Task task;
    public String label {get; set;}
    public String value {get; set;}


    public AptAssignedRoleFieldController(ApexPages.StandardController controller){
        Task t = (Task)controller.getrecord();
        this.task = [SELECT Assigned_Role__c FROM Task WHERE id=: t.id];
        this.label = Schema.getGlobalDescribe().get('Task').getDescribe().
                fields.getMap().get('Assigned_Role__c').getDescribe().getLabel();
        Map<String, String> assignedRoleTranslationApi = DependentPicklist.getPicklistApiMap(
                Account_Team_And_Authorizations__c.Type__c);
        this.value = assignedRoleTranslationApi.get(task.Assigned_Role__c);
    }

}