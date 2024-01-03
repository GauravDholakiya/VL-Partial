/**
 * @author Jozef
 * @date 6.2.2019.
 * @description //TODO
 */

public without sharing class AptActionPlanUtil {

    private List<Task> myTasksWithOutEmail { get; set; }
    private List<Task> myOldTasksWithEmail { get; set; }
    private List<Task> myNewTasksWithEmail { get; set; }
    private List<Task> noMoreExistTasks {get; set;}
    private List<APTaskTemplate__c> relAPTaskList { get; set; }
    private Boolean isUpdated {get; set;}

    public AptActionPlanUtil(Boolean isUpdated){
        this.isUpdated = isUpdated;
    }

    public void generateActionPlans(List<APTaskTemplate__c> aptTOTALList, Id planId) {

        //List<APTaskTemplate__c> aptList = null;
        //List<APTaskTemplate__c> aptTOTALList = new List<APTaskTemplate__c>();
        List<String> aptTOTALListId = new List<String>();
        Map<String, APTaskTemplate__c> mapAP = new Map<String, APTaskTemplate__c>();
        //Map<String, ActionPlan__c> mapIDAP = new Map<String, ActionPlan__c>();
        ActionPlan__c plan = [SELECT id, Contract__c, Contract__r.Account__c FROM ActionPlan__c WHERE id=: planId];
        Map<String, List<Task>> mapApTasks = new Map<String, List<Task>>();
        //Integer taskTemplateNameLength = APTaskTemplate__c.Name.getDescribe().getLength();

        //set of all used ActionPlanTemplates ids
        Set<Id> usedAPTemplatesId = new Set<ID>();

        this.myOldTasksWithEmail = new List<Task>();
        this.myNewTasksWithEmail = new List<Task>();
        this.myTasksWithOutEmail = new List<Task>();
        this.relAPTaskList = new List<APTaskTemplate__c>();


        for (APTaskTemplate__c t : aptTOTALList) {
            mapAP.put(t.Id, t);
        }


        addAttachmentLinks(aptTOTALList);

        //ActionPlansUtilities apUtil = new ActionPlansUtilities(baseAPlan);
        //apUtil.retrieveOwnersDataRelatedObject(tmpOIdsLIst, tmpRefType);



        for (Task task_tmp : [SELECT Id, TaskTemplateId__c, Period__c,
                Subject, Task_Number__c, AP_Task__c, Status
        FROM Task WHERE TaskTemplateId__c in:mapAP.keySet()]) {

            if (mapApTasks.containsKey(task_tmp.TaskTemplateId__c)) {
                mapApTasks.get(task_tmp.TaskTemplateId__c).add(task_tmp);
            } else {
                List<Task> lTasks = new List<Task>();
                lTasks.add(task_tmp);
                mapApTasks.put(task_tmp.TaskTemplateId__c, lTasks);
            }
        }
        //System.debug('mapApTasks -->' + mapApTasks);
        //Task t;

        //RECORD TYPE for SF TASK

        //RecordType taskRecordType = [SELECT Id FROM RecordType
        //WHERE SobjectType = 'Task' AND DeveloperName = :this.TaskRecordTypeDeveloperName
        //limit 1];

        List<ActionPlanTemplate__c> listTemplates = [SELECT Id, Name FROM ActionPlanTemplate__c
        WHERE id in :usedAPTemplatesId
        LIMIT 1000];
        Map<Id, ActionPlanTemplate__c> mapID_APTemplateWithName = new Map<Id, ActionPlanTemplate__c>( listTemplates );

        List<Task> sTasks = null;
        this.noMoreExistTasks = new List<Task>();
        Set<ID> existingTasks = new Set<ID>();
        for (APTaskTemplate__c t_t : aptTOTALList) {
            // check if task exists already
            sTasks = mapApTasks.get(t_t.Id);
            if (sTasks == null) {
                sTasks = createNewStandardTasks(t_t);
            } else {
                sTasks = getUpdatedStandardTasks(t_t, noMoreExistTasks, sTasks);
            }

            for (Task t : sTasks) {
                setTaskAccordingApt(t, t_t, plan.Contract__c, plan.Contract__r.Account__c);
                ActionPlanTemplate__c targetTemplate = mapID_APTemplateWithName.get( t_t.ActionPlanTemplate__c);
                if( targetTemplate != null ) {
                    t.Type =  targetTemplate.Name;
                }
                if (t.Id == null) {
                    t.Status = 'Not Started';
                }else{
                    //if (this.isUpdated){
                    existingTasks.add(t.id);
                    //}
                }
                if (t.Status != 'Completed' && t.Status != 'Not Applicable') {
                    this.myTasksWithOutEmail.add(t);
                }
            }
        }

        //Database.DMLOptions dmlo = new Database.DMLOptions();
        Database.DMLOptions dmlo2 = new Database.DMLOptions();

        //System.debug('myTasksWithOutEmail-->' + myTasksWithOutEmail);
        //System.debug('noMoreExistTasks-->' + noMoreExistTasks);

        if (this.myTasksWithOutEmail.size() > 0) {
            if (this.isUpdated) {
                //System.debug('upsert myTasksWithOutEmail-->' + myTasksWithOutEmail);
                upsert(this.myTasksWithOutEmail);
            } else {
                //System.debug('insert myTasksWithOutEmail-->' + myTasksWithOutEmail);
                insert(this.myTasksWithOutEmail);
            }
        }

        //if (this.isUpdated) {
        addAttachmentLinkToTask(existingTasks);
        //}else{
        //    addAttachmentLinkToNewTask();
        //TODO insertLinks
        //}


        if(this.noMoreExistTasks.size()>0){
            delete this.noMoreExistTasks;
        }

        //sendToSharePoint();
        //copyToSharePoint();
    }


    /* New tasks + new Attachments */
    /* New tasks + old Attachmntes */
    /* Existing tasks + new Attachments */
    private void addAttachmentLinkToTask(Set<ID> existingTasks){
        //System.debug('addAttachmentLinkToTask');
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        List<Task> newTasks = new List<Task>();
        Map<Id, Task> oldTasksMap = new Map<Id, Task>();

        Set<Id> aptTaskIds = new Set<Id>();
        //System.debug('existingTasksEditMode: ' + existingTasks);
        for (Task t : myTasksWithOutEmail){
            if (!existingTasks.contains(t.id)){
                //System.debug(t.AP_Task__r)
                newTasks.add(t);
                //aptTaskIds.add(t.AP_Task__c);
            } else {
                oldTasksMap.put(t.id, t);
            }
            aptTaskIds.add(t.AP_Task__c);
        }

        if(!aptTaskIds.isEmpty()) {
            //System.debug('HERE ------------> ' + aptTaskIds);
            Map<Id, Set<Id>> contentDocumentLinkMap = new Map<Id, Set<Id>>();
            loadDocumentLinkMap(contentDocumentLinkMap, aptTaskIds);
            /*
            for (ContentDocumentLink cdl : [
                    SELECT ContentDocumentId, LinkedEntityId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId in :aptTaskIds
            ]) {
                List<ContentDocumentLink> contentDocumentLinks = contentDocumentLinkMap.get(cdl.LinkedEntityId);
                if (contentDocumentLinks == null) {
                    contentDocumentLinks = new List<ContentDocumentLink>();
                    contentDocumentLinks.add(cdl);
                    contentDocumentLinkMap.put(cdl.LinkedEntityId, contentDocumentLinks);
                } else {
                    contentDocumentLinks.add(cdl);
                }
            }

             */

            if (!contentDocumentLinkMap.isEmpty()){
                //System.debug('newTasksEditMode2');
                for (Task t : newTasks){
                    if (contentDocumentLinkMap.containsKey(t.AP_Task__c)){
                        for (Id ContentDocumentId : contentDocumentLinkMap.get(t.AP_Task__c)){
                            cdls.add(AptContentHubRepository.createContentDocumentLink(ContentDocumentId,t.id));
                        }
                    }
                }

                if(!aptTaskIds.isEmpty() && !oldTasksMap.isEmpty()){
                    Set<ID> taskIds = oldTasksMap.keySet();

                    Map<Id, Set<Id>> taskDocumentLinkMap = new Map<Id, Set<Id>>();
                    loadDocumentLinkMap(taskDocumentLinkMap, taskIds);


                    for (Id taskId : taskIds){
                        Task t = oldTasksMap.get(taskId);
                        Set<Id> apContentDocIds =  contentDocumentLinkMap.get(t.AP_Task__c);
                        Set<Id> tContentDocIds =  taskDocumentLinkMap.get(t.id);

                        if (apContentDocIds != null) {
                            for (Id apContentDocId : apContentDocIds){
                                if(tContentDocIds == null || !tContentDocIds.contains(apContentDocId)){
                                    cdls.add(AptContentHubRepository.createContentDocumentLink(apContentDocId,taskId));
                                }
                            }
                        }
                        //TODO remove not existing anymore ap documents
                    }
                }

                if (!cdls.isEmpty()){
                    insert cdls;
                }


            }

        }

        /*
        if (!newTasks.isEmpty()){
            System.debug('newTasksEditMode1');
            Map<Id,List<ContentDocumentLink>> contentDocumentLinkMap = new Map<Id,List<ContentDocumentLink>>();
            for(ContentDocumentLink cdl: [ Select ContentDocumentId, LinkedEntityId from ContentDocumentLink
            where LinkedEntityId in : aptTaskIds]){
                List<ContentDocumentLink> contentDocumentLinks = contentDocumentLinkMap.get(cdl.LinkedEntityId);
                if(contentDocumentLinks == null) {
                    contentDocumentLinks = new  List<ContentDocumentLink>();
                    contentDocumentLinks.add(cdl);
                    contentDocumentLinkMap.put(cdl.LinkedEntityId,contentDocumentLinks);
                }else {
                    contentDocumentLinks.add(cdl);
                }
            }
            if (!contentDocumentLinkMap.isEmpty()){
                System.debug('newTasksEditMode2');
                for (Task t : newTasks){
                    if (contentDocumentLinkMap.containsKey(t.AP_Task__c)){
                        for (ContentDocumentLink cdl : contentDocumentLinkMap.get(t.AP_Task__c)){
                            cdls.add(AptContentHubRepository.createContentDocumentLink(cdl.ContentDocumentId,t.id));
                        }
                    }
                }
                if (!cdls.isEmpty()){
                    insert cdls;
                }
            }
        }

         */
    }

    /*
    private Set<ID> getTasksDocIds(List<ContentDocumentLink> tCdls){
        Set<ID> docIds = new Set<ID>();
        for (ContentDocumentLink cd : docIds){

        }

    }
    */



    private void loadDocumentLinkMap(Map<Id, Set<Id>> documentLinkMap, Set<Id> entityIds){
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink WHERE LinkedEntityId IN :entityIds]){

            Set<Id> taskDocumentLinks = documentLinkMap.get(cdl.LinkedEntityId);
            if (taskDocumentLinks == null) {
                taskDocumentLinks = new Set<Id>();
                taskDocumentLinks.add(cdl.ContentDocumentId);
                documentLinkMap.put(cdl.LinkedEntityId, taskDocumentLinks);
            } else {
                taskDocumentLinks.add(cdl.ContentDocumentId);
            }
        }
    }

    /*
    private void loadDocumentLinkMap(Map<Id, List<ContentDocumentLink>> documentLinkMap, Set<Id> entityIds){
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink WHERE LinkedEntityId IN :entityIds]){

            List<ContentDocumentLink> taskDocumentLinks = documentLinkMap.get(cdl.LinkedEntityId);
            if (taskDocumentLinks == null) {
                taskDocumentLinks = new List<ContentDocumentLink>();
                taskDocumentLinks.add(cdl);
                documentLinkMap.put(cdl.LinkedEntityId, taskDocumentLinks);
            } else {
                taskDocumentLinks.add(cdl);
            }
        }
    }
     */


    private List<Task> createNewStandardTasks(APTaskTemplate__c t_t) {
        List<Task> sTasks = new List<Task>();
        if (t_t.Period_1__c != null) addNewTask(sTasks, t_t.Period_1__c, 1, t_t.Reminder__c);
        if (t_t.Period_2__c != null) addNewTask(sTasks, t_t.Period_2__c, 2, t_t.Reminder__c);
        if (t_t.Period_3__c != null) addNewTask(sTasks, t_t.Period_3__c, 3, t_t.Reminder__c);
        if (t_t.Period_4__c != null) addNewTask(sTasks, t_t.Period_4__c, 4, t_t.Reminder__c);
        if (t_t.Period_5__c != null) addNewTask(sTasks, t_t.Period_5__c, 5, t_t.Reminder__c);
        if (t_t.Period_6__c != null) addNewTask(sTasks, t_t.Period_6__c, 6, t_t.Reminder__c);
        if (t_t.Period_7__c != null) addNewTask(sTasks, t_t.Period_7__c, 7, t_t.Reminder__c);
        if (t_t.Period_8__c != null) addNewTask(sTasks, t_t.Period_8__c, 8, t_t.Reminder__c);
        if (t_t.Period_9__c != null) addNewTask(sTasks, t_t.Period_9__c, 9, t_t.Reminder__c);
        if (t_t.Period_10__c != null) addNewTask(sTasks, t_t.Period_10__c, 10, t_t.Reminder__c);
        if (t_t.Period_11__c != null) addNewTask(sTasks, t_t.Period_11__c, 11, t_t.Reminder__c);
        if (t_t.Period_12__c != null) addNewTask(sTasks, t_t.Period_12__c, 12, t_t.Reminder__c);
        return sTasks;
    }

    private List<task> getUpdatedStandardTasks(APTaskTemplate__c t_t, List<Task> noMoreExistTasks, List<Task> sTasks) {
        List<task> updatedTasks = new List<task>();
        for (Task task : sTasks) {
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_1__c, 1, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_2__c, 2, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_3__c, 3, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_4__c, 4, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_5__c, 5, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_6__c, 6, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_7__c, 7, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_8__c, 8, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_9__c, 9, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_10__c, 10, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_11__c, 11, t_t.Reminder__c );
            updateStandardTask(updatedTasks, noMoreExistTasks, task, task.Period__c, t_t.Period_12__c, 12, t_t.Reminder__c );

        }
        //System.debug('updatedTasks after update -->' + updatedTasks);
        updatedTasks.addAll(createStandardTasks(t_t, updatedTasks));
        //System.debug('updatedTasks after insert -->' + updatedTasks);
        return updatedTasks;
    }

    private List<Task> createStandardTasks(APTaskTemplate__c t_t, List<Task> updatedTasks) {
        List<Task> sTasks = new List<Task>();
        if (t_t.Period_1__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_1__c, 1, t_t.Reminder__c);
        if (t_t.Period_2__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_2__c, 2, t_t.Reminder__c);
        if (t_t.Period_3__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_3__c, 3, t_t.Reminder__c);
        if (t_t.Period_4__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_4__c, 4, t_t.Reminder__c);
        if (t_t.Period_5__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_5__c, 5, t_t.Reminder__c);
        if (t_t.Period_6__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_6__c, 6, t_t.Reminder__c);
        if (t_t.Period_7__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_7__c, 7, t_t.Reminder__c);
        if (t_t.Period_8__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_8__c, 8, t_t.Reminder__c);
        if (t_t.Period_9__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_9__c, 9, t_t.Reminder__c);
        if (t_t.Period_10__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_10__c, 10, t_t.Reminder__c);
        if (t_t.Period_11__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_11__c, 11, t_t.Reminder__c);
        if (t_t.Period_12__c != null) addNewTask(updatedTasks, sTasks, t_t.Period_12__c, 12, t_t.Reminder__c);
        //System.debug('createStandardTasks.sTasks --> ' + sTasks);
        return sTasks;
    }

    private void addNewTask(List<Task> updatedTasks, List<Task> sTasks, Date aDate, Decimal period, Boolean reminder) {
        //Add new task according APTaskTemplate__c periods
        for(Task uTask: updatedTasks){
            if (uTask.Period__c == period){
                return;
            }
        }
        Task t = new Task();
        setTask(t, aDate, period, reminder);
        sTasks.add(t);
    }

    private void updateStandardTask(List<task> updatedTasks, List<Task> noMoreExistTasks, Task task, Decimal taskPeriod, Date apTaskDatePeriod, Decimal period, Boolean reminder ){
        //Delete or Update existing task accoriding APTaskTemplate__c periods
        if (taskPeriod == period) {
            //System.debug('taskPeriod ->' + taskPeriod);
            if (apTaskDatePeriod == null) {
                noMoreExistTasks.add(task);
            } else {
                setTask(task, apTaskDatePeriod, period, reminder );
                //System.debug('updatedTasks.add(task) -->' + task);
                updatedTasks.add(task);
            }
        }
    }

    private void addNewTask(List<Task> sTasks, Date aDate, Decimal period, Boolean reminder ) {
        Task t = new Task();
        setTask(t, aDate, period, reminder );
        sTasks.add(t);
    }

    public static void setTask(Task t, Date aDate, Decimal period, Boolean reminder) {
        if (reminder == true) {
            //one week before date
            Date weekBefore = aDate.addDays(-7);
            DateTime dt = datetime.newInstance(weekBefore.year(), weekBefore.month(),weekBefore.day(), 12,0,0);
            t.ReminderDateTime = dt;
            t.isReminderSet = true;
        }
        t.ActivityDate = aDate;
        t.Period__c = period;
    }

    public static void setTaskAccordingApt(Task t, APTaskTemplate__c t_t,
            Id contractId, Id accountId){
        t.Subject = t_t.Subject__c;
        t.Task_Number__c = t_t.Task_Number__c;
        //if is mandatory high else Normal
        if( t_t.IsMandatory__c == true ) {
            t.Priority = 'High';
        }
        else {
            t.Priority = 'Normal';
        }
        //t.Priority = t_t.Priority__c;

        // Do not change assigned to field if it has been manually updated
        // and the task template does not have custom owner checked
        //if (!t.Manually_updated__c || !t_t.Custom_Owner__c) {
        t.OwnerId = t_t.User__c;
        //    t.Manually_updated__c = False;
        //}

        t.TaskTemplateId__c = t_t.Id;
        t.AP_Task__c = t_t.Id;
        t.Task_Number__c = t_t.Task_Number__c;


        if (t_t.Comments__c != null) {
            t.Description = t_t.Comments__c;
        }

        if (t_t.Description__c != null) {
            t.Description__c = t_t.Description__c;
        }

        //TODO t.RecordTypeId = taskRecordType.Id;

        t.WhatId = contractId;//plan.Contract__c;
        t.Account__c = accountId;//plan.Contract__r.Account__c;
    }

    private void addAttachmentLinks(List<APTaskTemplate__c> newTasks ){
        //System.debug('addAttachmentLinks');
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        ////cdls.add(AptContentHubRepository.createContentDocumentLink(att.documentId,t.id));
        Map<ID,Set<ID>> headerCds = new Map<ID,Set<ID>>();
        Map<ID,Set<ID>> atCds = new Map<ID,Set<ID>>();

        Set<ID> hIds = new Set<ID>();
        Set<ID> atIds = new Set<ID>();
        if (!newTasks.isEmpty()) {
            for (APTaskTemplate__c at : newTasks) {
                hIds.add(at.AttachmentHeader__c);
                atIds.add(at.id);
            }

            List<ContentDocumentLink> cdHeaders = [
                    SELECT
                            ContentDocumentId,
                            Id,
                            IsDeleted,
                            LinkedEntityId,
                            ShareType,
                            SystemModstamp,
                            Visibility
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :hIds
            ];


            List<ContentDocumentLink> cdApTasks = [
                    SELECT
                            ContentDocumentId,
                            Id,
                            IsDeleted,
                            LinkedEntityId,
                            ShareType,
                            SystemModstamp,
                            Visibility
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :atIds
            ];

            for (ContentDocumentLink cd : cdApTasks) {
                Set<ID> docs = atCds.get(cd.LinkedEntityId);
                if (docs == null) {
                    docs = new Set<ID>();
                    docs.add(cd.ContentDocumentId);
                    atCds.put(cd.LinkedEntityId, docs);
                } else {
                    docs.add(cd.ContentDocumentId);
                }
            }


            for (ContentDocumentLink cd : cdHeaders) {
                Set<ID> docs = headerCds.get(cd.LinkedEntityId);
                if (docs == null) {
                    docs = new Set<ID>();
                    docs.add(cd.ContentDocumentId);
                    headerCds.put(cd.LinkedEntityId, docs);
                } else {
                    docs.add(cd.ContentDocumentId);
                }
            }

            Map<ID, ID> docApt = new Map<ID, ID>();

            for (APTaskTemplate__c at : newTasks) {
                if (at.AttachmentHeader__c != null) {
                    Set<ID> docs = headerCds.get(at.AttachmentHeader__c);
                    if (docs != null) {
                        for (ID docId : docs) {
                            ID atId = docApt.get(docId);
                            if (atId != at.id) {
                                Set<ID> existDocs = atCds.get(at.id);
                                if (existDocs == null || (!existDocs.contains(docId))) {
                                    cdls.add(AptContentHubRepository.createContentDocumentLink(docId, at.id));
                                    docApt.put(docId, at.id);
                                }
                            }
                        }
                    }
                }
            }
        }

        if (!cdls.isEmpty()){
            insert cdls;
        }

    }

}