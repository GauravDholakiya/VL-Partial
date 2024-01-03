/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         ContractTriggerhandler_Mock.apxc 
Description:  Test Mock Class that creates Fake Callout Responses for Rest Callout Request for CreateTeamSiteHelper_Test class.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
July 2019        0.1         Parthesh                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

@isTest
public class ContractTriggerhandler_Mock
{
    public class CreateTeamSiteHelper_Mock implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        { 
            system.debug('req : '+req);
            if(req.getEndpoint().endsWith('987d5b59-8ee7-4939-ab38-b720e9d085d7/oauth2/v2.0/token'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IkFRQUJBQUFBQUFBUDB3TGxxZExWVG9PcEE0a3d6U254NnpQamlfR2llR3JsSmR1T2ZzbVdfNWJyOWxINzRCbF9fVk9xWlQ4SmowV1padVVBUFotb1lUSTJ3QTZNdENMQ2o2T1gxenRDbjlMdzJUa1ZVSmVmVFNBQSIsImFsZyI6IlJTMjU2IiwieDV0IjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIiwia2lkIjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIn0.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC85ODdkNWI1OS04ZWU3LTQ5MzktYWIzOC1iNzIwZTlkMDg1ZDcvIiwiaWF0IjoxNTYzODY1MDYwLCJuYmYiOjE1NjM4NjUwNjAsImV4cCI6MTU2Mzg2ODk2MCwiYWlvIjoiNDJGZ1lCQnU4SnB0K25DMWc0ckh4ejZQaHNWN0FBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJTRkRDVG9TUCIsImFwcGlkIjoiYzRiODc2N2ItZDNlYy00YmFlLWI4ZWUtM2E1ZWI0ZThlMmNjIiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3LyIsIm9pZCI6IjZmOWViOWIzLTFhYjgtNDI1NC05YWQ5LTY1N2UzOGNhOGU3MSIsInJvbGVzIjpbIkFwcGxpY2F0aW9uLlJlYWRXcml0ZS5BbGwiLCJHcm91cC5SZWFkLkFsbCIsIkdyb3VwLlJlYWRXcml0ZS5BbGwiLCJEaXJlY3RvcnkuUmVhZC5BbGwiLCJTaXRlcy5GdWxsQ29udHJvbC5BbGwiXSwic3ViIjoiNmY5ZWI5YjMtMWFiOC00MjU0LTlhZDktNjU3ZTM4Y2E4ZTcxIiwidGlkIjoiOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3IiwidXRpIjoiRWRUcTktWlhkVUNHdVNJWDdEb0hBQSIsInZlciI6IjEuMCIsInhtc190Y2R0IjoxNDM2MjY5Njg3fQ.aDGeb_66hLbikAEXIXxjZ5-782sJ385_5PLqYfHQZ2N7HSNfARzmxWNr1iuAjx0ynwT0CFZjjcfb-gnA9O7z_geJR7bWosgyFH_o1eYdExw5G6yIpufMOwIZCex9v6SsYt04KnzTxgQEfAV1LkjgQEzZjAp9BnzKA4MWZy28qdA4PnNKEw1fFHd0DcYaOA6Hd7-r3BitX67vuUpvyTMPAZCXBzOdQK06g4ac2pco1gl27Eo4vUie0oeEpo6hvNoM2kYSutyC2zm6hMDhN4I19aKJhcoP2St_paMcvasTQavNXtHUg7m5hcxjoxTwAyjM1xXRO6aQzYbSUNlppRKC1w"}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-Java+Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;                
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-Salesforce+Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;                
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-ASP+Team\''))
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
            else if (req.getEndpoint().endsWith('teams/da3e84b5-1875-45c5-b5e3-c6a23a3517ab'))
            {
                HTTPResponse res = new HTTPResponse();
                //res.setBody('{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#teams/$entity","id":"da3e84b5-1875-45c5-b5e3-c6a23a3517ab","displayName":"VCD-Asia Team","description":"VCD-Asia Team description","internalId":"19:f9d37e3bc6f6411c8ce55bd7e85bcd34@thread.skype","webUrl":"https://teams.microsoft.com/l/team/19:f9d37e3bc6f6411c8ce55bd7e85bcd34%40thread.skype/conversations?groupId=da3e84b5-1875-45c5-b5e3-c6a23a3517ab&tenantId=987d5b59-8ee7-4939-ab38-b720e9d085d7","isArchived":null,"discoverySettings":null,"memberSettings":{"allowCreateUpdateChannels":true,"allowDeleteChannels":true,"allowAddRemoveApps":true,"allowCreateUpdateRemoveTabs":true,"allowCreateUpdateRemoveConnectors":true},"guestSettings":{"allowCreateUpdateChannels":false,"allowDeleteChannels":false},"messagingSettings":{"allowUserEditMessages":true,"allowUserDeleteMessages":true,"allowOwnerDeleteMessages":true,"allowTeamMentions":true,"allowChannelMentions":true},"funSettings":{"allowGiphy":true,"giphyContentRating":"strict","allowStickersAndMemes":true,"allowCustomMemes":true}}');
                res.setStatusCode(200);
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
            else if(req.getEndpoint().endsWith('sites/viewledger.sharepoint.com/lists/'+System.Label.SharePointListName+'/items'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatus('Created');
                res.setStatusCode(201);
                return res; 
            }
            //code Addded by Akshay 
            else if (req.getEndpoint().endsWith('https://devviewledgerapi.azurewebsites.net/api/api/Teams/CreateTeam')) 
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"jsonResponse":[{"groupId":"88deaa70-8a21-4cff-936f-41a3edf8f552","isTeamCreated":true,"url":"https://viewledger.sharepoint.com/sites/SBOX_VCD-Gtest0321C","teamName":"SBOX_VCD-Gtest0321C","email":"SBOX_VCD-Gtest0321C@viewledger.com","mailNickName":"SBOX_VCD-Gtest0321C"}],"isSuccess":true,"statusCode":200,"message":"Teams with multiple channels is created"}');
                res.setStatusCode(200);
                system.debug('Response body'+res);
                return res;
            } 
             else if (req.getEndpoint().endsWith('https://devviewledgerapi.azurewebsites.net/api/api/Teams/UpdateTeam')) 
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody(' {"data":{"groupId":"3314f402-92f8-4f5e-9966-99bdb0bff7b3"},"isSuccess":true,"statusCode":200,"message":"Owners and members added or deleted successfully"}');
                res.setStatusCode(200);
                system.debug('Response body'+res);
                return res;
            } 
            
