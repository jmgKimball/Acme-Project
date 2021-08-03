@isTest
public with sharing class MedicationSelectorTest {
    @TestSetup
    static void setupTestData(){
        List<Medication__c> medications = new List<Medication__c>();
        medications.addAll( KHC_TestUtility.insertMedications( 'Test Medicine', 100, false) );
        medications.add( KHC_TestUtility.insertMedication( 'Advil', false ) );
        INSERT medications;
    }

    @isTest
    public static void unitTestSelectAll(){
        MedicationSelector medicationSelector = new MedicationSelector();
        List<Medication__c> medications = medicationSelector.selectAll();
        System.assertEquals( 101, medications.size(), 'Total medications should be 101');
    }

    @isTest
    public static void unitTestSelectByName(){
        MedicationSelector medicationSelector = new MedicationSelector();
        List<Medication__c> medications = medicationSelector.selectByName( 'Advil' );
        System.assertEquals( 1, medications.size(), 'There should be only one medication with Advil');
    }
}