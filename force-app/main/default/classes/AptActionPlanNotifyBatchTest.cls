/**
 * Created by jozef on 17. 5. 2023.
 */

@IsTest
private class AptActionPlanNotifyBatchTest {
    /*
     Action_Plan_Automation__mdt conf = Action_Plan_Automation__mdt.getInstance('Notification');
     ID batchprocessid = Database.executeBatch(new AptActionPlanNotifyBatch(conf), 150);
     */

    @TestSetup static void setup() {
        AptUtilDataTest.setup();
    }
    @IsTest
    static void testBehavior() {
        AptUtilDataTest.createActionPlan();
        Test.StartTest();
        AptActionPlanNotifyBatch notifyBatch = new AptActionPlanNotifyBatch(getConf());
        ID batchprocessid = Database.executeBatch(notifyBatch, 150);
        Test.StopTest();
    }

    static Action_Plan_Automation__mdt getConf(){
        Action_Plan_Automation__mdt conf = new Action_Plan_Automation__mdt();
        conf.DeveloperName = 'Notification';
        conf.Label = 'Notification';
        conf.Creation_Date__c = '1.12';
        conf.Number_of_days_before_creation__c = 10;
        conf.Notification_Body__c = 'Action Plan for fiscal year {0} for Contract {1} is going to be created within {2} days';
        conf.Notification_Title__c = 'Title';
        return conf;
    }
}