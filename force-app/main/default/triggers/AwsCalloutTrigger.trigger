/***************************************************************************
*Created by: Minal Patil
*Description:  Trigger to invoke AwsUtilityQueueable which processes callout
***************************************************************************/

trigger AwsCalloutTrigger on Account (after update) {
    
    if (!AwsTriggerHelper.isExecuting) {

        AwsTriggerHelper.isExecuting = true;
        
        AwsCalloutTriggerHandler.handleTrigger(Trigger.new);        
    }
    
}