/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         SPTokenController.cls 
Description:  Generate token for REST API Callout using sharepoint credentials from custom setting.
Test class:   SharepointWidgetController_Test.cls 

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
02 Oct 2019        1.0        Deepak                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

public class SPTokenController {
    
    public static String GetToken()
    {
        SharepointCredentialsInfo__c SPcredentials = [Select ClientId__c,ClientSecret__c,GrantType__c,Principal__c,realm__c,resource__c,SharepointTokenURL__c from SharepointCredentialsInfo__c limit 1 ];
        
        String responseText='';
        String token='';
        String requestString = 'grant_type='+SPcredentials.GrantType__c+'&client_id='+SPcredentials.ClientId__c+'@'+SPcredentials.realm__c+'&client_secret='+EncodingUtil.urlEncode(SPcredentials.ClientSecret__c, 'UTF-8')+'&resource='+SPcredentials.resource__c;
        HttpRequest reqForToken = new HttpRequest();
        reqForToken.setMethod('POST');
        reqForToken.setHeader('Content-Type','application/x-www-form-urlencoded');
        reqForToken.setBody(requestString);
        reqForToken.setEndpoint(SPcredentials.SharepointTokenURL__c);
         system.debug('end : '+SPcredentials.SharepointTokenURL__c);
         system.debug('requestString : '+requestString);
        Http httpForToken = new Http();
        try
        {
            HTTPResponse resToken = httpForToken.send(reqForToken);
            responseText=resToken.getBody();
            System.debug('responseText:'+responseText);
            return JSONParserForToken(responseText);
            
        } catch(System.CalloutException e) {
            System.debug(e.getMessage());
        }
        
        System.debug('accessToken: '+token);
        return '';
    }
    
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
        System.debug('accessToken: '+token);
        return token;
    }
    
}