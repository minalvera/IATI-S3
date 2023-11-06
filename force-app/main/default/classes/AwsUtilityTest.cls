/***************************************************************************
*Created by: Minal Patil
*Description: Test class for AwsUtility class.
***************************************************************************/
@isTest
public class AwsUtilityTest {
    @isTest
    static void testUploadDocuments() {
        // Create test data for Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create test data for ContentVersion
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

        // Instantiate AwsUtility with mock data
        AwsUtility awsUtil = new AwsUtility('TestKey', 'TestSecret', 'TestBucket', 'TestMethod', 'TestHost');

        // Set up the mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new AwsUtilityHttpCalloutMock());

        Test.startTest();

        // Call the UploadDocuments method with the Account Id
        awsUtil.UploadDocuments(acc.Id);

        Test.stopTest(); 
    }

  
}