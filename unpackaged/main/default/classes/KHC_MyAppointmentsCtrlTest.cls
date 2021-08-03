@isTest
public class KHC_MyAppointmentsCtrlTest {
    Static String testingEmail = 'test@test.com';
    
    @TestSetup
    static void makeData(){
        Account a = MKH_TestDataFactory.createPersonAccount('First', 'Last', testingEmail, true);
        Contact con = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = :a.Id];
        MKH_TestDataFactory.createCommunityUser( con, true, true);
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        List<HealthCloudGA__EhrEncounter__c> encounters = new List<HealthCloudGA__EhrEncounter__c>();
        System.runAs( commUsr ) {
            encounters.addAll(KHC_TestUtility.insertEhrEncounters(null, 'Empty Account', 5, false));
            encounters.add(KHC_TestUtility.insertEhrEncounter(commUsr.AccountId, 'Provider 1', false));
            encounters.add(KHC_TestUtility.insertEhrEncounter(commUsr.AccountId, 'Provider 2', false));
            INSERT encounters;
        }
    }

    @isTest
    static void getAppointmentsForCommUser(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];

        System.runAs( commUsr ){
            Test.startTest();
            List<HealthCloudGA__EhrEncounter__c> accAppointments = KHC_MyAppointmentsCtrl.getAppointments();
            System.assertEquals( 2, accAppointments.size(), 'There should be only 2 records with the selected person account');
            Test.stopTest();
        }
    }

    @isTest
    static void getImmunizationsForInternalUser(){
        User usr = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs( usr ){
            Test.startTest();
            List<HealthCloudGA__EhrEncounter__c> accAppointments = KHC_MyAppointmentsCtrl.getAppointments();
            System.assertEquals( null, accAppointments, 'The list should return null as account id is blank.');
            Test.stopTest();
        }
    }
}