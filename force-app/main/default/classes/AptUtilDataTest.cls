/**
 * @author Jozef
 * @date 4.9.2019.
 * @description //TODO
 */

@IsTest
public class AptUtilDataTest {

    public class DatePeriod{
        public Date periodDate {get; set;}
        public Integer period {get; set;}
        public DatePeriod(Date periodDate,Integer period){
            this.periodDate = periodDate;
            this.period = period;
        }
    }

    @testSetup public static void setup() {
        // Create common test users
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

        MSTeamsOwnersRoles__c MSOwnerRoles = new MSTeamsOwnersRoles__c();
        MSOwnerRoles.ListOwners__c ='Account_Owner,Payroll_Responsible,Authorized Accountant';
        insert MSOwnerRoles;
    }

    @IsTest
    public static void createAccountTest(){
        createAccount('NO - Norge');
    }

    public static Account createAccount(String country){
        Account acc = getAccount();
        acc.Country2__c = country;

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.insert(acc, dml);

        return acc;
    }


    private static Account getAccount(){
        Account acc = new Account();
        acc.Name = 'Task Manager Account Test';
        acc.Firm__c = 'View Ledger AS';
        acc.Country2__c = 'NO - Norge';
        acc.IsMSTeamCreated__c = true;
        acc.SPGroupID__c = 'da3e84b5-1875-45c5-b5e3-c6a23a3517ab';
        return acc;
    }

    @IsTest
    public static Account createAccount(){
        Account acc = getAccount();

        insert acc;
        return acc;
    }

    public static Contract__c getContract(Account acc) {
        RecordType rt = [SELECT
                DeveloperName,
                Id,
                IsActive,
                Name,
                SobjectType
        FROM RecordType WHERE SobjectType = 'Contract__c' AND DeveloperName = 'Operational'];

        Contract__c con = new Contract__c();
        con.AccessToBankAccount__c= null;
        con.Account__c = acc.id;
        //con.Account_Owner_KA__c = null;
        con.CustomerResponsibleAndRemittanceResp__c = UserInfo.getUserId();
        con.Bank_Account__c = null;
        con.Business_Area__c = null;
        con.CertifiedAccountant__c = UserInfo.getUserId();
        con.ContractEndDate__c = System.today().addDays(5);
        con.Contract_Format__c = null;
        //con.ContractNumber__c =
        con.ContractSignatureDate__c = null;
        con.Cost_Centre__c = null;
        con.Country__c = 'NO - Norge';
        con.Customer_Group__c = null;
        con.CustomersAccountingSystem__c = null;
        //con.Delivery__c = 'Services Norway';
        con.Description__c = 'Test Contract Task Manager';
        con.Employee_1__c = UserInfo.getUserId();
        con.Employee_2__c = UserInfo.getUserId();
        con.Employee_3__c = UserInfo.getUserId();
        con.Employee_4__c = UserInfo.getUserId();
        //con.ERP_System__c = null;
        con.FiscalYearStart__c = Date.newInstance(System.today().year(), 1,1);
        con.IntegrationResource__c = UserInfo.getUserId();
        con.Invoice_Delivery_Method__c = null;
        con.Invoice_Email__c = null;
        //con.LastModifiedById=
        //con.OA_can_Edit__c = null;
        con.Assignment_Responsible__c = null;
        con.Opportunity__c = null;
        //con.OwnerId=
        con.Payment__c = null;
        con.PayrollDate__c =  Date.newInstance(System.today().year(), 1,15);
        con.PayrollOfficer__c = UserInfo.getUserId();
        con.Price_Agreement__c = null;
        con.ProjectManager__c = UserInfo.getUserId();
        con.RecordTypeId = rt.id;
        con.RemitForCustomer__c = null;
        con.ReportingDate__c = Date.newInstance(System.today().year(), 1,15);
        con.ReportingFrequency__c = 'Monthly';
        con.Scope__c = 'Payroll';
        con.Delivery__c = 'Services Norway';
        //con.Name = ''
        //con.SharepointLink__c =
        con.SpecialTerms__c = null;
        con.StartDate__c =  Date.newInstance(System.today().year() - 1, 1,1);
        con.Status__c = 'Draft';
        con.Support_Agreement__c = null;
        con.XGL__c = null;
        return con;
    }

    @IsTest
    public static Contract__c createContract() {
        Account account = createAccount();
        Contract__c contract = getContract(account);
        insert contract;
        return contract;
    }

    @IsTest
    public static ActionPlan__c createActionPlan() {
        ActionPlan__c apt = new ActionPlan__c();
        apt.Contract__c = createContract().id;
        apt.FiscalYear__c = String.valueOf(System.today().year());
        apt.Name = 'Test Action Plan';
        apt.SkipWeekends__c = true;
        insert apt;
        return apt;
    }

