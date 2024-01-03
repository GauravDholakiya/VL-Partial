@istest
public class sharepointFileUploadControllerTest {   
    
    @istest static void fetchGettermStore(){
        
        Termset__c testtermset = TestDataFactory.createTermset();
        test.startTest();
        sharepointFileUploadController.fetchGettermStore('Document_Classification');
        test.stopTest();
    }
    
    @istest public static void testDocumentWrapper() {
        // Create a new instance of DocumentWrapper
        sharepointFileUploadController.DocumentWrapper wrapper = new sharepointFileUploadController.DocumentWrapper();
        
        // Set some values for the properties
        wrapper.fileName = 'Test File';
        wrapper.title = 'Test Title';
        wrapper.docIcon = 'Test Icon';
        wrapper.modifiedBy = 'Test User';
        wrapper.modifiedTime = '2023-03-23T09:30:00Z';
        wrapper.fileLink = 'Test Link';
        
        // Assert that the values are set correctly
        System.assertEquals('Test File', wrapper.fileName);
        System.assertEquals('Test Title', wrapper.title);
        System.assertEquals('Test Icon', wrapper.docIcon);
        System.assertEquals('Test User', wrapper.modifiedBy);
        System.assertEquals('2023-03-23T09:30:00Z', wrapper.modifiedTime);
        System.assertEquals('Test Link', wrapper.fileLink);
    }
    
    @istest public static void testIsWidgetAccessibleResponse() {
        // Create a new instance of isWidgetAccessibleResponse
        sharepointFileUploadController.isWidgetAccessibleResponse response = new sharepointFileUploadController.isWidgetAccessibleResponse();
        
        // Set some values for the properties
        response.showWidget = true;
        response.message = 'Widget is accessible.';
        
        // Assert that the values are set correctly
        System.assertEquals(true, response.showWidget);
        System.assertEquals('Widget is accessible.', response.message);
    }
    
