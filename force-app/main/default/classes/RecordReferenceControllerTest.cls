/**
 * @author Jozef 
 * @date 6.9.2019.
 * @description //TODO
 */

@IsTest
private class RecordReferenceControllerTest {
    @testSetup static void setup() {
        AptUtilDataTest.setup();
    }

    @IsTest
    static void getObjectDataTest() {
        ActionPlan__c actionPlan = AptUtilDataTest.createActionPlan();
        Id recordId = actionPlan.id;
        String objectName = 'ActionPlan__c';
        String fieldName = 'Name';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        RecordReferenceController.getObjectData(recordId, objectName, fieldName);
        Test.stopTest();
    }

    @IsTest
    static void getObjectDataExceptionTest() {
        ActionPlan__c actionPlan = AptUtilDataTest.createActionPlan();
        Id recordId = actionPlan.id;
        String objectName = 'ActionPlan__c';
        String fieldName = 'wrongField';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        try {
            RecordReferenceController.getObjectData(recordId, objectName, fieldName);
        }catch (AuraHandledException ex){

        }
        Test.stopTest();
    }

}