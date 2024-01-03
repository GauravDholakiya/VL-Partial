/**
 * @author Jozef 
 * @date 6.2.2019.
 * @description //TODO
 */

public with sharing class RecordReferenceController {


    @AuraEnabled
    public static sObject getObjectData(Id recordId, String objectName, String fieldName) {
        System.debug('recordId = ' + recordId);
        System.debug('Object = ' + objectName);
        System.debug('fieldName = ' + fieldName);
        sObject obj = null;
        String theQuery = 'SELECT '+ fieldName + ' FROM ' + objectName + ' WHERE Id =: recordId ';
        try {
            obj = database.query(theQuery);
        }catch (Exception ex){
            throw new AuraHandledException('RecordReferenceController.getObjectData : ' + ex.getMessage());
        }
        return obj;
    }
}