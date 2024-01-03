public with sharing class SingleRelatedListController {
    public static final String FIELDS_PARAM = 'fields';
    public static final String NUMBER_OF_RECORDS_PARAM = 'numberOfRecords';
    public static final String RECORD_ID_PARAM = 'recordId';
    public static final String SOBJECT_API_NAME_PARAM = 'sobjectApiName';
    public static final String SOBJECT_LABEL_PARAM = 'sobjectLabel';
    public static final String SOBJECT_LABEL_PLURAL_PARAM = 'sobjectLabelPlural';
    public static final String PARENT_RELATIONSHIP_API_NAME_PARAM = 'parentRelationshipApiName';
    public static final String RELATED_FIELD_API_NAME_PARAM = 'relatedFieldApiName';
    public static final String SORTED_DIRECTION_PARAM = 'sortedDirection';
    public static final String SORTED_BY_PARAM = 'sortedBy';
    public static final String RECORDS_PARAM = 'records';
    public static final String ICON_NAME_PARAM = 'iconName';
    public static final String ADDITIONAL_FILTER = 'additionalFilter';
    
    @AuraEnabled
    public static String initData(String jsonData){
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(RECORDS_PARAM, getRecords(jsonData));
        
        String sobjectApiName = (String)requestMap.get(SOBJECT_API_NAME_PARAM);
        responseMap.put(ICON_NAME_PARAM, getIconName(sobjectApiName));
        String recordId = (String)requestMap.get(RECORD_ID_PARAM);
        responseMap.put(PARENT_RELATIONSHIP_API_NAME_PARAM, getParentRelationshipName(recordId, sobjectApiName));
        
        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectApiName);
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        responseMap.put(SOBJECT_LABEL_PARAM, sobjectDescribe.getLabel());
        responseMap.put(SOBJECT_LABEL_PLURAL_PARAM, sobjectDescribe.getLabelPlural());
        return JSON.serialize(responseMap);
    }
    
	@AuraEnabled
    public static List<Sobject> getRecords(String jsonData){
		Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        String fields = (String)root.get(FIELDS_PARAM);
		Integer numberOfRecords = (Integer)root.get(NUMBER_OF_RECORDS_PARAM);
        String recordId = (String)root.get(RECORD_ID_PARAM);
		String relatedFieldApiName = (String)root.get(RELATED_FIELD_API_NAME_PARAM);
		String sobjectApiName = (String)root.get(SOBJECT_API_NAME_PARAM);        
		String orderBy = (String)root.get(SORTED_BY_PARAM) + ' ' + (String)root.get(SORTED_DIRECTION_PARAM);  
        String additionalFilter = (String)root.get(ADDITIONAL_FILTER);  
        if(sobjectApiName == 'ContentVersion') {
            /*List<AttachmentRow__c> attRows = [SELECT Id, File_Name__c, AttachmentHeader__c, FileConnectID__c 
                                              FROM AttachmentRow__c WHERE AttachmentHeader__r.Standard_Task_Id__c = :recordId];
            
            Set<String> filesIds = new Set<String>();
            for (AttachmentRow__c ar : attRows) {
                filesIds.add(ar.FileConnectID__c);
            }*/
            Map<Id,List<Id>> documentLink = new Map<Id,List<Id>>();
            for(ContentDocumentLink cdl : [SELECT id, ContentDocument.id
                                            FROM ContentDocumentLink WHERE linkedentityid = :recordId]) {
    
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
                    Owner.Name
            FROM ContentVersion
            WHERE ContentDocumentId IN: documentLink.keySet()
            //WHERE ContentDocumentId IN :filesIds
            AND IsLatest = true
            ORDER BY LastModifiedDate desc];
           
            System.debug(cvs);
            return cvs;
            
        } else {
            String query = 'Select '+fields+' From '+sobjectApiName+' WHERE ' +relatedFieldApiName+ '= :recordId' ;
            if (!String.isEmpty(additionalFilter) && additionalFilter != null) {
                String convertedAdditionalFilter = additionalFilter.replace('!=', '<>');
                query += ' AND ' + convertedAdditionalFilter;  
            }
            query += ' ORDER BY ' +orderBy+' Limit :numberOfRecords';
        	system.debug('>>>>>>>>>>> QUERY: ' + query);
        	return Database.query(query);
        }
        
	}
        
    private static String getParentRelationshipName(Id recordId, String parentSobjectName){
        Schema.DescribeSObjectResult descrRes = recordId.getSObjectType().getDescribe();
        String name;
        for (Schema.ChildRelationship cr: descrRes.getChildRelationships()){ 
            if(cr.getChildSObject().getDescribe().getName() == parentSobjectName){
          	 	name = cr.getRelationshipName();
                break;
            }
        }
        return name;
    }

	@AuraEnabled
    public static Boolean deleteRecord(Id recordId){
        String keyCode  = ((String)recordId).subString(0,3);
		String objectLabel;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		for(Schema.SObjectType objectInstance : gd.values()) {
			if(objectInstance.getDescribe().getKeyPrefix() == keyCode) {
				objectLabel = objectInstance.getDescribe().getName();
			}
		}
        
        if (objectLabel == 'ContentVersion') {
          	system.debug('>>>>>>>deleteRecord: Content Version ID: ' + recordId);
            recordId = [SELECT id, ContentDocumentId FROM ContentVersion WHERE Id = :recordId LIMIT 1].ContentDocumentId;
           
            // TO DO - remove attachement rows in the future
            /*List<AttachmentRow__c> attRowsToDel = [SELECT Id FROM AttachmentRow__c WHERE FileConnectID__c = :recordId];
            system.debug('>>>>>>>> deleteRecord: AttachmentRow__c to delete: ' + attRowsToDel);
            if (attRowsToDel != null && attRowsToDel.size() > 0) {
                Database.DeleteResult[] drList = Database.delete(attRowsToDel, false);
            }*/
        }
        Sobject sobj = recordId.getSObjectType().newSObject(recordId);
        Database.DeleteResult result = Database.delete(sobj, true);
        return result.isSuccess();
	}       
    
    @AuraEnabled
    public static String getIconName(String sobjectApiName){
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { 
            tabDesc.addAll(tsr.getTabs()); 
        }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sobjectApiName == tr.getSobjectName() ) {
                if( tr.isCustom() ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + sobjectApiName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return iconName;
    }    
    
}