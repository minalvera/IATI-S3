/***************************************************************************
*Created by: Minal Patil
*Description: Utility to make rest callout to AWS to store files in S3 bucket.
***************************************************************************/
public class AwsUtility { 
    // Authentication parameters
    public string awsKey; 
    public string awsSecret; 
    public string bucketName; 
    public string methodName; 
    public string hostName;
    
    // Initialize authentication parameters in the constructor
    public AwsUtility(string key, string sec, string bkt, string method, string host) {
        awsKey = key;
        awsSecret = sec;
        bucketName = bkt;
        methodName = method; 
        hostName = host;
    }
    
    public string contentType(string fileType) {
        switch on fileType.toLowerCase() {
            when 'csv' {
                return 'application/vnd.ms-excel';
            }
            when 'docx' {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'wav' {
                return 'audio/wav';
            }
            when 'png' {
                return 'image/png';
            }
            when 'xml' {
                return 'application/xml';
            }
            when else {
                return 'image/jpeg';
            }
        }
    }
    
    public string CreateAuthHeader(String contentType, String filename, String formattedDateString, string fileExtension) {
        string auth;
        String orgId = UserInfo.getOrganizationId();
        String folderName = 'VeraAmpImpact-' + orgId; // Folder naming format
        String newFilename = filename.replaceAll(' ', '_');
        String stringToSign = this.methodName + '\n\n' + contentType + '\n' + formattedDateString + '\n/' + this.bucketName + '/' + folderName + '/' + newFilename.toLowerCase() + '.' + fileExtension.toLowerCase();
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign), blob.valueof(this.awsSecret));
        String sig = EncodingUtil.base64Encode(mac);
        auth = 'AWS' + ' ' + this.awsKey + ':' + sig;
        return auth;
    }
    
    public void UploadDocuments(string recordId) {
        if (string.isBlank(this.awsSecret) || string.isBlank(this.awsKey) || string.isBlank(this.bucketName) || string.isBlank(this.hostName)) {
            throw new BaseException('Set AWS credentials');
        }
        
        List<ContentDocumentLink> contentLinkList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        Set<Id> conDocIdSet = new Set<Id>();
        Map<String, String> fileUrlMap = new Map<String, String>();
        Map<Id, Account> accountsToUpdateMap = new Map<Id, Account>();
        DateTime uploadTimestamp;
        for (ContentDocumentLink link : contentLinkList) {
            conDocIdSet.add(link.ContentDocumentId);
        }
        
        
        String excludeCondition = '%xlsx';
        List<ContentVersion> cVersions = [
            SELECT VersionData, Title, ContentDocumentId, fileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :conDocIdSet
            AND fileExtension = 'xml'
            AND IsLatest = TRUE
        ];
                
        List<Map<String, String>> successfulFileDataList = new List<Map<String, String>>();
 
        for (ContentVersion attach : cVersions) {
            Map<String, String> attachmentData = new Map<String, String>();
            String attachmentBody = Encodingutil.base64Encode(attach.VersionData);
            String fileName = attach.Title.replaceAll(' ', '_');
            String contentType = contentType(attach.fileExtension);
            String orgId = UserInfo.getOrganizationId();
            String folderName = 'VeraAmpImpact-' + orgId;
            uploadTimestamp = DateTime.now();
            //create file url structure for s3 bucket
            String fileUrl = 'https://' + this.bucketName + '.' + this.hostName + '/' + folderName + '/' + fileName.toLowerCase() + '.' + attach.fileExtension.toLowerCase();
                        
            HttpRequest req = new HttpRequest();
            req.setMethod(this.methodName);
            req.setEndpoint(fileUrl);
            req.setHeader('Host', this.bucketName + '.' + this.hostName);
            req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
            req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-Type', contentType);
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('Date', uploadTimestamp.formatGMT('EEE, dd MMM yyyy HH:mm:ss z'));
            req.setHeader('ACL', 'public-read');
            req.setBodyAsBlob(EncodingUtil.base64Decode(attachmentBody));
            req.setHeader('Authorization', CreateAuthHeader(contentType, fileName, req.getHeader('Date'), attach.fileExtension));
            
            HttpResponse res = new Http().send(req); // send callout
            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                fileUrlMap.put(fileName, fileUrl);
                successfulFileDataList.add(attachmentData);
                
            } else {
                System.debug('Callout failed with status code: ' + res.getStatusCode());
            }
        }
        
        // Update the records outside for loop 
        for (ContentVersion attach : cVersions) {
            String fileName1 = attach.Title.replaceAll(' ', '_');
            String fileUrl1 = fileUrlMap.get(fileName1);
            
            if (fileUrl1 != null) {
                Id accountId = recordId; 
                Account accToUpdate = accountsToUpdateMap.get(accountId);
                
                if (accToUpdate == null) {
                    accToUpdate = new Account(Id = accountId);
                    accountsToUpdateMap.put(accountId, accToUpdate);
                }
                
               accToUpdate.S3_File_Last_Modified_Timestamp__c = string.valueOf(uploadTimestamp);
                if (!fileUrl1.contains('activity')) {
                    accToUpdate.IATI_Organisation_XML_Link_S3__c = fileUrl1;
                } else {
                    accToUpdate.IATI_Activity_XML_Link_S3__c = fileUrl1;
                }
            }
        }
        if (!accountsToUpdateMap.isEmpty()) {
            update accountsToUpdateMap.values();
        }
    }
}