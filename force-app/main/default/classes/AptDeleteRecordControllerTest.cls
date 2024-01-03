/**
 * @author Jozef 
 * @date 6.9.2019.
 * @description //TODO
 */

@IsTest
private class AptDeleteRecordControllerTest {
    @testSetup static void setup() {
        AptUtilDataTest.setup();
    }

    @IsTest
    static void deleteRecordTest() {
        ActionPlan__c ap = AptUtilDataTest.createActionPlan();
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        AptDeleteRecordController.deleteRecord(ap.id);
        Test.stopTest();
    }
}