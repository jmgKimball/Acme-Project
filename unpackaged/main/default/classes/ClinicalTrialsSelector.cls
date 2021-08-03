/**
 * Selector for Clinical Trial records
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-28
 */
public inherited sharing class ClinicalTrialsSelector {

    public List<Clinical_Trial__c> selectAllVisible(Integer recordLimit) {
        return [
                SELECT NCTId__c, Name, Brief_Title__c, Readable_Title__c, Clinical_Trial_Type__c, Phase__c,
                (
                        SELECT Condition_Name__c
                        FROM Clinical_Trial_Conditions__r
                        WHERE Condition__r.Non_MeSH_Condition__c = TRUE
                        ORDER BY Name
                ), (
                        SELECT Id
                        FROM Clinical_Trial_Patients__r
                        WHERE OwnerId = :UserInfo.getUserId()
                )
                FROM Clinical_Trial__c
                WHERE Clinical_Trial_Status__c IN :ClinicalTrials.VISIBLE_STATUSES
                ORDER BY Name
                LIMIT :recordLimit
        ];
    }

    public List<Clinical_Trial__c> selectById(Set<Id> recordIds) {
        return [
                SELECT NCTId__c, Name, Brief_Title__c, Readable_Title__c, Clinical_Trial_Type__c, Phase__c,
                (
                        SELECT Condition_Name__c
                        FROM Clinical_Trial_Conditions__r
                        WHERE Condition__r.Non_MeSH_Condition__c = TRUE
                        ORDER BY Name
                ), (
                        SELECT Id
                        FROM Clinical_Trial_Patients__r
                        WHERE OwnerId = :UserInfo.getUserId()
                )
                FROM Clinical_Trial__c
                WHERE Id IN :recordIds
                ORDER BY Name
        ];
    }

    public List<Clinical_Trial__c> selectByIdWithChildren(Set<Id> recordIds) {
        return [
                SELECT NCTId__c, Name, Brief_Title__c, Readable_Title__c, Clinical_Trial_Type__c, Organization__c,
                        Minimum_Age__c, Maximum_Age__c, Gender__c, Healthy_Volunteers__c, Phase__c,
                        Readable_Brief_Description__c, Clinical_Trial_Description_Brief__c,
                        Readable_Eligibility_Summary__c, Eligibility_Criteria__c,
                (
                        SELECT Condition_Name__c, Condition__r.Description__c
                        FROM Clinical_Trial_Conditions__r
                        WHERE Condition__r.Non_MeSH_Condition__c = TRUE
                        ORDER BY Name
                ), (
                        SELECT Id
                        FROM Clinical_Trial_Patients__r
                        WHERE OwnerId = :UserInfo.getUserId()
                ), (
                        SELECT Intervention_Name__c, Description__c
                        FROM NLM_Interventions__r
                ), (
                        SELECT Criteria__r.Name, Include_Exclude__c, Measure__c, Specific_Measure__c
                        FROM Clinical_Trial_Criteria__r
                )
                FROM Clinical_Trial__c
                WHERE Id IN :recordIds
        ];
    }
}