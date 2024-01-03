public class CreateAccountecUpdateField {
    
    //callout from create function to update field
    public static void updatefield(string ac,string UUID,string methodtype)
    {	try
      {
        Account acc = (Account)JSON.deserialize(ac, Account.class);
        string newAccessToken = AccountechAPICallout.RefreshToken();
        
        system.debug('INSIDE UPDATE FROM CREATE FUNCTION');
        APIAccountec__c act = APIAccountec__c.getValues('Accountec Credentials');
        string BaseURL = act.BaseURL__c;
        string Secret = act.Secret__c;
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('field','Other');
        requestBody.put('value',acc.SiteURL__c+acc.Accounting_Channel_URL__c+'*'+acc.SPGroupID__c);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(BaseURL+'/clients/'+UUID+'/fields');
        System.debug('Update field:->'+ UUID);
        request.setHeader('Client-Secret',Secret);
        request.setHeader('Content-Type','application/json');  
        request.setHeader('Authorization','Bearer '+newAccessToken); 
        system.debug('Serialize req body for UPDATE from create-> '+JSON.serialize(requestBody));
        
        request.setBody(JSON.serialize(requestBody));
        
        request.setMethod(methodtype);
        
        HttpResponse response = http.send(request);
        
        system.debug('**Response for update from create->'+response);
        system.debug('**Response body for update from create->'+response.getbody());
        if(string.isNotEmpty(response.getbody())) 
        {
            {
                Map<String, Object> ResponsefromAccountecforUpdateAPI = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                system.debug('Response for UPDATE API from create'+ResponsefromAccountecforUpdateAPI);
                
                if(response.getStatusCode() == 201 || response.getStatusCode() == 200)
                {   
                    string  fieldUUID = (string)ResponsefromAccountecforUpdateAPI.get('uuid');
                    system.debug('field UUID->'+fieldUUID);
                    List<Account> aclist= new List<Account>();
                    Account a =new Account();
                    a.id = acc.id; 
                    a.Accountec_UUID__c = UUID;
                    a.Field_UUID__c = fieldUUID;
                    a.CreateCalloutAPI__c = true;
                    aclist.add(a);
                    system.debug('list to Update customer from create->'+aclist);
                    Database.update(aclist,true); 
                }
                else
                {
                    system.debug('status code not 200 for update API from create');
                }
                
            }
        }
    }
     catch(Exception e)
     {
         system.debug('An exception occurred in Update Field from Create: ' + e.getMessage());
     }
    }
}