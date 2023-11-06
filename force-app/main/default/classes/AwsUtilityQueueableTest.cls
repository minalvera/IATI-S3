/***************************************************************************
*Created by: Minal Patil
*Description: Test class for AwsUtilityQueueable class.
***************************************************************************/
@isTest
public class AwsUtilityQueueableTest {
    @isTest
    static void testAwsUtilityQueueable() {
        // Create a mock response for the HTTP callout
        HttpCalloutMock mock = new AwsUtilityHttpCalloutMock();

        // Associate the mock with a test callout
        Test.setMock(HttpCalloutMock.class, mock);

        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Define AWS parameters
        String awsKey = 'yourAwsKey';
        String awsSecret = 'yourAwsSecret';
        String bucketName = 'yourBucketName';
        String methodName = 'POST';
        String hostName = 'yourHostName';

        // Enqueue the queueable job
        Test.startTest();
        System.enqueueJob(new AwsUtilityQueueable(awsKey, awsSecret, bucketName, methodName, hostName, testAccount.Id));
        Test.stopTest();

        // Verify that the queueable job has run
        System.assertEquals(1, [SELECT count() FROM AsyncApexJob WHERE JobType = 'Queueable']);
    }
}