/***************************************************************************
*Created by: Minal Patil
*Description: Test class for AwsCalloutTriggerHandler class.
***************************************************************************/
@isTest
public class AwsCalloutTriggerHandlerTest {
    
    @isTest
    static void testHandleTriggerWithBlankFields() {
        // Create an Account with blank fields
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        List<Account> newAccList = new List<Account>();
        List<Account> Accounts = [SELECT Id, IATI_Organisation_XML_Link_S3__c, IATI_Activity_XML_Link_S3__c FROM Account WHERE Id = :acc.Id];
        for(Account accUpdate: Accounts){
            acc.S3_File_Last_Modified_Timestamp__c = 'test';
            newAccList.add(accUpdate);
        }
        update newAccList;
        
        // Call the handleTrigger method
        //List<Account> newAccounts = new List<Account>{newAccList};
            AwsCalloutTriggerHandler.handleTrigger(newAccList);
        
        // Add assertions to check the expected behavior
        // Example: Assert that the recordIdsToProcess set should be empty
        System.assertEquals(0, AwsCalloutTriggerHandler.recordIdsToProcess.size());
    }
    
    @isTest
    static void testHandleTriggerWithNonBlankFields() {
        // Create an Account with non-blank fields
        Account acc = new Account(
            Name = 'Test Account',
            IATI_Organisation_XML_Link_S3__c = 'https://example.com/org.xml',
            IATI_Activity_XML_Link_S3__c = 'https://example.com/activity.xml'
        );
        insert acc;
        List<Account> newAccList = new List<Account>();
        List<Account> Accounts = [SELECT Id, IATI_Organisation_XML_Link_S3__c, IATI_Activity_XML_Link_S3__c FROM Account WHERE Id = :acc.Id];
        for(Account accUpdate: Accounts){
            acc.S3_File_Last_Modified_Timestamp__c = 'test';
            newAccList.add(accUpdate);
        }
        update newAccList;
                
        // Call the handleTrigger method
        List<Account> newAccounts = new List<Account>{acc};
            AwsCalloutTriggerHandler.handleTrigger(newAccList);
        
        System.assertEquals(0, AwsCalloutTriggerHandler.recordIdsToProcess.size());
    }
    
    @isTest
    static void testHandleTriggerWithRelatedXmlContentVersions() {
        // Create an Account with blank fields and related XML ContentVersions
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create related ContentDocumentLink and ContentVersion records with XML extensions
         ContentVersion content = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.xml',
            VersionData = Blob.valueOf('Test document content')
            
        );
        insert content;

        // Link the ContentVersion record to the Account using ContentDocumentLink
        ContentDocumentLink contentLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id].ContentDocumentId,
            LinkedEntityId = acc.Id,
            ShareType = 'I'
        );
        insert contentLink;
        
        List<Account> newAccList = new List<Account>();
        List<Account> Accounts = [SELECT Id, IATI_Organisation_XML_Link_S3__c, IATI_Activity_XML_Link_S3__c FROM Account WHERE Id = :acc.Id];
        for(Account accUpdate: Accounts){
            acc.S3_File_Last_Modified_Timestamp__c = 'test';
            newAccList.add(accUpdate);
        }
        update newAccList;
        
        // Call the handleTrigger method
            AwsCalloutTriggerHandler.handleTrigger(newAccList);
    }
    
    @isTest
    static void testProcessRecords() {
        // Create test data or use existing data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        // Create related ContentDocumentLink and ContentVersion records with XML extensions
         ContentVersion content = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.xml',
            VersionData = Blob.valueOf('Test document content')
            
        );
        insert content;

        // Link the ContentVersion record to the Account using ContentDocumentLink
        ContentDocumentLink contentLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id].ContentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'I'
        );
        insert contentLink;
         List<Account> newAccList = new List<Account>();
        List<Account> Accounts = [SELECT Id, IATI_Organisation_XML_Link_S3__c, IATI_Activity_XML_Link_S3__c FROM Account WHERE Id = :testAccount.Id];
        for(Account accUpdate: Accounts){
            accUpdate.S3_File_Last_Modified_Timestamp__c = 'test';
            newAccList.add(accUpdate);
        }
        update newAccList;

        // Set up the expected values from Custom Labels
        System.runAs(new User(Id = UserInfo.getUserId())) {
            String awsKey = 'YourS3Key';
            String awsSecret = 'YourS3Secret';
          String bucketName = 'YourS3Bucket';
           String methodName = 'PUT';
             String hostName = 's3.amazonaws.com';
        }

        // Create a test context to capture enqueued jobs
        Test.setMock(HttpCalloutMock.class, new AwsUtilityHttpCalloutMock());
        
         Test.startTest();
        // Trigger your handler method
        Set<Id> recordIds = new Set<Id>{testAccount.Id};
        AwsCalloutTriggerHandler.processRecords(recordIds);

        Test.stopTest();
    }

}