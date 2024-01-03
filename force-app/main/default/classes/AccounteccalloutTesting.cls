public class AccounteccalloutTesting {
	public static void RefreshToken()
    {
       
		Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://staging.accountec.se/external/authorization/refresh-token');
        request.setHeader('Client-Secret','947a11eb-8826-4c05-80a7-56211b45641e');
        request.setHeader('Refresh-Token','a883ab35-b69a-4a83-962a-f6a47724e331');
        request.setMethod('POST');

        HttpResponse response = http.send(request);
       
        system.debug('Response->'+response);
        system.debug('Response body->'+response.getbody());
        
    }
    	public static void ValidateToken()
    {
       
		Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://staging.accountec.se/external/authorization/validate');
        request.setHeader('Client-Secret','947a11eb-8826-4c05-80a7-56211b45641e');
        request.setHeader('Authorization','Bearer '+'565bac71-7b92-4470-b297-f490211751aa');
        request.setMethod('GET');
         
        HttpResponse response = http.send(request);
       
        system.debug('Response->'+response);
        system.debug('Response body->'+response.getbody());
        
    }
    public static void createCustomer()
    {
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('name','Test BR1');
        requestBody.put('orgNr', '611321-1234');
        
        //EncodingUtil.urlEncode('test@ad.abc.com','UTF-8')
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://staging.accountec.se/external/clients');
        request.setHeader('Client-Secret','947a11eb-8826-4c05-80a7-56211b45641e');
        request.setHeader('Content-Type','application/json');  
        request.setHeader('Authorization','Bearer '+'831bb1c5-5f1d-49c1-9394-60f705e9baa7');
		system.debug('Serialize req body-> '+JSON.serialize(requestBody));
        
        request.setBody(JSON.serialize(requestBody));
        
        request.setMethod('POST');
		
        HttpResponse response = http.send(request);
       
        system.debug('Response->'+response);
        system.debug('Response body->'+response.getbody());
    }
    public static void deletecustomer()
    {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://staging.accountec.se/external/clients/2db9b95f-ddf1-4980-8b93-f64e57819b4d');
        request.setHeader('Client-Secret','947a11eb-8826-4c05-80a7-56211b45641e');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');  
        request.setHeader('Authorization','Bearer '+'680532d4-7b0e-4e23-a0a5-b69e891e7b2c');
	  
        request.setMethod('DELETE');
		
        HttpResponse response = http.send(request);
       
        system.debug('Response->'+response);
        system.debug('Response body->'+response.getbody());
 
    }
    
    public static void updatefield()
    {	
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('field','Other');
        requestBody.put('value', 'test * test');
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://staging.accountec.se/external/clients/41e6ef33-a392-4e04-a7e8-f4a6100e081b/fields/2ca7eb67-9f24-438b-b88d-cde2849b685f');
        request.setHeader('Client-Secret','947a11eb-8826-4c05-80a7-56211b45641e');
        request.setHeader('Content-Type','application/json');  
        request.setHeader('Authorization','Bearer '+'e4d3807a-d895-417a-9f5f-50a3500beb8c');
		system.debug('Serialize req body-> '+JSON.serialize(requestBody));
        
        request.setBody(JSON.serialize(requestBody));
        
        request.setMethod('PUT');
		
        HttpResponse response = http.send(request);
       
        system.debug('Response->'+response);
        system.debug('Response body->'+response.getbody());

    }
    
}