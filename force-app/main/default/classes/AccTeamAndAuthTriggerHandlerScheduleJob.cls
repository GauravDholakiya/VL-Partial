global class AccTeamAndAuthTriggerHandlerScheduleJob implements Schedulable{
    
    // Define variables to hold the list of records to process and the type of operation to perform
    list<Account_Team_And_Authorizations__c> accTeamAuthLst = new list<Account_Team_And_Authorizations__c>();
    private String operationType;
    
    // Constructor that takes the list of records to process and the operation type as parameters
    global AccTeamAndAuthTriggerHandlerScheduleJob(list<Account_Team_And_Authorizations__c> accTeamAuthLst, String operationType){
        // Set the class variables to the values passed in as parameters
        this.accTeamAuthLst = accTeamAuthLst;
        this.operationType = operationType;
        system.debug(' In scheduler Operation type-->'+ operationType);
        system.debug(' In scheduler lst sp Id-->'+ accTeamAuthLst[0].Kontrakt__r.Account__r.SPGroupID__c);
        system.debug('In scheduler Email-->'+accTeamAuthLst[0].Responsible__r.Email);
    }
    
     // Method that runs when the job is executed
    global void execute(SchedulableContext sc) {
        try {
            if(operationType == 'Insert'){
                AccTeamAndAuthTriggerHandlerQueueablecls Queue = new AccTeamAndAuthTriggerHandlerQueueablecls(accTeamAuthLst, operationType);
                ID jobID = System.enqueueJob(Queue);
             }
            else if(operationType == 'Delete'){
                AccTeamAndAuthDeleteQueueable Queue = new AccTeamAndAuthDeleteQueueable(accTeamAuthLst,operationType);
                ID jobID = System.enqueueJob(Queue);
             }
            // Abort the job once the job is queued
            System.abortJob(sc.getTriggerId());
        } catch(Exception ex) {
            // log the exception or send an email
            ContractTriggerhandler.sendErrorMail('Exception occurred while processing the schedule job', ex.getMessage(), 'EXC');
        }
    }
}