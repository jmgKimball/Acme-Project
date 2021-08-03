/**
 * KHC_MyInsuranceController is used to control all screens related to Insurance
 *
 * @author Sabrina Perardt, Traction on Demand
 * * @date 2020-09-16
 *
 */
public with sharing class KHC_MyInsuranceController {

    private static AccountSelector accountSelector = new AccountSelector();

    @AuraEnabled
    public static Map<String, List<String>> getPicklistValues() {
        List<String> providers = new List<String>();
        Schema.DescribeFieldResult fieldResultProvider = Insurance__c.Insurance_Provider__c.getDescribe();
        List<Schema.PicklistEntry> plep = fieldResultProvider.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : plep) {
            providers.add(pickListVal.getLabel());
        }

        List<String> isInsuredValues = new List<String>();
        Schema.DescribeFieldResult fieldResultInsured = Account.Is_Insured__pc.getDescribe();
        List<Schema.PicklistEntry> plei = fieldResultInsured.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : plei) {
            isInsuredValues.add(pickListVal.getLabel());
        }

        Map<String, List<String>> myPicklists = new Map<String, List<String>>();
        myPicklists.put('Insurance_Provider__c', providers);
        myPicklists.put('Is_Insured__pc',isInsuredValues );

        return myPicklists;
    }

    @AuraEnabled
    public static void insertInsurance(String accId, Insurance__c myInsurance) {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :accId];
        if (contacts.size() > 0) {
            myInsurance.Member__c = contacts.get(0).Id;
        }
        upsert myInsurance;

    }

    @AuraEnabled
    public static List<Insurance__c> getMyInsuranceProvider(String currentLoggedAccount) {
        List<Insurance__c> insuranceInfo = [
                SELECT Member__c, Member_Number__c, Subscriber_Last_Name__c,
                        Subscriber_First_Name__c, Subscriber_Date_of_Birth__c, Subscriber_Number__c,
                        Member__r.AccountId, Member__r.Account.Name, Insurance_Provider__c, (
                        SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType
                        FROM ContentDocumentLinks
                )
                FROM Insurance__c
                WHERE Member__r.AccountId = :currentLoggedAccount
                ORDER BY Insurance_Provider__c
        ];

        return insuranceInfo;

    }

    @AuraEnabled
    public static List<ContentVersion> getImages(String insuranceId) {
        List<ContentDocumentLink> contentDocumentInfo = [
                SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :insuranceId
        ];

        List<Id> ContentDocumentIdList = new List<Id> ();

        for (ContentDocumentLink con : contentDocumentInfo) {
            ContentDocumentIdList.add(con.ContentDocumentId);
        }

        List<ContentVersion> ContentVersionInfo = [
                SELECT ContentDocumentId, Id, Title
                FROM ContentVersion
                WHERE ContentDocumentId = :ContentDocumentIdList
        ];

        return ContentVersionInfo;
    }

    @AuraEnabled
    public static void deleteInsurance(Insurance__c myInsurance) {
        if (myInsurance != null && myInsurance.Id != null)
            delete myInsurance;
    }

    /**
     * Get the data for a person account Id
     *
     * @param accountId Id for the person account
     * @return Response object including the person account
     *
     * @author Scott Taylor, Traction on Demand
     * @date 2020-11-17
     */
    @AuraEnabled
    public static KHC_MyInsuranceControllerResponse getAccountData(String accountId) {
        KHC_MyInsuranceControllerResponse response = new KHC_MyInsuranceControllerResponse();

        List<Account> personAccounts = accountSelector.getPersonAccountById(new List<String>{accountId});
        if (!personAccounts.isEmpty()) {
            response.personAccount = personAccounts[0];
        }

        return response;
    }

    /**
     * Update the data for a person account Id
     *
     * @param personAccount Account to update
     * @return Response object including the update status
     *
     * @author Scott Taylor, Traction on Demand
     * @date 2020-11-17
     */
    @AuraEnabled
    public static KHC_MyInsuranceControllerResponse updateAccountData(Account personAccount) {
        KHC_MyInsuranceControllerResponse response = new KHC_MyInsuranceControllerResponse();

        try {
            update personAccount;
            response.isSuccess = true;
        } catch (DmlException ex) {
            response.isSuccess = false;
            response.message = ex.getMessage();
        }

        return response;
    }

    /**
     * Response class for KHC_MyInsuranceController
     *
     * @author Scott Taylor, Traction on Demand
     * @date 2020-11-17
     */
    public class KHC_MyInsuranceControllerResponse {
        @AuraEnabled public Account personAccount;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean isSuccess;

        public KHC_MyInsuranceControllerResponse() {}
    }

}