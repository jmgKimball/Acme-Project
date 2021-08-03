/* * Controller class for My Contacts Component
 *
 * @author Nitin Chandwani, Traction on Demand
 * @date 2021-02-11
 */
 public with sharing class KHC_PatientContactsController {
    private final static Id supporterCaregiverRecordTypeId = Schema.SObjectType.Patient_Contact__c.getRecordTypeInfosByName().get('Supporter/Caregiver').getRecordTypeId();
    private static final KHC_FamilyMedicalHealthSelector patientContactSelector = new KHC_FamilyMedicalHealthSelector();

    @AuraEnabled
    public static List<Patient_Contact__c> getSupporters(){
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        if( currUser != null ){
            return patientContactSelector.selectByRelatedPatientAndRelationships( currUser.AccountId, supporterCaregiverRecordTypeId );
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static User getLoggedInUser(){
        return MyKomenHealthUtility.getLoggedInUserDetails();
    }
}