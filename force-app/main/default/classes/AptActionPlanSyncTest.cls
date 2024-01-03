/**
 * Created by jozef on 12. 5. 2023.
 */

@IsTest
private class AptActionPlanSyncTest {
    @TestSetup static void setup() {
        AptUtilDataTest.setup();
        AptUtilDataTest.createStandardTasks();
        Contract__c contract = [SELECT id, Account_Owner_KA__c FROM Contract__c LIMIT 1];
        contract.Account_Owner_KA__c = UserInfo.getUserId();
        update contract;
    }

    static void validateResult(Account_Team_And_Authorizations__c at){
        List<APTaskTemplate__c> actionPlanTemplatesAll = [SELECT id, User__c, Assigned_Role__c FROM APTaskTemplate__c];
        List<APTaskTemplate__c> actionPlanTemplates = [SELECT id, User__c, Assigned_Role__c FROM APTaskTemplate__c
        WHERE User__c =: at.Responsible__c AND Assigned_Role__c =: at.Type__c];
        //System.debug('All ----------->' + actionPlanTemplatesAll);
        //System.debug('just ----------->' + actionPlanTemplates);
        Assert.areEqual(actionPlanTemplatesAll.size(), actionPlanTemplates.size());
        List<Task> tasksAll = [SELECT id, OwnerId FROM Task];
        List<Task> tasks = [SELECT id, OwnerId FROM Task WHERE OwnerId =: at.Responsible__c ];
        Assert.areEqual(tasksAll.size(), tasks.size());
    }

    @IsTest
    static void insertAccountTeamTest() {
        Account_Team_And_Authorizations__c at = getAccountTeamAndAuthorizations(null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        insert at;
        Test.stopTest();
        at = [SELECT Type__c, Responsible__r.Name, Responsible__c FROM Account_Team_And_Authorizations__c
        WHERE Type__c = 'Payroll_Responsible'];
        validateResult(at);
    }

    static Account_Team_And_Authorizations__c getAccountTeamAndAuthorizations(User newUser){
        if (newUser == null){
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
            newUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/Los_Angeles', UserName='aptactionplantest@testorg.com');
            insert newUser;
        }
        Contract__c contract = [SELECT id, Account_Owner_KA__c FROM Contract__c LIMIT 1];
        Account_Team_And_Authorizations__c at = new Account_Team_And_Authorizations__c();
        at.Kontrakt__c = contract.id;
        at.Area__c = 'Account_Team';
        at.Type__c = 'Payroll_Responsible';
        at.Responsible__c = newUser.id;
        at.Bypass_Validation_Rule__c = true;
        return at;
    }

    @IsTest
    static void updateAccountTeamTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User newUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='aptactionplantest2@testorg.com');
        insert newUser;
        Account_Team_And_Authorizations__c atOne = getAccountTeamAndAuthorizations(null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        insert atOne;
        atOne.Responsible__c = newUser.id;
        update atOne;
        Test.stopTest();
        atOne = [SELECT Type__c, Responsible__r.Name, Responsible__c FROM Account_Team_And_Authorizations__c
        WHERE Type__c = 'Payroll_Responsible'];
        validateResult(atOne);
    }

    @IsTest
    static void deleteAccountTeamTest() {
        Account_Team_And_Authorizations__c atOne = getAccountTeamAndAuthorizations(null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        insert atOne;
        delete atOne;
        Test.stopTest();
        Account_Team_And_Authorizations__c at = [SELECT Type__c, Responsible__r.Name, Responsible__c
        FROM Account_Team_And_Authorizations__c
        WHERE Type__c = 'Account_Owner'];
        validateResult(at);
    }

    @IsTest
    static void updateYearAndReportingDateTest() {
        List<APTTaskTemplate__c> aptTaskTemplates = [SELECT id, Plus_Days__c FROM APTTaskTemplate__c];
        for (APTTaskTemplate__c apttTaskTemplate : aptTaskTemplates) {
            apttTaskTemplate.Plus_Days__c = 10;
        }
        update aptTaskTemplates;
        Contract__c contract = [SELECT Id, Year_end_reporting_date__c FROM Contract__c];
        Integer thisYear = System.today().year();
        contract.Year_end_reporting_date__c = Date.newInstance(thisYear,1,1);
        Test.startTest();
        update contract;
        Test.stopTest();
        List<APTaskTemplate__c> apTaskTemplates = [SELECT id,
                Period_1__c,
                Period_2__c, Period_3__c, Period_4__c, Period_5__c,
                Period_6__c, Period_7__c, Period_8__c, Period_9__c, Period_10__c,
                Period_11__c, Period_12__c, Skip_Weekends__c, Reminder__c, ActionPlanTemplate__r.Name,
                APT_Task__r.Initial_Start_Date__c
        FROM APTaskTemplate__c];
        System.debug(apTaskTemplates);
        List<Task> tasks = [SELECT id, ActivityDate, Period__c, Status FROM Task ];
        System.debug(tasks);
        //Follow 5-fifth period. 5th period is not static,
        //it is calculated from year end reporting date Period_5__c=2023-05-01 00:00:00
    }


}