/**
 * @author Jozef 
 * @date 6.9.2019.
 * @description //TODO
 */

@IsTest
private class AptFilesListControllerTest {

    @IsTest
    static void fetchFilesTest() {
        Task task = new Task();
        insert task;

        ContentVersion contentVersionInsert = AptUtilDataTest.createContentVersion();

        AttachmentHeader__c attachmentHeader = AptUtilDataTest.createAttachmentHeader();
        attachmentHeader.Standard_Task_Id__c = task.id;
        update attachmentHeader;
        String relatedRecordId = task.id;

        ContentVersion cv = [SELECT id, ContentDocumentId FROM ContentVersion WHERE id=:contentVersionInsert.id];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = task.id;
        cdl.ShareType = 'V';
        insert cdl;

        Test.startTest();
        AptFilesListController.fetchFiles(relatedRecordId);
        Test.stopTest();
    }
}