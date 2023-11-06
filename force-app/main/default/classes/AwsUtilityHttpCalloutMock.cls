/***************************************************************************
*Created by: Minal Patil
*Description: Mock response class to simulate the HTTP callout.
***************************************************************************/

public class AwsUtilityHttpCalloutMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock response with a success status code 
        HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('Response body here');
            return res;
    }
}