/**
 * @author Jozef
 * @date 22.1.2019.
 * @description //TODO
 */

@IsTest
private class AptActionPlanControllerTest {
    @testSetup static void setup() {
        AptUtilDataTest.setup();
    }
    /*
    @IsTest
    static void testBehavior() {
        String apTasksJSON = '[{"Id":"a0D1v00000JplpjEAB", "isVisible": "true" , "Subject__c":"Task Frist","Frequency__c":"Kvartal","NextNMonths__c":"3 months","Reminder__c":false,"Action_Plan__c":"a0E1v00000HsjRGEAZ","Period_1__c":"2019-01-25","User__c":"0050Y000003h3AZQAY","taskIndex__c":0,"IsMandatory__c":false,"AttachmentHeader__c":"a0H1v00000FMbUqEAL","User__r":{"Name":"Lauren Boyle","Id":"0050Y000003h3AZQAY"},"Action_Plan__r":{"Id":"a0E1v00000HsjRGEAZ"}},{"Id":"a0D1v00000JpmbIEAR","Subject__c":"Second","Reminder__c":false,"Action_Plan__c":"a0E1v00000HsjRGEAZ","User__c":"0050Y000000V3ZKQA0","taskIndex__c":1,"IsMandatory__c":false,"AttachmentHeader__c":"a0H1v00000FMbcQEAT","User__r":{"Name":"Jozef Huba","Id":"0050Y000000V3ZKQA0"},"Action_Plan__r":{"Id":"a0E1v00000HsjRGEAZ"}},{"Id":"a0D1v00000JpmbJEAR","Subject__c":"Third","Reminder__c":false,"Action_Plan__c":"a0E1v00000HsjRGEAZ","User__c":"0050Y000000V3ZKQA0","taskIndex__c":2,"IsMandatory__c":false,"AttachmentHeader__c":"a0H1v00000FMbcVEAT","User__r":{"Name":"Jozef Huba","Id":"0050Y000000V3ZKQA0"},"Action_Plan__r":{"Id":"a0E1v00000HsjRGEAZ"}},{"Id":"a0D1v00000JpmbKEAR","Subject__c":"Fifth task","Reminder__c":false,"Action_Plan__c":"a0E1v00000HsjRGEAZ","User__c":"0050Y000000V3ZKQA0","taskIndex__c":3,"IsMandatory__c":false,"AttachmentHeader__c":"a0H1v00000FMbcaEAD","User__r":{"Name":"Jozef Huba","Id":"0050Y000000V3ZKQA0"},"Action_Plan__r":{"Id":"a0E1v00000HsjRGEAZ"}},{"Id":"a0D1v00000JpmbLEAR","Subject__c":"Seven","Reminder__c":false,"Action_Plan__c":"a0E1v00000HsjRGEAZ","User__c":"0050Y000000V3ZKQA0","taskIndex__c":4,"IsMandatory__c":false,"AttachmentHeader__c":"a0H1v00000FMbcfEAD","User__r":{"Name":"Jozef Huba","Id":"0050Y000000V3ZKQA0"},"Action_Plan__r":{"Id":"a0E1v00000HsjRGEAZ"}}]';

        List<APTaskTemplate__c> apTasks  = (List<APTaskTemplate__c>) JSON.deserialize(apTasksJSON,
                List<APTaskTemplate__c>.class);

        System.debug(apTasks);

    }

    @IsTest
    static void testDate() {
        Date periodDate = Date.newInstance(2019, 6, 25);
        Date monday = Date.newInstance(1900, 1, 1);
        System.debug(monday.daysBetween(periodDate));
        Integer dayDiff = Math.mod(monday.daysBetween(periodDate), 7);
        System.debug(dayDiff);

    }

     */

    /*
    @IsTest
    static void getContractRolesTest() {
        Contract__c  con = AptUtilDataTest.createContract();
        Id contractId = con.id;
        String roleFieldNames = ', Employee_1__c, Employee_2__c';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        AptActionPlanController.getContractRoles(contractId, roleFieldNames);
        Test.stopTest();
    }
     */

    @IsTest
    static void getStandardTasksTest() {
        Task t = AptUtilDataTest.createStandardTask();
        t = [SELECT AP_Task__r.Action_Plan__c FROM Task WHERE Id =: t.Id];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        AptActionPlanController.getStandardTasks(t.AP_Task__r.Action_Plan__c);
        Test.stopTest();
    }

    @IsTest
    static void getContractTest() {
        Contract__c  con = AptUtilDataTest.createContract();
        Id contractId = con.id;
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        AptActionPlanController.getContract(contractId);
        Test.stopTest();
    }

    @IsTest
    static void getActionPlanTest() {
        ActionPlan__c  ap = AptUtilDataTest.createActionPlan();
        Id apId = ap.id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        AptActionPlanController.getActionPlan(apId);
        apId = null;
        AptActionPlanController.getActionPlan(apId);
        Test.stopTest();
    }

    @IsTest
    static void getNewTasksTest() {
        AptUtilDataTest.createTemplateTasks(2);
        Contract__c con = AptUtilDataTest.createContract();
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        AptActionPlanController.getNewTasks(con.id);
        Test.stopTest();
    }

    @IsTest
    static void getTasksTest() {
        List<APTTaskTemplate__c> tTasks = AptUtilDataTest.createTemplateTasks(2);
        Id apId = tTasks.get(0).Action_Plan_Template__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        AptActionPlanController.getTasks(apId);
        Test.stopTest();
    }

    @IsTest
    static void getAttachmentsTest() {
        AttachmentHeader__c attachmentHeader = AptUtilDataTest.createAttachmentHeader();
        Test.startTest();
        AptActionPlanController.getAttachments(attachmentHeader.id);
        Test.stopTest();
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

    @IsTest
    static void saveAttachmentsTest(){
        String attachmentHeaderId =  AptUtilDataTest.createAttachmentHeader().id;
        AptActionPlanController.AptAttachment aptAttachment = new AptActionPlanController.AptAttachment();

        aptAttachment.documentId = null;
        aptAttachment.name = 'Attachment';
        List<AptActionPlanController.AptAttachment> aptAttachments = new List<AptActionPlanController.AptAttachment>();
        aptAttachments.add(aptAttachment);

        String files = JSON.serialize(aptAttachments);
        Test.startTest();
        AptActionPlanController.saveAttachments(attachmentHeaderId, files);
        Test.stopTest();
    }

    @IsTest
    static void getAdditionalTasksTest() {
        String index = '0';
        List<APTTaskTemplate__c> tempTasks = AptUtilDataTest.createTemplateTasks(2);
        List<Id> selectedTasks = new List<Id>();
        for (APTTaskTemplate__c aptTaskTemplate : tempTasks) {
            selectedTasks.add(aptTaskTemplate.id);
        }
        Id contractId = AptUtilDataTest.createContract().id;
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        AptActionPlanController.getAdditionalTasks(index,  selectedTasks, contractId);
        Test.stopTest();
    }

    @IsTest
    static void copyTasksTest(){
        String fiscalYear = String.valueOf(System.today().year() + 1);
        AptUtilDataTest.createActionPlanTasks(2);
        Contract__c con = [SELECT id, Account_Owner_KA__c FROM Contract__c LIMIT 1];
        con.Account_Owner_KA__c = UserInfo.getUserId();
        update con;
        Test.StartTest();
        AptActionPlanController.copyTasks(con.Id, fiscalYear);
        Test.StopTest();
    }

    @IsTest
    static void fetchRolePicklistValuesTest() {
        AptActionPlanController.fetchRolePicklistValues();
    }

}