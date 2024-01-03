/**
 * @author Jozef 
 * @date 22.3.2021.
 * @description //TODO
 */

@IsTest
private class AuraControllerTest {

    @IsTest
    static void allFunctionTest() {
        try{
            Integer i = 1/0;
        }catch(Exception ex) {
            try {
                AuraController.throwException('EX', ex);
            }catch(System.AuraHandledException auex){

            }
        }
    }

}