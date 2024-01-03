@isTest
public class AccountecSchedulableTest {

    @testSetup 
    Public static void setup(){
        List<Account> listOfAccount=new List<Account>();
       // listOfAccount.add(new Account(Name='BRTEST17' ,Country2__c='SE - Sweden', Firm__c='VIEW Ledger AB', Org_Number__c='652727-7628', SiteURL__c='test', TeamEmail__c='testt', CustomerChannelURL__c='test', Accounting_Channel_URL__c='test', Payroll_Channel_URL__c='test'));
       // Test data for create method
        listofAccount.add(new Account(Name='BRTEST17' ,Country2__c='SE - Sweden', Firm__c='VIEW Ledger AB', Org_Number__c='6527277628', SiteURL__c='test', TeamEmail__c='testt', CustomerChannelURL__c='test', Accounting_Channel_URL__c=null, Payroll_Channel_URL__c=null, SPGroupID__c='test12'));
        listofAccount.add(new Account(Name='BRTEST20' ,Country2__c='SE - Sweden', Firm__c='VIEW Ledger AB', Org_Number__c='652727-7634', SiteURL__c='test', TeamEmail__c='testt', CustomerChannelURL__c='test', Accounting_Channel_URL__c=null, Payroll_Channel_URL__c=null, SPGroupID__c='test12'));
       // Test data for delete method 
        listOfAccount.add(new Account(Name='BRTEST18' ,Country2__c='SE - Sweden', Firm__c='VIEW Ledger AB', Org_Number__c='652727-7629', Deactivated__c=false, Accountec_UUID__c='e441461b-b6be-4cce-8279-ff962097c447', SiteURL__c='test', TeamEmail__c='testt', CustomerChannelURL__c='test', Accounting_Channel_URL__c='test', Payroll_Channel_URL__c='test'));
        listOfAccount.add(new Account(Name='BRTEST22' ,Country2__c='SE - Sweden', Firm__c='VIEW Ledger AB', Org_Number__c='652727-7632', Deactivated__c=false, Accountec_UUID__c='h441461b-b6be-4cce-8279-ff962097c449', SiteURL__c='test', TeamEmail__c='testt', CustomerChannelURL__c='test', Accounting_Channel_URL__c='test', Payroll_Channel_URL__c='test'));
       // Test data for update method 
        listofAccount.add(new Account(Name='BRTEST19' ,Country2__c='SE - Sweden', Firm__c='VIEW Ledger AB', Org_Number__c='652727-7630', SiteURL__c='test', TeamEmail__c='testt', Accountec_UUID__c='e441461b-b6be-4cce-8279-ff962097c447', Field_UUID__c='2ca7eb67-9f24-438b-b88d-cde2849b685f', CustomerChannelURL__c='test', Accounting_Channel_URL__c='test', Payroll_Channel_URL__c='test', MailNickName__c='testnew'));
        listofAccount.add(new Account(Name='BRTEST21' ,Country2__c='SE - Sweden', Firm__c='VIEW Ledger AB', Org_Number__c='652727-7631', SiteURL__c='test', TeamEmail__c='testt', Accountec_UUID__c='f441461b-b6be-4cce-8279-ff962097c448', Field_UUID__c='3ca7eb67-9f24-438b-b88d-cde2849b685g', CustomerChannelURL__c='test', Accounting_Channel_URL__c='test', Payroll_Channel_URL__c='test', MailNickName__c='testnew'));
        
        insert listOfAccount;
        
        //Custom Setting
        APIAccountec__c customsetting = new APIAccountec__c();
		customsetting.Name = 'Accountec Credentials';
		customsetting.BaseURL__c = 'TestBaseURL';
        customsetting.Secret__c='TestSecretKey';
        customsetting.ValidUntil__c=String.valueOf(System.now()+1);
        customsetting.RefreshToken__c='TestRefreshToken';
        customsetting.AccessToken__c='TestAccessToken';
		insert customsetting;
    }
    @isTest
    Public static void AccountecSchedulableInsertTest(){
        List<Account> listOfAccountTest1=[select Id, Name, Org_Number__c from Account where Name='BRTEST17' OR Name='BRTEST20'];
        
        AccountecSchedulable accountecSchedulable=new AccountecSchedulable(listOfAccountTest1, 'Insert');
        Test.startTest();
        HttpMockFactory accounttecMockTest1=new HttpMockFactory(200, 'Good', '{"uuid": "e441461b-b6be-4cce-8279-ff962097c446","name": "'+listOfAccountTest1.get(0).Name+'","orgNr": "'+listOfAccountTest1.get(0).Org_Number__c+'","access": {"documents": true,"expenses": false,"tickets": true},"fields": [],"isScreening": false,"lastActivityAt": "2023-09-19 08:16:01","createdAt": "2023-09-19 08:16:01"}');
        Test.setMock(HttpCalloutMock.class, accounttecMockTest1);
        HttpMockFactory accounttecMockTest2=new HttpMockFactory(200, 'Good', '{"uuid": "d441461b-b6be-4cce-8279-ff962097c447","name": "'+listOfAccountTest1.get(1).Name+'","orgNr": "'+listOfAccountTest1.get(1).Org_Number__c+'","access": {"documents": true,"expenses": false,"tickets": true},"fields": [],"isScreening": false,"lastActivityAt": "2023-09-19 08:16:01","createdAt": "2023-09-19 08:16:01"}');
        Test.setMock(HttpCalloutMock.class, accounttecMockTest2);
        string JobId=System.schedule('Message', '12 0 * * * ?', accountecSchedulable);
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
       // assert.areEqual('2042-09-03 03:12:12',ct.TimesTriggered,'Error');
        
    }
    
