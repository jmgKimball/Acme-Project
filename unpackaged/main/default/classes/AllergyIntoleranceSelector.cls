/* * Selector class for HealthCloudGA__EhrAllergyIntolerance__c
 *
 * @author Vikrant Upneja, Traction on Demand
 * @date 2021-01-15
 */
public with sharing class AllergyIntoleranceSelector {

    public List<HealthCloudGA__EhrAllergyIntolerance__c> selectAllergiesIntolerancesByAccId( String accountId ){
        if( String.isNotBlank( accountId ) ){
            return [SELECT Id, Name,
                    Allergy_Type__c,
                    Allergen_Name__c,
                    Reaction_Type__c,
                    HealthCloudGA__Reaction__c,
                    Severity__c ,
                    HealthCloudGA__Account__c
                    FROM HealthCloudGA__EhrAllergyIntolerance__c
                    WHERE HealthCloudGA__Account__c = :accountId];
        }
        return null;
    }
}