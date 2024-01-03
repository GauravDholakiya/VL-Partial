global class AccountecDeleteQueueable implements Queueable , Database.AllowsCallouts{
    
    List<Account> accountsToProcess = new List<Account>();
    public AccountecDeleteQueueable(List<Account> accountsToProcess) {
        system.debug('INSIDE DELETE QUEUEABLE CONSTRUCTOR');
        this.accountsToProcess = accountsToProcess;
    }
    
    global void execute(QueueableContext context) 
    {
        try
        {
            system.debug('INSIDE DELETE QUEUEABLE EXECUTE');
            for(Account ac:accountsToProcess)
            {	
                
             //   string AccessToken =  AccountechAPICallout.RefreshToken();
              //  system.debug('Access Token in Queueable->'+AccessToken);
                //Make callout for Delete Customer
                //AccountechAPICallout.deleteCustomer(ac.id,ac.Accountec_UUID__c,AccessToken,'DELETE'); 
                
            }
        }catch(Exception e)
        {
            system.debug('An exception occurred: ' + e.getMessage());
        }
        
    }
}