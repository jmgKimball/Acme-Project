@isTest
public class KHC_ImmunizationsControllerTest {
    Static String testingEmail = 'test@test.com';
    
    @TestSetup
    static void makeData(){
        Account a = MKH_TestDataFactory.createPersonAccount('First', 'Last', testingEmail, true);
        Contact con = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = :a.Id];
        MKH_TestDataFactory.createCommunityUser( con, true, true);
    }

    @isTest
    static void getImmunizationsForCommUser(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        List<HealthCloudGA__EhrImmunization__c> immunizations = new List<HealthCloudGA__EhrImmunization__c>();
        immunizations.addAll( KHC_TestUtility.insertEhrImmunizations( null, 'Hepatitis A', 5, false ) );
        immunizations.add( KHC_TestUtility.insertEhrImmunization( commUsr.AccountId, 'Cholera', false ) );
        immunizations.add( KHC_TestUtility.insertEhrImmunization( commUsr.AccountId, 'Hepatitis A', false ) );
        INSERT immunizations;

        System.runAs( commUsr ){
            Test.startTest();
            List<HealthCloudGA__EhrImmunization__c> accImmunizations = KHC_ImmunizationsController.getImmunizations();
            System.assertEquals( 2, accImmunizations.size(), 'There should be only 2 records with the selected person account');
            Test.stopTest();
        }
    }

    @isTest
    static void getImmunizationsForInternalUser(){
        User usr = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs( usr ){
            Test.startTest();
            List<HealthCloudGA__EhrImmunization__c> accImmunizations = KHC_ImmunizationsController.getImmunizations();
            System.assertEquals( null, accImmunizations, 'The list should return null as account id is blank.');
            Test.stopTest();
        }
    }
}
