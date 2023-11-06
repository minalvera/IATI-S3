/***************************************************************************
*Created by: Minal Patil
*Description: Test class for AwsTriggerHelper Class.
***************************************************************************/
@isTest
public class AwsTriggerHelperTest {

    @isTest
    static void testAwsTriggerHelper() {
        // Set the isExecuting flag to false and ensure it's initially false
        System.assertEquals(false, AwsTriggerHelper.isExecuting, 'isExecuting should be false initially');

        // Set the isExecuting flag to true and ensure it's set correctly
        AwsTriggerHelper.isExecuting = true;
        System.assertEquals(true, AwsTriggerHelper.isExecuting, 'isExecuting should be true after setting');

        // Set the isExecuting flag back to false and ensure it's set correctly
        AwsTriggerHelper.isExecuting = false;
        System.assertEquals(false, AwsTriggerHelper.isExecuting, 'isExecuting should be false after resetting');
    }
}