    @IsTest
    public static ActionPlanTemplate__c createTemplatePlan() {
        return createTemplatePlan('Payroll');
    }

    public static ActionPlanTemplate__c createTemplatePlan(String name) {
        ActionPlanTemplate__c apt = new ActionPlanTemplate__c();
        apt.Description__c = 'Description';
        apt.Library_Template__c = true;
        apt.Name = name;
        apt.SkipWeekends__c = true;
        insert apt;
        return apt;
    }

    @IsTest
    public static void createTemplateTasksTest(){
        createTemplateTasks(1);
    }

    public static List<APTTaskTemplate__c> createTemplateTasks(String templateName, Integer count) {
        List<APTTaskTemplate__c> tTasks = new List<APTTaskTemplate__c>();
        ActionPlanTemplate__c template = createTemplatePlan(templateName);
        for (Integer i = 0; i < count; i++) {
            APTTaskTemplate__c t = new APTTaskTemplate__c();
            t.Task_Number__c = i;
            t.Subject__c = 'Template task ' + i;
            t.Frequency__c = 'Monthly';
            t.Assigned_Role__c = 'Payroll_Responsible';
            t.Reminder__c = true;
            t.User__c = UserInfo.getUserId();
            t.Comments__c = 'Test comment';
            t.TaskIndex__c = i;
            t.IsMandatory__c = false;
            t.Action_Plan_Template__c = template.id;
            t.Initial_Start_Date__c = 'Year end reporting date';
            //AttachmentHeader__c,
            t.Skip_Weekends__c = true;
            t.Period_1__c = Date.newInstance(System.today().year(), 1,15);
            t.Period_2__c = Date.newInstance(System.today().year(), 2,15);
            t.Period_3__c = Date.newInstance(System.today().year(), 3,15);
            t.Period_12__c = Date.newInstance(System.today().year(), 2,15);
            tTasks.add(t);
        }
        insert tTasks;
        return tTasks;
    }

    public static List<APTTaskTemplate__c> createTemplateTasks(Integer count) {
        return createTemplateTasks('Payroll', count);
    }

    @IsTest
    public static void createActionPlanTasksTest(){
        createActionPlanTasks(1);
    }

    @IsTest
    public static Task createStandardTask(){
        createActionPlanTasks(1);
        APTaskTemplate__c apTaskTemplate = [SELECT id, Subject__c, User__c, Task_Number__c,
                Action_Plan__r.Contract__c, Action_Plan__r.Account__c, Action_Plan__c
        FROM APTaskTemplate__c LIMIT 1];
        Task t = new Task();
        t.AP_Task__c = apTaskTemplate.id;
        t.Subject = apTaskTemplate.Subject__c;
        t.Priority = 'Normal';
        t.Period__c = 1;
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.OwnerId = apTaskTemplate.User__c;
        t.TaskTemplateId__c = apTaskTemplate.Id;
        t.AP_Task__c = apTaskTemplate.Id;
        t.Task_Number__c = apTaskTemplate.Task_Number__c;
        t.WhatId = apTaskTemplate.Action_Plan__r.Contract__c;
        t.Account__c = apTaskTemplate.Action_Plan__r.Account__c;
        t.Task_Control__c = 'OK';
        insert t;
        return t;
    }

