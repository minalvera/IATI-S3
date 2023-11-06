/***************************************************************************
*Author: Minal Patil
*Date: October 26, 2023
*Description:  Controller for invoking AwsUtility with API callout.
***************************************************************************/
public class S3Controller {
    public static void UploadDocToS3Server(string recordId)
    {
        UploadDocument(recordId);
    }
    
    public static void UploadDocument(string recordId)
    {
        
        String key = System.Label.S3_key;  
        String secret = System.Label.S3_Secret;
        String bucket = System.Label.S3_bucket; 
        String host = System.Label.S3_Host;
        String method = System.Label.S3_method;
        AwsUtility service = new AwsUtility(key,secret,bucket,method,host);
		    service.UploadDocuments(recordId);
    }
}