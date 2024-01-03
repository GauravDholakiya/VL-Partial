@isTest
public class SharepointWidgetController_Test {
    
    
    @testSetup static void setup() {
        
        TestDataFactory.setTestData();
        User user = [select id from User where email='marika.finseth12@viewledger.com']; 
        Account account = TestDataFactory.createAccount('TestAccount', 'NO - Norge');
        insert account;
        
        Task task= new Task();
        task.WhatId = account.Id;
        insert task;
        
        account = TestDataFactory.createAccountWithActiveMsTeams('TestAccount Active MsTeams', 'NO - Norge');
        account.SiteURL__c = 'https://viewledger.sharepoint.com/sites/SBOX_VCD-AccountTest1Sandbox';
        insert account;
        
        account = TestDataFactory.createAccountWithActiveWidget('TestAccount Active Widget', 'NO - Norge');
        account.SiteURL__c = 'https://viewledger.sharepoint.com/sites/SBOX_VCD-AccountTest2Sandbox';
        insert account;
        
        task= TestDataFactory.createTask(account.id);
        insert task;
        
        ContentVersion contentVersion = TestDataFactory.createContentVersion('Test File Norway',account.Id);
        insert contentVersion;  
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.debug('documents : '+documents);
        
        ContentDocumentLink contentlink= TestDataFactory.createContentDocumentLink(documents[0],user.id);
        insert contentlink;
        
        contentlink= TestDataFactory.createContentDocumentLink(documents[0],task.id);
        insert contentlink;
        
        Document document = TestDataFactory.createDocument('Test File Norway');
        insert document;
    }
    
    
    @isTest public static void test(){
        
        
        
        Account account1=[Select Id from Account Where Name='TestAccount Active MsTeams' Limit 1];
        Account account2=[Select Id from Account Where Name='TestAccount Active Widget' Limit 1];
        
        AuraFileUploadTracker__c existingRecord = new AuraFileUploadTracker__c(AccountId__c = account1.Id);
        insert existingRecord;
     
        Task task=[Select Id from Task  where Account__c!=null Limit 1];
        Task task2=[Select Id,Account__c from Task where Account__c=null Limit 1];
        list<ContentDocument> ContentDocumentList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentVersion> contentVersions = [SELECT Id,ContentDocumentId,IsDeleted__c FROM ContentVersion Where ContentDocumentId IN :ContentDocumentList];
         List<ContentVersion> contentVersionsToUpdate = [SELECT Id,ContentDocumentId,IsDeleted__c FROM ContentVersion Where IsDeleted__c = true];
        List<Map<string,string>> docIdNameList = new List<Map<String,string>>();
        Map<string,string> DocumentDetailsMap;
        List<String> docslist;
        for(ContentDocument contentDocument :ContentDocumentList ){
            docslist = new List<String>();
            DocumentDetailsMap =  new Map<string,string>();
            DocumentDetailsMap.put('DocContentId',contentDocument.Id);
            DocumentDetailsMap.put('fileName',contentDocument.Title);
            docIdNameList.add(DocumentDetailsMap);
            docslist.add(contentDocument.Id);
        }
        
        system.debug('task2 : '+task2.Account__c);
        String requirefields='[{"Personal_Data":"Yes"},{"Document_Classification":"Project Document|5565bd41-042a-4905-95ae-d0c1f49f8448;"}]';
       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SharepointWidgetController_MockTest());
        SharepointWidgetController.fetchGettermStore('Document');
        SPTokenController.GetToken();
        
      
        SharepointWidgetController.getAllDocuments(account1.Id,  '', '','0dbb13e5-88e3-4e07-bda4-d559bd20ccf8');
        SharepointWidgetController.getAllDocuments(account2.Id,  '', '','');
        
