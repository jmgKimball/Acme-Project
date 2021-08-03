public with sharing class HealthProfile {
    public List<Patient_Contact__c> FamilyMembers;
    public List<HealthCloudGA__EhrCondition__c> Conditions;
    public List<HealthCloudGA__EhrMedicationStatement__c> medications;
}