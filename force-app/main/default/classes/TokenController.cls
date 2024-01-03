/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         TokenController.cls 
Description:  Controller class for getting Azure AD Access Token.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
July 2019        0.1         Parthesh                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */
public class TokenController 
{
    /*---------------------------------------------------------------------------------------------------------------------------------
    Method Name:    GetToken
    Description:    This method is used to call Azure AD for access token.
    Inputs:         -
    Notes:        	Please add comments on Line if anyone update the code with Respected Name, Date, Reson.
    
    <Date>          <Authors Name>      Modification Reason 
    July 2019       Parthesh            		-	
    
    ----------------------------------------------------------------------------------------------------------------------------------*/
    public static String GetToken()
    {
        AzureAD_Credential__c credentials = [Select TokenUrl__c, ClientId__c, ClientSecretKey__c, GrantType__c, Scope__c from AzureAD_Credential__c limit 1 ];
        
        String responseText='';
        String token='';
        String requestString = 'client_id='+credentials.ClientId__c+'&scope='+credentials.Scope__c+'&client_secret='+credentials.ClientSecretKey__c+'&grant_type='+credentials.GrantType__c;
        
        HttpRequest reqForToken = new HttpRequest();
        reqForToken.setMethod('POST');
        reqForToken.setHeader('Content-Type','application/x-www-form-urlencoded');
        reqForToken.setBody(requestString);
        reqForToken.setEndpoint(credentials.TokenUrl__c);
        
        Http httpForToken = new Http();
        try
        {
            HTTPResponse resToken = httpForToken.send(reqForToken);
            responseText=resToken.getBody();
            
            System.debug(credentials.TokenUrl__c);
            System.debug(resToken.getStatusCode());
            System.debug(resToken.getBody());
            System.debug('@@@ :: ' + JSONParserForToken(responseText));
            return JSONParserForToken(responseText);
            
        } catch(System.CalloutException e) {
            System.debug(e.getMessage());
        }
        return JSONParserForToken(responseText);
    }
    
    /*---------------------------------------------------------------------------------------------------------------------------------
    Method Name:    JSONParserForToken
    Description:    This method for JSON Parser.
    Inputs:         JSONParserString
    Notes:        	Please add comments on Line if anyone update the code with Respected Name, Date, Reson.
    
    <Date>          <Authors Name>      Modification Reason 
    July 2019       Parthesh            		-	
    
    ----------------------------------------------------------------------------------------------------------------------------------*/
    public static String JSONParserForToken(String JSONParserString)
    {
        String token = '';
        
        JSONParser parser = JSON.createParser(JSONParserString);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    token = parser.getText();
                    break;
                }
        }
        return token;
    }
}