        SharepointWidgetController.getAllDocuments(task.Id,  '', '','0dbb13e5-88e3-4e07-bda4-d559bd20ccf8');
        SharepointWidgetController.getAllDocuments(task.Id,  'ASC', 'Name','0dbb13e5-88e3-4e07-bda4-d559bd20ccf8');
        SharepointWidgetController.getAllDocuments(task2.Id,  'ASC', 'Name','0dbb13e5-88e3-4e07-bda4-d559bd20ccf8');
        SharepointWidgetController.getAllDocuments(task2.Id,  '', '','');
        
        SharepointWidgetController.searchdocuments(String.valueOf(account1.Id),'project');
        
        Map<string,string> savefilemap = SharepointWidgetController.saveTheFiles(String.valueOf(account1.Id),docIdNameList,'0x010100671DD7693448CE46ACE9EC9AF942AA660101010100DDDF6247B0540642B9C68539431AAAFD,Test File Norway',false, requirefields,string.valueOf(account1.id));
        Map<string,string> savefilemapTask = SharepointWidgetController.saveTheFiles(String.valueOf(account1.Id),docIdNameList,'0x010100671DD7693448CE46ACE9EC9AF942AA660101010100DDDF6247B0540642B9C68539431AAAFD,Test File Norway',false, requirefields,string.valueOf(task.id));
        
        Map<string,string> savefilemapAccountIsUpload = SharepointWidgetController.saveTheFiles(String.valueOf(account1.Id),docIdNameList,'0x010100671DD7693448CE46ACE9EC9AF942AA660101010100DDDF6247B0540642B9C68539431AAAFD,Test File Norway',true, requirefields,string.valueOf(account1.id));
        Map<string,string> savefilemapTaskIsUpload = SharepointWidgetController.saveTheFiles(String.valueOf(account1.Id),docIdNameList,'0x010100671DD7693448CE46ACE9EC9AF942AA660101010100DDDF6247B0540642B9C68539431AAAFD,Test File Norway',true, requirefields,string.valueOf(task.id));
        Object  CheckIfFilesExistsInSharepoint = SharepointWidgetController.CheckIfFilesExistsInSharepoint(String.valueOf(account1.Id),docIdNameList);
       
        List<AuraFileUploadTracker__c> todaysRecords = [SELECT Id, AccountId__c FROM AuraFileUploadTracker__c WHERE CreatedDate = TODAY];
		
        SharepointWidgetController.DeleteFilesFromSalesforce(docslist);
        SharepointWidgetController.UpdateIsDeletedTrue(docslist);
        SharepointWidgetController.CreateRecord(account1.id);
        System.assertEquals(1, todaysRecords.size(), 'Expected only one record to be created today');
        Test.stopTest();
    }
    @isTest public static void CreateRecordTest()
     {
       Account testAccount = new Account(Name = 'Test Account');
          Account account = [select ID,name from account limit 1];
      
     
         AuraFileUploadTracker__c existingRecord = new AuraFileUploadTracker__c(AccountId__c = account.Id, CreatedDate = Date.today());
        insert existingRecord;
         SharepointWidgetController.CreateRecord(testAccount.id);
        
          List<AuraFileUploadTracker__c> todaysRecords = [SELECT Id, AccountId__c FROM AuraFileUploadTracker__c WHERE CreatedDate = TODAY];
         
        System.assertEquals(2, todaysRecords.size(), 'Expected two records to be created today');
        Set<String> accountIdSet = new Set<String>();
        for (AuraFileUploadTracker__c record : todaysRecords) {
            accountIdSet.add(record.AccountId__c);
        }
        System.assertEquals(true, accountIdSet.contains(testAccount.Id), 'Expected new record to be created for the test account');
         
     }
   @isTest static void testFetchGettermStore() { 
        Termset__c ts = new Termset__c(Name = 'Test Termset', Guid__c = 'abc123'); 
       insert ts; // Test case with exception 
       Test.startTest(); 
        List<object> result = SharepointWidgetController.fetchGettermStore('Non-existent Termset'); 
       Test.stopTest(); 
        System.assert(result == null, 'Result should be null when termstore not found'); // Test case without exception 
       
        }
}