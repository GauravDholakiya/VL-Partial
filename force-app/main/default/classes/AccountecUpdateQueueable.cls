global class AccountecUpdateQueueable implements Queueable , Database.AllowsCallouts {
    
    List<Account> accountsToProcess = new List<Account>();
    global AccountecUpdateQueueable(List<Account> accountsToProcess) {
        this.accountsToProcess = accountsToProcess;
    }
    
    global void execute(QueueableContext context)
    {
        try
        {
            for(Account ac:accountsToProcess)
            {	
                Map<String, Object> requestBody = new Map<String, Object>();
                requestBody.put('field','Other');
                requestBody.put('value',ac.SiteURL__c+ac.Accounting_Channel_URL__c+'*'+ac.SPGroupID__c);
                
              //  string AccessToken =  AccountechAPICallout.RefreshToken();
             //   system.debug('Access Token in UPDATE Queueable->'+AccessToken);
                //Make callout for Update Customer
              //  AccountechAPICallout.updatefields(JSON.serialize(ac),'PUT',AccessToken,JSON.serialize(requestBody));
                
            }
        }catch(Exception e)
        {
            system.debug('An exception occurred: ' + e.getMessage());
        }
        
    }
}