             else if (req.getEndpoint().endsWith('https://devviewledgerapi.azurewebsites.net/api/file/getterm/b96aecbd-3eae-4435-97f7-86aa793686f8')) 
            {
                 HTTPResponse res = new HTTPResponse();
                
               res.setBody('');
                res.setStatusCode(200);
                system.debug('Response body'+res);
                return res;
                 
            } 
            else if (req.getEndpoint().endsWith('https://devviewledgerapi.azurewebsites.net/api/File/GetAllDocuments/nullPayrollSharedChannel/image')) 
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"data":[{"author":"Yash Patel","docIcon":"jpg","fileUrl":"https://viewledger.sharepoint.com/sites/SBOX_VCD-MewTest_LogCheckTest-AccountingSharedChannel/Shared Documents/image.jpg","modified":"3/24/2023 7:54:05 AM","name":"image.jpg","title":"image.jpg"},{"author":"Yash Patel","docIcon":"jpg","fileUrl":"https://viewledger.sharepoint.com/sites/SBOX_VCD-MewTest_LogCheckTest-AccountingSharedChannel/Shared Documents/capturing - Copy.jpg","modified":"3/24/2023 7:28:26 AM","name":"capturing - Copy.jpg","title":"capturing - Copy.jpg"}]}');
                res.setStatusCode(200);
                system.debug('Response body'+res);
                return res;
            } else if (req.getEndpoint().endsWith('https://devviewledgerapi.azurewebsites.net/api/File/GetAllDocuments/SBOX_NewTest_testupl2PayrollSharedChannel?SortingField=FileLeafRef&SortingDirection=asc')) 
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"data":[{"author":"Yash Patel","docIcon":"jpg","fileUrl":"https://viewledger.sharepoint.com/sites/SBOX_VCD-MewTest_LogCheckTest-AccountingSharedChannel/Shared Documents/image.jpg","modified":"3/24/20237: 54: 05AM","name":"image.jpg","title":"image.jpg"},{"author":"Yash Patel","docIcon":"jpg","fileUrl":"https://viewledger.sharepoint.com/sites/SBOX_VCD-MewTest_LogCheckTest-AccountingSharedChannel/Shared Documents/capturing - Copy.jpg","modified":"3/24/2023 7:28:26 AM","name":"capturing - Copy.jpg","title":"capturing - Copy.jpg"}]');
                res.setStatusCode(200);
                system.debug('Response body'+res);
                return res;
            } 
            else if (req.getEndpoint().endsWith('https://devviewledgerapi.azurewebsites.net/api/File/FileExists')) 
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"sharpointUrl":"https://viewledger.sharepoint.com/sites/SBOX_VCD-MewTest_LogCheckTest-AccountingSharedChannel","libraryName":"Documents","isSharedChannel":true,"fileNames":["class.txt","Code.txt"]}');
                res.setStatusCode(200);
                system.debug('Response body'+res);
                return res;
            } 
            
            else 
            {
               // System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
    
    public class CreateTeamSiteHelper_MockforUpdate implements HttpCalloutMock
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
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-Java+Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;                
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-Salesforce+Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;                
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-ASP+Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;                
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-Test+Team\''))
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
                res.setStatusCode(404);
                return res;
            }
            else if (req.getEndpoint().endsWith('teams/da3e84b5-1875-45c5-b5e3-c6a23a3517ab')) 
            {
                HTTPResponse res = new HTTPResponse();
                //res.setBody('{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#teams/$entity","id":"da3e84b5-1875-45c5-b5e3-c6a23a3517ab","displayName":"VCD-Asia Team","description":"VCD-Asia Team description","internalId":"19:f9d37e3bc6f6411c8ce55bd7e85bcd34@thread.skype","webUrl":"https://teams.microsoft.com/l/team/19:f9d37e3bc6f6411c8ce55bd7e85bcd34%40thread.skype/conversations?groupId=da3e84b5-1875-45c5-b5e3-c6a23a3517ab&tenantId=987d5b59-8ee7-4939-ab38-b720e9d085d7","isArchived":null,"discoverySettings":null,"memberSettings":{"allowCreateUpdateChannels":true,"allowDeleteChannels":true,"allowAddRemoveApps":true,"allowCreateUpdateRemoveTabs":true,"allowCreateUpdateRemoveConnectors":true},"guestSettings":{"allowCreateUpdateChannels":false,"allowDeleteChannels":false},"messagingSettings":{"allowUserEditMessages":true,"allowUserDeleteMessages":true,"allowOwnerDeleteMessages":true,"allowTeamMentions":true,"allowChannelMentions":true},"funSettings":{"allowGiphy":true,"giphyContentRating":"strict","allowStickersAndMemes":true,"allowCustomMemes":true}}');
                res.setStatusCode(200);
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
                res.setStatusCode(200);
                res.setBody('{     "responses": [         {             "id": "2",             "status": 200,             "headers": {                 "Cache-Control": "no-cache",                 "OData-Version": "4.0",                 "Content-Type": "application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=utf-8"             },             "body": {                 "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",                 "businessPhones": [],                 "displayName": "Morten Weber Bergesen",                 "givenName": "Morten Weber",                 "jobTitle": null,                 "mail": "mbe@viewledger.com",                 "mobilePhone": null,                 "officeLocation": null,                 "preferredLanguage": null,                 "surname": "Bergesen",                 "userPrincipalName": "morten.bergesen@viewledger.com",                 "id": "1a8470b3-9247-408b-afb0-4a0d160cb6b8"             }         },         {             "id": "3",             "status": 200,             "headers": {                 "Cache-Control": "no-cache",                 "OData-Version": "4.0",                 "Content-Type": "application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=utf-8"             },             "body": {                 "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",                 "businessPhones": [],                 "displayName": "Hozan Abdulla",                 "givenName": "Hozan",                 "jobTitle": null,                 "mail": "hab@viewledger.com",                 "mobilePhone": null,                 "officeLocation": null,                 "preferredLanguage": null,                 "surname": "Abdulla",                 "userPrincipalName": "hozan.abdulla@viewledger.com",                 "id": "f85db537-ec40-4035-9279-8d9e5d6a42fb"             }         },         {             "id": "1",             "status": 200,             "headers": {                 "Cache-Control": "no-cache",                 "OData-Version": "4.0",                 "Content-Type": "application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=utf-8"             },             "body": {                 "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",                 "businessPhones": [],                 "displayName": "Marika Iselin Finseth",                 "givenName": "Marika Iselin",                 "jobTitle": null,                 "mail": "mfi@viewledger.com",                 "mobilePhone": null,                 "officeLocation": null,                 "preferredLanguage": null,                 "surname": "Finseth",                 "userPrincipalName": "marika.finseth@viewledger.com",                 "id": "47a2ddd6-3101-418e-ba13-fa2092d76505"             }         }     ] }');
                return res; 
            }
            else if(req.getEndpoint().endsWith('da3e84b5-1875-45c5-b5e3-c6a23a3517ab/owners')){
                HTTPResponse res = new HTTPResponse();
                String body='{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#directoryObjects","value":[{"@odata.type":"#microsoft.graph.user","id":"6e6e7452-b23c-4f2d-9dc3-45c2030d7e47","businessPhones":[],"displayName":"J\u00f8rgen Austheim Person","givenName":"J\u00f8rgen Austheim","jobTitle":"Direkt\u00f8r for kvalitet og internkontroll","mail":"piyush@binaryrepublik.com","mobilePhone":"+47 90404101","officelocation":null,"preferredlanguage":null,"surname":"person","userPrincipalName":"piyush@binaryrepublik.com"},{"id":"h0869b9-e5e4-4ef3-b474-0407a96a1c78","businessPhones":[],"displayName":"Andr\u00e9 reitan","givenname":"andr\u00e9","jobtitle":"systemkonsulent","mail":"are@viewledger.com","mobilePhone":"+47 48143531","officelocation":null,"preferredlanguage":null,"surname":"reitan","userPrincipalName":"andre.reitan@viewledger.com"},{"id":"31578jdc-416t-4f43-a411-08ce0637er45","businessPhones":["90092555"],"displayName":"Andreas eriksen","givenname":"andreas","jobtitle":"systemkonsulent","mail":"aer@viewledger.com","mobilePhone":"+47 90092555","officelocation":null,"preferredlanguage":null,"surname":"eriksen","userPrincipalName":"andreas.eriksen@viewledger.com"}]}';
                res.setStatusCode(200);
                res.setBody(body);
                return res; 
            }
            else if(req.getEndpoint().endsWith('da3e84b5-1875-45c5-b5e3-c6a23a3517ab/members')){
                HTTPResponse res = new HTTPResponse();
                String body='{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#directoryObjects","value":[{"@odata.type":"#microsoft.graph.user","id":"6e6e7452-b23c-4f2d-9dc3-45c2030d7e47","businessPhones":[],"displayName":"J\u00f8rgen Austheim Person","givenName":"J\u00f8rgen Austheim","jobTitle":"Direkt\u00f8r for kvalitet og internkontroll","mail":"piyush@binaryrepublik.com","mobilePhone":"+47 90404101","officelocation":null,"preferredlanguage":null,"surname":"person","userPrincipalName":"piyush@binaryrepublik.com"},{"id":"h0869b9-e5e4-4ef3-b474-0407a96a1c78","businessPhones":[],"displayName":"Andr\u00e9 reitan","givenname":"andr\u00e9","jobtitle":"systemkonsulent","mail":"are@viewledger.com","mobilePhone":"+47 48143531","officelocation":null,"preferredlanguage":null,"surname":"reitan","userPrincipalName":"andre.reitan@viewledger.com"},{"id":"31578jdc-416t-4f43-a411-08ce0637er45","businessPhones":["90092555"],"displayName":"Andreas eriksen","givenname":"andreas","jobtitle":"systemkonsulent","mail":"supporttest@binaryrepublik.com","mobilePhone":"+47 90092555","officelocation":null,"preferredlanguage":null,"surname":"eriksen","userPrincipalName":"zarana@binaryrepublik.com"}]}';
                res.setStatusCode(200);
                res.setBody(body);
                return res; 
            }
            else 
            {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
    
    public class usernotfound_MOCK implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        {
            HTTPResponse res = new HTTPResponse();
            
            if(req.getEndpoint().endsWith('987d5b59-8ee7-4939-ab38-b720e9d085d7/oauth2/v2.0/token'))
            {
                res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IkFRQUJBQUFBQUFBUDB3TGxxZExWVG9PcEE0a3d6U254NnpQamlfR2llR3JsSmR1T2ZzbVdfNWJyOWxINzRCbF9fVk9xWlQ4SmowV1padVVBUFotb1lUSTJ3QTZNdENMQ2o2T1gxenRDbjlMdzJUa1ZVSmVmVFNBQSIsImFsZyI6IlJTMjU2IiwieDV0IjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIiwia2lkIjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIn0.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC85ODdkNWI1OS04ZWU3LTQ5MzktYWIzOC1iNzIwZTlkMDg1ZDcvIiwiaWF0IjoxNTYzODY1MDYwLCJuYmYiOjE1NjM4NjUwNjAsImV4cCI6MTU2Mzg2ODk2MCwiYWlvIjoiNDJGZ1lCQnU4SnB0K25DMWc0ckh4ejZQaHNWN0FBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJTRkRDVG9TUCIsImFwcGlkIjoiYzRiODc2N2ItZDNlYy00YmFlLWI4ZWUtM2E1ZWI0ZThlMmNjIiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3LyIsIm9pZCI6IjZmOWViOWIzLTFhYjgtNDI1NC05YWQ5LTY1N2UzOGNhOGU3MSIsInJvbGVzIjpbIkFwcGxpY2F0aW9uLlJlYWRXcml0ZS5BbGwiLCJHcm91cC5SZWFkLkFsbCIsIkdyb3VwLlJlYWRXcml0ZS5BbGwiLCJEaXJlY3RvcnkuUmVhZC5BbGwiLCJTaXRlcy5GdWxsQ29udHJvbC5BbGwiXSwic3ViIjoiNmY5ZWI5YjMtMWFiOC00MjU0LTlhZDktNjU3ZTM4Y2E4ZTcxIiwidGlkIjoiOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3IiwidXRpIjoiRWRUcTktWlhkVUNHdVNJWDdEb0hBQSIsInZlciI6IjEuMCIsInhtc190Y2R0IjoxNDM2MjY5Njg3fQ.aDGeb_66hLbikAEXIXxjZ5-782sJ385_5PLqYfHQZ2N7HSNfARzmxWNr1iuAjx0ynwT0CFZjjcfb-gnA9O7z_geJR7bWosgyFH_o1eYdExw5G6yIpufMOwIZCex9v6SsYt04KnzTxgQEfAV1LkjgQEzZjAp9BnzKA4MWZy28qdA4PnNKEw1fFHd0DcYaOA6Hd7-r3BitX67vuUpvyTMPAZCXBzOdQK06g4ac2pco1gl27Eo4vUie0oeEpo6hvNoM2kYSutyC2zm6hMDhN4I19aKJhcoP2St_paMcvasTQavNXtHUg7m5hcxjoxTwAyjM1xXRO6aQzYbSUNlppRKC1w"}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-Java+Team\''))
            {
                res.setBody('{"value":[]}');
                res.setStatusCode(200);
                return res;                
            }
            else if (req.getEndpoint().endsWith('groups/d42d9454-d843-4f93-b99c-a08c7d87e6fa/owners')) 
            {
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#directoryObjects",     "value": [         {             "@odata.type": "#microsoft.graph.user",             "id": "f08059b9-e5e4-4ef3-b474-0407a96a2b33",             "businessPhones": [],             "displayName": "André Reitan",             "givenName": "André",             "jobTitle": null,             "mail": "are@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Reitan",             "userPrincipalName": "andre.reitan@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "31578edc-419d-4f43-a411-08ce0636ad8e",             "businessPhones": [],             "displayName": "Andreas Eriksen",             "givenName": "Andreas",             "jobTitle": null,             "mail": "aer@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Eriksen",             "userPrincipalName": "andreas.eriksen@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "d33eea59-0df5-46c6-9864-44400497358f",             "businessPhones": [],             "displayName": "Dag Ove Valsgaard",             "givenName": "Dag Ove",             "jobTitle": null,             "mail": "dva@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Valsgaard",             "userPrincipalName": "dag.valsgaard@viewledger.com"         }     ] }');
                res.setStatusCode(200);
                return res;
            } 
            else if (req.getEndpoint().endsWith('groups/15e55f98-e3c7-4313-b989-a929b29d120e/owners')) 
            {
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#directoryObjects",     "value": [         {             "@odata.type": "#microsoft.graph.user",             "id": "9f9f1646-b23c-4f2d-9dc3-45c2030d7f14",             "businessPhones": [],             "displayName": "Jørgen Austheim Person",             "givenName": "Jørgen Austheim",             "jobTitle": null,             "mail": "jpe@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Person",             "userPrincipalName": "jorgen.person@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "1a8470b3-9247-408b-afb0-4a0d160cb6b8",             "businessPhones": [],             "displayName": "Morten Weber Bergesen",             "givenName": "Morten Weber",             "jobTitle": null,             "mail": "mbe@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Bergesen",             "userPrincipalName": "morten.bergesen@viewledger.com"         },         {             "@odata.type": "#microsoft.graph.user",             "id": "7c20ad22-6d22-470b-a282-9e025c4d0850",             "businessPhones": [],             "displayName": "Anders Mørland",             "givenName": "Anders",             "jobTitle": null,             "mail": "anders.morland@viewledger.com",             "mobilePhone": null,             "officeLocation": null,             "preferredLanguage": null,             "surname": "Mørland",             "userPrincipalName": "anders.morland@viewledger.com"         }     ] }');
                res.setStatusCode(200);
                return res;
            } 
            else if (req.getEndpoint().endsWith('/owners/$ref')) 
            {
                res.setBody('{   "error": {     "code": "Request_ResourceNotFound",     "message": "Resource \'piyush@binaryrepublik.com\' does not exist or one of its queried reference-property objects are not present.",     "innerError": {       "request-id": "134a5722-9404-42ad-af2b-e02466230f11",       "date": "2019-07-31T14:16:52"     }   } }');
                res.setStatusCode(404);
                return res;
            }
            else if (req.getEndpoint().endsWith('groups/da3e84b5-1875-45c5-b5e3-c6a23a3517ab/team')) 
            {
                res.setBody('{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#teams/$entity","id":"da3e84b5-1875-45c5-b5e3-c6a23a3517ab","displayName":"VCD-Asia Team","description":"VCD-Asia Team description","internalId":"19:f9d37e3bc6f6411c8ce55bd7e85bcd34@thread.skype","webUrl":"https://teams.microsoft.com/l/team/19:f9d37e3bc6f6411c8ce55bd7e85bcd34%40thread.skype/conversations?groupId=da3e84b5-1875-45c5-b5e3-c6a23a3517ab&tenantId=987d5b59-8ee7-4939-ab38-b720e9d085d7","isArchived":null,"discoverySettings":null,"memberSettings":{"allowCreateUpdateChannels":true,"allowDeleteChannels":true,"allowAddRemoveApps":true,"allowCreateUpdateRemoveTabs":true,"allowCreateUpdateRemoveConnectors":true},"guestSettings":{"allowCreateUpdateChannels":false,"allowDeleteChannels":false},"messagingSettings":{"allowUserEditMessages":true,"allowUserDeleteMessages":true,"allowOwnerDeleteMessages":true,"allowTeamMentions":true,"allowChannelMentions":true},"funSettings":{"allowGiphy":true,"giphyContentRating":"strict","allowStickersAndMemes":true,"allowCustomMemes":true}}');
                res.setStatusCode(201);
                return res;
            }
            return res;
        }
    }
    
    public class RenameSP_MSTeam_Name_Mock implements HttpCalloutMock
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
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-Sweden+Team\''))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#groups",     "value": [         {             "id": "3b02a397-2de6-45bb-b63d-a07bbfd2a582",             "deletedDateTime": null,             "classification": null,             "createdDateTime": "2019-07-22T09:19:17Z",             "creationOptions": [],             "description": "VCD-Sweden Team description",             "displayName": "VCD-Sweden Team",             "groupTypes": [                 "Unified"             ],             "mail": "VCD-SwedenTeam@viewledger.com",             "mailEnabled": true,             "mailNickname": "VCD-SwedenTeam",             "onPremisesLastSyncDateTime": null,             "onPremisesSecurityIdentifier": null,             "onPremisesSyncEnabled": null,             "preferredDataLocation": null,             "proxyAddresses": [                 "SPO:SPO_c39cd414-48cd-4701-8272-2ea39a752ee5@SPO_987d5b59-8ee7-4939-ab38-b720e9d085d7",                 "SMTP:VCD-SwedenTeam@viewledger.com",                 "smtp:VCD-SwedenTeam@viewledger.onmicrosoft.com"             ],             "renewedDateTime": "2019-07-22T09:19:17Z",             "resourceBehaviorOptions": [],             "resourceProvisioningOptions": [                 "Team"             ],             "securityEnabled": false,             "visibility": "Public",             "onPremisesProvisioningErrors": []         }     ] }');
                res.setStatusCode(200);
                return res;                
            }
            else if(req.getEndpoint().endsWith('groups/3b02a397-2de6-45bb-b63d-a07bbfd2a582/owners/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res; 
            }
            else 
            {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
    
    public class TeamVerification implements HttpCalloutMock
    {
        HTTPResponse res = new HTTPResponse();
        public HTTPResponse respond(HTTPRequest req) 
        {
            if(req.getEndpoint().endsWith('987d5b59-8ee7-4939-ab38-b720e9d085d7/oauth2/v2.0/token'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IkFRQUJBQUFBQUFBUDB3TGxxZExWVG9PcEE0a3d6U254NnpQamlfR2llR3JsSmR1T2ZzbVdfNWJyOWxINzRCbF9fVk9xWlQ4SmowV1padVVBUFotb1lUSTJ3QTZNdENMQ2o2T1gxenRDbjlMdzJUa1ZVSmVmVFNBQSIsImFsZyI6IlJTMjU2IiwieDV0IjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIiwia2lkIjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIn0.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC85ODdkNWI1OS04ZWU3LTQ5MzktYWIzOC1iNzIwZTlkMDg1ZDcvIiwiaWF0IjoxNTYzODY1MDYwLCJuYmYiOjE1NjM4NjUwNjAsImV4cCI6MTU2Mzg2ODk2MCwiYWlvIjoiNDJGZ1lCQnU4SnB0K25DMWc0ckh4ejZQaHNWN0FBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJTRkRDVG9TUCIsImFwcGlkIjoiYzRiODc2N2ItZDNlYy00YmFlLWI4ZWUtM2E1ZWI0ZThlMmNjIiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3LyIsIm9pZCI6IjZmOWViOWIzLTFhYjgtNDI1NC05YWQ5LTY1N2UzOGNhOGU3MSIsInJvbGVzIjpbIkFwcGxpY2F0aW9uLlJlYWRXcml0ZS5BbGwiLCJHcm91cC5SZWFkLkFsbCIsIkdyb3VwLlJlYWRXcml0ZS5BbGwiLCJEaXJlY3RvcnkuUmVhZC5BbGwiLCJTaXRlcy5GdWxsQ29udHJvbC5BbGwiXSwic3ViIjoiNmY5ZWI5YjMtMWFiOC00MjU0LTlhZDktNjU3ZTM4Y2E4ZTcxIiwidGlkIjoiOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3IiwidXRpIjoiRWRUcTktWlhkVUNHdVNJWDdEb0hBQSIsInZlciI6IjEuMCIsInhtc190Y2R0IjoxNDM2MjY5Njg3fQ.aDGeb_66hLbikAEXIXxjZ5-782sJ385_5PLqYfHQZ2N7HSNfARzmxWNr1iuAjx0ynwT0CFZjjcfb-gnA9O7z_geJR7bWosgyFH_o1eYdExw5G6yIpufMOwIZCex9v6SsYt04KnzTxgQEfAV1LkjgQEzZjAp9BnzKA4MWZy28qdA4PnNKEw1fFHd0DcYaOA6Hd7-r3BitX67vuUpvyTMPAZCXBzOdQK06g4ac2pco1gl27Eo4vUie0oeEpo6hvNoM2kYSutyC2zm6hMDhN4I19aKJhcoP2St_paMcvasTQavNXtHUg7m5hcxjoxTwAyjM1xXRO6aQzYbSUNlppRKC1w"}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('Groups?$filter=displayName+eq+\'VCD-BR+Team\''))
            {
                res.setBody('{     "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#groups",     "value": [         {             "id": "4afce567-aec1-417d-bedf-35b1318f3deb",             "deletedDateTime": null,             "classification": null,             "createdDateTime": "2019-07-26T13:04:06Z",             "creationOptions": [],             "description": "VCD-BR Team description",             "displayName": "VCD-BR Team",             "groupTypes": [                 "Unified"             ],             "mail": "VCD-BRTeam@viewledger.com",             "mailEnabled": true,             "mailNickname": "VCD-BRTeam",             "onPremisesLastSyncDateTime": null,             "onPremisesSecurityIdentifier": null,             "onPremisesSyncEnabled": null,             "preferredDataLocation": null,             "proxyAddresses": [                 "SPO:SPO_69fcbe85-92b0-4b99-a03c-09784e785e99@SPO_987d5b59-8ee7-4939-ab38-b720e9d085d7",                 "SMTP:VCD-BRTeam@viewledger.com",                 "smtp:VCD-BRTeam@viewledger.onmicrosoft.com"             ],             "renewedDateTime": "2019-07-26T13:04:06Z",             "resourceBehaviorOptions": [],             "resourceProvisioningOptions": [                 "Team"             ],             "securityEnabled": false,             "visibility": "Public",             "onPremisesProvisioningErrors": []         }     ] }');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('groups/3b02a397-2de6-45bb-b63d-a07bbfd2a582/owners/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res; 
            }
            else if(req.getEndpoint().endsWith('groups/4afce567-aec1-417d-bedf-35b1318f3deb/owners/$ref'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(204);
                return res; 
            }
            else 
            {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
    
    public class renameTeam implements HttpCalloutMock
    {
        HTTPResponse res = new HTTPResponse();
        public HTTPResponse respond(HTTPRequest req) 
        {
            if(req.getEndpoint().endsWith('987d5b59-8ee7-4939-ab38-b720e9d085d7/oauth2/v2.0/token'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IkFRQUJBQUFBQUFBUDB3TGxxZExWVG9PcEE0a3d6U254NnpQamlfR2llR3JsSmR1T2ZzbVdfNWJyOWxINzRCbF9fVk9xWlQ4SmowV1padVVBUFotb1lUSTJ3QTZNdENMQ2o2T1gxenRDbjlMdzJUa1ZVSmVmVFNBQSIsImFsZyI6IlJTMjU2IiwieDV0IjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIiwia2lkIjoidTRPZk5GUEh3RUJvc0hqdHJhdU9iVjg0TG5ZIn0.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC85ODdkNWI1OS04ZWU3LTQ5MzktYWIzOC1iNzIwZTlkMDg1ZDcvIiwiaWF0IjoxNTYzODY1MDYwLCJuYmYiOjE1NjM4NjUwNjAsImV4cCI6MTU2Mzg2ODk2MCwiYWlvIjoiNDJGZ1lCQnU4SnB0K25DMWc0ckh4ejZQaHNWN0FBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJTRkRDVG9TUCIsImFwcGlkIjoiYzRiODc2N2ItZDNlYy00YmFlLWI4ZWUtM2E1ZWI0ZThlMmNjIiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3LyIsIm9pZCI6IjZmOWViOWIzLTFhYjgtNDI1NC05YWQ5LTY1N2UzOGNhOGU3MSIsInJvbGVzIjpbIkFwcGxpY2F0aW9uLlJlYWRXcml0ZS5BbGwiLCJHcm91cC5SZWFkLkFsbCIsIkdyb3VwLlJlYWRXcml0ZS5BbGwiLCJEaXJlY3RvcnkuUmVhZC5BbGwiLCJTaXRlcy5GdWxsQ29udHJvbC5BbGwiXSwic3ViIjoiNmY5ZWI5YjMtMWFiOC00MjU0LTlhZDktNjU3ZTM4Y2E4ZTcxIiwidGlkIjoiOTg3ZDViNTktOGVlNy00OTM5LWFiMzgtYjcyMGU5ZDA4NWQ3IiwidXRpIjoiRWRUcTktWlhkVUNHdVNJWDdEb0hBQSIsInZlciI6IjEuMCIsInhtc190Y2R0IjoxNDM2MjY5Njg3fQ.aDGeb_66hLbikAEXIXxjZ5-782sJ385_5PLqYfHQZ2N7HSNfARzmxWNr1iuAjx0ynwT0CFZjjcfb-gnA9O7z_geJR7bWosgyFH_o1eYdExw5G6yIpufMOwIZCex9v6SsYt04KnzTxgQEfAV1LkjgQEzZjAp9BnzKA4MWZy28qdA4PnNKEw1fFHd0DcYaOA6Hd7-r3BitX67vuUpvyTMPAZCXBzOdQK06g4ac2pco1gl27Eo4vUie0oeEpo6hvNoM2kYSutyC2zm6hMDhN4I19aKJhcoP2St_paMcvasTQavNXtHUg7m5hcxjoxTwAyjM1xXRO6aQzYbSUNlppRKC1w"}');
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().endsWith('/$batch'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{     "responses": [         {             "id": "1",             "status": 204,             "headers": {                 "Cache-Control": "no-cache"             },             "body": null         },         {             "id": "2",             "status": 204,             "headers": {                 "Cache-Control": "no-cache"             },             "body": null         }     ] }');
                res.setStatusCode(200);
                return res;
            }
            return res;
        }
    }
}