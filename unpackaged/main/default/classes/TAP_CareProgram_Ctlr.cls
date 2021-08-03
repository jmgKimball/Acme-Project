/****************************************************************************************************************************************************************
* @author IVL Dev
* @date 20-May-2020
* @description class created for adding all client-side controller methods.
****************************************************************************************************************************************************************/
public without sharing class TAP_CareProgram_Ctlr {
    
    /*******************************************************************************************************
    * @description queries  the Eligibility Rules, Eligibility Criteria ,Eligibility Details for respective Care Program.		
    * @param recordId Id of CareProgram Id
    * @return Map with key String and value as Integer which is size of eligibilityRules,criteriaIds,eligibilityDetails for 
    * respective care program.
	********************************************************************************************************/
    
    @auraEnabled
    public static Map<String,Integer> loadProgramDetails(Id recordId){
        List<CareProgramEligibilityRule> eligibilityRules =[Select Id,EligibilityCriteriaId 
                                                            From CareProgramEligibilityRule Where CareProgramId = :recordId];
        List<Id> criteriaIds = new List<Id>();
        for(CareProgramEligibilityRule rule : eligibilityRules) {
            criteriaIds.add(rule.EligibilityCriteriaId);
        }
        
        Integer eligibilityDetails =[Select count() From Eligibility_Detail__c Where Eligibility_Criteria__c IN :criteriaIds];
        
        Map<String,Integer> eligibilityCareProgramMap = new Map<String,Integer>();
        eligibilityCareProgramMap.put('rules',eligibilityRules.size());
        eligibilityCareProgramMap.put('criterias',criteriaIds.size());
        eligibilityCareProgramMap.put('details',eligibilityDetails);
        return eligibilityCareProgramMap;
    }
}