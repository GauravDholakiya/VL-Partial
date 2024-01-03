/**
 * Created by jozef on 4. 5. 2023.
 */

@IsTest
private class AptActionPlanUtilTest {
    @testSetup static void setup() {
        AptUtilDataTest.setup();
    }
    @IsTest
    static void savePlanTest() {
        Id apId = null;
        Id userId = UserInfo.getUserId();
        Id tempId = AptUtilDataTest.createTemplatePlan().id;
        Id attHeaderId = AptUtilDataTest.createAttachmentHeader().id;
        String apTasksJSON = '[{"Task_Number__c":230,"Subject__c":"Avstemming a-melding (skyldig skatt/aga terminvis)",' +
                '"Frequency__c":"Bi-monthly","Reminder__c":true,"ActionPlanTemplate__c":"'+ tempId + '",' +
                '"Assigned_Role__c":"Payroll Officer","User__c":"'+ userId + '","taskIndex__c":0,' +
                '"IsMandatory__c":true,"Skip_Weekends__c":false,"IsVisible__c":true,' +
                '"Period_1__c":"2019-09-07","Period_2__c":"2019-11-11",'+
                '"AttachmentHeader__c":"'+ attHeaderId + '"}]';
        String delTasksJSON = '[]';
        String contractId = AptUtilDataTest.createContract().id;
        String fiscalYear = String.valueOf(System.today().year());
        String planName = 'Customer Norway 2019 Operational';
        Boolean skipWeekend = true;

        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        //Insert
        AptActionPlanController.savePlan(apId, apTasksJSON, delTasksJSON,
                contractId, fiscalYear, planName, skipWeekend);

        ActionPlan__c ap = [SELECT id FROM ActionPlan__c ];
        apId = ap.id;
        APTaskTemplate__c aptInserted = [SELECT id FROM APTaskTemplate__c WHERE Action_Plan__c =: apId];
        apTasksJSON = '[{"Id":"'+ aptInserted.id + '","Task_Number__c":230,' +
                '"Subject__c":"Avstemming a-melding (skyldig skatt/aga terminvis)",' +
                '"Frequency__c":"Bi-monthly","Reminder__c":true,"ActionPlanTemplate__c":"'+ tempId + '",' +
                '"Assigned_Role__c":"Payroll Officer","User__c":"'+ userId + '","taskIndex__c":0,' +
                '"IsMandatory__c":true,"Skip_Weekends__c":false,"IsVisible__c":true,' +
                '"Period_1__c":"2019-09-08","Period_2__c":"2019-09-08",'+
                '"AttachmentHeader__c":"'+ attHeaderId + '"}]';
        //Update
        AptActionPlanController.savePlan(apId, apTasksJSON, delTasksJSON,
                contractId, fiscalYear, planName, skipWeekend);

        APTaskTemplate__c apTaskTemplate = [
                SELECT
                        Action_Plan__c,
                        ActionPlanTemplate__c,
                        Assigned_Role__c,
                        Assigned_Type__c,
                        Attachment_Status__c,
                        AttachmentHeader__c,
                        Comments__c,
                        Contact__c,
                        CreatedById,
                        CreatedDate,
                        Frequency__c,
                        Id,
                        IsDeleted,
                        IsMandatory__c,
                        IsVisible__c,
                        LastActivityDate,
                        LastModifiedById,
                        LastModifiedDate,
                        Minutes_Reminder__c,
                        Name,
                        Period_10__c,
                        Period_11__c,
                        Period_12__c,
                        Period_1__c,
                        Period_2__c,
                        Period_3__c,
                        Period_4__c,
                        Period_5__c,
                        Period_6__c,
                        Period_7__c,
                        Period_8__c,
                        Period_9__c,
                        Reminder__c,
                        SendEmail__c,
                        Skip_Weekends__c,
                        Status__c,
                        Subject__c,
                        SystemModstamp,
                        Task_Number__c,
                        TaskId__c,
                        taskIndex__c,
                        TemplateStaticPeriodDates__c,
                        TemplateStaticPeriods__c,
                        User__c
                FROM APTaskTemplate__c WHERE Action_Plan__c =: ap.id];
        apTasksJSON = '[]';
        List<APTaskTemplate__c> apTaskTemplates = new List<APTaskTemplate__c>();
        System.debug(apTaskTemplate.AttachmentHeader__c);

        apTaskTemplates.add(apTaskTemplate);
        delTasksJSON = JSON.serialize(apTaskTemplates);

        //Delete
        AptActionPlanController.savePlan(apId, apTasksJSON, delTasksJSON,
                contractId, fiscalYear, planName, skipWeekend);

        ActionPlan__c actionPlan = [SELECT id FROM ActionPlan__c];
        delete actionPlan;
        Test.stopTest();
    }
}