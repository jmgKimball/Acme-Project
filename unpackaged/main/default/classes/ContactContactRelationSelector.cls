/**
 * Selector for ContactContactRelation records
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-09-18
 */
 public with sharing class ContactContactRelationSelector {
    public List<HealthCloudGA__ContactContactRelation__c> selectByRelatedContactAndRoleIds( Id contactId, Set<Id> roleIds ){
        return [
                SELECT Id, HealthCloudGA__Contact__c, HealthCloudGA__Contact__r.Name, 
                Provider__c, Provider__r.Name, RecordTypeId, HealthCloudGA__Role__c,
                HealthCloudGA__Active__c, HealthCloudGA__Role__r.Name,
                HealthCloudGA__Contact__r.FirstName, HealthCloudGA__Contact__r.LastName,
                HealthCloudGA__Contact__r.Email, HealthCloudGA__Contact__r.Phone,
				HealthCloudGA__Contact__r.HomePhone, HealthCloudGA__Contact__r.OtherPhone,
                HealthCloudGA__Contact__r.MailingAddress, HealthCloudGA__Contact__r.Description,
                Emergency_Contact__c
                FROM HealthCloudGA__ContactContactRelation__c
                WHERE HealthCloudGA__RelatedContact__c =: contactId
                AND HealthCloudGA__Role__c IN: roleIds
            ];
    }
    public List<HealthCloudGA__ContactContactRelation__c> selectByContactAndRole( Id contactId, Id roleId ){
        return [
                SELECT Id, HealthCloudGA__Contact__c, HealthCloudGA__Contact__r.Name, 
                Provider__c, Provider__r.Name, RecordTypeId, HealthCloudGA__Role__c,
                HealthCloudGA__Active__c, Provider__r.NPI_ID__c, Provider__r.MailingStreet, 
                Provider__r.MailingCity, Provider__r.MailingStateCode, Provider__r.MailingCountry,
                Provider__r.MailingPostalCode
                FROM HealthCloudGA__ContactContactRelation__c
                WHERE HealthCloudGA__RelatedContact__c = :contactId AND
                HealthCloudGA__Role__c = :roleId AND
                Provider__c != null
            ];
    }
}