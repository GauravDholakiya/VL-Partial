// Created June 2020 - Mia Genovese, Fluido
// Used for the View Academy App
@isTest
private class LinkControllerTest {
    @isTest
    static void getLinks() {
        Links__c link = new Links__c(
            Name = 'test',
            Description__c = 'test desc',
            Link_url__c = 'google.com',
            Type__c = 'Implementing',
            Country__c = 'Norway'
        );
        insert link;
        List<String> types = new List<String>{link.Type__c};
        List<String> countries = new List<String>{link.Country__c};
        String searchTerm = 'test';
        String emptysearchTerm = '';
        List<String> emptyList = new List<String>();
        System.debug('types' + types);
        System.debug('countries' + countries);
        Test.startTest();
        Links__c[] returned = LinkController.getFilteredLinks(emptyList, emptyList, emptysearchTerm);
        Links__c[] returned2 = LinkController.getFilteredLinks(emptyList, countries, emptysearchTerm);
        Links__c[] returned3 = LinkController.getFilteredLinks(types, countries, emptysearchTerm);
        Links__c[] returned4 = LinkController.getFilteredLinks(types, emptyList, emptysearchTerm);
        Links__c[] returned5 = LinkController.getFilteredLinks(emptyList, emptyList, searchTerm);
        Links__c[] returned6 = LinkController.getFilteredLinks(emptyList, countries, searchTerm);
        Links__c[] returned7 = LinkController.getFilteredLinks(types, countries, searchTerm);
        Links__c[] returned8 = LinkController.getFilteredLinks(types, emptyList, searchTerm);
        Test.stopTest();

        System.assert(returned.size() == 1);
        System.assert(returned2.size() == 1);
        System.assert(returned3.size() == 1);
        System.assert(returned4.size() == 1);
        System.assert(returned5.size() == 1);
        System.assert(returned6.size() == 1);
        System.assert(returned7.size() == 1);
        System.assert(returned8.size() == 1);
    }
    
    @isTest
    static void userPermissions(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='miatest@testorg.com');
        insert u;
       
        Test.startTest();
            Boolean bool = LinkController.getUserPermissions(u.Id);
        Test.stopTest();
        System.assertNotEquals(null, bool);
        
    }
    
    @isTest
    static void getCountryPicklistValues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Links__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
                options.add(String.valueOf(f.getLabel()));
        }
        Test.startTest();
            List<String> countries = LinkController.getCountryPicklistValues();
        Test.stopTest();
        System.assert(countries == options);
    }

    @isTest
    static void getTypePicklistValues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Links__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
                options.add(String.valueOf(f.getLabel()));
        }
        Test.startTest();
            List<String> types = LinkController.getTypePicklistValues();
        Test.stopTest();
        System.assert(types == options);
    }
}