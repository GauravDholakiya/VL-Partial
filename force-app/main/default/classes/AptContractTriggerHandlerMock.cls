/**
 * @author Jozef
 * @date 6.9.2019.
 * @description //TODO
 */

@isTest
public class AptContractTriggerHandlerMock
{

    public class CreateTeamSiteHelper_Mock implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req)
        {
            System.debug('REQUEST CreateTeamSiteHelper_Mock ---------->'  +req);
            if(req.getEndpoint().endsWith('987d5b59-8ee7-4939-ab38-b720e9d085d7/oauth2/v2.0/token'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IkFRQUJBQUFBQUFBUDB3TGxxZExWVG9PcEE0a3d6U254NnpQamlfR2llR3JsSmR1T2ZzbVdfNWJyOWxINzRCbF9fVk9xWlQ4SmowV1padVVBUFotb1lUSTJ3QTZNdENMQ2o2T1gxenRDbjlMdzJUa1ZVSmVmVFNBQSIsImFsZyI6IlJTMjU2IiwieDV0IjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIiwia2lkIjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIn0.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC85ODdkNWI1OS04ZWU3LTQ5MzktYWIzOC1iNzIwZTlkMDg1ZDcvIiwiaWF0IjoxNTYzODY1MDYwLCJuYmYiOjE1NjM4NjUwNjAsImV4cCI6MTU2Mzg2ODk2MCwiYWlvIjoiNDJGZ1lCQnU4SnB0K25DMWc0ckh4ejZQaHNWN0FBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJTRkRDVG9TUCIsImFwcGlkIjoiYzRiODc2N2ItZDNlYy00YmFlLWI4ZWUtM2E1ZWI0ZThlMmNjIiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3LyIsIm9pZCI6IjZmOWViOWIzLTFhYjgtNDI1NC05YWQ5LTY1N2UzOGNhOGU3MSIsInJvbGVzIjpbIkFwcGxpY2F0aW9uLlJlYWRXcml0ZS5BbGwiLCJHcm91cC5SZWFkLkFsbCIsIkdyb3VwLlJlYWRXcml0ZS5BbGwiLCJEaXJlY3RvcnkuUmVhZC5BbGwiLCJTaXRlcy5GdWxsQ29udHJvbC5BbGwiXSwic3ViIjoiNmY5ZWI5YjMtMWFiOC00MjU0LTlhZDktNjU3ZTM4Y2E4ZTcxIiwidGlkIjoiOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3IiwidXRpIjoiRWRUcTktWlhkVUNHdVNJWDdEb0hBQSIsInZlciI6IjEuMCIsInhtc190Y2R0IjoxNDM2MjY5Njg3fQ.aDGeb_66hLbikAEXIXxjZ5-782sJ385_5PLqYfHQZ2N7HSNfARzmxWNr1iuAjx0ynwT0CFZjjcfb-gnA9O7z_geJR7bWosgyFH_o1eYdExw5G6yIpufMOwIZCex9v6SsYt04KnzTxgQEfAV1LkjgQEzZjAp9BnzKA4MWZy28qdA4PnNKEw1fFHd0DcYaOA6Hd7-r3BitX67vuUpvyTMPAZCXBzOdQK06g4ac2pco1gl27Eo4vUie0oeEpo6hvNoM2kYSutyC2zm6hMDhN4I19aKJhcoP2St_paMcvasTQavNXtHUg7m5hcxjoxTwAyjM1xXRO6aQzYbSUNlppRKC1w"}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-Java%20Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-Salesforce%20Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'sfo-Task%20Manager%20Account%20Test\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-ASP%20Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().endsWith('groups/d42d9454-d843-4f93-b99c-a08c7d87e6fa/owners'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#directoryObjects",     "value": [         {             "@odata.type": "#microsoft.graph.user",             "id": "f08059b9-e5e4-4ef3-b474-0407a96a2b33",             "businessPhones": [],             "displayName": "André Reitan",             "givenName": "André",             "jobTitle": null,             "mail": "are@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Reitan",             "userPrincipalName": "andre.reitan@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "31578edc-419d-4f43-a411-08ce0636ad8e",             "businessPhones": [],             "displayName": "Andreas Eriksen",             "givenName": "Andreas",             "jobTitle": null,             "mail": "aer@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Eriksen",             "userPrincipalName": "andreas.eriksen@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "d33eea59-0df5-46c6-9864-44400497358f",             "businessPhones": [],             "displayName": "Dag Ove Valsgaard",             "givenName": "Dag Ove",             "jobTitle": null,             "mail": "dva@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Valsgaard",             "userPrincipalName": "dag.valsgaard@viewledger.com"         }     ] }');
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().endsWith('groups/15e55f98-e3c7-4313-b989-a929b29d120e/owners'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#directoryObjects",     "value": [         {             "@odata.type": "#microsoft.graph.user",             "id": "9f9f1646-b23c-4f2d-9dc3-45c2030d7f14",             "businessPhones": [],             "displayName": "Jørgen Austheim Person",             "givenName": "Jørgen Austheim",             "jobTitle": null,             "mail": "jpe@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Person",             "userPrincipalName": "jorgen.person@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "1a8470b3-9247-408b-afb0-4a0d160cb6b8",             "businessPhones": [],             "displayName": "Morten Weber Bergesen",             "givenName": "Morten Weber",             "jobTitle": null,             "mail": "mbe@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Bergesen",             "userPrincipalName": "morten.bergesen@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "7c20ad22-6d22-470b-a282-9e025c4d0850",             "businessPhones": [],             "displayName": "Anders Mørland",             "givenName": "Anders",             "jobTitle": null,             "mail": "anders.morland@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Mørland",             "userPrincipalName": "anders.morland@viewledger.com"         }     ] }');
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().endsWith('v1.0/groups'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"id":"da3e84b5-1875-45c5-b5e3-c6a23a3517ab","deletedDateTime":null,"classification":null,"createdDateTime":"2019-07-23T07:42:21Z","creationOptions":[],"description":"VCD-Asia Team description","displayName":"VCD-Asia Team","groupTypes":["Unified"],"mail":"VCD-AsiaTeam@viewledger.onmicrosoft.com","mailEnabled":true,"mailNickname":"VCD-AsiaTeam","onPremisesLastSyncDateTime":null,"onPremisesSecurityIdentifier":null,"onPremisesSyncEnabled":null,"preferredDataLocation":null,"proxyAddresses":["SMTP:VCD-AsiaTeam@viewledger.onmicrosoft.com"],"renewedDateTime":"2019-07-23T07:42:21Z","resourceBehaviorOptions":[],"resourceProvisioningOptions":[],"securityEnabled":false,"visibility":"Public","onPremisesProvisioningErrors":[]}');
                res.setStatusCode(201);
                return res;
            }
            else if (req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/team'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#teams/$entity","id":"da3e84b5-1875-45c5-b5e3-c6a23a3517ab","displayName":"VCD-Asia Team","description":"VCD-Asia Team description","internalId":"19:f9d37e3bc6f6411c8ce55bd7e85bcd34@thread.skype","webUrl":"https://teams.microsoft.com/l/team/19:f9d37e3bc6f6411c8ce55bd7e85bcd34%40thread.skype/conversations?groupId=da3e84b5-1875-45c5-b5e3-c6a23a3517ab&tenantId=987d5b59-8ee7-4939-ab38-b720e9d085d7","isArchived":null,"discoverySettings":null,"memberSettings":{"allowCreateUpdateChannels":true,"allowDeleteChannels":true,"allowAddRemoveApps":true,"allowCreateUpdateRemoveTabs":true,"allowCreateUpdateRemoveConnectors":true},"guestSettings":{"allowCreateUpdateChannels":false,"allowDeleteChannels":false},"messagingSettings":{"allowUserEditMessages":true,"allowUserDeleteMessages":true,"allowOwnerDeleteMessages":true,"allowTeamMentions":true,"allowChannelMentions":true},"funSettings":{"allowGiphy":true,"giphyContentRating":"strict","allowStickersAndMemes":true,"allowCustomMemes":true}}');
                res.setStatusCode(201);
                return res;
            }
            else if (req.getEndpoint().endsWith('/users/marika.finseth@viewledger.com'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",     "businessPhones": [],     "displayName": "Marika Iselin Finseth",     "givenName": "Marika Iselin",     "jobTitle": null,     "mail": "mfi@viewledger.com",     "mobilePhone": null,     "officeLocation": null,     "preferredLanguage": null,     "surname": "Finseth",     "userPrincipalName": "marika.finseth@viewledger.com",     "id": "47a2ddd6-3101-418e-ba13-fa2092d76505" }');
                res.setStatusCode(201);
                return res;
            }
            else if (req.getEndpoint().endsWith('/users/piyush@binaryrepublik.com'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{   "error": {     "code": "Request_ResourceNotFound",     "message": "Resource \'piyush@binaryrepublik.com\' does not exist or one of its queried reference-property objects are not present.",     "innerError": {       "request-id": "134a5722-9404-42ad-af2b-e02466230f11",       "date": "2019-07-31T14:16:52"     }   } }');
                res.setStatusCode(404);
                return res;
            }
            else if(req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/owners/47a2ddd6-3101-418e-ba13-fa2092d76505/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res;
            }
            else if(req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/owners/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res;
            }
            else if(req.getEndpoint().endsWith('/users/hozan.abdulla@viewledger.com'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",     "businessPhones": [],     "displayName": "Hozan Abdulla",     "givenName": "Hozan",     "jobTitle": null,     "mail": "hab@viewledger.com",     "mobilePhone": null,     "officeLocation": null,     "preferredLanguage": null,     "surname": "Abdulla",     "userPrincipalName": "hozan.abdulla@viewledger.com",     "id": "f85db537-ec40-4035-9279-8d9e5d6a42fb" }');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/members/f85db537-ec40-4035-9279-8d9e5d6a42fb/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res;
            }
            else if(req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/members/47a2ddd6-3101-418e-ba13-fa2092d76505/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res;
            }
            else if(req.getEndpoint().endsWith('/$batch'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatus('Success');
                res.setStatusCode(200);
                return res;
            }
            else
            {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    /*

    public class CreateTeamSiteHelper_Mock implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req)
        {

            if(req.getEndpoint().endsWith('987d5b59-8ee7-4939-ab38-b720e9d085d7/oauth2/v2.0/token'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IkFRQUJBQUFBQUFBUDB3TGxxZExWVG9PcEE0a3d6U254NnpQamlfR2llR3JsSmR1T2ZzbVdfNWJyOWxINzRCbF9fVk9xWlQ4SmowV1padVVBUFotb1lUSTJ3QTZNdENMQ2o2T1gxenRDbjlMdzJUa1ZVSmVmVFNBQSIsImFsZyI6IlJTMjU2IiwieDV0IjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIiwia2lkIjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIn0.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC85ODdkNWI1OS04ZWU3LTQ5MzktYWIzOC1iNzIwZTlkMDg1ZDcvIiwiaWF0IjoxNTYzODY1MDYwLCJuYmYiOjE1NjM4NjUwNjAsImV4cCI6MTU2Mzg2ODk2MCwiYWlvIjoiNDJGZ1lCQnU4SnB0K25DMWc0ckh4ejZQaHNWN0FBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJTRkRDVG9TUCIsImFwcGlkIjoiYzRiODc2N2ItZDNlYy00YmFlLWI4ZWUtM2E1ZWI0ZThlMmNjIiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3LyIsIm9pZCI6IjZmOWViOWIzLTFhYjgtNDI1NC05YWQ5LTY1N2UzOGNhOGU3MSIsInJvbGVzIjpbIkFwcGxpY2F0aW9uLlJlYWRXcml0ZS5BbGwiLCJHcm91cC5SZWFkLkFsbCIsIkdyb3VwLlJlYWRXcml0ZS5BbGwiLCJEaXJlY3RvcnkuUmVhZC5BbGwiLCJTaXRlcy5GdWxsQ29udHJvbC5BbGwiXSwic3ViIjoiNmY5ZWI5YjMtMWFiOC00MjU0LTlhZDktNjU3ZTM4Y2E4ZTcxIiwidGlkIjoiOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3IiwidXRpIjoiRWRUcTktWlhkVUNHdVNJWDdEb0hBQSIsInZlciI6IjEuMCIsInhtc190Y2R0IjoxNDM2MjY5Njg3fQ.aDGeb_66hLbikAEXIXxjZ5-782sJ385_5PLqYfHQZ2N7HSNfARzmxWNr1iuAjx0ynwT0CFZjjcfb-gnA9O7z_geJR7bWosgyFH_o1eYdExw5G6yIpufMOwIZCex9v6SsYt04KnzTxgQEfAV1LkjgQEzZjAp9BnzKA4MWZy28qdA4PnNKEw1fFHd0DcYaOA6Hd7-r3BitX67vuUpvyTMPAZCXBzOdQK06g4ac2pco1gl27Eo4vUie0oeEpo6hvNoM2kYSutyC2zm6hMDhN4I19aKJhcoP2St_paMcvasTQavNXtHUg7m5hcxjoxTwAyjM1xXRO6aQzYbSUNlppRKC1w"}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'sfo-Java%20Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'sfo-Salesforce%20Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'sfo-Task%20Manager%20Account%20Test\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;
            }

            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'sfo-ASP%20Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().endsWith('groups/d42d9454-d843-4f93-b99c-a08c7d87e6fa/owners'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#directoryObjects",     "value": [         {             "@odata.type": "#microsoft.graph.user",             "id": "f08059b9-e5e4-4ef3-b474-0407a96a2b33",             "businessPhones": [],             "displayName": "André Reitan",             "givenName": "André",             "jobTitle": null,             "mail": "are@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Reitan",             "userPrincipalName": "andre.reitan@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "31578edc-419d-4f43-a411-08ce0636ad8e",             "businessPhones": [],             "displayName": "Andreas Eriksen",             "givenName": "Andreas",             "jobTitle": null,             "mail": "aer@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Eriksen",             "userPrincipalName": "andreas.eriksen@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "d33eea59-0df5-46c6-9864-44400497358f",             "businessPhones": [],             "displayName": "Dag Ove Valsgaard",             "givenName": "Dag Ove",             "jobTitle": null,             "mail": "dva@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Valsgaard",             "userPrincipalName": "dag.valsgaard@viewledger.com"         }     ] }');
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().endsWith('groups/15e55f98-e3c7-4313-b989-a929b29d120e/owners'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#directoryObjects",     "value": [         {             "@odata.type": "#microsoft.graph.user",             "id": "9f9f1646-b23c-4f2d-9dc3-45c2030d7f14",             "businessPhones": [],             "displayName": "Jørgen Austheim Person",             "givenName": "Jørgen Austheim",             "jobTitle": null,             "mail": "jpe@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Person",             "userPrincipalName": "jorgen.person@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "1a8470b3-9247-408b-afb0-4a0d160cb6b8",             "businessPhones": [],             "displayName": "Morten Weber Bergesen",             "givenName": "Morten Weber",             "jobTitle": null,             "mail": "mbe@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Bergesen",             "userPrincipalName": "morten.bergesen@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "7c20ad22-6d22-470b-a282-9e025c4d0850",             "businessPhones": [],             "displayName": "Anders Mørland",             "givenName": "Anders",             "jobTitle": null,             "mail": "anders.morland@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Mørland",             "userPrincipalName": "anders.morland@viewledger.com"         }     ] }');
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().endsWith('v1.0/groups'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"id":"da3e84b5-1875-45c5-b5e3-c6a23a3517ab","deletedDateTime":null,"classification":null,"createdDateTime":"2019-07-23T07:42:21Z","creationOptions":[],"description":"sfo-Asia Team description","displayName":"sfo-Asia Team","groupTypes":["Unified"],"mail":"sfo-AsiaTeam@viewledger.onmicrosoft.com","mailEnabled":true,"mailNickname":"sfo-AsiaTeam","onPremisesLastSyncDateTime":null,"onPremisesSecurityIdentifier":null,"onPremisesSyncEnabled":null,"preferredDataLocation":null,"proxyAddresses":["SMTP:sfo-AsiaTeam@viewledger.onmicrosoft.com"],"renewedDateTime":"2019-07-23T07:42:21Z","resourceBehaviorOptions":[],"resourceProvisioningOptions":[],"securityEnabled":false,"visibility":"Public","onPremisesProvisioningErrors":[]}');
                res.setStatusCode(201);
                return res;
            }
            else if (req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/team'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#teams/$entity","id":"da3e84b5-1875-45c5-b5e3-c6a23a3517ab","displayName":"sfo-Asia Team","description":"sfo-Asia Team description","internalId":"19:f9d37e3bc6f6411c8ce55bd7e85bcd34@thread.skype","webUrl":"https://teams.microsoft.com/l/team/19:f9d37e3bc6f6411c8ce55bd7e85bcd34%40thread.skype/conversations?groupId=da3e84b5-1875-45c5-b5e3-c6a23a3517ab&tenantId=987d5b59-8ee7-4939-ab38-b720e9d085d7","isArchived":null,"discoverySettings":null,"memberSettings":{"allowCreateUpdateChannels":true,"allowDeleteChannels":true,"allowAddRemoveApps":true,"allowCreateUpdateRemoveTabs":true,"allowCreateUpdateRemoveConnectors":true},"guestSettings":{"allowCreateUpdateChannels":false,"allowDeleteChannels":false},"messagingSettings":{"allowUserEditMessages":true,"allowUserDeleteMessages":true,"allowOwnerDeleteMessages":true,"allowTeamMentions":true,"allowChannelMentions":true},"funSettings":{"allowGiphy":true,"giphyContentRating":"strict","allowStickersAndMemes":true,"allowCustomMemes":true}}');
                res.setStatusCode(201);
                return res;
            }
            else if (req.getEndpoint().endsWith('/users/marika.finseth@viewledger.com'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",     "businessPhones": [],     "displayName": "Marika Iselin Finseth",     "givenName": "Marika Iselin",     "jobTitle": null,     "mail": "mfi@viewledger.com",     "mobilePhone": null,     "officeLocation": null,     "preferredLanguage": null,     "surname": "Finseth",     "userPrincipalName": "marika.finseth@viewledger.com",     "id": "47a2ddd6-3101-418e-ba13-fa2092d76505" }');
                res.setStatusCode(201);
                return res;
            }
            else if (req.getEndpoint().endsWith('/users/piyush@binaryrepublik.com'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{   "error": {     "code": "Request_ResourceNotFound",     "message": "Resource \'piyush@binaryrepublik.com\' does not exist or one of its queried reference-property objects are not present.",     "innerError": {       "request-id": "134a5722-9404-42ad-af2b-e02466230f11",       "date": "2019-07-31T14:16:52"     }   } }');
                res.setStatusCode(404);
                return res;
            }
            else if(req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/owners/47a2ddd6-3101-418e-ba13-fa2092d76505/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res;
            }
            else if(req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/owners/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res;
            }
            else if(req.getEndpoint().endsWith('/users/hozan.abdulla@viewledger.com'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",     "businessPhones": [],     "displayName": "Hozan Abdulla",     "givenName": "Hozan",     "jobTitle": null,     "mail": "hab@viewledger.com",     "mobilePhone": null,     "officeLocation": null,     "preferredLanguage": null,     "surname": "Abdulla",     "userPrincipalName": "hozan.abdulla@viewledger.com",     "id": "f85db537-ec40-4035-9279-8d9e5d6a42fb" }');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/members/f85db537-ec40-4035-9279-8d9e5d6a42fb/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res;
            }
            else if(req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/members/47a2ddd6-3101-418e-ba13-fa2092d76505/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res;
            }
            else if(req.getEndpoint().endsWith('/$batch'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatus('Success');
                res.setStatusCode(200);
                return res;
            }
            else
            {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

     */

}