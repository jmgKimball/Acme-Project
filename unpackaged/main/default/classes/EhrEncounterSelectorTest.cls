@isTest
public inherited sharing class EhrEncounterSelectorTest {

    Static String testingEmail = 'test@test.com';

    @TestSetup
    static void makeData(){
        Account a = MKH_TestDataFactory.createPersonAccount('First', 'Last', testingEmail, true);
        Contact con = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = :a.Id];
        MKH_TestDataFactory.createCommunityUser( con, true, true);
    }

    @isTest
    static void getAppointmentsByAccountId(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];

        System.runAs( commUsr ){
            List<HealthCloudGA__EhrEncounter__c> encounters = new List<HealthCloudGA__EhrEncounter__c>();
            encounters.addAll( KHC_TestUtility.insertEhrEncounters( null, 'Empty Account', 5, false ) );
            encounters.add( KHC_TestUtility.insertEhrEncounter( commUsr.AccountId, 'Provider 1', false ) );
            encounters.add( KHC_TestUtility.insertEhrEncounter( commUsr.AccountId, 'Provider 2', false ) );
            INSERT encounters;

            Test.startTest();
            EhrEncounterSelector encounterSelector = new EhrEncounterSelector();
            List<HealthCloudGA__EhrEncounter__c> accEncounters = encounterSelector.getAppointmentsByPatientId( commUsr.AccountId );
            System.assertEquals( 2, accEncounters.size(), 'There should be only 2 records with the selected person account');
            Test.stopTest();
        }
    }
    @isTest
    static void getAppointmentsByBlankAccountId(){
        User usr = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs( usr ){
            Test.startTest();
            EhrEncounterSelector encounterSelector = new EhrEncounterSelector();
            List<HealthCloudGA__EhrEncounter__c> appointments = encounterSelector.getAppointmentsByPatientId( null );
            System.assertEquals( null, appointments, 'The list should return null elements as account id is blank.');
            Test.stopTest();
        }
    }
}