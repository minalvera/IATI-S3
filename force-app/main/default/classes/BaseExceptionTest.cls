/***************************************************************************
*Created by: Minal Patil
*Description: Test class for BaseException Class.
***************************************************************************/
@isTest
public class BaseExceptionTest {
    @isTest
    static void testBaseException() {
        // This is a simple test method to include the custom exception class in test coverage.
        // calling the constructor of the custom exception class to make sure it is covered.
        BaseException customException = new BaseException('Custom Exception Message');
        System.assertEquals('Custom Exception Message', customException.getMessage());
    }
}