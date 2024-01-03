/**
 * Created by jozef on 18. 5. 2023.
 */

@IsTest
private class AptActionPlanCreationBatchTest {
    @TestSetup static void setup() {
        AptUtilDataTest.setup();
    }
    @IsTest
    static void testBehavior() {
        AptUtilDataTest.createActionPlanTasks(2);
        Contract__c con = [SELECT id, Account_Owner_KA__c FROM Contract__c LIMIT 1];
        con.Account_Owner_KA__c = UserInfo.getUserId();
        update con;
        Test.StartTest();
        AptActionPlanCreationBatch creationBatch = new AptActionPlanCreationBatch();
        ID batchprocessid = Database.executeBatch(creationBatch);
        Test.StopTest();
    }

    @IsTest
    static void testFailBehavior() {
        AptUtilDataTest.createActionPlanTasks(5000);
        Test.StartTest();
        AptActionPlanCreationBatch creationBatch = new AptActionPlanCreationBatch();
        ID batchprocessid = Database.executeBatch(creationBatch);
        Test.StopTest();
    }

    @IsTest
    static void testFiscalYearBehavior() {
        AptUtilDataTest.createActionPlanTasks(2);
        Contract__c con = [SELECT id, Account_Owner_KA__c FROM Contract__c LIMIT 1];
        con.Account_Owner_KA__c = UserInfo.getUserId();
        update con;
        Integer fiscalYear = System.today().year() + 1;
        Test.StartTest();
        AptActionPlanCreationBatch creationBatch = new AptActionPlanCreationBatch(fiscalYear);
        ID batchprocessid = Database.executeBatch(creationBatch);
        Test.StopTest();
    }
}