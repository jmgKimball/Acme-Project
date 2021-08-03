@isTest
public class KHC_SyncReferralRecordsTest {
    static String testingEmail = 'test@test.com';
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
        String draftId = KbManagement.PublishingService.editOnlineArticle( newArticle.KnowledgeArticleId, true );
        KbManagement.PublishingService.publishArticle( newArticle.KnowledgeArticleId, true );    
    }

    @isTest
    static void syncReferralBatchTest(){
        List<Referral_Record__c> refRecords = [SELECT Id FROM Referral_Record__c WHERE Knowledge_Article_Referred__r.IsLatestVersion = FALSE];
        System.assertEquals( 1, refRecords.size(), '1 Referal record should have old article');
        Test.startTest();
        KHC_SyncReferralRecordsBatch syncReferralBatch = new KHC_SyncReferralRecordsBatch();
        Database.executeBatch( syncReferralBatch );
        Test.stopTest();
        refRecords = [SELECT Id FROM Referral_Record__c WHERE Knowledge_Article_Referred__r.IsLatestVersion = FALSE];
        System.assertEquals( 0, refRecords.size(), '0 Referal record should have old article');
    }
    @isTest
    static void syncReferralSchTest(){
        Test.startTest();
        KHC_SyncReferralRecordsSchedule syncReefRecordSchedule = new KHC_SyncReferralRecordsSchedule();
        String sch = '0 0 23 * * ?';
		system.schedule( 'Sync Ref Record', sch, syncReefRecordSchedule );
        Test.stopTest();
    }
}
