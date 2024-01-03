public class AptFiscalYearSelectorController {
	@AuraEnabled
    public static List<String> initYears(String contractId){
        Integer currentYear = System.Today().year();
        Date startDate = [SELECT Id, StartDate__c FROM Contract__c WHERE Id = :contractId LIMIT 1].StartDate__c;
        List<String> years = new List<String>();
        if (startDate != null) {
            Integer startYear = startDate.year();
            startYear = startYear;
            for (Integer i=startYear; i<=currentYear+1; i++) {
                years.add(String.valueOf(i));
            }
        } else {
           for (Integer i=currentYear; i<=currentYear+1; i++) {
                years.add(String.valueOf(i));
           } 
        }
        return years;
    }
    
    @AuraEnabled
    public static List<ActionPlan__c> fetchActionPlansForYears(String contractId, String fiscalYear){
        if (!String.isBlank(fiscalYear)) {
            return [SELECT Id, Name FROM ActionPlan__c WHERE Contract__c = :contractId AND FiscalYear__c =:fiscalYear];
        } else {
            return new List<ActionPlan__c>();
        }
        
    }
}