/**
 * Created by jozef on 18. 5. 2023.
 */

public class AptActionPlanCreationBatch implements Database.Batchable<sObject>, Database.Stateful{
    public class LimitException extends Exception {}
    private String fiscalYear;
    private String currentYear;
    private Boolean isError;
    private Integer numRowsInOneTransaction;
    private Integer CustomFiscalYear;

    public static String allContractsQuery = 'SELECT id, Account__r.OwnerId, Name, OwnerId, Account__c, ' +
            'Account__r.Name, Scope__c, FiscalYearStart__c,  Account__r.Owner.IsActive, \n' +
            'StartDate__c, ReportingFrequency__c, PayrollDate__c, ReportingDate__c,\n' +
            'RecordType.Name, Account_Owner_KA__c, CloseDate__c,\n' +
            'Year_end_reporting_date__c, Fiscal_Year_End__c,\n' +
            '( SELECT id, FiscalYear__c FROM Action_Plans__r ' +
            'WHERE FiscalYear__c =: fiscalYear OR FiscalYear__c =: currentYear) ' +
            'FROM Contract__c ' +
            'WHERE Account__c != NULL ' +
            'AND Do_Not_Create_Action_Plan_Automatically__c = false ' +
            'AND Account__r.Deactivated__c = false ' +
            'AND RecordType.DeveloperName  = \'Operational\'';

    public Iterable<sObject> start(Database.BatchableContext param1) {
        if (customFiscalYear == null){
            Integer thisYear = System.today().year();
            currentYear = String.valueOf(thisYear);
            fiscalYear = String.valueOf(thisYear + 1);
        }else {
            currentYear = String.valueOf(customFiscalYear - 1);
            fiscalYear = String.valueOf(customFiscalYear);
        }
        return Database.query(allContractsQuery);
    }
    public AptActionPlanCreationBatch(Integer fiscalYear){
        this.customFiscalYear = fiscalYear;
        this.initialization();
    }

    public AptActionPlanCreationBatch(){
        this.customFiscalYear = null;
        this.initialization();
    }

    private void initialization(){
        isError = false;
        numRowsInOneTransaction = 0;
        removeErrorLog();
    }

    private void removeErrorLog() {
        delete [SELECT id FROM Action_Plan_Error__c];
    }

    public void execute(Database.BatchableContext param1, List<Contract__c> contracts) {
        numRowsInOneTransaction = 0;
        AptActionPlan aptActionPlan;
        List<Action_Plan_Error__c> errors = new List<Action_Plan_Error__c>();
        for (Contract__c contract : contracts) {
            if (isContractEligibleToHaveNewPlan(contract, currentYear)) {
                try {
                    aptActionPlan = new AptActionPlan(contract, fiscalYear);
                    aptActionPlan.prepare();
                    checkAmountOfInsertedRows(aptActionPlan);
                    aptActionPlan.create();
                }catch (Exception ex){
                    addError(param1, errors, contract, ex);
                }
            }
        }
        if (!errors.isEmpty()){
            writeError(errors);
        }
    }

    private void checkAmountOfInsertedRows(AptActionPlan aptActionPlan) {
        numRowsInOneTransaction = numRowsInOneTransaction + aptActionPlan.numberOfInsertedRows;
        if (numRowsInOneTransaction >= 10000){
            throw new LimitException('Decrease size of batch because you hit SF limit: Too many DML rows: 10001. ' +
                    'Number of records: ' + numRowsInOneTransaction);
        }
    }

    private void writeError(List<Action_Plan_Error__c> actionPlanErrors) {
        isError = true;
        insert actionPlanErrors;
    }

    private void addError(Database.BatchableContext param1, List<Action_Plan_Error__c> actionPlanErrors,
            Contract__c contract, Exception ex) {
        System.debug(ex.getStackTraceString());
        Action_Plan_Error__c error = new Action_Plan_Error__c();
        error.Kontrakt__c = contract.id;
        error.Cause__c = ex.getTypeName();
        error.Child_Job_Id__c = param1.getChildJobId();
        error.Job_Id__c = param1.getJobId();
        error.Fiscal_Year__c = fiscalYear;
        error.Message__c = getShort(ex.getMessage());
        error.StackTraceString__c = getShort(ex.getStackTraceString());
        actionPlanErrors.add(error);
    }

    public static Boolean isContractEligibleToHaveNewPlan(Contract__c contract,  String year){
        Boolean value = false;
        if (contract.Action_Plans__r.size() == 1 && contract.Action_Plans__r.get(0).FiscalYear__c == year){
            value = true;
        }
        return value;
    }

    private static String getShort(String text){
        String shortText = text;
        if (!String.isEmpty(text)) {
            shortText = text.left(131071);
        }
        return shortText;
    }

    public void finish(Database.BatchableContext param1) {
        if (isError == true){
            sendErrorEmail();
        }
    }
    private void sendErrorEmail() {
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'renate.slinning@viewledger.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Automatic Action Plan Creation Error');
        string body = 'Hi,\n'+
                'there was an issue during automatic creation of Action Plans.\n ' +
                'You can check issue in Error Log: \n' +
                + sfdcBaseURL +'/lightning/o/Action_Plan_Error__c/list?filterName=all';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}