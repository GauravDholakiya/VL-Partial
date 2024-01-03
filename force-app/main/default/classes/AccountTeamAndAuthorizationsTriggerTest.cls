/**
 * @author Jozef 
 * @date 12.9.2019.
 * @description //TODO
 */

@IsTest
private class AccountTeamAndAuthorizationsTriggerTest {
    @testSetup static void setup() {
        AptUtilDataTest.setup();
    }

    @IsTest
    static void insertTest() {
        Id conId = insertAccountTeam('Account_Team', 'Payroll_Responsible').Kontrakt__c;
        Account_Team_And_Authorizations__c atOther = new Account_Team_And_Authorizations__c();
        atOther.Kontrakt__c = conId;
        atOther.Area__c = 'Account_Team';
        atOther.Type__c = 'Payroll_Responsible';
        atOther.Responsible__c = UserInfo.getUserId();

        try {
            insert atOther;
            System.assert(false);
        }catch (System.DmlException ex){
            System.debug(ex.getMessage());
            System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Test.stopTest();
    }

    @IsTest
    static void updateTest() {
        Account_Team_And_Authorizations__c at = insertAccountTeam('Account_Team', 'Payroll_Responsible');
        at.Type__c = 'Account_Owner';
        update at;
        Test.stopTest();
    }

    @IsTest
    static void updateResponsibleTest() {
        Account_Team_And_Authorizations__c at = insertAccountTeam('Account_Team', 'Payroll_Responsible');
        at.Responsible__c = UserInfo.getUserId();
        update at;
        Test.stopTest();
    }

    @IsTest
    static void updateResponsibleNonUniqueTest() {
        Account_Team_And_Authorizations__c at = insertAccountTeam('Account_Team', 'Accounting Consultant');
        Account_Team_And_Authorizations__c atOther = new Account_Team_And_Authorizations__c();
        atOther.Kontrakt__c = at.Kontrakt__c;
        atOther.Area__c = 'Account_Team';
        atOther.Type__c = 'Account_Owner';
        atOther.Responsible__c = UserInfo.getUserId();
        atOther.Bypass_Validation_Rule__c = true;
        insert atOther;

        atOther.Type__c = 'Accounting Consultant';
        update atOther;

        Account_Team_And_Authorizations__c atOtherAccount_Owner = new Account_Team_And_Authorizations__c();
        atOtherAccount_Owner.Kontrakt__c = at.Kontrakt__c;
        atOtherAccount_Owner.Area__c = 'Account_Team';
        atOtherAccount_Owner.Type__c = 'Account_Owner';
        atOtherAccount_Owner.Responsible__c = UserInfo.getUserId();
        atOtherAccount_Owner.Bypass_Validation_Rule__c = true;
        insert atOtherAccount_Owner;
        Test.stopTest();
    }


    @IsTest
    static void updateResponsibleFailTest() {
        Account_Team_And_Authorizations__c at = insertAccountTeam('Account_Team', 'Payroll_Responsible');
        Account_Team_And_Authorizations__c atOther = new Account_Team_And_Authorizations__c();
        atOther.Kontrakt__c = at.Kontrakt__c;
        atOther.Area__c = 'Account_Team';
        atOther.Type__c = 'Account_Owner';
        atOther.Responsible__c = UserInfo.getUserId();
        atOther.Bypass_Validation_Rule__c = true;
        insert atOther;

        atOther.Type__c = 'Payroll_Responsible';
        try {
            update atOther;
            System.assert(false);
        }catch (System.DmlException ex){
            System.debug(ex.getMessage());
            System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Test.stopTest();
    }

    private static Account_Team_And_Authorizations__c insertAccountTeam(String area, String type) {
        Contract__c contract = AptUtilDataTest.createContract();
        Account_Team_And_Authorizations__c at = new Account_Team_And_Authorizations__c();
        at.Kontrakt__c = contract.id;
        at.Area__c = area; //'Account_Team';
        at.Type__c = type; //'Payroll_Responsible';
        at.Responsible__c = UserInfo.getUserId();
        at.Bypass_Validation_Rule__c = true;
        Test.startTest();

        //Test.setMock(HttpCalloutMock.class, new ContractTriggerhandler_Mock.CreateTeamSiteHelper_Mock());
        //new AccountTeamAndAuthTriggerHandler_Mock()



        insert at;
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        return at;
    }

    @IsTest
    static void  insertAllowDuplicateTest() {
        Account_Team_And_Authorizations__c a = insertAccountTeam('Authorizations', 'Billing');
        Account_Team_And_Authorizations__c at = new Account_Team_And_Authorizations__c();
        at.Kontrakt__c = a.Kontrakt__c;
        at.Area__c = 'Authorizations';
        at.Type__c = 'Billing';
        at.Responsible__c = UserInfo.getUserId();
        at.Bypass_Validation_Rule__c = true;

        insert at;
        Test.stopTest();
    }

}