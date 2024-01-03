/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         AccountTeamAndAuthTriggerHandler_Test.cls 
Description:  Test class to test the method and get code coverage for AccountTeamAndAuthTriggerHandler class.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
15 Sep 2019        1.0         Deepak                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */
@isTest
public class AccountTeamAndAuthTriggerHandler_Test {
    @testSetup static void setup() {
        TestDataFactory.setTestData();
        
        //Account account = TestDataFactory.createAccountWithActiveMsTeams('Java Team', 'NO - Norge');
        // insert account;
        Account account = TestDataFactory.createAccount('Java Team', 'NO - Norge');
        insert account;
        account = TestDataFactory.createAccountWithActiveMsTeams('Salesforce Team', 'NO - Norge');       
        insert account;
        account = TestDataFactory.createAccountWithActiveMsTeams('ASP Team', 'NO - Norge');      
        insert account;
    }
    
    @isTest
    public static void InsertRecord()
    {
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
        
        Account_Team_And_Authorizations__c SelectedAATA1 =   [select id,Area__c,Type__c,Responsible__c, Kontrakt__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  selectedContract1.Id  and Type__c= 'Project_Manager'];
        UserList.add(user3.Email);
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new AccountTeamAndAuthTriggerHandler_Mock());
        
        // ContractTriggerhandler.SyncSalesforceAndSharepointUser(selectedContract1.Id, '', UserList, true, false, '', account1.SPGroupID__c, 'Remove');
        // ContractTriggerhandler.SyncSalesforceAndSharepointUser('', '', UserList, false, true, '', account1.SPGroupID__c, 'Remove');
        
        SelectedAATA1.Type__c ='Integration_Resource';
        SelectedAATA1.Responsible__c = user3.Id; 
        update SelectedAATA1;
        list<Sobject> listOfRec =  new list<Sobject>();
        listOfRec.add((sObject)SelectedAATA1);
        
        SelectedAATA1.Type__c ='Project_Manager';
        SelectedAATA1.Responsible__c = user3.Id;
        update SelectedAATA1;
        
        Account_Team_And_Authorizations__c SelectedAATA2 =   [select id,Area__c,Type__c,Responsible__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  selectedContract2.Id  and Type__c= 'Project_Manager'];
        SelectedAATA2.Area__c = 'Authorizations';
       // SelectedAATA2.Type__c ='Bank_Read';
           SelectedAATA2.Type__c ='Recovery_Claim';
        update SelectedAATA2;
        //system.assertequals(SelectedAATA2.Type__c = 'Bank_Read','record update failed');
        AccountTeamAndAuthTriggerHandler.scheduleAccTeamAuthjob(Listofrecords, 'Delete');
        set<string> emailids = new set<string>();
        emailids.add('marika.finseth12@viewledger.com');
        emailids.add('hozan.abdulla12@viewledger.com');
        // Map<string,Set<String>> result = new Map<string,Set<String>>();
        //   result =  ContractTriggerhandler.VerifyIfUserExists(selectedContract1.id, account1.Id , users, fetchowners, fetchMembers, graphtoken,AddOrRemove,GroupID);
        AccountTeamAndAuthTriggerHandler.DeleteOwners(emailids, '1a8470b3-9247-408b-afb0-4a0d160cb6b8', 'Bearer ' + TokenController.GetToken());
        AccountTeamAndAuthTriggerHandler.AddnewMembersTogroup(emailids, '1a8470b3-9247-408b-afb0-4a0d160cb6b8', 'Bearer ' + TokenController.GetToken());
        AccountTeamAndAuthTriggerHandler.DeleteMembers(emailids, '1a8470b3-9247-408b-afb0-4a0d160cb6b8', 'Bearer ' + TokenController.GetToken());
        AccountTeamAndAuthTriggerHandler cont =  new AccountTeamAndAuthTriggerHandler();
        cont.setCheckUniqueType(listOfRec ,null);
        delete SelectedAATA1;
        delete SelectedAATA2;
        Test.stopTest();
        
