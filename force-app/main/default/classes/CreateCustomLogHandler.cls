public class CreateCustomLogHandler {
    
    
    public static String addCustomlogTeamsCreation(Integer statusCodeTeam,string statusMessage,String responseBody, String accountID, Boolean IsMSTeamCreated)
    {
        System.debug('##Team Creation Response in Custom handler'+responseBody);
        System.debug('bool isMSTeamCreated-->'+IsMSTeamCreated);
        List<Log__c> logList=new list<Log__c>();
        Log__c objLog = new Log__c();
        
        try{  
            if(responseBody !=null && string.isNotBlank(responseBody) && statusCodeTeam == 200){        
                Object obj = JSON.deserializeUntyped(responseBody);
                Map<String, Object> jsonMap = (Map<String, Object>)obj;
                String message = (String)jsonMap.get('message');
                boolean IsSucces = (boolean)jsonMap.get('isSuccess');
                Integer StatusCode= (Integer)jsonMap.get('statusCode');  
                system.debug('jsonMap++-->'+jsonMap);
                if(!jsonMap.isEmpty()){
                    List<Object> records = (List<Object>) jsonMap.get('jsonResponse'); //get the records
                    
                    String logResponse =(String)responseBody;
                    system.debug('records-->'+records);
                    if (!records.isEmpty()) {
                        
                        for (Object r : records) {                        
                            Map<String,Object> recordMap = (Map<String,Object>)r;    
                            system.debug('StatusCode is'+StatusCode);
                            string teamEmail =(String)recordMap.get('email');
                            objLog.JSONResponse__c = logResponse;
                            if((boolean)recordMap.get('isTeamCreated') != null){
                                objLog.IsMSTeamCreated__c =(boolean)recordMap.get('isTeamCreated');
                            }
                            objLog.SiteURL__c = (String)recordMap.get('url');
                            objLog.SPGroupID__c=(String)recordMap.get('groupId'); 
                            objLog.AccountID__c = accountID;
                            objLog.IsSuccess__c=IsSucces;
                            objLog.Message__c=message;
                            objLog.StatusCode__c=StatusCode;
                            objLog.TeamEmail__c= teamEmail;
                            
                            
                            logList.add(objLog);
                            
                            System.debug('LogList+++>'+logList);
                            
                        }
                        
                    }
                    else{
                        objLog.AccountID__c = accountID;
                        objLog.Message__c=message;
                        objLog.StatusCode__c=StatusCode;
                        
                        logList.add(objLog);
                    }
                    
                }
                
                
            }
            else{
                objLog.AccountID__c = accountID;
                objLog.Message__c=statusMessage;
                objLog.StatusCode__c=statusCodeTeam;
                
                logList.add(objLog);
                
            }
            system.debug('logList-->'+logList);
            insert logList;
        }
        catch(Exception ex)
        {
            system.debug('logList-++->'+logList);
            System.debug('CreateCustomLogHandler'+ex.getMessage());
        }
        return 'Create log sucessfully';
    }
    
    public static void addCustomlogUserManagement(string responseBody, Integer statusCode, String statusMessage ,String grpId ){
        List<Log__c> logList=new list<Log__c>();
        
        try {
            system.debug('responseBody'+responseBody + 'statusCode'+statusCode +'statusMessage'+statusMessage);
            
            if(statusCode == 200 && String.isNotBlank(responseBody)){
                
                Object resObj = JSON.deserializeUntyped(responseBody);
                Map<string, Object> responseMap = (Map<string, Object>)resObj;
                system.debug(responseMap);
                String message = (String)responseMap.get('message');
                boolean IsSucces = (boolean)responseMap.get('isSuccess');
                Integer codeStatus= (Integer)responseMap.get('statusCode');
                system.debug(message + IsSucces +codeStatus);
                Object dataobj = (Object)responseMap.get('data');
                system.debug(dataobj);
                string GroupId;
                if(dataobj != null)
                {
                    map<string,Object> groupMap = (map<string,Object>)dataobj;
                     GroupId = (string)GroupMap.get('groupId');
                    system.debug(GroupId);
                }
                else
                {
                     GroupId = grpId;
                }
               
                
                Log__c log = new Log__c();
                log.IsSuccess__c = IsSucces;
                log.Message__c = message;
                log.StatusCode__c = codeStatus;
                log.SPGroupID__c = GroupId;
                log.JSONResponse__c = responseBody;
                logList.add(log);         
            }
            else{
                
                Log__c log = new Log__c();
             
                log.Message__c = statusMessage;
                log.StatusCode__c = statusCode;
                log.SPGroupID__c = grpId;
                logList.add(log);
                
            }
        } catch (Exception e) {
            // handle exception here
            system.debug('Exception message: ' + e.getMessage());
          
        }
        
        if(logList.size()>0){
            
            insert logList;
        }
        
    }
    
    public static void addCustomlogAccountNameChange(string responseBody, Integer statusCode, String statusMessage,String grpId){
        List<Log__c> logList=new list<Log__c>();
        
        try {
            if(statusCode == 200 && String.isNotBlank(responseBody)){
                
                Object resObj = JSON.deserializeUntyped(responseBody);
                Map<string, Object> responseMap = (Map<string, Object>)resObj;
                system.debug(responseMap);
                String message = (String)responseMap.get('message');
                boolean IsSucces = (boolean)responseMap.get('isSuccess');
                Integer codeStatus= (Integer)responseMap.get('statusCode');
                system.debug(message + IsSucces +codeStatus);
                Object dataobj = (Object)responseMap.get('data');
                system.debug(dataobj);
                map<string,Object> groupMap = (map<string,Object>)dataobj;
                string GroupId = (string)GroupMap.get('groupId');
                system.debug('**GroupId-->'+GroupId);
                
                
                Log__c log = new Log__c();
                log.IsSuccess__c = IsSucces;
                log.Message__c = message;
                log.StatusCode__c = codeStatus;
                log.SPGroupID__c = GroupId;
                log.JSONResponse__c = responseBody;
                logList.add(log);         
            }
            else{
                system.debug('Log ELSE');
                Log__c log = new Log__c();
                log.Message__c = statusMessage;
                log.StatusCode__c = statusCode;
                log.SPGroupID__c =  grpId;
                logList.add(log);
                system.debug('**logList->'+logList);
            }
        } catch (Exception e) {
            // handle exception here
            system.debug('Exception message: ' + e.getMessage());
          
        }
        
        if(logList.size()>0){
            insert logList;
        }
        
    }
}