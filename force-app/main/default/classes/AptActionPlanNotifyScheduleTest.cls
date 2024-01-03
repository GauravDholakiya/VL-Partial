/**
 * Created by jozef on 17. 5. 2023.
 */

@IsTest
private class AptActionPlanNotifyScheduleTest {
   /*
    @TestSetup
    static void setUp(){
        Action_Plan_Automation__mdt conf = new Action_Plan_Automation__mdt();
        conf.DeveloperName = 'Notification';
        conf.Label = 'Notification';
        conf.Creation_Date__c = '1.12';
        conf.Number_of_days_before_creation__c = 10;
    }*/

    @IsTest
    static void testBehavior() {
        String cron_exp = '0 0 0 3 9 ? 2042';
        Test.startTest();
        String jobId = System.schedule('testAptActionPlanScheduleTest',
                cron_exp, new AptActionPlanNotifySchedule());
        Test.stopTest();
    }
}