    private static List<DatePeriod> getDates(APTaskTemplate__c apTaskTemplate){
        List<DatePeriod> dates = new List<DatePeriod>();
        if (apTaskTemplate.Period_1__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_1__c,1));
        }
        if (apTaskTemplate.Period_2__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_2__c,2));
        }
        if (apTaskTemplate.Period_3__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_3__c,3));
        }
        if (apTaskTemplate.Period_4__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_4__c,4));
        }
        if (apTaskTemplate.Period_5__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_5__c,5));
        }
        if (apTaskTemplate.Period_6__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_6__c,6));
        }
        if (apTaskTemplate.Period_7__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_7__c,7));
        }
        if (apTaskTemplate.Period_8__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_8__c,8));
        }
        if (apTaskTemplate.Period_9__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_9__c,9));
        }
        if (apTaskTemplate.Period_10__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_10__c,10));
        }
        if (apTaskTemplate.Period_11__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_11__c,11));
        }
        if (apTaskTemplate.Period_12__c != null){
            dates.add(new DatePeriod(apTaskTemplate.Period_12__c,12));
        }
        return dates;
    }

    @IsTest
    public static List<Task> createStandardTasks(){
        List<Task> tasks = new List<Task>();
        createActionPlanTasks(1);
        APTaskTemplate__c apTaskTemplate = [SELECT id, Subject__c, User__c, Task_Number__c,
                Action_Plan__r.Contract__c, Action_Plan__r.Account__c, Action_Plan__c,
                Period_1__c,
                Period_2__c, Period_3__c, Period_4__c, Period_5__c,
                Period_6__c, Period_7__c, Period_8__c, Period_9__c, Period_10__c,
                Period_11__c, Period_12__c
        FROM APTaskTemplate__c LIMIT 1];
        List<DatePeriod> dates = getDates(apTaskTemplate);
        for (DatePeriod datePeriod : dates) {
            Task t = new Task();
            t.ActivityDate = datePeriod.periodDate;
            t.AP_Task__c = apTaskTemplate.id;
            t.Subject = apTaskTemplate.Subject__c;
            t.Priority = 'Normal';
            t.Period__c = datePeriod.period;
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            t.OwnerId = apTaskTemplate.User__c;
            t.TaskTemplateId__c = apTaskTemplate.Id;
            t.AP_Task__c = apTaskTemplate.Id;
            t.Task_Number__c = apTaskTemplate.Task_Number__c;
            t.WhatId = apTaskTemplate.Action_Plan__r.Contract__c;
            t.Account__c = apTaskTemplate.Action_Plan__r.Account__c;
            t.Task_Control__c = 'OK';
            tasks.add(t);
        }
        insert tasks;
        return tasks;
    }

    public static List<APTaskTemplate__c> createActionPlanTasks(Integer count) {
        List<APTaskTemplate__c> tTasks = new List<APTaskTemplate__c>();
        ActionPlan__c plan = createActionPlan();
        APTTaskTemplate__c aptt = createTemplateTasks(1).get(0);
        for (Integer i = 0; i < count; i++) {
            APTaskTemplate__c t = new APTaskTemplate__c();
            t.Task_Number__c = i;
            t.Subject__c = 'Template task ' + i;
            t.Frequency__c = 'Monthly';
            t.Assigned_Role__c = 'Payroll_Responsible';
            t.Reminder__c = true;
            t.User__c = UserInfo.getUserId();
            t.Comments__c = 'Test comment';
            t.TaskIndex__c = i;
            t.IsMandatory__c = false;
            t.Action_Plan__c = plan.id;
            t.APT_Task__c = aptt.id;
            //AttachmentHeader__c,
            t.Skip_Weekends__c = true;
            t.Period_1__c = Date.newInstance(System.today().year(), 1,15);
            t.Period_2__c = Date.newInstance(System.today().year(), 2,15);
            t.Period_3__c = Date.newInstance(System.today().year(), 3,15);
            t.Period_4__c = Date.newInstance(System.today().year(), 4,20);
            t.Period_12__c = Date.newInstance(System.today().year(), 2,15);
            tTasks.add(t);
        }
        insert tTasks;
        return tTasks;
    }

    @IsTest
    public static ContentVersion createContentVersion() {
        ContentVersion contentVersionInsert = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.txt',
                VersionData = Blob.valueOf('Test Content Data'),
                IsMajorVersion = true
        );
        //insert contentVersionInsert; Related to Binary work
        return contentVersionInsert;
    }

    @IsTest
    public static AttachmentHeader__c createAttachmentHeader(){
        AttachmentHeader__c attachmentHeader = new AttachmentHeader__c();
        insert attachmentHeader;
        AttachmentRow__c attachmentRow = new AttachmentRow__c();
        attachmentRow.AttachmentHeader__c = attachmentHeader.id;
        return attachmentHeader;
        /*
        Contract_Link__c,
                        CreatedById,
                        CreatedDate,
                        Error_Message__c,
                        File_Name__c,
                        FileConnectID__c,
                        Id,
                        IsDeleted,
                        IsThereError__c,
                        LastModifiedById,
                        LastModifiedDate,
                        LastReferencedDate,
                        LastViewedDate,
                        Name,
                        Number_of_attempts__c,
                        Sharepoint_Link__c,
                        Standard_Task_Link__c,
                        State__c,
                        SystemModstamp
                FROM AttachmentRow__c

                        return attachmentHeader;

                        AP_Task_Unique_Id__c,
                        APT_Task__c,
                        Contract_Id__c,
                        Contract_Link__c,
                        CreatedById,
                        CreatedDate,
                        Id,
                        IsDeleted,
                        LastModifiedById,
                        LastModifiedDate,
                        LastReferencedDate,
                        LastViewedDate,
                        Name,
                        OwnerId,
                        Standard_Task_Id__c,
                        Standard_Task_Link__c,
                        SystemModstamp

         */


    }



}