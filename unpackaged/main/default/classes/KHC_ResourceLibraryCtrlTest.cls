@isTest
public class KHC_ResourceLibraryCtrlTest {

    static String testingEmail = 'test@test.com';
    static List<PicklistEntry> knowledgeRelationshipToCancerFields = Knowledge__kav.Relationship_To_Cancer__c.getDescribe().getPicklistValues();
    static List<PicklistEntry> accountRelationshipToCancerFields = Account.Relationship_To_Cancer__pc.getDescribe().getPicklistValues();
    static List<PicklistEntry> dismissalReasonPicklistValues = Referral_Record__c.Dismissal_Reason__c.getDescribe().getPicklistValues();
    private static Id knowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Knowledge').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Account a = MKH_TestDataFactory.createPersonAccount('First', 'Last', testingEmail, true);
        Contact con = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = :a.Id];
        MKH_TestDataFactory.createCommunityUser( con, true, true);
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];

        Knowledge__kav newArticle = KHC_TestUtility.insertKnowledgeArticleVersion( 'xyz', 'Article', true, knowledgeRecordTypeId, false);
        newArticle = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: newArticle.Id];
        KbManagement.PublishingService.publishArticle( newArticle.KnowledgeArticleId, true );    

        Referral_Record__c refRecord = KHC_TestUtility.insertReferralRecord( commUsr.AccountId, newArticle.Id, true );

    }

    static void createKnowledgeArticleVersion () {
        Knowledge__kav newArticle = KHC_TestUtility.insertKnowledgeArticleVersion( 'abc' + Crypto.getRandomInteger(), 'Article', true, knowledgeRecordTypeId, false);
        newArticle = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: newArticle.Id];
        KbManagement.PublishingService.publishArticle( newArticle.KnowledgeArticleId, true );
    }

    static void createFeaturedKnowledgeArticleVersion () {
        Knowledge__kav featuredArticle = KHC_TestUtility.insertKnowledgeArticleVersion( 'abc' + Crypto.getRandomInteger(), 'Article', true, knowledgeRecordTypeId, true);
        featuredArticle = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: featuredArticle.Id];
        KbManagement.PublishingService.publishArticle( featuredArticle.KnowledgeArticleId, true );
    }

    static void createOtherArticleVersion (String relationshipToCancer) {
        Knowledge__kav otherArticle = KHC_TestUtility.insertKnowledgeArticleVersion( 'abc' + Crypto.getRandomInteger(), 'Article', true, knowledgeRecordTypeId, true);

        otherArticle.Relationship_To_Cancer__c = relationshipToCancer;
        update otherArticle;

        otherArticle = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: otherArticle.Id];
        KbManagement.PublishingService.publishArticle( otherArticle.KnowledgeArticleId, true );
    }

    @isTest
    static void getTopics(){
        Test.startTest();
        List<String> topics = KHC_ResourceLibraryCtrl.getTopics();
        Schema.DescribeFieldResult fieldResult = Knowledge__kav.Community_Topics__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.assertEquals( ple.size(), topics.size(), 'Topics must be returned from Schema.' );
        Test.stopTest();
    }

    @isTest
    static void getTypes(){
        Test.startTest();
        List<String> topics = KHC_ResourceLibraryCtrl.getTypes();
        Schema.DescribeFieldResult fieldResult = Knowledge__kav.Resource_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.assertEquals( ple.size(), topics.size(), 'Types must be returned from Schema.' );
        Test.stopTest();
    }

    @isTest
    static void getLocations(){
        Test.startTest();
        List<String> topics = KHC_ResourceLibraryCtrl.getLocations();
        Schema.DescribeFieldResult fieldResult = Knowledge_Resource_Recommendation__c.US_States__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.assertEquals( ple.size(), topics.size(), 'Locations must be returned from Schema.' );
        Test.stopTest();
    }

    @isTest
    static void getReferrals(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];

        System.runAs( commUsr ){
            Test.startTest();
            //When Referral = false 
            List<Referral_Record__c> referralRecords = KHC_ResourceLibraryCtrl.getMyReferrals();
            System.assertEquals( 0, referralRecords.size(), 'No records should be returned.' );
            //With Referral = true
            List<Referral_Record__c> existingReferralRecords = new List<Referral_Record__c>();
            for( Referral_Record__c refRec : [SELECT Id, Referred__c FROM Referral_Record__c] ){
                refRec.Referred__c = TRUE;
                existingReferralRecords.add( refRec );
            }
            UPDATE existingReferralRecords;
            referralRecords = KHC_ResourceLibraryCtrl.getMyReferrals();
            System.assertEquals( 1, referralRecords.size(), '1 referred record should be returned.' );
            Test.stopTest();
        }
    }
    @isTest
    static void getMyFavorites(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];

        System.runAs( commUsr ){
            Test.startTest();
            //When Favourite__c = false 
            List<Referral_Record__c> referralRecords = KHC_ResourceLibraryCtrl.getMyFavorites();
            System.assertEquals( 0, referralRecords.size(), 'No records should be returned.' );
            //With Favourite__c = true
            List<Referral_Record__c> existingReferralRecords = new List<Referral_Record__c>();
            for( Referral_Record__c refRec : [SELECT Id, Favourite__c, Knowledge_Article_Referred__c FROM Referral_Record__c] ){
                refRec.Favourite__c = TRUE;
                existingReferralRecords.add( refRec );
            }
            UPDATE existingReferralRecords;
            referralRecords = KHC_ResourceLibraryCtrl.getMyFavorites();
            System.assertEquals( 1, referralRecords.size(), '1 referred record should be returned.' );
            Test.stopTest();
        }
    }

    @isTest
    static void getOtherResourcesSingle(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        Account acc = [SELECT Id, Relationship_To_Cancer__pc FROM Account WHERE Id = :commUsr.AccountId];
        acc.Relationship_To_Cancer__pc = String.valueOf(accountRelationshipToCancerFields[0].getLabel());
        update acc;

        createOtherArticleVersion(String.valueOf(knowledgeRelationshipToCancerFields[0].getLabel()));

        System.runAs( commUsr ){
            Test.startTest();
            List<Knowledge__kav> referralRecords = KHC_ResourceLibraryCtrl.getOtherResources();
            System.assertEquals( 1, referralRecords.size(), '1 other records should be returned.' );
            Test.stopTest();
        }
    }

    @isTest
    static void getOtherResourcesMultipleOnAccount(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        Account acc = [SELECT Id, Relationship_To_Cancer__pc FROM Account WHERE Id = :commUsr.AccountId];
        acc.Relationship_To_Cancer__pc = String.valueOf(
                accountRelationshipToCancerFields[0].getLabel() + ';' +
                accountRelationshipToCancerFields[1].getLabel() + ';' +
                accountRelationshipToCancerFields[2].getLabel()
        );
        update acc;

        createOtherArticleVersion(String.valueOf(knowledgeRelationshipToCancerFields[0].getLabel()));

        System.runAs( commUsr ){
            Test.startTest();
            List<Knowledge__kav> referralRecords = KHC_ResourceLibraryCtrl.getOtherResources();
            System.assertEquals( 1, referralRecords.size(), '1 other records should be returned.' );
            Test.stopTest();
        }
    }

    @isTest
    static void getOtherResourcesMultipleOnArticle(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        Account acc = [SELECT Id, Relationship_To_Cancer__pc FROM Account WHERE Id = :commUsr.AccountId];
        acc.Relationship_To_Cancer__pc = String.valueOf(accountRelationshipToCancerFields[0].getLabel());
        update acc;

        createOtherArticleVersion(
                String.valueOf(accountRelationshipToCancerFields[0].getLabel() + ';' +
                accountRelationshipToCancerFields[1].getLabel() + ';' +
                accountRelationshipToCancerFields[2].getLabel())
        );

        System.runAs( commUsr ){
            Test.startTest();
            List<Knowledge__kav> referralRecords = KHC_ResourceLibraryCtrl.getOtherResources();
            System.assertEquals( 1, referralRecords.size(), '1 other records should be returned.' );
            Test.stopTest();
        }
    }

    @isTest
    static void getOtherResourcesMultipleResults(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        Account acc = [SELECT Id, Relationship_To_Cancer__pc FROM Account WHERE Id = :commUsr.AccountId];
        acc.Relationship_To_Cancer__pc = String.valueOf(
                accountRelationshipToCancerFields[0].getLabel() + ';' +
                        accountRelationshipToCancerFields[1].getLabel() + ';' +
                        accountRelationshipToCancerFields[2].getLabel()
        );
        update acc;

        createOtherArticleVersion(String.valueOf(knowledgeRelationshipToCancerFields[0].getLabel()));
        createOtherArticleVersion(String.valueOf(knowledgeRelationshipToCancerFields[1].getLabel()));
        createOtherArticleVersion(String.valueOf(knowledgeRelationshipToCancerFields[2].getLabel()));

        System.runAs( commUsr ){
            Test.startTest();
            List<Knowledge__kav> referralRecords = KHC_ResourceLibraryCtrl.getOtherResources();
            System.assertEquals( 3, referralRecords.size(), '3 other records should be returned.' );
            Test.stopTest();
        }
    }

    @isTest
    static void getOtherResourcesFail(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        Account acc = [SELECT Id, Relationship_To_Cancer__pc FROM Account WHERE Id = :commUsr.AccountId];
        acc.Relationship_To_Cancer__pc = String.valueOf(accountRelationshipToCancerFields[0].getLabel());
        update acc;

        createOtherArticleVersion(String.valueOf(knowledgeRelationshipToCancerFields[1].getLabel()));

        System.runAs( commUsr ){
            Test.startTest();
            List<Knowledge__kav> referralRecords = KHC_ResourceLibraryCtrl.getOtherResources();
            System.assertEquals( 0, referralRecords.size(), '0 other records should be returned.' );
            Test.stopTest();
        }
    }

    @isTest
    static void toggleFavouriteTestCreateNew(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        List<Knowledge__kav> kav = [SELECT Id, Featured__c FROM Knowledge__kav LIMIT 1];

        System.runAs( commUsr ){
            Test.startTest();
            Referral_Record__c referralRecordResponse = KHC_ResourceLibraryCtrl.toggleFavourite(commUsr.AccountId, false, kav[0].Id, false);

            System.assertNotEquals( null, referralRecordResponse, 'A new Referral Record should be created' );
            System.assertEquals( commUsr.AccountId, referralRecordResponse.Patient__c, 'The referral record should be tied to our Account Id' );
            System.assertEquals( kav[0].Id, referralRecordResponse.Knowledge_Article_Referred__c, 'The referral record should be tied to the Knowledge Article Version we liked' );
            System.assertEquals( true, referralRecordResponse.Favourite__c, 'The referral record should be favourited' );
            System.assertEquals( false, referralRecordResponse.Featured__c, 'The referral record should not be featured because the Knowledge Article Version was not featured' );
            Test.stopTest();
        }
    }

    @isTest
    static void toggleFavouriteTestCreateNewWithFeatured(){
        createFeaturedKnowledgeArticleVersion();

        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        List<Knowledge__kav> featuredKav = [SELECT Id, Featured__c FROM Knowledge__kav WHERE Featured__c = TRUE LIMIT 1];

        System.runAs( commUsr ){
            Test.startTest();
            Referral_Record__c referralRecordResponse = KHC_ResourceLibraryCtrl.toggleFavourite(commUsr.AccountId, false, featuredKav[0].Id, true);

            System.assertNotEquals( null, referralRecordResponse, 'A new Referral Record should be created' );
            System.assertEquals( commUsr.AccountId, referralRecordResponse.Patient__c, 'The referral record should be tied to our Account Id' );
            System.assertEquals( featuredKav[0].Id, referralRecordResponse.Knowledge_Article_Referred__c, 'The referral record should be tied to the Knowledge Article Version we liked' );
            System.assertEquals( true, referralRecordResponse.Favourite__c, 'The referral record should be favourited' );
            System.assertEquals( true, referralRecordResponse.Featured__c, 'The referral record should be featured' );
            Test.stopTest();
        }
    }

    @isTest
    static void toggleFavouriteTestUnFavouriteSingle(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        List<Knowledge__kav> kav = [SELECT Id, Featured__c FROM Knowledge__kav LIMIT 1];

        System.runAs( commUsr ){
            Test.startTest();
            KHC_ResourceLibraryCtrl.toggleFavourite(commUsr.AccountId, false, kav[0].Id, false);

            Referral_Record__c referralRecordResponse = KHC_ResourceLibraryCtrl.toggleFavourite(commUsr.AccountId, true, kav[0].Id, false);

            System.assertEquals( null, referralRecordResponse, 'A null response should be returned after un-favouriting' );
            List<Referral_Record__c> anyOtherFavourites = [SELECT Id, Patient__c FROM Referral_Record__c WHERE Patient__c = :commUsr.AccountId AND Knowledge_Article_Referred__c = :kav[0].Id AND Favourite__c = TRUE];
            System.assertEquals( 0, anyOtherFavourites.size(), 'There should be no other favourited referral records for our Users Account' );
            Test.stopTest();
        }
    }

    @isTest
    static void toggleFavouriteTestUnFavouriteMultiple(){
        createKnowledgeArticleVersion();
        createKnowledgeArticleVersion();
        createKnowledgeArticleVersion();

        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        List<Knowledge__kav> kavs = [SELECT Id, Featured__c FROM Knowledge__kav];
        System.assertEquals(4, kavs.size());
        for ( Knowledge__kav k : kavs ) {
            KHC_ResourceLibraryCtrl.toggleFavourite(commUsr.AccountId, false, k.Id, false);
        }

        System.runAs( commUsr ){
            Test.startTest();

            Referral_Record__c referralRecordResponse = KHC_ResourceLibraryCtrl.toggleFavourite(commUsr.AccountId, true, kavs[0].Id, false);

            System.assertEquals( null, referralRecordResponse, 'A null response should be returned after un-favouriting' );
            List<Referral_Record__c> anyOtherFavourites = [SELECT Id, Patient__c FROM Referral_Record__c WHERE Patient__c = :commUsr.AccountId AND Favourite__c = TRUE];
            System.assertEquals( 3, anyOtherFavourites.size(), 'There should still be 3 other favourited referral records' );
            Test.stopTest();
        }
    }

    @isTest
    static void toggleFavouriteTestUnFavouriteWithDuplicates(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        List<Knowledge__kav> kav = [SELECT Id, Featured__c FROM Knowledge__kav LIMIT 1];

        KHC_ResourceLibraryCtrl.toggleFavourite(commUsr.AccountId, false, kav[0].Id, false);
        KHC_ResourceLibraryCtrl.toggleFavourite(commUsr.AccountId, false, kav[0].Id, false);
        KHC_ResourceLibraryCtrl.toggleFavourite(commUsr.AccountId, false, kav[0].Id, false);

        List<Referral_Record__c> duplicateFavouritedReferralRecords = [SELECT Id, Patient__c FROM Referral_Record__c WHERE Patient__c = :commUsr.AccountId AND Knowledge_Article_Referred__c = :kav[0].Id AND Favourite__c = TRUE];
        System.assertEquals(3, duplicateFavouritedReferralRecords.size(), 'There should be 3 duplicate favourited referral records for the same article');

        System.runAs( commUsr ){
            Test.startTest();

            Referral_Record__c referralRecordResponse = KHC_ResourceLibraryCtrl.toggleFavourite(commUsr.AccountId, true, kav[0].Id, false);

            System.assertEquals( null, referralRecordResponse, 'A null response should be returned after un-favouriting' );
            List<Referral_Record__c> anyOtherFavourites = [SELECT Id, Patient__c FROM Referral_Record__c WHERE Patient__c = :commUsr.AccountId AND Favourite__c = TRUE];
            System.assertEquals( 0, anyOtherFavourites.size(), 'All favourited referral records for the same Article Version should be un-favourited' );
            Test.stopTest();
        }
    }

    @isTest
    static void removeReferralSingle(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];

        List<Referral_Record__c> referralRecords = [SELECT Id, Knowledge_Article_Referred__c FROM Referral_Record__c WHERE Patient__c = :commUsr.AccountId];
        referralRecords[0].Referred__c = true;
        update referralRecords[0];

        System.runAs( commUsr ){
            Test.startTest();
            Referral_Record__c referralRecordResponse = KHC_ResourceLibraryCtrl.removeReferral(referralRecords[0].Knowledge_Article_Referred__c, dismissalReasonPicklistValues[0].getLabel());
            System.assertEquals( null, referralRecordResponse, 'A null response should be returned after removing the referral' );
            List<Referral_Record__c> anyOtherReferrals = [SELECT Id, Patient__c FROM Referral_Record__c WHERE Knowledge_Article_Referred__c = :referralRecords[0].Knowledge_Article_Referred__c AND Patient__c = :commUsr.AccountId AND Referred__c = TRUE];
            System.assertEquals( 0, anyOtherReferrals.size(), 'All referred records for the same Article Version should be removed' );

            Referral_Record__c dismissedReferral = [SELECT Id, Dismissal_Reason__c, Referred__c FROM Referral_Record__c WHERE Id = :referralRecords[0].Id];
            System.assertEquals( false, dismissedReferral.Referred__c, 'The referral record should still exist but not be referred' );
            System.assertEquals( dismissalReasonPicklistValues[0].getLabel(), dismissedReferral.Dismissal_Reason__c, 'The dismissal reason on the dismissed referral should be populated' );

            Test.stopTest();
        }
    }

    @isTest
    static void removeReferralMultiple(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        List<Knowledge__kav> kav = [SELECT Id, Featured__c FROM Knowledge__kav LIMIT 1];

        KHC_TestUtility.insertReferralRecord( commUsr.AccountId, kav[0].Id, true );
        KHC_TestUtility.insertReferralRecord( commUsr.AccountId, kav[0].Id, true );

        List<Referral_Record__c> referralRecords = [SELECT Id, Knowledge_Article_Referred__c FROM Referral_Record__c WHERE Patient__c = :commUsr.AccountId];
        for ( Referral_Record__c rr : referralRecords ) {
            rr.Referred__c = true;
        }
        update referralRecords;

        System.runAs( commUsr ){
            Test.startTest();
            Referral_Record__c referralRecordResponse = KHC_ResourceLibraryCtrl.removeReferral(kav[0].Id, dismissalReasonPicklistValues[0].getLabel());
            System.assertEquals( null, referralRecordResponse, 'A null response should be returned after removing the referral' );
            List<Referral_Record__c> anyOtherReferrals = [SELECT Id, Patient__c FROM Referral_Record__c WHERE Knowledge_Article_Referred__c = :kav[0].Id AND Patient__c = :commUsr.AccountId AND Referred__c = TRUE];
            System.assertEquals( 0, anyOtherReferrals.size(), 'All referred records for the same Article Version should be removed' );
            Test.stopTest();
        }
    }
}