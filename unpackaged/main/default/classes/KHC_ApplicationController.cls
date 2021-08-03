/**
 * Created by vupneja on 3/1/2021.
 */

public with sharing class KHC_ApplicationController {

    private static ApplicationEnrollmentReqSelector applicationEnrollmentReqSelector = new ApplicationEnrollmentReqSelector();

    @AuraEnabled
    // To fetch the Application records.
    public static List<Application__c> getApplications(){
        User currUser = getLoggedInUserDetails();
        if( currUser != null ){
            return applicationEnrollmentReqSelector.selectApplicationEnrollmentReq( currUser.Account__c);
        }
        return null;
    }

    @AuraEnabled
    //Method to get logged in user
    public static User getLoggedInUserDetails(){
        List<User> loggedInUsers = [SELECT Id,
                                    Account__c
                                    FROM User
                                    WHERE Id = :UserInfo.getUSerId()];
        if( loggedInUsers != null && !loggedInUsers.isEmpty() ){
            return loggedInUsers[0];
        }
        return null;
    }

    @AuraEnabled
    //Method to update Application Status = Canceled
    public static Boolean withdrawApplication(Id enrollmentId){

        List<Application__c> Enrollment = [SELECT Id,
                                            Application_Status__c
                                            FROM Application__c
                                            WHERE Id = :enrollmentID];

            if( Enrollment.size() > 0 ){
                Enrollment[0].Application_Status__c = 'Canceled';
                update Enrollment;
                return true;
        }
        return false;
    }

    @AuraEnabled
    //Method to get logged in Patient Details
    public static Account getPatientDetails(Id accId){

        List<Account> patientDetails = [SELECT
                                        PersonEmail
                                        FROM Account
                                        WHERE Id = :accId];
            if( patientDetails != null && !patientDetails.isEmpty() ){
                return patientDetails[0];
        }
        return null;
    }

    @AuraEnabled
    //Method to get RecordType Id
    public static String getPatientNavigationRecordTypeID(){
        Id recordTypeId =  Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Patient_Navigation').getRecordTypeId();
        return String.valueof(recordTypeId);
    }
}