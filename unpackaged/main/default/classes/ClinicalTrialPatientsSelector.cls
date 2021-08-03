/**
 * Selector for Clinical Trial Patient records
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-28
 */
public inherited sharing class ClinicalTrialPatientsSelector {

    public List<Clinical_Trial_Patient__c> selectByTrialIdAndUserId(Set<Id> trialIds, Set<Id> userIds) {
        return [
                SELECT Clinical_Trial__c, OwnerId
                FROM Clinical_Trial_Patient__c
                WHERE Clinical_Trial__c IN :trialIds
                AND OwnerId IN :userIds
        ];
    }
}