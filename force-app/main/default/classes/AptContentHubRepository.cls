/**
 * @author Jozef 
 * @date 7.2.2019.
 * @description //TODO
 */

public with sharing class AptContentHubRepository {

    public static ContentDocumentLink createContentDocumentLink(ID contentDocumentId, ID entitiId){
        System.debug('createContentDocumentLink ' + contentDocumentId + ' : ' + entitiId);
        ContentDocumentLink link = new ContentDocumentLink();
        link.LinkedEntityId = entitiId;
        link.ContentDocumentId = contentDocumentId;
        link.ShareType = 'V';
        link.Visibility = 'AllUsers';
        return link;
    }


}