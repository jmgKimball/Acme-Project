/**
 * Utility class used to hold methods for community
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-09-04
 */
public with sharing class MyKomenHealthUtility {
    
    //Method to get care plan Id
    public static Id getCarePlanId(){
        List<User> loggedInUsers = [SELECT Id, Contact.AccountId, Contact.Account.HealthCloudGA__CarePlan__c 
                                    FROM User 
                                    WHERE Id = :UserInfo.getUSerId()];
        if( loggedInUsers != null && !loggedInUsers.isEmpty() ){
            return loggedInUsers[0].Contact.Account.HealthCloudGA__CarePlan__c;
        }
        return null;
    }

    //Method to get logged in user 
    public static User getLoggedInUserDetails(){
        List<User> loggedInUsers = [SELECT Id, Contact.Account.HealthCloudGA__CarePlan__c,
                                    AccountId, ContactId
                                    FROM User 
                                    WHERE Id = :UserInfo.getUSerId()];
        if( loggedInUsers != null && !loggedInUsers.isEmpty() ){
            return loggedInUsers[0];
        }
        return null;
    }

    public static Boolean isGuestUser(){
        return UserInfo.getUserType() == 'Guest';
    }

}