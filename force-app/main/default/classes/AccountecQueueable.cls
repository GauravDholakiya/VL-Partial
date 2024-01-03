global class AccountecQueueable implements Queueable , Database.AllowsCallouts
{
    List<Account> accountsToProcess = new List<Account>();
    public AccountecQueueable(List<Account> accountsToProcess) {
        this.accountsToProcess = accountsToProcess;
    }
    
    
    global void execute(QueueableContext context) 
    {	System.debug('insert queueable execute');
        try
        {
            for(Account ac:accountsToProcess)
            {	
                string OrgNumber = ac.Org_Number__c;
                // Defined a regular expression pattern for 'xxxxxx-xxxx'
                String pattern1 = '^[0-9]{6}-[0-9]{4}$';
                Pattern orgnumberPattern = Pattern.compile(pattern1);
                Matcher orgnumberMatcher = orgnumberPattern.matcher(OrgNumber);
                APIAccountec__c act = APIAccountec__c.getValues('Accountec Credentials');
                string officeUUID = act.Office_UUID__c;
                Map<String, Object> requestBody = new Map<String, Object>();

                requestBody.put('officeUuid', officeUUID);
                requestBody.put('name', ac.Name);
                
                if(orgnumberMatcher.matches())
                {
                    // If the format is correct, use the original orgNumber
                    requestBody.put('orgNr',OrgNumber); 
                }
                else
                {
                    // If the format is incorrect, format it and use the formatted version
                    orgNumber = OrgNumber.replaceAll('[^0-9]', ''); // Remove non-digit characters
                    String formattedOrgNumber = orgNumber.substring(0, 6) + '-' + orgNumber.substring(6, 10);
                    System.debug('Formatted Org Number: ' + formattedOrgNumber);
                    requestBody.put('orgNr', formattedOrgNumber);
                }
                system.debug('requestBody for create customer->'+requestBody);
             //   string AccessToken =  AccountechAPICallout.RefreshToken();
             //   system.debug('Access Token in Queueable->'+AccessToken);
                //Make callout for Create Customer
                system.debug('JSON.serialize(ac)-> '+JSON.serialize(ac));
          //      AccountechAPICallout.makeCallout(JSON.serialize(ac),JSON.serialize(requestBody),'POST',AccessToken);
                
            }
        }catch(Exception e)
        {
            system.debug('An exception occurred: ' + e.getMessage());
        }
        
    }
}