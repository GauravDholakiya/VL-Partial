@isTest
public class TestDataFactory {
    
    public static void SetupCustomSettingsData(){
        
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
        azureCred.SPServiceAccount__c ='service@viewledger.com';
        insert azureCred;
        
        SharepointCredentialsInfo__c spcredentials = new SharepointCredentialsInfo__c();
        spcredentials.ClientId__c='cd48e79e-cb2a-4355-9238-d6ef9bc67892b';
        spcredentials.ClientSecret__c='Sa785S7eTS0AuUlsvlFXGBAtOkh1XbnH24DmtuZKui4=';
        spcredentials.GrantType__c='client_credentials';
        spcredentials.Principal__c='00000003-0000-0ff1-ce00-000000000000';
        spcredentials.realm__c='156c7a45-e98b-4b0d-a7ff-72201bcfreui';
        spcredentials.resource__c='00000003-0000-0ff1-ce00-000000000000/binaryrepublik516.sharepoint.com@156c7a45-e98b-4b0d-a7ff-72201bcfreui';
        spcredentials.SharepointTokenURL__c='https://accounts.accesscontrol.windows.net/156c7a45-e98b-4b0d-a7ff-72201bcfreui/tokens/OAuth/2';
        spcredentials.timezone__c='America/Los_Angeles';
        insert spcredentials;
        
        Termset__c termset= new Termset__c();
        termset.Name ='Document';
        termset.Guid__c ='c4b8767b-d3ec-4bae-b8ee-3a5eb4e8e2cc';
        insert termset;
        
        termset= new Termset__c();
        termset.Name ='Main_account';
        termset.Guid__c ='d42d9454-d843-4f93-b99c-a08c7d87e6fa';
        insert termset;
        
        TermStoreAPI__c tsa = new TermStoreAPI__c();
        tsa.URL__c ='https://viewledgerterms.azurewebsites.net';
        insert tsa;
        
        MSTeamsOwnersRoles__c MSOwnerRoles = new MSTeamsOwnersRoles__c();
        MSOwnerRoles.ListOwners__c ='Oppdragsansvarlig,Account Owner,Project_Manager';
        insert MSOwnerRoles;
        
        ExternalWebAPI__c uploadfileurl = new ExternalWebAPI__c();
        uploadfileurl.Url__c = 'https://viewledgerterms.azurewebsites.net/api/FileShare';
        uploadfileurl.Fetch_TermStore__c = 'https://viewledgerterms.azurewebsites.net/api/FileShare/GetTerms';
        uploadfileurl.CreateNewFile__c = 'https://viewledgerterms.azurewebsites.net/api/CreateNewFile';
        uploadfileurl.Upload_File__c = 'https://viewledgerterms.azurewebsites.net/api/UploadFile';
        uploadfileurl.Update_Item_Author__c = 'https://viewledgerterms.azurewebsites.net/api/UpdateItemAuthor';
        insert uploadfileurl;
        
    }
    public static Id createUser(string profileName,string username,string userEmail,string FirstName,string LastName){
        
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name =:profileName].Id,
            LastName =LastName,
            FirstName =FirstName,
            Email = userEmail,
            Username = username,
            CompanyName = 'TEST',
            Title = 'title',
            Alias = (FirstName+LastName).substring(0, 7),
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user;
        return user.Id;
        
    }
    
    public static Account createAccount(string AccountName,string countryname) {
        Account account = new Account();
        account.Name = AccountName;
        account.Country2__c = countryname;
        account.Firm__c='View Ledger AS';
        // insert account;
        return account;
    }
    public static Account createAccountWithActiveMsTeams(string AccountName,string countryname) {
        Account account = new Account();
        account.Name = AccountName;
        account.Country2__c = countryname;
        account.IsMSTeamCreated__c =true;
        account.MailNickName__c='VCD-'+AccountName;
        account.Org_Number__c='123';
        account.Project_Number_Operational__c='10';
        account.Firm__c='View Ledger AS';
        account.SPGroupID__c = 'da3e84b5-1875-45c5-b5e3-c6a23a3517ab';
        return account;
    }
    public static Account createAccountWithActiveWidget(string AccountName,string countryname) {
        Account account = new Account();
        account.Name = AccountName;
        account.Country2__c = countryname;
        account.IsMSTeamCreated__c =true;
        account.isWidgetActive__c =true;
        account.SPGroupID__c = 'da3e84b5-1875-45c5-b5e3-c6a23a3517ab';
        account.MailNickName__c='VCD-'+AccountName;
        account.Org_Number__c='123';
        account.Project_Number_Operational__c='10';
        account.Firm__c='View Ledger AS';
        return account;
    }
    
    public static Contract__c CreateAgreement(Id Accountid,Id ownerId, Id RecordTypeId){
        
        Contract__c Agreement = new Contract__c();
        Agreement.Account__c = Accountid;
        Agreement.RecordTypeId = RecordTypeId;
        Agreement.OwnerId = ownerId;
        Agreement.Status__c = 'Draft';
        Agreement.Account_Owner_KA__c =ownerId;
        
        // insert Agreement;
        return Agreement;
        
    } 
    public static Contract__c updateAgreement(Id agreementid,Id ownerId){
        
        Contract__c Agreement = new Contract__c(Id= agreementid);
        Agreement.OwnerId = ownerId;
        Agreement.Status__c = 'Draft';
        //update Agreement;
        return Agreement;
        
    }
    
    
    public static List<Contract__c> CreateAgreementWithAccount(Integer NumberOfContract,Id Accountid,Id ownerId,Id RecordTypeId){
        List<Contract__c> returnContractList = new List<Contract__c>();
        for(integer i=0; i<NumberOfContract;i++){
            returnContractList.add(CreateAgreement(Accountid,ownerId,RecordTypeId));
        }
        return returnContractList;
    }
    
    
    public static Task createTask(Id Accountid){
        Task task= new Task();
        task.Period__c=3;
        task.Task_Number__c=123;
        task.WhatId = Accountid;
        task.Account__c =Accountid;
        return task;
    }
    
    public static contentVersion createContentVersion(string Title,Id AccountId){
        
        ContentVersion contentVersion = new ContentVersion(
            Title = Title,
            PathOnClient = Title,
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            FirstPublishLocationId = AccountId,
            IsDeleted__c = false
        );
        return contentVersion;
        
    }
    
    public static ContentDocumentLink createContentDocumentLink(ContentDocument document,Id LinkedEntityId){
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=LinkedEntityId;
        contentlink.ContentDocumentId=document.Id;
        contentlink.Visibility = 'AllUsers'; 
        contentlink.ShareType= 'V';
        return contentlink;
    }
    
    public static Document createDocument(string documentName){
        Document document = new Document();
        string userid = UserInfo.getUserId();
        document.Body=Blob.valueof('Some random String');
        document.Name='Test File Norway';
        document.FolderId=userid;
        return document;
    }
    
    
    public static Account_Team_And_Authorizations__c Create_Account_Team_And_Authorizations(Id contractId,string Area,string Area_Type,Id Responsible_User){
        
        Account_Team_And_Authorizations__c ATAA = new Account_Team_And_Authorizations__c();
        ATAA.Kontrakt__c = contractId;
        ATAA.Area__c = Area;
        ATAA.Type__c = Area_Type;
        ATAA.Responsible__c= Responsible_User; 
        ATAA.CheckUniqueType__c = '001Account_Owner';
        return ATAA;
    }
    
    public static Termset__c createTermset(){
        Termset__c testTermset = new Termset__c(Name='Document_Classification', Guid__c='b96aecbd-3eae-4435-97f7-86aa793686f8');
        insert testTermset;
        return testTermset;
    }
    
    public static AzureAD_Credential__c createAzurecredential(){
        AzureAD_Credential__c credential = new AzureAD_Credential__c();
        credential.DevAPIEndPoint__c='https://devviewledgerapi.azurewebsites.net/';
        credential.ClientId__c='c4b8767b-d3ec-4bae-b8ee-3a5eb4e8e2cc';
        credential.ClientSecretKey__c='nKMW14fTI[zDe4VHzG/1aTewlgGhWy:*';
        insert credential;
        return credential;
    }
    
    public static Account createAccount(){
        Account ac= new account();
        ac.name='Test';
        ac.IsMSTeamCreated__c =true;
        ac.isWidgetActive__c =true;
        ac.MailNickName__c=null;
        ac.Country2__c='NO - Norge';
        
        insert ac;
        return ac; 
    }
    public static Account createAccountcountry(){
        Account ac= new account();
        ac.name='Test1';
        ac.IsMSTeamCreated__c =true;
        ac.isWidgetActive__c =true;
        ac.MailNickName__c=null;
        ac.Country2__c='NO - Norge';
        
        insert ac;
        return ac; 
    }
    public static User createUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            
            UserName='userName53672822'+'@testorg.com'
        );
        insert u;
        return u;
    }
    public static Account createAccount4(){
        Account ac= new account();
        ac.name='Test';
        ac.IsMSTeamCreated__c =true;
        ac.isWidgetActive__c =false;
        ac.Country2__c='NO - Norge';
        insert ac;
        return ac; 
    }
    public static Task createTask(){
        Account ac= new account();
        ac.name='Test';
        ac.IsMSTeamCreated__c =true;
        ac.isWidgetActive__c =true;
        
        insert ac;
        
        Task testTask = new Task(); 
        testTask.WhatId = ac.Id; 
        insert testTask;
        return testTask;
    }
    public static Task createTaskCountry(){
        Account ac= new account();
        ac.name='Test1';
        ac.IsMSTeamCreated__c =true;
        ac.isWidgetActive__c =true;
        ac.Country2__c='NO - Norge';
        
        insert ac;
        
        Task testTask = new Task(); 
        testTask.WhatId = ac.Id; 
        insert testTask;
        return testTask;
    }
    
    
    public static Task createTask4(){
        Account ac= new account();
        ac.name='Test';
        ac.IsMSTeamCreated__c =true;
        ac.isWidgetActive__c =false;
        ac.Country2__c='NO - Norge';
        insert ac;
        
        Task testTask = new Task(); 
        testTask.WhatId = ac.Id; 
        insert testTask;
        return testTask;
    }
    
    @isTest
    
    public static void setTestData(){
        
        SetupCustomSettingsData();
        User unitUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( unitUser ) {
            createUser('System Administrator', 'hozan.abdulla12@viewledger.com', 'hozan.abdulla12@viewledger.com', 'hozan', 'abdulla');
            createUser('System Administrator', 'marika.finseth12345@viewledger.com', 'marika.finseth12345@viewledger.com', 'marika1', 'finseth1');
            createUser('System Administrator', 'Test.User@viewledger.com', 'Test.User@viewledger.com', 'Test', 'User');
            createUser('System Administrator', 'piyush1@binaryrepublik.com', 'piyush1@binaryrepublik.com', 'piyush1', 'Patel1');
        }
    }
    
}