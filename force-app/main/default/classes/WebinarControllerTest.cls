// Created June 2020 - Mia Genovese, Fluido
// Used for the View Academy App
@isTest
private class WebinarControllerTest {
    @isTest
    static void getWebinars() {
        Webinars__c webinar = new Webinars__c(
            Name = 'test',
            Description__c = 'test desc',
            Video_url__c = 'google.com',
            Type__c = 'Internal',
            Country__c = 'Norway'
        );
        insert webinar;
        List<String> types = new List<String>{webinar.Type__c};
        List<String> countries = new List<String>{webinar.Country__c};
        String searchTerm = 'test';
        String emptysearchTerm = '';
        List<String> emptyList = new List<String>();
        System.debug('types' + types);
        System.debug('countries' + countries);
        Test.startTest();
        Webinars__c[] returned = WebinarController.getFilteredWebinars(emptyList, emptyList, emptysearchTerm);
        Webinars__c[] returned2 = WebinarController.getFilteredWebinars(emptyList, countries, emptysearchTerm);
        Webinars__c[] returned3 = WebinarController.getFilteredWebinars(types, countries, emptysearchTerm);
        Webinars__c[] returned4 = WebinarController.getFilteredWebinars(types, emptyList, emptysearchTerm);
        Webinars__c[] returned5 = WebinarController.getFilteredWebinars(emptyList, emptyList, searchTerm);
        Webinars__c[] returned6 = WebinarController.getFilteredWebinars(emptyList, countries, searchTerm);
        Webinars__c[] returned7 = WebinarController.getFilteredWebinars(types, countries, searchTerm);
        Webinars__c[] returned8 = WebinarController.getFilteredWebinars(types, emptyList, searchTerm);
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
            Boolean bool = WebinarController.getUserPermissions(u.Id);
        Test.stopTest();
        System.assertNotEquals(null, bool);
    }

    @isTest
    static void getCountryPicklistValues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Webinars__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
                options.add(String.valueOf(f.getLabel()));
        }
        Test.startTest();
            List<String> countries = WebinarController.getCountryPicklistValues();
        Test.stopTest();
        System.assert(countries == options);
    }

    @isTest
    static void getTypePicklistValues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Webinars__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
                options.add(String.valueOf(f.getLabel()));
        }
        Test.startTest();
            List<String> types = WebinarController.getTypePicklistValues();
        Test.stopTest();
        System.assert(types == options);
    }
}