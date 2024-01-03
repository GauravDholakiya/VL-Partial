public class CreateAccountec {
    
    public static void checkconditions(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {	 
        try
        {
            system.debug('INSIDE CHECK CONDITIONS METHOD');
            List<account> aclist = new List<account>();
            List<account> accdeletelist = new List<account>();
            List<account> accupdatelist = new List<account>();
            for (Id id : newItems.keySet()) {
                Account oldAccount = (Account)oldItems.get(id);
                Account newAccount = (Account)newItems.get(id);
                
                
                // condition for Create
                if(newAccount.Country2__c == 'SE - Sweden' && newAccount.Firm__c == 'VIEW Ledger AB' && 
                   newAccount.Accounting_Channel_URL__c !=NULL && newAccount.Payroll_Channel_URL__c !=NULL 
                   && newAccount.Accountec_UUID__c == NULL 
                   && newAccount.SiteURL__c !=NULL 
                   && newAccount.SPGroupID__c !=NULL
                   && oldAccount.Accounting_Channel_URL__c != newAccount.Accounting_Channel_URL__c
                   && oldAccount.Payroll_Channel_URL__c != newAccount.Payroll_Channel_URL__c
                   && oldAccount.Accounting_Channel_URL__c == Null
                   && oldAccount.Payroll_Channel_URL__c == Null
                   && newAccount.Org_Number__c != NULL
                   && newAccount.CreateCalloutAPI__c == false) 
                {
                    
                    aclist.add(newAccount);
                    system.debug('List to pass from apex to queueable for creation->'+aclist);
                }
                // condition for Delete 
                if(newAccount.Accountec_UUID__c != NULL && newAccount.Country2__c == 'SE - Sweden'
                   && newAccount.Org_Number__c != NULL && newAccount.Deactivated__c == true && oldAccount.Deactivated__c == false 
                   && newAccount.DeleteCalloutAPI__c == false)
                {
                    //call queueable AccountecDeleteQueueable
                    accdeletelist.add(newAccount);
                    system.debug('List to pass from apex to queueable for deletion'+accdeletelist);
                }
                // condition for Update field
                if( newAccount.Country2__c == 'SE - Sweden' 
                   && oldAccount.MailNickName__c != newAccount.MailNickName__c
                   && oldAccount.SiteURL__c != newAccount.SiteURL__c
                   && oldAccount.TeamEmail__c != newAccount.TeamEmail__c
                   && newAccount.Org_Number__c != NULL
                   && newAccount.Accountec_UUID__c != NULL
                   && newAccount.Field_UUID__c != NULL
                   && oldAccount.MailNickName__c != NULL
                   && oldAccount.SiteURL__c != NULL
                   && oldAccount.TeamEmail__c != NULL
                   )
                {
                    accupdatelist.add(newAccount);
                    system.debug('List to pass from apex to queueable for Update'+accupdatelist);
                }
                
            }
            
            if(aclist.size() > 0)
            {	
                
                List<List<Account>> groupOf45Accounts = (List<List<Account>>) SplitList.doPartions(aclist, 20, List<List<Account>>.class);
                system.debug('list size->'+groupOf45Accounts.size());
                
                for(List<Account> innerList : groupOf45Accounts)
                {
                    
                    system.debug('list size for passing to queueable->'+innerList.size());
                    // then pass to schedulable
                    if(Limits.getQueueableJobs() >= 1)
                    {
                        DateTime dt = System.now(); // DateTime.now(); 
                        DateTime adjustedDt = dt.addSeconds(5);
                        
                        String nextFireTime = adjustedDt.second() + ' ' + adjustedDt.minute() + ' ' + adjustedDt.hour() + ' * * ?';
                        System.schedule('Schedule queueable class',nextFireTime,new AccountecSchedulable(innerList,'Insert'));                    
                        
                    }
                    else
                    {
                        System.enqueueJob(new AccountecQueueable(innerList));
                    }
                }
                
            }
            if(accdeletelist.size() > 0)
            {
                List<List<Account>> groupOf45Accounts = (List<List<Account>>) SplitList.doPartions(accdeletelist, 20, List<List<Account>>.class);
                system.debug('list size for delete->'+groupOf45Accounts.size());
                
                for(List<Account> innerList : groupOf45Accounts)
                {
                    
                    system.debug('list size for(delete) passing to queueable->'+innerList.size());
                    // then pass to schedulable
                    if(Limits.getQueueableJobs() >= 1)
                    {
                        DateTime dt = System.now(); // DateTime.now();  
                        DateTime adjustedDt = dt.addSeconds(5);
                        
                        String nextFireTime = adjustedDt.second() + ' ' + adjustedDt.minute() + ' ' + adjustedDt.hour() + ' * * ?';
                        System.schedule('Schedule queueable class',nextFireTime,new AccountecSchedulable(innerList,'Delete'));                    
                        
                    }
                    else
                    {
                        System.enqueueJob(new AccountecDeleteQueueable(innerList));
                    }
                }
                
                
            }
            if(accupdatelist.size() > 0)
            {
                List<List<Account>> groupOf45Accounts = (List<List<Account>>) SplitList.doPartions(accupdatelist, 20, List<List<Account>>.class);
                system.debug('list size for update->'+groupOf45Accounts.size());
                
                for(List<Account> innerList : groupOf45Accounts)
                {
                    
                    system.debug('list size for(update) passing to queueable->'+innerList.size());
                    // then pass to schedulable
                    if(Limits.getQueueableJobs() >= 1)
                    {
                        DateTime dt = System.now(); // DateTime.now();  
                        DateTime adjustedDt = dt.addSeconds(5);
                        
                        String nextFireTime = adjustedDt.second() + ' ' + adjustedDt.minute() + ' ' + adjustedDt.hour() + ' * * ?';
                        System.schedule('Schedule queueable class',nextFireTime,new AccountecSchedulable(innerList,'Update'));                    
                        
                    }
                    else
                    {
                        System.enqueueJob(new AccountecUpdateQueueable(innerList));
                    }
                }
                
            }   
        }catch(Exception e)
        {
            System.debug('Exception : ' + e.getMessage());
        }
        
    }
    
}