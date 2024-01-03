/**
 * Created by jozef on 12. 5. 2023.
 */

public without sharing class AptActionPlanSync {
    public class AgreementException extends Exception{}
    public class UserRole{
        public Id userId {get; set;}
        public String assignedRole {get; set;}
        public UserRole(Id userId, String assignedRole){
            this.userId = userId;
            this.assignedRole = assignedRole;
        }
    }

    public class Apt{
        public APTaskTemplate__c apTaskTemplate {get; set;}
        public APTTaskTemplate__c aptt {get; set;}
        public Date iniDate {get; set;}
        public Integer plusDays {get; set;}
        public String frequency {get; set;}
        public List<Decimal> periods {get; set;}
        public Map<Integer, Task> periodTaskMap {get; set;}
        public Integer fiscalYear {get; set;}
        Integer staticPeriodWithYearPlusOne;
        Map<Integer, Date> staticPeriodDates;
        Map<Integer, Date> periodDates;
        List<Task> toInsertTasks;
        List<Task> toDeleteTasks;
        List<Task> toUpdateTasks;
        Id contractId;
        Id accountId;

        public Apt(Task task, Date initDate, Decimal plusDays,  String frequency,
                APTTaskTemplate__c aptt, Id contractId, Id accountId){
            periods = new List<Decimal>();
            this.iniDate = initDate;
            this.plusDays = Integer.valueOf(plusDays);
            this.frequency = frequency;
            this.aptt = aptt;
            this.periodTaskMap = new Map<Integer, Task>();
            this.fiscalYear = Integer.valueOf(task.AP_Task__r.Action_Plan__r.FiscalYear__c);
            toInsertTasks = new List<Task>();
            toDeleteTasks = new List<Task>();
            toUpdateTasks = new List<Task>();
            this.contractId = contractId;
            this.accountId = accountId;
        }

        private void setPeriodsFields() {
            staticPeriodDates = new Map<Integer, Date>();
            periodDates = new Map<Integer, Date>();
            for (Integer i = 1; i <= 12; i++) {
                staticPeriodDates.put(i,(Date)aptt.get('Period_'+i+ '__c'));
                periodDates.put(i,(Date)apTaskTemplate.get('Period_'+i+ '__c'));
            }
        }
        Boolean isTaskOpened(Integer period){
            Boolean isOpened = true;
            Task t = this.periodTaskMap.get(period);
            if (t!=null){
                isOpened = t.Status == 'Not Started' || t.Status == 'Open';
            }
            return isOpened;
        }
        private void calculate() {
            if (aptt.Plus_Days__c != null && aptt.Plus_Days__c != 0){
                iniDate = iniDate.addDays(Integer.valueOf(aptt.Plus_Days__c));
            }
            setPeriodsFields();
            setPeriodsByFrequency();
        }
        private void setPeriodsByFrequency(){
            this.setStaticPeriodWithYearPlusOne();
            if (frequency == 'Monthly' || frequency == 'Månedlig'){
                this.setMonthly();
            }else if (frequency == 'Bi-monthly' || frequency == 'Terminvis'){
                this.setBiMonthly();
            }else if (frequency == 'Quarterly' || frequency == 'Kvartalsvis'){
                this.setQuarterly();
            }else if (frequency == 'Interim' || frequency == 'Tertial'){
                this.setInterim();
            }else if (frequency == 'Biannual' || frequency == 'Halvårlig'){
                this.setBiannual();
            }else if (frequency == 'Annual' || frequency == 'Årlig'){
                this.setAnnual();
            }
        }

        private void setMonthly(){
            setFrequency(1);
        }
        private void setBiMonthly(){
            setFrequency(2);
        }
        private void setQuarterly(){
            setFrequency(3);
        }
        private void setInterim(){
            setFrequency(4);
        }
        private void setBiannual(){
            setFrequency(6);
        }
        private void setAnnual(){
            Date iDate;
            Date staticDate = staticPeriodDates.get(12);
            if (staticDate == null){
                iDate = iniDate;
            }else{
                iDate = staticDate;
            }
            apTaskTemplate.Period_12__c = changeYear(iDate, fiscalYear + 1);
        }

        private void setFrequency(Integer modulo){
            Integer month = 0;
            Boolean incMonth = false;
            Boolean isDivisible = false;
            for (Integer i = 0; i <= 11; i++) {
                Integer period = i + 1;
                if (incMonth == true){
                    month = month + 1;
                }
                if (Math.mod(period, modulo) == 0) {
                    incMonth = true;
                    isDivisible = true;
                }else{
                    isDivisible = false;
                }
                if (isTaskOpened(period)){
                    setFrequencyForOpenedTasks(period, incMonth, month, isDivisible);
                }
            }
        }

        private void setFrequencyForOpenedTasks(Integer period, Boolean incMonth, Integer month,
                Boolean isDivisible){
            String periodField = 'Period_' + period + '__c';
            if (isDivisible == true) {
                setPeriodDate(periodField, month, period);
                incMonth = true;
            } else {
                Date periodDate = periodDates.get(period);
                if (periodDate != null && periodDate.year() != fiscalYear) {
                    periodDate = changeYear(periodDate, fiscalYear);
                    apTaskTemplate.put(periodField, periodDate);
                }
            }
            if (apTaskTemplate.Skip_Weekends__c == true){
                skipWeekend();
            }
            setStandardTasks(period, periodField);
        }

        private void setStandardTasks(Integer period, String periodField){
            Date periodDate = (Date)apTaskTemplate.get(periodField);
            Task t = periodTaskMap.get(period);
            if (t==null){
                if (periodDate!=null){
                    t = getNewStandardTask(period, periodDate);
                    toInsertTasks.add(t);
                }
            }else{
                if (periodDate == null){
                    toDeleteTasks.add(t);
                }else{
                    if (t.ActivityDate != periodDate){
                        t.ActivityDate = periodDate;
                        toUpdateTasks.add(t);
                    }
                }
            }
        }
        private Task getNewStandardTask(Integer period, Date periodDate){
            Task t = new Task();
            AptActionPlanUtil.setTask(t, periodDate, period, apTaskTemplate.Reminder__c );
            t.type = apTaskTemplate.ActionPlanTemplate__r.Name;
            t.Status = 'Not Started';
            AptActionPlanUtil.setTaskAccordingApt(t, apTaskTemplate, contractId, accountId);
            return t;
        }

        private void setPeriodDate(String periodField, Integer month, Integer period){
            Date staticDate = staticPeriodDates.get(period);
            if (staticDate == null){
                apTaskTemplate.put(periodField, addMonths(iniDate, month));
            }else{
                if (staticPeriodWithYearPlusOne == period){
                    apTaskTemplate.put(periodField, changeYear((Date)apTaskTemplate.get(periodField),
                            fiscalYear + 1));
                }else{
                    if (period == 12){
                        apTaskTemplate.put(periodField, changeYearStaticPeriod12((Date)apTaskTemplate.get(periodField),
                                fiscalYear));
                    }else{
                        apTaskTemplate.put(periodField, changeYear((Date)apTaskTemplate.get(periodField),
                                fiscalYear));
                    }
                }
            }
        }

        private Date changeYearStaticPeriod12(Date periodDate, Integer year){
            Integer month;
            Date newDate = null;
            if (periodDate != null){
                month = periodDate.month();
                if (month == 1 || month == 2 || month == 3 || month == 4){
                    year = year + 1;
                }
                newDate = Date.newInstance(year, month, periodDate.day());
            }
            return newDate;
        }
        private Date addMonths(Date inputDate, Integer months) {
            Date newDate;
            newDate = inputDate.addMonths(months);
            return newDate;
        }
        private Date changeYear(Date d, Integer year){
            Date newDate = null;
            if (d!=null) {
                newDate = Date.newInstance(year, d.month(), d.day());
            }
            return newDate;
        }

        private void setStaticPeriodWithYearPlusOne(){
            staticPeriodWithYearPlusOne = -1;
            Integer currentYear = -1;
            for (Integer i = 1; i <= 12; i++) {
                Date dt = staticPeriodDates.get(i);
                if (dt != null){
                    if (currentYear == -1){
                        currentYear = dt.year();
                    }else if (currentYear < dt.year()){
                        staticPeriodWithYearPlusOne = i;
                        break;
                    }
                }
            }
        }
        private void skipWeekend() {
            apTaskTemplate.Period_1__c = getWorkingDay(apTaskTemplate.Period_1__c);
            apTaskTemplate.Period_2__c = getWorkingDay(apTaskTemplate.Period_2__c);
            apTaskTemplate.Period_3__c = getWorkingDay(apTaskTemplate.Period_3__c);
            apTaskTemplate.Period_4__c = getWorkingDay(apTaskTemplate.Period_4__c);
            apTaskTemplate.Period_5__c = getWorkingDay(apTaskTemplate.Period_5__c);
            apTaskTemplate.Period_6__c = getWorkingDay(apTaskTemplate.Period_6__c);
            apTaskTemplate.Period_7__c = getWorkingDay(apTaskTemplate.Period_7__c);
            apTaskTemplate.Period_8__c = getWorkingDay(apTaskTemplate.Period_8__c);
            apTaskTemplate.Period_9__c = getWorkingDay(apTaskTemplate.Period_9__c);
            apTaskTemplate.Period_10__c = getWorkingDay(apTaskTemplate.Period_10__c);
            apTaskTemplate.Period_11__c = getWorkingDay(apTaskTemplate.Period_11__c);
            apTaskTemplate.Period_12__c = getWorkingDay(apTaskTemplate.Period_12__c);
        }

        private Date getWorkingDay(Date periodDate){
            Date newDate;
            DateTime dt;
            String dayInWeek;
            if (periodDate!=null){
                dt = periodDate;
                dayInWeek = dt.format('u');
                if (dayInWeek == '6'){
                    newDate = periodDate.addDays(2);
                }else if (dayInWeek == '7'){
                    newDate = periodDate.addDays(1);
                } else {
                    newDate = periodDate;
                }
            }else{
                newDate = periodDate;
            }
            return newDate;
        }

    }
    public class AptTaskData {
        List<Contract__c> changedContracts;
        List<Task> tasks;
        List<APTaskTemplate__c> apTaskTemplates;
        Map<Id, Apt> apts;

        public AptTaskData(){
            changedContracts = new List<Contract__c>();
            tasks = new List<Task>();
            apTaskTemplates = new List<APTaskTemplate__c>();
            apts = new Map<Id, Apt>();
        }

        private void setTasks(){
            tasks = [ SELECT Account__c,  AccountId, Accounting_Upload__c, Action_Plan__c, Action_Plan_Task__c,
                    ActivityDate, AP_Task__c, Assigned_Role__c, Completed_date__c, CompletedDateTime,
                    Controlled_by__c, Country__c, Days_Overdue__c, Days_to_Completed__c,  Overdue_Reason__c,
                    OwnerId, Payroll_Upload__c, Period__c, Priority, Scope__c, Status, Subject, Task_Control__c,
                    Task_Control_Modified_Date__c, Task_Descripton__c, Task_Number__c, Task_sequence__c,
                    TaskSubtype, TaskTemplateId__c, Type, WhatCount, WhatId, WhoCount, WhoId,
                    AP_Task__r.APT_Task__r.Initial_Start_Date__c,
                    AP_Task__r.APT_Task__r.Frequency__c,
                    AP_Task__r.APT_Task__r.Plus_Days__c,
                    AP_Task__r.Action_Plan__r.Contract__r.Year_end_reporting_date__c,
                    AP_Task__r.APT_Task__r.Period_1__c,
                    AP_Task__r.APT_Task__r.Period_2__c,
                    AP_Task__r.APT_Task__r.Period_3__c,
                    AP_Task__r.APT_Task__r.Period_4__c,
                    AP_Task__r.APT_Task__r.Period_5__c,
                    AP_Task__r.APT_Task__r.Period_6__c,
                    AP_Task__r.APT_Task__r.Period_7__c,
                    AP_Task__r.APT_Task__r.Period_8__c,
                    AP_Task__r.APT_Task__r.Period_9__c,
                    AP_Task__r.APT_Task__r.Period_10__c,
                    AP_Task__r.APT_Task__r.Period_11__c,
                    AP_Task__r.APT_Task__r.Period_12__c,
                    AP_Task__r.APT_Task__r.Skip_Weekends__c,
                    AP_Task__r.Action_Plan__r.FiscalYear__c,
                    AP_Task__r.TemplateStaticPeriods__c,
                    AP_Task__r.Skip_Weekends__c
            FROM Task WHERE //(Status = 'Open' OR Status = 'Not Started')
                    AP_Task__r.APT_Task__r.Initial_Start_Date__c = 'Year end reporting date'
                    AND WhatId IN: changedContracts];
            for (Task task : tasks) {
                Apt apt = apts.get(task.AP_Task__c);
                if (apt == null){
                    apt = new Apt(task,
                            task.AP_Task__r.Action_Plan__r.Contract__r.Year_end_reporting_date__c,
                            task.AP_Task__r.APT_Task__r.Plus_Days__c,
                            task.AP_Task__r.APT_Task__r.Frequency__c,
                            task.AP_Task__r.APT_Task__r, task.WhatId, task.AccountId);
                    apts.put(task.AP_Task__c, apt);
                }
                apt.periods.add(task.Period__c);
                apt.periodTaskMap.put(Integer.valueOf(task.Period__c),task);
            }
        }
        private void setApTaskTemplates(){
            for (APTaskTemplate__c apTaskTemplate : [SELECT id,
                    Period_1__c,
                    Period_2__c, Period_3__c, Period_4__c, Period_5__c,
                    Period_6__c, Period_7__c, Period_8__c, Period_9__c, Period_10__c,
                    Period_11__c, Period_12__c, Skip_Weekends__c, Reminder__c, ActionPlanTemplate__r.Name,
                    Subject__c, Task_Number__c, IsMandatory__c, User__c, Comments__c, Description__c
            FROM APTaskTemplate__c WHERE id IN: apts.keySet()]) {
                Apt apt = apts.get(apTaskTemplate.id);
                apt.apTaskTemplate = apTaskTemplate;
            }
        }
        private void updateAptAndTasks() {
            setTasks();
            setApTaskTemplates();
            calculatePeriods();
            updateApTaskTemplates();
            updateStandardTasks();
        }

        private void updateStandardTasks() {
            List<Task> tasksToUpdate = new List<Task>();
            List<Task> tasksToInsert = new List<Task>();
            List<Task> tasksToDelete = new List<Task>();
            for (Apt apt : apts.values()) {
                tasksToDelete.addAll(apt.toDeleteTasks);
                tasksToUpdate.addAll(apt.toUpdateTasks);
                tasksToInsert.addAll(apt.toInsertTasks);
            }
            if (!tasksToDelete.isEmpty()){
                delete tasksToDelete;
            }
            if (!tasksToUpdate.isEmpty()){
                update tasksToUpdate;
            }
            if (!tasksToInsert.isEmpty()){
                insert tasksToInsert;
            }
        }

        private void updateApTaskTemplates() {
            if (!apTaskTemplates.isEmpty()){
                update apTaskTemplates;
            }
        }

        private void calculatePeriods() {
            for (Apt apt : apts.values()) {
                apt.calculate();
                apTaskTemplates.add(apt.apTaskTemplate);
            }
        }

        private void setContracts(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
            Contract__c newContract;
            Contract__c oldContract;
            for (Id id : newItems.keySet()) {
                newContract = (Contract__c)newItems.get(id);
                oldContract = (Contract__c)oldItems.get(id);
                if (newContract.Year_end_reporting_date__c != null
                        && (newContract.Year_end_reporting_date__c != oldContract.Year_end_reporting_date__c)){
                    changedContracts.add(newContract);
                }
            }
        }

    }

    public class ActionPlan {
        Map<ID, Map<String, Id>> contractAccountTeamMap;
        Map<Id, SObject> accountTeamAndAuthItems;
        List<APTaskTemplate__c> apTaskTemplatesToUpdate;
        Map<Id, UserRole> taskOwnerToUpdate;
        Map<ID , List<Task>> taskMap;
        List<Task> taskToUpdate;
        public ActionPlan(){
            accountTeamAndAuthItems = new Map<Id, SObject>();
            contractAccountTeamMap = new Map<ID, Map<String, Id>>();
            taskMap = new Map<ID , List<Task>>();
            apTaskTemplatesToUpdate = new List<APTaskTemplate__c>();
            taskToUpdate = new List<Task>();
            taskOwnerToUpdate = new Map<Id, UserRole>();
        }

        public void setContractAccountTeamMap(){
            for (SObject sobj : accountTeamAndAuthItems.values()) {
                Account_Team_And_Authorizations__c a = (Account_Team_And_Authorizations__c) sobj;
                if (a.Kontrakt__c != null) {
                    contractAccountTeamMap.put(a.Kontrakt__c, null);
                }
            }
            for (Account_Team_And_Authorizations__c a : [SELECT id, Kontrakt__c, Type__c, Responsible__c
            FROM Account_Team_And_Authorizations__c WHERE Kontrakt__c IN: contractAccountTeamMap.keySet()]){
                if (a.Kontrakt__c != null) {
                    Map<String, Id> accountTeamAndAuthorizationMap
                            = contractAccountTeamMap.get(a.Kontrakt__c);
                    if (accountTeamAndAuthorizationMap == null) {
                        accountTeamAndAuthorizationMap = new Map<String, Id>();
                        contractAccountTeamMap.put(a.Kontrakt__c, accountTeamAndAuthorizationMap);
                    }
                    accountTeamAndAuthorizationMap.put(a.Type__c, a.Responsible__c);
                }
            }
        }

        public void setTaskMap(){
            List<Task> tasks = [SELECT id, AP_Task__c, AP_Task__r.Action_Plan__r.Contract__c,
                    AP_Task__r.Action_Plan__r.Contract__r.Account_Owner_KA__c,
                    Assigned_Role__c, OwnerId
            FROM Task
            WHERE Status = 'Not Started'
            AND AP_Task__r.Action_Plan__r.Contract__c IN: contractAccountTeamMap.keySet()];
            for (Task t : tasks) {
                List<Task> taskList = taskMap.get(t.AP_Task__r.Action_Plan__r.Contract__c);
                if (taskList == null) {
                    taskList = new List<Task>();
                    taskMap.put(t.AP_Task__r.Action_Plan__r.Contract__c, taskList);
                }
                taskList.add(t);
            }
        }

        private Id getResponsible(Map<String, Id> allRoles, Task t){
            Id userId = null;
            if (!String.isEmpty(t.Assigned_Role__c)) {
                userId = allRoles.get(t.Assigned_Role__c);
            }
            return userId;
        }

        public void setTaskOwner() {
            for (List<Task> tasks : taskMap.values()) {
                for (Task t : tasks) {
                    Id originalUserId = t.OwnerId;
                    Map<String, Id> allRoles = contractAccountTeamMap.get(t.AP_Task__r.Action_Plan__r.Contract__c);
                    ID userId = getResponsible(allRoles, t);
                    String assignedRole;
                    if (userId == null){
                        assignedRole =  AptActionPlanController.ACCOUNT_OWNER;
                        t.OwnerId = t.AP_Task__r.Action_Plan__r.Contract__r.Account_Owner_KA__c;
                    }else{
                        assignedRole = t.Assigned_Role__c;
                        t.OwnerId = userId;
                    }
                    if (originalUserId != t.OwnerId) {
                        if (t.OwnerId == null) {
                            throw new AgreementException('Agreement is missing default Account Owner KA');
                        }
                        taskToUpdate.add(t);
                        taskOwnerToUpdate.put(t.AP_Task__c, new UserRole(t.OwnerId, assignedRole));
                    }
                }
            }
        }

        public void setApTaskUser() {
            apTaskTemplatesToUpdate = [SELECT id, User__c, Assigned_Role__c FROM APTaskTemplate__c
            WHERE Id IN: taskOwnerToUpdate.keySet()];
            for (APTaskTemplate__c apTask : apTaskTemplatesToUpdate) {
                AptActionPlanSync.UserRole ur = taskOwnerToUpdate.get(apTask.id);
                apTask.User__c = ur.userId;
                apTask.Assigned_Role__c = ur.assignedRole;
            }
        }


    }

    /*****************************************************
    * @description
        For all related Action Plans:
        Responsible__c
        Type__c
        According Type__c and related APTTemplateTask.Assigned_Role__c we do change of:
        APTTemplateTask.UserId = Responsible__c
        Taks.OwnerId = Responsible__c
    * @param  items
    */
    private static void synchronizeTaskOwners(Map<Id, SObject> items){
        ActionPlan actionPlan = new ActionPlan();
        actionPlan.accountTeamAndAuthItems = items;
        actionPlan.setContractAccountTeamMap();
        actionPlan.setTaskMap();
        actionPlan.setTaskOwner();
        actionPlan.setApTaskUser();
        if (!actionPlan.taskToUpdate.isEmpty()){
            update actionPlan.taskToUpdate;
            update actionPlan.apTaskTemplatesToUpdate;
        }
    }

    public static void synchronizeAccountTeamAfterInsert(Map<Id, SObject> newAccountTeamAndAuthItems) {
        synchronizeTaskOwners(newAccountTeamAndAuthItems);
    }

    public static void synchronizeAccountTeamAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        synchronizeTaskOwners(newItems);
    }

    public static void synchronizeAccountTeamAfterDelete(Map<Id, SObject> oldItems) {
        synchronizeTaskOwners(oldItems);
    }

    public static void synchronizeActionPlan(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        synchronizeAptPeriods(newItems, oldItems);
    }

    private static void synchronizeAptPeriods(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        AptTaskData aptTaskData = new AptTaskData();
        aptTaskData.setContracts(newItems, oldItems);
        aptTaskData.updateAptAndTasks();
    }

}