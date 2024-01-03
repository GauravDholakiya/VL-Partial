/**
 * @author Jozef 
 * @date 12.9.2019.
 * @description //TODO
 */

@IsTest
private class AptKontraktTriggerHandlerTest {
    @testSetup static void setup() {
        AptUtilDataTest.setup();
    }

    @IsTest
    static void insertKontrakt() {
        Account acc  = AptUtilDataTest.createAccount('NO - Norge');
        Contract__c con = AptUtilDataTest.getContract(acc);
        con.Scope__c = null;
        Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        insert con;
        con = [SELECT Country__c, Scope__c FROM Contract__c WHERE id  =: con.id ];
        System.assertEquals('NO - Norge', con.Country__c);
        /*List<String> acctualScope = con.Scope__c.split(';');
        List<String> expectedScope = AptKontraktTriggerHandler.NO_SCOPE.split(';');
        for (String expected : expectedScope) {
            if (!acctualScope.contains(expected)){
                system.assert(false);
            }
        }*/
        Test.stopTest();
    }

    @IsTest
    static void updateKontrakt() {
        Account acc  = AptUtilDataTest.createAccount('NO - Norge');
        Contract__c con = AptUtilDataTest.getContract(acc);
        insert con;

        Account accSweden  = AptUtilDataTest.createAccount('SE - Sweden');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        // OCT 09 2019 commeted by Binary republik 
        // Modification reason : Test fail due mock class overriding which not used.
       // Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        con.Account__c = accSweden.id;
        con.Scope__c = 'Payroll';
        con.Billing_Account__c = acc.Id;
        //update con;
        con = [SELECT Country__c FROM Contract__c WHERE Id =: con.id];

        //System.assertEquals('SE - Sweden', con.Country__c);
        Test.stopTest();
    }
}