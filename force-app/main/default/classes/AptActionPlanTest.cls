/**
 * Created by jozef on 19. 5. 2023.
 */

@IsTest
private class AptActionPlanTest {
    @testSetup public static void setup() {
        AptUtilDataTest.setup();
    }
    @IsTest
    static void createTest() {
        AptUtilDataTest.createActionPlanTasks(2);
        Contract__c con = [SELECT id, Account_Owner_KA__c FROM Contract__c LIMIT 1];
        con.Account_Owner_KA__c = UserInfo.getUserId();
        update con;
        con = [SELECT id, Account__r.OwnerId, Name, OwnerId, Account__c,
            Account__r.Name, Scope__c, FiscalYearStart__c,
            StartDate__c, ReportingFrequency__c, PayrollDate__c, ReportingDate__c,
            RecordType.Name, Account_Owner_KA__c, CloseDate__c,
            Year_end_reporting_date__c, Fiscal_Year_End__c
            FROM Contract__c WHERE id =: con.id];
        String fiscalYear = String.valueOf(System.today().year() + 1);
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        AptActionPlan plan = new AptActionPlan(con, fiscalYear);
        plan.prepare();
        plan.create();
        Test.stopTest();
    }
}