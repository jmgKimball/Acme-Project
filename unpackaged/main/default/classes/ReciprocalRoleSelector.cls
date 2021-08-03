public without sharing class ReciprocalRoleSelector {
    public List<HealthCloudGA__ReciprocalRole__c> selectRoleByName( String roleName ){
        return [SELECT Id, Name 
                FROM HealthCloudGA__ReciprocalRole__c 
                WHERE Name =: roleName ];
    }

    public List<HealthCloudGA__ReciprocalRole__c> selectRolesByNames( Set<String> roleNames ){
        return [SELECT Id, Name 
                FROM HealthCloudGA__ReciprocalRole__c 
                WHERE Name IN: roleNames ];
    }
}