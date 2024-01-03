trigger shareFileToAdmin on ContentVersion (before Insert,after insert,after update) {
    User user = [SELECT Id,Name,Email FROM User WHERE Email = 'svc_salesforce@viewledger.com'];
    public static String Operation_Type = '';
    if(Trigger.isBefore && Trigger.isInsert){
        for(ContentVersion con : Trigger.New){
            if(con.FirstPublishLocationId != null){
                String myIdPrefix = String.valueOf(con.FirstPublishLocationId).substring(0,3);
                if(myIdPrefix.contains('001') || myIdPrefix.contains('00T')){
                    if(!con.IsDeleted__c){
                        con.IsDeleted__c = true;
                    }
                }
            }
        }
    }
    if(Trigger.isAfter && Trigger.isInsert){
        Operation_Type = 'isInsert';
        sharedocumenthelpermeth(Trigger.New,null);
        
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        Operation_Type = 'isUpdate';
        sharedocumenthelpermeth(Trigger.New,Trigger.oldMap);
        
    }
    
    public static void sharedocumenthelpermeth(List<ContentVersion> newdocuments,Map<Id,ContentVersion> olddocuments){
             
       List<ContentDocumentLink> conDocuList = new List<ContentDocumentLink>();
            for(ContentVersion con : newdocuments){
                System.debug('deleted : '+con.IsDeleted__c);
                if(con.IsDeleted__c){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = con.ContentDocumentId;
                    cdl.LinkedEntityId = user.Id;
                    cdl.ShareType = 'C';
                    conDocuList.add(cdl);
                }
            }
        
        try{
            System.debug('conDocuList : '+conDocuList);
            insert conDocuList;
        }
        catch(System.DmlException ex){
            System.debug('Insertion Failed:  '+ex.getMessage());
        }
    }
}