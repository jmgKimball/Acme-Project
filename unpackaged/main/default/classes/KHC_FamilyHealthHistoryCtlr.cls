/**
 * Server-side controller for Family Health History LWC
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-17
 */
public with sharing class KHC_FamilyHealthHistoryCtlr {
    private static KHC_FamilyMedicalHealthSelector healthSelector = new KHC_FamilyMedicalHealthSelector();

    @AuraEnabled
    public static List<Patient_Contact__c> loadHistory(Id patientId) {
        return healthSelector.selectByPersonAccountIdWithConditions(patientId);
    }

    @AuraEnabled
    public static void updateConditions(List<Family_Medical_History_Condition__c> conditionsToInsert,
            List<Family_Medical_History_Condition__c> conditionsToDelete) {

        insert conditionsToInsert;
        delete conditionsToDelete;
    }
}