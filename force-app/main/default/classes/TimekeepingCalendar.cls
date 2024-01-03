public class TimekeepingCalendar extends AuraController{

  public class ActivityPriceAgreementConfig{
      @AuraEnabled
      public List<Activity_Price_Agreement_Setting__c> settings;
      @AuraEnabled
      public UiSettings__c uiSettings;
      @AuraEnabled
      public Decimal numOfWorkingHours;
      @AuraEnabled
      public Decimal numOfWorkingMinutes;

      public ActivityPriceAgreementConfig(){
          settings = new List<Activity_Price_Agreement_Setting__c>();
      }
      public void setData(List<Activity_Price_Agreement_Setting__c> settings){
          this.settings = settings;
      }
  }

  public class ActivityPriceAgreementOptions{
      @AuraEnabled
      public String warning;
      @AuraEnabled
      public Contract__c agreement;

      public ActivityPriceAgreementOptions(){
          this.warning = null;
          this.agreement = null;
      }
  }

  @AuraEnabled
  public static void setUiConf(Boolean operationalFilter, Boolean internalFilter){
      System.debug('operationalFilter = ' + operationalFilter);
      System.debug('internalFilter = ' + internalFilter);
      UiSettings__c uiSettings = getUiConfig();
      if (operationalFilter == true){
          uiSettings.Time_Operational__c = true;
      }else{
          uiSettings.Time_Operational__c = false;
      }
      if (internalFilter == true){
          uiSettings.Time_Internal__c = true;
      }else{
          uiSettings.Time_Internal__c = false;
      }
      upsert uiSettings;
  }

  private static void setWorkingHours(ActivityPriceAgreementConfig config){
      Decimal workingHours = 8;
      User u = [SELECT id, Work_Hours_Daily__c, FTE__c FROM User WHERE id =: UserInfo.getUserId()];
      If (u.Work_Hours_Daily__c != null){
          if (u.FTE__c != null){
              workingHours = u.Work_Hours_Daily__c * (u.FTE__c/100);
          }else{
              workingHours = u.Work_Hours_Daily__c;
          }
      }
      config.numOfWorkingHours = math.floor(workingHours);
      config.numOfWorkingMinutes = (workingHours - config.numOfWorkingHours) * 60;
  }

  private static UiSettings__c getUiConfig() {
      UiSettings__c uiSetting;
      List<UiSettings__c> uiSettings = [
        SELECT Id, User__c, Time_Internal__c, Time_Operational__c
        FROM UiSettings__c
        WHERE User__c = :UserInfo.getUserId()
      ];
      if (uiSettings.isEmpty()){
          uiSetting = new UiSettings__c();
          uiSetting.User__c = UserInfo.getUserId();
          uiSetting.Time_Operational__c = false;
          uiSetting.Time_Internal__c = false;
      }else{
          uiSetting = uiSettings.get(0);
      }
      return uiSetting;
    }

    @AuraEnabled
  public static ActivityPriceAgreementConfig getActivityPriceAgreementConfig(){
      ActivityPriceAgreementConfig config = new ActivityPriceAgreementConfig();
      try {
          setWorkingHours(config);
          config.uiSettings = getUiConfig();
          List<Activity_Price_Agreement_Setting__c> settings = [
                  SELECT
                          Activity__c,
                          Exception__c,
                          Price_Agreement_Field__c,
                          Value_not_allowed__c
                  FROM Activity_Price_Agreement_Setting__c];
          config.setData(settings);
      } catch (Exception ex) {
          throwException('ActivityPriceAgreementConfig', ex);
      }
      return config;
  }

  @AuraEnabled
  public static ActivityPriceAgreementOptions getActivityPriceAgreementOptions(List<String> projTaskIds) {
      ActivityPriceAgreementOptions options = new ActivityPriceAgreementOptions();
      System.debug('projTaskIds =' + projTaskIds);
      Set<Id> accountsIds = new Set<Id>();
      try{
          List<Project_task__c> projectTasks = [
                SELECT id, Project__r.Account__c
                FROM Project_task__c
                WHERE id IN: projTaskIds
          ];
          for (Project_task__c p : projectTasks) {
              accountsIds.add(p.Project__r.Account__c);
          }
          if (accountsIds.size() > 1){
              options.warning = Label.Exception_More_Accounts;
          }else{
              List<Contract__c> contracts =
                [SELECT id, RecordType.DeveloperName, PA_Accounting__c, PA_Consulting__c, PA_HR__c, PA_Payroll__c,
                        PA_Support__c, PA_VTI__c, PA_Year_end_reporting__c,PA_Services__c,PA_Reporting__c,
                        PA_Custodial_recipient__c
                FROM Contract__c WHERE Account__c =: accountsIds.iterator().next()
                    AND RecordType.DeveloperName = 'Operational'];
              if (contracts.isEmpty()){
                  options.warning = Label.Exception_No_Operational;
              }else if(contracts.size() > 1){
                  options.warning = Label.Exception_More_Operational_Agreement;
              }else{
                  options.agreement = contracts.get(0);
              }
          }
      } catch (Exception ex) {
          throwException('ActivityPriceAgreementOptions', ex);
      }
      return options;
  }

  @AuraEnabled
    public static list<Time__c> getAllTimes(){
      list<Time__c> timeList;
      try {
          timeList = [
                  Select id, Date__c, Name, Project_Task__c, Incurred_By__c,
                          Registered_Hours__c,
                          Registered_Minutes__c,
                          Billable_Hours__c,
                          Billable_Minutes__c,
                          Description__c,
                          Project_Name__c,
                          Project_Task_Name__c,
                          Main_Activity__c,
                          Time_Type__c,
                          CreatedDate,
                          Activity__c
                  from Time__c
                  where Incurred_By__c = :Userinfo.getUserId()
                  order by CreatedDate
          ] ;

          for (Time__c t : timeList) {
              If (t.Registered_Hours__c == null) {
                  t.Registered_Hours__c = 0;
              }
              If (t.Registered_Minutes__c == null) {
                  t.Registered_Minutes__c = 0;
              }
              If (t.Billable_Hours__c == null) {
                  t.Billable_Hours__c = 0;
              }
              If (t.Billable_Minutes__c == null) {
                  t.Billable_Minutes__c = 0;
              }
          }
      }catch (Exception ex) {
          throwException('Get All Times', ex);
      }

      return timeList;
    }
    
    
    @AuraEnabled
    public static void updateTime(string timeid,string timedate){
        system.debug(timeid);
        system.debug(timedate);
        string timedatelist = timedate.replace('T',' ');
       
        system.debug(timedatelist);
        try {
            Time__c t = new Time__c(id = timeid);
            t.Date__c = (Date) DateTime.valueof(timedatelist);
            update t;
        } catch (Exception ex) {
            throwException('Update Time', ex);
        }

    }

    @AuraEnabled
    public static void saveTime(List<Time__c> newTimes){
        try{
            insert newTimes;
        } catch (Exception ex) {
            throwException('Save', ex);
        }
    }

    @AuraEnabled
    public static String getCurrentUser(){
      return (String) Userinfo.getUserId();
    }

    @AuraEnabled        
    public static List<String> getMainActivityValues(){
        List<String> pickListValuesList = new List<String>();
        try {
            Schema.DescribeFieldResult fieldResult = Time__c.Main_Activity__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple) {
                pickListValuesList.add(pickListVal.getLabel());
                System.debug('Values in Activity are: ' + pickListValuesList);
            }
        }catch (Exception ex) {
            throwException('Get Main Activity Values', ex);
        }
        return pickListValuesList;

    }

    @AuraEnabled        
    public static List<String> getActivityValues(String mainActivityValue){
        List<String> pickListValuesList = new List<String>();
        try {
            Schema.DescribeFieldResult fieldResult = Time__c.Activity__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple) {
                pickListValuesList.add(pickListVal.getLabel());
                System.debug('Values in Activity are: ' + pickListValuesList);
            }
        }catch(Exception ex) {
            throwException('Get Activity Values', ex);
        }
        return pickListValuesList;

    }

    /* Time Type remove */
    @AuraEnabled        
    public static List<String> getTimeTypeValues(){
   
        List<String> pickListValuesList = new List<String>();
        try {
            Set<String> privateTimeTypes = new Set<String>();
            for (AggregateResult pt : [SELECT Default_Time_Type__c FROM Project_task__c WHERE Lock_Time_Type__c = true AND Default_Time_Type__c != '' GROUP BY Default_Time_Type__c]) {
                privateTimeTypes.add((String) pt.get('Default_Time_Type__c'));
            }

            Schema.DescribeFieldResult fieldResult = Time__c.Time_Type__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple) {
                if (!privateTimeTypes.contains(pickListVal.getValue())) {
                    pickListValuesList.add(pickListVal.getLabel());
                }
            }
        }catch(Exception ex) {
            throwException('Get Time Type Values', ex);
        }
        return pickListValuesList;
 
    }

    
	@AuraEnabled
	public static String getDefaultTimeTypeValue() { 
		for( Schema.PicklistEntry pickListVal : Time__c.Time_Type__c.getDescribe().getPicklistValues()) {
			if (pickListVal.isDefaultValue()) return pickListVal.getLabel();
		}
		return '';
	}

    private static Set<Id> getOperationalAccounts(){
        Set<ID> accountsIds = new Set<ID>();
        List<Account_Team_And_Authorizations__c> ataa = [SELECT id, Kontrakt__r.Account__c, Area__c, Responsible__c
            FROM Account_Team_And_Authorizations__c WHERE Area__c = 'Account_Team'
            AND Responsible__c =: UserInfo.getUserId()];
        for (Account_Team_And_Authorizations__c a : ataa) {
            accountsIds.add(a.Kontrakt__r.Account__c);
        }
        return accountsIds;
    }

    private static String getUserCompany(){
        User u = [SELECT id, CompanyName FROM User WHERE id=: UserInfo.getUserId()];
        return u.CompanyName;
    }

    private static Map<String, Id> getRecordTypeIdMap(){
        Map<String, Id> rt = new Map<String, Id>();
        for (RecordType r : [SELECT id, DeveloperName FROM RecordType WHERE SobjectType = 'Project__c'
                AND (DeveloperName =: 'Operational' OR DeveloperName =: 'Internal_Project')]) {
            if (r.DeveloperName == 'Operational'){
                rt.put('operational', r.id);
            }else{
                rt.put('internal', r.id);
            }
        }
        return rt;
    }

    @AuraEnabled
    public static List<Project_Task__c> getProjTasks( String nameFilterString, Boolean internalFilter,
            Boolean operationalFilter) {
        system.debug('## nameFilterString = ' + nameFilterString);
        system.debug('## internalFilter = ' + internalFilter);
        system.debug('## operationalFilter = ' + operationalFilter);
        String searchStringQuery = '';
        String key;
        String query;
        String filters = '';
        Map<String, Id> rt;
        String recordTypeIdInternal = '';
        String recordTypeIdOperational = '';
        Set<Id> accountsIds;
        String staticFilter = ' (Status__c = \'Ongoing\' ) ';
        if (!String.isEmpty(nameFilterString)){
            key = '%' + nameFilterString + '%';
            searchStringQuery = ' AND Name like :key ';
        }
        List<Project_Task__c> validTasks = new List<Project_Task__c>();
        try {
            rt = getRecordTypeIdMap();
            String compName = getUserCompany();
            recordTypeIdOperational = rt.get('operational');
            recordTypeIdInternal = rt.get('internal');
            accountsIds = getOperationalAccounts();

            filters = 'WHERE ' + staticFilter;
            filters += searchStringQuery;
            if (operationalFilter == true && internalFilter == true){
                //just My operational and My internal
                filters += ' AND (( Project__r.RecordTypeId =: recordTypeIdInternal ' +
                                ' AND Project__r.Account__r.Name =: compName ) ';
                if (!accountsIds.isEmpty()) {
                    filters += ' OR ( Project__r.Account__c IN : accountsIds ' +
                        ' AND Project__r.RecordTypeId =: recordTypeIdOperational ) ';
                }
                filters += ' ) ';
            }else if(operationalFilter == true ){
                //My operational and all internal
                filters += 'AND ( Project__r.RecordTypeId =: recordTypeIdInternal ';
                if (!accountsIds.isEmpty()) {
                    filters += ' OR ( Project__r.Account__c IN : accountsIds ' +
                            ' AND Project__r.RecordTypeId =: recordTypeIdOperational ) ';
                }
                filters += ' ) ';
            }else if(internalFilter == true){
                //My internal and all operational
                filters += ' AND (( Project__r.RecordTypeId =: recordTypeIdInternal ' +
                        ' AND Project__r.Account__r.Name =: compName ) OR ' +
                        ' Project__r.RecordTypeId =: recordTypeIdOperational ) ';
            }
            query = 'Select Budget_Hours__c, ' +
                    'Project__c, ' +
                    'Start_Date__c, ' +
                    'End_Date__c, ' +
                    'Name, ' +
                    'Resource__c, ' +
                    'id, ' +
                    'Status__c, ' +
                    'Project__r.RecordType.DeveloperName, ' +
                    'Project__r.Account__r.Reason_For_Deactivation__c, ' +
                    'Project__r.Account__r.Deactivated__c, ' +
                    'Project__r.Account__r.Termination_end_date__c, ' +
                    'Project__r.Account__r.Late_payment__c, ' +
                    'Default_Time_Type__c, ' +
                    'Lock_Time_Type__c ' +
                    'from Project_Task__c ';
            query+=filters;
            query+= 'LIMIT 100 ';
            System.debug(filters);
            System.debug(query);
            validTasks = Database.query(query);
        }catch(Exception ex) {
            throwException('Get Project Tasks', ex);
        }
        return validTasks;
    }

    /*
    @AuraEnabled
    public static List<Project_Task__c> getProjectTasks( String nameFilterString, String timeRegistrationDate,
            Boolean operationalFilter) {
      system.debug('## nameFilterString = ' + nameFilterString);
      system.debug('## timeRegistrationDate = ' + timeRegistrationDate);
      system.debug('## operationalFilter = ' + operationalFilter);
      String taskFilterString = timeRegistrationDate;
      String searchStringQuery = '';
      String key;
      String query;
      String filters = '';
      String recordTypeId = '';
      String staticFilter = ' Status__c = \'Ongoing\' ';
      if (!String.isEmpty(nameFilterString)){
        key = '%' + nameFilterString + '%';
        searchStringQuery = ' AND Name like :key ';
      }
      List<Project_Task__c> validTasks = new List<Project_Task__c>();
        try {
            filters = 'WHERE ' + staticFilter;
            filters += searchStringQuery;
            if(!String.isEmpty(taskFilterString)) {
                recordTypeId = getRecordTypeId(taskFilterString);
                filters += ' AND Project__r.RecordTypeId =: recordTypeId ';
                if (taskFilterString == 'internal') {
                    String compName = getUserCompany();
                    filters += ' AND Project__r.Account__r.Name =: compName ';
                } else if (taskFilterString == 'operational') {
                    Set<Id> accountsIds = getOperationalAccounts();
                    if (!accountsIds.isEmpty()) {
                        filters += ' AND Project__r.Account__c IN : accountsIds ';
                    } else {
                        return validTasks;
                    }
                }
            }
            query = 'Select Budget_Hours__c, ' +
                    'Project__c, ' +
                    'Start_Date__c, ' +
                    'End_Date__c, ' +
                    'Name, ' +
                    'Resource__c, ' +
                    'id, ' +
                    'Status__c, ' +
                    'Project__r.RecordType.DeveloperName, ' +
                    'Project__r.Account__r.Reason_For_Deactivation__c, ' +
                    'Project__r.Account__r.Deactivated__c, ' +
                    'Project__r.Account__r.Termination_end_date__c, ' +
                    'Project__r.Account__r.Late_payment__c, ' +
                    'Default_Time_Type__c, ' +
                    'Lock_Time_Type__c ' +
                    'from Project_Task__c ';
            query+=filters;
            query+= 'LIMIT 100 ';
            System.debug(filters);
            System.debug(query);
            validTasks = Database.query(query);
        }catch(Exception ex) {
            throwException('Get Project Tasks', ex);
        }
        return validTasks;
    }
    */

    @AuraEnabled
    public static string getProjectTaskCountry(String projectTaskId){
      Project_Task__c pt = [Select Id, Project__c, Project__r.Account__r.Country2__c from Project_Task__c where Id = :projectTaskId];
      return pt.Project__r.Account__r.Country2__c;      
    }
    @AuraEnabled
    public static string getMainPriceAgreement(String projectTaskId){
      Project_Task__c pt = [Select Id, Project__c, Project__r.Account__r.Price_Agreement__c from Project_Task__c where Id = :projectTaskId];
      return pt.Project__r.Account__r.Price_Agreement__c;      
    }
}