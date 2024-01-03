/**
 * @author Jozef 
 * @date 6.9.2019.
 * @description //TODO
 */

@IsTest
private class PickListControllerTest {
    @IsTest
    static void getPickListValuesIntoListTest() {
        String objectType = 'APTTaskTemplate__c';
        String selectedField = 'Assigned_Role__c';
        PickListController.getPickListValuesIntoList(objectType, selectedField);
    }
}