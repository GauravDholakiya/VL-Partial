/**
 * @author Jozef 
 * @date 22.3.2021.
 * @description //TODO
 */

public with sharing abstract class AuraController {

    public static void throwException(String methodName, Exception ex){
        System.debug(ex.getStackTraceString());
        System.debug(ex);
        throw new AuraHandledException(methodName +  ' : ' + ex.getMessage());
    }

}