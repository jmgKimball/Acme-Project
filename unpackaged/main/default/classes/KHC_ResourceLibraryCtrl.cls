public with sharing class KHC_ResourceLibraryCtrl {

    private static Set<String> refRecordFieldSet;
    private static Id knowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Knowledge').getRecordTypeId();

    static{
        refRecordFieldSet = new Set<String>();
        refRecordFieldSet.add( 'Favourite__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Featured__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Phone__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Email__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Resource_Type__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Title' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Summary' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Account_Name__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Account_Billing_Address_Street__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Account_Billing_Address_City__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Account_Billing_Address_State__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Account_Billing_Address_Country__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Account_Billing_Address_Zip__c' );
        refRecordFieldSet.add( 'Knowledge_Article_Referred__r.Komen_Site_URL__c' );
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getTopics(){
        List<String> topicOptions = new List<String>();
        Schema.DescribeFieldResult fieldResult = Knowledge__kav.Community_Topics__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			topicOptions.add(pickListVal.getLabel());
		}

		return topicOptions;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getTypes(){
        List<String> typeOptions = new List<String>();
        Schema.DescribeFieldResult fieldResult = Knowledge__kav.Resource_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			typeOptions.add( pickListVal.getLabel() );
		}     
		return typeOptions;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getLocations(){
        List<String> locationOptions = new List<String>();
        Schema.DescribeFieldResult fieldResult = Knowledge_Resource_Recommendation__c.US_States__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			locationOptions.add( pickListVal.getLabel() );
		}
		return locationOptions;
    }

    public static List<Referral_Record__c> removeDuplicateReferralRecords(List<Referral_Record__c> referrals) {

        if (referrals.isEmpty()) {
            return referrals;
        }

        Set<Id> mySet = new Set<Id>();
        List<Referral_Record__c> refs = new List<Referral_Record__c>();

        for (Integer i = 0; i < referrals.size(); i++) {
            if (!mySet.contains(referrals[i].Knowledge_Article_Referred__c)) {
                mySet.add(referrals[i].Knowledge_Article_Referred__c);
                refs.add(referrals[i]);
            }
        }
        return refs;
    }

    @AuraEnabled
    public static List<Referral_Record__c> getMyReferrals(){
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        if( currUser != null ){
            Id accId = currUser.AccountId;
            String query = 'SELECT Id ';
            for( String fieldStr : refRecordFieldSet ){
                query += ', ' + fieldStr;
            }
            query += ' FROM  Referral_Record__c';
            query += ' WHERE Patient__c =: accId';
            query += ' AND Knowledge_Article_Referred__c != NULL';
            query += ' AND Knowledge_Article_Referred__r.IsVisibleInCsp = TRUE';
            query += ' AND Referred__c = TRUE';
            query += ' AND Knowledge_Article_Referred__r.ArchivedById = NULL';
            query += ' AND Knowledge_Article_Referred__r.IsLatestVersion = TRUE';
            query += ' AND Knowledge_Article_Referred__r.PublishStatus = \'Online\'';
            query += ' ORDER BY CreatedDate DESC';
            query += ' LIMIT 3';
            return removeDuplicateReferralRecords(Database.query(query));
        }
        return null;
    }

    @AuraEnabled
    public static List<Referral_Record__c> getMyFavorites(){
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        if( currUser != null ){
            Id accId = currUser.AccountId;
            String query = 'SELECT Id ';
            for( String fieldStr : refRecordFieldSet ){
                query += ', ' + fieldStr;
            }
            query += ' FROM  Referral_Record__c';
            query += ' WHERE Patient__c =: accId';
            query += ' AND Knowledge_Article_Referred__c != NULL';
            query += ' AND Knowledge_Article_Referred__r.IsVisibleInCsp = TRUE';
            query += ' AND Favourite__c = TRUE';
            query += ' AND Knowledge_Article_Referred__r.ArchivedById = NULL';
            query += ' AND Knowledge_Article_Referred__r.IsLatestVersion = TRUE';
            query += ' AND Knowledge_Article_Referred__r.PublishStatus = \'Online\'';
            query += ' ORDER BY CreatedDate DESC';
            query += ' LIMIT 3';
            return removeDuplicateReferralRecords(Database.query(query));
        }
        return null;
    }

    @AuraEnabled
    public static List<Knowledge__kav> getOtherResources(){
        // Return null if Guest User
        Boolean isGuestUser = MyKomenHealthUtility.isGuestUser();
        if ( isGuestUser ) {
            return null;
        }

        // Get current User
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        if (currUser == null) {
            return null;
        }

        // Get current Account for User
        Account currentLoggedInAccount;
        List<Account> userAcc = [SELECT Id, Relationship_To_Cancer__pc FROM Account WHERE Id = :currUser.AccountId LIMIT 1];
        if ( userAcc.size() > 0 ) {
            currentLoggedInAccount = userAcc[0];
        }

        // Other resources are only related by the Relationship_To_Cancer__pc field
        // Return null if no Account or if no values in Relationship_To_Cancer__pc
        if (currentLoggedInAccount.Id == null ||
            currentLoggedInAccount.Relationship_To_Cancer__pc == null ) {
            return null;
        }

        // Build a query clause to ensure Articles contain one or more of the Relationships to Cancer on the Account
        // Need to loop through each relationship value because we can't bind values to INCLUDES as you'd expect
        List<String> relationshipToCancerField = currentLoggedInAccount.Relationship_To_Cancer__pc.split(';');
        String includesQueryVarString = '(';
        for ( String s : relationshipToCancerField ) {
            includesQueryVarString += ' Relationship_To_Cancer__c INCLUDES (\'' + s + '\') OR';
        }
        // Remove the last "OR" from the string and close the clause
        includesQueryVarString = includesQueryVarString.substring(0, (includesQueryVarString.length()-3));
        includesQueryVarString += ')';

        // Limit to 3 for quick view
        Integer recordLimit = 3;

        // Get count of all possible other resources
        String countQuery = 'SELECT COUNT() FROM Knowledge__kav\n' +
                'WHERE ArchivedById = NULL\n' +
                'AND RecordTypeId != NULL\n' +
                'AND RecordTypeId = :knowledgeRecordTypeId\n' +
                'AND IsLatestVersion = TRUE\n' +
                'AND PublishStatus = \'Online\' AND';
        countQuery += includesQueryVarString;
        Integer count = Database.countQuery( countQuery );

        // Determine "random" offset based on count of possible other resources
        Integer rand = Math.floor(Math.random() * count).intValue();
        Integer diff = count - rand;
        rand = ( rand + recordLimit ) > count ? ( rand - (  recordLimit - diff ) ): rand;
        rand = rand < 0 ? 0 : rand;

        // Query fields
        String query = 'SELECT Id, Title, Summary, Resource_Type__c, Community_Topics__c, Phone__c, Email__c';
        query += ', Account__c';
        query += ', Account_Name__c';
        query += ', Account_Billing_Address_Street__c';
        query += ', Account_Billing_Address_City__c';
        query += ', Account_Billing_Address_State__c';
        query += ', Account_Billing_Address_Country__c';
        query += ', Account_Billing_Address_Zip__c';
        query += ', Komen_Site_URL__c';
        query += ', Body__c';

        // Query clauses
        query += ' FROM Knowledge__kav ';
        query += ' WHERE ArchivedById = NULL';
        query += ' And RecordTypeId != NULL';
        query += ' AND RecordTypeId = :knowledgeRecordTypeId';
        query += ' AND IsLatestVersion = TRUE';
        query += ' AND PublishStatus = \'Online\' AND';
        query += includesQueryVarString;
        query += ' LIMIT :recordLimit';
        query += ' OFFSET :rand';

        return Database.query( query );
    }


    @AuraEnabled
    public static Referral_Record__c toggleFavourite(Id currentAccountId, Boolean isFavourited, Id knowledgeArticleId, Boolean isKnowledgeFeatured){
        if ( isFavourited ) {
            unfavouriteReferralRecordsForArticle(currentAccountId, knowledgeArticleId);
            return null;
        } else {
            return createNewFavouritedReferralRecord(currentAccountId, knowledgeArticleId, isKnowledgeFeatured);
        }
    }

    private static void unfavouriteReferralRecordsForArticle (Id currentAccountId, Id knowledgeArticleId) {
        List<Referral_Record__c> existingFavouritedReferralRecords = [SELECT Id, Patient__c, Knowledge_Article_Referred__c
        FROM Referral_Record__c
        WHERE Patient__c = :currentAccountId
        AND Knowledge_Article_Referred__c = :knowledgeArticleId
        AND Favourite__c = true];

        for ( Referral_Record__c r : existingFavouritedReferralRecords ) {
            r.Favourite__c = false;
        }
        update existingFavouritedReferralRecords;
    }

    private static Referral_Record__c createNewFavouritedReferralRecord (Id currentAccountId, Id knowledgeArticleId, Boolean isKnowledgeFeatured) {
        Referral_Record__c r = new Referral_Record__c();
        r.Patient__c = currentAccountId;
        r.Knowledge_Article_Referred__c = knowledgeArticleId;
        r.Favourite__c = true;
        if ( isKnowledgeFeatured ) {
            r.Featured__c = true;
        }
        insert r;
        return r;
    }

    @AuraEnabled
    public static Referral_Record__c removeReferral(Id knowledgeArticleId, String dismissalReason){
        // Return null if Guest User
        Boolean isGuestUser = MyKomenHealthUtility.isGuestUser();
        if ( isGuestUser ) {
            return null;
        }

        // Get current User
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        if (currUser == null) {
            return null;
        }

        List<Referral_Record__c> existingReferredReferrals = [SELECT Id, Patient__c, Knowledge_Article_Referred__c
        FROM Referral_Record__c
        WHERE Patient__c = :currUser.AccountId
        AND Knowledge_Article_Referred__c = :knowledgeArticleId
        AND Referred__c = true];

        if ( existingReferredReferrals.size() > 0 ) {
            for( Referral_Record__c rr : existingReferredReferrals ) {
                rr.Referred__c = false;
                rr.Dismissal_Reason__c = dismissalReason;
            }
            update existingReferredReferrals;
        }

        return null;
    }

}