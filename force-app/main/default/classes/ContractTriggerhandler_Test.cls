@isTest
public class ContractTriggerhandler_Test {
    
    @testSetup static void setup() {
        TestDataFactory.setTestData();
        
        Account account = TestDataFactory.createAccount('Java Team', 'NO - Norge');
        insert account;
        account = TestDataFactory.createAccountWithActiveMsTeams('Salesforce Team', 'NO - Norge');       
        insert account;
        account = TestDataFactory.createAccountWithActiveMsTeams('ASP Team', 'NO - Norge');       
        insert account;
    }
    
    @isTest
    public static void SPCreateMSTeamSiteOprational()
    {
        List<Contract__c> ContractList = new  List<Contract__c>();
        List<string> ownerList = new  List<string>();
        
        User user1 = [SELECT Id,Email FROM User WHERE Email='marika.finseth12@viewledger.com' LIMIT 1];
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
        
        //Code Modified by akshay
        // Mock Callout 
        Test.setMock(HttpCalloutMock.class, new ContractTriggerhandler_Mock.CreateTeamSiteHelper_Mock());
        ContractTriggerhandler.CreateMSTeam(account1.Name,'zarana.joshi@viewledger.com',account1.Id,account1.IsMSTeamCreated__c,account1.SPGroupID__c);
        
        Test.stopTest();
        Account updatedAccount = [SELECT Id, IsMSTeamCreated__c, SPGroupID__c FROM Account WHERE Id =: account1.Id];
        //Checking That we are Getting the Expected value same as actual Value or not
        System.assertEquals(true, updatedAccount.IsMSTeamCreated__c);
        System.assertNotEquals(null, updatedAccount.SPGroupID__c);
        
    }
    
     /* @isTest
    public static void SPUpdateMSTeamSiteOprational()
    {
        
        List<Contract__c> ContractList = new List<Contract__c>();
        List<Contract__c> ContractUpdateList = new List<Contract__c>();
        
        User user1 = [SELECT Id FROM User WHERE Email='marika.finseth12@viewledger.com' LIMIT 1];
        User user2 = [SELECT Id FROM User WHERE Email='hozan.abdulla12@viewledger.com' LIMIT 1];
        
        Account account1 = [select id,SPGroupID__c,MailNickName__c from account where name = 'ASP Team' limit 1];
        Account account2 = [select id,SPGroupID__c,MailNickName__c from account where name = 'Salesforce Team' limit 1];
        
        Id operationalRtId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        Id implementatioRtId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        
        Contract__c contract1 = TestDataFactory.CreateAgreement(account1.Id, user1.Id, operationalRtId);
        ContractList.add(contract1);
        
        Contract__c contract2 = TestDataFactory.CreateAgreement(account2.Id, user2.Id, implementatioRtId);
        ContractList.add(contract2);
        
        Test.startTest();
        contractTriggerHandler.populateStartDateOnAccount(ContractList);
        Test.setMock(HttpCalloutMock.class, new ContractTriggerhandler_Mock.CreateTeamSiteHelper_MockforUpdate());
        insert ContractList;
        
        for(Contract__c contract :  ContractList){
            if(contract.Account__c==account1.Id){
                contract.OwnerId = user2.Id;
                ContractUpdateList.add(contract);
            }
            else
            {
                contract.OwnerId = user1.Id;
                ContractUpdateList.add(contract);
            }
        }
        //ContractTriggerhandler.RetryCreateTeamSite(account2.SPGroupID__c, '', account2.MailNickName__c, account2.Id, 1);
        update ContractUpdateList;
        Test.stopTest();
    } */
    
    
    @isTest
    public static void SPUserNotFound()
    {
        List<Contract__c> ContractList = new  List<Contract__c>();
        List<string> ownerList = new  List<string>();
        User user1 = [SELECT Id,Email FROM User WHERE Email='piyush@binaryrepublik.com' LIMIT 1];
        
        Account account1 = [select id,SPGroupID__c from account where name = 'Java Team' limit 1];
        
        Id Operational = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        Id Implementation = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        
        Contract__c contract1 = TestDataFactory.CreateAgreement(account1.Id, user1.Id, Operational);
        ContractList.add(contract1);
        insert ContractList;
        ownerList.add(user1.Email);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContractTriggerhandler_Mock.usernotfound_MOCK());
        //ContractTriggerhandler.NewOwnerForMSTeam(ownerList, account1.SPGroupID__c, '');
        