    //testMethod2 for covering method 'getAllFileDocuments' method.    
    @isTest static void testgetAllFileDocuments() {
        AzureAD_Credential__c credential = TestDataFactory.createAzurecredential();
        Account ac= TestDataFactory.createAccount();
        List<Account> aclist= new List<Account>();
        aclist.add(ac);
        String sortingField = 'FileLeafRef';
        String sortingDirection = 'asc';
        String endpoint = 'https://example.com/api';
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContractTriggerhandler_Mock.CreateTeamSiteHelper_Mock());
        sharepointFileUploadController.getAllFileDocuments(ac.id,'PayrollSharedChannel','image',sortingField,sortingDirection);
        test.stopTest();
    }
    
    //testMethod3 for covering 'checkforExistingMultipleFiles'
    @isTest static void testcheckforExistingMultipleFiles() {
        AzureAD_Credential__c credential = TestDataFactory.createAzurecredential();
        Account ac= TestDataFactory.createAccountcountry();
        Task testTask =TestDataFactory.createTask4();
        
        List<Account> aclist= new List<Account>();
        aclist.add(ac);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContractTriggerhandler_Mock.CreateTeamSiteHelper_Mock());
        sharepointFileUploadController.checkforExistingMultipleFiles(ac.id,'"class.txt","Code.txt"','AccountingSharedChannel');   
        sharepointFileUploadController.checkforExistingMultipleFilesTask(testTask.id,'"class.txt","Code.txt"','AccountingSharedChannel');
        try {
            sharepointFileUploadController.checkforExistingMultipleFiles('', '"class.txt","Code.txt"', 'AccountingSharedChannel');

            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            // System.assertEquals('Invalid record ID', e.getMessage());
        }
        test.stopTest();
    }
    
    //testmethod4 for covering 'isWidgetAccessible' & 'isTaskWidgetAccessible'
    @isTest static void testisWidgetAccessibleAndResp() {
        Account ac= TestDataFactory.createAccount4();
        Task testTask =TestDataFactory.createTaskCountry();
        
        sharepointFileUploadController.isWidgetAccessibleResponse wrapper = new sharepointFileUploadController.isWidgetAccessibleResponse();
        
        wrapper.showWidget = false;
        wrapper.message = 'Access is denied.';
        
        Test.startTest();
        wrapper = sharepointFileUploadController.isWidgetAccessible(ac.id,false);
        wrapper = sharepointFileUploadController.isTaskWidgetAccessible(testTask.id,false);
        
        Test.stopTest();
        System.assertNotEquals(null, wrapper, 'sharepointFileUploadController instance should not be null');
        
        
        
        
    }
    
    @isTest static void testUploadFile() {
        // Create a test Task record
           
        Task taskRecord =TestDataFactory.createTask4();
        
        List<Task> tasks = sharepointFileUploadController.getTasksWithCustomFields(taskRecord.Id);
        
        // Call the uploadFile method with widgetName as 'Accounting'
        sharepointFileUploadController.uploadFile(taskRecord.Id, 'Accounting');
        
        // Verify that the Accounting_Upload__c field on the Task record is set to true
        Task updatedTaskRecord = [SELECT Id, Accounting_Upload__c, Payroll_Upload__c FROM Task WHERE Id = :taskRecord.Id LIMIT 1];
        System.assertEquals(true, updatedTaskRecord.Accounting_Upload__c);
        System.assertEquals(false, updatedTaskRecord.Payroll_Upload__c);
        
        // Call the uploadFile method with widgetName as 'Payroll'
        sharepointFileUploadController.uploadFile(taskRecord.Id, 'Payroll');
        
        // Verify that the Payroll_Upload__c field on the Task record is set to true
        updatedTaskRecord = [SELECT Id, Accounting_Upload__c, Payroll_Upload__c FROM Task WHERE Id = :taskRecord.Id LIMIT 1];
        System.assertEquals(true, updatedTaskRecord.Payroll_Upload__c);
        System.assertEquals(true, updatedTaskRecord.Accounting_Upload__c);
    }
    
    @isTest static void testgetCustomSettings(){
        AzureAD_Credential__c credential = TestDataFactory.createAzurecredential();
        
        test.startTest();
        sharepointFileUploadController.getCustomSettings();
        test.stopTest();
    }
    
    @IsTest  static void testHasAccessToWidget() {
        // Create a test account and contracts
        
        Account ac= TestDataFactory.createAccount();
        
        Contract__c Agreement = new Contract__c();
        Agreement.Account__c = ac.Id;
        
        Contract__c Agreement1 = new Contract__c();
        Agreement.Account__c = ac.Id;
        
        Task testTask =TestDataFactory.createTaskCountry();
        
        User u = TestDataFactory.createUser();
        
        // Create test user and account teams
        
        Account_Team_And_Authorizations__c team1 = new Account_Team_And_Authorizations__c(Kontrakt__c=Agreement.Id, Responsible__c=u.Id, Type__c='Accounting Responsible');
        Account_Team_And_Authorizations__c team2 = new Account_Team_And_Authorizations__c(Kontrakt__c=Agreement1.Id, Responsible__c=u.Id, Type__c='Payroll Consultant');
        
        // Test access for accounting widget
        Test.startTest(); 
        
        Boolean hasAccess = sharepointFileUploadController.hasAccessToWidget(testTask.Id, true);
        
        Test.stopTest();
        
        
    }
    
    @isTest static void testHasAccessToWidgetteam() {
        TestDataFactory.setTestData();
        
        Account account = TestDataFactory.createAccount('Java Team', 'NO - Norge');
        insert account;
        account = TestDataFactory.createAccountWithActiveMsTeams('Salesforce Team', 'NO - Norge');       
        insert account;
        account = TestDataFactory.createAccountWithActiveMsTeams('ASP Team', 'NO - Norge');       
        insert account;
        List<Contract__c> ContractList = new  List<Contract__c>();
        Set<string> UserList = new  Set<string>();
        
        User user1 = [SELECT Id,Email FROM User WHERE Email='marika.finseth12345@viewledger.com' LIMIT 1];
        User user2 = [SELECT Id,Email FROM User WHERE Email='hozan.abdulla12@viewledger.com' LIMIT 1];
        User user3 = [SELECT Id,Email FROM User WHERE Email='Test.User@viewledger.com' LIMIT 1];
        
        Account account1 = [select id,SPGroupID__c from account where name = 'Java Team' limit 1];
        account1.SPGroupID__c = '1a8470b3-9247-408b-afb0-4a0d160cb6b8';
        update account1;
        Account account2 = [select id,SPGroupID__c from account where name = 'Salesforce Team' limit 1];
        
        
        Id Operational = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        Id Implementation = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        
        Contract__c contract1 = TestDataFactory.CreateAgreement(account1.Id, user1.Id, Operational);
        ContractList.add(contract1);
        
        Contract__c contract2 = TestDataFactory.CreateAgreement(account2.Id, user2.Id, Implementation);
        ContractList.add(contract2);
        
        Contract__c contract3 = TestDataFactory.CreateAgreement(account1.Id, user1.Id, Implementation);
        ContractList.add(contract3);
        
        insert ContractList;
        
        Contract__c selectedContract1 = [select id from Contract__c where Account__c=:  account1.Id  and RecordTypeId=: Operational];
        Contract__c selectedContract2 = [select id from Contract__c where Account__c=:  account2.Id ];
        Contract__c selectedContract3 = [select id from Contract__c where Account__c=:  account1.Id  and RecordTypeId=: Implementation];
        
        List<Account_Team_And_Authorizations__c> Listofrecords = new List<Account_Team_And_Authorizations__c>();
        Account_Team_And_Authorizations__c  AATA = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract1.Id, 'Account_Team','Project_Manager',user2.Id);
        Listofrecords.add(AATA);
        
        Account_Team_And_Authorizations__c  AATA2 = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract2.Id, 'Account_Team','Integration_Resource',user1.Id);
        Listofrecords.add(AATA2);
        
        Account_Team_And_Authorizations__c  AATA3 = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract2.Id, 'Account_Team','Project_Manager',user1.Id);
        Listofrecords.add(AATA3);
        
        Account_Team_And_Authorizations__c  AATA4 = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract3.Id, 'Account_Team','Project_Manager',user3.Id);
        Listofrecords.add(AATA4);
        Account_Team_And_Authorizations__c  AATA5 = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract3.Id, 'Account_Team','Payroll Consultant',user3.Id);
        Listofrecords.add(AATA5);
        Account_Team_And_Authorizations__c  AATA6 = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract3.Id, 'Account_Team','Accounting Responsible',user3.Id);
        Listofrecords.add(AATA6);
        insert Listofrecords;
        
        Task task= new Task();
        task.Period__c=3;
        task.Task_Number__c=123;
        task.WhatId = account1.Id;
        task.Account__c =account1.Id;
        insert task;
        
        Account_Team_And_Authorizations__c SelectedAATA1 =   [select id,Area__c,Type__c,Responsible__c, Kontrakt__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  selectedContract1.Id  and Type__c= 'Project_Manager'];
        UserList.add(user3.Email);
        
        Boolean hasAccess = sharepointFileUploadController.hasAccessToWidget(task.Id, true);
        
    }
    
    @isTest static void testmethodgetTermStore(){
        Test.startTest();
        AzureAD_Credential__c credential = TestDataFactory.createAzurecredential();
        
        sharepointFileUploadController.getTermStore('b96aecbd-3eae-4435-97f7-86aa793686f8'); 
        Test.setMock(HttpCalloutMock.class, new ContractTriggerhandler_Mock.CreateTeamSiteHelper_Mock());
        
        test.stopTest();
    }
    
    @isTest static void testmethodSortinggetAlldocuments(){
        AzureAD_Credential__c credential = TestDataFactory.createAzurecredential();
        Account ac= new account();
        ac.name='Upload Test change';
        ac.IsMSTeamCreated__c =true;
        ac.isWidgetActive__c =true;
        ac.MailNickName__c='SBOX_NewTest_testupl2';
        ac.Country2__c='NO - Norge';
        insert ac;
        List<Account> aclist= new List<Account>();
        aclist.add(ac);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContractTriggerhandler_Mock.CreateTeamSiteHelper_Mock());
        sharepointFileUploadController.getAllFileDocuments(ac.id,'PayrollSharedChannel','','FileLeafRef','asc');
        test.stopTest();
    }
    
    @isTest static void testmethodCreatecustomrecord()
    {
        Account account = TestDataFactory.createAccount('Java Team', 'NO - Norge');
        insert account;
        
        User u = TestDataFactory.createUser();
        
         Test.startTest(); 
        sharepointFileUploadController.CreateLWCRecord('Test Lwc Name',account.Id,u.Id);
		        
        Test.stopTest();
        List<LWC_File_Tracker__c> records = [select id from LWC_File_Tracker__c where Record_ID__c=:account.Id AND User_ID__c=:u.Id AND LWC_Name__c='Test Lwc Name'];
        System.assertEquals(1, records.size(), 'Expected one record to be created');
    }
       
}