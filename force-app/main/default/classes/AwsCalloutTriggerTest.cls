/***************************************************************************
*Created by: Minal Patil
*Description: Test class for AwsCalloutTrigger.
***************************************************************************/

@isTest
public class AwsCalloutTriggerTest {
    @isTest
    static void testAwsCalloutTrigger() {
        // Create a test account
        Account testAccount = new Account(
            Name = 'Test Account',
            IATI_Organisation_XML_Link_S3__c = 'https://example.com/org.xml',
            IATI_Activity_XML_Link_S3__c = 'https://example.com/activity.xml'
        );
        insert testAccount;

        // Create a new test Account with IATI fields blank
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert testAccount2;

        // Modify the account to trigger the update
        testAccount.IATI_Organisation_XML_Link_S3__c = 'https://example.com/neworg.xml';
        update testAccount;

        // Enqueue the queueable job
        AwsUtilityQueueable queueableJob = new AwsUtilityQueueable(
            'YourKey', 'YourSecret', 'YourBucket', 'YourMethod', 'YourHost', testAccount.Id
        );
        System.enqueueJob(queueableJob);

        // Query the queueable job
        System.assertEquals(1, [SELECT Id FROM AsyncApexJob WHERE JobType = 'Queueable' LIMIT 1].size(),
            'Queueable job not enqueued');
    }
}