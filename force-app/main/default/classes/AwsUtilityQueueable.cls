/***************************************************************************
*Created by: Minal Patil
*Description:  Queueable class for handling AwsUtility with API callout async.
***************************************************************************/
public class AwsUtilityQueueable implements Queueable, Database.AllowsCallouts{
    
    public string awsKey;
    public string awsSecret;
    public string bucketName;
    public string methodName;
    public string hostName;
    public Id recordId;
    
    public AwsUtilityQueueable(string key, string sec, string bkt, string method, string host, Id recId) {
        awsKey = key;
        awsSecret = sec;
        bucketName = bkt;
        methodName = method;
        hostName = host;
        recordId = recId;
    }
    public void execute(QueueableContext context) {
        AwsUtility awsUtility = new AwsUtility(awsKey, awsSecret, bucketName, methodName, hostName);
        awsUtility.UploadDocuments(recordId);
    }

}