    @isTest
    Public static void AccountecSchedulableDeleteTest(){
        List<Account> listOfAccountTest1=[select Id, Name, Org_Number__c from Account where Name='BRTEST18' OR Name='BRTEST22'];
        
        AccountecSchedulable accountecSchedulable=new AccountecSchedulable(listOfAccountTest1, 'Delete');
        HttpMockFactory accounttecMock=new HttpMockFactory(200, 'Good',' ');
        Test.setMock(HttpCalloutMock.class, accounttecMock);
        Test.startTest();
        string JobId=System.schedule('Message', '0 45 * * * ?', accountecSchedulable);
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
        //assert.areEqual('2042-09-03 05:45:00',ct.TimesTriggered,'Error'); 
    }
    
    @isTest
    Public static void AccountecSchedulableDeleteWithExpiredCustomSettingsTest(){
        List<Account> listOfAccountTest1=[select Id, Name, Org_Number__c from Account where Name='BRTEST18' OR Name='BRTEST22'];
        APIAccountec__c act = APIAccountec__c.getValues('Accountec Credentials');
        act.ValidUntil__c='2023-09-22T07:16:01Z';
        update act;
        AccountecSchedulable accountecSchedulable=new AccountecSchedulable(listOfAccountTest1, 'Delete');
        HttpMockFactory accounttecMock=new HttpMockFactory(200, 'Good',' ');
        Test.setMock(HttpCalloutMock.class, accounttecMock);
        Test.startTest();
        string JobId=System.schedule('Message', '0 45 * * * ?', accountecSchedulable);
        Test.stopTest();
         
    }
    
    @isTest
    Public static void AccountecSchedulableUpdateTest(){
        List<Account> listOfAccountTest1=[select Id, Name, Org_Number__c from Account where Name='BRTEST19' OR Name='BRTEST21'];
        AccountecSchedulable accountecSchedulable=new AccountecSchedulable(listOfAccountTest1, 'Update');
        HttpMockFactory accounttecMockTest1=new HttpMockFactory(200, 'Good', '{"uuid":"2ca7eb67-9f24-438b-b88d-cde2849b685f","field":"Other","value":"test * test","createdAt":"2023-09-22","updatedAt":"2023-09-22"}');
        Test.setMock(HttpCalloutMock.class, accounttecMockTest1);
        HttpMockFactory accounttecMockTest2=new HttpMockFactory(200, 'Good', '{"uuid":"3ca7eb67-9f24-438b-b88d-cde2849b685g","field":"Other","value":"test * test","createdAt":"2023-09-22","updatedAt":"2023-09-22"}');
        Test.setMock(HttpCalloutMock.class, accounttecMockTest2);
        Test.startTest();
        string JobId=System.schedule('Message', '0 45 * * * ?', accountecSchedulable);
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
       // assert.areEqual('2042-09-03 05:45:00',ct.TimesTriggered,'Error');
        
    }
    
    
}