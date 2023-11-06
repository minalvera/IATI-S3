/***************************************************************************
*Created by: Minal Patil
*Description: AwsCalloutTrigger handler.
***************************************************************************/
public with sharing class AwsCalloutTriggerHandler {
    public static Set<Id> recordIdsToProcess = new Set<Id>();

    public static void handleTrigger(List<Account> newAccounts) {
        System.debug('inside handleTrigger');
        //Set<Id> recordIdsToProcess = new Set<Id>();
            
        for (Account record : newAccounts) {

            // Check if IATI_Organisation_XML_Link_S3__c and IATI_Activity_XML_Link_S3__c are blank
            Boolean isFieldBlank = String.isBlank(record.IATI_Organisation_XML_Link_S3__c) || String.isBlank(record.IATI_Activity_XML_Link_S3__c);

            if ((isFieldBlank && hasRelatedXmlContentVersions(record)) ) {
                recordIdsToProcess.add(record.Id);
            }
        }
			 
        if (!recordIdsToProcess.isEmpty()) {
            processRecords(recordIdsToProcess);
          
        }
    }
    
    public static Boolean hasRelatedXmlContentVersions(Account record) {
        Set<String> prefixesToCheck = new Set<String>{'ActivityStandard', 'OrganisationStandard'};
            
            List<ContentDocumentLink> ContentLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :record.Id
            ];
        
        Set<Id> ContentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : ContentLinks) {
            ContentDocumentIds.add(link.ContentDocumentId);
        }
        
        // Query ContentVersions related to the ContentDocumentIds
        List<ContentVersion> ContentVersions = [
            SELECT Id, Title, ContentDocumentId, fileExtension, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN :ContentDocumentIds
            AND IsLatest = TRUE
            AND fileExtension = 'xml'
        ];
        
        system.debug('ContentVersions>> ' +ContentVersions);
        
        if (!ContentVersions.isEmpty()) {
            for (ContentVersion version : ContentVersions) { 
                if (version.Title != null) {
                    for (String prefix : prefixesToCheck) {
                        if (version.Title.startsWith(prefix)) {
                            system.debug('true');
                            return true; // Found at least one related XML ContentVersion
                        }
                    }
                }
            }
        }
        system.debug('false');
        return false; // NO related XML ContentVersion found
        
    }
    
    public static void processRecords(Set<Id> recordIds) {
        String awsKey = System.Label.S3_key;
        String awsSecret = System.Label.S3_Secret;
        String bucketName = System.Label.S3_bucket;
        String methodName = System.Label.S3_method;
        String hostName = System.Label.S3_Host;

        for (Id recordId : recordIds) {
            System.enqueueJob(new AwsUtilityQueueable(awsKey, awsSecret, bucketName, methodName, hostName, recordId));
        }
        AwsTriggerHelper.isExecuting = false;
    }
    
}