        // Add a System.assert statement to check if the expected result is obtained
        List<Account_Team_And_Authorizations__c> accountTeamAuthList = [SELECT Id, Type__c, Responsible__c FROM Account_Team_And_Authorizations__c];
        System.assertEquals(4, accountTeamAuthList.size(), 'Incorrect number of Account_Team_And_Authorizations__c records created.');
    }
    @istest
    public static void InsertRecord2()
    {
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
        
        Account_Team_And_Authorizations__c  AATA3 = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract2.Id, 'Account_Team','Remittance Responsible',user1.Id);
        Listofrecords.add(AATA3);
        
        Account_Team_And_Authorizations__c  AATA4 = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract3.Id, 'Account_Team','Project_Manager',user3.Id);
        Listofrecords.add(AATA4);
        insert Listofrecords;
        
        Account_Team_And_Authorizations__c SelectedAATA1 =   [select id,Area__c,Type__c,Responsible__c, Kontrakt__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  selectedContract1.Id  and Type__c= 'Project_Manager'];
        UserList.add(user3.Email);
        try{
            Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new AccountTeamAndAuthTriggerHandler_Mock());
            
            // ContractTriggerhandler.SyncSalesforceAndSharepointUser(selectedContract1.Id, '', UserList, true, false, '', account1.SPGroupID__c, 'Remove');
            // ContractTriggerhandler.SyncSalesforceAndSharepointUser('', '', UserList, false, true, '', account1.SPGroupID__c, 'Remove');
            
            SelectedAATA1.Type__c ='Integration_Resource';
            SelectedAATA1.Responsible__c = user3.Id;
            update SelectedAATA1;
            list<Sobject> listOfRec =  new list<Sobject>();
            listOfRec.add((sObject)SelectedAATA1);
            
            SelectedAATA1.Type__c ='Project_Manager';
            SelectedAATA1.Responsible__c = user3.Id;
            update SelectedAATA1;
            
            /*Account_Team_And_Authorizations__c SelectedAATA2 =   [select id,Area__c,Type__c,Responsible__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  selectedContract2.Id  and Type__c= 'Project_Manager'];
SelectedAATA2.Area__c = 'Authorizations';
SelectedAATA2.Type__c ='Bank_Read';

update SelectedAATA2;
*/
            AccountTeamAndAuthTriggerHandler.scheduleAccTeamAuthjob(Listofrecords, 'Delete');
            set<string> emailids = new set<string>();
            emailids.add('marika.finseth12@viewledger.com');
            emailids.add('hozan.abdulla12@viewledger.com');
            // Map<string,Set<String>> result = new Map<string,Set<String>>();
            //   result =  ContractTriggerhandler.VerifyIfUserExists(selectedContract1.id, account1.Id , users, fetchowners, fetchMembers, graphtoken,AddOrRemove,GroupID);
            AccountTeamAndAuthTriggerHandler.DeleteOwners(emailids, '1a8470b3-9247-408b-afb0-4a0d160cb6b8', 'Bearer ' + TokenController.GetToken());
            AccountTeamAndAuthTriggerHandler.AddnewMembersTogroup(emailids, '1a8470b3-9247-408b-afb0-4a0d160cb6b8', 'Bearer ' + TokenController.GetToken());
            AccountTeamAndAuthTriggerHandler.DeleteMembers(emailids, '1a8470b3-9247-408b-afb0-4a0d160cb6b8', 'Bearer ' + TokenController.GetToken());
            AccountTeamAndAuthTriggerHandler cont =  new AccountTeamAndAuthTriggerHandler();
            cont.setCheckUniqueType(listOfRec ,null);
            
            delete SelectedAATA1;
            
            Test.stopTest();
            
            // query records to verify results
            List<Account_Team_And_Authorizations__c> accountTeamAuthList = [SELECT Id, Type__c, Responsible__c FROM Account_Team_And_Authorizations__c];
            System.assertEquals(3, accountTeamAuthList.size(), 'Incorrect number of Account Team and Authorization records created.');
            
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        
    }
    @istest
    public static void InsertRecord3()
    {
        List<Contract__c> ContractList = new  List<Contract__c>();
        Set<string> UserList = new  Set<string>();
        
        
        
        User user1 = [SELECT Id,Email FROM User WHERE Email='marika.finseth12345@viewledger.com' LIMIT 1];        
        Account account1 = [select id,SPGroupID__c from account where name = 'Java Team' limit 1];
        
        Id Operational = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        
        
        Contract__c contract1 = TestDataFactory.CreateAgreement(account1.Id, user1.Id, Operational);
        ContractList.add(contract1);
        insert ContractList;
        Contract__c selectedContract1 = [select id from Contract__c where Account__c=:  account1.Id  and RecordTypeId=: Operational];
        
        List<Account_Team_And_Authorizations__c> Listofrecords = new List<Account_Team_And_Authorizations__c>();
        Account_Team_And_Authorizations__c  AATA = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract1.Id, 'Account_Team','Project_Manager',user1.Id);
        Listofrecords.add(AATA);
        insert Listofrecords;
        Test.startTest();  
        AccountTeamAndAuthTriggerHandler.scheduleAccTeamAuthjob(Listofrecords, 'Delete');
        
        Test.stopTest();
        // Assert that the scheduled job was queued
        List<CronTrigger> jobList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Delete Account Team And Authorizations Job'];
        //System.assertEquals(0, jobList.size(), 'Scheduled job was not created');
        
        // Assert that the scheduled job was set to run after 1 minute
        // Datetime expectedTime = System.now().addMinutes(1);
        // Datetime actualTime = jobList[0].NextFireTime;
        /* System.assertEquals(expectedTime.second(), actualTime.second(), 'Scheduled job time does not match expected time');
System.assertEquals(expectedTime.minute(), actualTime.minute(), 'Scheduled job time does not match expected time');
System.assertEquals(expectedTime.hour(), actualTime.hour(), 'Scheduled job time does not match expected time');
System.assertEquals(expectedTime.day(), actualTime.day(), 'Scheduled job time does not match expected time');
System.assertEquals(expectedTime.month(), actualTime.month(), 'Scheduled job time does not match expected time');
System.assertEquals(expectedTime.year(), actualTime.year(), 'Scheduled job time does not match expected time');
*/    
    }
    
    
    @istest
    public static void InsertRecord4()
    {
        String body='{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#directoryObjects","value":[{"@odata.type":"#microsoft.graph.user","id":"6e6e7452-b23c-4f2d-9dc3-45c2030d7e47","businessPhones":[],"displayName":"J\u00f8rgen Austheim Person","givenName":"J\u00f8rgen Austheim","jobTitle":"Direkt\u00f8r for kvalitet og internkontroll","mail":"marika.finseth23@viewledger.com","mobilePhone":"+47 90404101","officelocation":null,"preferredlanguage":null,"surname":"person","userPrincipalName":"marika.finseth23@viewledger.com"},{"id":"h0869b9-e5e4-4ef3-b474-0407a96a1c78","businessPhones":[],"displayName":"Andr\u00e9 reitan","givenname":"andr\u00e9","jobtitle":"systemkonsulent","mail":"are@viewledger.com","mobilePhone":"+47 48143531","officelocation":null,"preferredlanguage":null,"surname":"reitan","userPrincipalName":"Test.User@viewledger.com"},{"id":"31578jdc-416t-4f43-a411-08ce0637er45","businessPhones":["90092555"],"displayName":"Andreas eriksen","givenname":"andreas","jobtitle":"systemkonsulent","mail":"aer@viewledger.com","mobilePhone":"+47 90092555","officelocation":null,"preferredlanguage":null,"surname":"eriksen","userPrincipalName":"andreas.eriksen@viewledger.com"}]}';
        Account account1 = [select id,SPGroupID__c,name from account where name = 'Java Team' limit 1];
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class,new AccountTeamAndAuthTriggerHandler_Mock());
        AccountTeamAndAuthTriggerHandler.MakeBatchCallout(body,TokenController.GetToken(), 'getUserIds', account1.Name);
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void test_addCustomlogTeamsCreation()
    {
        List<Contract__c> ContractList = new  List<Contract__c>();
        List<string> ownerList = new  List<string>();
        
        User user1 = [SELECT Id,Email FROM User WHERE Email='marika.finseth12345@viewledger.com' LIMIT 1];
        User user2 = [SELECT Id,Email FROM User WHERE Email='hozan.abdulla12@viewledger.com' LIMIT 1];
        
        Account account1 = [select id,Name,SPGroupID__c,MailNickName__c,IsMSTeamCreated__c from account where name = 'Java Team' limit 1];
        Account account2 = [select id,Name,SPGroupID__c,MailNickName__c,IsMSTeamCreated__c from account where name = 'Salesforce Team' limit 1];
        
        Id Operational = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        Id Implementation = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        
        Contract__c contract1 = TestDataFactory.CreateAgreement(account1.Id, user1.Id, Operational);
        ContractList.add(contract1);
        Contract__c contract2 = TestDataFactory.CreateAgreement(account2.Id, user2.Id, Implementation);
        ContractList.add(contract2);
        ContractList.addAll(TestDataFactory.CreateAgreementWithAccount(20,account2.Id, user2.Id, Implementation));
        // insert ContractList;
        ownerList.add(user2.Email );
        Test.startTest();
        
        insert ContractList;
        
        /*   //Code Modified by akshay
// Mock Callout 
Test.setMock(HttpCalloutMock.class, new ContractTriggerhandler_Mock.CreateTeamSiteHelper_Mock());
// Test.setMock(HttpCalloutMock.class, new AccountTeamAndAuthTriggerHandler_Mock());
ContractTriggerhandler.CreateMSTeam(account1.Name,'zarana.joshi@viewledger.com',account1.Id,account1.IsMSTeamCreated__c,account1.SPGroupID__c);

Test.stopTest();
Account updatedAccount = [SELECT Id, IsMSTeamCreated__c, SPGroupID__c FROM Account WHERE Id =: account1.Id];
//Checking That we are Getting the Expected value same as actual Value or not
System.assertEquals(true, updatedAccount.IsMSTeamCreated__c);
System.assertNotEquals(null, updatedAccount.SPGroupID__c); */
        
    }
    
    @isTest
    public static void test_addCustomlogAccountNameChange()
    {
        
        String body='{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#directoryObjects","value":[{"@odata.type":"#microsoft.graph.user","id":"6e6e7452-b23c-4f2d-9dc3-45c2030d7e47","businessPhones":[],"displayName":"J\u00f8rgen Austheim Person","givenName":"J\u00f8rgen Austheim","jobTitle":"Direkt\u00f8r for kvalitet og internkontroll","mail":"marika.finseth23@viewledger.com","mobilePhone":"+47 90404101","officelocation":null,"preferredlanguage":null,"surname":"person","userPrincipalName":"marika.finseth23@viewledger.com"},{"id":"h0869b9-e5e4-4ef3-b474-0407a96a1c78","businessPhones":[],"displayName":"Andr\u00e9 reitan","givenname":"andr\u00e9","jobtitle":"systemkonsulent","mail":"are@viewledger.com","mobilePhone":"+47 48143531","officelocation":null,"preferredlanguage":null,"surname":"reitan","userPrincipalName":"Test.User@viewledger.com"},{"id":"31578jdc-416t-4f43-a411-08ce0637er45","businessPhones":["90092555"],"displayName":"Andreas eriksen","givenname":"andreas","jobtitle":"systemkonsulent","mail":"aer@viewledger.com","mobilePhone":"+47 90092555","officelocation":null,"preferredlanguage":null,"surname":"eriksen","userPrincipalName":"andreas.eriksen@viewledger.com"}]}';
        Account account1 = [select id,SPGroupID__c,name from account where name = 'Java Team' limit 1];
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class,new AccountTeamAndAuthTriggerHandler_Mock());
        Test.stopTest();
        
    }
    @isTest
    public static void InsertRecord5()
    {
        List<Contract__c> ContractList = new  List<Contract__c>();
        Set<string> UserList = new  Set<string>();
        
        User user1 = [SELECT Id,Email FROM User WHERE Email='marika.finseth12345@viewledger.com' LIMIT 1];
        User user2 = [SELECT Id,Email FROM User WHERE Email='hozan.abdulla12@viewledger.com' LIMIT 1];
        User user3 = [SELECT Id,Email FROM User WHERE Email='Test.User@viewledger.com' LIMIT 1];
        
        Account account1 = [select id,SPGroupID__c from account where name = 'Java Team' limit 1];
        account1.SPGroupID__c = '1a8470b3-9247-408b-afb0-4a0d160cb6b8';
        update account1;
        Account account2 = [select id,SPGroupID__c from account where name = 'Java Team' limit 1];
        account2.SPGroupID__c = '1b8470b3-9247-408b-afb0-4a0d160cb6b8';
        update account2;
        Account account3 = [select id,SPGroupID__c from account where name = 'Salesforce Team' limit 1];
        
        
        Id Operational = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        Id Implementation = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        
        Contract__c contract1 = TestDataFactory.CreateAgreement(account1.Id, user1.Id, Operational);
        ContractList.add(contract1);
        
        Contract__c contract2 = TestDataFactory.CreateAgreement(account2.Id, user2.Id, Implementation);
        ContractList.add(contract2);
        
        Contract__c contract3 = TestDataFactory.CreateAgreement(account1.Id, user1.Id, Implementation);
        ContractList.add(contract3);
        
        insert ContractList;
        
        Contract__c selectedContract1 = [select id from Contract__c where Account__c=:  account1.Id  and RecordTypeId=: Operational limit 1];
        Contract__c selectedContract2 = [select id from Contract__c where Account__c=:  account2.Id limit 1];
        Contract__c selectedContract3 = [select id from Contract__c where Account__c=:  account1.Id  and RecordTypeId=: Implementation limit 1];
        
        List<Account_Team_And_Authorizations__c> Listofrecords = new List<Account_Team_And_Authorizations__c>();
        Account_Team_And_Authorizations__c  AATA = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract1.Id, 'Account_Team','Project_Manager',user2.Id);
        Listofrecords.add(AATA);
        
        Account_Team_And_Authorizations__c  AATA2 = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract2.Id, 'Account_Team','Payroll_Responsible',user1.Id);
        Listofrecords.add(AATA2);
        
        Account_Team_And_Authorizations__c  AATA3 = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract2.Id, 'Account_Team','Project_Manager',user1.Id);
        Listofrecords.add(AATA3);
        
        Account_Team_And_Authorizations__c  AATA4 = TestDataFactory.Create_Account_Team_And_Authorizations(selectedContract3.Id, 'Account_Team','Project_Manager',user3.Id);
        Listofrecords.add(AATA4);
        insert Listofrecords;
        
        Account_Team_And_Authorizations__c SelectedAATA1 =   [select id,Area__c,Type__c,Responsible__c, Kontrakt__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  selectedContract1.Id  and Type__c= 'Project_Manager' limit 1];
        UserList.add(user3.Email);
        
        Map<id,Account_Team_And_Authorizations__c> newMap = new  Map<id,Account_Team_And_Authorizations__c>();
        Map<id,Account_Team_And_Authorizations__c> oldMap = new  Map<id,Account_Team_And_Authorizations__c>();
        newMap.put(AATA.Id, AATA);
        oldMap.put(AATA2.Id, AATA);
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new AccountTeamAndAuthTriggerHandler_Mock());
        
        // ContractTriggerhandler.SyncSalesforceAndSharepointUser(selectedContract1.Id, '', UserList, true, false, '', account1.SPGroupID__c, 'Remove');
        // ContractTriggerhandler.SyncSalesforceAndSharepointUser('', '', UserList, false, true, '', account1.SPGroupID__c, 'Remove');
        
        SelectedAATA1.Type__c ='Integration_Resource';
        SelectedAATA1.Responsible__c = user3.Id;
        update SelectedAATA1;
        list<Sobject> listOfRec =  new list<Sobject>();
        listOfRec.add((sObject)SelectedAATA1);
        
        SelectedAATA1.Type__c ='Project_Manager';
        SelectedAATA1.Responsible__c = user3.Id;
        update SelectedAATA1;
        
        Account_Team_And_Authorizations__c SelectedAATA2 =   [select id,Area__c,Type__c,Responsible__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  selectedContract2.Id  and Type__c= 'Project_Manager' limit 1];
        SelectedAATA2.Area__c = 'Authorizations';
       // SelectedAATA2.Type__c ='Bank_Read';
         SelectedAATA2.Type__c ='Recovery_Claim';
        update SelectedAATA2;
        //system.assertequals(SelectedAATA2.Type__c = 'Bank_Read','record update failed');
        AccountTeamAndAuthTriggerHandler.scheduleAccTeamAuthjob(Listofrecords, 'Delete');
        set<string> emailids = new set<string>();
        emailids.add('marika.finseth12@viewledger.com');
        emailids.add('hozan.abdulla12@viewledger.com');
        // Map<string,Set<String>> result = new Map<string,Set<String>>();
        //   result =  ContractTriggerhandler.VerifyIfUserExists(selectedContract1.id, account1.Id , users, fetchowners, fetchMembers, graphtoken,AddOrRemove,GroupID);
        AccountTeamAndAuthTriggerHandler.DeleteOwners(emailids, '1a8470b3-9247-408b-afb0-4a0d160cb6b8', 'Bearer ' + TokenController.GetToken());
        AccountTeamAndAuthTriggerHandler.AddnewMembersTogroup(emailids, '1a8470b3-9247-408b-afb0-4a0d160cb6b8', 'Bearer ' + TokenController.GetToken());
        AccountTeamAndAuthTriggerHandler.DeleteMembers(emailids, '1a8470b3-9247-408b-afb0-4a0d160cb6b8', 'Bearer ' + TokenController.GetToken());
        AccountTeamAndAuthTriggerHandler cont =  new AccountTeamAndAuthTriggerHandler();
        cont.setCheckUniqueType(listOfRec ,null);
        delete SelectedAATA1;
        //delete SelectedAATA2;
        
        Test.stopTest();
        AccTeamAndAuthDeleteQueueable test = new AccTeamAndAuthDeleteQueueable(Listofrecords,'insert');
        
        //AccTeamAndAuthUpdateQueue test2 = new AccTeamAndAuthUpdateQueue();
        
        // Add a System.assert statement to check if the expected result is obtained
        List<Account_Team_And_Authorizations__c> accountTeamAuthList = [SELECT Id, Type__c, Responsible__c FROM Account_Team_And_Authorizations__c];
        // System.assertEquals(4, accountTeamAuthList.size(), 'Incorrect number of Account_Team_And_Authorizations__c records created.');
    }
    
    @istest
    public static void testAccTeamAndAuthUpdateQueue1()
    {
        Map<id,Account_Team_And_Authorizations__c> newMap = new  Map<id,Account_Team_And_Authorizations__c>();
        Map<id,Account_Team_And_Authorizations__c> oldMap = new  Map<id,Account_Team_And_Authorizations__c>();
        
        
        
        User user1 = [SELECT Id,Email FROM User WHERE Email='hozan.abdulla12@viewledger.com' LIMIT 1];
        Id Operational = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        
        // Account Withoutaccount = TestDataFactory.createAccountWithActiveMsTeams('ASP Team', 'NO - Norge');       
        // insert account;
        
        Account account = TestDataFactory.createAccount('Java Teams', 'NO - Norge');
        insert account;
        
        
        
        Contract__c contract1 = TestDataFactory.CreateAgreement(account.Id, user1.Id, Operational);
        insert contract1;
        
        Account_Team_And_Authorizations__c  AATA1 = TestDataFactory.Create_Account_Team_And_Authorizations(contract1.Id, 'Account_Team','Project_Manager',user1.Id);
        insert AATA1;
        
        oldMap.put(AATA1.Id, AATA1);
        
        account.SPGroupID__c = '1a8470b3-9247-408b-afb0-4a0d160cb6b8';
        update account;        
        //Account_Team_And_Authorizations__c  AATA2 = TestDataFactory.Create_Account_Team_And_Authorizations(contract1.Id, 'Account_Team','Project_Manager',user1.Id);
        AATA1.Type__c ='Payroll_Responsible';
        
        update AATA1;
        newMap.put(AATA1.Id, AATA1);
        
        test.startTest();
        AccTeamAndAuthUpdateQueue testUpdate = new AccTeamAndAuthUpdateQueue(newMap, oldMap, 'Delete');
        test.stopTest();
        
    }
    @istest
    public static void testAccTeamAndAuthUpdateQueue2()
    {
        Map<id,Account_Team_And_Authorizations__c> newMap = new  Map<id,Account_Team_And_Authorizations__c>();
        Map<id,Account_Team_And_Authorizations__c> oldMap = new  Map<id,Account_Team_And_Authorizations__c>();
        List<Account_Team_And_Authorizations__c> listOfAcc = new List<Account_Team_And_Authorizations__c>();
        
        
        
        User user1 = [SELECT Id,Email FROM User WHERE Email='hozan.abdulla12@viewledger.com' LIMIT 1];
        Id Operational = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        
        // Account Withoutaccount = TestDataFactory.createAccountWithActiveMsTeams('ASP Team', 'NO - Norge');       
        // insert account;
        
        Account account = TestDataFactory.createAccount('Java TeamMate', 'NO - Norge');
        insert account;
        
        
        
        Contract__c contract1 = TestDataFactory.CreateAgreement(account.Id, user1.Id, Operational);
        insert contract1;
        
        Account_Team_And_Authorizations__c  AATA1 = TestDataFactory.Create_Account_Team_And_Authorizations(contract1.Id, 'Account_Team','Payroll_Responsible',user1.Id);
        insert AATA1;
        
        
        oldMap.put(AATA1.Id, AATA1);
        
        account.SPGroupID__c = '1a8470b3-9247-408b-afb0-4a0d160cb6b8';
        update account;        
        
        AATA1.Type__c ='Project_Manager';
        
        update AATA1;
        
        Account_Team_And_Authorizations__c  AATA2 = TestDataFactory.Create_Account_Team_And_Authorizations(contract1.Id, 'Account_Team','Project_Manager',user1.Id);
        listOfAcc.add(AATA2);
        insert listOfAcc;
        
        
        newMap.put(AATA1.Id, AATA1);
        
        test.startTest();
        AccTeamAndAuthUpdateQueue testUpdate = new AccTeamAndAuthUpdateQueue(newMap, oldMap, 'Delete');
        test.stopTest();
    }
    @isTest
    public static void testAccTeamAndAuthDeleteQueueable(){
        List<Contract__c> ContractList = new  List<Contract__c>();
        Set<string> UserList = new  Set<string>();
        
        User user1 = [SELECT Id,Email FROM User WHERE Email='marika.finseth12345@viewledger.com' LIMIT 1];
        User user2 = [SELECT Id,Email FROM User WHERE Email='hozan.abdulla12@viewledger.com' LIMIT 1];
        
        Account account1 = [select id,SPGroupID__c from account where name = 'Java Team' limit 1];
        account1.SPGroupID__c = '1a8470b3-9247-408b-afb0-4a0d160cb6b8';
        update account1;
        
        Account account2 = [select id,SPGroupID__c from account where name = 'Salesforce Team' limit 1];
        
        
        Id Operational = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        Id Implementation = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        
        Contract__c contract1 = TestDataFactory.CreateAgreement(account1.Id, user1.Id, Operational);
        ContractList.add(contract1);
        
        Contract__c contract2 = TestDataFactory.CreateAgreement(account1.Id, user2.Id, Operational);
        ContractList.add(contract2);
        
        insert ContractList;
        
        List<Account_Team_And_Authorizations__c> Listofrecords = new List<Account_Team_And_Authorizations__c>();
        
        Account_Team_And_Authorizations__c  AATA = TestDataFactory.Create_Account_Team_And_Authorizations(contract1.Id, 'Account_Team','Accounting Responsible',user1.Id);
        Listofrecords.add(AATA);
        
        Account_Team_And_Authorizations__c  AATA2 = TestDataFactory.Create_Account_Team_And_Authorizations(contract1.Id, 'Account_Team','Project Manager Payroll',user2.Id);
        Listofrecords.add(AATA2);
        insert Listofrecords;
        
        Account_Team_And_Authorizations__c SelectedAATA1 =   [select id,Area__c,Type__c,Responsible__c, Kontrakt__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  contract1.Id  and Type__c= 'Accounting Responsible'];
        
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new AccountTeamAndAuthTriggerHandler_Mock());
        
        
        SelectedAATA1.Type__c ='Payroll Consultant';
        SelectedAATA1.Responsible__c = user1.Id;
        update SelectedAATA1;
        list<Sobject> listOfRec =  new list<Sobject>();
        listOfRec.add((sObject)SelectedAATA1);
        
        SelectedAATA1.Type__c ='Payroll_Responsible';
        SelectedAATA1.Responsible__c = user1.Id;
        update SelectedAATA1;
        
        Account_Team_And_Authorizations__c SelectedAATA2 =   [select id,Area__c,Type__c,Responsible__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  contract1.Id  and Type__c= 'Project Manager Payroll'];
        SelectedAATA2.Area__c = 'Authorizations';
       // SelectedAATA2.Type__c ='Bank_Read';
         SelectedAATA2.Type__c ='Recovery_Claim';
        update SelectedAATA2;
        //system.assertequals(SelectedAATA2.Type__c = 'Bank_Read','record update failed');
        AccountTeamAndAuthTriggerHandler.scheduleAccTeamAuthjob(Listofrecords, 'Delete');
        set<string> emailids = new set<string>();
        emailids.add('marika.finseth12@viewledger.com');
        emailids.add('hozan.abdulla12@viewledger.com');
        delete SelectedAATA1;
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void testAccTeamAndAuthDeleteQueueable1(){
        List<Contract__c> ContractList = new  List<Contract__c>();
        
        Map<id,Account_Team_And_Authorizations__c> newMap = new  Map<id,Account_Team_And_Authorizations__c>();
        Map<id,Account_Team_And_Authorizations__c> oldMap = new  Map<id,Account_Team_And_Authorizations__c>();
        List<Account_Team_And_Authorizations__c> listOfAcc = new List<Account_Team_And_Authorizations__c>();
        
        
        User user1 = [SELECT Id,Email FROM User WHERE Email='marika.finseth12345@viewledger.com' LIMIT 1];
        User user2 = [SELECT Id,Email FROM User WHERE Email='hozan.abdulla12@viewledger.com' LIMIT 1];
        
        Account account1 = [select id,SPGroupID__c from account where name = 'Java Team' limit 1];
        account1.SPGroupID__c = '1a8470b3-9247-408b-afb0-4a0d160cb6b8';
        update account1;
        
        Account account2 = [select id,SPGroupID__c from account where name = 'Salesforce Team' limit 1];
        Account account3 = TestDataFactory.createAccountWithActiveMsTeams('Payroll Team', 'NO - Norge');
        insert account3;
        
        Id Operational = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        Id Implementation = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        
        Contract__c contract1 = TestDataFactory.CreateAgreement(account1.Id, user1.Id, Operational);
        ContractList.add(contract1);
        
        Contract__c contract2 = TestDataFactory.CreateAgreement(account1.Id, user2.Id, Operational);
        ContractList.add(contract2);
        
        insert ContractList;
        
        List<Account_Team_And_Authorizations__c> Listofrecords = new List<Account_Team_And_Authorizations__c>();
         Account_Team_And_Authorizations__c  AATA = TestDataFactory.Create_Account_Team_And_Authorizations(contract1.Id, 'Account_Team','Accounting Responsible',user1.Id);
        Listofrecords.add(AATA);
        
        Account_Team_And_Authorizations__c  AATA2 = TestDataFactory.Create_Account_Team_And_Authorizations(contract1.Id, 'Account_Team','Project Manager Payroll',user2.Id);
        Listofrecords.add(AATA2);
        
        // Add two records to cover the mentioned code block
        Account_Team_And_Authorizations__c AATA3 = TestDataFactory.Create_Account_Team_And_Authorizations(contract1.Id, 'Account_Team','Payroll_Responsible',user2.Id);
        Listofrecords.add(AATA3);
        
        Account_Team_And_Authorizations__c AATA4 = TestDataFactory.Create_Account_Team_And_Authorizations(contract1.Id, 'Account_Team','Executive Sponsor',user2.Id);
        Listofrecords.add(AATA4);
        
        
        insert Listofrecords;     
        
        Account_Team_And_Authorizations__c SelectedAATA1 =   [select id,Area__c,Type__c,Responsible__c, Kontrakt__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  contract1.Id  and Type__c= 'Project Manager Payroll'];
        
         Account_Team_And_Authorizations__c SelectedAATA2 =   [select id,Area__c,Type__c,Responsible__c, Kontrakt__c from Account_Team_And_Authorizations__c where Kontrakt__c=:  contract1.Id  and Type__c= 'Executive Sponsor'];
       
        List<String> typePayrollLst = new List<String>{'Payroll'};
            List<String> typeAccLst = new List<String>{'Account_Team'};
                
                Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new AccountTeamAndAuthTriggerHandler_Mock());
        
        
        SelectedAATA1.Type__c ='Integration_Resource';
        SelectedAATA1.Responsible__c = user1.Id;
        update SelectedAATA1;
        list<Sobject> listOfRec =  new list<Sobject>();
        listOfRec.add((sObject)SelectedAATA1);
        
        SelectedAATA1.Type__c ='Integration_Resource';
        SelectedAATA1.Responsible__c = user1.Id;
        update SelectedAATA1;
        
           SelectedAATA1.Type__c ='Project Manager Payroll';
        SelectedAATA1.Responsible__c = user2.Id;
        update SelectedAATA1;
           SelectedAATA2.Type__c ='Integration_Resource';
        SelectedAATA2.Responsible__c = user2.Id;
        update SelectedAATA2;
       
        AccountTeamAndAuthTriggerHandler.scheduleAccTeamAuthjob(Listofrecords, 'Delete');
        set<string> emailids = new set<string>();
        emailids.add('marika.finseth12@viewledger.com');
        emailids.add('hozan.abdulla12@viewledger.com');
        delete SelectedAATA1;
        delete SelectedAATA2;
        Test.stopTest();
        
        
    }
    
    
}