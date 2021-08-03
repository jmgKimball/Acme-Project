/**
 * Created by vupneja on 1/22/2021.
 */
@isTest
public with sharing class KHC_AllergyControllerTest {

    Static String testingEmail = 'test@test.com';

    @TestSetup
    static void makeData(){
        Account a = MKH_TestDataFactory.createPersonAccount('First', 'Last', testingEmail, true);
        Contact con = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = :a.Id];
        MKH_TestDataFactory.createCommunityUser( con, true, true);
    }

    @isTest
    static void getAllergyForCommUser(){

        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        List<HealthCloudGA__EhrAllergyIntolerance__c> allergies = new List<HealthCloudGA__EhrAllergyIntolerance__c>();
        //allergies.addAll( KHC_TestUtility.insertEhrAllergyIntolerances( null, 'Food Allergy','Pain', 5, false ) );
        allergies.add( KHC_TestUtility.insertEhrAllergyIntolerance( commUsr.AccountId, 'Materials Allergy','Cough', false ) );
        allergies.add( KHC_TestUtility.insertEhrAllergyIntolerance( commUsr.AccountId, 'Medication Allergy', 'Pain',false ) );
        INSERT allergies;

        system.runAs(commUsr) {
            Test.startTest();
            List<HealthCloudGA__EhrAllergyIntolerance__c> accAllergies = KHC_AllergyController.getAllergies();
            System.assertEquals( 2, accAllergies.size(), 'There should be only 2 records with the selected person account');
            Test.stopTest();
        }
    }

}