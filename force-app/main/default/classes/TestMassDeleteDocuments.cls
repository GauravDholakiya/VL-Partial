@isTest
public class TestMassDeleteDocuments {
    @testSetup
    static void setup() {
        TestDataFactory.setTestData();
       	Account account = TestDataFactory.createAccount('TestAccount', 'NO - Norge');
        insert account;
        
        Task task= new Task();
        task.WhatId = account.Id;
        insert task;
        List<contentVersion> versions = new List<contentVersion>();            
        for(Integer i = 0; i < 5; i++){
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document' +i;
            cv.PathOnClient = 'TestDocument'+i+'.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            cv.FirstPublishLocationId = account.Id;
            cv.IsDeleted__c = true;
            Insert cv;
        }
        insert versions;
      /*	List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.debug(cdList.size());*/
    }
    @isTest static void test() {
        Test.startTest();
        MassDeleteDocuments docs = new MassDeleteDocuments();
        Id batchId = Database.executeBatch(docs);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(0, [select count() from ContentDocument]);
    }
}