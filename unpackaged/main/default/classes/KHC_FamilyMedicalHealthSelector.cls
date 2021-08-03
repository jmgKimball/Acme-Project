/**
 * Selector for the Family Medical History object
 * Object renamed to Patient Contact
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-17
 */
public inherited sharing class KHC_FamilyMedicalHealthSelector {

    public static final Id supporterCaregiverRecTypeId = Schema.SObjectType.Patient_Contact__c.getRecordTypeInfosByName().get('Supporter/Caregiver').getRecordTypeId();
    public static final Id familyMedicalHistoryRecTypeId = Schema.SObjectType.Patient_Contact__c.getRecordTypeInfosByName().get('Family Medical History').getRecordTypeId();

    public List<Patient_Contact__c> selectByPersonAccountIdWithConditions(Id personAccountId) {
        return [
                SELECT Name_with_Relationship__c, Relationship__c, Is_this_person_living__c,
                (
                        SELECT Condition_Category__c, Condition_Sub_Category__c, Age_at_diagnosis__c
                        FROM Family_Medical_History_Conditions__r
                )
                FROM Patient_Contact__c
                WHERE Patient__c = :personAccountId 
                AND RecordTypeId =: familyMedicalHistoryRecTypeId 
                ORDER BY CreatedDate
        ];
    }

    public List<Patient_Contact__c> selectByRelatedPatientAndRelationships( Id personAccountId, Id recordTypeId ) {
        return [
                SELECT Id, Name, Patient__c, Patient__r.Name, Relationship__c,
                Family_Member_Name__c, Email__c, Phone__c, 
                Mobile_Phone__c, Emergency_Contact__c, Mailing_Street__c,
                Mailing_City__c, Mailing_State_Province__c, Mailing_Country__c, 
                Mailing_Zip_Postal_Code__c, Description_Notes__c
                FROM Patient_Contact__c
                WHERE Patient__c =:personAccountId 
                AND RecordTypeId =: recordTypeId
                ORDER BY CreatedDate
        ];
    }
}