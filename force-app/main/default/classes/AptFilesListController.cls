public class AptFilesListController {

    @AuraEnabled
    public static List<ContentVersion> fetchFiles(String relatedRecordId) {
        /*List<AttachmentHeader__c> attHeaders = [SELECT Id, Name, Standard_Task_Id__c, Contract_Id__c 
                                                FROM AttachmentHeader__c WHERE Standard_Task_Id__c = :relatedRecordId];*/
        Set<Id> attHeadersIds = new Set<Id>();
        for (AttachmentHeader__c ah : [SELECT Id, Name, Standard_Task_Id__c, Contract_Id__c 
                                                FROM AttachmentHeader__c WHERE Standard_Task_Id__c = :relatedRecordId]) {
                                                    
            attHeadersIds.add(ah.Id);
        }
        
        List<AttachmentRow__c> attRows = [SELECT Id, File_Name__c, AttachmentHeader__c 
                                          FROM AttachmentRow__c WHERE AttachmentHeader__c IN :attHeadersIds];
        
        Map<Id,List<Id>> documentLink = new Map<Id,List<Id>>();
        for(ContentDocumentLink cdl : [SELECT id, ContentDocument.id
        								FROM ContentDocumentLink WHERE linkedentityid = :relatedRecordId]) {

            if (documentLink.containsKey(cdl.ContentDocument.id)){
                documentLink.get(cdl.ContentDocument.id).add(cdl.id);
            }else{
                List<Id> cdlIds = new List<Id>();
                cdlIds.add(cdl.id);
                documentLink.put(cdl.ContentDocument.id, cdlIds);
            }
        }

        List<ContentVersion> cvs = [SELECT id,
                Description,
                Title,
                PathOnClient,
                ContentLocation,
                ExternalDataSourceId,
                ExternalDocumentInfo1,
                ExternalDocumentInfo2,
                Origin,
                ContentDocumentId,
                ContentDocument.Title,
                LastModifiedDate,
                CreatedById,
                OwnerId,
                Owner.Name,
                CreatedBy.Name                   
        FROM ContentVersion
        WHERE ContentDocumentId IN: documentLink.keySet()
        AND IsLatest = true
        ORDER BY LastModifiedDate desc];
       
        System.debug(cvs);
        return cvs;
     }
}