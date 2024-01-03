/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         AccountTriggerHandlerTest.cls 
Description:  Test class for Account Rename.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
Aug 2019         0.1         Parthesh                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

@isTest
public class AccountTriggerHandlerTest {
    
    @isTest
    public static void renameAccountName()
    {
        AzureAD_Credential__c azureCred = new AzureAD_Credential__c();
        azureCred.SPSiteURL__c = 'https://viewledger.sharepoint.com/sites/';
        azureCred.ClientSecretKey__c = 'nKMW14fTI[zDe4VHzG/1aTewlgGhWy:*';
        azureCred.Scope__c = 'https://graph.microsoft.com/.default';
        azureCred.ClientId__c = 'c4b8767b-d3ec-4bae-b8ee-3a5eb4e8e2cc';
        azureCred.GrantType__c = 'client_credentials';
        azureCred.MicrosoftGraphURL__c = 'https://graph.microsoft.com/v1.0/';
        azureCred.VTIID__c = 'd42d9454-d843-4f93-b99c-a08c7d87e6fa';
        azureCred.ComplianceID__c = '15e55f98-e3c7-4313-b989-a929b29d120e';
        azureCred.TokenUrl__c = 'https://login.microsoftonline.com/987d5b59-8ee7-4939-ab38-b720e9d085d7/oauth2/v2.0/token';
        azureCred.AdminUser__c = 'elena.gorder@viewledger.com';
        azureCred.MSTeamsprefix__c = 'VCD-';
        azureCred.Salesforce_ClientId__c='3MVG9fTLmJ60pJ5KzQlZMIBy5QycLczRL6igy2hMVlcwJAInHEajCT7l_uZG3ldbeMRC_.u5yhKniiTQW9mco';
        azureCred.Salesforce_ClientSecret__c='0672912EBEC863C1099DD7673F114B569433345DF6C4484DF9327B6D0BBC7DED';
        insert azureCred;
        
        String responseBody = '{ "statusCode": 200, "message": "Success", "data": { "newSiteUrl": "example.com", "newnickName": "Example", "newEmail": "example@example.com" } }';
        
        
        List<Account> accLST = new List<Account>();
        For(Integer i = 10 ; i < 110 ; i++)
        {
            Account acc01 = new Account();
            acc01.Name = 'Java Team ' + i;
            acc01.IsMSTeamCreated__c = true;
            
            accLST.add(acc01);
        }
        Database.Insert(accLST,false); 
        
        List<Account> aLST = [Select Name From Account];
        List<Account> updateAcc = new List<Account>();
        For(Account acc : aLST)
        {
            acc.Name = 'New ' + acc.Name;
            updateAcc.add(acc);
        }
        
        Database.Update(updateAcc,false);
        Account acc = new Account();
        acc.Name='Test 118 JP AS';
        acc.SPGroupID__c='13b3e9ef-e6b6-4528-8156-15df1c5afdbe';
        acc.Country2__c='NO - Norge';
        
        insert acc;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new ContractTriggerhandler_Mock.CreateTeamSiteHelper_Mock());
        AccountTriggerhandler.updateAccountNameToO365Group(acc.Name,acc.SPGroupID__c);
        
        Test.stopTest();
    }
    
   
    @isTest
    static void testRenameMSTeamsTitle() {
        
         AzureAD_Credential__c azureCred = new AzureAD_Credential__c();
        azureCred.SPSiteURL__c = 'https://viewledger.sharepoint.com/sites/';
        azureCred.ClientSecretKey__c = 'nKMW14fTI[zDe4VHzG/1aTewlgGhWy:*';
        azureCred.Scope__c = 'https://graph.microsoft.com/.default';
        azureCred.ClientId__c = 'c4b8767b-d3ec-4bae-b8ee-3a5eb4e8e2cc';
        azureCred.GrantType__c = 'client_credentials';
        azureCred.MicrosoftGraphURL__c = 'https://graph.microsoft.com/v1.0/';
        azureCred.VTIID__c = 'd42d9454-d843-4f93-b99c-a08c7d87e6fa';
        azureCred.ComplianceID__c = '15e55f98-e3c7-4313-b989-a929b29d120e';
        azureCred.TokenUrl__c = 'https://login.microsoftonline.com/987d5b59-8ee7-4939-ab38-b720e9d085d7/oauth2/v2.0/token';
        azureCred.AdminUser__c = 'elena.gorder@viewledger.com';
        azureCred.MSTeamsprefix__c = 'VCD-';
        insert azureCred;
        
        // Create test accounts
        Account acc1 = new Account(Name = 'Test Account 1', IsMSTeamCreated__c = true,Country2__c='NO - Norge');
        Account acc2 = new Account(Name = 'Test Account 2', IsMSTeamCreated__c = false,Country2__c='NO - Norge');
        insert new List<Account>{acc1, acc2};
            
            acc1.name = 'Test1';
         update acc1;
        
            
            // Call the method under test
            Test.startTest();
       // AccountTriggerhandler.renameMSTeamsTitle(newMap, oldMap);
        Test.stopTest();
        
        // Verify that the accounts were updated
       acc1 = [SELECT Name, IsMSTeamCreated__c FROM Account WHERE Id = :acc1.Id];
  
        System.assertEquals('Test1', acc1.Name);
   
    }
  
}