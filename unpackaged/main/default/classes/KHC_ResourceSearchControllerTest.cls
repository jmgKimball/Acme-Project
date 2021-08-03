@isTest
public class KHC_ResourceSearchControllerTest {
    
    static String testingEmail = 'test@test.com';
    private static Id knowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Knowledge').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Account a = MKH_TestDataFactory.createPersonAccount('First', 'Last', testingEmail, true);
        Contact con = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = :a.Id];
        MKH_TestDataFactory.createCommunityUser( con, true, true);
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];

        List<Knowledge__kav> newArticles = new List<Knowledge__kav>();
        newArticles.add( KHC_TestUtility.insertKnowledgeArticleVersion( 'SampleArticle', 'Article',
                false, knowledgeRecordTypeId, true) );
        newArticles.add( KHC_TestUtility.insertKnowledgeArticleVersion( 'SampleWeb', 'Web',
                false, knowledgeRecordTypeId, false ) );
        newArticles[1].Komen_Site_URL__c = 'https://test.com';
        newArticles[1].Community_Topics__c = 'Care coordination, logistics;Screening & Mammograms';
        INSERT newArticles;
        for( Knowledge__kav knowledge : [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav] ){
            KbManagement.PublishingService.publishArticle( knowledge.KnowledgeArticleId, true );   
        }

        Referral_Record__c refRecord = KHC_TestUtility.insertReferralRecord( a.Id, newArticles[1].Id, false );
        refRecord.Referred__c = true;
        refRecord.Favourite__c = true;

        INSERT refRecord;
    }

    @isTest
    static void getResourcesNullFilters(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            List<Knowledge__kav> articles = KHC_ResourceSearchController.getResources( null );
            System.assertEquals( 2, articles.size(), 'All articles must be returned.');
            Test.stopTest();
        }
    }

    @isTest
    static void getResourcesFilterByType(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            KHC_ResourceSearchController.ResourceFilterWrapper filter = new KHC_ResourceSearchController.ResourceFilterWrapper();
            filter.type = new List<String>{'Web'};
            List<Knowledge__kav> articles = KHC_ResourceSearchController.getResources( filter );
            System.assertEquals( 1, articles.size(), '1 article must be returned.');
            Test.stopTest();
        }
    }

    @isTest
    static void getResourcesFilterByTopics(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            KHC_ResourceSearchController.ResourceFilterWrapper filter = new KHC_ResourceSearchController.ResourceFilterWrapper();
            filter.topics = new List<String>{'Care coordination, logistics'};
            List<Knowledge__kav> articles = KHC_ResourceSearchController.getResources( filter );
            System.assertEquals( 1, articles.size(), '1 article must be returned.');
            Test.stopTest();
        }
    }

    @isTest
    static void getResourcesFilterByFeatured(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            KHC_ResourceSearchController.ResourceFilterWrapper filter = new KHC_ResourceSearchController.ResourceFilterWrapper();
            filter.featured = true;
            List<Knowledge__kav> articles = KHC_ResourceSearchController.getResources( filter );
            System.assertEquals( 1, articles.size(), '1 article must be returned.');
            Test.stopTest();
        }
    }

    @isTest
    static void getResourcesFilterByReferred(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            KHC_ResourceSearchController.ResourceFilterWrapper filter = new KHC_ResourceSearchController.ResourceFilterWrapper();
            filter.referred = true;
            List<Knowledge__kav> articles = KHC_ResourceSearchController.getResources( filter );
            System.assertEquals( 1, articles.size(), '1 article must be returned.');
            Test.stopTest();
        }
    }

    @isTest
    static void getResourcesFilterByFavourites(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            KHC_ResourceSearchController.ResourceFilterWrapper filter = new KHC_ResourceSearchController.ResourceFilterWrapper();
            filter.favourites = true;
            List<Knowledge__kav> articles = KHC_ResourceSearchController.getResources( filter );
            System.assertEquals( 1, articles.size(), '1 article must be returned.');
            Test.stopTest();
        }
    }

    @isTest
    static void getResourcesFilterByLocation(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            KHC_ResourceSearchController.ResourceFilterWrapper filter = new KHC_ResourceSearchController.ResourceFilterWrapper();
            filter.location  = new List<String>{'Colorado'};
            List<Knowledge__kav> articles = KHC_ResourceSearchController.getResources( filter );
            System.assertEquals( 0, articles.size(), 'No article must be returned.');
            Test.stopTest();
        }
    }

    @isTest
    static void getResourcesFilterById(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        List<knowledge__kav> knowledges = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            KHC_ResourceSearchController.ResourceFilterWrapper filter = new KHC_ResourceSearchController.ResourceFilterWrapper();
            filter.articleId  = knowledges[0].Id;
            List<Knowledge__kav> articles = KHC_ResourceSearchController.getResources( filter );
            System.assertEquals( 1, articles.size(), '1 article must be returned.');
            Test.stopTest();
        }
    }

    @isTest
    static void getResourcesFilterByAll(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            KHC_ResourceSearchController.ResourceFilterWrapper filter = new KHC_ResourceSearchController.ResourceFilterWrapper();
            filter.type = new List<String>{'Web', 'Article'};
            List<Knowledge__kav> articles = KHC_ResourceSearchController.getResources( filter );
            System.assertEquals( 2, articles.size(), '2 articles must be returned.');
            filter.referred = true;
            articles = KHC_ResourceSearchController.getResources( filter );
            System.assertEquals( 1, articles.size(), '1 article must be returned.');
            Test.stopTest();
        }
    }
}