public with sharing class MetadataDeploy implements Metadata.DeployCallback{
    
    public static String updateCustomMetadata(string newAccessToken,string newRefreshToken, String newValidUntill)
    {
        try {
            system.debug('INSIDE METADATA UPDATE METHOD');
            //retrieving custom metadata records, using the first record .
            AccountechAPI__mdt tcm = getMetaDataRecords()[0];  
            Id customMetadataId = tcm.Id;
            
            system.debug('CustomMetadata Id ' + customMetadataId);
            
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            
            customMetadata.fullName = 'AccountechAPI.Accountec_Credentials'; //custom metadata name which we want to update   
            customMetadata.label = 'Accountec Credentials';
            
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue(); 
            customField.field = 'AcessToken__c';
            customField.value = newAccessToken;
            customMetadata.values.add(customField);//adding the changes to list of changes to be deployed for 'Access Token'
            
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue(); 
            customField1.field = 'Refresh_Token__c';
            customField1.value = newRefreshToken;
            customMetadata.values.add(customField1);//adding the changes to list of changes to be deployed for 'Refresh Token'
            
            Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue(); 
            customField2.field = 'Valid_Untill__c';
            customField2.value = newValidUntill;
            customMetadata.values.add(customField2);//adding the changes to list of changes to be deployed for 'Valid Untill'
            
            system.debug('customMetadata->'+customMetadata);            
            
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            system.debug('mdContainer->'+mdContainer);
            
            MetadataDeploy callback = new MetadataDeploy();
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            
            system.debug('jobId is ' + jobId);
            
            return 'Success';
            
        } catch (Exception e) {
            
            return e.getMessage();
        }
        
    }
    
    
    public static list<AccountechAPI__mdt> getMetaDataRecords()
    {
        list<AccountechAPI__mdt> tcm = [Select Id, label FROM AccountechAPI__mdt];
        
        return tcm;
    }
    
    
    // find all sObjects available in the organization
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if(result.status == Metadata.DeployStatus.SUCCEEDED)
        {
            //success
            System.debug(' ===>'+ result);
        }else{
            //not success
            System.debug(' ===> fail '+ result);
        }
        
    }
}