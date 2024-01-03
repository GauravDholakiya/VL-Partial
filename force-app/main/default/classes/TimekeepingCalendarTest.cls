/**
 * @author Jozef 
 * @date 24.3.2021.
 * @description //TODO
 */

@IsTest
private class TimekeepingCalendarTest {
    @TestSetup
    static void setup(){
        Activity_Price_Agreement_Setting__c settings = new Activity_Price_Agreement_Setting__c();
        settings.Activity__c = '0202 Periodic reconciliation';
        settings.Exception__c = 'Hourly Rate';
        settings.Price_Agreement_Field__c = 'PA_Accounting__c';
        settings.Value_not_allowed__c = 'Hourly Rate';
        insert settings;

        Project_Number_o__c pSetting = new Project_Number_o__c();
        pSetting.Identifier__c = 'PNO';
        pSetting.Project_Number_Operational__c = 1;
        insert pSetting;

        prepareProjectTasks();
    }


    static void prepareProjectTasks(){
        Account account = new Account(
                Name = 'Mørland Sko AS',            // Account Name
                //Type = 'Customer',                                    // Type
                Country2__c = 'NO - Norge',                          // Country

                Firm__c = 'VIEW Ledger AS',                           // Firm
                //Project_Number_Operational__c = '10148',              // Project Number - Operational
                Assignment_Responsible__c = UserInfo.getUserId(),
                Business_Area__c = '120 - Xledger - Tjeneste',
                Bypass_Validation_Rule__c = false,
                Case_Invoicable_Flow__c = false,
                Contract_Start_Date_Oper__c = System.today(),
                Cost_Center__c = '01 Oslo Felles',
                Create_Case__c = false,
                Create_Opportunity__c = false,
                Customer_Group__c = 'Premium',
                Deactivated__c = false,
                DESKSCMT__Desk_Migrated_Account__c = false,
                Inspection_on_money_laundering_completed__c = false,  // Inspection on money laundering completed
                Invoice_Delivery_Method__c = 'Internal',
                Late_payment__c = false,
                Payment__c = 'Invoice',
                Price_Agreement__c = 'Unit Price',
                Support_Agreement__c = '500 No Support',
                Type = 'Dummy'
        );
        insert account;
        RecordType rt = [SELECT id, DeveloperName FROM RecordType WHERE SobjectType = 'Project__c'
            AND DeveloperName = 'Operational'];

        Project__c proj = new Project__c(
                //Project_Number__c = 10148,
                Name = 'Test Project - 2021',         // Project Name
                RecordTypeId = rt.id,
                Account__c = account.id,              // Account
                Status__c = 'Draft',                         // Status
                Start_Date__c = System.today(),  // Start Date
                Invoice_Responsible__c = UserInfo.getUserId(),
                End_Date__c = System.today().addYears(1),    // End Date
                Budgeting_Completed__c = false,
                Integrations__c = false
        );
        insert proj;

        Project_task__c projectTask = new Project_task__c();
        projectTask.Project__c = proj.id;
        projectTask.Status__c = 'Ongoing';
        projectTask.Default_Time_Type__c = '0 Normal Time';
        projectTask.Resource__c = UserInfo.getUserId();
        insert projectTask;
    }

    @IsTest
    static void getActivityPriceAgreementConfigTest() {
        TimekeepingCalendar.getActivityPriceAgreementConfig();
    }

    @IsTest
    static void getActivityPriceAgreementOptionsTest() {
        List<Project_task__c> projectTasks = [SELECT id FROM Project_task__c];
        List<String> pTasks = new List<String>();
        for (Project_task__c pt : projectTasks) {
            pTasks.add(pt.id);
        }
        TimekeepingCalendar.getActivityPriceAgreementOptions(pTasks);
    }

    @IsTest
    static void testBehaviour() {
        List<Time__c> times = new List<Time__c>();
        Time__c t = new Time__c();
        List<Project_task__c> projectTasks = [SELECT id FROM Project_task__c];

        t.Date__c = System.today();
        t.Project_Task__c = projectTasks.get(0).Id;
        t.Incurred_By__c = UserInfo.getUserId();
        t.Registered_Hours__c = 2;
        t.Registered_Minutes__c = 0;
        t.Billable_Hours__c = 2;
        t.Billable_Minutes__c = 0;
        t.Description__c = 'Description';
        t.Main_Activity__c = 'Accounting (NOR)';
        t.Activity__c = '0201 Vouchers';
        t.Time_Type__c = '0 Normal Time';
        t.Comment__c = 'Comment';
        t.Activity_Price_Agreement__c = 'Hourly Rate';
        t.Project_Country__c = 'NO - Norge';
        //insert t;

        times.add(t);

        TimekeepingCalendar.saveTime(times);

        String timeid = t.id;
        String timedate = '2021-04-07T00:00:00';
        try {
            TimekeepingCalendar.updateTime(timeid, timedate);
        }catch (Exception ex){

        }
        TimekeepingCalendar.getAllTimes();
        TimekeepingCalendar.getCurrentUser();
        TimekeepingCalendar.getMainActivityValues();
        TimekeepingCalendar.getActivityValues('Accounting');
        /* Time Type remove */
        TimekeepingCalendar.getTimeTypeValues();
        TimekeepingCalendar.getDefaultTimeTypeValue();

        TimekeepingCalendar.getProjTasks('', false, false);
        TimekeepingCalendar.getProjTasks('abc', true, true);
        TimekeepingCalendar.getProjTasks('abc', true, false);
        TimekeepingCalendar.getProjTasks('abc', false, true);
        TimekeepingCalendar.getProjectTaskCountry(t.Project_Task__c);
        TimekeepingCalendar.getMainPriceAgreement(t.Project_Task__c);
        TimekeepingCalendar.setUiConf(true, true);
        TimekeepingCalendar.setUiConf(false, false);
        TimekeepingCalendar.setUiConf(false, true);
        TimekeepingCalendar.setUiConf(true, false);
    }
}