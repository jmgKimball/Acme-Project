/**
 * Selector for EhrMedicationStatement records
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-09-04
 */
public with sharing class EhrMedicationStatementSelector {
    public List<HealthCloudGA__EhrMedicationStatement__c> selectByPersonAccount( Id accountId ){
        return [
                SELECT Id, HealthCloudGA__Account__c, Name, 
                Medication__c, Medication__r.Name, Notes__c 
                FROM HealthCloudGA__EhrMedicationStatement__c
                WHERE Medication__c != NULL AND HealthCloudGA__Account__c =: accountId
            ];
    }
}