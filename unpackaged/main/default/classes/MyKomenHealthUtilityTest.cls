@isTest
public with sharing class MyKomenHealthUtilityTest {
    @isTest
    public static void getCarePlan(){
        String carePlan = MyKomenHealthUtility.getCarePlanId();
        System.assertEquals( null, carePlan, 'Internal user will have null.' );
    }
    @isTest
    public static void getLoggedInUserDetails(){
        User loggedInUser = MyKomenHealthUtility.getLoggedInUserDetails();
        System.assertEquals( UserInfo.getUserId(), loggedInUser.Id, 'Logged In user must be same.' );
    }
    
}