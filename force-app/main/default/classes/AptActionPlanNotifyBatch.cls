/**
 * Created by jozef on 17. 5. 2023.
 */

public class AptActionPlanNotifyBatch implements Database.Batchable<sObject>,  Database.Stateful {
    /*
    The Account Owner must be notified 10 days in advance before a new "Action Plan"
    is created automatically, so that he can stop the process if the customer does not
    wants a new Action Plan
     */
    private Action_Plan_Automation__mdt conf;
    private CustomNotificationType notifyType;
    private String fiscalYear;
    private String currentYear;

    public AptActionPlanNotifyBatch(Action_Plan_Automation__mdt conf){
        this.conf = conf;
        this.notifyType = [SELECT Id FROM CustomNotificationType
            WHERE DeveloperName = 'Action_Plan_Creation_Notification'];
    }

    public Iterable<sObject> start(Database.BatchableContext param1) {
        Integer thisYear = System.today().year();
        currentYear = String.valueOf(thisYear);
        fiscalYear = String.valueOf(thisYear + 1);
        return Database.query(AptActionPlanCreationBatch.allContractsQuery);
    }

    public void execute(Database.BatchableContext param1, List<Contract__c> contracts) {
        //https://www.forcetrails.com/2020/08/send-custom-notification-using-apex.html
        for (Contract__c contract : contracts) {
            //if Plan does not exist yet
            if (AptActionPlanCreationBatch.isContractEligibleToHaveNewPlan(contract, this.currentYear)){
                if (contract.Account__r.Owner.IsActive == true) {
                    sendNotification(contract, contract.Account__r.OwnerId);
                }
            }
        }
    }

    private void sendNotification(Contract__c contract, ID userId){
        //Action Plan for fiscal year {0} for Contract {1} is going to be created within {2} days
        List<Object> parameters = new List<Object> {fiscalYear, contract.Name, conf.Number_of_days_before_creation__c };
        String notifyBody = String.format(conf.Notification_Body__c, parameters);
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setBody(notifyBody);
        notification.setTitle(conf.Notification_Title__c);
        notification.setNotificationTypeId(notifyType.id);
        notification.setTargetId(contract.id);
        notification.send(new Set<String> {userId});
    }

    public void finish(Database.BatchableContext param1) {

    }


}