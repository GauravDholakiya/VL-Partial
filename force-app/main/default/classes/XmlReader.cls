/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Name:         XmlReader.cls 
Description:  Read xml and return all the required columns with Choice values.
Test class:   SharepointWidgetController_Test.cls 

Date             Version     Author                  Tag     Summary of Changes 
-----------      -------     -----------------       ---     ------------------------------------------------------------------------
02 Oct 2019        1.0        Deepak                None    Initial draft
-------------------------------------------------------------------------------------------------------------------------------------------------------- */


public class XmlReader{
    
    public static  List<Map<string,object>> ExtractRequiredColumDetails(string xml){
        
        List<Map<string,object>> RequiredColumDetails = new List<Map<string,object>>();
        Map<string,object> columnDetails;
        List<string> choicesList;
       
        DOM.Document doc = new DOM.Document();
        doc.load(xml);
        //Retrieve the root element for this document.
        Dom.XMLNode rootelement = doc.getRootElement();
        Dom.XMLNode fields = rootelement.getChildElement('Fields', null);
        
        // Alternatively, loop through the child elements.
        // This prints out all the elements of the address
        for(Dom.XMLNode field : fields.getChildElements()) {
            columnDetails =  new Map<string,object>();
            if(field.getAttribute('Required',null)=='true')
            {
                if(field.getAttribute('Type',null)=='Choice'){
                    choicesList = new List<string>();
                    for(Dom.XMLNode Choices: field.getChildElements()){
                        for(Dom.XMLNode Choice: Choices.getChildElements()){
                            choicesList.add(Choice.getText());
                        }
                    }
                    columnDetails.put('Choices',choicesList);
                }
                if(field.getAttribute('DisplayName',null)!='Name'){
                    columnDetails.put('ColumnName',field.getAttribute('DisplayName',null));
                    columnDetails.put('ColumnType',field.getAttribute('Type',null));
                    RequiredColumDetails.add(columnDetails);
                }
            }
        }
        return RequiredColumDetails;
    }
}