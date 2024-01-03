global class AccountechAPICallout {
    
    @future(callout = true)
    public static void makeCallout(string ac,String requestBody,String MethodType,string AccessToken){
        try
        {
            system.debug('INSIDE MAKE CALLOUT');
            APIAccountec__c act = APIAccountec__c.getValues('Accountec Credentials');
            
            string BaseURL = act.BaseURL__c;
            string Secret = act.Secret__c;
            // callout for Create customer
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BaseURL+'/clients');
            request.setHeader('Client-Secret',Secret);
            request.setHeader('Content-Type','application/json');  
            request.setHeader('Authorization','Bearer '+AccessToken);  
            
            request.setBody(requestBody);
            request.setMethod(MethodType);
            
            HttpResponse response = http.send(request);
            system.debug('**CreateCustomer Response->'+response);
            system.debug('**CreateCustomer Response body->'+response.getbody());
            
            if(string.isNotEmpty(response.getbody())) 
            {
                
                Map<String, Object> ResponsefromAccountecforCreateAPI = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                system.debug('Response from Accountec for CreateAPI'+ResponsefromAccountecforCreateAPI);
                
                if(response.getStatusCode() == 201 || response.getStatusCode() == 200)
                {
                    string  UUID = (string)ResponsefromAccountecforCreateAPI.get('uuid');
                    system.debug('UUID->'+UUID);
                    
                    
                    CreateAccountecUpdateField.updatefield(ac,UUID,MethodType);
                }
                else{
                    system.debug('status code not 200 for Customer Creation');
                }
            }
            
        }catch(Exception e)
        {
            system.debug('Exception occurred in Create Customer: ' + e.getMessage());
        }
        
    }
    
    @future(callout = true)
    public static void deleteCustomer(string ID,String uuid, string accesstoken, string methodtype)
    {
        try
        {
            APIAccountec__c act = APIAccountec__c.getValues('Accountec Credentials');
            string BaseURL = act.BaseURL__c;
            string Secret = act.Secret__c;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BaseURL+'/clients/'+uuid);
            request.setHeader('Client-Secret',Secret);
            request.setHeader('Content-Type','application/x-www-form-urlencoded');  
            request.setHeader('Authorization','Bearer '+accesstoken);
            
            request.setMethod(methodtype);
            
            HttpResponse response = http.send(request);
            
            system.debug('Response for deletion->'+response);
            system.debug('Response body for deletion->'+response.getbody());
            
            List<Account> aclist= new List<Account>();
            Account a =new Account();
            a.id = ID;
            a.DeleteCalloutAPI__c = true;
            aclist.add(a);
            system.debug('list to delete customer->'+aclist);
            Database.update(aclist,true); 
        }catch(Exception e)
        {
            system.debug('Exception occurred in Delete Customer: ' + e.getMessage());
        }
        
    }
    
    @future(callout=true)
    public static void updatefields(string ac,string methodtype, string AccessToken,string requestbody)
    {
        try
        {
            Account acc = (Account)JSON.deserialize(ac, Account.class);
            
            APIAccountec__c act = APIAccountec__c.getValues('Accountec Credentials');
            string BaseURL = act.BaseURL__c;
            string Secret = act.Secret__c;
            
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BaseURL+'/clients/'+acc.Accountec_UUID__c+'/fields/'+acc.Field_UUID__c);
            request.setHeader('Client-Secret',Secret);
            request.setHeader('Content-Type','application/json');  
            request.setHeader('Authorization','Bearer '+AccessToken);
            system.debug('req body for UPDATE-> '+requestbody);
            
            request.setBody(requestbody);
            request.setMethod(methodtype);
            
            HttpResponse response = http.send(request);
            
            system.debug('**Response for update->'+response);
            system.debug('**Response body for update->'+response.getbody());
        }catch(Exception e)
        {
            system.debug('Exception occured in Update Field: ' + e.getMessage());
        }
        
        
    }
    
    public static string RefreshToken () {
        string newAccesstokentoreturn;
        DateTime validUntilDateTime;
        
        try
        {
            // get data from custom setting 
            APIAccountec__c act = APIAccountec__c.getValues('Accountec Credentials');
            
            string BaseURL = act.BaseURL__c;
            string Secret = act.Secret__c;
            string validUntil = act.ValidUntil__c;
            string RefreshToken = act.RefreshToken__c;
            string AccessToken = act.AccessToken__c;
            
            Integer colonCount = 0;
            for (Integer i = 0; i < validUntil.length(); i++) {
                if (validUntil.substring(i, i + 1) == ':') {
                    colonCount++;
                }
            }
            if(colonCount == 1)
            {
                validUntil = validUntil.replace('T', ' ').replace('Z', '');
                validUntil = validUntil+':00';
                system.debug('validUntil-->'+validUntil);
                validUntilDateTime = DateTime.valueOf(validUntil);
                system.debug('validUntilDateTime(1) --->'+validUntilDateTime);
            }
            else
            {
                validUntil = validUntil.replace('T', ' ').replace('Z', '');
                // Convert the string to DateTime
                validUntilDateTime = DateTime.valueOf(validUntil);
                system.debug('validUntilDateTime(2) --->'+validUntilDateTime);
                
            }
      
            validUntilDateTime = validUntilDateTime.addHours(1);
			system.debug('validUntilDateTime +1 -> '+validUntilDateTime);

            //get the current date time in GMT format GMT = 0
            Datetime dt = datetime.now();
            // Add 1 hours to the DateTime
            datetime dt1 = dt.addHours(1);
         	system.debug('dt1->'+dt1);

            Integer dateDifference = date.valueof(validUntilDateTime).daysBetween(date.valueof(dt1)); 
            system.debug('dateDifference->'+dateDifference);
            // Calculate the difference in minutes
            Long timeDifferenceMinutes = ((dt1.getTime() - validUntilDateTime.getTime()) / 1000)/60 ;
              
            system.debug('timeDifferenceMinutes-->'+timeDifferenceMinutes);
            
            if (dateDifference == 0  && timeDifferenceMinutes<50 )
            {
                
                //return the same acess token 
                return  AccessToken;
            }
            else
            {
                //  callout for getting the new refresh token,new access token & new valid until. 
                
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(baseURL+'/authorization/refresh-token');
                request.setHeader('Client-Secret',Secret);
                request.setHeader('Refresh-Token',RefreshToken);
                request.setMethod('POST');
                
                HttpResponse response = http.send(request);
                
                system.debug('**Refresh Token Response->'+response);
                system.debug('**Refresh Token Response body->'+response.getbody());
                
                if(string.isNotEmpty(response.getbody())) 
                {
                    Map<String, Object> ResponsefromAccountec = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    system.debug('ResponsefromAccountec'+ResponsefromAccountec);
                    
                    //fetch new Access token & refresh token here.
                    
                    string  newAccessToken = (string)ResponsefromAccountec.get('accessToken');
                    string newRefreshToken = (string)ResponsefromAccountec.get('refreshToken');
                    String newValidUntill = (String)ResponsefromAccountec.get('validUntil');
                    
                    system.debug('newAccessToken from Accountec->'+newAccessToken);
                    system.debug('newRefreshToken from Accountec->'+newRefreshToken);
                    system.debug('newValidUntill from Accountec->'+newValidUntill);
                    
                    // here we need to check the status code of response  
                    if(response.getStatusCode() == 200 ||response.getStatusCode() == 201)
                    {	
                        newAccesstokentoreturn=newAccessToken;
                        
                        //update the new values in custom settings 
                        APIAccountec__c ac = APIAccountec__c.getValues('Accountec Credentials');
                        ac.AccessToken__c = newAccessToken;
                        ac.RefreshToken__c = newRefreshToken;
                        ac.ValidUntil__c  = newValidUntill;
                        
                        update ac;
                        system.debug('updated values in custom setting->'+ac);
                    }
                    else
                    {
                        system.debug('status code not 200');
                    }
                }
                
                
            } 
        }catch(Exception e)
        {
            system.debug('An exception occurred in Refresh Token: ' + e.getMessage());
        }
        
        return newAccesstokentoreturn;
    }
    
    
}