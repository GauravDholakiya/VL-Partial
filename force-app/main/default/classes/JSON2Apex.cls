/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         JSON2Apex.apxc 
Description:  JSON Parser form sharepoint Status Code 404.

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
July 2019        0.1         Deepak                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */
public class JSON2Apex {
    
    public Error error;
    
    public class Error {
        public String code;
        public String message;
        public InnerError innerError;
        public Error(JSONParser parser){
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'code') {
                            code = parser.getText();
                        }
                        else if (text == 'message') {
                            message = parser.getText();
                        }
                        else if(text == 'innerError'){
                            innerError = new innerError(parser);
                        }
                        else {
                            System.debug(LoggingLevel.WARN, 'Error consuming unrecognized property: '+text);
                        }
                    }
                }
            }
        }
    }
    
    public class InnerError {
        public String request_id;
        public String eventdate;
        public InnerError(JSONParser parser){
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'request-id') {
                            request_id = parser.getText();
                        }
                        else if (text == 'date') {
                            eventdate = parser.getText();
                        }
                        else {
                            System.debug(LoggingLevel.WARN, 'Error consuming unrecognized property: '+text);
                        }
                    }
                }
            }
        }
    }
    
    
    
    public static JSON2Apex parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new JSON2Apex(parser);
    }
    
    public JSON2Apex(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'Error') {
                         Error = new Error(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                    }
                }
            }
        }
        
    }
}