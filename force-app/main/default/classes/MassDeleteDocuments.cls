public class MassDeleteDocuments implements Database.Batchable<sobject>, Database.Stateful{
    public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id,contentdocumentId,FirstPublishLocationId,Title,OwnerId from ContentVersion Where IsDeleted__c= true';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<ContentVersion> scope){
        Set<Id> documentIds = new Set<Id>();
        for(ContentVersion cv : scope){
            String myIdPrefix = String.valueOf(cv.FirstPublishLocationId).substring(0,3);
            if(myIdPrefix.contains('001') || myIdPrefix.contains('00T')){
                documentIds.add(cv.contentdocumentId);
                recordsProcessed = recordsProcessed + 1; 
            }
            
        }
        List<ContentDocument> documents = [Select Id From ContentDocument Where Id IN :documentIds];
        try{
            delete documents;
        }
        catch(Exception ex){
            System.debug('Exception in deleting documents : '+ex.getMessage());
        }
        
    }
    public void finish(Database.BatchableContext info){     
        System.debug(recordsProcessed + ' records processed.');
    } 
}