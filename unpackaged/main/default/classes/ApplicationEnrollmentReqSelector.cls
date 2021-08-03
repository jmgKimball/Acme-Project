/**
 * Created by vupneja on 2/17/2021.
 */

public with sharing class ApplicationEnrollmentReqSelector {

    public List<Application__c> selectApplicationEnrollmentReq( Id accId ){
        if( String.isNotBlank( accId ) ){
             return [select Patient__c,
                        Patient__r.Name,
                        Patient_Email_Address__c,
                        Application_Status__c,
                        Applicant_Email__c,
                        Patient_State__c ,
                        Name, Id,
                        Abnormal_Screening_Result__c,
                        In_Active_Treatment__c,
                        Application_Source__c,
                        Status_Change_Date__c
                        from Application__c
                        WHERE Patient__c =  :accId
                        ];
        }
        return null;
    }
}