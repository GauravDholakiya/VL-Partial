/**
 * @author Jozef 
 * @date 28.1.2019.
 * @description //TODO
 */

public class CustomLookUpController {

    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        //SELECT Responsible__r.id, Responsible__r.Name FROM Account_Team_And_Authorizations__c where Name LIKE: searchKey order by createdDate DESC limit 5';
        //String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';

        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';

        List < sObject > returnList = new List < sObject > ();

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

    @AuraEnabled
    public static List < sObject > fetchLookUpValuesByQuery(String searchKeyWord, String sQuery) {
        //SELECT Responsible__r.id, Responsible__r.Name FROM Account_Team_And_Authorizations__c where Name LIKE: searchKey order by createdDate DESC limit 5';
        //String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';

        system.debug('query-->' + sQuery);
        String searchKey = searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }


    @AuraEnabled
    public static sObject fetchLookUpValuesById(Id recordId, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        System.debug('RecordId ' +recordId);
        sObject obj = null;
        String sQuery =  'SELECT id, Name FROM ' +ObjectName + ' WHERE id = ' + '\'' + recordId + '\'';
        //System.debug(sQuery);
        List < sObject > result = doQuery(sQuery);
        if(!result.isEmpty()){
            obj = result.get(0);
        }
        return obj;
    }

    private static List < sObject > doQuery(String sQuery){
        List < sObject > returnList = new List < sObject > ();

        // String sQuery =  'SELECT id, Name FROM ' +ObjectName + ' WHER id: recordId';
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

}