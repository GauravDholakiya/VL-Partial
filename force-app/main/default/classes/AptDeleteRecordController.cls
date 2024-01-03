public class AptDeleteRecordController {
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
        
        Sobject sobj = recordId.getSObjectType().newSObject(recordId);
       	Database.DeleteResult result = Database.delete(sobj, true);
       	return result.isSuccess();
	}       
}