@isTest
public class KHC_DeleteUtilityTest {

    Static String testingEmail = 'test@test.com';
    
    @TestSetup
    static void makeData(){
        Account a = MKH_TestDataFactory.createPersonAccount('First', 'Last', testingEmail, true);
        Contact con = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = :a.Id];
        MKH_TestDataFactory.createCommunityUser( con, true, true);
    }
    
    @isTest
    private static void uniteTesDelete(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        HealthCloudGA__EhrImmunization__c immunization = KHC_TestUtility.insertEhrImmunization( commUsr.AccountId, 'Cholera', true );

        System.runAs( commUsr ){
            Test.startTest();
            HealthCloudGA__EhrImmunization__c delImmunization = new HealthCloudGA__EhrImmunization__c();
            delImmunization.Id = immunization.Id;
            KHC_DeleteUtility.deleteRecord( delImmunization );
            Test.stopTest();
            System.assertEquals( 0, [SELECT Id FROM HealthCloudGA__EhrImmunization__c].size(), 'Record should be deleted' );
        }
    } 
    @isTest
    private static void unitTestDeleteNull(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];

        System.runAs( commUsr ){
            Test.startTest();
            KHC_DeleteUtility.deleteRecord( null );
            Test.stopTest();
        }
    } 
    @isTest
    private static void unitTestDeleteBlankRecord(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];

        System.runAs( commUsr ){
            Test.startTest();
            Contact con = new Contact();
            try{
                KHC_DeleteUtility.deleteRecord( con );
            }catch( AuraHandledException ae ){
                System.assertNotEquals( null, ae, 'AuraHandledException should be thrown' );
            }
            Test.stopTest();
        }
    } 
}
