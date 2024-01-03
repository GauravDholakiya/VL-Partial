global class AccountecCreateQueueable implements Queueable , Database.AllowsCallouts {
	
	Map<Id, SObject> accountNewMAP = new Map<Id, SObject>();
    Map<Id, SObject> accountOldMAP = new Map<Id, SObject>();
    
    global AccountecCreateQueueable(Map<Id, SObject> accountCLSNewMap,Map<Id, SObject> accountCLSOldMap)
    {
        this.accountNewMAP = accountCLSNewMap;
        this.accountOldMAP = accountCLSOldMap;
    }
    
    global void execute(QueueableContext context) 
    {
        for( Id accId : accountNewMAP.keySet() )
        {
            Account newAccount = (Account)accountNewMAP.get(accId);
            Account oldAccount = (Account)accountOldMAP.get(accId);
            
            if( newAccount.Country2__c == 'SE - Sweden' && newAccount.SiteURL__c !=NULL && newAccount.Accounting_Channel_URL__c !=NULL && newAccount.Payroll_Channel_URL__c !=NULL && newAccount.Accountec_UUID__c !=NULL  && oldAccount.SiteURL__c != newAccount.SiteURL__c )
            {
              //  AccountechAPICallout.makeCallout();
            } 
        }
    }
}