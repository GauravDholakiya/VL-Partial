/**
 * @author Jozef 
 * @date 5.9.2019.
 * @description //TODO
 */

@IsTest
private class AptTemplateControllerTest {
    @IsTest
    static void getTemplatePlanTest() {
        Id recordId = AptUtilDataTest.createTemplatePlan().id;
        Test.startTest();
        AptTemplateController.getTemplatePlan(recordId);
        Test.stopTest();
    }

    @IsTest
    static void getTasksTest() {
        List<APTTaskTemplate__c> tTasks = AptUtilDataTest.createTemplateTasks(2);
        Id apId = tTasks.get(0).Action_Plan_Template__c;
        Test.startTest();
        AptTemplateController.getTasks(apId);
        Test.stopTest();
    }

    @IsTest
    static void getNewTemplatePlanTaskTest() {
        AptTemplateController.getNewTemplatePlanTask('0');
    }

    @IsTest
    static void fetchRolePicklistValuesTest() {
        AptTemplateController.fetchRolePicklistValues();
    }

    @IsTest
    static void fetchIniStartDatePicklistValuesTest() {
        AptTemplateController.fetchIniStartDatePicklistValues();
    }


    @IsTest
    static void saveTemplatePlanNewTest() {
        Id tId = null;
        ActionPlanTemplate__c tPlan = new ActionPlanTemplate__c(Name = 'Test Template One');
        String userId = UserInfo.getUserId();
        String tTasksJSON = '[{"taskIndex__c":0,' +
                '"User__c":"'+ userId + '","IsVisible__c":true,"Id":null,' +
                '"Frequency__c":"Biannual","Assigned_Role__c":"Payroll Responsible",' +
                '"Task_Number__c":"230","Subject__c":"Test Subject","Period_1__c":"2019-09-07"},' +
                '{"taskIndex__c":1,"User__c":"'+ userId + '","IsVisible__c":true,"Id":null,' +
                '"Frequency__c":"Biannual","Assigned_Role__c":"Payroll Responsible","Task_Number__c":"231",' +
                '"Subject__c":"Test Subject second","Period_2__c":"2019-09-07"}]';
        String delTasksJSON = '[]';
        AptTemplateController.savePlan(tId, tPlan , tTasksJSON, delTasksJSON);
    }
}