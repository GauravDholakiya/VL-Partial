/**
 * @author Jozef
 * @date 22.1.2019.
 * @description //TODO
 */

public with sharing class AptActionPlanController {
    public static final String ACCOUNT_OWNER = 'Account_Owner';
    public class AptAttachment {
        public String name { get;set; }
        public String documentId { get;set; }
    }

    public class StandardTask{
        @AuraEnabled
        public string id {get; set;}
        @AuraEnabled
        public List<Task> tasks {get; set;}

        public StandardTask(String id){
            this.id = id;
            tasks = new List<Task>();
        }
    }

    @AuraEnabled
    public static Contract__c getContract(Id contractId) {
        Contract__c con;
        try {
            con = [
                    SELECT id, OwnerId, Name, Account__c, Account__r.Name, Scope__c, FiscalYearStart__c,
                            StartDate__c, ReportingFrequency__c, PayrollDate__c, ReportingDate__c,
                            Closing_Frequency__c, RecordType.Name, Account_Owner_KA__c, CloseDate__c,
                            Year_end_reporting_date__c, Fiscal_Year_End__c
                    FROM Contract__c
                    WHERE Id = :contractId
            ];
        }catch (Exception ex){
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException('AptActionPlanController.getContract : ' + ex.getMessage());
        }
        return con;
    }

    @AuraEnabled
    public static ActionPlan__c getActionPlan(Id apId) {
        System.debug('apId = ' + apId);
        ActionPlan__c plan;
        try {
            if (!String.isEmpty(apId)) {
                plan = [
                        SELECT
                                Account__c,
                                Account__r.Name,
                                Action_Plan_Template__c,
                                Contact__c,
                                Contract__c,
                                Contract__r.Name,
                                CreatedById,
                                CreatedBy.Name,
                                CreatedDate,
                                FiscalYear__c,
                                Id,
                                LastModifiedById,
                                LastModifiedBy.Name,
                                LastModifiedDate,
                                Name,
                                OwnerId,
                                Owner.Name,
                                SkipDay__c,
                                SkipWeekends__c,
                                StartDate__c
                        FROM ActionPlan__c WHERE id =: apId];
            }else{
                plan = new ActionPlan__c();
                plan.OwnerId = UserInfo.getUserId();
                plan.SkipWeekends__c = false;
                plan.Name = '';
            }
            System.debug(plan);
        }catch (Exception ex){
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException('AptActionPlanController.getActionPlan : ' + ex.getMessage());
        }
        return plan;
    }

    @AuraEnabled
    public static List<APTaskTemplate__c> getNewTasks(Id contractId) {
        List<APTaskTemplate__c> apTaskTemplates = new List<APTaskTemplate__c>();
        try {
            apTaskTemplates = prepareNewTasks(contractId);
        }catch (Exception ex){
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException('AptActionPlanController.getNewTasks : ' + ex.getMessage());
        }
        return apTaskTemplates;
    }


    private static List<APTTaskTemplate__c> getTemplatesAccordingContract(Contract__c contract){
        List<APTTaskTemplate__c> templateTaskList = new List<APTTaskTemplate__c>();
        List<String> templateNames = new  List<String>();
        if (contract.Scope__c != null) {
            templateNames = contract.Scope__c.split(';');
            templateTaskList =  [
                    SELECT  Name, User__c, User__r.Name, Id,
                            Action_Plan_Template__c, Subject__c,
                            Reminder__c, SendEmail__c, Comments__c, taskIndex__c,
                            Frequency__c, Assigned_Role__c, IsMandatory__c,
                            TaskId__c, Action_Plan_Template__r.Name, Task_Number__c, Period_1__c,
                            Period_2__c, Period_3__c, Period_4__c, Period_5__c,
                            Period_6__c, Period_7__c, Period_8__c, Period_9__c, Period_10__c,
                            Period_11__c, Period_12__c, Skip_Weekends__c, Action_Plan_Template__r.Start_Date__c,
                            Description__c, Initial_Start_Date__c, Plus_Days__c
                    FROM APTTaskTemplate__c
                    WHERE Action_Plan_Template__r.Name IN :templateNames
                    ORDER BY Task_Number__c, Name, taskIndex__c ASC
            ];
        }

        return templateTaskList;
    }

    private static List<APTTaskTemplate__c> getTemplatesAccordingAptt(List<Id> selectedAptt){
        List<APTTaskTemplate__c> templateTaskList = new List<APTTaskTemplate__c>();
        templateTaskList =  [
                SELECT  Name, User__c, User__r.Name, Id,
                        Action_Plan_Template__c, Subject__c,
                        Reminder__c, SendEmail__c, Comments__c, taskIndex__c,
                        Frequency__c, Assigned_Role__c, IsMandatory__c,
                        TaskId__c, Action_Plan_Template__r.Name, Task_Number__c, Period_1__c,
                        Period_2__c, Period_3__c, Period_4__c, Period_5__c,
                        Period_6__c, Period_7__c, Period_8__c, Period_9__c, Period_10__c,
                        Period_11__c, Period_12__c, Skip_Weekends__c, Action_Plan_Template__r.Start_Date__c,
                        Description__c, Initial_Start_Date__c, Plus_Days__c
                FROM APTTaskTemplate__c
                WHERE Id IN :selectedAptt
                ORDER BY Task_Number__c, Name ,taskIndex__c ASC
        ];
        //System.debug(templateTaskList.get(0).Frequency__c);
        return templateTaskList;
    }

    private static Map<String, Id> getAllRoles(Contract__c contract){
        Map<String, Id> allRoles = new Map<String, Id>();
        List<Account_Team_And_Authorizations__c> atas = [SELECT Type__c, Responsible__c
        FROM Account_Team_And_Authorizations__c WHERE Kontrakt__c =: contract.id
        AND Area__c = 'Account_Team'];
        for (Account_Team_And_Authorizations__c a : atas) {
            allRoles.put(a.Type__c ,a.Responsible__c);
        }
        return allRoles;
    }

    private static void setDefaultFrequency(APTaskTemplate__c apt, APTTaskTemplate__c aptt, Contract__c contract){
        if (aptt.Frequency__c != null) {
            apt.Frequency__c = aptt.Frequency__c;
        }else {
            apt.Frequency__c = contract.ReportingFrequency__c;
            if (aptt.Initial_Start_Date__c == 'Closing date'){
                apt.Frequency__c = contract.Closing_Frequency__c;
            }
        }
    }

    private static List<APTaskTemplate__c> prepareNewTasks(Contract__c contract,
            List<APTTaskTemplate__c> templateTaskList, Integer index) {
        List<APTaskTemplate__c> apTaskTemplates = new List<APTaskTemplate__c>();
        List<AttachmentHeader__c> headers =  new List<AttachmentHeader__c>();
        Map<String, Id> allRoles = getAllRoles(contract);
        Map<String, String> assignedRoleTranslationApi = DependentPicklist.getPicklistApiMap(
                Account_Team_And_Authorizations__c.Type__c);

        Integer i = index;
        for (APTTaskTemplate__c aptt : templateTaskList) {

            AttachmentHeader__c attachmentHeader = new AttachmentHeader__c();
            APTaskTemplate__c apt = new APTaskTemplate__c();
            apt.Task_Number__c = aptt.Task_Number__c;
            apt.Subject__c = aptt.Subject__c;
            setDefaultFrequency(apt, aptt, contract);
            apt.Reminder__c = aptt.Reminder__c;
            apt.Action_Plan__c = null;

            apt.ActionPlanTemplate__c = aptt.Action_Plan_Template__c;
            apt.ActionPlanTemplate__r = new ActionPlanTemplate__c();
            apt.ActionPlanTemplate__r.Name = aptt.Action_Plan_Template__r.Name;
            apt.ActionPlanTemplate__r.Start_Date__c = aptt.Action_Plan_Template__r.Start_Date__c;

            ID userId = getResponsible(allRoles, aptt);
            if (userId == null){
                apt.Assigned_Role__c =  ACCOUNT_OWNER;
                apt.User__c = contract.Account_Owner_KA__c;
            }else {
                apt.Assigned_Role__c = aptt.Assigned_Role__c;
                apt.User__c = userId;
            }

            apt.Assigned_Role__c = assignedRoleTranslationApi.get(apt.Assigned_Role__c);
            //apt.Contact__c = res.contactId;
            apt.Comments__c = aptt.Comments__c;
            apt.taskIndex__c = i;
            apt.IsMandatory__c =  aptt.IsMandatory__c;
            apt.Skip_Weekends__c = aptt.Skip_Weekends__c;
            apt.Description__c = aptt.Description__c;
            apt.APT_Task__c = aptt.id;
            apt.APT_Task__r = new APTTaskTemplate__c();
            apt.APT_Task__r.Initial_Start_Date__c = aptt.Initial_Start_Date__c;
            apt.APT_Task__r.Plus_Days__c = aptt.Plus_Days__c;

            //There should be a bug because is not possible add variable myVariable dynamicaly in component controller
            //and expression then validate {!t.myVariable == true}
            //even it's possible read this expression {!t.myVariable} then
            apt.IsVisible__c = true;
            apTaskTemplates.add(apt);
            headers.add(attachmentHeader);

            setStaticPeriod(apt, aptt);
            i++;
        }
        if (!headers.isEmpty()){
            insert headers;
        }

        for (Integer apI = 0; apI < apTaskTemplates.size(); apI++) {
            APTaskTemplate__c ap = apTaskTemplates.get(apI);
            ap.AttachmentHeader__c = headers.get(apI).id;
        }

        return apTaskTemplates;
    }

    private static List<APTaskTemplate__c> prepareNewTasks(Id contractId) {
        List<APTaskTemplate__c> newTasks = new List<APTaskTemplate__c>();
        Contract__c contract = getContract(contractId);
        List<APTTaskTemplate__c> templateTaskList = getTemplatesAccordingContract(contract);
        newTasks = prepareNewTasks(contract, templateTaskList, 0);
        return newTasks;
    }


    private static void setStaticPeriod(APTaskTemplate__c apt, APTTaskTemplate__c aptt){
        String usedStaticPeriods = '';

        if (aptt.Period_1__c!=null){
            usedStaticPeriods = '1';
        }
        apt.Period_1__c = aptt.Period_1__c;

        if (aptt.Period_2__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '2';
        }
        apt.Period_2__c = aptt.Period_2__c;

        if (aptt.Period_3__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '3';
        }
        apt.Period_3__c = aptt.Period_3__c;
        if (aptt.Period_4__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '4';
        }
        apt.Period_4__c = aptt.Period_4__c;
        if (aptt.Period_5__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '5';
        }
        apt.Period_5__c = aptt.Period_5__c;
        if (aptt.Period_6__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '6';
        }
        apt.Period_6__c = aptt.Period_6__c;
        if (aptt.Period_7__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '7';
        }
        apt.Period_7__c = aptt.Period_7__c;
        if (aptt.Period_8__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '8';
        }
        apt.Period_8__c = aptt.Period_8__c;
        if (aptt.Period_9__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '9';
        }
        apt.Period_9__c = aptt.Period_9__c;
        if (aptt.Period_10__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '10';
        }
        apt.Period_10__c = aptt.Period_10__c;
        if (aptt.Period_11__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '11';
        }
        apt.Period_11__c = aptt.Period_11__c;
        if (aptt.Period_12__c!=null){
            usedStaticPeriods = usedStaticPeriods + (usedStaticPeriods.length() > 0 ? ';' : '') + '12';
        }
        apt.Period_12__c = aptt.Period_12__c;
        apt.TemplateStaticPeriods__c = usedStaticPeriods;
    }


    private static Id getResponsible(Map<String, Id> allRoles, APTTaskTemplate__c aptt){
        Id userId = null;
        if (!String.isEmpty(aptt.Assigned_Role__c)) {
            userId = allRoles.get(aptt.Assigned_Role__c);
        }
        return userId;
    }

    @AuraEnabled
    public static List<AptActionPlanController.StandardTask> getStandardTasks(Id apId) {
        Map<String, StandardTask> standardTaskMap = new  Map<String, StandardTask>();
        List<Task> tasks = [SELECT id, Status, Period__c, AP_Task__c, ActivityDate, Task_Control__c,
                Days_to_Completed__c, Description__c, Description, Accounting_Upload__c, Payroll_Upload__c,
                Overdue_Reason__c, Controlled_by__r.Name, Task_Control_Modified_Date__c
        FROM Task WHERE AP_Task__r.Action_Plan__c =: apId];
        for (Task task : tasks) {
            StandardTask sTask = standardTaskMap.get(task.AP_Task__c);
            if (sTask == null){
                sTask = new StandardTask(task.AP_Task__c);
                standardTaskMap.put(task.AP_Task__c, sTask);
            }
            sTask.tasks.add(task);
        }
        return standardTaskMap.values();
    }

    @AuraEnabled
    public static List<APTaskTemplate__c> getTasks(Id apId) {
        System.debug('aptId = ' + apId);
        List<APTaskTemplate__c> apTaskTemplates = new List<APTaskTemplate__c>();
        try {
            apTaskTemplates = AptActionPlan.getTasks(apId);
        }catch (Exception ex){
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException('AptActionPlanController.getTasks : ' + ex.getMessage());
        }
        return apTaskTemplates;
    }

    @AuraEnabled
    public static List<APTaskTemplate__c> copyTasks(Id contractId, String fiscalYear) {
        List<APTaskTemplate__c> apTaskTemplatesNew = new List<APTaskTemplate__c>();
        try{
            apTaskTemplatesNew = AptActionPlan.copyTasks(contractId, fiscalYear);
        }catch (Exception ex){
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException('AptActionPlanController.getTasks : ' + ex.getMessage());
        }
        return apTaskTemplatesNew;
    }

    @AuraEnabled
    public static List<AttachmentRow__c> getAttachments(String attachmentHeaderId) {
        System.debug('attachmentHeaderId = ' + attachmentHeaderId);
        List<AttachmentRow__c> attachmentRows = new List<AttachmentRow__c>();
        //TODO Select according ID APTaskTemplate__c.AttachmentHeader
        attachmentRows = [
                select id, File_Name__c, Error_Message__c, IsThereError__c, Sharepoint_Link__c, State__c
                from AttachmentRow__c
                where AttachmentHeader__c = :attachmentHeaderId
                order by LastModifiedDate asc
        ];
        return attachmentRows;
    }

    @AuraEnabled
    public static List<APTaskTemplate__c> savePlan(Id apId, String apTasksJSON, String delTasksJSON,
            String contractId, String fiscalYear, String planName, Boolean skipWeekend) {
        List<APTaskTemplate__c> apTaskTemplates = new List<APTaskTemplate__c>();
        try {
            apTaskTemplates = saveActionPlan(apId, apTasksJSON, delTasksJSON, contractId, fiscalYear, planName,
                    skipWeekend);
        }catch (Exception ex){
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException('AptActionPlanController.saveActionPlan : ' + ex.getMessage());
        }
        return apTaskTemplates;
    }


    private static List<APTaskTemplate__c> saveActionPlan(Id apId, String apTasksJSON, String delTasksJSON,
            String contractId, String fiscalYear, String planName, Boolean skipWeekend) {
        System.debug('Save Plan id = ' + apId);
        System.debug('DELETE Tasks: ' + delTasksJSON);
        System.debug('UPDATE INSERT: ' + apTasksJSON);
        System.debug('ContractId: ' + contractId);
        System.debug('fiscalYear: ' + fiscalYear);

        List<APTaskTemplate__c> apTasks  = (List<APTaskTemplate__c>) JSON.deserialize(apTasksJSON,
                List<APTaskTemplate__c>.class);
        if(apTasks == null){
            throw new AuraHandledException('Impossible to retrieve the tasks list. Contact your system administrator');
        }

        List<APTaskTemplate__c> delApTasks  = (List<APTaskTemplate__c>) JSON.deserialize(delTasksJSON,
                List<APTaskTemplate__c>.class);
        if(delApTasks == null){
            throw new AuraHandledException('Impossible to retrieve the tasks list for deletion. Contact your system administrator');
        }

        Contract__c contract = [SELECT id, Account__c FROM Contract__c WHERE Id =: contractId];

        List<APTaskTemplate__c> apTasksForDeletion = new List<APTaskTemplate__c>();
        List<APTaskTemplate__c> apTasksForInsert = new List<APTaskTemplate__c>();
        List<APTaskTemplate__c> apTasksForUpdate = new List<APTaskTemplate__c>();
        List<AttachmentHeader__c> apAttHeadersForDeletion = new List<AttachmentHeader__c>();


        Set<ID> idTasksForDel = new Set<ID>();
        Set<ID> idAttForDel = new Set<ID>();
        for (APTaskTemplate__c  t : delApTasks) {
            if (t.Id != null) {
                idTasksForDel.add(t.Id);
            }
            idAttForDel.add(t.AttachmentHeader__c);
        }

        System.debug('idTasksForDel = ' + idTasksForDel);
        System.debug('idAttForDel = ' + idAttForDel);

        if (!idTasksForDel.isEmpty()) {
            apTasksForDeletion = [SELECT Id FROM APTaskTemplate__c WHERE Id IN:idTasksForDel];
            delete apTasksForDeletion;
        }

        if (!idAttForDel.isEmpty()) {
            apAttHeadersForDeletion = [SELECT Id FROM AttachmentHeader__c WHERE Id IN:idAttForDel];
            delete apAttHeadersForDeletion;
        }

        ActionPlan__c plan;
        AptActionPlanUtil util;
        if (String.isEmpty(apId)){
            util = new AptActionPlanUtil(false);
            plan = new ActionPlan__c();
            plan.Name = planName;
            plan.Contract__c = contractId;
            plan.Account__c = contract.Account__c;
            plan.FiscalYear__c = fiscalYear;
            plan.SkipWeekends__c = skipWeekend;
            insert plan;
        }else {
            util = new AptActionPlanUtil(true);
            plan = [SELECT id,  SkipWeekends__c FROM ActionPlan__c WHERE id = :apId];
            plan.SkipWeekends__c = skipWeekend;
            update plan;
        }

        Map<String, String> assignedRoleTranslationVal = DependentPicklist.getPicklistValueMap(
                Account_Team_And_Authorizations__c.Type__c);

        for (APTaskTemplate__c apTaskTemplate : apTasks) {
            if (apTaskTemplate.APT_Task__r != null){
                apTaskTemplate.APT_Task__r = null;
            }
            apTaskTemplate.IsVisible__c = true;
            apTaskTemplate.User__r = null;
            if (apTaskTemplate.Assigned_Role__c != null) {
                apTaskTemplate.Assigned_Role__c = assignedRoleTranslationVal.get(
                        apTaskTemplate.Assigned_Role__c);
            }
            if (apTaskTemplate.id == null){
                apTaskTemplate.Action_Plan__c = plan.id;
                apTasksForInsert.add(apTaskTemplate);
            }else{
                apTasksForUpdate.add(apTaskTemplate);
            }
        }
        //TODO check which tasks has been changed
        if (!apTasksForUpdate.isEmpty()){
            update apTasksForUpdate;
        }

        if (!apTasksForInsert.isEmpty()) {
            System.debug(apTasksForInsert);
            insert apTasksForInsert;
        }

        List<APTaskTemplate__c> newTasks = getTasks(plan.id);

        util.generateActionPlans(newTasks, plan.id);
        return newTasks;
    }



    @AuraEnabled
    public static void saveAttachments(String attachmentHeaderId, String files){
        System.debug('saveAttachments = ' + attachmentHeaderId);
        System.debug('files = ' + files);
        List<AttachmentRow__c> attachmentRows = new List<AttachmentRow__c>();


        List<AptAttachment> fieldList = (List<AptAttachment>) JSON.deserialize(files, List<AptAttachment>.class);
        if(fieldList == null){
            throw new AuraHandledException('Impossible to retrieve the file list. Contact your system administrator');
        }

        for(AptAttachment att: fieldList){
            AttachmentRow__c attachmentRow = new AttachmentRow__c();
            attachmentRow.AttachmentHeader__c = attachmentHeaderId;
            attachmentRow.Error_Message__c = null;
            attachmentRow.File_Name__c = att.name;
            attachmentRow.FileConnectID__c = att.documentId;
            attachmentRow.IsThereError__c = false;
            attachmentRow.Sharepoint_Link__c = null;
            attachmentRow.State__c = 'PREPARED';
            attachmentRows.add(attachmentRow);
        }

        if (!attachmentRows.isEmpty()){
            insert attachmentRows;
        }
    }

    /*
    @AuraEnabled
    public static APTaskTemplate__c getNewTemplateTask(String index){
        //System.debug('getNewTemplateTask = ' + index);
        APTaskTemplate__c at = new APTaskTemplate__c();
        at.TaskIndex__c = Integer.valueOf(index);
        at.User__c = UserInfo.getUserId();
        at.IsVisible__c = true;
        at.IsMandatory__c = false;
        //at.Assigned_Role__c = 'Project Manager';

        AttachmentHeader__c attachmentHeader = new AttachmentHeader__c();
        //attachmentHeader.AP_Task_Unique_Id__c = at.TaskId__c;
        insert attachmentHeader;

        at.AttachmentHeader__c = attachmentHeader.id;
                //= new List<AttachmentHeader__c>();
        //at.AttachmentHeaders__r[0].Id = attachmentHeader.id;
        return at;
    }
    */

    private static List<APTaskTemplate__c> prepareNewTasks(String index, List<Id> selectedTasks, Id contractId) {
        List<APTaskTemplate__c> additionalTasks = new List<APTaskTemplate__c>();
        Integer i = Integer.valueOf(index);
        Contract__c contract = getContract(contractId);
        List<APTTaskTemplate__c> templateTaskList = getTemplatesAccordingAptt(selectedTasks);
        additionalTasks = prepareNewTasks(contract, templateTaskList, i);
        return additionalTasks;
    }


    @AuraEnabled
    public static List<APTaskTemplate__c> getAdditionalTasks(String index, List<Id> selectedTasks, Id contractId){
        System.debug(index);
        System.debug(selectedTasks);
        List<APTaskTemplate__c> additionalTasks = new List<APTaskTemplate__c>();
        try {
            additionalTasks = prepareNewTasks(index, selectedTasks, contractId);
        }catch (Exception ex){
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException('AptActionPlanController.getAdditionalTasks : ' + ex.getMessage());
        }
        return additionalTasks;
    }

    @AuraEnabled
    public static List<String> fetchRolePicklistValues() {
        List<String> roles = DependentPicklist.getDependentPicklistValues(Account_Team_And_Authorizations__c.Type__c,
                'Account Team');
        return roles;
    }

    /*
    @AuraEnabled
    public static String getContractId(ID apId){
        String conId;
        try {
            ActionPlan__c actionPlan = [
                    SELECT Id, Contract__c
                    FROM ActionPlan__c
                    WHERE Id = :apId
            ];
            conId = actionPlan.Contract__c;
        }catch (Exception ex){
            throw new AuraHandledException('AptActionPlanController.getContractId : ' + ex.getMessage());
        }
        return conId;
    }
    */

}