/**
 * @description Controller class for My Health Profile Page.
 * @author Vikrant Upneja , Traction on Demand
 * @date 9/14/2020.
 */
public with sharing class kHC_MyHeathConditionsController {

    /**
     * Get the Map of Type of Health Condition and Health Conditions
     * @param recordId current Logged in Account Id
     *
     * @return Map of Type and List of Condition.
     */
    /*
    @AuraEnabled
    //public static List<HealthCloudGA__EhrCondition__c> getBreastCancerConditions(Id currentLoggedAccount){
    public static Map<String, List<HealthCloudGA__EhrCondition__c>> getBreastCancerConditions(Id currentLoggedAccount){
          Map<String, List<HealthCloudGA__EhrCondition__c>>  healthConditionMap = new Map<String, List<HealthCloudGA__EhrCondition__c>>();
        system.debug('** currentLoggedAccount '+ currentLoggedAccount);
        List<HealthCloudGA__EhrCondition__c> breastCancerInfo = [
                                                                    SELECT  Id, Breast_Cancer_Sub_Type__c,Breast_Cancer_Type__c, Stage_at_Diagnosis__c,
                                                                            HealthCloudGA__DateAsserted__c, Date_Abated__c, Condition_Name__c, HealthCloudGA__IsAbated__c,
                                                                            HealthCloudGA__Notes__c, recordtype.Name, recordtype.Id
                                                                    FROM HealthCloudGA__EhrCondition__c
                                                                    WHERE HealthCloudGA__Account__c = :currentLoggedAccount  and Condition_Name__c != ''
                                                                ];

        system.debug('** breastCancerInfo.size() '+ breastCancerInfo.size());

        if(breastCancerInfo.size() >0) {
            for (HealthCloudGA__EhrCondition__c condition : breastCancerInfo) {
                if (healthConditionMap.containsKey((condition.RecordType).Name)) {
                    healthConditionMap.get((condition.RecordType).Name).add(condition);
                } else {
                    List<HealthCloudGA__EhrCondition__c> healthConditionList = new List<HealthCloudGA__EhrCondition__c>();
                    healthConditionList.add(condition);
                    healthConditionMap.put((condition.RecordType).Name, healthConditionList);
                }
            }
            return healthConditionMap;
        }
        //return breastCancerInfo;
        return null;
    }
    */
/**
 * Get the List of Chronic Conditions
 * @param recordId current Logged in Account Id
 *
 * @return List of Chronic Condition.
 */

    @AuraEnabled
    public static List<HealthCloudGA__EhrCondition__c> getChronicConditions(Id currentLoggedAccount){
        system.debug('** currentLoggedAccount '+ currentLoggedAccount);
        List<HealthCloudGA__EhrCondition__c> chronicConditionsInfo = [
                SELECT  Id, HealthCloudGA__DateAsserted__c, Date_Abated__c, Condition_Name__c, HealthCloudGA__IsAbated__c,
                        HealthCloudGA__Notes__c, recordtype.Name, recordtype.Id
                FROM HealthCloudGA__EhrCondition__c
                WHERE HealthCloudGA__Account__c = :currentLoggedAccount  and Condition_Name__c != ''
                and RecordType.Name = 'Chronic Condition'
        ];

        system.debug('** breastCancerInfo.size() '+ chronicConditionsInfo.size());
        return chronicConditionsInfo;
    }

/**
 * Get the List of Breast Cancer Conditions
 * @param recordId current Logged in Account Id
 *
 * @return  List of Breast Cancer Condition.
 */
    @AuraEnabled
    public static List<HealthCloudGA__EhrCondition__c> getBCancerConditions(Id currentLoggedAccount){
        system.debug('** currentLoggedAccount '+ currentLoggedAccount);
        List<HealthCloudGA__EhrCondition__c> breastCancerInfo = [
                SELECT  Id, Breast_Cancer_Sub_Type__c,Breast_Cancer_Type__c, Stage_at_Diagnosis__c,
                        HealthCloudGA__DateAsserted__c, Date_Abated__c, Condition_Name__c, HealthCloudGA__IsAbated__c,
                        HealthCloudGA__Notes__c, recordtype.Name, recordtype.Id
                FROM HealthCloudGA__EhrCondition__c
                WHERE HealthCloudGA__Account__c = :currentLoggedAccount  and Condition_Name__c != ''
                and RecordType.Name = 'Breast Cancer'
        ];

        system.debug('** breastCancerInfo.size() '+ breastCancerInfo.size());

        return breastCancerInfo;
    }

 /**
 *
 * @return List of recordTypes for Condition.
 */
    @AuraEnabled
    public static list<RecordType> getConditionRecordType(){
        return [select Id,Name, Developername from RecordType where sObjectType='HealthCloudGA__EhrCondition__c'];
        //return null;
    }

    @AuraEnabled
    public static List<HealthCloudGA__EhrCondition__c> getCondition(Id recordId, Id currentLoggedAccount) {
        List<HealthCloudGA__EhrCondition__c> conditions = [
                SELECT Id, Breast_Cancer_Type__c, Breast_Cancer_Type_Other__c,
                        Breast_Cancer_Sub_Type__c, Breast_Cancer_Sub_Type_Other__c, HealthCloudGA__IsAbated__c, Date_Abated__c, Is_Recurrence__c,
                        Condition_Name__c, Stage_at_Diagnosis__c, HealthCloudGA__DateAsserted__c, Treatment_Start_Date__c, Treatment_End_Date__c,
                        HealthCloudGA__Notes__c, HealthCloudGA__Account__c
                FROM HealthCloudGA__EhrCondition__c
                WHERE HealthCloudGA__Account__c = :currentLoggedAccount AND Id = :recordId
                LIMIT 1
        ];

        return conditions;
    }
}