        Test.stopTest();
        
    }
    /*---------------------------------------------------------------------------------------------------------------------------------
Method Name:    testFilterContractsByAccount and testSendErrorMail
Description:    For testing FilterContractsByAccount() and testSendErrorMail method of ContractTriggerHandler . 
Inputs:         contracts in FilterContractsByAccount() Method
Notes:          Please add comments on Line if anyone update the code with Respected Name, Date, Reason.
<Date>          <Authors Name>      Modification Reason 
March 2023      Akshay                  -   

----------------------------------------------------------------------------------------------------------------------------------*/
    @isTest
    static void testSendErrorMail() { 
        Test.startTest();
        ContractTriggerhandler.sendErrorMail('Test Subject', 'Test Body', 'Test Type');
        Test.stopTest(); 
    }
    
    @isTest
    public static void testFilterContractsByAccount() {
        List<Contract__c> contracts = new List<Contract__c>();
        
        Account account1 = TestDataFactory.createAccount('Java Teams', 'NO - Norge');
        insert account1;
        
        Account account2 = TestDataFactory.createAccount('Java', 'NO - Norge');
        insert account2;
        
        Contract__c contract1 = new Contract__c(Account__c = account1.Id);
        contracts.add(contract1);
        
        Contract__c contract2 = new Contract__c(Account__c = account2.Id);
        contracts.add(contract2);
        
        Contract__c contract3 = new Contract__c(Account__c = account2.Id);
        contracts.add(contract3);
        
        Map<String, Object> accountMap = ContractTriggerhandler.FilterContractsByAccount(contracts);
        
        System.assertEquals(2, accountMap.size());
        System.assertEquals(1, ((List<Contract__c>) accountMap.get(account1.Id)).size());
        System.assertEquals(2, ((List<Contract__c>) accountMap.get(account2.Id)).size());
    }
    

    
    @isTest
    static void testAddCustomlogTeamsCreation() {
        // Prepare test data
        Integer statusCodeTeam = 200;
        String statusMessage = 'Success';
        String responseBody = '{"message":"Teams created successfully.","isSuccess":true,"statusCode":200,"jsonResponse":[{"email":"team1@example.com","isTeamCreated":true,"url":"https://example.com/teams/team1","groupId":"12345"}]}';
        String accountID = '001000000000000';
        Boolean IsMSTeamCreated = true;
        
        // Call the method to be tested
        Test.startTest();
        String result = CreateCustomLogHandler.addCustomlogTeamsCreation(statusCodeTeam, statusMessage, responseBody, accountID, IsMSTeamCreated);
        Test.stopTest();
        
        // Verify the result
        System.assertEquals('Create log sucessfully', result);
        
        // Verify that a Log__c record was inserted
        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(1, logs.size());
    }
    
    @isTest
    static void testAddCustomlogUserManagement() {
        // Prepare test data
        Integer statusCode = 200;
        String statusMessage = 'Success';
        String responseBody = '{"message":"User created successfully.","isSuccess":true,"statusCode":200,"data":{"groupId":"12345"}}';
        
        // Call the method to be tested
        Test.startTest();
        CreateCustomLogHandler.addCustomlogUserManagement(responseBody, statusCode, statusMessage,'12345');
        Test.stopTest();
        
        // Verify that a Log__c record was inserted
        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(1, logs.size());
    }
    
    @isTest
    static void testAddCustomlogAccountNameChange() {
        // Prepare test data
        Integer statusCode = 200;
        String statusMessage = 'Success';
        String responseBody = '{"message":"Account name changed successfully.","isSuccess":true,"statusCode":200,"data":{"accountId":"001000000000000","newAccountName":"New Account Name"}}';
        String spgroupid= '31cc3785-5841-48e6-8a67-a079658ae6b3';
        // Call the method to be tested
        Test.startTest();
        CreateCustomLogHandler.addCustomlogAccountNameChange(responseBody, statusCode, statusMessage,spgroupid);
        Test.stopTest();
        
        // Verify that a Log__c record was inserted
        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(1, logs.size());
    }    
    
    
       @isTest
    static void testExecute() {
        
        // Create test data
        Account testAccount = new Account(Name = 'Test Account',Country2__c='NO - Norge');
        insert testAccount;
        Map<Id, String> accountOwnerMap = new Map<Id, String>();
        accountOwnerMap.put(testAccount.Id, 'Test Owner');
        
        // Create a new instance of the class
        ContractTriggerhandlerInsertSchedule schedule = new ContractTriggerhandlerInsertSchedule(accountOwnerMap);
        
        // Call the execute method
        Test.startTest();
        String jobId = System.schedule('Test Job', '0 0 * * * ?', schedule);
        Test.stopTest();

    }
    
}