@IsTest
private class AptTaskUploadSelectorControllerTest {

    @IsTest
    static void fetchAPTaskTempatesLibraryTest() {
        List<APTTaskTemplate__c> lAptTaskTemplates = AptUtilDataTest.createTemplateTasks(2);

        APTTaskTemplate__c apt = lAptTaskTemplates.get(0);
        ActionPlanTemplate__c actionPlanTemplate = [SELECT id, Library_Template__c FROM ActionPlanTemplate__c
            WHERE id =: apt.Action_Plan_Template__c];
        actionPlanTemplate.Library_Template__c = true;
        update actionPlanTemplate;

        Test.startTest();
        AptTaskUploadSelectorController.fetchAPTaskTempates('library', null);
        Test.stopTest();
    }

    @IsTest
    static void fetchAPTaskTempatesTest() {
        AptUtilDataTest.setup();
        List<APTTaskTemplate__c> lAptTaskTemplates = AptUtilDataTest.createTemplateTasks(2);
        Contract__c contract = AptUtilDataTest.createContract();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        contract.Scope__c = '';
        update contract;

        AptTaskUploadSelectorController.fetchAPTaskTempates('template', contract.id);
        Test.stopTest();
    }

}