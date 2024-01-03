/**
 * Created by jozef on 18. 5. 2023.
 */

@IsTest
private class AptActionPlanCreationScheduleTest {
    @IsTest
    static void testBehavior() {
        //10:17:06.27 (64843315)|USER_DEBUG|[3]|DEBUG|Action_Plan_Automation__mdt:{Label=Notification, MasterLabel=Notification, SystemModstamp=2023-05-18 07:19:51, Number_of_days_before_creation__c=10, Language=no, QualifiedApiName=Notification, Id=m043L0000000TCY, DeveloperName=Notification, NamespacePrefix=null}
        String cron_exp = '0 0 0 3 9 ? 2042';
        String jobId = System.schedule('testAptActionPlanScheduleTest',
                cron_exp, new AptActionPlanCreationSchedule());
    }
}