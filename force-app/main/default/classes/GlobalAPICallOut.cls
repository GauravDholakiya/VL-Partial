global class GlobalAPICallOut {
    
    public static httpResponse makeCallout(string requestBody, String Endpoint,string MethodType,string authorization)
    {
        
        HttpResponse responseNewMSTeam = new HttpResponse();
        integer   timeout = 120000;
        
        system.debug('GlobalAPICallOut requestBody=>'+requestBody);
        system.debug('GlobalAPICallOut Endpoint=>'+Endpoint);
        system.debug('GlobalAPICallOut MethodType=>'+MethodType);
        system.debug('GlobalAPICallOut Authorization=>'+authorization);
        try{
            HttpRequest httpReqNewMSTeams = new HttpRequest();
            httpReqNewMSTeams.setTimeout(timeout);
            httpReqNewMSTeams.setEndpoint(Endpoint);
            httpReqNewMSTeams.setHeader('Authorization',authorization);
            httpReqNewMSTeams.setMethod(MethodType);
            httpReqNewMSTeams.setBody(requestBody);
            httpReqNewMSTeams.setHeader('Accept', 'application/json');
            httpReqNewMSTeams.setHeader('Content-Type','application/json'); 
            
            Http httpNewMSTeams = new Http();
            
            responseNewMSTeam = httpNewMSTeams.send(httpReqNewMSTeams);
           system.debug('ResponseNewMSTeam=='+responseNewMSTeam);
            
        }
        catch(Exception ex)
        {
            System.debug('Global API Call out'+ex.getMessage());
        }
        
        return responseNewMSTeam;
        
    }  
    
    
    //
    public static httpResponse makefileCallout(String EndpointUrl,string MethodType,string authorization)
    {
        
        HttpResponse responseGetTerm = new HttpResponse();
        integer   timeout = 120000;
        
        system.debug('GlobalAPICallOut Endpoint=>'+EndpointUrl);
        system.debug('GlobalAPICallOut MethodType=>'+MethodType);
        system.debug('GlobalAPICallOut Authorization=>'+authorization);
        try{
            HttpRequest httpReqGetTerm = new HttpRequest();
            httpReqGetTerm.setTimeout(timeout);
            httpReqGetTerm.setEndpoint(EndpointUrl);
            httpReqGetTerm.setHeader('Authorization',authorization);
            httpReqGetTerm.setMethod('GET');
            httpReqGetTerm.setHeader('Accept', 'application/json');
            httpReqGetTerm.setHeader('Content-Type','application/json'); 
            
            Http httpNewGetTerm = new Http();
            
            responseGetTerm = httpNewGetTerm.send(httpReqGetTerm);
           system.debug('response =='+responseGetTerm);
            
        }
        catch(Exception ex)
        {
            System.debug('Global API Call out'+ex.getMessage());
        }
        
        return responseGetTerm;
        
    }  
    
     
    
}