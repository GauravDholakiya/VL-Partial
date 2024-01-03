@isTest
public class HttpMockFactory implements HttpCalloutMock{

    public Integer code;
    public String status;
    public String body;
    
    Public HttpMockFactory(Integer code, String status, String body){
        this.code=code;
        this.status=status;
        this.body=body;
    }
    
    Public HTTPResponse respond(HTTPRequest req){
        System.debug(req);
        HttpResponse res=new httpResponse();
        if(req.getEndpoint().endsWith('refresh-token')){
            res.setBody('{"accessToken": "testAccessToken1","refreshToken": "testRefreshToken1","validUntil": "2023-09-20T07:16:01Z"}');
        }
        else if(req.getEndpoint().endsWith('/fields')){
            System.debug('Testing response');
            res.setBody('{"uuid":"e441461b-b6be-4cce-8279-ff962097c446","field":"Other","value":"test*test","createdAt":"2023-09-20","updatedAt":"2023-09-20"}');
           
        }
        else{
           res.setBody(this.body); 
        }
        
        res.setStatus(this.status);
        res.setStatusCode(this.code);
        return res;
    }
}