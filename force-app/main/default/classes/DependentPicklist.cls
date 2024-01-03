/**
 * @author Jozef 
 * @date 11.9.2019.
 * @description //TODO
 */

public with sharing class DependentPicklist {

    public static Map<Object,List<String>> getDependentPicklistValues( Schema.sObjectField dependToken )
    {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
                (   control.getType() == Schema.DisplayType.Boolean
                        ?   null
                        :   control.getPicklistValues()
                );

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                    String.valueOf
                            (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                            ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                        (   controlEntries == null
                                ?   (Object) (index == 1)
                                :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                        );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                        ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                        ) continue;
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
            }
        }
        return dependentPicklistValues;
    }

    public static List<String> getDependentPicklistValues( Schema.sObjectField dependToken, String controlValue ){
        List<String> values = new List<String>();
        Map<Object,List<String>> result =
                DependentPicklist.getDependentPicklistValues( dependToken );
        //System.debug(result);
        values = result.get(controlValue);
        return values;
    }

    public static Map<String,String> getPicklistApiMap(SObjectField sObtField) {
        //SObjectField sObtField = Account_Team_And_Authorizations__c.Type__c;
        Map<String,String> pickMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = sObtField.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry v : values) {
            pickMap.put(v.getValue(),v.getLabel());
            //System.debug('Picklist Value Label:' + v.getLabel());
            //System.debug('Picklist API Name:' + v.getValue());
        }
        return pickMap;

    }

    public static Map<String,String> getPicklistValueMap(SObjectField sObtField) {
        Map<String,String> pickMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = sObtField.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry v : values) {
            pickMap.put(v.getLabel(), v.getValue());
        }
        return pickMap;

    }


    /*
    public static Map<Object,List<String>> getDependentPicklistValues( String sObjectName, String fieldName )
    {
        return getDependentPicklistValues(Schema.getGlobalDescribe().get( sObjectName ).
                getDescribe().fields.getMap().get( fieldName ));
    }
    */

}