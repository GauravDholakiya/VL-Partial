/**
 * @author Jozef 
 * @date 12.9.2019.
 * @description //TODO
 */

public with sharing class AptAccountTriggerHandler {

    public static void updateContractCountry(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id, String> accCountryMap = new Map<Id, String>();
        for (Id id : newItems.keySet()) {
            Account oldAccount = (Account)oldItems.get(id);
            Account newAccount = (Account)newItems.get(id);
            if (newAccount.Country2__c != oldAccount.Country2__c){
                accCountryMap.put(id, newAccount.Country2__c);
            }
        }
        List<Contract__c> contracts = [SELECT id, Country__c, Account__c FROM Contract__c
            WHERE Account__c IN : accCountryMap.keySet()];
        for (Contract__c contract : contracts) {
            contract.Country__c = accCountryMap.get(contract.Account__c);
        }
        if (!contracts.isEmpty()){
            update contracts;
        }
    }

}