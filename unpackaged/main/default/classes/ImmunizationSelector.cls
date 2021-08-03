/* * Selector class for Immunization(HealthCloudGA__EhrImmunization__c) 
 *
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-10-01
 */
 public with sharing class ImmunizationSelector {
    public List<HealthCloudGA__EhrImmunization__c> getImmunizationsByAccountId( String accountId ) {
        if( String.isNotBlank( accountId ) ){
            return [SELECT Id, HealthCloudGA__Account__c, 
                    Name, Immunization_Type__c,
                    Date_Administered__c
                    FROM HealthCloudGA__EhrImmunization__c
                    WHERE HealthCloudGA__Account__c = :accountId ];
        }
        return null;
    }
}