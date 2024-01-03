/**
 * @author Jozef 
 * @date 6.9.2019.
 * @description //TODO
 */

@IsTest
private class CustomLookUpControllerTest {
    @testSetup static void setup() {
        AptUtilDataTest.setup();
    }

    @IsTest
    static void fetchLookUpValuesTest() {
        ActionPlan__c ap = AptUtilDataTest.createActionPlan();
        String searchKeyWord = ap.Name;
        String ObjectName = 'ActionPlan__c';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        CustomLookUpController.fetchLookUpValues(searchKeyWord, ObjectName);
        Test.stopTest();
    }

    @IsTest
    static void fetchLookUpValuesByIdTest() {
        ActionPlan__c ap = AptUtilDataTest.createActionPlan();
        String recordId = ap.id;
        String ObjectName = 'ActionPlan__c';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        CustomLookUpController.fetchLookUpValuesById(recordId, ObjectName);
        Test.stopTest();
    }

    @IsTest
    static void fetchLookUpValuesByQueryTest() {
        Contract__c contract = AptUtilDataTest.createContract();
        Account_Team_And_Authorizations__c at = new Account_Team_And_Authorizations__c();
        at.Kontrakt__c = contract.id;
        at.Area__c = 'Account_Team';
        at.Type__c = 'Payroll_Responsible';
        at.Responsible__c = UserInfo.getUserId();
        insert at;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        String searchString = 'SELECT Responsible__r.id, Responsible__r.Name FROM Account_Team_And_Authorizations__c ' +
                'WHERE Name LIKE: searchKey order by createdDate DESC limit 5';
        String sKey = UserInfo.getLastName();
        CustomLookUpController.fetchLookUpValuesByQuery(sKey, searchString);
        Test.stopTest();
    }

}