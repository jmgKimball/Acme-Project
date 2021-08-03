public with sharing class kHC_MyHeathProfileController {

    private static ReciprocalRoleSelector reciprocalRoleSelector = new ReciprocalRoleSelector();
    private static final String ROLE_NAME = 'Provider';

    @AuraEnabled
    public static List<Account> getMyInformation(Id currentLoggedAccount) {
        Date today = Date.today();

        return [
                SELECT Id, Height_ft__pc, Height_in__pc, Blood_Type__pc,
                        Multiple_Twin__pc, Organ_Donor__pc, Care_Giver_Co_Survivor__pc, Relationship_To_Cancer__pc,
                        Risk_Level__c, Notes_Risk_Assessment__c, Date_of_Assessment__c, Type_of_Assessment__c,
                        Breast_Health_topics_on_your_mind__pc,
                (
                        SELECT Id, Name, FirstName, Rhesus_Negative__c
                        FROM Contacts
                ),
                (
                        SELECT Family_Member_Name__c, Relationship__c, RecordType.Name
                        FROM Patient_Contacts__r 
                ),
                (
                        SELECT Condition_Name__c
                        FROM HealthCloudGA__Conditions__r
                ),
                (
                        SELECT HealthCloudGA__MedicationName__c
                        FROM HealthCloudGA__MedicationStatements__r
                        WHERE Medication__c != NULL
                ),
                (
                        SELECT Allergy_Type__c, Allergen_Name__c
                        FROM HealthCloudGA__AllergyIntolerances__r
                ),
                (
                        SELECT Immunization_Type__c
                        FROM HealthCloudGA__Immunizations__r
                ),
                (
                        SELECT Procedure_Type__c
                        FROM HealthCloudGA__EHRProcedures__r
                ), 
                (       SELECT Title__c, Appointment_Date__c, Appointment_Time__c
                        FROM HealthCloudGA__Encounters__r
                        WHERE Appointment_Date__c >= :today
                        ORDER BY Appointment_Date__c, Appointment_Time__c ASC
                )
                FROM Account
                WHERE Id = :currentLoggedAccount
        ];
    }

    @AuraEnabled
    public static List<Insurance__c> getInsurancesByMemberId(Id memberId) {
        return [
                SELECT Insurance_Provider__c, Name
                FROM Insurance__c
                WHERE Member__c = :memberId
        ];
    }

    @AuraEnabled
    public static List<HealthCloudGA__ContactContactRelation__c> getProvidersByPatientId(Id contactId) {
        Id roleId = getProviderRoleId();
        return [
                SELECT Provider__c, Provider__r.Name
                FROM HealthCloudGA__ContactContactRelation__c
                WHERE HealthCloudGA__RelatedContact__c = :contactId AND
                HealthCloudGA__Role__c = :roleId AND
                HealthCloudGA__Active__c = TRUE
        ];
    }

    @AuraEnabled
    public static void updateAccount(Account accountToBeUpdated, Contact contactToBeUpdated) {
        update accountToBeUpdated;
        update contactToBeUpdated;
    }

    @AuraEnabled
    public static List<String> getBloodTypePicklistValues() {
        List<String> bloodTypes = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Blood_Type__pc.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            bloodTypes.add(pickListVal.getLabel());
        }

        return bloodTypes;
    }

    @AuraEnabled
    public static List<String> getRelationShipValues() {
        List<String> relationship = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Relationship_To_Cancer__pc.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            relationship.add(pickListVal.getLabel());
        }

        return relationship;
    }

    @AuraEnabled
    public static List<String> getBreastHealthTopic() {
        List<String> relationship = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Breast_Health_topics_on_your_mind__pc.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            relationship.add(pickListVal.getLabel());
        }

        return relationship;
    }

    public static Id getProviderRoleId(){
        List<HealthCloudGA__ReciprocalRole__c> roles = reciprocalRoleSelector.selectRoleByName( ROLE_NAME );
        if( roles != null && !roles.isEmpty() ){
            return roles[0].Id;
        }
        return null;
    }

    private static Set<Id> getCaregiverRoleIds(){
        Set<Id> roleIds = new Set<Id>();
        List<HealthCloudGA__ReciprocalRole__c> roles = reciprocalRoleSelector.selectRolesByNames( KHC_MyContactsController.CONTACT_ROLES );
        if( roles != null && !roles.isEmpty() ){
            for( HealthCloudGA__ReciprocalRole__c role: roles ){
                roleIds.add( role.Id );
            }
        }
        return roleIds;
    }
}