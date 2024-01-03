// Created June 2020 - Mia Genovese, Fluido
// Used for the View Academy App
public with sharing class WebinarController {
    @AuraEnabled(cacheable=true)
    public static Webinars__c[] getWebinarList() {
        return [select Id, Name, Description__c, Video_url__c, Type__c, Country__c, LastModifiedDate
                from Webinars__c];
    }

    @AuraEnabled(cacheable=true)
    public static Webinars__c[] getFilteredWebinars(List<String> types, List<String> countries, String searchTerm) {
       if (types == null && countries == null && searchTerm == null|| (types.isEmpty() && countries.isEmpty() && searchTerm == '' )) {
            return getWebinarList();
       } 
       else if((types != null || !types.isEmpty()) && ( (countries == null || countries.isEmpty()) && (searchTerm == null || searchTerm == '' )) ) {
            return [select Id, Name, Description__c, Video_url__c, Type__c, Country__c, LastModifiedDate 
                    from Webinars__c
                    where Type__c in :types];
       }
       else if((types == null || types.isEmpty()) && (countries != null || !countries.isEmpty()) && (searchTerm == null || searchTerm == '')) {
            return [select Id, Name, Description__c, Video_url__c, Type__c, Country__c, LastModifiedDate 
                    from Webinars__c
                    where Country__c in :countries];
       }
       else if (!types.isEmpty() && !countries.isEmpty() && (searchTerm == null || searchTerm == '')) {
        System.debug('##hallooo');
            return [select Id, Name, Description__c, Video_url__c, Type__c, Country__c, LastModifiedDate 
                    from Webinars__c
                    where Type__c in :types
                    and Country__c in :countries];
       }
       else if(types == null && countries == null && searchTerm != null|| (types.isEmpty() && countries.isEmpty() && searchTerm != '' )){
            searchTerm = '%'+ searchTerm +'%';
            return [select Id, Name, Description__c, Video_url__c, Type__c, Country__c, LastModifiedDate 
                    from Webinars__c
                    where Name LIKE :searchTerm or Description__c LIKE :searchTerm];
       }
       else if(!types.isEmpty() && !countries.isEmpty() && (searchTerm != null || searchTerm != '')){
            searchTerm = '%'+ searchTerm +'%';
            return [select Id, Name, Description__c, Video_url__c, Type__c, Country__c, LastModifiedDate 
                    from Webinars__c
                    where (Name LIKE :searchTerm or Description__c LIKE :searchTerm)
                    and Type__c in :types
                    and Country__c in :countries];
       }
       else if((types == null || types.isEmpty()) && (countries != null || !countries.isEmpty()) && (searchTerm != null || searchTerm != '')){
          searchTerm = '%'+ searchTerm +'%';
          return [select Id, Name, Description__c, Video_url__c, Type__c, Country__c, LastModifiedDate 
                  from Webinars__c
                  where (Name LIKE :searchTerm or Description__c LIKE :searchTerm)
                  and Country__c in :countries];
       }
       else if((types != null || !types.isEmpty()) && ( (countries == null || countries.isEmpty()) && (searchTerm != null || searchTerm != '' ))){
          searchTerm = '%'+ searchTerm +'%';
          return [select Id, Name, Description__c, Video_url__c, Type__c, Country__c, LastModifiedDate 
                  from Webinars__c
                  where (Name LIKE :searchTerm or Description__c LIKE :searchTerm)
                  and Type__c in :types];
       }
       else {
           return null;
       }
    }
    @AuraEnabled(cacheable=true)
    public static Boolean getUserPermissions(String userId){
            System.debug('userId ' + userId);
        Boolean hasPermission = false;
        List<PermissionSetAssignment> currentUserPermissions = [select Id, PermissionSet.Name, AssigneeId
                                                                from PermissionSetAssignment
                                                                where AssigneeId = :userId ];
        for(PermissionSetAssignment psa : currentUserPermissions){
                if(psa.PermissionSet.Name == 'manage_Academy'){
                        hasPermission = true;
                    	return hasPermission;
                }
        }
        Id sysAdmin = [select Id, Name from Profile where Name = 'System Administrator'].Id;
        Id profileId = UserInfo.getProfileId();
        if(profileId == sysAdmin){
                hasPermission = true;
        }
        return hasPermission;  
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getCountryPicklistValues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Webinars__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
                options.add(String.valueOf(f.getLabel()));
        }
        System.debug('##country options' + options);
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getTypePicklistValues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Webinars__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
                options.add(String.valueOf(f.getLabel()));
        }
        System.debug('##country options' + options);
        return options;
    }
}