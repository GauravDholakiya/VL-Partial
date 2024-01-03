/**
 * Created by jozef on 19. 5. 2023.
 */

public without sharing class AptActionPlan {
    private Contract__c contract;
    private String fiscalYear;
    private List<APTaskTemplate__c> apTaskTemplates;
    public List<APTaskTemplate__c> apTasksForInsert {get; set;}
    public Integer numberOfInsertedRows {get; set;}
    ActionPlan__c plan;


    public AptActionPlan(Contract__c contract, String fiscalYear) {
        this.contract = contract;
        this.fiscalYear = fiscalYear;
        this.apTaskTemplates = new List<APTaskTemplate__c>();
        this.apTasksForInsert = new List<APTaskTemplate__c>();
        this.numberOfInsertedRows = 0;
    }

    public void prepare() {
        apTaskTemplates = copyTasks(contract.Id, fiscalYear);
        this.numberOfInsertedRows = apTaskTemplates.size() + 1;
        prepareSave();
        this.numberOfInsertedRows = this.numberOfInsertedRows + apTasksForInsert.size();
        Integer countOfTasks = calculateNumberOfInsertedTasks();
        this.numberOfInsertedRows = this.numberOfInsertedRows + countOfTasks;
    }

    private Integer calculateNumberOfInsertedTasks() {
        Integer numOfTask = 0;
        for (APTaskTemplate__c apt : apTasksForInsert) {
            if (apt.Period_1__c!=null){
                numOfTask++;
            }
            if (apt.Period_2__c!=null){
                numOfTask++;
            }
            if (apt.Period_3__c!=null){
                numOfTask++;
            }
            if (apt.Period_4__c!=null){
                numOfTask++;
            }
            if (apt.Period_5__c!=null){
                numOfTask++;
            }
            if (apt.Period_6__c!=null){
                numOfTask++;
            }
            if (apt.Period_7__c!=null){
                numOfTask++;
            }
            if (apt.Period_8__c!=null){
                numOfTask++;
            }
            if (apt.Period_9__c!=null){
                numOfTask++;
            }
            if (apt.Period_10__c!=null){
                numOfTask++;
            }
            if (apt.Period_11__c!=null){
                numOfTask++;
            }
            if (apt.Period_12__c!=null){
                numOfTask++;
            }
        }
        return numOfTask;
    }

    public void create() {
        saveActionPlan();
    }

    private String getActionPlanName() {
        //CustomerName + Year + [Implementation/Operational]
        String apName;
        String customerName = getShortNameOfAccount(contract.Account__r.Name);
        apName = customerName + ' ' + fiscalYear + ' ' + contract.RecordType.Name;
        return apName;
    }
    private String getShortNameOfAccount(String aName) {
        String newName = aName;
        if (aName.length() >= 59) {
            newName = aName.substring(0, 56) + '...';
        }
        return newName;
    }

    private static void copyApt(APTaskTemplate__c aptt, List<AttachmentHeader__c> headers,
            List<APTaskTemplate__c> apTaskTemplatesNew){
        APTaskTemplate__c newTask = aptt.clone(false, false, false, false);
        newTask.Period_1__c = (newTask.Period_1__c != null) ? newTask.Period_1__c.addYears(1) : newTask.Period_1__c;
        newTask.Period_2__c = (newTask.Period_2__c != null) ? newTask.Period_2__c.addYears(1) : newTask.Period_2__c;
        newTask.Period_3__c = (newTask.Period_3__c != null) ? newTask.Period_3__c.addYears(1) : newTask.Period_3__c;
        newTask.Period_4__c = (newTask.Period_4__c != null) ? newTask.Period_4__c.addYears(1) : newTask.Period_4__c;
        newTask.Period_5__c = (newTask.Period_5__c != null) ? newTask.Period_5__c.addYears(1) : newTask.Period_5__c;
        newTask.Period_6__c = (newTask.Period_6__c != null) ? newTask.Period_6__c.addYears(1) : newTask.Period_6__c;
        newTask.Period_7__c = (newTask.Period_7__c != null) ? newTask.Period_7__c.addYears(1) : newTask.Period_7__c;
        newTask.Period_8__c = (newTask.Period_8__c != null) ? newTask.Period_8__c.addYears(1) : newTask.Period_8__c;
        newTask.Period_9__c = (newTask.Period_9__c != null) ? newTask.Period_9__c.addYears(1) : newTask.Period_9__c;
        newTask.Period_10__c = (newTask.Period_10__c != null) ? newTask.Period_10__c.addYears(1) : newTask.Period_10__c;
        newTask.Period_11__c = (newTask.Period_11__c != null) ? newTask.Period_11__c.addYears(1) : newTask.Period_11__c;
        newTask.Period_12__c = (newTask.Period_12__c != null) ? newTask.Period_12__c.addYears(1) : newTask.Period_12__c;
        AttachmentHeader__c attachmentHeader = new AttachmentHeader__c();
        headers.add(attachmentHeader);
        apTaskTemplatesNew.add(newTask);
    }

    public static List<APTaskTemplate__c> copyTasks(Id contractId, String fiscalYear) {
        ActionPlan__c actionPlan;
        Integer year = Integer.valueOf(fiscalYear) - 1;
        String yearS = String.valueOf(year);
        List<ActionPlan__c> actionPlans = [SELECT Id, Contract__r.Scope__c FROM ActionPlan__c
        WHERE Contract__c = :contractId
        AND FiscalYear__c = :yearS];
        String apId;
        if (actionPlans.size() > 0) {
            actionPlan = actionPlans.get(0);
            apId = actionPlan.Id;
        }
        System.debug('aptId = ' + apId);
        List<APTaskTemplate__c> apTaskTemplates = new List<APTaskTemplate__c>();
        List<APTaskTemplate__c> apTaskTemplatesNew = new List<APTaskTemplate__c>();
        List<AttachmentHeader__c> headers =  new List<AttachmentHeader__c>();

        Map<String, String> assignedRoleTranslationApi = DependentPicklist.getPicklistApiMap(
                Account_Team_And_Authorizations__c.Type__c);
        if (!String.isEmpty(apId)) {
            apTaskTemplates = [
                    SELECT id, Task_Number__c, Subject__c, Frequency__c,
                            Assigned_Role__c, Reminder__c, Action_Plan__c,
                            Period_1__c, Period_2__c, Period_3__c, Period_4__c, Period_5__c, Period_6__c,
                            Period_7__c, Period_8__c, Period_9__c, Period_10__c, Period_11__c, Period_12__c,
                            ActionPlanTemplate__c, ActionPlanTemplate__r.Name,
                            Contact__c, Contact__r.Name, User__c, User__r.Name, Comments__c, TaskIndex__c,
                            IsMandatory__c, TemplateStaticPeriods__c,
                            AttachmentHeader__c, IsVisible__c, Skip_Weekends__c,
                            Description__c, APT_Task__r.Initial_Start_Date__c, APT_Task__r.Plus_Days__c,
                            APT_Task__r.Action_Plan_Template__r.Name,
                            APT_Task__r.Action_Plan_Template__r.Library_Template__c
                    FROM APTaskTemplate__c
                    WHERE Action_Plan__c = :apId
                    ORDER BY TaskIndex__c asc
            ];
            for (APTaskTemplate__c aptt : apTaskTemplates) {
                if (actionPlan.Contract__r.Scope__c.contains(aptt.APT_Task__r.Action_Plan_Template__r.Name)
                        || aptt.APT_Task__r.Action_Plan_Template__r.Library_Template__c == true){
                    copyApt(aptt, headers, apTaskTemplatesNew);
                }
            }
        }
        if (!headers.isEmpty()){
            insert headers;
        }

        //There should be a bug because is not possible add variable myVariable dynamicaly in component controller
        //and expression then validate {!t.myVariable == true}
        //even it's possible read this expression {!t.myVariable} then
        Integer apI = 0;
        for (APTaskTemplate__c apTaskTemplate : apTaskTemplatesNew) {
            apTaskTemplate.IsVisible__c = true;
            if (apTaskTemplate.Assigned_Role__c != null) {
                apTaskTemplate.Assigned_Role__c = assignedRoleTranslationApi.get(
                        apTaskTemplate.Assigned_Role__c);
            }
            apTaskTemplate.AttachmentHeader__c = headers.get(apI).id;
            apI++;
        }
        return apTaskTemplatesNew;
    }

    public static List<APTaskTemplate__c> getTasks(Id apId) {
        List<APTaskTemplate__c> apTaskTemplates = new List<APTaskTemplate__c>();
        Map<String, String> assignedRoleTranslationApi = DependentPicklist.getPicklistApiMap(
                Account_Team_And_Authorizations__c.Type__c);
        if (!String.isEmpty(apId)) {
            apTaskTemplates = [
                    SELECT id, Task_Number__c, Subject__c, Frequency__c,
                            Assigned_Role__c, Reminder__c, Action_Plan__c,
                            Period_1__c, Period_2__c, Period_3__c, Period_4__c, Period_5__c, Period_6__c,
                            Period_7__c, Period_8__c, Period_9__c, Period_10__c, Period_11__c, Period_12__c,
                            ActionPlanTemplate__c, ActionPlanTemplate__r.Name,
                            Contact__c, Contact__r.Name, User__c, User__r.Name, Comments__c, TaskIndex__c,
                            IsMandatory__c, TemplateStaticPeriods__c,
                            AttachmentHeader__c, IsVisible__c, Skip_Weekends__c,
                            Description__c, APT_Task__r.Initial_Start_Date__c, APT_Task__r.Plus_Days__c
                    FROM APTaskTemplate__c
                    WHERE Action_Plan__c = :apId
                    ORDER BY Task_Number__c, TaskIndex__c asc
            ];
        }
        //There should be a bug because is not possible add variable myVariable dynamicaly in component controller
        //and expression then validate {!t.myVariable == true}
        //even it's possible read this expression {!t.myVariable} then
        for (APTaskTemplate__c apTaskTemplate : apTaskTemplates) {
            apTaskTemplate.IsVisible__c = true;
            if (apTaskTemplate.Assigned_Role__c != null) {
                apTaskTemplate.Assigned_Role__c = assignedRoleTranslationApi.get(
                        apTaskTemplate.Assigned_Role__c);
            }
        }
        return apTaskTemplates;
    }

    private void prepareSave() {
        apTasksForInsert = new List<APTaskTemplate__c>();

        plan = new ActionPlan__c();
        plan.Name = getActionPlanName();
        plan.Contract__c = contract.id;
        plan.Account__c = contract.Account__c;
        plan.FiscalYear__c = fiscalYear;
        plan.SkipWeekends__c = false;
        insert plan;

        Map<String, String> assignedRoleTranslationVal = DependentPicklist.getPicklistValueMap(
                Account_Team_And_Authorizations__c.Type__c);

        for (APTaskTemplate__c apTaskTemplate : apTaskTemplates) {
            if (apTaskTemplate.APT_Task__r != null) {
                apTaskTemplate.APT_Task__r = null;
            }
            apTaskTemplate.IsVisible__c = true;
            apTaskTemplate.User__r = null;
            if (apTaskTemplate.Assigned_Role__c != null) {
                apTaskTemplate.Assigned_Role__c = assignedRoleTranslationVal.get(
                        apTaskTemplate.Assigned_Role__c);
            }
            apTaskTemplate.Action_Plan__c = plan.id;
            apTasksForInsert.add(apTaskTemplate);
        }
    }
    private void saveActionPlan() {
        AptActionPlanUtil util;
        util = new AptActionPlanUtil(false);

        if (!apTasksForInsert.isEmpty()) {
            //System.debug(apTasksForInsert);
            insert apTasksForInsert;
        }

        List<APTaskTemplate__c> newTasks = getTasks(plan.id);
        util.generateActionPlans(newTasks, plan.id);
    }
}