/**
 * @author Jozef 
 * @date 12.9.2019.
 * @description //TODO
 */

@IsTest
private class AptAccountTriggerHandlerTest {
    @testSetup static void setup() {
        AptUtilDataTest.setup();
    }

    @IsTest
    static void updateCountryTest() {
        Account account = AptUtilDataTest.createAccount('NO - Norge');
        Contract__c contract = AptUtilDataTest.getContract(account);
        insert contract;

        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new AptContractTriggerHandlerMock.CreateTeamSiteHelper_Mock());
        Test.setMock(HttpCalloutMock.class, new AptAccountTeamAndAuthTriggerHandlerMock.MsCallout_Mock());
        account.Country2__c = 'SE - Sweden';
        update account;
        Test.stopTest();
    }
}