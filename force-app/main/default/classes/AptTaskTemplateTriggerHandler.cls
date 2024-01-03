/**
 * @author Jozef 
 * @date 21.6.2019.
 * @description //TODO
 */

public class AptTaskTemplateTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }

    public void BeforeInsert(List<SObject> newItems) {
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void BeforeDelete(Map<Id, SObject> oldItems) {
        deleteRelatedTasks(oldItems);
    }

    public void AfterInsert(Map<Id, SObject> newItems) {
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void AfterDelete(Map<Id, SObject> oldItems) {

    }

    public void AfterUndelete(Map<Id, SObject> oldItems) {
    }

    private void deleteRelatedTasks (Map<Id, SObject> oldItems) {
        Set<ID> apttIds= new Set<ID>();
        Set<ID> taskIds= new Set<ID>();
        for( SObject o : oldItems.values() ){
            APTaskTemplate__c ap = (APTaskTemplate__c)o;
            apttIds.add( ap.Id );
        }
        for( Task ap : [select Id from Task where Status != 'Completed' and TaskTemplateId__c in :apttIds ] ){
            taskIds.add( ap.Id );
        }

        if( taskIds.size() > 0 ){
            AptActionPlanTriggerHandler.deleteTasks(taskIds);
        }
    }
}