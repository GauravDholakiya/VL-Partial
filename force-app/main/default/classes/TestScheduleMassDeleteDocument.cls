@isTest
public class TestScheduleMassDeleteDocument {
 public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void testScheduledJob() {
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP, new ScheduleMassDeleteDocument());
        Test.stopTest();
    }
}