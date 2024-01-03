/**
 * @author Jozef 
 * @date 6.9.2019.
 * @description //TODO
 */

@IsTest
private class AptFiscalYearSelectorControllerTest {
    @testSetup static void setup() {
        AptUtilDataTest.setup();
    }

    @IsTest
    static void initYearsTest() {
        String contractId =  AptUtilDataTest.createContract().id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        AptFiscalYearSelectorController.initYears(contractId);
        Test.stopTest();
    }

    @IsTest
    static void fetchActionPlansForYearsTest() {
        ActionPlan__c actionPlan = AptUtilDataTest.createActionPlan();
        String contractId = actionPlan.Contract__c;
        String fiscalYear = String.valueOf(System.today().year());
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        AptFiscalYearSelectorController.fetchActionPlansForYears(contractId, fiscalYear);
        Test.stopTest();
    }
}