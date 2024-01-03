/**
 * @author Jozef 
 * @date 19.6.2019.
 * @description //TODO
 */

public class AptActionPlanTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }

    public void BeforeInsert(List<SObject> newItems) {}

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void BeforeDelete(Map<Id, SObject> oldItems) {
        deleteRelatedTasks(oldItems);
    }

    public void AfterInsert(Map<Id, SObject> newItems) {}

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

    public void AfterDelete(Map<Id, SObject> oldItems) {}

    public void AfterUndelete(Map<Id, SObject> oldItems) {}

    private void deleteRelatedTasks (Map<Id, SObject> oldItems) {
        Set<ID> apIds= new Set<ID>();
        Set<ID> apttIds= new Set<ID>();
        Set<ID> taskIds= new Set<ID>();
        for( SObject o : oldItems.values() ){
            ActionPlan__c ap = (ActionPlan__c)o;
            apIds.add( ap.Id );
        }

        for( APTaskTemplate__c aptt : [ select Id from APTaskTemplate__c where Action_Plan__c in :apIds ] ){
            apttIds.add( aptt.Id );
        }
        for( Task ap : [select Id from Task where Status != 'Completed'
            AND TaskTemplateId__c != null AND TaskTemplateId__c in :apttIds ] ){
                taskIds.add( ap.Id );
        }

        if( taskIds.size() > 0 ){
            //ActionPlansTaskTriggerUtilities.deleteTasks( taskIds );
            deleteTasks(taskIds);
        }
    }

    public static void deleteTasks( set<ID> apttIds ) {
        System.debug('deleteTasks apttIds --->' +apttIds);
        if( !apttIds.isEmpty() ){
            delete [ select Id from Task where Status != 'Completed' and id in :apttIds ];
        }
    }

}