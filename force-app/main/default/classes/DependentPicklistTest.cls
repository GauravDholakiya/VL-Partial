/**
 * @author Jozef 
 * @date 9.9.2019.
 * @description DependentPicklistTest
 */

@IsTest
private class DependentPicklistTest {
    @isTest
    private static void getDependentPicklistValuesTest(){
        Test.startTest();
        Map<Object,List<String>> result =
                DependentPicklist.getDependentPicklistValues( Contract__c.Scope__c );
        System.debug(result);
        Test.stopTest();
    }


    @isTest
    private static void getDependentPicklistValuesByValueTest(){
        Test.startTest();
        List<String> result =
                DependentPicklist.getDependentPicklistValues( Account_Team_And_Authorizations__c.Type__c,
                        'Account Team');
        System.debug(result);
        Test.stopTest();
    }

    @isTest
    private static void getPicklistMapValueTest(){
        Test.startTest();
        DependentPicklist.getPicklistValueMap( Account_Team_And_Authorizations__c.Type__c);
        Test.stopTest();
    }

    @isTest
    private static void getPicklistMapApiTest(){
        Test.startTest();
        DependentPicklist.getPicklistApiMap( Account_Team_And_Authorizations__c.Type__c);
        Test.stopTest();
    }
}