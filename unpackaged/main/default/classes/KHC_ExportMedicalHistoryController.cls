/**
 * Controller for the Export Medical History VF page
 * Loads patient record (Person Account) and all related medical history records for rendering in VF as a PDF document
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-08-13
 */
public with sharing class KHC_ExportMedicalHistoryController {
    @TestVisible
    private static final String UNABLE_TO_LOAD_ACCOUNT_ERROR_MSG = 'Unable to load account for Id provided';

    public Account patient { get; private set; }
    public List<Patient_Contact__c> familyMedicalHistories { get; private set; }
    public List<Family_Medical_History_Condition__c> familyMedicalHistoryConditions { get; private set; }


    public KHC_ExportMedicalHistoryController(ApexPages.StandardController ctlr) {
        Id accountId = ctlr.getId();

        patient = loadPatient(accountId);
        familyMedicalHistories = loadFamilyMedicalHistory(accountId);
        familyMedicalHistoryConditions = extractConditionsFromFamilyHistories(familyMedicalHistories);

        String filename = generateFilename(patient);
        setFilenameHeader(filename);
    }

    private Account loadPatient(Id accountId) {
        List<Account> result = selectAccountById(accountId);

        if (result.isEmpty()) {
            throw new MedicalHistoryControllerException(UNABLE_TO_LOAD_ACCOUNT_ERROR_MSG);
        }

        return result[0];
    }

    private List<Patient_Contact__c> loadFamilyMedicalHistory(Id accountId) {
        return selectFamilyMedicalHistoryByAccountIdWithConditions(accountId);
    }

    private List<Account> selectAccountById(Id accountId) {
        return [
                SELECT Name, 
                FirstName, 
                LastName, 
                Breast_Cancer_Status__c, 
                PersonEmail, 
                Phone, 
                Gender__pc,
                HealthCloudGA__BirthDate__pc,
                Blood_Type__pc,
                Height_ft__pc,
                Height_in__pc,
                Weight__c,
                Ethnicity__pc
                FROM Account
                WHERE Id = :accountId
        ];
    }

    private static List<Patient_Contact__c> selectFamilyMedicalHistoryByAccountIdWithConditions(Id accountId) {
        return [
                SELECT Relationship__c, Related_through_family_member__c, Family_Member_Name__c, Gender__c,
                        Was_this_person_born_a_twin_multiple__c, Birth_Year__c, Adopted__c, Race_Picklist__c, Ethnicity__c,
                        Are_They_Ashkenazi_Jewish__c, Is_this_person_living__c, Estimated_Age_at_Death__c,
                        Cause_of_Death__c,
                (
                        SELECT Condition_Category__c, Condition_Sub_Category__c, Family_Medical_History__c,
                                Family_Medical_History__r.Family_Member_Name__c, Age_at_diagnosis__c
                        FROM Family_Medical_History_Conditions__r
                )
                FROM Patient_Contact__c
                WHERE Patient__c = :accountId
        ];
    }

    private List<Family_Medical_History_Condition__c> extractConditionsFromFamilyHistories(
            List<Patient_Contact__c> histories) {

        List<Family_Medical_History_Condition__c> result = new List<Family_Medical_History_Condition__c>();

        for ( Patient_Contact__c history : histories) {
            if (history.Family_Medical_History_Conditions__r.size() > 0) {
                result.addAll(history.Family_Medical_History_Conditions__r);
            }
        }

        return result;
    }
    private String generateFilename(Account patient) {
        return String.join(new String[]{
                patient.LastName, patient.FirstName, Label.Export_Medical_History_Main_Heading
        }, '_');
    }

    private void setFilenameHeader(String filename) {
        ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + filename + '.pdf');
    }

    @TestVisible
    private class MedicalHistoryControllerException extends Exception {
    }
}