/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         AccountTeamAndAuthTriggerHandler_Mock.cls 
Description:  Handle Test class Callout of AccountTeamAndAuthTriggerHandler_Test class as Mock response .

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
15 Sep 2019        1.0         Deepak                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */
public class AccountTeamAndAuthTriggerHandler_Mock  implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) 
    { 
        HTTPResponse httpResponse = new HTTPResponse();
      /*  if(req.getEndpoint().endsWith('987d5b59-8ee7-4939-ab38-b720e9d085d7/oauth2/v2.0/token'))
        {
            httpResponse.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IkFRQUJBQUFBQUFBUDB3TGxxZExWVG9PcEE0a3d6U254NnpQamlfR2llR3JsSmR1T2ZzbVdfNWJyOWxINzRCbF9fVk9xWlQ4SmowV1padVVBUFotb1lUSTJ3QTZNdENMQ2o2T1gxenRDbjlMdzJUa1ZVSmVmVFNBQSIsImFsZyI6IlJTMjU2IiwieDV0IjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIiwia2lkIjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIn0.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC85ODdkNWI1OS04ZWU3LTQ5MzktYWIzOC1iNzIwZTlkMDg1ZDcvIiwiaWF0IjoxNTYzODY1MDYwLCJuYmYiOjE1NjM4NjUwNjAsImV4cCI6MTU2Mzg2ODk2MCwiYWlvIjoiNDJGZ1lCQnU4SnB0K25DMWc0ckh4ejZQaHNWN0FBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJTRkRDVG9TUCIsImFwcGlkIjoiYzRiODc2N2ItZDNlYy00YmFlLWI4ZWUtM2E1ZWI0ZThlMmNjIiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3LyIsIm9pZCI6IjZmOWViOWIzLTFhYjgtNDI1NC05YWQ5LTY1N2UzOGNhOGU3MSIsInJvbGVzIjpbIkFwcGxpY2F0aW9uLlJlYWRXcml0ZS5BbGwiLCJHcm91cC5SZWFkLkFsbCIsIkdyb3VwLlJlYWRXcml0ZS5BbGwiLCJEaXJlY3RvcnkuUmVhZC5BbGwiLCJTaXRlcy5GdWxsQ29udHJvbC5BbGwiXSwic3ViIjoiNmY5ZWI5YjMtMWFiOC00MjU0LTlhZDktNjU3ZTM4Y2E4ZTcxIiwidGlkIjoiOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3IiwidXRpIjoiRWRUcTktWlhkVUNHdVNJWDdEb0hBQSIsInZlciI6IjEuMCIsInhtc190Y2R0IjoxNDM2MjY5Njg3fQ.aDGeb_66hLbikAEXIXxjZ5-782sJ385_5PLqYfHQZ2N7HSNfARzmxWNr1iuAjx0ynwT0CFZjjcfb-gnA9O7z_geJR7bWosgyFH_o1eYdExw5G6yIpufMOwIZCex9v6SsYt04KnzTxgQEfAV1LkjgQEzZjAp9BnzKA4MWZy28qdA4PnNKEw1fFHd0DcYaOA6Hd7-r3BitX67vuUpvyTMPAZCXBzOdQK06g4ac2pco1gl27Eo4vUie0oeEpo6hvNoM2kYSutyC2zm6hMDhN4I19aKJhcoP2St_paMcvasTQavNXtHUg7m5hcxjoxTwAyjM1xXRO6aQzYbSUNlppRKC1w"}');
            httpResponse.setStatusCode(200);
        }
        else if(req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/owners/$ref'))
        {
            httpResponse.setStatusCode(204);
        }
        
        else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-Java%20Team\''))
        {
            httpResponse.setBody('{"value":[]}');
            httpResponse.setStatusCode(200);
        }
        
        else */if(req.getEndpoint().endsWith('/$batch'))
        {
            httpResponse.setStatusCode(200);
            httpResponse.setBody('{     "responses": [         {             "id": "2",             "status": 200,             "headers": {                 "Cache-Control": "no-cache",                 "OData-Version": "4.0",                 "Content-Type": "application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=utf-8"             },             "body": {                 "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",                 "businessPhones": [],                 "displayName": "Morten Weber Bergesen",                 "givenName": "Morten Weber",                 "jobTitle": null,                 "mail": "mbe@viewledger.com",                 "mobilePhone": null,                 "officeLocation": null,                 "preferredLanguage": null,                 "surname": "Bergesen",                 "userPrincipalName": "morten.bergesen@viewledger.com",                 "id": "1a8470b3-9247-408b-afb0-4a0d160cb6b8"             }         },         {             "id": "3",             "status": 200,             "headers": {                 "Cache-Control": "no-cache",                 "OData-Version": "4.0",                 "Content-Type": "application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=utf-8"             },             "body": {                 "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",                 "businessPhones": [],                 "displayName": "Hozan Abdulla",                 "givenName": "Hozan",                 "jobTitle": null,                 "mail": "hab@viewledger.com",                 "mobilePhone": null,                 "officeLocation": null,                 "preferredLanguage": null,                 "surname": "Abdulla",                 "userPrincipalName": "hozan.abdulla23@viewledger.com",                 "id": "f85db537-ec40-4035-9279-8d9e5d6a42fb"             }         },         {             "id": "1",             "status": 200,             "headers": {                 "Cache-Control": "no-cache",                 "OData-Version": "4.0",                 "Content-Type": "application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=utf-8"             },             "body": {                 "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",                 "businessPhones": [],                 "displayName": "Marika Iselin Finseth",                 "givenName": "Marika Iselin",                 "jobTitle": null,                 "mail": "mfi@viewledger.com",                 "mobilePhone": null,                 "officeLocation": null,                 "preferredLanguage": null,                 "surname": "Finseth",                 "userPrincipalName": "marika.finseth23@viewledger.com",                 "id": "47a2ddd6-3101-418e-ba13-fa2092d76505"             }         }     ] }');     
        }
        else if(req.getEndpoint().endsWith('da3e84b5-1875-45c5-b5e3-c6a23a3517ab/owners')){
         
            String body='{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#directoryObjects","value":[{"@odata.type":"#microsoft.graph.user","id":"6e6e7452-b23c-4f2d-9dc3-45c2030d7e47","businessPhones":[],"displayName":"J\u00f8rgen Austheim Person","givenName":"J\u00f8rgen Austheim","jobTitle":"Direkt\u00f8r for kvalitet og internkontroll","mail":"marika.finseth23@viewledger.com","mobilePhone":"+47 90404101","officelocation":null,"preferredlanguage":null,"surname":"person","userPrincipalName":"marika.finseth23@viewledger.com"},{"id":"h0869b9-e5e4-4ef3-b474-0407a96a1c78","businessPhones":[],"displayName":"Andr\u00e9 reitan","givenname":"andr\u00e9","jobtitle":"systemkonsulent","mail":"are@viewledger.com","mobilePhone":"+47 48143531","officelocation":null,"preferredlanguage":null,"surname":"reitan","userPrincipalName":"Test.User@viewledger.com"},{"id":"31578jdc-416t-4f43-a411-08ce0637er45","businessPhones":["90092555"],"displayName":"Andreas eriksen","givenname":"andreas","jobtitle":"systemkonsulent","mail":"aer@viewledger.com","mobilePhone":"+47 90092555","officelocation":null,"preferredlanguage":null,"surname":"eriksen","userPrincipalName":"andreas.eriksen@viewledger.com"}]}';
            httpResponse.setStatusCode(200);
            httpResponse.setBody(body);
        }
        else if(req.getEndpoint().endsWith('da3e84b5-1875-45c5-b5e3-c6a23a3517ab/members')){
            String body='{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#directoryObjects","value":[{"@odata.type":"#microsoft.graph.user","id":"6e6e7452-b23c-4f2d-9dc3-45c2030d7e47","businessPhones":[],"displayName":"J\u00f8rgen Austheim Person","givenName":"J\u00f8rgen Austheim","jobTitle":"Direkt\u00f8r for kvalitet og internkontroll","mail":"marika.finseth23@viewledger.com","mobilePhone":"+47 90404101","officelocation":null,"preferredlanguage":null,"surname":"person","userPrincipalName":"marika.finseth23@viewledger.com"},{"id":"h0869b9-e5e4-4ef3-b474-0407a96a1c78","businessPhones":[],"displayName":"Andr\u00e9 reitan","givenname":"andr\u00e9","jobtitle":"systemkonsulent","mail":"are@viewledger.com","mobilePhone":"+47 48143531","officelocation":null,"preferredlanguage":null,"surname":"reitan","userPrincipalName":"Test.User@viewledger.com"},{"id":"31578jdc-416t-4f43-a411-08ce0637er45","businessPhones":["90092555"],"displayName":"Andreas eriksen","givenname":"andreas","jobtitle":"systemkonsulent","mail":"supporttest@binaryrepublik.com","mobilePhone":"+47 90092555","officelocation":null,"preferredlanguage":null,"surname":"eriksen","userPrincipalName":"zarana@binaryrepublik.com"}]}';
            httpResponse.setStatusCode(200);
            httpResponse.setBody(body);
        }
        return httpResponse;
    }
}