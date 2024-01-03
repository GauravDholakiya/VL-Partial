/**
 * @author Jozef 
 * @date 12.9.2019.
 * @description //TODO
 */

@IsTest
private class AptAssignedRoleFieldControllerTest {
    @testSetup static void setup() {
        AptUtilDataTest.setup();
    }

    @IsTest
    static void controllerTest() {
        //PageReference pageRef = Page.AptAssignedRoleField;
        //Test.setCurrentPage(pageRef);
        /*
        List<APTTaskTemplate__c> lt = [SELECT id, Assigned_Role__c FROM APTTaskTemplate__c
            WHERE Assigned_Role__c = 'Account Owner' OR Assigned_Role__c = 'Payroll Officer'];
        System.debug('TO BE DONE:' + lt.size());
        for (APTTaskTemplate__c aptTaskTemplate : lt) {
            if (aptTaskTemplate.Assigned_Role__c == 'Account Owner'){
                aptTaskTemplate.Assigned_Role__c = 'Account_Owner';
            }else if(aptTaskTemplate.Assigned_Role__c == 'Payroll Officer'){
                aptTaskTemplate.Assigned_Role__c = 'Payroll_Responsible';
            }
        }
        if (!lt.isEmpty()){
            update lt;
        }
         */


        Task t = new Task();
        t.AP_Task__c = AptUtilDataTest.createActionPlanTasks(1).get(0).id;
        insert t;


        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        ApexPages.StandardController std = new   ApexPages.StandardController(t);
        AptAssignedRoleFieldController controller = new AptAssignedRoleFieldController(std);
        System.assert(controller.label != null);
        System.assert(controller.value != null);
        Test.stopTest();
    }
}