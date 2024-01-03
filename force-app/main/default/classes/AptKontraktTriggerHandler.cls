/**
 * @author Jozef 
 * @date 12.9.2019.
 * @description //TODO
 */

public with sharing class AptKontraktTriggerHandler {
    //public static String NO_SCOPE = 'Supervisory tasks;Accounting VAT;Year end report;Payroll';

    public static void updateCountry(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id, Contract__c> contractMap = new Map<Id, Contract__c>();
        Set<Id> accounts = new Set<Id>();
        for (Id id : newItems.keySet()) {
            Contract__c oldContract = (Contract__c)oldItems.get(id);
            Contract__c newContract = (Contract__c)newItems.get(id);
            if (oldContract.Account__c != newContract.Account__c){
                contractMap.put(id, newContract);
                accounts.add(newContract.Account__c);
            }
        }
        setNewCountry(contractMap, accounts);
    }

    public static void insertCountry(List<SObject> newItems){
        Map<Id,Contract__c> contractMap = new Map<Id,Contract__c>();
        Set<Id> accounts = new Set<Id>();
        for (SObject sobj : newItems) {
            Contract__c contract = (Contract__c)sobj;
            if (contract.Account__c != null) {
                contractMap.put(contract.id, contract);
                accounts.add(contract.Account__c);
            }
        }
        setNewCountry(contractMap, accounts);
    }

    private static void setNewCountry(Map<Id,Contract__c> contractMap, Set<Id> accounts){
        if (!contractMap.isEmpty()) {
            Map<Id,Account> accountCountryMap = new   Map<Id,Account>([SELECT id, Country2__c
            FROM Account WHERE id IN :accounts]);
            //System.debug(accountCountryMap);
            for (Id conId : contractMap.keySet()) {
                Contract__c con = contractMap.get(conId);
                con.Country__c = (accountCountryMap.containsKey(con.Account__c) && String.isNotBlank(accountCountryMap.get(con.Account__c).Country2__c)?accountCountryMap.get(con.Account__c).Country2__c:'');
                //setScope(con);
            }
        }
    }

   /* public static void setScope(Contract__c contract){
        if (contract.Scope__c == null && contract.Country__c == 'NO - Norge'){
            contract.Scope__c = NO_SCOPE;
        }
    }*/
}