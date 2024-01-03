public class AccountTeamAndAuthCallOutHandller {
    
    // This method will run asynchronously and make a callout to an external service
    @future(Callout=true)
    public static void addMembersAndOwners(String body,String GroupId) {
        try {
            // Retrieve AzureAD credentials from a custom object
            AzureAD_Credential__c objAzureCredential = [Select DevAPIEndPoint__c, ClientId__c, ClientSecretKey__c,Salesforce_ClientId__c,Salesforce_ClientSecret__c FROM AzureAD_Credential__c];
            
            // Retrieve AzureAD credentials from a custom object
            String endpoint = objAzureCredential.DevAPIEndPoint__c + 'api/UserManagement/UserManagement';
            String authorization = objAzureCredential.Salesforce_ClientId__c + objAzureCredential.Salesforce_ClientSecret__c;
            
            // Make the callout to the external service and capture the response
            HttpResponse response = GlobalAPICallOut.makeCallout(body, endpoint, 'POST', authorization);
            String responseBody = response.getBody();
            Integer statusCode = response.getStatusCode();
            String statusMessage = response.getStatus();
            
            System.debug('responseBody: ' + responseBody);
            System.debug('statusCodeTeam: ' + statusCode);
            System.debug('statusMessage: ' + statusMessage);
            
            // Log the response information to a custom object
            CreateCustomLogHandler.addCustomlogUserManagement(responseBody,statusCode,statusMessage,GroupId);
        }catch (Exception e) {
            // Handle the exception here
            System.debug('Exception caught: ' + e.getMessage());
            
        }
    }       
}