global class AccountecSchedulable  implements Schedulable {
    
    List<Account> listAccount = new List<Account>();
    String optype;
    
    global AccountecSchedulable(List<Account> accountlist, string operationType)
    {
        this.listAccount = accountlist;
        this.optype = operationType;
    }
    
    global void execute(SchedulableContext sc) 
    {
        if(optype == 'Insert')
        {
            system.debug('for Insert queueable');
            System.enqueueJob(new AccountecQueueable(listAccount));
        }
        else if(optype == 'Delete')
        {
            system.debug('for Delete queueable');
            System.enqueueJob(new AccountecDeleteQueueable(listAccount));
        }
        else if(optype == 'Update')
        {
            system.debug('for Update queueable');
            System.enqueueJob(new AccountecUpdateQueueable(listAccount));
            
        }
    }
}